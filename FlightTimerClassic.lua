--[[--------------------------------------------------------------------
	Flight Timer Classic by Nomana-Kingsfall
	CC BY 2.0 (https://creativecommons.org/licenses/by/2.0/)
	Huge credit to PhanxFlightTimer, InFlight and Consequence-Flightmaster
	which helped me to put together FTC as my first addon
	https://github.com/phanx-wow/PhanxFlightTimer
	https://www.curseforge.com/wow/addons/inflight-taxi-timer
	https://www.curseforge.com/wow/addons/consequence-flightmaster
----------------------------------------------------------------------]]

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

local defaultTimes = {}

local Addon = CreateFrame("Frame", "FlightTimerClassic", UIParent)

Addon:UnregisterAllEvents()
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)

local currentName, currentHash, startTime, endName, endHash, endTime
local showDebug = false

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

local function getTaxiNodeInfo(i)
	local name = strmatch(TaxiNodeName(i), "[^,]+")
	return name, getTaxiNodeHash(i)
end

local function consoleLog(text)
	print(format("|cff00ccff[FlightTimerClassic]|cff66ddff %s", text))
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
		CopyFrame.text:SetText("Please share this data with Flight Timer Classic.\nThanks for helping to improve this AddOn.")

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

local FlightFrame
local function FlightFrame_Show()

	if not FlightFrame then
		FlightFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		FlightFrame:EnableMouse(true)
		FlightFrame:SetMovable(true)
		FlightFrame:SetWidth(120)
		FlightFrame:SetHeight(48)
		FlightFrame:SetPoint("CENTER", 0, 0);

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
			GameTooltip:AddDoubleLine(L.FlyingFrom, currentName, 1, 0.82, 0, 1, 1, 1)
			GameTooltip:AddDoubleLine(L.FlyingTo, endName, 1, 0.82, 0, 1, 1, 1)
			
			local t = defaultTimes[currentHash] and defaultTimes[currentHash][endHash]
			GameTooltip:AddDoubleLine(L.EstimatedTime, getFormattedTime(t), 1, 0.82, 0, 1, 1, 1)
			GameTooltip:Show()
		end)

		FlightFrame:SetScript("OnLeave", GameTooltip_Hide)

		FlightFrame:SetScript("OnUpdate", function(self, elapsed)
			local now = GetTime()
			if now <= endTime then
				local t = endTime - now
				self.time:SetText(getFormattedTime(t))
			else
				self.time:SetText('0s')
			end
		end)

		FlightFrame.time = FlightFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
		FlightFrame.time:SetPoint("CENTER", FlightFrame, "CENTER")

		FlightFrame:Show()
	end

	local t = defaultTimes[currentHash] and defaultTimes[currentHash][endHash]
	FlightFrame.time:SetText(getFormattedTime(t))
end
local function FlightFrame_Hide()
	if FlightFrame ~= nil then
		FlightFrame:Hide()
	end
end

function Addon:PLAYER_LOGIN()  
	local faction = UnitFactionGroup("player")
	
	--FlightFrame_Show()

	if FTCData[faction] ~= nil then
		defaultTimes = FTCData[faction]
		
		self:RegisterEvent("PLAYER_CONTROL_GAINED")
		self:RegisterEvent("TAXIMAP_OPENED")
		
		consoleLog(faction .. ' Flightpaths loaded.')
		print()
	else
		consoleLog("No flight data found for" .. faction .. '.')
	end

	
	local function FTCCommands(msg, editbox)
		if msg == 'debug' then
			showDebug = not showDebug

			if showDebug then
				consoleLog('Debug enabled. Type /ftc debug again to disable.')
			else
				consoleLog('Debug disabled. Type /ftc debug again to enable.')
			end
		elseif msg == 'help' then
			consoleLog('/ftc debug – Enable/disable debug output.')
			consoleLog('/ftc help – Show this help text.')
		else
			consoleLog('unkown command. Type /ftc help to see all commands.')
		end
	end
	
	SLASH_FLIGHTIMERCLASSIC1, SLASH_FLIGHTIMERCLASSIC2 = '/ftc', '/flighttimerclassic'
	
	SlashCmdList["FLIGHTIMERCLASSIC"] = FTCCommands
--
end

function Addon:PLAYER_CONTROL_GAINED()
	--print("PLAYER_CONTROL_GAINED")
	FlightFrame_Hide()
end

function Addon:TAXIMAP_OPENED()
	--print("TAXIMAP_OPENED")

	local nodesInfo = "name;x;y"

	for i = 1, NumTaxiNodes() do
		
		local nodeType = TaxiNodeGetType(i)
		local name, hash = getTaxiNodeInfo(i)
		local x, y = TaxiNodePosition(i)

		if nodeType == "CURRENT" then
			currentName, currentHash = name, hash
		end

		nodesInfo = nodesInfo .. "\n" .. name .. ";" .. x .. ";" .. y
	end

	if showDebug then
		CopyFrame_Show(nodesInfo)
	end
end

hooksecurefunc("TaxiNodeOnButtonEnter", function(button)

	local i = button:GetID()
	local name, hash = getTaxiNodeInfo(i)

	local t = defaultTimes[currentHash] and defaultTimes[currentHash][hash]

	if t then
		GameTooltip:AddDoubleLine(L.EstimatedTime, getFormattedTime(t), 1, 0.82, 0, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine(L.EstimatedTime, UNKNOWN, 1, 0.82, 0, 0.6, 0.6, 0.6)
	end

	GameTooltip:Show()

end)

hooksecurefunc("TakeTaxiNode", function(i)
	--print("TakeTaxiNode", i)
	endName, endHash = getTaxiNodeInfo(i)
	
	local now = GetTime()
	local t = defaultTimes[currentHash] and defaultTimes[currentHash][endHash]

	startTime = now

	if t == nil then
		endTime = nil
	else
		endTime = startTime + t
	end

	FlightFrame_Show()
end)

hooksecurefunc("AcceptBattlefieldPort", function(index, accept) 
	--print("AcceptBattlefieldPort")
	FlightFrame_Hide()
end)

hooksecurefunc(C_SummonInfo, "ConfirmSummon", function()
	print("|cffff8080Summon|cff208080, porttaken -|r")
	FlightFrame_Hide()
end)