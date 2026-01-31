local ADDON_NAME, private = ...

local L = private:NewLocale("frFR")
if not L then return end

L.SlashBG = "fond"
L.SlashBGOn = "xanGoldMine : Fond maintenant [|cFF99CC33AFFICHE|r]"
L.SlashBGOff = "xanGoldMine : Fond maintenant [|cFF99CC33MASQUE|r]"
L.SlashBGInfo = "Afficher le fond de la fenetre."

L.SlashReset = "reinit"
L.SlashResetInfo = "Reinitialiser la position de la fenetre."
L.SlashResetAlert = "xanGoldMine : Position de la fenetre reinitialisee !"

L.SlashResetGold = "reinitgold"
L.SlashResetGoldInfo = "Reinitialiser les valeurs d'or de la base de donnees."
L.SlashResetGoldAlert = "xanGoldMine : Les valeurs d'or ont ete reinitialisees !"

L.SlashScale = "echelle"
L.SlashScaleSet = "xanGoldMine : l'echelle a ete definie sur [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Echelle invalide ! Le nombre doit etre entre [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Definit l'echelle de la fenetre xanGoldMine (0.5 - 5)."
L.SlashScaleText = "Echelle de la fenetre xanGoldMine"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine : [|cFF99CC33Total gagne|r] est maintenant [|cFF99CC33AFFICHE|r]"
L.SlashTotalEarnedOff = "xanGoldMine : [|cFF99CC33Profit net|r] est maintenant [|cFF99CC33AFFICHE|r]"
L.SlashTotalEarnedInfo = "Bascule entre [|cFF99CC33Total gagne|r] et [|cFF99CC33Profit net|r] comme texte du bouton."
L.SlashTotalEarnedChkBtn = "Afficher [|cFF99CC33Total gagne|r] au lieu de [|cFF99CC33Profit net|r] comme texte du bouton."

L.SlashFontColor = "couleur"
L.SlashFontColorOn = "xanGoldMine : Couleur de la police des infobulles maintenant [|cFF99CC33JAUNE|r]"
L.SlashFontColorOff = "xanGoldMine : Couleur de la police des infobulles maintenant [|cFF99CC33BLANC|r]"
L.SlashFontColorInfo = "Bascule la couleur des infobulles entre [|cFF99CC33BLANC|r] et [|cFF99CC33JAUNE|r]."
L.SlashFontColorChkBtn = "Afficher [|cFF99CC33JAUNE|r] au lieu de [|cFF99CC33BLANC|r] comme couleur d'infobulle."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine : Totaux a vie des statistiques maintenant [|cFF99CC33ON|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine : Totaux a vie des statistiques maintenant [|cFF99CC33OFF|r]"
L.SlashAchLifetimeTotalsInfo = "Basculer l'utilisation des totaux a vie des statistiques du personnage [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "Utiliser Hauts faits -> Statistiques -> Personnage -> Richesse -> Totaux a vie."

L.Waiting = "En attente..."

L.TooltipDragInfo = "[Maintenez Shift et faites glisser pour deplacer la fenetre.]"
L.TooltipTotalGold = "Argent total :"
L.TooltipSession = "Session"
L.TooltipLifetime = "A vie"
L.TooltipTotalEarned = "Total gagne :"
L.TooltipTotalSpent = "Total depense :"
L.TooltipNetProfit = "Profit net :"
L.TooltipDiff = "Diff totale :"
L.TooltipLastTransaction = "Derniere transaction :"
L.TooltipQuest = "Recompenses de quete :"
L.TooltipTaxi = "Voyages :"
L.TooltipLoot = "Butin :"
L.TooltipRepairs = "Reparations :"
L.TooltipMerchant = "Marchand :"
L.TooltipGoldPerSec = "Or/Sec :"
L.TooltipGoldPerMinute = "Or/Minute :"
L.TooltipGoldPerHour = "Or/Heure :"
L.TooltipLastSession = "Derniere session"
