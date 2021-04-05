
local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local questHistory = {}
local playerSession = {}
local starttime
local auditorTag

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

local staticGMFWidth = 61

----------------------
--      Enable      --
----------------------

local CATEGORYID_WEALTH = 140
local STATID_GOLD_AQUIRED = 328
local STATID_QUEST_REWARDS = 326
local STATID_LOOTED = 333
local STATID_TRAVEL = 1146

--get this from the Achievement panel under Statistics
function GetStatisticByID(categoryID, statID)
	if not IsRetail then return nil end
	
	--for _, cID in pairs(GetStatisticsCategoryList()) do
	--	if cID and cID == categoryID then
			local Title, ParentCategoryId, Something = GetCategoryInfo(categoryID)
			local statisticCount = GetCategoryNumAchievements(categoryID)
			
			for i = 1, statisticCount do
				local idNum, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = GetAchievementInfo(categoryID, i)
				--Debug(categoryID, idNum, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText)
				if idNum == statID then
					return GetStatistic(idNum)
				end
			end
	--	end
	--end
	return nil
end

local function GetPlayerMoney()
	return (GetMoney() or 0) - GetCursorMoney() - GetPlayerTradeMoney()
end

local function StripMoneyTextureString(moneyString)
	if not moneyString then return nil end
	
	local gold
	local silver
	local copper
	local total = 0
	
	-- COPPER_AMOUNT = "%d Copper";
	-- COPPER_AMOUNT_SYMBOL = "c";
	-- COPPER_AMOUNT_TEXTURE = "%d\124TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:2:0\124t";

	-- GOLD_AMOUNT = "%d Gold";
	-- GOLD_AMOUNT_SYMBOL = "g";
	-- GOLD_AMOUNT_TEXTURE = "%d\124TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0\124t";

	-- SILVER_AMOUNT = "%d Silver";
	-- SILVER_AMOUNT_SYMBOL = "s";
	-- SILVER_AMOUNT_TEXTURE = "%d\124TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:2:0\124t";

	--grab each texture string and strip it only returning the number at the front of |TInterface\\  \124 = |
	for w in moneyString:gmatch("%S+") do
		if not gold and string.find(w, "UI-GoldIcon", 1, true) then
			gold = string.match(w,"%d+")
		elseif not silver and string.find(w, "UI-SilverIcon", 1, true) then
			silver = string.match(w,"%d+")
		elseif not copper and string.find(w, "UI-CopperIcon", 1, true) then
			copper = string.match(w,"%d+")
		end
	end
	
	if gold then
		total = total + (gold * 10000) --gold to copper
	end
	if silver then
		total = total + (silver * 100) --silver to copper
	end
	if copper then
		total = total + copper 
	end
	
	if gold or silver or copper then
		return tonumber(gold), tonumber(silver), tonumber(copper), tonumber(total)
	end

	return nil
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

	if IsRetail then
		for i=1, C_QuestLog.GetNumQuestLogEntries() do
			local questInfo = C_QuestLog.GetInfo(i)
			if not questInfo.isHeader then
				if questInfo.questID and not questHistory[questInfo.questID] then
					questHistory[questInfo.questID] = {
						money = GetQuestLogRewardMoney(questInfo.questID) or 0,
						gotReward = false,
						questID = questInfo.questID,
						title = questInfo.title
					}
				end
			end
		end
	else
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

local function updateRepairCost()
	if CanMerchantRepair() then
		local repairCost, canRepair = GetRepairAllCost()
		if canRepair and repairCost > 0 then
			return repairCost
		end
	end
	return nil
end

------------------------------
--      Event Handlers      --
------------------------------
function addon:CreatePlayerGoldDB(resetGold)
	
	local currentPlayer = UnitName("player")
	local currentRealm = select(2, UnitFullName("player")) --get shortend realm name with no spaces and dashes

	if resetGold then
		XanGM_DB[currentRealm][currentPlayer] = nil
	end

	XanGM_DB[currentRealm] = XanGM_DB[currentRealm] or {}
	XanGM_DB[currentRealm][currentPlayer] = XanGM_DB[currentRealm][currentPlayer] or {}
	self.player_DB = XanGM_DB[currentRealm][currentPlayer]
	if not self.player_DB.money then self.player_DB.money = GetPlayerMoney() end
	
	if not self.player_DB.lifetime then self.player_DB.lifetime = {} end
	self.player_LT = self.player_DB.lifetime
	if not self.player_LT.money then self.player_LT.money = GetPlayerMoney() end
	
	if not self.player_DB.lastSession then self.player_DB.lastSession = {} end
	self.player_LASS = self.player_DB.lastSession
	self.player_LASS.totalMoney = self.player_LASS.sessionMoney or 0
	self.player_LASS.totalSpent = self.player_LASS.sessionSpent or 0
	self.player_LASS.totalNetProfit = self.player_LASS.sessionNetProfit or 0
	
	self:UpdateUsingAchievementStats()
end

function addon:EnableAddon()

	if not XanGM_DB then XanGM_DB = {} end
	if XanGM_DB.bgShown == nil then XanGM_DB.bgShown = true end
	if XanGM_DB.scale == nil then XanGM_DB.scale = 1 end
	if XanGM_DB.showTotalEarned == nil then XanGM_DB.showTotalEarned = true end
	if XanGM_DB.fontColor == nil then XanGM_DB.fontColor = true end
	if XanGM_DB.useAchStatistics == nil then XanGM_DB.useAchStatistics = true end
	
	self:CreateGoldFrame()
	self:RestoreLayout(ADDON_NAME)
	
	self:CreatePlayerGoldDB()
	
	DoQuestLogScan()
	
	starttime = GetTime()

	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("CHAT_MSG_MONEY")
	self:RegisterEvent("TAXIMAP_CLOSED")
	
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")
	
	SLASH_XANGOLDMINE1 = "/xgm";
	SlashCmdList["XANGOLDMINE"] = xanGoldMine_SlashCommand;
	
	if self.configFrame then self.configFrame:EnableConfig() end
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xgm", ADDON_NAME, ver or "1.0"))
end

function addon:UpdateUsingAchievementStats(specificID)
	if not IsRetail then return false end
	if not XanGM_DB.useAchStatistics then return false end
	
	local statTotal, gold, silver, copper, totalNum
	local passChk = false
	
	if not specificID or specificID == "gold" then
		--total gold aquired
		statTotal = GetStatisticByID(CATEGORYID_WEALTH, STATID_GOLD_AQUIRED)
		if statTotal then
			gold, silver, copper, totalNum = StripMoneyTextureString(statTotal)
			if gold and totalNum and totalNum >= 0 and self.player_LT.money ~= totalNum then
				self.player_LT.money = totalNum
				passChk = true
			end
		end
	end

	if not specificID or specificID == "quest" then
		--total gold quests
		statTotal = GetStatisticByID(CATEGORYID_WEALTH, STATID_QUEST_REWARDS)
		if statTotal then
			gold, silver, copper, totalNum = StripMoneyTextureString(statTotal)
			if gold and totalNum and totalNum >= 0 and self.player_LT.quest ~= totalNum then
				self.player_LT.quest = totalNum
				passChk = true
			end
		end
	end

	if not specificID or specificID == "taxi" then	
		--total gold taxi
		statTotal = GetStatisticByID(CATEGORYID_WEALTH, STATID_TRAVEL)
		if statTotal then
			gold, silver, copper, totalNum = StripMoneyTextureString(statTotal)
			if gold and totalNum and totalNum >= 0 and self.player_LT.taxi ~= totalNum then
				self.player_LT.taxi = totalNum
				passChk = true
			end
		end
	end
		
	if not specificID or specificID == "loot" then
		--total gold loot
		statTotal = GetStatisticByID(CATEGORYID_WEALTH, STATID_LOOTED)
		if statTotal then
			gold, silver, copper, totalNum = StripMoneyTextureString(statTotal)
			if gold and totalNum and totalNum >= 0 and self.player_LT.loot ~= totalNum then
				self.player_LT.loot = totalNum
				passChk = true
			end
		end
	end

	return passChk
end

function addon:PLAYER_MONEY()

    local tmpMoney = GetPlayerMoney()
	local diffMoney = 0

	diffMoney = tmpMoney - (self.player_DB.money or 0)
	self.player_DB.money = tmpMoney
	
	if self.merchant_start then
		self.merchant_trackGold = (self.merchant_trackGold or 0) + diffMoney
	end

	playerSession.lastMoneyDiff = diffMoney
	playerSession.netProfit = (playerSession.netProfit or 0) + diffMoney
	self.player_LASS.sessionNetProfit = playerSession.netProfit or 0
	
	--force update of our achievement money tracker if it's enabled
	local doChk = self:UpdateUsingAchievementStats("gold")
	
	--it's positive money so lets add it to our session and lifetime
	if diffMoney > 0 then
		playerSession.money = (playerSession.money or 0) + diffMoney
		if not doChk then
			--only store these values IF we aren't using the achievement money tracker
			self.player_LT.money = (self.player_LT.money or 0) + diffMoney
		end
		self.player_LASS.sessionMoney = playerSession.money or 0
	else
		--add to our total spent.  Value will change depending if we are in net profit or loss
		playerSession.spent = (playerSession.spent or 0) + diffMoney
		self.player_LT.spent = (self.player_LT.spent or 0) + diffMoney
		self.player_LASS.sessionSpent = playerSession.spent or 0
	end

	addon:UpdateButtonText()

	--TAXI
	if auditorTag and auditorTag == "taxi" then
		
		local oldTaxi = self.player_LT.taxi or 0
		
		if self:UpdateUsingAchievementStats("taxi") then
			local currTaxi = (self.player_LT.taxi or 0) - oldTaxi --subtract old from new to get diff spent
			playerSession.taxi = (playerSession.taxi or 0) + currTaxi --now add it to our session total
		else
			--diff comes in as negative so make it positive for storing
			if diffMoney < 0 then diffMoney = diffMoney * -1 end
			playerSession.taxi = (playerSession.taxi or 0) + diffMoney
		end
		
		auditorTag = nil
		return
	end
end

----------------------
--      Taxi        --
----------------------

addon:SetScript("OnUpdate", function(self, elapsed)
	if not self.checkTaxi then
		if not self.OnUpdateCounter or self.OnUpdateCounter > 0 then self.OnUpdateCounter = 0 end
		return
	end 
	
	self.OnUpdateCounter = (self.OnUpdateCounter or 0) + elapsed
	if self.OnUpdateCounter < 2 then return end --two seconds should suffice
	
	self.OnUpdateCounter = 0

	if UnitOnTaxi("player") then
		if not auditorTag or auditorTag ~= "taxi" then
			auditorTag = "taxi"
			self:PLAYER_MONEY()
		end
	end
	
	--disable this we don't want it running constantly if it fails the condition check
	self.checkTaxi = false
end)

function addon:TAXIMAP_CLOSED()
	self.checkTaxi = true
end

----------------------
--      Quest       --
----------------------

function addon:QUEST_ACCEPTED(event, questLogIndex, questID)
	DoQuestLogScan()
end

function addon:QUEST_REMOVED(event, questID)
	if questHistory[questID] then
		if not questHistory[questID].gotReward then
			playerSession.quest = (playerSession.quest or 0) + questHistory[questID].money
			
			if not self:UpdateUsingAchievementStats("quest") then
				self.player_LT.quest = (self.player_LT.quest or 0) + questHistory[questID].money
			end
		end
		questHistory[questID] = nil
	end
end

function addon:QUEST_TURNED_IN(event, questID, xpReward, moneyReward)
	if questHistory[questID] then
		questHistory[questID].gotReward = true
	end
	playerSession.quest = (playerSession.quest or 0) + moneyReward
	
	if not self:UpdateUsingAchievementStats("quest") then
		self.player_LT.quest = (self.player_LT.quest or 0) + moneyReward
	end
end

function addon:CHAT_MSG_MONEY(event, msg)
	local gold, silver, copper, money = ChatMoneyScan(msg) 
	if money then
		playerSession.loot = (playerSession.loot or 0) + money
		
		if not self:UpdateUsingAchievementStats("loot") then
			self.player_LT.loot = (self.player_LT.loot or 0) + money
		end
	end
end

----------------------
--      Merchant    --
----------------------

hooksecurefunc("RepairAllItems", function(useGuildRepair, arg2)
	--we want to track OUR money not the guilds money for repairs
	if useGuildRepair then
		addon.usedGuildRepair = true
	end
end)

local function startMerchantTransactions()
	if addon.merchant_start then return end
	addon.merchant_start = true
	
	addon.merchant_repairCost = updateRepairCost()
	addon.merchant_playerGold = GetPlayerMoney()
	addon.merchant_trackGold = 0
end

local function endMerchantTransactions()
	if not addon.merchant_start then return end
	
	local repairDiff = 0

	--lets do the repairs first, make sure we didn't do a guild repair
	if not addon.usedGuildRepair then
		if addon.merchant_repairCost then
			--the stored repair cost and the current one has changed, the player has repaired something.
			repairDiff = (addon.merchant_repairCost or 0) - (updateRepairCost() or 0)
			if repairDiff < 0 then repairDiff = repairDiff * -1 end --make sure it's a positive number
			
			playerSession.repairs = (playerSession.repairs or 0) + repairDiff
			addon.player_LT.repairs = (addon.player_LT.repairs or 0) + repairDiff
		end
	end

	--get the player gold and subtract any money we spent on repairs to have a base to work with
	local newDiff = (addon.merchant_trackGold or 0) - (repairDiff or 0)

	--now lets store our merchant values
	playerSession.merchant = (playerSession.merchant or 0) + newDiff
	addon.player_LT.merchant = (addon.player_LT.merchant or 0) + newDiff

	addon.merchant_repairCost = nil
	addon.merchant_playerGold = nil
	addon.merchant_trackGold = 0
	addon.usedGuildRepair = nil
	addon.merchant_start = nil
end

--these merchant functions can be slow depending on other addons
function addon:MERCHANT_SHOW()
	startMerchantTransactions()
end

function addon:MERCHANT_CLOSED()
	endMerchantTransactions()
end

--these two merchant hooks are really catch alls if the registered event ones fail
MerchantFrame:HookScript("OnShow", function(self)
	startMerchantTransactions()
end)
MerchantFrame:HookScript("OnHide", function(self)
	endMerchantTransactions()
end)

----------------------
--      Utils      --
----------------------

--QuestMapQuestOptions_AbandonQuest
--https://www.townlong-yak.com/framexml/33062/StaticPopup.lua#2175
--https://www.townlong-yak.com/framexml/36230/QuestMapFrame.lua

if IsRetail then

	hooksecurefunc(C_QuestLog, "AbandonQuest", function()
		local questID
		local title = QuestUtils_GetQuestName(C_QuestLog.GetAbandonQuest())

		for k, v in pairs(questHistory) do
			if v.title and v.title == title then
				questID = k
				break
			end
		end
		if questID and questHistory[questID] then
			questHistory[questID] = nil
		end
	end)
	
else
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
		elseif c and c:lower() == L.SlashResetGold then
			addon:CreatePlayerGoldDB(true)
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashResetGoldAlert)
			return true
		elseif c and c:lower() == L.SlashAchLifetimeTotals then
			addon.aboutPanel.btnAchLifetimeTotals.func()
			return true
		elseif c and c:lower() == L.SlashTotalEarned then
			addon.aboutPanel.btnTotalEarned.func(true)
			return true
		elseif c and c:lower() == L.SlashFontColor then
			addon.aboutPanel.btnFontColor.func(true)
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
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashReset.." - "..L.SlashResetInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashBG.." - "..L.SlashBGInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashScale.." # - "..L.SlashScaleInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashTotalEarned.." - "..L.SlashTotalEarnedInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashFontColor.." - "..L.SlashFontColorInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashResetGold.." - "..L.SlashResetGoldInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashAchLifetimeTotals.." - "..L.SlashAchLifetimeTotalsInfo)
end

local function DoMoneyIcon(money)
	if not money or not tonumber(money) then return false end
	if money < 0 then money = money * -1 end
	return GetMoneyString(money, true)
end

function addon:CreateGoldFrame()

	addon:SetWidth(staticGMFWidth)
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
	if (g:GetStringWidth() + 40) > staticGMFWidth then
		addon:SetWidth(g:GetStringWidth() + 40)
	else
		addon:SetWidth(staticGMFWidth)
	end
	self.btnText = g

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
		
		local fontColor = {r=1,g=210/255,b=0}
		if not XanGM_DB.fontColor then fontColor = {r=1,g=1,b=1} end
		
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(self:GetTipAnchor(self))
		GameTooltip:ClearLines()

		GameTooltip:AddLine(ADDON_NAME)
		GameTooltip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		GameTooltip:AddLine(" ")
		
		GameTooltip:AddDoubleLine(L.TooltipTotalGold, self.player_DB.money and DoMoneyIcon(self.player_DB.money) or L.Waiting, 129/255, 209/255, 92/255, 1,1,1)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TooltipSession, 64/255, 224/255, 208/255)
		GameTooltip:AddDoubleLine(L.TooltipTotalEarned, playerSession.money and DoMoneyIcon(playerSession.money) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTotalSpent, playerSession.spent and DoMoneyIcon(playerSession.spent) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		
		if playerSession.netProfit then
			if playerSession.netProfit >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, DoMoneyIcon(playerSession.netProfit), fontColor.r,fontColor.g,fontColor.b, 0,1,0)
			else
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, DoMoneyIcon(playerSession.netProfit), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipNetProfit, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		if playerSession.lastMoneyDiff then
			if playerSession.lastMoneyDiff >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipLastTransaction, DoMoneyIcon(playerSession.lastMoneyDiff), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			else
				GameTooltip:AddDoubleLine(L.TooltipLastTransaction, DoMoneyIcon(playerSession.lastMoneyDiff), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipLastTransaction, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L.TooltipQuest, playerSession.quest and DoMoneyIcon(playerSession.quest) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTaxi, playerSession.taxi and DoMoneyIcon(playerSession.taxi) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipLoot, playerSession.loot and DoMoneyIcon(playerSession.loot) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipRepairs, playerSession.repairs and DoMoneyIcon(playerSession.repairs) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		
		if playerSession.merchant then
			if playerSession.merchant >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipMerchant, DoMoneyIcon(playerSession.merchant), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			else
				GameTooltip:AddDoubleLine(L.TooltipMerchant, DoMoneyIcon(playerSession.merchant), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipMerchant, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		

		if playerSession.money and playerSession.money >= 0 then
			local sessionTime = GetTime() - starttime
			local goldPerSecond = ceil(playerSession.money / sessionTime)
			local goldPerMinute = ceil(goldPerSecond * 60)
			local goldPerHour = ceil(goldPerSecond * 3600)
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L.TooltipGoldPerSec, DoMoneyIcon(goldPerSecond), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerMinute, DoMoneyIcon(goldPerMinute), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerHour, DoMoneyIcon(goldPerHour), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		else
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L.TooltipGoldPerSec, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerMinute, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			GameTooltip:AddDoubleLine(L.TooltipGoldPerHour, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TooltipLastSession, 64/255, 224/255, 208/255)
		
		GameTooltip:AddDoubleLine(L.TooltipTotalEarned, self.player_LASS.totalMoney and DoMoneyIcon(self.player_LASS.totalMoney) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTotalSpent, self.player_LASS.totalSpent and DoMoneyIcon(self.player_LASS.totalSpent) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		if self.player_LASS.totalNetProfit then
			if self.player_LASS.totalNetProfit >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, DoMoneyIcon(self.player_LASS.totalNetProfit), fontColor.r,fontColor.g,fontColor.b, 0,1,0)
			else
				GameTooltip:AddDoubleLine(L.TooltipNetProfit, DoMoneyIcon(self.player_LASS.totalNetProfit), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipNetProfit, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TooltipLifetime, 64/255, 224/255, 208/255)
		GameTooltip:AddDoubleLine(L.TooltipTotalEarned, self.player_LT.money and DoMoneyIcon(self.player_LT.money) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTotalSpent, self.player_LT.spent and DoMoneyIcon(self.player_LT.spent) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		if self.player_LT.money and self.player_LT.spent then
			local ltDiff = (self.player_LT.money or 0) - (self.player_LT.spent or 0)
			if ltDiff >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipDiff, DoMoneyIcon(ltDiff), fontColor.r,fontColor.g,fontColor.b, 0,1,0)
			else
				GameTooltip:AddDoubleLine(L.TooltipDiff, DoMoneyIcon(ltDiff), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipDiff, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L.TooltipQuest, self.player_LT.quest and DoMoneyIcon(self.player_LT.quest) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipTaxi, self.player_LT.taxi and DoMoneyIcon(self.player_LT.taxi) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipLoot, self.player_LT.loot and DoMoneyIcon(self.player_LT.loot) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		GameTooltip:AddDoubleLine(L.TooltipRepairs, self.player_LT.repairs and DoMoneyIcon(self.player_LT.repairs) or L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		
		if self.player_LT.merchant then
			if self.player_LT.merchant >= 0 then
				GameTooltip:AddDoubleLine(L.TooltipMerchant, DoMoneyIcon(self.player_LT.merchant), fontColor.r,fontColor.g,fontColor.b, 1,1,1)
			else
				GameTooltip:AddDoubleLine(L.TooltipMerchant, DoMoneyIcon(self.player_LT.merchant), fontColor.r,fontColor.g,fontColor.b, 1,0,0) --red
			end
		else
			GameTooltip:AddDoubleLine(L.TooltipMerchant, L.Waiting, fontColor.r,fontColor.g,fontColor.b, 1,1,1)
		end
		
		GameTooltip:Show()
	end)
	
	addon:Show()
end

function addon:UpdateButtonText()
	
	local gold, silver, copper, goldString, silverString, copperString
	
	if XanGM_DB.showTotalEarned and playerSession.money then
	
		gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.money, true)
		self.btnText:SetTextColor(1,210/255,0,1) --standard orange
		
	elseif not XanGM_DB.showTotalEarned and playerSession.netProfit then
	
		if playerSession.netProfit > 0 then
			gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.netProfit, true)
			self.btnText:SetTextColor(0,1,0,1) --green
		else
			gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.netProfit * -1, true)
			self.btnText:SetTextColor(1,0,0,1) --red
		end
		
	else
		self.btnText:SetText("?")
		self.btnText:SetTextColor(1,210/255,0,1) --standard orange
		addon:SetWidth(staticGMFWidth)
		return
	end

	if gold and gold > 0 then
		--only show gold as priority
		self.btnText:SetText(goldString)
	elseif silver and silver > 0 then
		--as a backup show silver
		self.btnText:SetText(silverString)
	elseif copper and copper > 0 then
		--last resort copper
		self.btnText:SetText(copperString)
	else
		self.btnText:SetText("?")
	end
	if (self.btnText:GetStringWidth() + 40) > staticGMFWidth then
		addon:SetWidth(self.btnText:GetStringWidth() + 40)
	else
		addon:SetWidth(staticGMFWidth)
	end
		
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
