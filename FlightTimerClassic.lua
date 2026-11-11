local addonName, ns = ...
-- Localization.lua fills this. A missing line is English.
local L = ns.L

--[[--------------------------------------------------------------------
	Flight Timer Classic by Nomana
	CC BY 2.0 (https://creativecommons.org/licenses/by/2.0/)
    https://www.curseforge.com/wow/addons/flight-timer-classic
    https://github.com/timohausmann/FlightTimerClassic

	Huge credit to PhanxFlightTimer, InFlight and Consequence-Flightmaster
	from which I more or less frankensteined this AddOn together.
	https://github.com/phanx-wow/PhanxFlightTimer
	https://www.curseforge.com/wow/addons/inflight-taxi-timer
	https://www.curseforge.com/wow/addons/consequence-flightmaster
----------------------------------------------------------------------]]

local currentName, currentId, startTime, endName, endId, endTime, estimatedT, timeIsEstimate
local defaultTimes = {}
local customTimes = {}
local flightStarted = false
-- Set on click. The clock stays off until the character is actually on the taxi.
local pendingSince
-- Flight watch handle. A ticker is not parented to the box, so hiding the box does not stop it.
local flightTicker
-- True after UnitOnTaxi has been seen during this flight. Landing clears it.
local confirmedTaxi
-- A refused takeoff never leaves the ground.
local TAKEOFF_WAIT = 10
-- How often the watch reads UnitOnTaxi. The clock and the landing can be this late.
local FLIGHT_POLL = 0.1
local mapHooked = false
local taxiShowHooked = false
local loadHooked = false
local pinsWarned = false

--[[
Local Functions
--]]

-- Filled in once the clock text exists. Shift-click pastes an arrival line.
local PasteArrival

local function Frame_OnMouseDown(frame, button)
    -- Chat link key, Shift unless the player changed it. Insert now: the click
    -- would otherwise close the chat line before mouse-up. Do not open chat.
    if button == "LeftButton" and IsModifiedClick("CHATLINK") then
        PasteArrival()
        return
    end
    frame:StartMoving()
end

local function Frame_OnMouseUp(frame)
    frame:StopMovingOrSizing()
end

-- "Stormwind, Elwynn" is shown as "Stormwind". Times are stored by node id.
local function ShortName(name)
    if not name then
        return
    end
    return strmatch(name, "[^,]+")
end

local function consoleLog(text, important)
    if important or not FTCConfig or not FTCConfig.mute then
        print(format("|cff00ccff[FTC]|cff66ddff %s", text))
    end
end

-- A name or a slash command, in the lighter blue. The line color comes back after it.
local function Hi(text)
    return "|cffcceeff" .. text .. "|cff66ddff"
end

local function getFormattedTime(t)
    if t then
        if t > 60 then
            return format(L.TimeMinSec, t / 60, mod(t, 60))
        else
            return format(L.TimeSec, t)
        end
    else
        return UNKNOWN
    end
end

-- The number stays white. The label says where it came from.
local function AddEstimatedLine(seconds, isEstimate)
    local text = seconds and getFormattedTime(seconds) or UNKNOWN
    local label = (seconds and not isEstimate) and L.RecordedTime or L.EstimatedTime
    GameTooltip:AddDoubleLine(label, text, 1, 0.82, 0, 1, 1, 1)
end

--[[
FlightFrame
--]]

local flightFrameLoaded = false
local FlightFrame = CreateFrame("Frame", "FlightTimerClassic", UIParent,
    BackdropTemplateMixin and "BackdropTemplate" or nil)
FlightFrame:EnableMouse(true)
FlightFrame:SetMovable(true)
FlightFrame:SetWidth(120)
FlightFrame:SetHeight(48)
FlightFrame:SetPoint("CENTER", 0, 0);
FlightFrame:Hide()

-- nil when the API cannot answer. Callers must not treat that as "on the ground".
local function OnTaxi()
    if type(UnitOnTaxi) ~= "function" then
        return
    end
    local onTaxi = UnitOnTaxi("player")
    if issecretvalue and issecretvalue(onTaxi) then
        return
    end
    return not not onTaxi
end

-- Cancel the flight watch. The click time or the air time is still set here, so it can be logged.
local function StopFlightWatch(reason)
    if not flightTicker then
        return
    end
    local began = pendingSince or startTime
    local waited = began and (GetTime() - began) or 0
    flightTicker:Cancel()
    flightTicker = nil
    -- English on purpose: this line only shows with /ftc debug.
    if FTCConfig and FTCConfig.debug then
        consoleLog(format("Flight watch stopped after %.1fs (%s).", waited, reason))
    end
end

local function BeginFlightClock()
    if startTime or not pendingSince then
        return
    end
    startTime = GetTime()
    pendingSince = nil
    if estimatedT then
        endTime = startTime + estimatedT
    end
end

-- Drop a click that never took off. Keep the flight master node; the map is still open.
local function AbortTakeoff(reason)
    StopFlightWatch(reason or "aborted")
    pendingSince = nil
    confirmedTaxi = nil
    startTime = nil
    endName = nil
    endId = nil
    endTime = nil
    estimatedT = nil
    timeIsEstimate = nil
    flightStarted = false
    FlightFrame:Hide()
end

local function ResetFlight()
    StopFlightWatch("reset")
    flightStarted = false
    pendingSince = nil
    confirmedTaxi = nil
    currentName = nil
    currentId = nil
    startTime = nil
    endName = nil
    endId = nil
    endTime = nil
    estimatedT = nil
    timeIsEstimate = nil
    FlightFrame:Hide()
end

-- Defined with the perk helpers below. Saved times are seconds with no perk.
local ActualToBase

-- Save the flight and hide the box. Safe to call twice.
local function FinishFlight()
    if not startTime then
        return
    end
    local t = ceil(GetTime() - startTime)
    local fromName = Hi(currentName or UNKNOWN)
    local toName = Hi(endName or UNKNOWN)
    local taken = Hi(getFormattedTime(t))

    if endTime == nil then
        consoleLog(format(L.NewData, fromName, toName, taken))
    elseif abs(t - estimatedT) > 2 then -- allow 2 seconds error margin before nagging around
        consoleLog(format(L.Correction, fromName, toName, taken, Hi(getFormattedTime(estimatedT))))
    else
        consoleLog(format(L.Arrived, toName, taken))
    end

    -- Node ids, stored with no Frequent Flier.
    if currentId and endId and t > 0 then
        customTimes[currentId] = customTimes[currentId] or {}
        customTimes[currentId][endId] = ActualToBase(t)
    end

    ResetFlight()
end

-- Time left, or the "+N" the box shows once the estimate has passed.
local function CountdownText()
    if not endTime then
        return
    end
    local t = ceil(endTime - GetTime())
    if t >= 0 then
        return getFormattedTime(t), false
    end
    return getFormattedTime((t - 1) * -1), true
end

-- The number on the box. The watch calls this, so a hidden box simply skips the paint.
local function PaintClock()
    if not FlightFrame.time or not FlightFrame:IsShown() then
        return
    end
    if not startTime then
        if pendingSince then
            FlightFrame.time:SetText(UNKNOWN)
        end
        return
    end

    if endTime == nil then
        FlightFrame.time:SetText(getFormattedTime(GetTime() - startTime))
        return
    end

    local text, overdue = CountdownText()
    FlightFrame.time:SetText(overdue and ('+' .. text) or text)
end

function PasteArrival()
    if type(ChatEdit_GetActiveWindow) ~= "function" then
        return
    end
    local editBox = ChatEdit_GetActiveWindow()
    if not editBox or not editBox:IsShown() then
        return
    end
    local text, overdue = CountdownText()
    if not text then
        return
    end
    local line
    if overdue then
        line = endName and format(L.ArrivalOverdue, endName, text) or format(L.ArrivalOverdueNoPlace, text)
    else
        line = endName and format(L.Arriving, endName, text) or format(L.ArrivingNoPlace, text)
    end
    local existing = editBox:GetText() or ""
    if existing ~= "" and not strmatch(existing, "%s$") then
        line = " " .. line
    end
    editBox:Insert(line)
end

local function FlightFrame_Show()

    if not flightFrameLoaded then

        flightFrameLoaded = true

        FlightFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 16,
            insets = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8
            }
        })

        FlightFrame:SetScript("OnMouseDown", Frame_OnMouseDown)
        FlightFrame:SetScript("OnMouseUp", Frame_OnMouseUp)

        FlightFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            GameTooltip:SetText(L.Title)
            GameTooltip:AddDoubleLine(L.FlyingFrom, currentName or UNKNOWN, 1, 0.82, 0, 1, 1, 1)
            GameTooltip:AddDoubleLine(L.FlyingTo, endName or UNKNOWN, 1, 0.82, 0, 1, 1, 1)

            AddEstimatedLine(estimatedT, timeIsEstimate)
            GameTooltip:AddLine(L.PasteHint, 1, 1, 1)

            GameTooltip:Show()
        end)

        FlightFrame:SetScript("OnLeave", GameTooltip_Hide)

        FlightFrame.time = FlightFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
        FlightFrame.time:SetPoint("CENTER", FlightFrame, "CENTER")
    end

    FlightFrame.time:SetText(UNKNOWN)
    FlightFrame:Show()
    PaintClock()
end

-- Takeoff, the taxi flag, and the number. Runs from the click until the flight is saved or dropped.
local function WatchFlight()
    if pendingSince then
        local onTaxi = OnTaxi()
        -- false: still on the ground. nil: the API cannot answer, so start anyway.
        if onTaxi ~= false then
            BeginFlightClock()
        elseif GetTime() - pendingSince > TAKEOFF_WAIT then
            AbortTakeoff("still on the ground")
            return
        end
    end

    if startTime then
        -- The landing event can run while the taxi flag is still set, and it does not fire again.
        local onTaxi = OnTaxi()
        if onTaxi == true then
            confirmedTaxi = true
        elseif onTaxi == false and confirmedTaxi then
            FinishFlight()
            return
        end
    end

    PaintClock()
end

local function StartFlightWatch()
    -- The caller already stopped the previous watch, while its start time was still set.
    if flightTicker then
        flightTicker:Cancel()
        flightTicker = nil
    end
    if not C_Timer or type(C_Timer.NewTicker) ~= "function" then
        return
    end
    flightTicker = C_Timer.NewTicker(FLIGHT_POLL, WatchFlight)
end

local function CancelFlight()
    consoleLog(L.FlightCancelled)
    -- Nothing to save on landing: the clock is cleared before control returns.
    AbortTakeoff("cancelled")
end

-- The map the player is looking at. GetTaxiMapID stays on the opener's continent.
local function GetViewedTaxiMapID()
    if FlightMapFrame and type(FlightMapFrame.GetMapID) == "function" then
        local mapID = FlightMapFrame:GetMapID()
        if mapID and mapID > 0 then
            return mapID
        end
    end
    if type(GetTaxiMapID) == "function" then
        local mapID = GetTaxiMapID()
        if mapID and mapID > 0 then
            return mapID
        end
    end
end

-- slotIndex on the open map's node list is the TakeTaxiNode index.
local function GetNodeID(slot)
    if not slot or not C_TaxiMap or type(C_TaxiMap.GetAllTaxiNodes) ~= "function" then
        return
    end
    local mapID = GetViewedTaxiMapID()
    if not mapID then
        return
    end
    local nodes = C_TaxiMap.GetAllTaxiNodes(mapID)
    if not nodes then
        return
    end
    for i = 1, #nodes do
        local node = nodes[i]
        if node.slotIndex == slot then
            return node.nodeID
        end
    end
end

-- Direct flight is {start, dest}. Otherwise the same indexes as InFlight:
-- position 1 is the start, position numRoutes + 1 is the destination,
-- and hops 2..numRoutes are the stops.
-- shortcut: a stop is resolved on the open map only, upgrade when a hop on another continent should still sum.
local function RouteNodeIDs(slot, srcId, dstId)
    if not srcId or not dstId then
        return
    end
    if not slot or type(GetNumRoutes) ~= "function" or type(TaxiGetNodeSlot) ~= "function" then
        return {srcId, dstId}
    end
    local numRoutes = GetNumRoutes(slot)
    if not numRoutes or numRoutes < 2 then
        return {srcId, dstId}
    end
    local ids = {srcId}
    for hop = 2, numRoutes do
        local hopSlot = TaxiGetNodeSlot(slot, hop, true)
        local hopId = hopSlot and GetNodeID(hopSlot)
        if not hopId then
            return
        end
        ids[#ids + 1] = hopId
    end
    ids[#ids + 1] = dstId
    return ids
end

-- Frequent Flier is legacy node 110300, spell 1225490. Mounts are 20% faster.
-- Estimates and saved times are both without that perk. Display divides by 1.2.
local FREQUENT_FLIER_NODE = 110300

local function HasFrequentFlier()
    local legacy = Constants and Constants.LegacyConsts
    if not legacy or not legacy.LEGACY_TREE_ADVENTURE_ID then
        return false
    end
    if not C_Traits or type(C_Traits.GetConfigIDByTreeID) ~= "function" or type(C_Traits.GetNodeInfo) ~= "function" then
        return false
    end
    local configID = C_Traits.GetConfigIDByTreeID(legacy.LEGACY_TREE_ADVENTURE_ID)
    local node = configID and C_Traits.GetNodeInfo(configID, FREQUENT_FLIER_NODE)
    local rank = node and node.activeRank
    if issecretvalue and issecretvalue(rank) then
        return false
    end
    return rank and rank > 0
end

-- The logged-in character's perk. Another character or realm stored the base time.
local function BaseToActual(seconds)
    if not HasFrequentFlier() then
        return seconds
    end
    local scaled = math.floor(seconds / 1.2 + 0.5)
    if scaled < 1 then
        scaled = 1
    end
    return scaled
end

function ActualToBase(seconds)
    if not HasFrequentFlier() then
        return seconds
    end
    return math.floor(seconds * 1.2 + 0.5)
end

-- Saved total for this pair first. Else add FTCData edges. A saved total is never one hop.
-- The perk is applied on the way out.
local function ResolveTime(srcId, dstId, slot)
    if not srcId or not dstId then
        return
    end
    local measured = customTimes[srcId] and customTimes[srcId][dstId]
    -- A saved 0 is a failed click, not a flight. Fall through to the estimate.
    if type(measured) == "number" and measured > 0 then
        return BaseToActual(measured), false
    end
    local ids = RouteNodeIDs(slot, srcId, dstId)
    if not ids then
        return
    end
    local sum = 0
    for i = 1, #ids - 1 do
        local fromTimes = defaultTimes[ids[i]]
        local leg = fromTimes and fromTimes[ids[i + 1]]
        if type(leg) ~= "number" then
            return
        end
        sum = sum + leg
    end
    return BaseToActual(sum), true
end

local function AddFlightTime(seconds, isEstimate)
    AddEstimatedLine(seconds, isEstimate)
    GameTooltip:Show()
end

local function IsReachable(nodeType)
    if nodeType == "REACHABLE" then
        return true
    end
    return Enum and Enum.FlightPathState and nodeType == Enum.FlightPathState.Reachable
end

-- Keep the last source when this map has no "you are here" node.
local function ReadCurrentNode()
    local found = false
    if C_TaxiMap and type(C_TaxiMap.GetAllTaxiNodes) == "function" and Enum and Enum.FlightPathState then
        local mapID = GetViewedTaxiMapID()
        if mapID then
            local nodes = C_TaxiMap.GetAllTaxiNodes(mapID)
            if nodes then
                for i = 1, #nodes do
                    local node = nodes[i]
                    if node.state == Enum.FlightPathState.Current then
                        currentName = ShortName(node.name)
                        currentId = node.nodeID
                        found = true
                        break
                    end
                end
            end
        end
    end
    -- Old taxi map: the current node is a TaxiButton, not a flight-map pin.
    if found or type(NumTaxiNodes) ~= "function" or type(TaxiNodeGetType) ~= "function" or type(TaxiNodeName) ~=
        "function" then
        return
    end
    for i = 1, NumTaxiNodes() do
        if TaxiNodeGetType(i) == "CURRENT" then
            currentName = ShortName(TaxiNodeName(i))
            local id = GetNodeID(i)
            if id then
                currentId = id
            end
            return
        end
    end
end

local function WarnMissingPins()
    if pinsWarned then
        return
    end
    pinsWarned = true
    local which = L.NoMapFrame
    -- Frame names stay English. They name the UI object in a bug report.
    if FlightMapFrame then
        which = "FlightMapFrame"
    elseif TaxiFrame then
        which = "TaxiFrame"
    end
    consoleLog(format(L.PinsUnavailable, which), true)
end

-- One tooltip hook per pin. EnumerateActive yields the pin as the key.
local function HookOnePin(pin)
    if not pin or pin.ftcHooked or type(pin.HookScript) ~= "function" then
        return
    end
    pin.ftcHooked = true
    pin:HookScript("OnEnter", function(self)
        local data = self.taxiNodeData
        if not data or not IsReachable(data.state) then
            return
        end
        local seconds, isEstimate = ResolveTime(currentId, data.nodeID, data.slotIndex)
        AddFlightTime(seconds, isEstimate)
    end)
end

local function EachPoolPin(pool, visitor)
    if not pool or type(pool.EnumerateActive) ~= "function" then
        return 0
    end
    local found = 0
    for first, second in pool:EnumerateActive() do
        local pin = first
        if type(pin) ~= "table" and type(pin) ~= "userdata" then
            pin = second
        end
        if pin and pin.taxiNodeData and type(pin.HookScript) == "function" then
            visitor(pin)
            found = found + 1
        end
    end
    return found
end

-- The pin pool is created when the first pin is drawn, which is after TAXIMAP_OPENED.
local function HookFlightPins()
    local found = 0
    local pools = FlightMapFrame and FlightMapFrame.pinPools
    if pools then
        local named = pools.FlightMap_FlightPointPinTemplate
        found = EachPoolPin(named, HookOnePin)
        if found == 0 then
            for _, pool in pairs(pools) do
                if pool ~= named then
                    found = found + EachPoolPin(pool, HookOnePin)
                end
            end
        end
    end
    if found == 0 and FlightMapFrame and type(FlightMapFrame.GetNumChildren) == "function" then
        local function walk(frame)
            if not frame or type(frame.GetNumChildren) ~= "function" then
                return
            end
            for i = 1, frame:GetNumChildren() do
                local child = select(i, frame:GetChildren())
                if child and child.taxiNodeData then
                    HookOnePin(child)
                    found = found + 1
                end
                walk(child)
            end
        end
        walk(FlightMapFrame)
    end
    -- TaxiFrame buttons. Hook the button directly; the old global enter function may not exist.
    if type(NumTaxiNodes) == "function" then
        local count = NumTaxiNodes()
        if type(count) == "number" then
            for i = 1, count do
                local button = _G["TaxiButton" .. i]
                if button and type(button.IsShown) == "function" and button:IsShown() and type(button.HookScript) ==
                    "function" then
                    found = found + 1
                    if not button.ftcHooked then
                        button.ftcHooked = true
                        button:HookScript("OnEnter", function(self)
                            local slot = self:GetID()
                            if type(TaxiNodeGetType) == "function" and not IsReachable(TaxiNodeGetType(slot)) then
                                return
                            end
                            if not currentId then
                                ReadCurrentNode()
                            end
                            local seconds, isEstimate = ResolveTime(currentId, GetNodeID(slot), slot)
                            AddFlightTime(seconds, isEstimate)
                        end)
                    end
                end
            end
        end
    end
    return found
end

local function OnMapRefresh()
    ReadCurrentNode()
    HookFlightPins()
end

local function EnsureMapHooks()
    if FlightMapFrame and not mapHooked then
        if type(FlightMapFrame.SetMapID) == "function" then
            hooksecurefunc(FlightMapFrame, "SetMapID", OnMapRefresh)
        end
        if type(FlightMapFrame.HookScript) == "function" then
            FlightMapFrame:HookScript("OnShow", OnMapRefresh)
        end
        mapHooked = true
    end
    if TaxiFrame and not taxiShowHooked and type(TaxiFrame.HookScript) == "function" then
        TaxiFrame:HookScript("OnShow", OnMapRefresh)
        taxiShowHooked = true
    end
    if not loadHooked and type(FlightMap_LoadUI) == "function" then
        loadHooked = true
        hooksecurefunc("FlightMap_LoadUI", function()
            EnsureMapHooks()
            OnMapRefresh()
        end)
    end
end

FlightFrame:UnregisterAllEvents()
FlightFrame:RegisterEvent("ADDON_LOADED")
FlightFrame:RegisterEvent("PLAYER_LOGIN")
FlightFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
FlightFrame:RegisterEvent("TAXIMAP_OPENED")
FlightFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, ...)
end)

--[[
Slash Commands
--]]

local function FTCCommands(msg, editbox)

    local cmds = {
        debug = function()
            FTCConfig.debug = not FTCConfig.debug

            if FTCConfig.debug then
                consoleLog(format(L.DebugOn, Hi("/ftc debug")), true)
            else
                consoleLog(format(L.DebugOff, Hi("/ftc debug")), true)
            end
        end,
        mute = function()
            FTCConfig.mute = not FTCConfig.mute

            if FTCConfig.mute then
                consoleLog(format(L.MuteOn, Hi("/ftc mute")), true)
            else
                consoleLog(format(L.MuteOff, Hi("/ftc mute")), true)
            end
        end,
        show = function()
            if not FlightFrame:IsShown() then
                FlightFrame_Show()
                -- /ftc show sample. A real flight replaces it.
                if not startTime and not pendingSince then
                    FlightFrame.time:SetText(getFormattedTime(90))
                end
                consoleLog(format(L.TimerShown, Hi("/ftc hide")), true)
            else
                consoleLog(format(L.TimerAlreadyShown, Hi("/ftc hide")), true)
            end
        end,
        hide = function()
            if FlightFrame:IsShown() then
                FlightFrame:Hide()
                consoleLog(format(L.TimerHidden, Hi("/ftc show")), true)
            else
                consoleLog(format(L.TimerAlreadyHidden, Hi("/ftc show")), true)
            end
        end,
        help = function()
            consoleLog(format(L.HelpShow, Hi("/ftc show")), true)
            consoleLog(format(L.HelpHide, Hi("/ftc hide")), true)
            consoleLog(format(L.HelpMute, Hi("/ftc mute")), true)
            consoleLog(format(L.HelpDebug, Hi("/ftc debug")), true)
            consoleLog(format(L.HelpHelp, Hi("/ftc help")), true)
            consoleLog(L.HelpPaste, true)
        end
    }

    local func = cmds[msg]
    if (func) then
        func()
    else
        consoleLog(format(L.UnknownCommand, Hi(format("%q", msg))))
        cmds.help()
    end
end

SLASH_FLIGHTIMERCLASSIC1 = '/ftc'
SlashCmdList["FLIGHTIMERCLASSIC"] = FTCCommands

--[[
ADDON_LOADED
SavedVariables are not readable until this event.
--]]

function FlightFrame:ADDON_LOADED(loaded)
    if loaded ~= addonName then
        return
    end

    FTCCustomData = FTCCustomData or {}
    FTCConfig = FTCConfig or {}
    if FTCConfig.debug == nil then
        FTCConfig.debug = false
    end
    if FTCConfig.mute == nil then
        FTCConfig.mute = false
    end
    customTimes = FTCCustomData

    self:UnregisterEvent("ADDON_LOADED")
end

--[[
PLAYER_LOGIN
--]]

function FlightFrame:PLAYER_LOGIN()
    defaultTimes = FTCData or {}

    if FTCData then
        consoleLog(format(L.Ready, Hi("/ftc help")))
    else
        consoleLog(format(L.NoData, Hi("/ftc help")))
    end
end

--[[
PLAYER_CONTROL_GAINED
--]]

function FlightFrame:PLAYER_CONTROL_GAINED()

    if FTCConfig and FTCConfig.debug then
        consoleLog("PLAYER_CONTROL_GAINED")
    end

    -- Still in the air. The flight watch stops the clock once the taxi flag drops.
    if startTime and OnTaxi() then
        return
    end

    if startTime then
        FinishFlight()
        return
    end

    -- Clicked, not airborne yet. The flight watch is still waiting on the server.
    if pendingSince then
        return
    end

    ResetFlight()
end

--[[
TAXIMAP_OPENED
--]]

local bindSerial = 0

function FlightFrame:TAXIMAP_OPENED()
    -- Pins are drawn after this event. Try now, then twice on the following frames.
    bindSerial = bindSerial + 1
    local serial = bindSerial
    local function tryBind(step)
        if serial ~= bindSerial then
            return
        end
        EnsureMapHooks()
        ReadCurrentNode()
        if HookFlightPins() > 0 then
            return
        end
        if step < 2 and C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0, function()
                tryBind(step + 1)
            end)
        else
            WarnMissingPins()
        end
    end
    tryBind(0)
end

--[[
TakeTaxiNode
--]]

hooksecurefunc("TakeTaxiNode", function(slot)

    -- A second click replaces a wait that has not left the ground. Log that wait first.
    StopFlightWatch("restarted")
    flightStarted = true
    if not currentId then
        ReadCurrentNode()
    end
    endName = ShortName(TaxiNodeName(slot))
    endId = GetNodeID(slot)
    -- The clock starts in the flight watch, once the character is on the taxi.
    startTime = nil
    endTime = nil
    pendingSince = GetTime()
    estimatedT, timeIsEstimate = ResolveTime(currentId, endId, slot)

    if estimatedT == nil then
        consoleLog(format(L.UnknownFlight, Hi(currentName or UNKNOWN), Hi(endName or UNKNOWN)))
    end

    FlightFrame_Show()
    StartFlightWatch()
end)

--[[
AcceptBattlefieldPort
--]]

hooksecurefunc("AcceptBattlefieldPort", function(index, accept)
    if FTCConfig and FTCConfig.debug then
        consoleLog("AcceptBattlefieldPort")
    end

    if accept and flightStarted then
        CancelFlight()
    end
end)

--[[
ConfirmSummon
--]]

if C_SummonInfo and type(C_SummonInfo.ConfirmSummon) == "function" then
    hooksecurefunc(C_SummonInfo, "ConfirmSummon", function()
        if FTCConfig and FTCConfig.debug then
            consoleLog("ConfirmSummon")
        end

        if flightStarted then
            CancelFlight()
        end
    end)
end

--[[
TaxiRequestEarlyLanding
--]]

if type(TaxiRequestEarlyLanding) == "function" then
    hooksecurefunc("TaxiRequestEarlyLanding", function()
        if FTCConfig and FTCConfig.debug then
            consoleLog("TaxiRequestEarlyLanding")
        end

        if flightStarted then
            CancelFlight()
        end
    end)
end
