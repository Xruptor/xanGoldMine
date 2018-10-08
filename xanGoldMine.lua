
local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent)
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local start, max, starttime, startlevel

addon:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

local function GetPlayerMoney()
	return (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
end

----------------------
--      Enable      --
----------------------

--trigger quest scans
-- local triggers = {
	-- ["QUEST_COMPLETE"] = true,
	-- ["UNIT_QUEST_LOG_CHANGED"] = true,
	-- ["QUEST_WATCH_UPDATE"] = true,
	-- ["QUEST_FINISHED"] = true,
	-- ["QUEST_LOG_UPDATE"] = true,
-- }

--[[ 	function E:QUEST_ACCEPTED(questLogIndex, questID, ...)
		if IsQuestTask(questID) then
			-- print('TASK_QUEST_ACCEPTED', questID, questLogIndex, GetQuestLogTitle(questLogIndex))
			local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
			if questName then
				ActiveWorldQuests[ questName ] = questID
			end
		else
			-- print('QUEST_ACCEPTED', questID, questLogIndex, GetQuestLogTitle(questLogIndex))
		end
	end
	
	function E:QUEST_REMOVED(questID)
		local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
		if questName and ActiveWorldQuests[ questName ] then
			ActiveWorldQuests[ questName ] = nil
			-- print('TASK_QUEST_REMOVED', questID, questName)
			-- get task progress when it's updated to display on the nameplate
			-- C_TaskQuest.GetQuestProgressBarInfo
		end
	end ]]

function addon:PLAYER_LOGIN()

	if not XanGM_DB then XanGM_DB = {} end
	if XanGM_DB.bgShown == nil then XanGM_DB.bgShown = true end
	if XanGM_DB.scale == nil then XanGM_DB.scale = 1 end

	self:CreateGoldFrame()
	self:RestoreLayout(ADDON_NAME)
	
	local currentPlayer = UnitName("player")
	local currentRealm = select(2, UnitFullName("player")) --get shortend realm name with no spaces and dashes

	XanGM_DB[currentRealm] = XanGM_DB[currentRealm] or {}
	XanGM_DB[currentRealm][currentPlayer] = XanGM_DB[currentRealm][currentPlayer] or {}
	addon.playerDB = XanGM_DB[currentRealm][currentPlayer]
	
	addon:PLAYER_MONEY()
	
	
	--start, max, starttime = UnitXP("player"), UnitXPMax("player"), GetTime()
	--startlevel = UnitLevel("player") + start/max
	
	
	self:RegisterEvent("PLAYER_MONEY")

	SLASH_XANGOLDMINE1 = "/xgm";
	SlashCmdList["XANGOLDMINE"] = xanGoldMine_SlashCommand;
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xgm", ADDON_NAME, ver or "1.0"))
	
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function xanGoldMine_SlashCommand(cmd)

	local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters
	
	if a then
		if c and c:lower() == L.SlashBG then
			addon.aboutPanel.btnBG.func(true)
			return true
		elseif c and c:lower() == L.SlashReset then
			addon.aboutPanel.btnReset.func()
			return true
		elseif c and c:lower() == L.SlashScale then
			if b then
				local scalenum = strsub(cmd, b+2)
				if scalenum and scalenum ~= "" and tonumber(scalenum) and tonumber(scalenum) > 0 and tonumber(scalenum) <= 200 then
					addon.aboutPanel.sliderScale.func(tonumber(scalenum))
				else
					DEFAULT_CHAT_FRAME:AddMessage(L.SlashScaleSetInvalid)
				end
				return true
			end
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage(ADDON_NAME, 64/255, 224/255, 208/255)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashReset.." - "..L.SlashResetInfo);
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashBG.." - "..L.SlashBGInfo);
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashScale.." # - "..L.SlashScaleInfo)
end


function addon:CreateGoldFrame()

	addon:SetWidth(61)
	addon:SetHeight(27)
	addon:SetMovable(true)
	addon:SetClampedToScreen(true)
	
	addon:SetScale(XanGM_DB.scale)
	
	if XanGM_DB.bgShown then
		addon:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5);
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end
	
	addon:EnableMouse(true);
	
	local t = addon:CreateTexture("$parentIcon", "ARTWORK")
	t:SetTexture("Interface\\AddOns\\xanEXP\\icon")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetPoint("TOPLEFT",5,-6)

	local g = addon:CreateFontString("xanEXPText", "ARTWORK", "GameFontNormalSmall")
	g:SetJustifyH("LEFT")
	g:SetPoint("CENTER",8,0)
	g:SetText("?")

	addon:SetScript("OnMouseDown",function()
		if (IsShiftKeyDown()) then
			self.isMoving = true
			self:StartMoving();
	 	end
	end)
	addon:SetScript("OnMouseUp",function()
		if( self.isMoving ) then

			self.isMoving = nil
			self:StopMovingOrSizing()

			addon:SaveLayout(ADDON_NAME)

		end
	end)
	addon:SetScript("OnLeave",function()
		GameTooltip:Hide()
	end)

	addon:SetScript("OnEnter",function()
	
		-- GameTooltip:SetOwner(self, "ANCHOR_NONE")
		-- GameTooltip:SetPoint(self:GetTipAnchor(self))
		-- GameTooltip:ClearLines()

		-- GameTooltip:AddLine(ADDON_NAME)
		-- GameTooltip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		-- GameTooltip:AddLine(" ")
		
		-- local cur = UnitXP("player")
		-- local maxXP = UnitXPMax("player")
		-- local restXP = GetXPExhaustion() or 0
		-- local remainXP = maxXP - (cur + restXP)
		-- local toLevelXPPercent = math.floor((maxXP - cur) / maxXP * 100)
		
        -- local sessionTime = GetTime() - starttime
		-- local xpGainedSession = (cur - start)
        -- local xpPerSecond = ceil(xpGainedSession / sessionTime)
		-- local xpPerMinute = ceil(xpPerSecond * 60)
        -- local xpPerHour = ceil(xpPerSecond * 3600)
        -- local timeToLevel
		-- if xpPerSecond <= 0 then
			-- timeToLevel = L.TooltipTimeToLevelNone
		-- else
			-- timeToLevel = (maxXP - cur) / xpPerSecond
		-- end
		-- GameTooltip:AddDoubleLine(L.TooltipEXP, cur.."/"..max, nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipRest, string.format("%d%%", (GetXPExhaustion() or 0)/max*100), nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipToNextLevel, maxXP-cur..(" ("..toLevelXPPercent.."%)"), nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipXPPerSec, xpPerSecond, nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipXPPerMinute, xpPerMinute, nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipXPPerHour, xpPerHour, nil,nil,nil, 1,1,1)
		-- GameTooltip:AddDoubleLine(L.TooltipTimeToLevel, FormatTime(timeToLevel), nil,nil,nil, 1,1,1)
		-- GameTooltip:AddLine(string.format(L.TooltipSessionHoursPlayed, ceil(sessionTime/3600)), 1,1,1)
		-- GameTooltip:AddLine(xpGainedSession..L.TooltipSessionExpGained, 1,1,1)
		-- GameTooltip:AddLine(string.format(L.TooltipSessionLevelsGained, ceil(UnitLevel("player") + cur/max - startlevel)), 1,1,1)
		
		-- GameTooltip:Show()
	end)
	
	
	addon:Show();
end

function addon:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanGM_DB then XanGM_DB = {} end
	
	local opt = XanGM_DB[frame] or nil

	if not opt then
		XanGM_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanGM_DB[frame]
		return
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanGM_DB then XanGM_DB = {} end

	local opt = XanGM_DB[frame] or nil

	if not opt then
		XanGM_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanGM_DB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end

function addon:BackgroundToggle()
	if XanGM_DB.bgShown then
		addon:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5);
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end
end

------------------------------
--      Event Handlers      --
------------------------------

function addon:PLAYER_MONEY()
	if not addon.playerDB.lifetime and GetPlayerMoney() > 0 then
		addon.playerDB.lifetime = GetPlayerMoney()
	end
	
	if addon.playerDB.lifetime == GetPlayerMoney() then return end --nothing has changed
	
	
end

------------------------
--      Tooltip!      --
------------------------

function addon:GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

if IsLoggedIn() then addon:PLAYER_LOGIN() else addon:RegisterEvent("PLAYER_LOGIN") end
