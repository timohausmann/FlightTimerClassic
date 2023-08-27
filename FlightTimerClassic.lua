--[[--------------------------------------------------------------------
	Flight Timer Classic by Nomana-Kingsfall
	CC BY 2.0 (https://creativecommons.org/licenses/by/2.0/)
    https://www.curseforge.com/wow/addons/flight-timer-classic
    https://github.com/timohausmann/FlightTimerClassic

	Huge credit to PhanxFlightTimer, InFlight and Consequence-Flightmaster
	from which I more or less frankensteined this AddOn together.
	https://github.com/phanx-wow/PhanxFlightTimer
	https://www.curseforge.com/wow/addons/inflight-taxi-timer
	https://www.curseforge.com/wow/addons/consequence-flightmaster

	@TODO
	* Bugfix: Not enough money to fly starts timer nevertheless
----------------------------------------------------------------------]]

FTCCustomData = { Alliance = {}, Horde = {} }
FTCConfig = {
	debug = false,
	mute = false
}

local currentName, currentHash, startTime, endName, endHash, endTime, estimatedT
local defaultTimes = {}
local customTimes = {}
local flightStarted = false


--[[
Localization
--]]

local L = {
	EstimatedTime = "Estimated time:",
	FlyingFrom = "Flying from:",
	FlyingTo = "Flying to:",
	TimeMinSec = gsub(MINUTE_ONELETTER_ABBR, "%s", "") .. " " .. gsub(SECOND_ONELETTER_ABBR, "%s", ""),
	TimeSec = gsub(SECOND_ONELETTER_ABBR, "%s", ""),
}
if GetLocale() == "deDE" then
	L.EstimatedTime = "Geschätzte Flugzeit:"
	L.FlyingFrom = "Fliegt von:"
	L.FlyingTo = "Flug nach:"
elseif strmatch(GetLocale(), "^es") then
	L.EstimatedTime = "Tiempo estimado:"
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

local function getTaxiNodeHash(i)
	local x, y = TaxiNodePosition(i)
	return tostring(floor(x * 100000000))
end

local function getTaxiNodeName(i)
	return strmatch(TaxiNodeName(i), "[^,]+")
end

local function consoleLog(text, important)
	if important or not FTCConfig.mute then
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


--[[
CopyFrame
https://www.wowinterface.com/forums/showthread.php?t=55498
https://www.reddit.com/r/wowaddons/comments/8ddudp/devhelp_editbox_with_text/
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
			
			if estimatedT then
				GameTooltip:AddDoubleLine(L.EstimatedTime, getFormattedTime(estimatedT), 1, 0.82, 0, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(L.EstimatedTime, UNKNOWN, 1, 0.82, 0, 0.6, 0.6, 0.6)
			end

			GameTooltip:Show()
		end)

		FlightFrame:SetScript("OnLeave", GameTooltip_Hide)

		FlightFrame:SetScript("OnUpdate", function(self, elapsed)
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
	-- reset startTime, so nothing will be logged upon PLAYER_CONTROL_GAINED
	startTime = nil
	FlightFrame:Hide()
end

FlightFrame:UnregisterAllEvents()
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
PLAYER_LOGIN
--]]

function FlightFrame:PLAYER_LOGIN()  
	local faction = UnitFactionGroup("player")

	customTimes = FTCCustomData[faction]

	if FTCData[faction] ~= nil then
		defaultTimes = FTCData[faction]
		consoleLog("|cffcceeff" .. faction .. " |cff66ddffflightpaths loaded.")
	else
		consoleLog("There are currently no flight durations included for |cffcceeff" .. faction .. '|cff66ddff. Hit me up on Discord if you want to help out.')
	end
end


--[[
PLAYER_CONTROL_GAINED
--]]

function FlightFrame:PLAYER_CONTROL_GAINED()
	
	if FTCConfig.debug then
		consoleLog("PLAYER_CONTROL_GAINED")
	end
	
	FlightFrame:Hide()

	-- always save the recorded time
	if startTime then
		local now = GetTime()
		local t = ceil(now - startTime)
		local flightInfo = "|cffcceeff" .. currentName .. "|cff66ddff to |cffcceeff" .. endName .. "|cff66ddff took |cffcceeff" .. getFormattedTime(t);
		
		if endTime == nil then
			consoleLog("New data: " .. flightInfo .. "|cff66ddff.")
		elseif abs(t - estimatedT) > 2 then -- allow 2 seconds error margin before nagging around
			consoleLog("Correction: " .. flightInfo .. "|cff66ddff (was |cffcceeff" .. getFormattedTime(estimatedT) .. "|cff66ddff).")
		else
			consoleLog("Arrived at |cffcceeff" .. endName .. "|cff66ddff after |cffcceeff" .. getFormattedTime(t) .. "|cff66ddff.")
		end

		customTimes[currentHash] = customTimes[currentHash] or {}
		customTimes[currentHash][endHash] = t
	end

	-- reset
	flightStarted = false
	currentName = nil
	currentHash = nil
	startTime = nil
	endName = nil
	endHash = nil
	endTime = nil
	estimatedT = nil
	
end


--[[
TAXIMAP_OPENED
--]]

function FlightFrame:TAXIMAP_OPENED()

	for i = 1, NumTaxiNodes() do
		
		local nodeType = TaxiNodeGetType(i)
		local name = getTaxiNodeName(i)
		local hash = getTaxiNodeHash(i)

		if nodeType == "CURRENT" then
			currentName, currentHash = name, hash
		end
	end

	if FTCConfig.debug then
		local nodesInfo = "name;hash;x;y"
		for i = 1, NumTaxiNodes() do
			local name = getTaxiNodeName(i)
			local hash = getTaxiNodeHash(i)
			local x, y = TaxiNodePosition(i)
			nodesInfo = nodesInfo .. "\n" .. name .. ";" .. hash .. ";" .. x .. ";" .. y
		end
		CopyFrame_Show(nodesInfo)
	end
end


--[[
TaxiNodeOnButtonEnter
--]]

hooksecurefunc("TaxiNodeOnButtonEnter", function(button)

	local i = button:GetID()
	local nodeType = TaxiNodeGetType(i)

	if nodeType ~= "CURRENT" then
		local hash = getTaxiNodeHash(i)
		local t = customTimes[currentHash] and customTimes[currentHash][hash] or defaultTimes[currentHash] and defaultTimes[currentHash][hash]

		if t then
			GameTooltip:AddDoubleLine(L.EstimatedTime, getFormattedTime(t), 1, 0.82, 0, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine(L.EstimatedTime, UNKNOWN, 1, 0.82, 0, 0.6, 0.6, 0.6)
		end

		GameTooltip:Show()
	end

end)


--[[
TakeTaxiNode
--]]

hooksecurefunc("TakeTaxiNode", function(i)

	flightStarted = true
	endName = getTaxiNodeName(i)
	endHash = getTaxiNodeHash(i)
	startTime = GetTime()
	estimatedT = customTimes[currentHash] and customTimes[currentHash][endHash] or defaultTimes[currentHash] and defaultTimes[currentHash][endHash]

	if estimatedT == nil then
		endTime = nil
		consoleLog("Unknown flightpath. Measuring duration from |cffcceeff" .. currentName .. "|cff66ddff to |cffcceeff" .. endName .. "|cff66ddff.")
	else	
		endTime = startTime + estimatedT
	end

	FlightFrame_Show()
end)


--[[
AcceptBattlefieldPort
--]]

hooksecurefunc("AcceptBattlefieldPort", function(index, accept) 
	if FTCConfig.debug then
		consoleLog("AcceptBattlefieldPort")
	end

	if flightStarted then
		CancelFlight()
	end
end)


--[[
ConfirmSummon
--]]

hooksecurefunc(C_SummonInfo, "ConfirmSummon", function()
	if FTCConfig.debug then
		consoleLog("ConfirmSummon")
	end

	if flightStarted then
		CancelFlight()
	end
end)


--[[
TaxiRequestEarlyLanding
--]]

hooksecurefunc("TaxiRequestEarlyLanding", function()
	if FTCConfig.debug then
		consoleLog("TaxiRequestEarlyLanding")
	end

	if flightStarted then
		CancelFlight()
	end
end)