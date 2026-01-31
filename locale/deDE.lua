local ADDON_NAME, private = ...

local L = private:NewLocale("deDE")
if not L then return end

L.SlashBG = "hintergrund"
L.SlashBGOn = "xanGoldMine: Hintergrund ist jetzt [|cFF99CC33ANGEZEIGT|r]"
L.SlashBGOff = "xanGoldMine: Hintergrund ist jetzt [|cFF99CC33VERSTECKT|r]"
L.SlashBGInfo = "Zeigt den Fensterhintergrund an."

L.SlashReset = "zuruecksetzen"
L.SlashResetInfo = "Fensterposition zuruecksetzen."
L.SlashResetAlert = "xanGoldMine: Fensterposition wurde zurueckgesetzt!"

L.SlashResetGold = "goldreset"
L.SlashResetGoldInfo = "Goldwerte in der Datenbank zuruecksetzen."
L.SlashResetGoldAlert = "xanGoldMine: Goldwerte in der Datenbank wurden zurueckgesetzt!"

L.SlashScale = "skalierung"
L.SlashScaleSet = "xanGoldMine: Skalierung wurde auf [|cFF20ff20%s|r] gesetzt"
L.SlashScaleSetInvalid = "Skalierung ungueltig! Zahl muss zwischen [0.5 - 5] liegen. (0.5, 1, 3, 4.6, usw.)"
L.SlashScaleInfo = "Skaliert das xanGoldMine-Fenster (0.5 - 5)."
L.SlashScaleText = "xanGoldMine-Fensterskalierung"

L.SlashTotalEarned = "gesamt"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Insgesamt verdient|r] ist jetzt [|cFF99CC33ANGEZEIGT|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Netto-Gewinn|r] ist jetzt [|cFF99CC33ANGEZEIGT|r]"
L.SlashTotalEarnedInfo = "Schaltet zwischen [|cFF99CC33Insgesamt verdient|r] und [|cFF99CC33Netto-Gewinn|r] als Buttontext um."
L.SlashTotalEarnedChkBtn = "Zeige [|cFF99CC33Insgesamt verdient|r] statt [|cFF99CC33Netto-Gewinn|r] als Buttontext."

L.SlashFontColor = "farbe"
L.SlashFontColorOn = "xanGoldMine: Tooltip-Schriftfarbe ist jetzt [|cFF99CC33GELB|r]"
L.SlashFontColorOff = "xanGoldMine: Tooltip-Schriftfarbe ist jetzt [|cFF99CC33WEISS|r]"
L.SlashFontColorInfo = "Schaltet Tooltipfarbe zwischen [|cFF99CC33WEISS|r] und [|cFF99CC33GELB|r] um."
L.SlashFontColorChkBtn = "Zeige [|cFF99CC33GELB|r] statt [|cFF99CC33WEISS|r] als Tooltipfarbe."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Lebenszeit-Statistiken sind jetzt [|cFF99CC33AN|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Lebenszeit-Statistiken sind jetzt [|cFF99CC33AUS|r]"
L.SlashAchLifetimeTotalsInfo = "Verwende Lebenszeit-Statistiken des Charakters [|cFF99CC33AN/AUS|r]."
L.SlashAchLifetimeTotalsChkBtn = "Verwende Erfolge -> Statistik -> Charakter -> Reichtum -> Lebenszeitwerte."

L.Waiting = "Warten..."

L.TooltipDragInfo = "[Umschalt halten und ziehen, um das Fenster zu bewegen.]"
L.TooltipTotalGold = "Gesamtgeld:"
L.TooltipSession = "Sitzung"
L.TooltipLifetime = "Lebenszeit"
L.TooltipTotalEarned = "Insgesamt verdient:"
L.TooltipTotalSpent = "Insgesamt ausgegeben:"
L.TooltipNetProfit = "Netto-Gewinn:"
L.TooltipDiff = "Gesamtdifferenz:"
L.TooltipLastTransaction = "Letzte Transaktion:"
L.TooltipQuest = "Questbelohnungen:"
L.TooltipTaxi = "Reisekosten:"
L.TooltipLoot = "Beute:"
L.TooltipRepairs = "Reparaturen:"
L.TooltipMerchant = "Haendler:"
L.TooltipGoldPerSec = "Gold/Sek:"
L.TooltipGoldPerMinute = "Gold/Minute:"
L.TooltipGoldPerHour = "Gold/Stunde:"
L.TooltipLastSession = "Letzte Sitzung"
