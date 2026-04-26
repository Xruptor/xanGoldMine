
local ADDON_NAME, private = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
local addon = _G[ADDON_NAME]

addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata

local function ClampScale(value)
	value = tonumber(value) or 1
	if value < 0.5 then return 0.5 end
	if value > 5 then return 5 end
	return value
end

addon.ClampScale = ClampScale

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if (...) == ADDON_NAME then
			self:UnregisterEvent("ADDON_LOADED")
			self:RegisterEvent("PLAYER_LOGIN")
		end
	elseif event == "PLAYER_LOGIN" then
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
	elseif self[event] then
		return self[event](self, event, ...)
	end
end)

local questHistory = {}
local playerSession = {}
local starttime
local lastQuestScan = 0
local lastAchUpdate = 0
local ACH_UPDATE_INTERVAL = 2
local QUEST_SCAN_INTERVAL = 2
local statCache = {}

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD   = 100
local COPPER_PER_GOLD   = COPPER_PER_SILVER * SILVER_PER_GOLD

local staticGMFWidth = 61

local xanGoldMineTooltip = CreateFrame("GameTooltip", "xanGoldMineTooltip", UIParent, "GameTooltipTemplate")
local tooltipColorYellow = { r = 1, g = 210/255, b = 0 }
local tooltipColorWhite  = { r = 1, g = 1, b = 1 }

local coinCache = {}

local ADDON_BACKDROP = {
	bgFile   = "Interface\\TutorialFrame\\TutorialFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

----------------------
--      Enable      --
----------------------

local CATEGORYID_WEALTH    = 140
local STATID_GOLD_AQUIRED  = 328
local STATID_QUEST_REWARDS = 326
local STATID_LOOTED        = 333
local STATID_TRAVEL        = 1146

local STAT_DEFS = {
	{ key = "gold",  statID = STATID_GOLD_AQUIRED,  ltKey = "money" },
	{ key = "quest", statID = STATID_QUEST_REWARDS, ltKey = "quest" },
	{ key = "taxi",  statID = STATID_TRAVEL,        ltKey = "taxi"  },
	{ key = "loot",  statID = STATID_LOOTED,        ltKey = "loot"  },
}

local function GetStatisticByID(categoryID, statID)
	if not CanShowAchievementUI or not CanShowAchievementUI() then return nil end
	if not GetCategoryNumAchievements or not GetAchievementInfo or not GetStatistic then return nil end
	for i = 1, GetCategoryNumAchievements(categoryID) do
		local idNum = GetAchievementInfo(categoryID, i)
		if idNum == statID then
			return GetStatistic(idNum)
		end
	end
	return nil
end

local function GetPlayerMoney()
	return (GetMoney() or 0) - (GetCursorMoney() or 0) - (GetPlayerTradeMoney() or 0)
end

local function StripMoneyTextureString(moneyString)
	if not moneyString then return nil end
	local gold, silver, copper
	local total = 0
	for w in moneyString:gmatch("%S+") do
		if not gold   and w:find("UI-GoldIcon",   1, true) then gold   = w:match("%d+")
		elseif not silver and w:find("UI-SilverIcon", 1, true) then silver = w:match("%d+")
		elseif not copper and w:find("UI-CopperIcon", 1, true) then copper = w:match("%d+")
		end
	end
	if gold   then total = total + gold   * COPPER_PER_GOLD   end
	if silver then total = total + silver * COPPER_PER_SILVER end
	if copper then total = total + copper end
	if gold or silver or copper then
		return tonumber(gold), tonumber(silver), tonumber(copper), tonumber(total)
	end
	return nil
end

local function ReturnCoinValue(money, separateThousands)
	if not money then return end
	if coinCache.money == money and coinCache.separateThousands == separateThousands then
		return coinCache.gold, coinCache.silver, coinCache.copper,
		       coinCache.goldString, coinCache.silverString, coinCache.copperString
	end

	local gold   = floor(money / COPPER_PER_GOLD)
	local silver = floor((money - gold * COPPER_PER_GOLD) / COPPER_PER_SILVER)
	local copper = mod(money, COPPER_PER_SILVER)

	local goldString, silverString, copperString
	if ENABLE_COLORBLIND_MODE == "1" then
		goldString   = (separateThousands and FormatLargeNumber(gold) or gold) .. GOLD_AMOUNT_SYMBOL
		silverString = silver .. SILVER_AMOUNT_SYMBOL
		copperString = copper .. COPPER_AMOUNT_SYMBOL
	else
		goldString   = separateThousands and GOLD_AMOUNT_TEXTURE_STRING:format(FormatLargeNumber(gold), 0, 0)
		              or GOLD_AMOUNT_TEXTURE:format(gold, 0, 0)
		silverString = SILVER_AMOUNT_TEXTURE:format(silver, 0, 0)
		copperString = COPPER_AMOUNT_TEXTURE:format(copper, 0, 0)
	end

	coinCache.money            = money
	coinCache.separateThousands = separateThousands
	coinCache.gold             = gold
	coinCache.silver           = silver
	coinCache.copper           = copper
	coinCache.goldString       = goldString
	coinCache.silverString     = silverString
	coinCache.copperString     = copperString

	return gold, silver, copper, goldString, silverString, copperString
end

local function DoQuestLogScan(force)
	local now = GetTime()
	if not force and (now - lastQuestScan) < QUEST_SCAN_INTERVAL then return end
	lastQuestScan = now

	if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
		for i = 1, C_QuestLog.GetNumQuestLogEntries() do
			local questInfo = C_QuestLog.GetInfo(i)
			if questInfo and not questInfo.isHeader then
				local qID = questInfo.questID
				if qID and not questHistory[qID] then
					questHistory[qID] = {
						money     = GetQuestLogRewardMoney(qID) or 0,
						gotReward = false,
						questID   = qID,
						title     = questInfo.title,
					}
				end
			end
		end
	else
		for i = 1, GetNumQuestLogEntries() do
			local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
			if not isHeader and questID and not questHistory[questID] then
				questHistory[questID] = {
					money     = GetQuestLogRewardMoney(questID) or 0,
					gotReward = false,
					questID   = questID,
					title     = title,
				}
			end
		end
	end
end

local function ParseStatTotal(statID, statTotal)
	if not statTotal then return nil end
	local cache = statCache[statID]
	if cache and cache.raw == statTotal then return cache.total end
	local gold, silver, copper, totalNum = StripMoneyTextureString(statTotal)
	if gold and totalNum and totalNum >= 0 then
		statCache[statID] = { raw = statTotal, total = totalNum }
		return totalNum
	end
	return nil
end

local GOLD_SCAN_PATTERN, SILVER_SCAN_PATTERN, COPPER_SCAN_PATTERN
local function ChatMoneyScan(msg)
	if not GOLD_SCAN_PATTERN then
		GOLD_SCAN_PATTERN   = GOLD_AMOUNT:gsub("%%d", "(%%d+)")
		SILVER_SCAN_PATTERN = SILVER_AMOUNT:gsub("%%d", "(%%d+)")
		COPPER_SCAN_PATTERN = COPPER_AMOUNT:gsub("%%d", "(%%d+)")
	end
	local gold   = msg:match(GOLD_SCAN_PATTERN)
	local silver = msg:match(SILVER_SCAN_PATTERN)
	local copper = msg:match(COPPER_SCAN_PATTERN)
	local money  = (gold or 0) * COPPER_PER_GOLD + (silver or 0) * COPPER_PER_SILVER + (copper or 0)
	return gold, silver, copper, money
end

local function updateRepairCost()
	if CanMerchantRepair() then
		local repairCost, canRepair = GetRepairAllCost()
		if canRepair and repairCost > 0 then return repairCost end
	end
	return nil
end

------------------------------
--      Event Handlers      --
------------------------------

function addon:CreatePlayerGoldDB(resetGold)
	local currentPlayer = UnitName("player")
	local currentRealm  = select(2, UnitFullName("player"))
	if not currentRealm or currentRealm == "" then
		currentRealm = GetRealmName() or "UNKNOWN"
	end

	XanGM_DB[currentRealm] = XanGM_DB[currentRealm] or {}

	if resetGold then
		XanGM_DB[currentRealm][currentPlayer] = nil
	end
	XanGM_DB[currentRealm][currentPlayer] = XanGM_DB[currentRealm][currentPlayer] or {}
	self.player_DB = XanGM_DB[currentRealm][currentPlayer]
	if not self.player_DB.money then self.player_DB.money = GetPlayerMoney() end

	if not self.player_DB.lifetime then self.player_DB.lifetime = {} end
	self.player_LT = self.player_DB.lifetime
	if not self.player_LT.money then self.player_LT.money = GetPlayerMoney() end

	if not self.player_DB.lastSession then self.player_DB.lastSession = {} end
	self.player_LASS = self.player_DB.lastSession
	self.player_LASS.totalMoney     = self.player_LASS.sessionMoney     or 0
	self.player_LASS.totalSpent     = self.player_LASS.sessionSpent     or 0
	self.player_LASS.totalNetProfit = self.player_LASS.sessionNetProfit or 0

	self:UpdateUsingAchievementStats()
	addon.tooltipDirty = true
end

function addon:EnableAddon()
	if not XanGM_DB then XanGM_DB = {} end
	if XanGM_DB.bgShown         == nil then XanGM_DB.bgShown         = true end
	if XanGM_DB.scale            == nil then XanGM_DB.scale           = 1    end
	if XanGM_DB.showTotalEarned  == nil then XanGM_DB.showTotalEarned = true end
	if XanGM_DB.fontColor        == nil then XanGM_DB.fontColor       = true end
	if XanGM_DB.useAchStatistics == nil then XanGM_DB.useAchStatistics = true end

	self:CreateGoldFrame()
	self:RestoreLayout(ADDON_NAME)
	self:CreatePlayerGoldDB()

	DoQuestLogScan(true)
	starttime = GetTime()

	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("CHAT_MSG_MONEY")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")

	SLASH_XANGOLDMINE1 = "/xgm"
	SlashCmdList["XANGOLDMINE"] = xanGoldMine_SlashCommand

	if self.configFrame then self.configFrame:EnableConfig() end

	local ver = (GetMetadata and GetMetadata(ADDON_NAME, "Version")) or "1.0"
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xgm", ADDON_NAME, ver))
end

function addon:UpdateUsingAchievementStats(specificID)
	if not CanShowAchievementUI() then return false end
	if not XanGM_DB.useAchStatistics then return false end

	local now = GetTime()
	local minInterval = specificID and 0.5 or ACH_UPDATE_INTERVAL
	if (now - lastAchUpdate) < minInterval then return false end
	lastAchUpdate = now

	local passChk = false
	for _, def in ipairs(STAT_DEFS) do
		if not specificID or specificID == def.key then
			local statTotal = GetStatisticByID(CATEGORYID_WEALTH, def.statID)
			local totalNum  = ParseStatTotal(def.statID, statTotal)
			if totalNum and self.player_LT[def.ltKey] ~= totalNum then
				self.player_LT[def.ltKey] = totalNum
				passChk = true
			end
		end
	end

	if passChk then addon.tooltipDirty = true end
	return passChk
end

function addon:PLAYER_MONEY()
	local tmpMoney  = GetPlayerMoney()
	local diffMoney = tmpMoney - (self.player_DB.money or 0)
	self.player_DB.money = tmpMoney

	if self.merchant_start then
		self.merchant_trackGold = (self.merchant_trackGold or 0) + diffMoney
	end

	playerSession.lastMoneyDiff = diffMoney
	playerSession.netProfit = (playerSession.netProfit or 0) + diffMoney
	self.player_LASS.sessionNetProfit = playerSession.netProfit

	local doChk = self:UpdateUsingAchievementStats("gold")

	if diffMoney > 0 then
		playerSession.money = (playerSession.money or 0) + diffMoney
		if not doChk then
			self.player_LT.money = (self.player_LT.money or 0) + diffMoney
		end
		self.player_LASS.sessionMoney = playerSession.money
	else
		playerSession.spent  = (playerSession.spent  or 0) + diffMoney
		self.player_LT.spent = (self.player_LT.spent or 0) + diffMoney
		self.player_LASS.sessionSpent = playerSession.spent
	end

	addon:UpdateButtonText()
	addon.tooltipDirty = true

	if self.checkTaxi and UnitOnTaxi("player") then
		local oldTaxi = self.player_LT.taxi or 0
		if self:UpdateUsingAchievementStats("taxi") then
			local currTaxi = (self.player_LT.taxi or 0) - oldTaxi
			playerSession.taxi = (playerSession.taxi or 0) + currTaxi
		else
			local absDiff = math.abs(diffMoney)
			playerSession.taxi    = (playerSession.taxi    or 0) + absDiff
			self.player_LT.taxi   = (self.player_LT.taxi   or 0) + absDiff
		end
		self.checkTaxi = false
	end
end

----------------------
--      Taxi        --
----------------------

function addon:PLAYER_CONTROL_LOST()
	self.checkTaxi = true
end

----------------------
--      Quest       --
----------------------

function addon:QUEST_ACCEPTED(event, questLogIndex, questID)
	DoQuestLogScan()
end

function addon:QUEST_REMOVED(event, questID)
	if not questID or not questHistory[questID] then return end
	questHistory[questID] = nil
end

function addon:QUEST_TURNED_IN(event, questID, xpReward, moneyReward)
	if not questID or not questHistory[questID] then return end
	if questHistory[questID].gotReward then return end
	questHistory[questID].gotReward = true
	playerSession.quest = (playerSession.quest or 0) + moneyReward
	if not self:UpdateUsingAchievementStats("quest") then
		self.player_LT.quest = (self.player_LT.quest or 0) + moneyReward
	end
	addon.tooltipDirty = true
end

function addon:CHAT_MSG_MONEY(event, msg)
	local gold, silver, copper, money = ChatMoneyScan(msg)
	if money then
		playerSession.loot = (playerSession.loot or 0) + money
		if not self:UpdateUsingAchievementStats("loot") then
			self.player_LT.loot = (self.player_LT.loot or 0) + money
		end
		addon.tooltipDirty = true
	end
end

----------------------
--      Merchant    --
----------------------

hooksecurefunc("RepairAllItems", function(useGuildRepair)
	if useGuildRepair then addon.usedGuildRepair = true end
end)

local function startMerchantTransactions()
	if addon.merchant_start then return end
	addon.merchant_start      = true
	addon.merchant_repairCost = updateRepairCost()
	addon.merchant_playerGold = GetPlayerMoney()
	addon.merchant_trackGold  = 0
end

local function endMerchantTransactions()
	if not addon.merchant_start then return end

	local repairDiff = 0
	if not addon.usedGuildRepair and addon.merchant_repairCost then
		repairDiff = math.abs(addon.merchant_repairCost - (updateRepairCost() or 0))
		playerSession.repairs     = (playerSession.repairs     or 0) + repairDiff
		addon.player_LT.repairs   = (addon.player_LT.repairs   or 0) + repairDiff
	end

	local newDiff = (addon.merchant_trackGold or 0) - repairDiff
	playerSession.merchant    = (playerSession.merchant    or 0) + newDiff
	addon.player_LT.merchant  = (addon.player_LT.merchant  or 0) + newDiff

	addon.merchant_repairCost = nil
	addon.merchant_playerGold = nil
	addon.merchant_trackGold  = 0
	addon.usedGuildRepair     = nil
	addon.merchant_start      = nil
	addon.tooltipDirty        = true
end

function addon:MERCHANT_SHOW()  startMerchantTransactions() end
function addon:MERCHANT_CLOSED() endMerchantTransactions()  end

if _G.MerchantFrame and _G.MerchantFrame.HookScript then
	_G.MerchantFrame:HookScript("OnShow", startMerchantTransactions)
	_G.MerchantFrame:HookScript("OnHide", endMerchantTransactions)
end

local function PrintSlashHelp()
	DEFAULT_CHAT_FRAME:AddMessage(ADDON_NAME, 64/255, 224/255, 208/255)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashReset.."        - "..L.SlashResetInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashBG.."           - "..L.SlashBGInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashScale.." #      - "..L.SlashScaleInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashTotalEarned.."  - "..L.SlashTotalEarnedInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashFontColor.."    - "..L.SlashFontColorInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashResetGold.."    - "..L.SlashResetGoldInfo)
	DEFAULT_CHAT_FRAME:AddMessage("/xgm "..L.SlashAchLifetimeTotals.." - "..L.SlashAchLifetimeTotalsInfo)
end

function xanGoldMine_SlashCommand(cmd)
	local subcmd, rest = cmd:match("^%s*(%S+)%s*(.-)%s*$")
	if not subcmd then PrintSlashHelp() return end

	subcmd = subcmd:lower()
	if subcmd == L.SlashBG then
		addon.aboutPanel.btnBG.func()
	elseif subcmd == L.SlashReset then
		addon.aboutPanel.btnReset.func()
	elseif subcmd == L.SlashResetGold then
		addon:CreatePlayerGoldDB(true)
		DEFAULT_CHAT_FRAME:AddMessage(L.SlashResetGoldAlert)
	elseif subcmd == L.SlashAchLifetimeTotals then
		addon.aboutPanel.btnAchLifetimeTotals.func()
	elseif subcmd == L.SlashTotalEarned then
		addon.aboutPanel.btnTotalEarned.func()
	elseif subcmd == L.SlashFontColor then
		addon.aboutPanel.btnFontColor.func()
	elseif subcmd == L.SlashScale then
		local scalenum = tonumber(rest)
		if scalenum and scalenum >= 0.5 and scalenum <= 5 then
			addon:SetAddonScale(scalenum)
		else
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashScaleSetInvalid)
		end
	else
		PrintSlashHelp()
	end
end

local function DoMoneyIcon(money)
	if not money or not tonumber(money) then return false end
	return GetMoneyString(math.abs(money), true)
end

------------------------
--   Tooltip Helpers  --
------------------------

local function TipMoney(label, value, fc)
	xanGoldMineTooltip:AddDoubleLine(label,
		value and DoMoneyIcon(value) or L.Waiting,
		fc.r, fc.g, fc.b, 1, 1, 1)
end

-- Green when >= 0, red when < 0
local function TipMoneyNet(label, value, fc)
	if not value then
		xanGoldMineTooltip:AddDoubleLine(label, L.Waiting,         fc.r, fc.g, fc.b, 1, 1, 1)
	elseif value >= 0 then
		xanGoldMineTooltip:AddDoubleLine(label, DoMoneyIcon(value), fc.r, fc.g, fc.b, 0, 1, 0)
	else
		xanGoldMineTooltip:AddDoubleLine(label, DoMoneyIcon(value), fc.r, fc.g, fc.b, 1, 0, 0)
	end
end

-- White when >= 0, red when < 0
local function TipMoneyTxn(label, value, fc)
	if not value then
		xanGoldMineTooltip:AddDoubleLine(label, L.Waiting,         fc.r, fc.g, fc.b, 1, 1, 1)
	elseif value >= 0 then
		xanGoldMineTooltip:AddDoubleLine(label, DoMoneyIcon(value), fc.r, fc.g, fc.b, 1, 1, 1)
	else
		xanGoldMineTooltip:AddDoubleLine(label, DoMoneyIcon(value), fc.r, fc.g, fc.b, 1, 0, 0)
	end
end

function addon:CreateGoldFrame()
	addon:SetWidth(staticGMFWidth)
	addon:SetHeight(27)
	addon:SetMovable(true)
	addon:SetClampedToScreen(true)
	addon:SetAddonScale(XanGM_DB.scale, true)

	if XanGM_DB.bgShown then
		addon:SetBackdrop(ADDON_BACKDROP)
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5)
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end

	addon:EnableMouse(true)

	local t = addon:CreateTexture("$parentIcon", "ARTWORK")
	t:SetTexture("Interface\\Minimap\\Tracking\\Auctioneer")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetPoint("TOPLEFT", 5, -6)

	local g = addon:CreateFontString("xanGoldMineText", "ARTWORK", "GameFontNormalSmall")
	g:SetJustifyH("LEFT")
	g:SetPoint("CENTER", 8, 0)
	g:SetText("?")
	addon:SetWidth(math.max(g:GetStringWidth() + 40, staticGMFWidth))
	self.btnText = g

	addon:SetScript("OnMouseDown", function()
		if IsShiftKeyDown() then
			self.isMoving = true
			self:StartMoving()
		end
	end)
	addon:SetScript("OnMouseUp", function()
		if self.isMoving then
			self.isMoving = nil
			self:StopMovingOrSizing()
			addon:SaveLayout(ADDON_NAME)
		end
	end)
	addon:SetScript("OnLeave", function()
		xanGoldMineTooltip:Hide()
	end)

	addon:SetScript("OnEnter", function()
		if xanGoldMineTooltip:IsShown() and not addon.tooltipDirty then return end

		local fc  = XanGM_DB.fontColor and tooltipColorYellow or tooltipColorWhite
		local tip = xanGoldMineTooltip

		tip:SetOwner(self, "ANCHOR_TOP")
		tip:SetPoint(self:GetTipAnchor(addon))
		tip:ClearLines()

		tip:AddLine(ADDON_NAME)
		tip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		tip:AddLine(" ")
		tip:AddDoubleLine(L.TooltipTotalGold,
			self.player_DB.money and DoMoneyIcon(self.player_DB.money) or L.Waiting,
			129/255, 209/255, 92/255, 1, 1, 1)

		-- Session
		tip:AddLine(" ")
		tip:AddLine(L.TooltipSession, 64/255, 224/255, 208/255)
		TipMoney   (L.TooltipTotalEarned,     playerSession.money,          fc)
		TipMoney   (L.TooltipTotalSpent,      playerSession.spent,          fc)
		TipMoneyNet(L.TooltipNetProfit,       playerSession.netProfit,      fc)
		TipMoneyTxn(L.TooltipLastTransaction, playerSession.lastMoneyDiff,  fc)
		tip:AddLine(" ")
		TipMoney   (L.TooltipQuest,   playerSession.quest,   fc)
		TipMoney   (L.TooltipTaxi,    playerSession.taxi,    fc)
		TipMoney   (L.TooltipLoot,    playerSession.loot,    fc)
		TipMoney   (L.TooltipRepairs, playerSession.repairs, fc)
		TipMoneyTxn(L.TooltipMerchant, playerSession.merchant, fc)

		-- Gold rates
		local sessionTime = GetTime() - starttime
		local gps = (playerSession.money and playerSession.money >= 0 and sessionTime > 0)
			and ceil(playerSession.money / sessionTime) or nil
		tip:AddLine(" ")
		TipMoney(L.TooltipGoldPerSec,    gps,                          fc)
		TipMoney(L.TooltipGoldPerMinute, gps and ceil(gps * 60),       fc)
		TipMoney(L.TooltipGoldPerHour,   gps and ceil(gps * 3600),     fc)

		-- Last session
		tip:AddLine(" ")
		tip:AddLine(L.TooltipLastSession, 64/255, 224/255, 208/255)
		TipMoney   (L.TooltipTotalEarned, self.player_LASS.totalMoney,      fc)
		TipMoney   (L.TooltipTotalSpent,  self.player_LASS.totalSpent,      fc)
		TipMoneyNet(L.TooltipNetProfit,   self.player_LASS.totalNetProfit,  fc)

		-- Lifetime
		tip:AddLine(" ")
		tip:AddLine(L.TooltipLifetime, 64/255, 224/255, 208/255)
		TipMoney(L.TooltipTotalEarned, self.player_LT.money, fc)
		TipMoney(L.TooltipTotalSpent,  self.player_LT.spent, fc)
		if self.player_LT.money and self.player_LT.spent then
			local ltDiff = math.abs(self.player_LT.money) - math.abs(self.player_LT.spent)
			if ltDiff >= self.player_LT.money then
				tip:AddDoubleLine(L.TooltipDiff, DoMoneyIcon(ltDiff), fc.r, fc.g, fc.b, 0, 1, 0)
			elseif ltDiff >= 0 then
				tip:AddDoubleLine(L.TooltipDiff, DoMoneyIcon(ltDiff), fc.r, fc.g, fc.b, 1, 1, 1)
			else
				tip:AddDoubleLine(L.TooltipDiff, DoMoneyIcon(ltDiff), fc.r, fc.g, fc.b, 1, 0, 0)
			end
		else
			tip:AddDoubleLine(L.TooltipDiff, L.Waiting, fc.r, fc.g, fc.b, 1, 1, 1)
		end
		tip:AddLine(" ")
		TipMoney   (L.TooltipQuest,   self.player_LT.quest,   fc)
		TipMoney   (L.TooltipTaxi,    self.player_LT.taxi,    fc)
		TipMoney   (L.TooltipLoot,    self.player_LT.loot,    fc)
		TipMoney   (L.TooltipRepairs, self.player_LT.repairs, fc)
		TipMoneyTxn(L.TooltipMerchant, self.player_LT.merchant, fc)

		tip:Show()
		addon.tooltipDirty = false
	end)

	addon:Show()
end

function addon:SetAddonScale(value, bypass)
	value = ClampScale(value)
	XanGM_DB.scale = value
	if not bypass then
		DEFAULT_CHAT_FRAME:AddMessage(string.format(L.SlashScaleSet, value))
	end
	addon:SetScale(XanGM_DB.scale)
	addon.tooltipDirty = true
end

function addon:UpdateButtonText()
	local gold, silver, copper, goldString, silverString, copperString

	if XanGM_DB.showTotalEarned and playerSession.money then
		gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.money, true)
		self.btnText:SetTextColor(1, 210/255, 0, 1)
	elseif not XanGM_DB.showTotalEarned and playerSession.netProfit then
		if playerSession.netProfit > 0 then
			gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(playerSession.netProfit, true)
			self.btnText:SetTextColor(0, 1, 0, 1)
		else
			gold, silver, copper, goldString, silverString, copperString = ReturnCoinValue(math.abs(playerSession.netProfit), true)
			self.btnText:SetTextColor(1, 0, 0, 1)
		end
	else
		self.btnText:SetText("?")
		self.btnText:SetTextColor(1, 210/255, 0, 1)
		addon:SetWidth(staticGMFWidth)
		return
	end

	if gold and gold > 0 then
		self.btnText:SetText(goldString)
	elseif silver and silver > 0 then
		self.btnText:SetText(silverString)
	elseif copper and copper > 0 then
		self.btnText:SetText(copperString)
	else
		self.btnText:SetText("?")
	end
	addon:SetWidth(math.max(self.btnText:GetStringWidth() + 40, staticGMFWidth))
end

local function ensureLayout(frameName)
	XanGM_DB[frameName] = XanGM_DB[frameName] or {
		point = "CENTER", relativePoint = "CENTER", xOfs = 0, yOfs = 0,
	}
	return XanGM_DB[frameName]
end

function addon:SaveLayout(frame)
	if type(frame) ~= "string" or not _G[frame] then return end
	if not XanGM_DB then XanGM_DB = {} end
	local opt = ensureLayout(frame)
	local point, _, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point         = point
	opt.relativePoint = relativePoint
	opt.xOfs          = xOfs
	opt.yOfs          = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" or not _G[frame] then return end
	if not XanGM_DB then XanGM_DB = {} end
	local opt = ensureLayout(frame)
	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end

function addon:BackgroundToggle()
	if XanGM_DB.bgShown then
		addon:SetBackdrop(ADDON_BACKDROP)
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5)
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end
end

------------------------
--      Tooltip!      --
------------------------

function addon:GetTipAnchor(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end
