local ADDON_NAME, private = ...

local L = private:NewLocale("itIT")
if not L then return end

L.SlashBG = "sfondo"
L.SlashBGOn = "xanGoldMine: Sfondo ora [|cFF99CC33MOSTRATO|r]"
L.SlashBGOff = "xanGoldMine: Sfondo ora [|cFF99CC33NASCOSTO|r]"
L.SlashBGInfo = "Mostra lo sfondo della finestra."

L.SlashReset = "reset"
L.SlashResetInfo = "Ripristina la posizione della finestra."
L.SlashResetAlert = "xanGoldMine: Posizione della finestra ripristinata!"

L.SlashResetGold = "resetoro"
L.SlashResetGoldInfo = "Ripristina i valori dell'oro nel database."
L.SlashResetGoldAlert = "xanGoldMine: Valori dell'oro ripristinati!"

L.SlashScale = "scala"
L.SlashScaleSet = "xanGoldMine: la scala e stata impostata a [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Scala non valida! Il numero deve essere tra [0.5 - 5]. (0.5, 1, 3, 4.6, ecc.)"
L.SlashScaleInfo = "Imposta la scala della finestra xanGoldMine (0.5 - 5)."
L.SlashScaleText = "Scala della finestra xanGoldMine"

L.SlashTotalEarned = "totale"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Totale guadagnato|r] ora [|cFF99CC33MOSTRATO|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Profitto netto|r] ora [|cFF99CC33MOSTRATO|r]"
L.SlashTotalEarnedInfo = "Alterna tra [|cFF99CC33Totale guadagnato|r] e [|cFF99CC33Profitto netto|r] come testo del pulsante."
L.SlashTotalEarnedChkBtn = "Mostra [|cFF99CC33Totale guadagnato|r] invece di [|cFF99CC33Profitto netto|r] come testo del pulsante."

L.SlashFontColor = "colore"
L.SlashFontColorOn = "xanGoldMine: Colore del testo del tooltip ora [|cFF99CC33GIALLO|r]"
L.SlashFontColorOff = "xanGoldMine: Colore del testo del tooltip ora [|cFF99CC33BIANCO|r]"
L.SlashFontColorInfo = "Alterna il colore del tooltip tra [|cFF99CC33BIANCO|r] e [|cFF99CC33GIALLO|r]."
L.SlashFontColorChkBtn = "Mostra [|cFF99CC33GIALLO|r] invece di [|cFF99CC33BIANCO|r] come colore del tooltip."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Totali a vita delle statistiche ora [|cFF99CC33ON|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Totali a vita delle statistiche ora [|cFF99CC33OFF|r]"
L.SlashAchLifetimeTotalsInfo = "Alterna l'uso dei totali a vita delle statistiche del personaggio [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "Usa Imprese -> Statistiche -> Personaggio -> Ricchezza -> Totali a vita."

L.Waiting = "In attesa..."

L.TooltipDragInfo = "[Tieni premuto Shift e trascina per spostare la finestra.]"
L.TooltipTotalGold = "Denaro totale:"
L.TooltipSession = "Sessione"
L.TooltipLifetime = "A vita"
L.TooltipTotalEarned = "Totale guadagnato:"
L.TooltipTotalSpent = "Totale speso:"
L.TooltipNetProfit = "Profitto netto:"
L.TooltipDiff = "Differenza totale:"
L.TooltipLastTransaction = "Ultima transazione:"
L.TooltipQuest = "Ricompense missioni:"
L.TooltipTaxi = "Viaggi:"
L.TooltipLoot = "Bottino:"
L.TooltipRepairs = "Riparazioni:"
L.TooltipMerchant = "Mercante:"
L.TooltipGoldPerSec = "Oro/Sec:"
L.TooltipGoldPerMinute = "Oro/Minuto:"
L.TooltipGoldPerHour = "Oro/Ora:"
L.TooltipLastSession = "Ultima sessione"
