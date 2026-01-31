local ADDON_NAME, private = ...

local L = private:NewLocale("zhTW")
if not L then return end

L.SlashBG = "背景"
L.SlashBGOn = "xanGoldMine: 背景為 [|cFF99CC33顯示|r]"
L.SlashBGOff = "xanGoldMine: 背景為 [|cFF99CC33隱藏|r]"
L.SlashBGInfo = "顯示視窗背景。"

L.SlashReset = "重置"
L.SlashResetInfo = "重置視窗位置。"
L.SlashResetAlert = "xanGoldMine: 視窗位置已重置！"

L.SlashResetGold = "重置金幣"
L.SlashResetGoldInfo = "重置資料庫金幣數值。"
L.SlashResetGoldAlert = "xanGoldMine: 資料庫金幣數值已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "xanGoldMine: 比例設置為 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "數值無效！數字必須是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "設定 xanGoldMine 視窗比例 (0.5 - 5)。"
L.SlashScaleText = "xanGoldMine 視窗比例"

L.SlashTotalEarned = "總計"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33總收益|r] 為 [|cFF99CC33顯示|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33淨利潤|r] 為 [|cFF99CC33顯示|r]"
L.SlashTotalEarnedInfo = "切換使用 [|cFF99CC33總收益|r] 或 [|cFF99CC33淨利潤|r] 作為按鈕文字。"
L.SlashTotalEarnedChkBtn = "顯示 [|cFF99CC33總收益|r] 而不是 [|cFF99CC33淨利潤|r] 作為按鈕文字。"

L.SlashFontColor = "顏色"
L.SlashFontColorOn = "xanGoldMine: 提示字體顏色為 [|cFF99CC33黃色|r]"
L.SlashFontColorOff = "xanGoldMine: 提示字體顏色為 [|cFF99CC33白色|r]"
L.SlashFontColorInfo = "切換提示顏色 [|cFF99CC33白色|r] 或 [|cFF99CC33黃色|r]。"
L.SlashFontColorChkBtn = "顯示 [|cFF99CC33黃色|r] 而不是 [|cFF99CC33白色|r] 的提示顏色。"

L.SlashAchLifetimeTotals = "成就統計"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: 成就統計終身總數為 [|cFF99CC33開|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: 成就統計終身總數為 [|cFF99CC33關|r]"
L.SlashAchLifetimeTotalsInfo = "切換使用成就統計終身總數 [|cFF99CC33開/關|r]。"
L.SlashAchLifetimeTotalsChkBtn = "使用 成就 -> 統計 -> 角色 -> 財富 -> 終身總數。"

L.Waiting = "等待中..."

L.TooltipDragInfo = "[按住 Shift 並拖曳以移動視窗。]"
L.TooltipTotalGold = "總金額:"
L.TooltipSession = "本次"
L.TooltipLifetime = "總計"
L.TooltipTotalEarned = "總收益:"
L.TooltipTotalSpent = "總支出:"
L.TooltipNetProfit = "淨利潤:"
L.TooltipDiff = "總差額:"
L.TooltipLastTransaction = "最後交易:"
L.TooltipQuest = "任務獎勵:"
L.TooltipTaxi = "旅途花費:"
L.TooltipLoot = "拾取:"
L.TooltipRepairs = "修理:"
L.TooltipMerchant = "商人:"
L.TooltipGoldPerSec = "金幣/秒:"
L.TooltipGoldPerMinute = "金幣/分鐘:"
L.TooltipGoldPerHour = "金幣/小時:"
L.TooltipLastSession = "上一回合"
