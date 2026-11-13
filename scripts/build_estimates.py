#!/usr/bin/env python3
"""Build the per-game direct flights on top of Data.lua.

Data.lua holds the measured routes, shared by both games. This script writes
direct flights that table does not have, and direct flights whose path length
misses the stored time by more than DIRECT_REPLACE_SECONDS. A pair in the
game file replaces the same pair in Data.lua.

No arguments writes every game. --game forever or --game vanilla writes one.
--from-legacy rebuilds Data.lua from scripts/data/DataLegacy.lua. That is not part of a
normal run.
"""

import csv
import heapq
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

import legacy_nodes

# TaxiPathNode.Flags bit that means this waypoint's Delay is part of the flight.
DELAY_FLAG = 2

DROP_PREFIXES = (
    "Quest Path",
    "zzOLD",
    "Transport",
    "Generic",
    "Programmer Isle",
)

# A stored direct flight is replaced when the path length misses it by more
# than this. Same margin as the addon's correction nag.
DIRECT_REPLACE_SECONDS = 2

# Flown routes, no Frequent Flier. The result must land within 2 seconds,
# the same margin the addon uses before it calls a time a correction.
# (source, dest, min seconds, max seconds)
FOREVER_EDGES = (
    (2, 4, 77, 81),  # Stormwind -> Sentinel Hill, flew 79
    (2, 5, 112, 116),  # Stormwind -> Lakeshire, flew 114
    (2, 6, 258, 262),  # Stormwind -> Ironforge, flew 260
    (4, 12, 95, 99),  # Sentinel Hill -> Darkshire, flew 97
    (5, 12, 59, 63),  # Lakeshire -> Darkshire, flew 61
    (6, 14, 263, 267),  # Ironforge -> Southshore, flew 265
)

# Whole routes from Data.lua, including stops. The leg sum is longer.
MEASURED_ROUTES = (
    (2, 7, 341, 345),  # Stormwind -> Menethil Harbor, 343
    (2, 14, 441, 445),  # Stormwind -> Southshore, 443
    (37, 27, 365, 369),  # Nijel's Point -> Rut'theran Village, 367
)

BANNED_COMMENT_TEXT = ("Quest Path", "Transport")

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

ROOT = Path(__file__).resolve().parents[1]
CACHE_DIR = ROOT / "scripts" / "data" / "wago"

# One row per TOC game type. Output names match Data<Game>.lua.
GAMES = (
    {
        "name": "forever",
        "title": "WoW Forever",
        "product": "wowf",
        "output": ROOT / "DataForever.lua",
        "yards_per_second": 30,
        "required_edges": FOREVER_EDGES + MEASURED_ROUTES,
    },
    {
        "name": "vanilla",
        "title": "Classic Era",
        "product": "wow_classic_era",
        "output": ROOT / "DataVanilla.lua",
        "yards_per_second": 30,
        "required_edges": MEASURED_ROUTES,
    },
)

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


def read_builds_page():
    """Front page text. Each game's current build is a product/version pair."""
    page = fetch_bytes("https://wago.tools/").decode("utf-8", "replace")
    return html.unescape(page)


def read_build(page, product):
    """Build id for one wago product, from the front page."""
    match = re.search(
        r'"product"\s*:\s*"%s"\s*,\s*"version"\s*:\s*"(\d+\.\d+\.\d+\.\d+)"'
        % re.escape(product),
        page,
    )
    if not match:
        raise SystemExit("Build for %s was not on https://wago.tools/" % product)
    return match.group(1)


def download_tables(build, product):
    """Cache CSVs per product so two games do not overwrite each other."""
    cache = CACHE_DIR / product
    cache.mkdir(parents=True, exist_ok=True)
    paths = {}
    for name in TABLES:
        url = "https://wago.tools/db2/%s/csv?build=%s" % (name, build)
        dest = cache / ("%s.csv" % name)
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
    """Node id -> (name, faction flags). Pos is the flight master in the world."""
    records = {}
    for row in read_csv(path):
        node_id = as_int(row["ID"])
        name = row.get("Name_lang") or ""
        if node_id == 0 or dropped_name(name):
            continue
        records[node_id] = (name, as_int(row.get("Flags")))
    return records


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


def estimate_seconds(points, yards_per_second):
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
            elapsed += math.sqrt(dx * dx + dy * dy + dz * dz) / yards_per_second
        if flags & DELAY_FLAG:
            elapsed += delay
        previous = (continent, x, y, z)
    # Half away from zero. Times are positive, so floor(n + 0.5) matches that.
    rounded = int(math.floor(elapsed + 0.5))
    if rounded < 1:
        return 1
    return rounded


def load_estimates(path, paths, yards_per_second):
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
        seconds = estimate_seconds(points, yards_per_second)
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


def shortest_route(edges, src, dst):
    """(seconds, hops) of the quickest sum of direct legs, or None."""
    best = {src: (0, 0)}
    heap = [(0, src)]
    while heap:
        seconds, node = heapq.heappop(heap)
        if seconds != best[node][0]:
            continue
        if node == dst and node != src:
            return best[node]
        for nxt, leg in edges.get(node, {}).items():
            cand = seconds + leg
            prev = best.get(nxt)
            if prev is None or cand < prev[0]:
                best[nxt] = (cand, best[node][1] + 1)
                heapq.heappush(heap, (cand, nxt))
    return None


def lua_comment(name):
    cleaned = "".join(ch if ch >= " " else " " for ch in name).strip()
    return cleaned


def render(header, table_name, names, edges):
    lines = list(header)
    lines.append("%s = {" % table_name)
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


def load_base(path):
    """Node id -> dest id -> seconds from Data.lua. Missing file is an error."""
    base_path = Path(path)
    if not base_path.is_file():
        raise SystemExit("Missing %s. Rebuild it with --from-legacy." % base_path.name)
    edges = defaultdict(dict)
    source = None
    for line in base_path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip().rstrip(",")
        opened = re.fullmatch(r"\[(\d+)\] = \{.*", stripped)
        if opened:
            source = int(opened.group(1))
            continue
        pair = re.fullmatch(r"\[(\d+)\] = (\d+).*", stripped)
        if pair and source is not None:
            edges[source][int(pair.group(1))] = int(pair.group(2))
            continue
        if stripped == "}":
            source = None
    return edges


def game_directs(estimates, base):
    """Direct flights to write for one game.

    A pair is included when Data.lua has no time for it, or when the path
    length misses the stored time by more than DIRECT_REPLACE_SECONDS.
    Replacements are (source, dest, stored, path seconds), sorted.
    """
    extra = defaultdict(dict)
    replaced = []
    for source, dests in estimates.items():
        known = base.get(source, {})
        for dest, seconds in dests.items():
            stored = known.get(dest)
            if stored is None:
                extra[source][dest] = seconds
            elif abs(seconds - stored) > DIRECT_REPLACE_SECONDS:
                extra[source][dest] = seconds
                replaced.append((source, dest, stored, seconds))
    replaced.sort()
    return extra, replaced


def overlay(base, extra):
    """Same merge the addon does. A pair in the game file replaces Data.lua."""
    merged = defaultdict(dict)
    for source, dests in base.items():
        merged[source].update(dests)
    for source, dests in extra.items():
        merged[source].update(dests)
    return merged


def validate(edges, text, required_edges):
    problems = []
    for source, dest, low, high in required_edges:
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


def report(game, build, edges):
    count = sum(len(dests) for dests in edges.values())
    print("%s (%s)" % (game["title"], game["name"]))
    print("Build: %s" % build)
    print("Edges: %d" % count)
    for source, dest, _low, _high in game["required_edges"]:
        seconds = edges.get(source, {}).get(dest)
        if seconds is None:
            print("%d -> %d: missing" % (source, dest))
        else:
            print("%d -> %d: %ds" % (source, dest, seconds))


def game_by_name(name):
    for game in GAMES:
        if game["name"] == name:
            return game
    known = ", ".join(game["name"] for game in GAMES)
    raise SystemExit("Unknown game %r. Choose one of: %s" % (name, known))


def selected_games(argv):
    """No flag writes every game. --game <name> writes that one."""
    if len(argv) == 1:
        return GAMES
    if len(argv) == 3 and argv[1] == "--game":
        return (game_by_name(argv[2]),)
    raise SystemExit(
        "Usage: python3 scripts/build_estimates.py [--game forever|vanilla | --from-legacy]"
    )


def choose_conflicts(candidates, estimates):
    """One duration per pair. Two faction times: keep the one nearer the leg sum."""
    chosen = defaultdict(dict)
    conflicts = []
    for src, dst in sorted(candidates):
        times = sorted(set(candidates[(src, dst)]))
        if len(times) == 1:
            chosen[src][dst] = times[0]
            continue
        found = shortest_route(estimates, src, dst)
        if found is None:
            # No path to judge by. The shorter stored time is the one that
            # agrees with the other measured routes, which run under the sum.
            pick = times[0]
        else:
            total = found[0]
            pick = min(times, key=lambda seconds: (abs(seconds - total), seconds))
        chosen[src][dst] = pick
        conflicts.append((src, dst, times, pick, None if found is None else found[0]))
    return chosen, conflicts


def measured_from_legacy(records, estimates):
    """DataLegacy.lua hashes as node-id pairs. Needs the taxi nodes for names."""
    import legacy_nodes

    names = {node_id: name for node_id, (name, _flags) in records.items()}
    routes = legacy_nodes.load_routes(ROOT / "scripts" / "data" / "DataLegacy.lua")
    bound = legacy_nodes.node_ids_for(routes, records)
    candidates = legacy_nodes.measured_candidates(routes, bound)
    present = {}
    for (src, dst), times in candidates.items():
        if src in names and dst in names:
            present[(src, dst)] = times
    chosen, conflicts = choose_conflicts(present, estimates)
    return names, chosen, conflicts


def write_legacy_base(page):
    """Write Data.lua from DataLegacy.lua. Not used by a normal build."""
    game = game_by_name("vanilla")
    build = read_build(page, game["product"])
    tables = download_tables(build, game["product"])
    records = load_nodes(tables["TaxiNodes"])
    names = {node_id: name for node_id, (name, _flags) in records.items()}
    paths = load_paths(tables["TaxiPath"], names)
    estimates = load_estimates(tables["TaxiPathNode"], paths, game["yards_per_second"])
    names, chosen, conflicts = measured_from_legacy(records, estimates)
    header = [
        "-- Measured routes for both games, by flight-master node id.",
        "-- Converted once from scripts/data/DataLegacy.lua.",
        "-- A game file can replace a direct flight it times differently.",
    ]
    text = render(header, "FTCData", names, chosen)
    (ROOT / "Data.lua").write_bytes(text.encode("utf-8"))
    count = sum(len(dests) for dests in chosen.values())
    print("Wrote Data.lua (%d routes)" % count)
    for src, dst, times, pick, total in conflicts:
        print(
            "Two times for %s -> %s: %s, chose %ds (legs %s)"
            % (
                names.get(src, str(src)).split(",")[0],
                names.get(dst, str(dst)).split(",")[0],
                ", ".join("%ds" % seconds for seconds in times),
                pick,
                "none" if total is None else "%ds" % total,
            )
        )
    return True


def build_game(page, game, base):
    """Download one product and write its direct-flight file."""
    build = read_build(page, game["product"])
    tables = download_tables(build, game["product"])
    records = load_nodes(tables["TaxiNodes"])
    names = {node_id: name for node_id, (name, _flags) in records.items()}
    paths = load_paths(tables["TaxiPath"], names)
    estimates = load_estimates(tables["TaxiPathNode"], paths, game["yards_per_second"])
    extra, replaced = game_directs(estimates, base)
    merged = overlay(base, extra)
    header = [
        "-- Direct flights for %s (%s)." % (game["title"], game["name"]),
        "-- Path length when Data.lua has no time, or misses it by more than %ds."
        % DIRECT_REPLACE_SECONDS,
        "-- A pair here replaces the same pair in Data.lua.",
        "-- Build: %s" % build,
        "-- TAXI_YARDS_PER_SECOND: %d" % game["yards_per_second"],
        "-- Generated: %s" % date.today().isoformat(),
        "-- python3 scripts/build_estimates.py --game %s" % game["name"],
    ]
    text = render(header, "FTCExtra", names, extra)
    problems = validate(merged, text, game["required_edges"])
    report(game, build, merged)
    extra_count = sum(len(dests) for dests in extra.values())
    print("Extra direct flights: %d (%d replace Data.lua)" % (extra_count, len(replaced)))
    for source, dest, stored, seconds in replaced:
        print(
            "  %s -> %s: Data.lua %ds, path %ds"
            % (
                names.get(source, str(source)).split(",")[0],
                names.get(dest, str(dest)).split(",")[0],
                stored,
                seconds,
            )
        )
    if problems:
        for problem in problems:
            print(problem, file=sys.stderr)
        return False
    game["output"].write_bytes(text.encode("utf-8"))
    print("Wrote %s" % game["output"].name)
    return True


def main(argv):
    if len(argv) == 2 and argv[1] == "--from-legacy":
        return 0 if write_legacy_base(read_builds_page()) else 1
    games = selected_games(argv)
    base = load_base(ROOT / "Data.lua")
    page = read_builds_page()
    failed = False
    for game in games:
        if not build_game(page, game, base):
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
