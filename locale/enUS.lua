local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

L.SlashBG = "bg"
L.SlashBGOn = "xanGoldMine: Background is now [|cFF99CC33SHOWN|r]"
L.SlashBGOff = "xanGoldMine: Background is now [|cFF99CC33HIDDEN|r]"
L.SlashBGInfo = "Show the window background."

L.SlashReset = "reset"
L.SlashResetInfo = "Reset frame position."
L.SlashResetAlert = "xanGoldMine: Frame position has been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanGoldMine: scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "xanGoldMine: scale invalid or number cannot be greater than 2"
L.SlashScaleInfo = "Set the scale of the xanGoldMine frame (0-200)"
L.SlashScaleText = "xanGoldMine Frame Scale"

L.Waiting = "Waiting..."

L.TooltipDragInfo = "[Hold Shift and Drag to move window.]"
L.TooltipTotalGold = "Total Money:"
L.TooltipSession = "Session"
L.TooltipLifetime = "Lifetime"
L.TooltipTotalEarned = "Total Earned:"
L.TooltipTotalSpent = "Total Spent:"
L.TooltipNetProfit = "Net Profit:"
L.TooltipLastTransaction = "Last Transaction:"
L.TooltipQuest = "Quest Rewards:"
L.TooltipTaxi = "Taxi Fares:"
L.TooltipLoot = "Looted:"
L.TooltipRepairs = "Repairs:"
L.TooltipMerchant = "Merchant:"
L.TooltipGoldPerSec = "Gold/Sec:"
L.TooltipGoldPerMinute = "Gold/Minute:"
L.TooltipGoldPerHour = "Gold/Hour:"
