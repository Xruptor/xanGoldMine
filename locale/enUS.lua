local ADDON_NAME, private = ...

local L = private:NewLocale("enUS", true)
if not L then return end

L.SlashBG = "bg"
L.SlashBGOn = "xanGoldMine: Background is now [|cFF99CC33SHOWN|r]"
L.SlashBGOff = "xanGoldMine: Background is now [|cFF99CC33HIDDEN|r]"
L.SlashBGInfo = "Show the window background."

L.SlashReset = "reset"
L.SlashResetInfo = "Reset frame position."
L.SlashResetAlert = "xanGoldMine: Frame position has been reset!"

L.SlashResetGold = "resetgold"
L.SlashResetGoldInfo = "Reset database Gold values."
L.SlashResetGoldAlert = "xanGoldMine: Database gold values have been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanGoldMine: scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Scale invalid! Number must be from [0.5 - 5].  (0.5, 1, 3, 4.6, etc..)"
L.SlashScaleInfo = "Set the scale of the LootRollMover loot frames (0.5 - 5)."
L.SlashScaleText = "xanGoldMine Frame Scale"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Total Earned|r] is now [|cFF99CC33SHOWN|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Net Profit|r] is now [|cFF99CC33SHOWN|r]"
L.SlashTotalEarnedInfo = "Toggle between [|cFF99CC33Total Earned|r] instead of [|cFF99CC33Net Profit|r] as button text."
L.SlashTotalEarnedChkBtn = "Show [|cFF99CC33Total Earned|r] instead of [|cFF99CC33Net Profit|r] as button text."

L.SlashFontColor = "color"
L.SlashFontColorOn = "xanGoldMine: Tooltip font color is now [|cFF99CC33YELLOW|r]"
L.SlashFontColorOff = "xanGoldMine: Tooltip font color is now [|cFF99CC33WHITE|r]"
L.SlashFontColorInfo = "Toggle between [|cFF99CC33WHITE|r] instead of [|cFF99CC33YELLOW|r] tooltip color."
L.SlashFontColorChkBtn = "Show [|cFF99CC33YELLOW|r] instead of [|cFF99CC33WHITE|r] tooltip color."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Achievements Statistics Lifetime Totals is now [|cFF99CC33ON|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Achievements Statistics Lifetime Totals is now [|cFF99CC33OFF|r]"
L.SlashAchLifetimeTotalsInfo = "Toggle using character Achievements Statistics Lifetime Totals [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "Use Achievements -> Statistics -> Character -> Wealth -> Lifetime totals."

L.Waiting = "Waiting..."

L.TooltipDragInfo = "[Hold Shift and Drag to move window.]"
L.TooltipTotalGold = "Total Money:"
L.TooltipSession = "Session"
L.TooltipLifetime = "Lifetime"
L.TooltipTotalEarned = "Total Earned:"
L.TooltipTotalSpent = "Total Spent:"
L.TooltipNetProfit = "Net Profit:"
L.TooltipDiff = "Total Diff:"
L.TooltipLastTransaction = "Last Transaction:"
L.TooltipQuest = "Quest Rewards:"
L.TooltipTaxi = "Taxi Fares:"
L.TooltipLoot = "Looted:"
L.TooltipRepairs = "Repairs:"
L.TooltipMerchant = "Merchant:"
L.TooltipGoldPerSec = "Gold/Sec:"
L.TooltipGoldPerMinute = "Gold/Minute:"
L.TooltipGoldPerHour = "Gold/Hour:"
L.TooltipLastSession = "Last Session"
