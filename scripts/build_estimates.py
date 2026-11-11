#!/usr/bin/env python3
"""Build Data.lua from the Forever taxi tables on wago.tools.

Direct edges only. Measured flights stay in FTCCustomData.
"""

import csv
import html
import io
import math
import re
import sys
import urllib.error
import urllib.request
from collections import defaultdict
from datetime import date
from pathlib import Path

# Flight speed used to turn path length into seconds. Change this after a real
# flight and regenerate; Lua stores the rounded seconds and does not rescale.
TAXI_YARDS_PER_SECOND = 30

# TaxiPathNode.Flags bit that means this waypoint's Delay is part of the flight.
DELAY_FLAG = 2

DROP_PREFIXES = (
    "Quest Path",
    "zzOLD",
    "Transport",
    "Generic",
    "Programmer Isle",
)

# (source, dest, min seconds, max seconds). The build is wrong if these fail.
REQUIRED_EDGES = (
    (2, 4, 20, 240),
    (3203, 56, 20, 600),
)

BANNED_COMMENT_TEXT = ("Quest Path", "Transport")

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

ROOT = Path(__file__).resolve().parents[1]
CACHE_DIR = ROOT / "scripts" / "data" / "wago"
DATA_LUA = ROOT / "Data.lua"

TABLES = ("TaxiNodes", "TaxiPath", "TaxiPathNode")


def fetch_bytes(url):
    """GET url. A 403 is retried once with a normal browser User-Agent."""
    last_error = None
    for agent in (None, BROWSER_UA):
        request = urllib.request.Request(url)
        if agent:
            request.add_header("User-Agent", agent)
        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                return response.read()
        except urllib.error.HTTPError as error:
            last_error = error
            # The default client is refused with 403, and sometimes with 400.
            if error.code not in (400, 403) or agent:
                raise
    raise last_error


def read_forever_build():
    """Build id from the Forever (wowf) row on the wago.tools front page."""
    page = fetch_bytes("https://wago.tools/").decode("utf-8", "replace")
    text = html.unescape(page)
    match = re.search(
        r'"product"\s*:\s*"wowf"\s*,\s*"version"\s*:\s*"(\d+\.\d+\.\d+\.\d+)"',
        text,
    )
    if not match:
        raise SystemExit("Forever build (wowf) was not on https://wago.tools/")
    return match.group(1)


def download_tables(build):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    paths = {}
    for name in TABLES:
        url = "https://wago.tools/db2/%s/csv?build=%s" % (name, build)
        dest = CACHE_DIR / ("%s.csv" % name)
        dest.write_bytes(fetch_bytes(url))
        paths[name] = dest
    return paths


def read_csv(path):
    raw = path.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    return csv.DictReader(io.StringIO(raw.decode("utf-8")))


def as_int(value):
    if value is None or value == "":
        return 0
    return int(float(value))


def as_float(value):
    if value is None or value == "":
        return 0.0
    return float(value)


def dropped_name(name):
    return bool(name) and name.startswith(DROP_PREFIXES)


def load_nodes(path):
    """Node id -> name. Pos is the flight master in the world, not the map."""
    names = {}
    for row in read_csv(path):
        node_id = as_int(row["ID"])
        name = row.get("Name_lang") or ""
        if node_id == 0 or dropped_name(name):
            continue
        names[node_id] = name
    return names


def load_paths(path, names):
    """Path id -> (source node, dest node). Cost is the copper price and unused."""
    paths = {}
    for row in read_csv(path):
        source = as_int(row["FromTaxiNode"])
        dest = as_int(row["ToTaxiNode"])
        if source == 0 or dest == 0 or source == dest:
            continue
        if source not in names or dest not in names:
            continue
        paths[as_int(row["ID"])] = (source, dest)
    return paths


def estimate_seconds(points):
    """Seconds for one path, or None when the path leaves its continent.

    points are (continent, x, y, z, flags, delay) sorted by NodeIndex.
    """
    if len(points) < 2:
        return None
    elapsed = 0.0
    previous = None
    for continent, x, y, z, flags, delay in points:
        if previous is not None:
            if continent != previous[0]:
                return None
            dx = x - previous[1]
            dy = y - previous[2]
            dz = z - previous[3]
            elapsed += math.sqrt(dx * dx + dy * dy + dz * dz) / TAXI_YARDS_PER_SECOND
        if flags & DELAY_FLAG:
            elapsed += delay
        previous = (continent, x, y, z)
    # Half away from zero. Times are positive, so floor(n + 0.5) matches that.
    rounded = int(math.floor(elapsed + 0.5))
    if rounded < 1:
        return 1
    return rounded


def load_estimates(path, paths):
    """(source, dest) -> seconds. Same pair: keep the path with the most points."""
    grouped = defaultdict(list)
    for row in read_csv(path):
        path_id = as_int(row["PathID"])
        if path_id not in paths:
            continue
        grouped[path_id].append(
            (
                as_int(row["NodeIndex"]),
                as_int(row["ContinentID"]),
                as_float(row["Loc_0"]),
                as_float(row["Loc_1"]),
                as_float(row["Loc_2"]),
                as_int(row["Flags"]),
                as_float(row["Delay"]),
            )
        )

    chosen = {}
    for path_id in sorted(grouped):
        rows = sorted(grouped[path_id])
        points = [row[1:] for row in rows]
        seconds = estimate_seconds(points)
        if seconds is None:
            continue
        source, dest = paths[path_id]
        current = chosen.get((source, dest))
        if current is None or len(points) > current[0]:
            chosen[(source, dest)] = (len(points), seconds)

    edges = defaultdict(dict)
    for (source, dest), (_count, seconds) in chosen.items():
        edges[source][dest] = seconds
    return edges


def lua_comment(name):
    cleaned = "".join(ch if ch >= " " else " " for ch in name).strip()
    return cleaned


def render(build, names, edges):
    lines = [
        "-- Direct flight estimates for WoW Forever. Measured routes live in FTCCustomData.",
        "-- Build: %s" % build,
        "-- TAXI_YARDS_PER_SECOND: %d" % TAXI_YARDS_PER_SECOND,
        "-- Generated: %s" % date.today().isoformat(),
        "-- python3 scripts/build_estimates.py",
        "FTCData = {",
    ]
    for source in sorted(edges):
        lines.append("  [%d] = { -- %s" % (source, lua_comment(names.get(source, ""))))
        for dest in sorted(edges[source]):
            lines.append(
                "    [%d] = %d, -- %s"
                % (dest, edges[source][dest], lua_comment(names.get(dest, "")))
            )
        lines.append("  },")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def validate(edges, text):
    problems = []
    for source, dest, low, high in REQUIRED_EDGES:
        seconds = edges.get(source, {}).get(dest)
        if seconds is None:
            problems.append("missing edge %d -> %d" % (source, dest))
        elif seconds < low or seconds > high:
            problems.append(
                "edge %d -> %d is %ds, expected %d..%d" % (source, dest, seconds, low, high)
            )
    for banned in BANNED_COMMENT_TEXT:
        if banned in text:
            problems.append("output contains %r" % banned)
    return problems


def report(build, edges):
    count = sum(len(dests) for dests in edges.values())
    print("Build: %s" % build)
    print("Edges: %d" % count)
    for source, dest, _low, _high in REQUIRED_EDGES:
        seconds = edges.get(source, {}).get(dest)
        if seconds is None:
            print("%d -> %d: missing" % (source, dest))
        else:
            print("%d -> %d: %ds" % (source, dest, seconds))


def main():
    build = read_forever_build()
    tables = download_tables(build)
    names = load_nodes(tables["TaxiNodes"])
    paths = load_paths(tables["TaxiPath"], names)
    edges = load_estimates(tables["TaxiPathNode"], paths)
    text = render(build, names, edges)
    problems = validate(edges, text)
    report(build, edges)
    if problems:
        for problem in problems:
            print(problem, file=sys.stderr)
        return 1
    DATA_LUA.write_bytes(text.encode("utf-8"))
    print("Wrote %s" % DATA_LUA.name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
