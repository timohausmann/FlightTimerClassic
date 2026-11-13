"""0.6 routes in Data.lua, keyed by flight-map pin hash.

The hash is floor(TaxiNodePosition x * 1e8). The name is the label the old
addon showed, which is the flight master name before the comma.
"""

import re
from collections import defaultdict
from pathlib import Path

# TaxiNodes.Flags bits. A neutral master such as Ratchet has both.
ALLIANCE_FLAG = 1
HORDE_FLAG = 2

HASH_TO_NAME = {
    "31353121": "Feathermoon",
    "31660270": "Shadowprey Village",
    "38447540": "The Sepulcher",
    "39064586": "Stonetalon Peak",
    "39622759": "Nijel's Point",
    "40741020": "Sentinel Hill",
    "40795725": "Sun Rock Retreat",
    "40973830": "Zoram'gar Outpost",
    "41614419": "Rut'theran Village",
    "41632127": "Cenarion Hold",
    "41897988": "Cenarion Hold",
    "42778635": "Auberdine",
    "43159055": "Booty Bay",
    "43250447": "Stormwind",
    "43367666": "Booty Bay",
    "44250988": "Camp Mojache",
    "44267696": "Undercity",
    "44825941": "Grom'gol",
    "44947779": "Thunder Bluff",
    "46258175": "Astranaar",
    "46455299": "Bloodvenom Post",
    "47861999": "Southshore",
    "48257559": "Thalanaar",
    "49090653": "Menethil Harbor",
    "49442172": "Tarren Mill",
    "49764585": "Marshal's Refuge",
    "50543880": "Thorium Point",
    "50797998": "Ironforge",
    "50856858": "Thorium Point",
    "51285266": "Darkshire",
    "52058124": "Chillwind Camp",
    "52804720": "Camp Taurajo",
    "53079825": "Talonbranch Glade",
    "53793668": "Moonglade",
    "54685318": "Aerie Peak",
    "54988908": "Freewind Post",
    "55288457": "Moonglade",
    "55441868": "Splintertree Post",
    "55498695": "Kargath",
    "55533051": "Flame Crest",
    "55734276": "Lakeshire",
    "55735743": "Crossroads",
    "56746834": "Brackenwall Village",
    "57035875": "Refuge Pointe",
    "58060050": "Morgan's Vigil",
    "58939349": "Thelsamar",
    "60413265": "Gadgetzan",
    "60541588": "Stonard",
    "60571116": "Ratchet",
    "60601317": "Gadgetzan",
    "61013311": "Talrendis Point",
    "61259531": "Nethergarde Keep",
    "61540073": "Hammerfall",
    "62800776": "Orgrimmar",
    "63107562": "Valormok",
    "63626050": "Theramore",
    "64014458": "Everlook",
    "64553982": "Everlook",
    "67153739": "Revantusk Village",
    "69752216": "Light's Hope Chapel",
    "69999539": "Light's Hope Chapel",
}


def short_name(name):
    return name.split(",")[0].strip()


def load_routes(path):
    """Faction -> source hash -> dest hash -> seconds. Hashes stay strings."""
    text = Path(path).read_text(encoding="utf-8")
    faction = None
    current = None
    routes = {"Alliance": {}, "Horde": {}}
    for line in text.splitlines():
        stripped = line.strip().rstrip(",")
        if stripped in ("Alliance = {", "Horde = {"):
            faction = stripped.split()[0]
            continue
        source = re.fullmatch(r"\['(\d+)'\] = \{", stripped)
        if source and faction:
            current = source.group(1)
            routes[faction].setdefault(current, {})
            continue
        pair = re.fullmatch(r"\['(\d+)'\] = (\d+)", stripped)
        if pair and faction and current:
            routes[faction][current][pair.group(1)] = int(pair.group(2))
    return routes


def bind_hashes(records):
    """Faction -> hash -> node id.

    records is node id -> (full name, TaxiNodes.Flags).
    A hash with no node, or two nodes, is a hard error: the pin map would be a guess.
    """
    by_label = {"Alliance": defaultdict(list), "Horde": defaultdict(list)}
    for node_id, (name, flags) in records.items():
        label = short_name(name)
        if flags & ALLIANCE_FLAG:
            by_label["Alliance"][label].append(node_id)
        if flags & HORDE_FLAG:
            by_label["Horde"][label].append(node_id)
    return by_label


def node_ids_for(routes, records):
    """Faction -> hash -> node id, for every hash the routes use."""
    by_label = bind_hashes(records)
    problems = []
    bound = {"Alliance": {}, "Horde": {}}
    for faction, rows in routes.items():
        hashes = set(rows)
        for dests in rows.values():
            hashes.update(dests)
        for hash_id in sorted(hashes):
            label = HASH_TO_NAME.get(hash_id)
            if label is None:
                problems.append("Data.lua hash %s has no name" % hash_id)
                continue
            matches = by_label[faction].get(label, [])
            if len(matches) != 1:
                problems.append(
                    "%s hash %s %r matches %s"
                    % (faction, hash_id, label, matches or "nothing")
                )
                continue
            bound[faction][hash_id] = matches[0]
    if problems:
        raise SystemExit("\n".join(problems))
    return bound


def measured_candidates(routes, bound):
    """(source node, dest node) -> every stored duration, both factions.

    A neutral master is one node, so both factions can store that same pair.
    """
    found = defaultdict(list)
    for faction, rows in routes.items():
        ids = bound[faction]
        for src_hash, dests in rows.items():
            src = ids[src_hash]
            for dst_hash, seconds in dests.items():
                dst = ids[dst_hash]
                if src == dst or seconds <= 0:
                    continue
                found[(src, dst)].append(seconds)
    return found
