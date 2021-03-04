local MAX_NUMBER_ALCHEMY_CREATIONS = 4 -- how many alchemy creations can we show per page
local MAX_NUMBER_ALCHEMY_INGREDIENTS = 6 -- how many alchemy ingredients can we show

local CurrentAlchemy = PPPShadowlandsAlchemy

local current_alchemy_page = 1

function PPPAlchemyChangePage(direction)
	if current_alchemy_page+direction > 0 or current_alchemy_page+direction > #CurrentAlchemy/MAX_NUMBER_ALCHEMY_CREATIONS then
		current_alchemy_page = current_alchemy_page+direction
		PPPUpdateOffsetCreations("PPPBaseFrameAlchemyFrameMain",current_alchemy_page,CurrentAlchemy,PPPAlchemyCreations)
	else
		print("[PlantProfitPredictor] Invalid direction " .. direction)
	end
end
function PPPGotoAlchemyPage()
	-- stuff to do when going to alchemy page
	--UpdateAlchemyPage()
	PPPAlchemyChangePage(0)
end