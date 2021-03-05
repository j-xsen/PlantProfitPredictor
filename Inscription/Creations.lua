local MAX_NUMBER_INSCRIPTION_CREATIONS = 4 -- how many alchemy creations can we show per page
local MAX_NUMBER_INSCRIPTION_INGREDIENTS = 6 -- how many alchemy ingredients can we show

local CurrentInscription = PPPShadowlandsInscription

local current_inscription_page = 1
function PPPInscriptionChangePage(direction)
	if current_inscription_page+direction > 0 or current_inscription_page+direction > #CurrentInscription/MAX_NUMBER_INSCRIPTION_CREATIONS then
		current_inscription_page = current_inscription_page+direction
		PPPUpdateOffsetCreations("PPPBaseFrameInscriptionFrameMain",current_inscription_page,CurrentInscription,PPPInscriptionCreations)
	else
		print("[PlantProfitPredictor] Invalid direction " .. direction)
	end
end
local function UpdateInscriptionPage()
	PPPUpdateInventory()
	
	-- bottom bar stuff
	PPPBaseFrameInscriptionFrameMainBottomBarPageNumber:SetText(current_inscription_page)
	if current_inscription_page == 1 then
		PPPBaseFrameInscriptionFrameMainBottomBarButtonLeft:Disable()
	else
		PPPBaseFrameInscriptionFrameMainBottomBarButtonLeft:Enable()
	end
	if current_inscription_page >= #CurrentInscription / MAX_NUMBER_INSCRIPTION_CREATIONS then
		PPPBaseFrameInscriptionFrameMainBottomBarButtonRight:Disable()
	else
		PPPBaseFrameInscriptionFrameMainBottomBarButtonRight:Enable()
	end
	
	local inscription_offset = (current_inscription_page * MAX_NUMBER_INSCRIPTION_CREATIONS) - MAX_NUMBER_INSCRIPTION_CREATIONS
	for i=1,MAX_NUMBER_INSCRIPTION_CREATIONS do
		if i+inscription_offset<=#CurrentInscription then
		
		end
	end
end

function PPPGotoInscriptionPage()
	-- UpdateInscriptionPage()
	--PPPUpdateOffsetCreations("PPPBaseFrameInscriptionFrameMain",current_inscription_page,CurrentInscription,PPPInscriptionCreations)
	PPPInscriptionChangePage(0)
end
