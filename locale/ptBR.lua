local ADDON_NAME, private = ...

local L = private:NewLocale("ptBR")
if not L then return end

L.SlashBG = "fundo"
L.SlashBGOn = "xanGoldMine: Fundo agora [|cFF99CC33EXIBIDO|r]"
L.SlashBGOff = "xanGoldMine: Fundo agora [|cFF99CC33OCULTO|r]"
L.SlashBGInfo = "Mostrar o fundo da janela."

L.SlashReset = "reset"
L.SlashResetInfo = "Redefinir a posicao da janela."
L.SlashResetAlert = "xanGoldMine: Posicao da janela redefinida!"

L.SlashResetGold = "resetouro"
L.SlashResetGoldInfo = "Redefinir valores de ouro do banco de dados."
L.SlashResetGoldAlert = "xanGoldMine: Valores de ouro redefinidos!"

L.SlashScale = "escala"
L.SlashScaleSet = "xanGoldMine: a escala foi definida para [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Escala invalida! O numero deve ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Define a escala da janela xanGoldMine (0.5 - 5)."
L.SlashScaleText = "Escala da janela xanGoldMine"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33Total ganho|r] agora [|cFF99CC33EXIBIDO|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33Lucro liquido|r] agora [|cFF99CC33EXIBIDO|r]"
L.SlashTotalEarnedInfo = "Alterna entre [|cFF99CC33Total ganho|r] e [|cFF99CC33Lucro liquido|r] como texto do botao."
L.SlashTotalEarnedChkBtn = "Mostrar [|cFF99CC33Total ganho|r] em vez de [|cFF99CC33Lucro liquido|r] como texto do botao."

L.SlashFontColor = "cor"
L.SlashFontColorOn = "xanGoldMine: Cor da fonte do tooltip agora [|cFF99CC33AMARELO|r]"
L.SlashFontColorOff = "xanGoldMine: Cor da fonte do tooltip agora [|cFF99CC33BRANCO|r]"
L.SlashFontColorInfo = "Alterna a cor do tooltip entre [|cFF99CC33BRANCO|r] e [|cFF99CC33AMARELO|r]."
L.SlashFontColorChkBtn = "Mostrar [|cFF99CC33AMARELO|r] em vez de [|cFF99CC33BRANCO|r] como cor do tooltip."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: Totais vitalicios das estatisticas agora [|cFF99CC33ATIVADO|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: Totais vitalicios das estatisticas agora [|cFF99CC33DESATIVADO|r]"
L.SlashAchLifetimeTotalsInfo = "Alterna o uso dos totais vitalicios das estatisticas do personagem [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "Usar Conquistas -> Estatisticas -> Personagem -> Riqueza -> Totais vitalicios."

L.Waiting = "Aguardando..."

L.TooltipDragInfo = "[Segure Shift e arraste para mover a janela.]"
L.TooltipTotalGold = "Dinheiro total:"
L.TooltipSession = "Sessao"
L.TooltipLifetime = "Vitalicio"
L.TooltipTotalEarned = "Total ganho:"
L.TooltipTotalSpent = "Total gasto:"
L.TooltipNetProfit = "Lucro liquido:"
L.TooltipDiff = "Diferenca total:"
L.TooltipLastTransaction = "Ultima transacao:"
L.TooltipQuest = "Recompensas de missao:"
L.TooltipTaxi = "Viagens:"
L.TooltipLoot = "Saque:"
L.TooltipRepairs = "Reparos:"
L.TooltipMerchant = "Mercador:"
L.TooltipGoldPerSec = "Ouro/Seg:"
L.TooltipGoldPerMinute = "Ouro/Minuto:"
L.TooltipGoldPerHour = "Ouro/Hora:"
L.TooltipLastSession = "Ultima sessao"
