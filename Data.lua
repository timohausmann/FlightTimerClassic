-- Direct flight estimates for WoW Forever. Measured routes live in FTCCustomData.
-- Build: 1.60.1.70888
-- TAXI_YARDS_PER_SECOND: 32
-- Generated: 2026-11-10
-- python3 scripts/build_estimates.py
FTCData = {
  [2] = { -- Stormwind, Elwynn
    [4] = 73, -- Sentinel Hill, Westfall
    [5] = 106, -- Lakeshire, Redridge
    [6] = 242, -- Ironforge, Dun Morogh
    [12] = 109, -- Darkshire, Duskwood
    [19] = 229, -- Booty Bay, Stranglethorn
    [45] = 165, -- Nethergarde Keep, Blasted Lands
    [71] = 147, -- Morgan's Vigil, Burning Steppes
  },
  [4] = { -- Sentinel Hill, Westfall
    [2] = 76, -- Stormwind, Elwynn
    [5] = 122, -- Lakeshire, Redridge
    [12] = 91, -- Darkshire, Duskwood
    [19] = 174, -- Booty Bay, Stranglethorn
  },
  [5] = { -- Lakeshire, Redridge
    [2] = 105, -- Stormwind, Elwynn
    [4] = 125, -- Sentinel Hill, Westfall
    [12] = 57, -- Darkshire, Duskwood
    [71] = 57, -- Morgan's Vigil, Burning Steppes
    [3276] = 124, -- Farholde Keep, Riverglades
  },
  [6] = { -- Ironforge, Dun Morogh
    [2] = 197, -- Stormwind, Elwynn
    [7] = 121, -- Menethil Harbor, Wetlands
    [8] = 95, -- Thelsamar, Loch Modan
    [14] = 248, -- Southshore, Hillsbrad
    [16] = 237, -- Refuge Pointe, Arathi
    [43] = 279, -- Aerie Peak, The Hinterlands
    [66] = 276, -- Chillwind Camp, Western Plaguelands
    [67] = 326, -- Light's Hope Chapel, Eastern Plaguelands
    [74] = 81, -- Thorium Point, Searing Gorge
  },
  [7] = { -- Menethil Harbor, Wetlands
    [6] = 83, -- Ironforge, Dun Morogh
    [8] = 152, -- Thelsamar, Loch Modan
    [14] = 100, -- Southshore, Hillsbrad
    [16] = 106, -- Refuge Pointe, Arathi
  },
  [8] = { -- Thelsamar, Loch Modan
    [6] = 102, -- Ironforge, Dun Morogh
    [7] = 143, -- Menethil Harbor, Wetlands
    [16] = 153, -- Refuge Pointe, Arathi
    [3276] = 173, -- Farholde Keep, Riverglades
  },
  [10] = { -- The Sepulcher, Silverpine Forest
    [11] = 105, -- Undercity, Tirisfal
    [13] = 90, -- Tarren Mill, Hillsbrad
  },
  [11] = { -- Undercity, Tirisfal
    [10] = 99, -- The Sepulcher, Silverpine Forest
    [13] = 132, -- Tarren Mill, Hillsbrad
    [17] = 282, -- Hammerfall, Arathi
    [21] = 464, -- Kargath, Badlands
    [60] = 15, -- Frostwolf Keep, Alterac Valley
    [68] = 245, -- Light's Hope Chapel, Eastern Plaguelands
    [76] = 267, -- Revantusk Village, The Hinterlands
  },
  [12] = { -- Darkshire, Duskwood
    [2] = 82, -- Stormwind, Elwynn
    [4] = 87, -- Sentinel Hill, Westfall
    [5] = 56, -- Lakeshire, Redridge
    [19] = 160, -- Booty Bay, Stranglethorn
    [45] = 91, -- Nethergarde Keep, Blasted Lands
  },
  [13] = { -- Tarren Mill, Hillsbrad
    [10] = 93, -- The Sepulcher, Silverpine Forest
    [11] = 130, -- Undercity, Tirisfal
    [17] = 110, -- Hammerfall, Arathi
    [76] = 182, -- Revantusk Village, The Hinterlands
  },
  [14] = { -- Southshore, Hillsbrad
    [6] = 193, -- Ironforge, Dun Morogh
    [7] = 103, -- Menethil Harbor, Wetlands
    [16] = 69, -- Refuge Pointe, Arathi
    [43] = 67, -- Aerie Peak, The Hinterlands
    [66] = 76, -- Chillwind Camp, Western Plaguelands
  },
  [16] = { -- Refuge Pointe, Arathi
    [6] = 253, -- Ironforge, Dun Morogh
    [7] = 118, -- Menethil Harbor, Wetlands
    [8] = 160, -- Thelsamar, Loch Modan
    [14] = 81, -- Southshore, Hillsbrad
    [43] = 67, -- Aerie Peak, The Hinterlands
  },
  [17] = { -- Hammerfall, Arathi
    [11] = 243, -- Undercity, Tirisfal
    [13] = 109, -- Tarren Mill, Hillsbrad
    [21] = 243, -- Kargath, Badlands
    [76] = 85, -- Revantusk Village, The Hinterlands
    [3203] = 305, -- Rog'mar, Riverglades
  },
  [18] = { -- Booty Bay, Stranglethorn
    [20] = 95, -- Grom'gol, Stranglethorn
    [21] = 381, -- Kargath, Badlands
    [56] = 250, -- Stonard, Swamp of Sorrows
  },
  [19] = { -- Booty Bay, Stranglethorn
    [2] = 206, -- Stormwind, Elwynn
    [4] = 170, -- Sentinel Hill, Westfall
    [12] = 164, -- Darkshire, Duskwood
  },
  [20] = { -- Grom'gol, Stranglethorn
    [18] = 76, -- Booty Bay, Stranglethorn
    [21] = 306, -- Kargath, Badlands
    [56] = 192, -- Stonard, Swamp of Sorrows
  },
  [21] = { -- Kargath, Badlands
    [11] = 466, -- Undercity, Tirisfal
    [17] = 246, -- Hammerfall, Arathi
    [18] = 390, -- Booty Bay, Stranglethorn
    [20] = 293, -- Grom'gol, Stranglethorn
    [56] = 263, -- Stonard, Swamp of Sorrows
    [70] = 81, -- Flame Crest, Burning Steppes
    [75] = 53, -- Thorium Point, Searing Gorge
    [3203] = 119, -- Rog'mar, Riverglades
  },
  [22] = { -- Thunder Bluff, Mulgore
    [23] = 194, -- Orgrimmar, Durotar
    [25] = 149, -- Crossroads, The Barrens
    [29] = 170, -- Sun Rock Retreat, Stonetalon Mountains
    [30] = 191, -- Freewind Post, Thousand Needles
    [38] = 148, -- Shadowprey Village, Desolace
    [40] = 272, -- Gadgetzan, Tanaris
    [42] = 236, -- Camp Mojache, Feralas
    [44] = 252, -- Valormok, Azshara
    [55] = 223, -- Brackenwall Village, Dustwallow Marsh
    [77] = 81, -- Camp Taurajo, The Barrens
  },
  [23] = { -- Orgrimmar, Durotar
    [22] = 211, -- Thunder Bluff, Mulgore
    [25] = 103, -- Crossroads, The Barrens
    [40] = 391, -- Gadgetzan, Tanaris
    [44] = 93, -- Valormok, Azshara
    [48] = 236, -- Bloodvenom Post, Felwood
    [53] = 299, -- Everlook, Winterspring
    [55] = 214, -- Brackenwall Village, Dustwallow Marsh
    [61] = 84, -- Splintertree Post, Ashenvale
  },
  [25] = { -- Crossroads, The Barrens
    [22] = 171, -- Thunder Bluff, Mulgore
    [23] = 133, -- Orgrimmar, Durotar
    [29] = 140, -- Sun Rock Retreat, Stonetalon Mountains
    [30] = 173, -- Freewind Post, Thousand Needles
    [40] = 284, -- Gadgetzan, Tanaris
    [42] = 236, -- Camp Mojache, Feralas
    [44] = 158, -- Valormok, Azshara
    [48] = 238, -- Bloodvenom Post, Felwood
    [55] = 152, -- Brackenwall Village, Dustwallow Marsh
    [58] = 216, -- Zoram'gar Outpost, Ashenvale
    [61] = 152, -- Splintertree Post, Ashenvale
    [77] = 85, -- Camp Taurajo, The Barrens
    [80] = 48, -- Ratchet, The Barrens
  },
  [26] = { -- Auberdine, Darkshore
    [27] = 79, -- Rut'theran Village, Teldrassil
    [28] = 165, -- Astranaar, Ashenvale
    [32] = 632, -- Theramore, Dustwallow Marsh
    [33] = 170, -- Stonetalon Peak, Stonetalon Mountains
    [37] = 273, -- Nijel's Point, Desolace
    [41] = 443, -- Feathermoon, Feralas
    [49] = 141, -- Moonglade
    [64] = 281, -- Talrendis Point, Azshara
    [65] = 178, -- Talonbranch Glade, Felwood
  },
  [27] = { -- Rut'theran Village, Teldrassil
    [26] = 80, -- Auberdine, Darkshore
  },
  [28] = { -- Astranaar, Ashenvale
    [26] = 138, -- Auberdine, Darkshore
    [33] = 144, -- Stonetalon Peak, Stonetalon Mountains
    [64] = 138, -- Talrendis Point, Azshara
  },
  [29] = { -- Sun Rock Retreat, Stonetalon Mountains
    [22] = 163, -- Thunder Bluff, Mulgore
    [25] = 140, -- Crossroads, The Barrens
    [38] = 134, -- Shadowprey Village, Desolace
  },
  [30] = { -- Freewind Post, Thousand Needles
    [22] = 211, -- Thunder Bluff, Mulgore
    [25] = 182, -- Crossroads, The Barrens
    [40] = 87, -- Gadgetzan, Tanaris
    [42] = 115, -- Camp Mojache, Feralas
    [77] = 128, -- Camp Taurajo, The Barrens
  },
  [31] = { -- Thalanaar, Feralas
    [32] = 149, -- Theramore, Dustwallow Marsh
    [39] = 160, -- Gadgetzan, Tanaris
    [41] = 167, -- Feathermoon, Feralas
  },
  [32] = { -- Theramore, Dustwallow Marsh
    [26] = 582, -- Auberdine, Darkshore
    [31] = 153, -- Thalanaar, Feralas
    [37] = 313, -- Nijel's Point, Desolace
    [39] = 147, -- Gadgetzan, Tanaris
    [64] = 220, -- Talrendis Point, Azshara
    [80] = 108, -- Ratchet, The Barrens
  },
  [33] = { -- Stonetalon Peak, Stonetalon Mountains
    [26] = 166, -- Auberdine, Darkshore
    [28] = 144, -- Astranaar, Ashenvale
    [37] = 119, -- Nijel's Point, Desolace
  },
  [37] = { -- Nijel's Point, Desolace
    [26] = 264, -- Auberdine, Darkshore
    [32] = 288, -- Theramore, Dustwallow Marsh
    [33] = 112, -- Stonetalon Peak, Stonetalon Mountains
    [41] = 217, -- Feathermoon, Feralas
  },
  [38] = { -- Shadowprey Village, Desolace
    [22] = 167, -- Thunder Bluff, Mulgore
    [29] = 186, -- Sun Rock Retreat, Stonetalon Mountains
    [42] = 184, -- Camp Mojache, Feralas
  },
  [39] = { -- Gadgetzan, Tanaris
    [31] = 166, -- Thalanaar, Feralas
    [32] = 144, -- Theramore, Dustwallow Marsh
    [73] = 185, -- Cenarion Hold, Silithus
    [79] = 97, -- Marshal's Refuge, Un'Goro Crater
  },
  [40] = { -- Gadgetzan, Tanaris
    [22] = 285, -- Thunder Bluff, Mulgore
    [23] = 328, -- Orgrimmar, Durotar
    [25] = 282, -- Crossroads, The Barrens
    [30] = 81, -- Freewind Post, Thousand Needles
    [42] = 187, -- Camp Mojache, Feralas
    [55] = 208, -- Brackenwall Village, Dustwallow Marsh
    [72] = 218, -- Cenarion Hold, Silithus
    [79] = 101, -- Marshal's Refuge, Un'Goro Crater
  },
  [41] = { -- Feathermoon, Feralas
    [26] = 438, -- Auberdine, Darkshore
    [31] = 145, -- Thalanaar, Feralas
    [37] = 212, -- Nijel's Point, Desolace
    [73] = 149, -- Cenarion Hold, Silithus
  },
  [42] = { -- Camp Mojache, Feralas
    [22] = 243, -- Thunder Bluff, Mulgore
    [25] = 247, -- Crossroads, The Barrens
    [30] = 100, -- Freewind Post, Thousand Needles
    [38] = 188, -- Shadowprey Village, Desolace
    [40] = 188, -- Gadgetzan, Tanaris
    [72] = 122, -- Cenarion Hold, Silithus
  },
  [43] = { -- Aerie Peak, The Hinterlands
    [6] = 239, -- Ironforge, Dun Morogh
    [14] = 64, -- Southshore, Hillsbrad
    [16] = 71, -- Refuge Pointe, Arathi
    [66] = 50, -- Chillwind Camp, Western Plaguelands
    [67] = 154, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [44] = { -- Valormok, Azshara
    [22] = 241, -- Thunder Bluff, Mulgore
    [23] = 113, -- Orgrimmar, Durotar
    [25] = 161, -- Crossroads, The Barrens
    [48] = 217, -- Bloodvenom Post, Felwood
    [53] = 122, -- Everlook, Winterspring
    [61] = 87, -- Splintertree Post, Ashenvale
  },
  [45] = { -- Nethergarde Keep, Blasted Lands
    [2] = 177, -- Stormwind, Elwynn
    [12] = 86, -- Darkshire, Duskwood
    [71] = 195, -- Morgan's Vigil, Burning Steppes
  },
  [46] = { -- Southshore Ferry, Hillsbrad
    [7] = 195, -- Menethil Harbor, Wetlands
  },
  [48] = { -- Bloodvenom Post, Felwood
    [23] = 242, -- Orgrimmar, Durotar
    [25] = 226, -- Crossroads, The Barrens
    [44] = 226, -- Valormok, Azshara
    [53] = 178, -- Everlook, Winterspring
    [69] = 155, -- Moonglade
  },
  [49] = { -- Moonglade
    [26] = 133, -- Auberdine, Darkshore
    [52] = 122, -- Everlook, Winterspring
    [65] = 57, -- Talonbranch Glade, Felwood
  },
  [52] = { -- Everlook, Winterspring
    [49] = 114, -- Moonglade
    [64] = 165, -- Talrendis Point, Azshara
    [65] = 115, -- Talonbranch Glade, Felwood
    [3242] = 127, -- Tainted Foothills, Mount Hyjal
  },
  [53] = { -- Everlook, Winterspring
    [23] = 285, -- Orgrimmar, Durotar
    [44] = 127, -- Valormok, Azshara
    [48] = 183, -- Bloodvenom Post, Felwood
    [69] = 125, -- Moonglade
    [3242] = 127, -- Tainted Foothills, Mount Hyjal
  },
  [55] = { -- Brackenwall Village, Dustwallow Marsh
    [22] = 210, -- Thunder Bluff, Mulgore
    [23] = 203, -- Orgrimmar, Durotar
    [25] = 151, -- Crossroads, The Barrens
    [40] = 208, -- Gadgetzan, Tanaris
  },
  [56] = { -- Stonard, Swamp of Sorrows
    [18] = 244, -- Booty Bay, Stranglethorn
    [20] = 176, -- Grom'gol, Stranglethorn
    [21] = 267, -- Kargath, Badlands
    [70] = 185, -- Flame Crest, Burning Steppes
    [3203] = 159, -- Rog'mar, Riverglades
  },
  [58] = { -- Zoram'gar Outpost, Ashenvale
    [25] = 213, -- Crossroads, The Barrens
    [61] = 157, -- Splintertree Post, Ashenvale
  },
  [60] = { -- Frostwolf Keep, Alterac Valley
    [11] = 15, -- Undercity, Tirisfal
  },
  [61] = { -- Splintertree Post, Ashenvale
    [23] = 90, -- Orgrimmar, Durotar
    [25] = 150, -- Crossroads, The Barrens
    [44] = 90, -- Valormok, Azshara
    [58] = 156, -- Zoram'gar Outpost, Ashenvale
  },
  [62] = { -- Nighthaven, Moonglade
    [27] = 142, -- Rut'theran Village, Teldrassil
  },
  [63] = { -- Nighthaven, Moonglade
    [22] = 510, -- Thunder Bluff, Mulgore
  },
  [64] = { -- Talrendis Point, Azshara
    [26] = 282, -- Auberdine, Darkshore
    [28] = 143, -- Astranaar, Ashenvale
    [32] = 226, -- Theramore, Dustwallow Marsh
    [52] = 167, -- Everlook, Winterspring
    [65] = 266, -- Talonbranch Glade, Felwood
    [80] = 127, -- Ratchet, The Barrens
  },
  [65] = { -- Talonbranch Glade, Felwood
    [26] = 176, -- Auberdine, Darkshore
    [49] = 63, -- Moonglade
    [52] = 113, -- Everlook, Winterspring
    [64] = 265, -- Talrendis Point, Azshara
  },
  [66] = { -- Chillwind Camp, Western Plaguelands
    [6] = 243, -- Ironforge, Dun Morogh
    [14] = 80, -- Southshore, Hillsbrad
    [43] = 61, -- Aerie Peak, The Hinterlands
    [67] = 137, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [67] = { -- Light's Hope Chapel, Eastern Plaguelands
    [6] = 345, -- Ironforge, Dun Morogh
    [43] = 152, -- Aerie Peak, The Hinterlands
    [66] = 140, -- Chillwind Camp, Western Plaguelands
  },
  [68] = { -- Light's Hope Chapel, Eastern Plaguelands
    [11] = 245, -- Undercity, Tirisfal
    [76] = 132, -- Revantusk Village, The Hinterlands
  },
  [69] = { -- Moonglade
    [48] = 147, -- Bloodvenom Post, Felwood
    [53] = 133, -- Everlook, Winterspring
  },
  [70] = { -- Flame Crest, Burning Steppes
    [21] = 94, -- Kargath, Badlands
    [56] = 199, -- Stonard, Swamp of Sorrows
    [75] = 67, -- Thorium Point, Searing Gorge
    [3203] = 129, -- Rog'mar, Riverglades
  },
  [71] = { -- Morgan's Vigil, Burning Steppes
    [2] = 141, -- Stormwind, Elwynn
    [5] = 59, -- Lakeshire, Redridge
    [45] = 196, -- Nethergarde Keep, Blasted Lands
    [74] = 97, -- Thorium Point, Searing Gorge
    [3276] = 123, -- Farholde Keep, Riverglades
  },
  [72] = { -- Cenarion Hold, Silithus
    [40] = 226, -- Gadgetzan, Tanaris
    [42] = 122, -- Camp Mojache, Feralas
    [79] = 91, -- Marshal's Refuge, Un'Goro Crater
  },
  [73] = { -- Cenarion Hold, Silithus
    [39] = 177, -- Gadgetzan, Tanaris
    [41] = 164, -- Feathermoon, Feralas
    [79] = 86, -- Marshal's Refuge, Un'Goro Crater
  },
  [74] = { -- Thorium Point, Searing Gorge
    [6] = 88, -- Ironforge, Dun Morogh
    [71] = 90, -- Morgan's Vigil, Burning Steppes
  },
  [75] = { -- Thorium Point, Searing Gorge
    [21] = 65, -- Kargath, Badlands
    [70] = 72, -- Flame Crest, Burning Steppes
  },
  [76] = { -- Revantusk Village, The Hinterlands
    [11] = 267, -- Undercity, Tirisfal
    [13] = 149, -- Tarren Mill, Hillsbrad
    [17] = 87, -- Hammerfall, Arathi
    [68] = 130, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [77] = { -- Camp Taurajo, The Barrens
    [22] = 106, -- Thunder Bluff, Mulgore
    [25] = 74, -- Crossroads, The Barrens
    [30] = 117, -- Freewind Post, Thousand Needles
  },
  [79] = { -- Marshal's Refuge, Un'Goro Crater
    [39] = 97, -- Gadgetzan, Tanaris
    [40] = 106, -- Gadgetzan, Tanaris
    [72] = 94, -- Cenarion Hold, Silithus
    [73] = 88, -- Cenarion Hold, Silithus
  },
  [80] = { -- Ratchet, The Barrens
    [25] = 64, -- Crossroads, The Barrens
    [32] = 98, -- Theramore, Dustwallow Marsh
    [64] = 124, -- Talrendis Point, Azshara
  },
  [84] = { -- Plaguewood Tower, Eastern Plaguelands
    [85] = 46, -- Northpass Tower, Eastern Plaguelands
    [86] = 59, -- Eastwall Tower, Eastern Plaguelands
    [87] = 48, -- Crown Guard Tower, Eastern Plaguelands
  },
  [559] = { -- Summit of Eternity, Mount Hyjal
    [3242] = 58, -- Tainted Foothills, Mount Hyjal
  },
  [3203] = { -- Rog'mar, Riverglades
    [17] = 308, -- Hammerfall, Arathi
    [21] = 113, -- Kargath, Badlands
    [56] = 144, -- Stonard, Swamp of Sorrows
    [70] = 125, -- Flame Crest, Burning Steppes
  },
  [3242] = { -- Tainted Foothills, Mount Hyjal
    [52] = 117, -- Everlook, Winterspring
    [53] = 124, -- Everlook, Winterspring
    [559] = 58, -- Summit of Eternity, Mount Hyjal
  },
  [3276] = { -- Farholde Keep, Riverglades
    [5] = 122, -- Lakeshire, Redridge
    [8] = 162, -- Thelsamar, Loch Modan
    [71] = 115, -- Morgan's Vigil, Burning Steppes
  },
}
