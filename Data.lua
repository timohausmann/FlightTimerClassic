-- Direct flight estimates for WoW Forever. Measured routes live in FTCCustomData.
-- Build: 1.60.1.70888
-- TAXI_YARDS_PER_SECOND: 30
-- Generated: 2026-11-11
-- python3 scripts/build_estimates.py
FTCData = {
  [2] = { -- Stormwind, Elwynn
    [4] = 78, -- Sentinel Hill, Westfall
    [5] = 113, -- Lakeshire, Redridge
    [6] = 259, -- Ironforge, Dun Morogh
    [12] = 116, -- Darkshire, Duskwood
    [19] = 244, -- Booty Bay, Stranglethorn
    [45] = 176, -- Nethergarde Keep, Blasted Lands
    [71] = 157, -- Morgan's Vigil, Burning Steppes
  },
  [4] = { -- Sentinel Hill, Westfall
    [2] = 81, -- Stormwind, Elwynn
    [5] = 130, -- Lakeshire, Redridge
    [12] = 97, -- Darkshire, Duskwood
    [19] = 185, -- Booty Bay, Stranglethorn
  },
  [5] = { -- Lakeshire, Redridge
    [2] = 112, -- Stormwind, Elwynn
    [4] = 133, -- Sentinel Hill, Westfall
    [12] = 60, -- Darkshire, Duskwood
    [71] = 61, -- Morgan's Vigil, Burning Steppes
    [3276] = 132, -- Farholde Keep, Riverglades
  },
  [6] = { -- Ironforge, Dun Morogh
    [2] = 210, -- Stormwind, Elwynn
    [7] = 129, -- Menethil Harbor, Wetlands
    [8] = 101, -- Thelsamar, Loch Modan
    [14] = 265, -- Southshore, Hillsbrad
    [16] = 253, -- Refuge Pointe, Arathi
    [43] = 298, -- Aerie Peak, The Hinterlands
    [66] = 294, -- Chillwind Camp, Western Plaguelands
    [67] = 348, -- Light's Hope Chapel, Eastern Plaguelands
    [74] = 86, -- Thorium Point, Searing Gorge
  },
  [7] = { -- Menethil Harbor, Wetlands
    [6] = 89, -- Ironforge, Dun Morogh
    [8] = 163, -- Thelsamar, Loch Modan
    [14] = 107, -- Southshore, Hillsbrad
    [16] = 113, -- Refuge Pointe, Arathi
  },
  [8] = { -- Thelsamar, Loch Modan
    [6] = 109, -- Ironforge, Dun Morogh
    [7] = 152, -- Menethil Harbor, Wetlands
    [16] = 163, -- Refuge Pointe, Arathi
    [3276] = 184, -- Farholde Keep, Riverglades
  },
  [10] = { -- The Sepulcher, Silverpine Forest
    [11] = 111, -- Undercity, Tirisfal
    [13] = 96, -- Tarren Mill, Hillsbrad
  },
  [11] = { -- Undercity, Tirisfal
    [10] = 106, -- The Sepulcher, Silverpine Forest
    [13] = 141, -- Tarren Mill, Hillsbrad
    [17] = 300, -- Hammerfall, Arathi
    [21] = 495, -- Kargath, Badlands
    [60] = 16, -- Frostwolf Keep, Alterac Valley
    [68] = 262, -- Light's Hope Chapel, Eastern Plaguelands
    [76] = 284, -- Revantusk Village, The Hinterlands
  },
  [12] = { -- Darkshire, Duskwood
    [2] = 88, -- Stormwind, Elwynn
    [4] = 93, -- Sentinel Hill, Westfall
    [5] = 60, -- Lakeshire, Redridge
    [19] = 171, -- Booty Bay, Stranglethorn
    [45] = 97, -- Nethergarde Keep, Blasted Lands
  },
  [13] = { -- Tarren Mill, Hillsbrad
    [10] = 100, -- The Sepulcher, Silverpine Forest
    [11] = 139, -- Undercity, Tirisfal
    [17] = 118, -- Hammerfall, Arathi
    [76] = 195, -- Revantusk Village, The Hinterlands
  },
  [14] = { -- Southshore, Hillsbrad
    [6] = 206, -- Ironforge, Dun Morogh
    [7] = 110, -- Menethil Harbor, Wetlands
    [16] = 74, -- Refuge Pointe, Arathi
    [43] = 71, -- Aerie Peak, The Hinterlands
    [66] = 81, -- Chillwind Camp, Western Plaguelands
  },
  [16] = { -- Refuge Pointe, Arathi
    [6] = 270, -- Ironforge, Dun Morogh
    [7] = 126, -- Menethil Harbor, Wetlands
    [8] = 170, -- Thelsamar, Loch Modan
    [14] = 87, -- Southshore, Hillsbrad
    [43] = 72, -- Aerie Peak, The Hinterlands
  },
  [17] = { -- Hammerfall, Arathi
    [11] = 259, -- Undercity, Tirisfal
    [13] = 116, -- Tarren Mill, Hillsbrad
    [21] = 259, -- Kargath, Badlands
    [76] = 90, -- Revantusk Village, The Hinterlands
    [3203] = 326, -- Rog'mar, Riverglades
  },
  [18] = { -- Booty Bay, Stranglethorn
    [20] = 102, -- Grom'gol, Stranglethorn
    [21] = 406, -- Kargath, Badlands
    [56] = 266, -- Stonard, Swamp of Sorrows
  },
  [19] = { -- Booty Bay, Stranglethorn
    [2] = 219, -- Stormwind, Elwynn
    [4] = 181, -- Sentinel Hill, Westfall
    [12] = 175, -- Darkshire, Duskwood
  },
  [20] = { -- Grom'gol, Stranglethorn
    [18] = 81, -- Booty Bay, Stranglethorn
    [21] = 327, -- Kargath, Badlands
    [56] = 205, -- Stonard, Swamp of Sorrows
  },
  [21] = { -- Kargath, Badlands
    [11] = 497, -- Undercity, Tirisfal
    [17] = 263, -- Hammerfall, Arathi
    [18] = 416, -- Booty Bay, Stranglethorn
    [20] = 313, -- Grom'gol, Stranglethorn
    [56] = 281, -- Stonard, Swamp of Sorrows
    [70] = 86, -- Flame Crest, Burning Steppes
    [75] = 56, -- Thorium Point, Searing Gorge
    [3203] = 127, -- Rog'mar, Riverglades
  },
  [22] = { -- Thunder Bluff, Mulgore
    [23] = 207, -- Orgrimmar, Durotar
    [25] = 158, -- Crossroads, The Barrens
    [29] = 181, -- Sun Rock Retreat, Stonetalon Mountains
    [30] = 204, -- Freewind Post, Thousand Needles
    [38] = 158, -- Shadowprey Village, Desolace
    [40] = 290, -- Gadgetzan, Tanaris
    [42] = 252, -- Camp Mojache, Feralas
    [44] = 269, -- Valormok, Azshara
    [55] = 238, -- Brackenwall Village, Dustwallow Marsh
    [77] = 87, -- Camp Taurajo, The Barrens
  },
  [23] = { -- Orgrimmar, Durotar
    [22] = 225, -- Thunder Bluff, Mulgore
    [25] = 110, -- Crossroads, The Barrens
    [40] = 417, -- Gadgetzan, Tanaris
    [44] = 99, -- Valormok, Azshara
    [48] = 252, -- Bloodvenom Post, Felwood
    [53] = 319, -- Everlook, Winterspring
    [55] = 228, -- Brackenwall Village, Dustwallow Marsh
    [61] = 89, -- Splintertree Post, Ashenvale
  },
  [25] = { -- Crossroads, The Barrens
    [22] = 182, -- Thunder Bluff, Mulgore
    [23] = 142, -- Orgrimmar, Durotar
    [29] = 150, -- Sun Rock Retreat, Stonetalon Mountains
    [30] = 184, -- Freewind Post, Thousand Needles
    [40] = 303, -- Gadgetzan, Tanaris
    [42] = 252, -- Camp Mojache, Feralas
    [44] = 168, -- Valormok, Azshara
    [48] = 253, -- Bloodvenom Post, Felwood
    [55] = 163, -- Brackenwall Village, Dustwallow Marsh
    [58] = 230, -- Zoram'gar Outpost, Ashenvale
    [61] = 162, -- Splintertree Post, Ashenvale
    [77] = 90, -- Camp Taurajo, The Barrens
    [80] = 52, -- Ratchet, The Barrens
  },
  [26] = { -- Auberdine, Darkshore
    [27] = 84, -- Rut'theran Village, Teldrassil
    [28] = 176, -- Astranaar, Ashenvale
    [32] = 674, -- Theramore, Dustwallow Marsh
    [33] = 181, -- Stonetalon Peak, Stonetalon Mountains
    [37] = 291, -- Nijel's Point, Desolace
    [41] = 472, -- Feathermoon, Feralas
    [49] = 151, -- Moonglade
    [64] = 299, -- Talrendis Point, Azshara
    [65] = 189, -- Talonbranch Glade, Felwood
  },
  [27] = { -- Rut'theran Village, Teldrassil
    [26] = 85, -- Auberdine, Darkshore
  },
  [28] = { -- Astranaar, Ashenvale
    [26] = 148, -- Auberdine, Darkshore
    [33] = 153, -- Stonetalon Peak, Stonetalon Mountains
    [64] = 148, -- Talrendis Point, Azshara
  },
  [29] = { -- Sun Rock Retreat, Stonetalon Mountains
    [22] = 174, -- Thunder Bluff, Mulgore
    [25] = 149, -- Crossroads, The Barrens
    [38] = 143, -- Shadowprey Village, Desolace
  },
  [30] = { -- Freewind Post, Thousand Needles
    [22] = 225, -- Thunder Bluff, Mulgore
    [25] = 194, -- Crossroads, The Barrens
    [40] = 93, -- Gadgetzan, Tanaris
    [42] = 123, -- Camp Mojache, Feralas
    [77] = 137, -- Camp Taurajo, The Barrens
  },
  [31] = { -- Thalanaar, Feralas
    [32] = 159, -- Theramore, Dustwallow Marsh
    [39] = 171, -- Gadgetzan, Tanaris
    [41] = 178, -- Feathermoon, Feralas
  },
  [32] = { -- Theramore, Dustwallow Marsh
    [26] = 621, -- Auberdine, Darkshore
    [31] = 163, -- Thalanaar, Feralas
    [37] = 334, -- Nijel's Point, Desolace
    [39] = 156, -- Gadgetzan, Tanaris
    [64] = 235, -- Talrendis Point, Azshara
    [80] = 115, -- Ratchet, The Barrens
  },
  [33] = { -- Stonetalon Peak, Stonetalon Mountains
    [26] = 177, -- Auberdine, Darkshore
    [28] = 154, -- Astranaar, Ashenvale
    [37] = 127, -- Nijel's Point, Desolace
  },
  [37] = { -- Nijel's Point, Desolace
    [26] = 282, -- Auberdine, Darkshore
    [32] = 307, -- Theramore, Dustwallow Marsh
    [33] = 119, -- Stonetalon Peak, Stonetalon Mountains
    [41] = 232, -- Feathermoon, Feralas
  },
  [38] = { -- Shadowprey Village, Desolace
    [22] = 178, -- Thunder Bluff, Mulgore
    [29] = 199, -- Sun Rock Retreat, Stonetalon Mountains
    [42] = 196, -- Camp Mojache, Feralas
  },
  [39] = { -- Gadgetzan, Tanaris
    [31] = 177, -- Thalanaar, Feralas
    [32] = 154, -- Theramore, Dustwallow Marsh
    [73] = 197, -- Cenarion Hold, Silithus
    [79] = 104, -- Marshal's Refuge, Un'Goro Crater
  },
  [40] = { -- Gadgetzan, Tanaris
    [22] = 304, -- Thunder Bluff, Mulgore
    [23] = 350, -- Orgrimmar, Durotar
    [25] = 300, -- Crossroads, The Barrens
    [30] = 87, -- Freewind Post, Thousand Needles
    [42] = 199, -- Camp Mojache, Feralas
    [55] = 222, -- Brackenwall Village, Dustwallow Marsh
    [72] = 233, -- Cenarion Hold, Silithus
    [79] = 107, -- Marshal's Refuge, Un'Goro Crater
  },
  [41] = { -- Feathermoon, Feralas
    [26] = 467, -- Auberdine, Darkshore
    [31] = 155, -- Thalanaar, Feralas
    [37] = 227, -- Nijel's Point, Desolace
    [73] = 159, -- Cenarion Hold, Silithus
  },
  [42] = { -- Camp Mojache, Feralas
    [22] = 259, -- Thunder Bluff, Mulgore
    [25] = 264, -- Crossroads, The Barrens
    [30] = 107, -- Freewind Post, Thousand Needles
    [38] = 201, -- Shadowprey Village, Desolace
    [40] = 201, -- Gadgetzan, Tanaris
    [72] = 130, -- Cenarion Hold, Silithus
  },
  [43] = { -- Aerie Peak, The Hinterlands
    [6] = 255, -- Ironforge, Dun Morogh
    [14] = 68, -- Southshore, Hillsbrad
    [16] = 76, -- Refuge Pointe, Arathi
    [66] = 53, -- Chillwind Camp, Western Plaguelands
    [67] = 164, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [44] = { -- Valormok, Azshara
    [22] = 257, -- Thunder Bluff, Mulgore
    [23] = 121, -- Orgrimmar, Durotar
    [25] = 172, -- Crossroads, The Barrens
    [48] = 232, -- Bloodvenom Post, Felwood
    [53] = 130, -- Everlook, Winterspring
    [61] = 93, -- Splintertree Post, Ashenvale
  },
  [45] = { -- Nethergarde Keep, Blasted Lands
    [2] = 189, -- Stormwind, Elwynn
    [12] = 92, -- Darkshire, Duskwood
    [71] = 208, -- Morgan's Vigil, Burning Steppes
  },
  [46] = { -- Southshore Ferry, Hillsbrad
    [7] = 208, -- Menethil Harbor, Wetlands
  },
  [48] = { -- Bloodvenom Post, Felwood
    [23] = 258, -- Orgrimmar, Durotar
    [25] = 241, -- Crossroads, The Barrens
    [44] = 241, -- Valormok, Azshara
    [53] = 190, -- Everlook, Winterspring
    [69] = 165, -- Moonglade
  },
  [49] = { -- Moonglade
    [26] = 142, -- Auberdine, Darkshore
    [52] = 130, -- Everlook, Winterspring
    [65] = 61, -- Talonbranch Glade, Felwood
  },
  [52] = { -- Everlook, Winterspring
    [49] = 121, -- Moonglade
    [64] = 176, -- Talrendis Point, Azshara
    [65] = 122, -- Talonbranch Glade, Felwood
    [3242] = 135, -- Tainted Foothills, Mount Hyjal
  },
  [53] = { -- Everlook, Winterspring
    [23] = 304, -- Orgrimmar, Durotar
    [44] = 136, -- Valormok, Azshara
    [48] = 195, -- Bloodvenom Post, Felwood
    [69] = 134, -- Moonglade
    [3242] = 136, -- Tainted Foothills, Mount Hyjal
  },
  [55] = { -- Brackenwall Village, Dustwallow Marsh
    [22] = 224, -- Thunder Bluff, Mulgore
    [23] = 217, -- Orgrimmar, Durotar
    [25] = 162, -- Crossroads, The Barrens
    [40] = 222, -- Gadgetzan, Tanaris
  },
  [56] = { -- Stonard, Swamp of Sorrows
    [18] = 260, -- Booty Bay, Stranglethorn
    [20] = 188, -- Grom'gol, Stranglethorn
    [21] = 285, -- Kargath, Badlands
    [70] = 197, -- Flame Crest, Burning Steppes
    [3203] = 170, -- Rog'mar, Riverglades
  },
  [58] = { -- Zoram'gar Outpost, Ashenvale
    [25] = 228, -- Crossroads, The Barrens
    [61] = 167, -- Splintertree Post, Ashenvale
  },
  [60] = { -- Frostwolf Keep, Alterac Valley
    [11] = 16, -- Undercity, Tirisfal
  },
  [61] = { -- Splintertree Post, Ashenvale
    [23] = 96, -- Orgrimmar, Durotar
    [25] = 160, -- Crossroads, The Barrens
    [44] = 96, -- Valormok, Azshara
    [58] = 166, -- Zoram'gar Outpost, Ashenvale
  },
  [62] = { -- Nighthaven, Moonglade
    [27] = 152, -- Rut'theran Village, Teldrassil
  },
  [63] = { -- Nighthaven, Moonglade
    [22] = 544, -- Thunder Bluff, Mulgore
  },
  [64] = { -- Talrendis Point, Azshara
    [26] = 301, -- Auberdine, Darkshore
    [28] = 153, -- Astranaar, Ashenvale
    [32] = 241, -- Theramore, Dustwallow Marsh
    [52] = 178, -- Everlook, Winterspring
    [65] = 283, -- Talonbranch Glade, Felwood
    [80] = 135, -- Ratchet, The Barrens
  },
  [65] = { -- Talonbranch Glade, Felwood
    [26] = 187, -- Auberdine, Darkshore
    [49] = 67, -- Moonglade
    [52] = 120, -- Everlook, Winterspring
    [64] = 282, -- Talrendis Point, Azshara
  },
  [66] = { -- Chillwind Camp, Western Plaguelands
    [6] = 259, -- Ironforge, Dun Morogh
    [14] = 85, -- Southshore, Hillsbrad
    [43] = 65, -- Aerie Peak, The Hinterlands
    [67] = 146, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [67] = { -- Light's Hope Chapel, Eastern Plaguelands
    [6] = 367, -- Ironforge, Dun Morogh
    [43] = 162, -- Aerie Peak, The Hinterlands
    [66] = 149, -- Chillwind Camp, Western Plaguelands
  },
  [68] = { -- Light's Hope Chapel, Eastern Plaguelands
    [11] = 261, -- Undercity, Tirisfal
    [76] = 141, -- Revantusk Village, The Hinterlands
  },
  [69] = { -- Moonglade
    [48] = 157, -- Bloodvenom Post, Felwood
    [53] = 142, -- Everlook, Winterspring
  },
  [70] = { -- Flame Crest, Burning Steppes
    [21] = 100, -- Kargath, Badlands
    [56] = 213, -- Stonard, Swamp of Sorrows
    [75] = 72, -- Thorium Point, Searing Gorge
    [3203] = 137, -- Rog'mar, Riverglades
  },
  [71] = { -- Morgan's Vigil, Burning Steppes
    [2] = 151, -- Stormwind, Elwynn
    [5] = 63, -- Lakeshire, Redridge
    [45] = 210, -- Nethergarde Keep, Blasted Lands
    [74] = 103, -- Thorium Point, Searing Gorge
    [3276] = 131, -- Farholde Keep, Riverglades
  },
  [72] = { -- Cenarion Hold, Silithus
    [40] = 241, -- Gadgetzan, Tanaris
    [42] = 130, -- Camp Mojache, Feralas
    [79] = 97, -- Marshal's Refuge, Un'Goro Crater
  },
  [73] = { -- Cenarion Hold, Silithus
    [39] = 188, -- Gadgetzan, Tanaris
    [41] = 175, -- Feathermoon, Feralas
    [79] = 91, -- Marshal's Refuge, Un'Goro Crater
  },
  [74] = { -- Thorium Point, Searing Gorge
    [6] = 93, -- Ironforge, Dun Morogh
    [71] = 96, -- Morgan's Vigil, Burning Steppes
  },
  [75] = { -- Thorium Point, Searing Gorge
    [21] = 70, -- Kargath, Badlands
    [70] = 77, -- Flame Crest, Burning Steppes
  },
  [76] = { -- Revantusk Village, The Hinterlands
    [11] = 285, -- Undercity, Tirisfal
    [13] = 159, -- Tarren Mill, Hillsbrad
    [17] = 93, -- Hammerfall, Arathi
    [68] = 139, -- Light's Hope Chapel, Eastern Plaguelands
  },
  [77] = { -- Camp Taurajo, The Barrens
    [22] = 114, -- Thunder Bluff, Mulgore
    [25] = 79, -- Crossroads, The Barrens
    [30] = 125, -- Freewind Post, Thousand Needles
  },
  [79] = { -- Marshal's Refuge, Un'Goro Crater
    [39] = 103, -- Gadgetzan, Tanaris
    [40] = 113, -- Gadgetzan, Tanaris
    [72] = 100, -- Cenarion Hold, Silithus
    [73] = 94, -- Cenarion Hold, Silithus
  },
  [80] = { -- Ratchet, The Barrens
    [25] = 68, -- Crossroads, The Barrens
    [32] = 105, -- Theramore, Dustwallow Marsh
    [64] = 132, -- Talrendis Point, Azshara
  },
  [84] = { -- Plaguewood Tower, Eastern Plaguelands
    [85] = 49, -- Northpass Tower, Eastern Plaguelands
    [86] = 63, -- Eastwall Tower, Eastern Plaguelands
    [87] = 51, -- Crown Guard Tower, Eastern Plaguelands
  },
  [559] = { -- Summit of Eternity, Mount Hyjal
    [3242] = 62, -- Tainted Foothills, Mount Hyjal
  },
  [3203] = { -- Rog'mar, Riverglades
    [17] = 328, -- Hammerfall, Arathi
    [21] = 120, -- Kargath, Badlands
    [56] = 154, -- Stonard, Swamp of Sorrows
    [70] = 133, -- Flame Crest, Burning Steppes
  },
  [3242] = { -- Tainted Foothills, Mount Hyjal
    [52] = 125, -- Everlook, Winterspring
    [53] = 132, -- Everlook, Winterspring
    [559] = 62, -- Summit of Eternity, Mount Hyjal
  },
  [3276] = { -- Farholde Keep, Riverglades
    [5] = 131, -- Lakeshire, Redridge
    [8] = 173, -- Thelsamar, Loch Modan
    [71] = 123, -- Morgan's Vigil, Burning Steppes
  },
}
