local addonName = ...

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
-- True after UnitOnTaxi has been seen during this flight. Landing clears it.
local confirmedTaxi
-- A refused takeoff (not enough money) never leaves the ground. Give up after this.
local TAKEOFF_WAIT = 5
local mapHooked = false
local taxiShowHooked = false
local loadHooked = false
local pinsWarned = false


--[[
Localization
--]]

local L = {
	EstimatedTime = "Estimated time:",
	RecordedTime = "Recorded time:",
	FlyingFrom = "Flying from:",
	FlyingTo = "Flying to:",
	TimeMinSec = gsub(MINUTE_ONELETTER_ABBR, "%s", "") .. " " .. gsub(SECOND_ONELETTER_ABBR, "%s", ""),
	TimeSec = gsub(SECOND_ONELETTER_ABBR, "%s", ""),
}
if GetLocale() == "deDE" then
	L.EstimatedTime = "Geschätzte Flugzeit:"
	L.RecordedTime = "Erfasste Flugzeit:"
	L.FlyingFrom = "Fliegt von:"
	L.FlyingTo = "Flug nach:"
elseif strmatch(GetLocale(), "^es") then
	L.EstimatedTime = "Tiempo estimado:"
	L.RecordedTime = "Tiempo registrado:"
	L.FlyingFrom = "Vuelo de:"
	L.FlyingTo = "Vuelo a:"
end


--[[
Local Functions
--]]

local function Frame_OnMouseDown(frame)
	frame:StartMoving()
end

local function Frame_OnMouseUp(frame)
	frame:StopMovingOrSizing()
end

-- "Stormwind, Elwynn" is stored and shown as "Stormwind".
local function ShortName(name)
	if not name then
		return
	end
	return strmatch(name, "[^,]+")
end

local function consoleLog(text, important)
	if important or not FTCConfig or not FTCConfig.mute then
		print(format("|cff00ccff[FlightTimerClassic]|cff66ddff %s", text))
	end
end

local function getFormattedTime(t)
	if t then
		if t > 60 then
			return format(L.TimeMinSec, t/60, mod(t,60))
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
CopyFrame
--]]

local CopyFrame
local function CopyFrame_Show(text)

	if not CopyFrame then
		CopyFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		CopyFrame:SetMovable(true)
		CopyFrame:SetScript("OnMouseDown", Frame_OnMouseDown)
		CopyFrame:SetScript("OnMouseUp", Frame_OnMouseUp)
		CopyFrame:SetClampedToScreen(true)
		CopyFrame:SetSize(480,360)
		CopyFrame:SetPoint("CENTER")

		CopyFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 16,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})

		CopyFrame.text = CopyFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		CopyFrame.text:SetWidth(400)
		CopyFrame.text:SetPoint("CENTER", CopyFrame, "TOP", 0, -30)
		CopyFrame.text:SetText("Please share this data with Flight Timer Classic.\nThanks for your contribution to improve this AddOn.")

		CopyFrame.scrollFrame = CreateFrame("ScrollFrame", "MyMultiLineEditBox", CopyFrame, "InputScrollFrameTemplate")
		CopyFrame.scrollFrame:SetSize(480-32,240)
		CopyFrame.scrollFrame:SetPoint("CENTER")
		CopyFrame.scrollFrame.EditBox:SetFontObject("ChatFontNormal")
		CopyFrame.scrollFrame.EditBox:SetMaxLetters(0)
		CopyFrame.scrollFrame.EditBox:SetWidth(480-32)
		CopyFrame.scrollFrame.CharCount:Hide()
		CopyFrame.scrollFrame.EditBox:SetScript("OnEscapePressed", function() CopyFrame:Hide() end)

		CopyFrame.CloseButton = CreateFrame("Button", nil, CopyFrame, "GameMenuButtonTemplate");
		CopyFrame.CloseButton:SetPoint("BOTTOM", CopyFrame, "BOTTOM", 0, 20);
		CopyFrame.CloseButton:SetSize(96, 24);
		CopyFrame.CloseButton:SetText("Close");
		CopyFrame.CloseButton:SetScript("OnClick", function() CopyFrame:Hide() end)
	end

	CopyFrame.scrollFrame.EditBox:SetText(text)
	CopyFrame.scrollFrame.EditBox:SetAutoFocus(true)
	CopyFrame.scrollFrame.EditBox:HighlightText()
	CopyFrame:Show()
end


--[[
FlightFrame
--]]

local flightFrameLoaded = false
local FlightFrame = CreateFrame("Frame", "FlightTimerClassic", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
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
local function AbortTakeoff()
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

-- Save the flight and hide the box. Safe to call twice.
local function FinishFlight()
	if not startTime then
		return
	end
	local t = ceil(GetTime() - startTime)
	local flightInfo = "|cffcceeff" .. (currentName or UNKNOWN) .. "|cff66ddff to |cffcceeff" .. (endName or UNKNOWN) .. "|cff66ddff took |cffcceeff" .. getFormattedTime(t)

	if endTime == nil then
		consoleLog("New data: " .. flightInfo .. "|cff66ddff.")
	elseif abs(t - estimatedT) > 2 then -- allow 2 seconds error margin before nagging around
		consoleLog("Correction: " .. flightInfo .. "|cff66ddff (was |cffcceeff" .. getFormattedTime(estimatedT) .. "|cff66ddff).")
	else
		consoleLog("Arrived at |cffcceeff" .. (endName or UNKNOWN) .. "|cff66ddff after |cffcceeff" .. getFormattedTime(t) .. "|cff66ddff.")
	end

	-- Numeric node ids. Old Alliance / Horde hash keys are left in place.
	if currentId and endId and t > 0 then
		customTimes[currentId] = customTimes[currentId] or {}
		customTimes[currentId][endId] = t
	end

	ResetFlight()
end

local function FlightFrame_Show()

	if not flightFrameLoaded then
		
		flightFrameLoaded = true

		FlightFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 16,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})
		
		FlightFrame:SetScript("OnMouseDown", Frame_OnMouseDown)
		FlightFrame:SetScript("OnMouseUp", Frame_OnMouseUp)

		FlightFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
			GameTooltip:SetText("Flight Timer Classic")
			GameTooltip:AddDoubleLine(L.FlyingFrom, currentName or UNKNOWN, 1, 0.82, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine(L.FlyingTo, endName or UNKNOWN, 1, 0.82, 0, 1, 1, 1)

			AddEstimatedLine(estimatedT, timeIsEstimate)

			GameTooltip:Show()
		end)

		FlightFrame:SetScript("OnLeave", GameTooltip_Hide)

		FlightFrame:SetScript("OnUpdate", function(self, elapsed)
			if not startTime then
				local onTaxi = pendingSince and OnTaxi()
				-- false: still on the ground. nil: the API cannot answer, so start anyway.
				if pendingSince and onTaxi ~= false then
					BeginFlightClock()
				elseif pendingSince and GetTime() - pendingSince > TAKEOFF_WAIT then
					AbortTakeoff()
					return
				else
					self.time:SetText(UNKNOWN)
					return
				end
			end

			-- The landing event can run while the taxi flag is still set, and it does not fire again.
			local onTaxi = OnTaxi()
			if onTaxi == true then
				confirmedTaxi = true
			elseif onTaxi == false and confirmedTaxi then
				FinishFlight()
				return
			end

			local now = GetTime()

			-- endTime unknown, show count up
			if endTime == nil then
				local t = now - startTime
				self.time:SetText(getFormattedTime(t))

			-- endTime known, show count down
			else 
				local t = ceil(endTime - now)
				if t >= 0 then
					self.time:SetText(getFormattedTime(t))
				else
					self.time:SetText('+' .. getFormattedTime((t-1) * -1))
				end
			end
		end)

		FlightFrame.time = FlightFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
		FlightFrame.time:SetPoint("CENTER", FlightFrame, "CENTER")
	end
	
	FlightFrame.time:SetText(UNKNOWN)
	FlightFrame:Show()
end

local function CancelFlight()
	consoleLog("Flight cancelled.")
	-- Nothing to save on landing: the clock is cleared before control returns.
	AbortTakeoff()
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
		return { srcId, dstId }
	end
	local numRoutes = GetNumRoutes(slot)
	if not numRoutes or numRoutes < 2 then
		return { srcId, dstId }
	end
	local ids = { srcId }
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

-- Frequent Flier is legacy node 110300, spell 1225490. Mounts are 20% faster,
-- so a base estimate is divided by 1.2. The node is how the game menu reads it.
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

-- Saved total for this pair first. Else the same saved seconds for the direct flight back.
-- A saved total is never one hop.
local function ResolveTime(srcId, dstId, slot)
	if not srcId or not dstId then
		return
	end
	local measured = customTimes[srcId] and customTimes[srcId][dstId]
	-- A saved 0 is a failed click, not a flight. Fall through to the estimate.
	if type(measured) == "number" and measured > 0 then
		return measured, false
	end
	local ids = RouteNodeIDs(slot, srcId, dstId)
	if not ids then
		return
	end
	-- Direct return only. A multi-hop total is a different road.
	if #ids == 2 then
		local reverse = customTimes[dstId] and customTimes[dstId][srcId]
		if type(reverse) == "number" and reverse > 0 then
			return reverse, false
		end
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
	if HasFrequentFlier() then
		sum = math.floor(sum / 1.2 + 0.5)
		if sum < 1 then
			sum = 1
		end
	end
	return sum, true
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
	if found or type(NumTaxiNodes) ~= "function" or type(TaxiNodeGetType) ~= "function" or type(TaxiNodeName) ~= "function" then
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
	local which = "no map frame"
	if FlightMapFrame then
		which = "FlightMapFrame"
	elseif TaxiFrame then
		which = "TaxiFrame"
	end
	consoleLog("Flight map pins unavailable (" .. which .. ").", true)
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
				if button and type(button.IsShown) == "function" and button:IsShown() and type(button.HookScript) == "function" then
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

local function ShowDebugNodes()
	if not C_TaxiMap or type(C_TaxiMap.GetAllTaxiNodes) ~= "function" then
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
	local lines = "name;nodeID;x;y"
	for i = 1, #nodes do
		local node = nodes[i]
		local pos = node.position
		local x = pos and pos.x or ""
		local y = pos and pos.y or ""
		lines = lines .. "\n" .. (ShortName(node.name) or "") .. ";" .. (node.nodeID or "") .. ";" .. x .. ";" .. y
	end
	CopyFrame_Show(lines)
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
				consoleLog('Debug enabled. Type |cffcceeff/ftc debug |cff66ddffagain to disable.', true)
				ShowDebugNodes()
			else
				consoleLog('Debug disabled. Type |cffcceeff/ftc debug |cff66ddffagain to enable.', true)
			end
		end,
		mute = function()
			FTCConfig.mute = not FTCConfig.mute

			if FTCConfig.mute then
				consoleLog('Disabled info messages. Type |cffcceeff/ftc mute |cff66ddffagain to unmute.', true)
			else
				consoleLog('Enabled info messages. Type |cffcceeff/ftc mute |cff66ddffagain to mute.', true)
			end
		end,
		show = function()
			-- show some fake up counting
			if startTime == nil then
				startTime = GetTime()
			end
			if FlightFrame == nil or not FlightFrame:IsShown() then
				FlightFrame_Show()
				consoleLog('Revealed FTC UI for positioning. Type |cffcceeff/ftc hide |cff66ddffto hide.', true)
			else 
				consoleLog('FTC UI should already be visible.', true)
			end
		end,
		hide = function()
			FlightFrame:Hide()
			consoleLog('Hiding FTC UI.', true)
		end,
		help = function()
			consoleLog('|cffcceeff/ftc show |cff66ddff– Show the FTC UI for positioning.', true)
			consoleLog('|cffcceeff/ftc hide |cff66ddff– Hide the FTC UI.', true)
			consoleLog('|cffcceeff/ftc debug |cff66ddff– Enable/disable debug output.', true)
			consoleLog('|cffcceeff/ftc help |cff66ddff– Show this help text.', true)
		end
	}

	local func = cmds[msg]
	if(func) then
		func()
	else
		consoleLog(format('unkown command: |cffcceeff%q', msg))
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
		consoleLog("Flight paths loaded.")
	else
		consoleLog("There are currently no flight durations included.")
	end
end


--[[
PLAYER_CONTROL_GAINED
--]]

function FlightFrame:PLAYER_CONTROL_GAINED()
	
	if FTCConfig and FTCConfig.debug then
		consoleLog("PLAYER_CONTROL_GAINED")
	end

	-- Still in the air. OnUpdate stops the clock once the taxi flag drops.
	if startTime and OnTaxi() then
		return
	end

	if startTime then
		FinishFlight()
		return
	end

	-- Clicked, not airborne yet. OnUpdate gives the takeoff a few seconds.
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

	if FTCConfig and FTCConfig.debug then
		ShowDebugNodes()
	end
end


--[[
TakeTaxiNode
--]]

hooksecurefunc("TakeTaxiNode", function(slot)

	flightStarted = true
	if not currentId then
		ReadCurrentNode()
	end
	endName = ShortName(TaxiNodeName(slot))
	endId = GetNodeID(slot)
	-- The clock starts in OnUpdate, once the character is on the taxi.
	startTime = nil
	endTime = nil
	pendingSince = GetTime()
	estimatedT, timeIsEstimate = ResolveTime(currentId, endId, slot)

	if estimatedT == nil then
		consoleLog("Unknown flightpath. Measuring duration from |cffcceeff" .. (currentName or UNKNOWN) .. "|cff66ddff to |cffcceeff" .. (endName or UNKNOWN) .. "|cff66ddff.")
	end

	FlightFrame_Show()
end)


--[[
AcceptBattlefieldPort
--]]

if type(AcceptBattlefieldPort) == "function" then
	hooksecurefunc("AcceptBattlefieldPort", function(index, accept)
		if FTCConfig and FTCConfig.debug then
			consoleLog("AcceptBattlefieldPort")
		end

		if flightStarted then
			CancelFlight()
		end
	end)
end


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
