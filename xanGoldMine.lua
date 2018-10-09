
local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent)
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

addon:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

local questHistory = {}
local start, max, starttime, startlevel

local startMoney, startQuestMoney = 0, 0

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

----------------------
--      Enable      --
----------------------

local function GetPlayerMoney()
	return (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
end

function addon:ReturnCoinValue(money)
	if not money then return end
	
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(money, COPPER_PER_SILVER)
	
	return gold, silver, copper
end

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
	
	addon:DoQuestLogScan()
	
	--addon:PLAYER_MONEY()
	
	-- function GoldCounter:GetTotalGoldForDisplay()
	  -- return GoldCounter:comma_value(floor(GoldCounter.totalCopper / 100 / 100))
	-- end

	
	--start, max, starttime = UnitXP("player"), UnitXPMax("player"), GetTime()
	--startlevel = UnitLevel("player") + start/max
	
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_TURNED_IN")

	SLASH_XANGOLDMINE1 = "/xgm";
	SlashCmdList["XANGOLDMINE"] = xanGoldMine_SlashCommand;
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xgm", ADDON_NAME, ver or "1.0"))
	
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function addon:DoQuestLogScan()
	for i=1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
		if not isHeader then
			if questID and not questHistory[questID] then
				questHistory[questID] = {
					money = GetQuestLogRewardMoney(questID) or 0,
					gotReward = false,
					questID = questID,
					title = title
				}
			end
		end
	end
end

function addon:QUEST_ACCEPTED(event, questLogIndex, questID)

	if questID and not questHistory[questID] then
	
		questHistory[questID] = {
			money = GetQuestLogRewardMoney(questID) or 0,
			gotReward = false,
			questID = questID
		}
		
		--lets grab the title
		local title = GetQuestLogTitle(questLogIndex)

		if title then
			questHistory[questID].title = title
		else
			for i=1, GetNumQuestLogEntries() do
				local xTitle, _, _, _, _, _, _, xQuestID = GetQuestLogTitle(i)
				if xQuestID and xQuestID == questID then
					questHistory[questID].title = xTitle
					return
				end
			end
		end
		
	end

end

function addon:QUEST_REMOVED(event, questID)
	if questHistory[questID] then
		if not questHistory[questID].gotReward then
			startQuestMoney = startQuestMoney + questHistory[questID].money
		end
		questHistory[questID] = nil
	end
end

function addon:QUEST_TURNED_IN(event, questID, xpReward, moneyReward)

	if questHistory[questID] then
		questHistory[questID].gotReward = true
	end
	
	startQuestMoney = startQuestMoney + moneyReward
end

hooksecurefunc("AbandonQuest", function()
	local questID
	
	for k, v in pairs(questHistory) do
		if v.title and v.title == GetAbandonQuestName() then
			questID = k
			break
		end
	end
	
	if questID and questHistory[questID] then
		questHistory[questID] = nil
	end
end)
	
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
	t:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
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
	
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(self:GetTipAnchor(self))
		GameTooltip:ClearLines()

		GameTooltip:AddLine(ADDON_NAME)
		GameTooltip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		GameTooltip:AddLine(" ")
		
		GameTooltip:AddDoubleLine("QuestMoney", GetMoneyString(startQuestMoney), nil,nil,nil, 1,1,1)

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
		
		GameTooltip:Show()
	end)
	
	addon:Show()
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

local function FormatMoney(money)
    local ret = ""
    local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
    local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
    local copper = mod(money, COPPER_PER_SILVER);
    if gold > 0 then
        ret = gold .. " gold "
    end
    if silver > 0 or gold > 0 then
        ret = ret .. silver .. " silver "
    end
    ret = ret .. copper .. " copper"
    return ret
end

function addon:PLAYER_MONEY(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

    local tmpMoney = GetMoney()
    if self.CurrentMoney then
        self.DiffMoney = tmpMoney - self.CurrentMoney
    else
        self.DiffMoney = 0
    end
    self.CurrentMoney = tmpMoney
    if self.DiffMoney > 0 then
        Debug("You gained" .. FormatMoney(self.DiffMoney) .. ".")
    elseif self.DiffMoney < 0 then
        Debug("You lost" .. FormatMoney(self.DiffMoney * -1) .. ".")
    end
	
	
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
