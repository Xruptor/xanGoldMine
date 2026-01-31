local ADDON_NAME, private = ...

local L = private:NewLocale("esMX")
if not L then return end

L.SlashBG = "fondo"
L.SlashBGOn = "xanGoldMine: El fondo ahora esta [|cFF99CC33MOSTRADO|r]"
L.SlashBGOff = "xanGoldMine: El fondo ahora esta [|cFF99CC33OCULTO|r]"
L.SlashBGInfo = "Mostrar el fondo de la ventana."

L.SlashReset = "reiniciar"
L.SlashResetInfo = "Restablecer la posicion del marco."
L.SlashResetAlert = "xanGoldMine: La posicion del marco ha sido restablecida!"

L.SlashResetGold = "reiniciargold"
L.SlashResetGoldInfo = "Restablecer los valores de oro en la base de datos."
L.SlashResetGoldAlert = "xanGoldMine: Los valores de oro se han restablecido!"

L.SlashScale = "escala"
L.SlashScaleSet = "xanGoldMine: la escala se ha establecido en [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Escala invalida! El numero debe ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Establece la escala del marco de xanGoldMine (0.5 - 5)."
L.SlashScaleText = "Escala del marco xanGoldMine"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Total ganado|r] ahora esta [|cFF99CC33MOSTRADO|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Ganancia neta|r] ahora esta [|cFF99CC33MOSTRADO|r]"
L.SlashTotalEarnedInfo = "Alterna entre [|cFF99CC33Total ganado|r] en lugar de [|cFF99CC33Ganancia neta|r] como texto del boton."
L.SlashTotalEarnedChkBtn = "Mostrar [|cFF99CC33Total ganado|r] en lugar de [|cFF99CC33Ganancia neta|r] como texto del boton."

L.SlashFontColor = "color"
L.SlashFontColorOn = "xanGoldMine: El color de la fuente del tooltip ahora es [|cFF99CC33AMARILLO|r]"
L.SlashFontColorOff = "xanGoldMine: El color de la fuente del tooltip ahora es [|cFF99CC33BLANCO|r]"
L.SlashFontColorInfo = "Alterna el color del tooltip entre [|cFF99CC33BLANCO|r] y [|cFF99CC33AMARILLO|r]."
L.SlashFontColorChkBtn = "Mostrar [|cFF99CC33AMARILLO|r] en lugar de [|cFF99CC33BLANCO|r] como color del tooltip."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Totales de por vida de estadisticas ahora [|cFF99CC33ACTIVADO|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Totales de por vida de estadisticas ahora [|cFF99CC33DESACTIVADO|r]"
L.SlashAchLifetimeTotalsInfo = "Alterna el uso de totales de por vida de estadisticas del personaje [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "Usar Logros -> Estadisticas -> Personaje -> Riqueza -> Totales de por vida."

L.Waiting = "Esperando..."

L.TooltipDragInfo = "[Mantenga Shift y arrastre para mover la ventana.]"
L.TooltipTotalGold = "Dinero total:"
L.TooltipSession = "Sesion"
L.TooltipLifetime = "De por vida"
L.TooltipTotalEarned = "Total ganado:"
L.TooltipTotalSpent = "Total gastado:"
L.TooltipNetProfit = "Ganancia neta:"
L.TooltipDiff = "Diferencia total:"
L.TooltipLastTransaction = "Ultima transaccion:"
L.TooltipQuest = "Recompensas de misiones:"
L.TooltipTaxi = "Viajes:"
L.TooltipLoot = "Botin:"
L.TooltipRepairs = "Reparaciones:"
L.TooltipMerchant = "Mercader:"
L.TooltipGoldPerSec = "Oro/Seg:"
L.TooltipGoldPerMinute = "Oro/Minuto:"
L.TooltipGoldPerHour = "Oro/Hora:"
L.TooltipLastSession = "Ultima sesion"
