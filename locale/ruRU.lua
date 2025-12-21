local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU")
if not L then return end
-- Translator ZamestoTV
L.SlashBG = "bg"
L.SlashBGOn = "xanGoldMine: Фон теперь [|cFF99CC33ПОКАЗАН|r]"
L.SlashBGOff = "xanGoldMine: Фон теперь [|cFF99CC33СКРЫТ|r]"
L.SlashBGInfo = "Показать фон окна."

L.SlashReset = "reset"
L.SlashResetInfo = "Сбросить позицию окна."
L.SlashResetAlert = "xanGoldMine: Позиция окна сброшена!"

L.SlashResetGold = "resetgold"
L.SlashResetGoldInfo = "Сбросить значения золота в базе данных."
L.SlashResetGoldAlert = "xanGoldMine: Значения золота в базе данных сброшены!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanGoldMine: масштаб установлен на [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Неверный масштаб! Число должно быть от [0.5 - 5]. (0.5, 1, 3, 4.6 и т.д.)"
L.SlashScaleInfo = "Установить масштаб окон лута LootRollMover (0.5 - 5)."
L.SlashScaleText = "Масштаб окна xanGoldMine"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Всего заработано|r] теперь [|cFF99CC33ПОКАЗАНО|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Чистая прибыль|r] теперь [|cFF99CC33ПОКАЗАНО|r]"
L.SlashTotalEarnedInfo = "Переключить между [|cFF99CC33Всего заработано|r] вместо [|cFF99CC33Чистая прибыль|r] в тексте кнопки."
L.SlashTotalEarnedChkBtn = "Показывать [|cFF99CC33Всего заработано|r] вместо [|cFF99CC33Чистая прибыль|r] в тексте кнопки."

L.SlashFontColor = "color"
L.SlashFontColorOn = "xanGoldMine: Цвет шрифта подсказки теперь [|cFF99CC33ЖЁЛТЫЙ|r]"
L.SlashFontColorOff = "xanGoldMine: Цвет шрифта подсказки теперь [|cFF99CC33БЕЛЫЙ|r]"
L.SlashFontColorInfo = "Переключить между [|cFF99CC33БЕЛЫМ|r] вместо [|cFF99CC33ЖЁЛТЫМ|r] цветом подсказки."
L.SlashFontColorChkBtn = "Показывать [|cFF99CC33ЖЁЛТЫЙ|r] вместо [|cFF99CC33БЕЛОГО|r] цвет подсказки."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Общие lifetime-суммы в статистике достижений теперь [|cFF99CC33ВКЛ|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Общие lifetime-суммы в статистике достижений теперь [|cFF99CC33ВЫКЛ|r]"
L.SlashAchLifetimeTotalsInfo = "Переключить использование lifetime-сумм из раздела Достижения → Статистика → Персонаж → Богатство [|cFF99CC33ВКЛ/ВЫКЛ|r]."
L.SlashAchLifetimeTotalsChkBtn = "Использовать Достижения → Статистика → Персонаж → Богатство → Общие суммы за всё время."

L.Waiting = "Ожидание..."

L.TooltipDragInfo = "[Зажмите Shift и перетащите, чтобы переместить окно.]"
L.TooltipTotalGold = "Всего золота:"
L.TooltipSession = "Сессия"
L.TooltipLifetime = "За всё время"
L.TooltipTotalEarned = "Всего заработано:"
L.TooltipTotalSpent = "Всего потрачено:"
L.TooltipNetProfit = "Чистая прибыль:"
L.TooltipDiff = "Общая разница:"
L.TooltipLastTransaction = "Последняя транзакция:"
L.TooltipQuest = "Награды за квесты:"
L.TooltipTaxi = "Оплата такси:"
L.TooltipLoot = "Добыча:"
L.TooltipRepairs = "Ремонт:"
L.TooltipMerchant = "Торговцы:"
L.TooltipGoldPerSec = "Золото/сек:"
L.TooltipGoldPerMinute = "Золото/мин:"
L.TooltipGoldPerHour = "Золото/час:"
L.TooltipLastSession = "Прошлая сессия"
