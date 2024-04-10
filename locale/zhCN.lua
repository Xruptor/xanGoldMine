local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L.SlashBG = "背景"
L.SlashBGOn = "xanGoldMine: 背景为 [|cFF99CC33显示|r]"
L.SlashBGOff = "xanGoldMine: 背景为 [|cFF99CC33隐藏|r]"
L.SlashBGInfo = "显示窗口背景"

L.SlashReset = "重置"
L.SlashResetInfo = "重置位置。"
L.SlashResetAlert = "xanGoldMine: 位置已重置！"

L.SlashResetGold = "重置金币"
L.SlashResetGoldInfo = "重置数据库金币数"
L.SlashResetGoldAlert = "xanGoldMine: 数据库金币数已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "xanGoldMine: 比例设置为 [|cFF20ff20%s|r]"
-- L.SlashScaleSetInvalid = "数值无效！数字必须是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
-- L.SlashScaleInfo = "设置xanGoldMine耐久度窗口的比例 (0.5 - 5)。"
L.SlashScaleText = "金币窗口比例"

L.SlashTotalEarned = "总计"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33总收益|r] 为 [|cFF99CC33显示|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33净利润|r] 为 [|cFF99CC33显示|r]"
L.SlashTotalEarnedInfo = "切换 [|cFF99CC33总收益|r] 而不是 [|cFF99CC33净利润|r] 作为主按钮。"
L.SlashTotalEarnedChkBtn = "显示 [|cFF99CC33总收益|r] 而不是 [|cFF99CC33净利润|r] 作为显示文本。"

L.SlashFontColor = "颜色"
L.SlashFontColorOn = "xanGoldMine: 鼠标提示颜色为 [|cFF99CC33黄色|r]"
L.SlashFontColorOff = "xanGoldMine: 鼠标提示颜色为 [|cFF99CC33白色|r]"
L.SlashFontColorInfo = "切换 [|cFF99CC33白色|r] 而不是 [|cFF99CC33黄色|r] 为鼠标提示颜色。"
L.SlashFontColorChkBtn = "显示 [|cFF99CC33黄色|r] 而不是 [|cFF99CC33白色|r] 为鼠标提示颜色。"

L.SlashAchLifetimeTotals = "成就统计"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: 成就统计帐号总数为 [|cFF99CC33开|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: 成就统计帐号总数为 [|cFF99CC33关|r]"
L.SlashAchLifetimeTotalsInfo = "切换使用角色成就统计为帐号总数 [|cFF99CC33开/关|r]。"
L.SlashAchLifetimeTotalsChkBtn = "使用成就 -> 统计 -> 角色 -> 财富 -> 总数。"

L.Waiting = "等待中..."

L.TooltipDragInfo = "[按住Shift-点击移动窗口。]"
L.TooltipTotalGold = "总金额:"
L.TooltipSession = "同步"
L.TooltipLifetime = "总计"
L.TooltipTotalEarned = "总收入:"
L.TooltipTotalSpent = "总支出:"
L.TooltipNetProfit = "净利润:"
L.TooltipDiff = "总差额:"
L.TooltipLastTransaction = "最后交易:"
L.TooltipQuest = "任务奖励:"
L.TooltipTaxi = "旅行花费:"
L.TooltipLoot = "拾取:"
L.TooltipRepairs = "修理:"
L.TooltipMerchant = "商人:"
L.TooltipGoldPerSec = "金币/秒:"
L.TooltipGoldPerMinute = "金币/分钟:"
L.TooltipGoldPerHour = "金币/小时:"
L.TooltipLastSession = "最后同步"
