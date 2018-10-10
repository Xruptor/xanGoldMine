
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
local playerSession = {}
local starttime
local auditorTag

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

----------------------
--      Enable      --
----------------------

local function GetPlayerMoney()
	return (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
end

local function ReturnCoinValue(money, separateThousands)
	if not money then return end
	
	local goldString, silverString, copperString
	
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(money, COPPER_PER_SILVER)
	
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		if (separateThousands) then
			goldString = FormatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL
		else
			goldString = gold..GOLD_AMOUNT_SYMBOL
		end
		goldString = gold..GOLD_AMOUNT_SYMBOL
		silverString = silver..SILVER_AMOUNT_SYMBOL
		copperString = copper..COPPER_AMOUNT_SYMBOL
	else
		if (separateThousands) then
			goldString = GOLD_AMOUNT_TEXTURE_STRING:format(FormatLargeNumber(gold), 0, 0)
		else
			goldString = GOLD_AMOUNT_TEXTURE:format(gold, 0, 0)
		end
		silverString = SILVER_AMOUNT_TEXTURE:format(silver, 0, 0)
		copperString = COPPER_AMOUNT_TEXTURE:format(copper, 0, 0)
	end
	
	return gold, silver, copper, goldString, silverString, copperString
end

local function DoQuestLogScan()
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

local function ChatMoneyScan(msg) 
	local GOLD_SCAN_AMOUNT = string.gsub(GOLD_AMOUNT, "%%d", "(%%d+)")
	local SILVER_SCAN_AMOUNT = string.gsub(SILVER_AMOUNT, "%%d", "(%%d+)")
	local COPPER_SCAN_AMOUNT = string.gsub(COPPER_AMOUNT, "%%d", "(%%d+)")
	local copper = string.match(msg, COPPER_SCAN_AMOUNT)
	local silver = string.match(msg, SILVER_SCAN_AMOUNT)
	local gold = string.match(msg, GOLD_SCAN_AMOUNT)
	local money = (gold or 0) * 10000 + (silver or 0) * 100 + (copper or 0)
	
	return gold, silver, copper, money
end

------------------------------
--      Event Handlers      --
------------------------------

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
	addon.player_DB = XanGM_DB[currentRealm][currentPlayer]
	
	if not addon.player_DB.lifetime then addon.player_DB.lifetime = {} end
	addon.player_LT = addon.player_DB.lifetime

	DoQuestLogScan()
	
	starttime = GetTime()
	
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("CHAT_MSG_MONEY")
	self:RegisterEvent("TAXIMAP_OPENED")
	
	--MERCHANT_SHOW
	
	SLASH_XANGOLDMINE1 = "/xgm";
	SlashCmdList["XANGOLDMINE"] = xanGoldMine_SlashCommand;
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xgm", ADDON_NAME, ver or "1.0"))
	
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function addon:PLAYER_MONEY(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

    local tmpMoney = GetPlayerMoney()
	
    if addon.player_DB.money then
        self.DiffMoney = tmpMoney - addon.player_DB.money
    else
        self.DiffMoney = 0
    end
	playerSession.lastMoneyDiff = self.DiffMoney
	
	--add to our current player money and calculate net profit
	addon.player_DB.money = tmpMoney
	playerSession.netProfit = playerSession.netProfit + self.DiffMoney
	
	--it's positive money so lets add it to our session and lifetime
	if self.DiffMoney > 0 then
		playerSession.money = (playerSession.money or 0) + self.DiffMoney
		addon.player_LT.money = (addon.player_LT.money or 0) + self.DiffMoney
		
		local gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.money, true)
		if gold and gold > 0 then
			--only show gold earned, the rest is pointless
			addon.btnText:SetText(goldString)
		end
	end

	if auditorTag then
		if UnitOnTaxi("player") and auditorTag == "taxi" then
			--diff comes in as negative so make it positive for storing
			playerSession.taxi = (playerSession.taxi or 0) + (self.DiffMoney * -1)
			addon.player_LT.taxi = (addon.player_LT.taxi or 0) + (self.DiffMoney * -1)
			auditorTag = nil
		end
	end
	
end

function addon:TAXIMAP_OPENED()
	auditorTag = "taxi"
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
			playerSession.quest = (playerSession.quest or 0) + questHistory[questID].money
			addon.player_LT.quest = (addon.player_LT.quest or 0) + questHistory[questID].money
		end
		questHistory[questID] = nil
	end
end

function addon:QUEST_TURNED_IN(event, questID, xpReward, moneyReward)
	if questHistory[questID] then
		questHistory[questID].gotReward = true
	end
	playerSession.quest = (playerSession.quest or 0) + moneyReward
	addon.player_LT.quest = (addon.player_LT.quest or 0) + moneyReward
end

function addon:CHAT_MSG_MONEY(event, msg)
	local gold, silver, copper, money = ChatMoneyScan(msg) 
	if money then
		playerSession.loot = (playerSession.loot or 0) + money
		addon.player_LT.loot = (addon.player_LT.loot or 0) + money
	end
end

----------------------
--      Utils      --
----------------------

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
	--t:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
	t:SetTexture("Interface\\Minimap\\Tracking\\Auctioneer")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetPoint("TOPLEFT",5,-6)

	local g = addon:CreateFontString("xanGoldMineText", "ARTWORK", "GameFontNormalSmall")
	g:SetJustifyH("LEFT")
	g:SetPoint("CENTER",8,0)
	g:SetText("?")
	addon.btnText = g

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
		
		GameTooltip:AddLine(L.TooltipSession, 129/255, 209/255, 23/255)
		GameTooltip:AddDoubleLine(L.TooltipTotalEarned, playerSession.money and GetMoneyString(playerSession.money, true) or L.Waiting, nil,nil,nil, 1,1,1)
		
		if playerSession.netProfit then
			local netProfit = playerSession.netProfit * -1 -- convert to positive number
			if playerSession.netProfit < 0 then
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, GetMoneyString(netProfit, true), nil,nil,nil, 1,0,0) --red
			else
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, GetMoneyString(netProfit, true), nil,nil,nil, 0,1,0) -- green
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipNetProfit, L.Waiting, nil,nil,nil, 1, 204/255, 0)
		end
		if playerSession.lastMoneyDiff then
			local lastDiff = playerSession.lastMoneyDiff * -1 -- convert to positive number
			if playerSession.lastMoneyDiff < 0 then
				GameTooltip:AddDoubleLine(L.TooltipLastTransaction, GetMoneyString(lastDiff, true), nil,nil,nil, 1,0,0) --red
			else
				GameTooltip:AddDoubleLine(L.TooltipLastTransaction, GetMoneyString(lastDiff, true), nil,nil,nil, 0,1,0) -- green
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipLastTransaction, L.Waiting, nil,nil,nil, 1, 204/255, 0)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L.TooltipQuest, playerSession.quest and GetMoneyString(playerSession.quest, true) or L.Waiting, nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTaxi, playerSession.taxi and GetMoneyString(playerSession.taxi, true) or L.Waiting, nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipLoot, playerSession.loot and GetMoneyString(playerSession.loot, true) or L.Waiting, nil,nil,nil, 1,1,1)
	
		if playerSession.money and playerSession.money > 0 then
			local sessionTime = GetTime() - starttime
			local goldPerSecond = ceil(playerSession.money / sessionTime)
			local goldPerMinute = ceil(goldPerSecond * 60)
			local goldPerHour = ceil(goldPerSecond * 3600)
			
			GameTooltip:AddDoubleLine(L.TooltipGoldPerSec, GetMoneyString(goldPerSecond, true), nil,nil,nil, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerMinute, GetMoneyString(goldPerMinute, true), nil,nil,nil, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerHour, GetMoneyString(goldPerHour, true), nil,nil,nil, 1,1,1)
		else
			GameTooltip:AddDoubleLine(L.TooltipGoldPerSec, L.Waiting, nil,nil,nil, 1, 204/255, 0)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerMinute, L.Waiting, nil,nil,nil, 1, 204/255, 0)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerHour, L.Waiting, nil,nil,nil, 1, 204/255, 0)
		end
	
		GameTooltip:AddLine(" ")
		--GameTooltip:AddLine(L.TooltipLifetime, 129/255, 209/255, 23/255)
		GameTooltip:AddLine(L.TooltipLifetime, 129/255, 209/255, 92/255)

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L.TooltipTotalEarned, addon.player_LT.money and GetMoneyString(addon.player_LT.money, true) or L.Waiting, nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipQuest, addon.player_LT.quest and GetMoneyString(addon.player_LT.quest, true) or L.Waiting, nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTaxi, addon.player_LT.taxi and GetMoneyString(addon.player_LT.taxi, true) or L.Waiting, nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipLoot, addon.player_LT.loot and GetMoneyString(addon.player_LT.loot, true) or L.Waiting, nil,nil,nil, 1,1,1)
		
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
