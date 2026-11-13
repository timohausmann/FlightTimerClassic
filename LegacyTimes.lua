local _, ns = ...

-- 0.6 stored FTCCustomData[faction][hash][hash] = seconds.
-- The hash is the pin X on that continent's flight map, not a node id.
-- Opening the map exposes both, so this continent's pairs move to node ids.
-- Other continents stay in the old keys until their map opens.

local function MapID()
    -- Same order as the timer: the open map, then the flight master's continent.
    if FlightMapFrame and type(FlightMapFrame.GetMapID) == "function" then
        local mapID = FlightMapFrame:GetMapID()
        if type(mapID) == "number" and mapID > 0 then
            return mapID
        end
    end
    if type(GetTaxiMapID) == "function" then
        local mapID = GetTaxiMapID()
        if type(mapID) == "number" and mapID > 0 then
            return mapID
        end
    end
end

-- Matches 0.6: tostring(floor(x * 100000000)). Y was never part of the key.
local function PinHash(slot)
    if type(TaxiNodePosition) ~= "function" then
        return
    end
    local x = TaxiNodePosition(slot)
    if type(x) ~= "number" then
        return
    end
    if issecretvalue and issecretvalue(x) then
        return
    end
    return tostring(math.floor(x * 100000000))
end

-- SavedVariables may bring a numeric-looking string back as a number.
local function HashKey(key)
    if type(key) == "string" then
        return key
    end
    if type(key) == "number" then
        return tostring(key)
    end
end

local function NodeBySlot(mapID)
    if not C_TaxiMap or type(C_TaxiMap.GetAllTaxiNodes) ~= "function" then
        return
    end
    local nodes = C_TaxiMap.GetAllTaxiNodes(mapID)
    if type(nodes) ~= "table" then
        return
    end
    local bySlot = {}
    for i = 1, #nodes do
        local node = nodes[i]
        local slot = node and node.slotIndex
        local nodeID = node and node.nodeID
        if issecretvalue and (issecretvalue(slot) or issecretvalue(nodeID)) then
            slot = nil
        end
        if type(slot) == "number" and type(nodeID) == "number" then
            bySlot[slot] = nodeID
        end
    end
    return bySlot
end

-- hash -> node id for this map. Two pins with the same X cannot be told apart.
local function HashToNode(bySlot)
    if type(NumTaxiNodes) ~= "function" then
        return
    end
    local count = NumTaxiNodes()
    if issecretvalue and issecretvalue(count) then
        return
    end
    if type(count) ~= "number" or count < 1 then
        return {}
    end
    -- Mark a repeated X before the node lookup. A pin missing from bySlot
    -- still shares that hash, so the saved route must stay unconverted.
    local firstSlot = {}
    local ambiguous = {}
    for slot = 1, count do
        local hash = PinHash(slot)
        if hash then
            if firstSlot[hash] then
                ambiguous[hash] = true
            else
                firstSlot[hash] = slot
            end
        end
    end
    local hashToId = {}
    for hash, slot in pairs(firstSlot) do
        local nodeID = bySlot[slot]
        if not ambiguous[hash] and type(nodeID) == "number" then
            hashToId[hash] = nodeID
        end
    end
    return hashToId
end

local function HasTime(srcId, dstId)
    local row = FTCCustomData[srcId]
    local seconds = row and row[dstId]
    return type(seconds) == "number" and seconds > 0
end

-- Copy resolved pairs. Raw seconds: 0.6 did not know Frequent Flier.
-- Returns how many old keys were retired, or nil when this map cannot be read.
function ns.MigrateLegacyTimes()
    if type(FTCCustomData) ~= "table" then
        return
    end
    local alliance = type(FTCCustomData.Alliance) == "table"
    local horde = type(FTCCustomData.Horde) == "table"
    if not alliance and not horde then
        return
    end
    -- Only this character's faction. An Alliance map must not rewrite Horde rows.
    local faction = UnitFactionGroup("player")
    local saved = faction and FTCCustomData[faction]
    if type(saved) ~= "table" then
        return
    end

    local mapID = MapID()
    if not mapID then
        return
    end
    local bySlot = NodeBySlot(mapID)
    if not bySlot then
        return
    end
    local hashToId = HashToNode(bySlot)
    if not hashToId then
        return
    end

    local moved = 0
    -- Clear empty origins after the walk. pairs must not delete keys it has not visited.
    local clearFrom = {}
    for fromKey, dests in pairs(saved) do
        local srcId = hashToId[HashKey(fromKey)]
        if srcId and type(dests) == "table" then
            local remove = {}
            for toKey, seconds in pairs(dests) do
                local dstId = hashToId[HashKey(toKey)]
                -- A non-positive value is not a flight. Leave that key alone.
                -- Copy, then retire the hash. An existing node-id time keeps its 0.6 pair.
                if dstId and type(seconds) == "number" and seconds > 0 and not HasTime(srcId, dstId) then
                    FTCCustomData[srcId] = FTCCustomData[srcId] or {}
                    FTCCustomData[srcId][dstId] = seconds
                    remove[#remove + 1] = toKey
                    moved = moved + 1
                end
            end
            for i = 1, #remove do
                dests[remove[i]] = nil
            end
            if not next(dests) then
                clearFrom[#clearFrom + 1] = fromKey
            end
        end
    end
    for i = 1, #clearFrom do
        saved[clearFrom[i]] = nil
    end
    if not next(saved) then
        FTCCustomData[faction] = nil
    end
    return moved
end
