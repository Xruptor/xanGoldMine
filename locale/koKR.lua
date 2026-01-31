local ADDON_NAME, private = ...

local L = private:NewLocale("koKR")
if not L then return end

L.SlashBG = "bg"
L.SlashBGOn = "xanGoldMine: 배경이 [|cFF99CC33표시됨|r]"
L.SlashBGOff = "xanGoldMine: 배경이 [|cFF99CC33숨김|r]"
L.SlashBGInfo = "창 배경 표시."

L.SlashReset = "reset"
L.SlashResetInfo = "창 위치 초기화."
L.SlashResetAlert = "xanGoldMine: 창 위치가 초기화되었습니다!"

L.SlashResetGold = "resetgold"
L.SlashResetGoldInfo = "데이터베이스 골드 값을 초기화합니다."
L.SlashResetGoldAlert = "xanGoldMine: 데이터베이스 골드 값이 초기화되었습니다!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanGoldMine: 스케일이 [|cFF20ff20%s|r](으)로 설정되었습니다"
L.SlashScaleSetInvalid = "스케일이 올바르지 않습니다! 숫자는 [0.5 - 5] 사이여야 합니다. (0.5, 1, 3, 4.6 등)"
L.SlashScaleInfo = "xanGoldMine 창의 스케일을 설정합니다 (0.5 - 5)."
L.SlashScaleText = "xanGoldMine 창 스케일"

L.SlashTotalEarned = "total"
L.SlashTotalEarnedOn = "xanGoldMine: [|cFF99CC33총 획득|r]이 [|cFF99CC33표시됨|r]"
L.SlashTotalEarnedOff = "xanGoldMine: [|cFF99CC33순이익|r]이 [|cFF99CC33표시됨|r]"
L.SlashTotalEarnedInfo = "버튼 텍스트를 [|cFF99CC33총 획득|r] 또는 [|cFF99CC33순이익|r]으로 전환합니다."
L.SlashTotalEarnedChkBtn = "버튼 텍스트를 [|cFF99CC33총 획득|r]으로 표시합니다."

L.SlashFontColor = "color"
L.SlashFontColorOn = "xanGoldMine: 툴팁 글꼴 색상이 [|cFF99CC33노랑|r]"
L.SlashFontColorOff = "xanGoldMine: 툴팁 글꼴 색상이 [|cFF99CC33흰색|r]"
L.SlashFontColorInfo = "툴팁 색상을 [|cFF99CC33흰색|r]과 [|cFF99CC33노랑|r] 사이에서 전환합니다."
L.SlashFontColorChkBtn = "툴팁 색상을 [|cFF99CC33노랑|r]으로 표시합니다."

L.SlashAchLifetimeTotals = "achtotals"
L.SlashAchLifetimeTotalsOn = "xanGoldMine: 업적 통계 평생 합계가 [|cFF99CC33켜짐|r]"
L.SlashAchLifetimeTotalsOff = "xanGoldMine: 업적 통계 평생 합계가 [|cFF99CC33꺼짐|r]"
L.SlashAchLifetimeTotalsInfo = "캐릭터 업적 통계 평생 합계를 사용 [|cFF99CC33ON/OFF|r]."
L.SlashAchLifetimeTotalsChkBtn = "업적 -> 통계 -> 캐릭터 -> 부 -> 평생 합계 사용."

L.Waiting = "대기 중..."

L.TooltipDragInfo = "[Shift를 누른 채 드래그하여 창을 이동합니다.]"
L.TooltipTotalGold = "총 골드:"
L.TooltipSession = "세션"
L.TooltipLifetime = "전체"
L.TooltipTotalEarned = "총 획득:"
L.TooltipTotalSpent = "총 지출:"
L.TooltipNetProfit = "순이익:"
L.TooltipDiff = "총 차이:"
L.TooltipLastTransaction = "최근 거래:"
L.TooltipQuest = "퀘스트 보상:"
L.TooltipTaxi = "탈것 이동 비용:"
L.TooltipLoot = "전리품:"
L.TooltipRepairs = "수리:"
L.TooltipMerchant = "상인:"
L.TooltipGoldPerSec = "골드/초:"
L.TooltipGoldPerMinute = "골드/분:"
L.TooltipGoldPerHour = "골드/시간:"
L.TooltipLastSession = "마지막 세션"
