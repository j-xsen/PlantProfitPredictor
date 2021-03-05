local MAX_NUMBER_ROWS = 6
local MAX_NUMBER_COLS = 9


function PPPBags_OnLoad(self)
	self.Icon:SetTexture(133633)
	self.Count:SetText(5)
end

function PPPGotoBagsPage()
	PPPUpdateInventory()
	
	local ordered_bag = {}
	for k,v in pairs(PPPCurrentBag) do
		if v>0 then
			ordered_bag[#ordered_bag+1]=k
		end
	end
	
	for i=1,MAX_NUMBER_ROWS do
		for j=1,MAX_NUMBER_COLS do
		
			-- offset
			local current_index = ((i*MAX_NUMBER_COLS)-MAX_NUMBER_COLS)+j
			local current_id = ordered_bag[current_index]
			
			local frame = _G["PPPBaseFrameBagsFrameMainRow"..i..j]
			if frame then
				-- make sure it is in backpack
				if current_id and PPPCurrentBag[current_id] > 0 then
					-- find what table this item is in
					local current_table = nil
					if PPPPlants[current_id] then
						current_table = PPPPlants
					elseif PPPInks[current_id] then
						current_table = PPPInks
					elseif PPPPigments[current_id] then
						current_table = PPPPigments
					elseif PPPAlchemyCreations[current_id] then
						current_table = PPPAlchemyCreations
					elseif PPPInscriptionCreations[current_id] then
						current_table = PPPInscriptionCreations
					else
						print("[PlantProfitPredictor] Could not locate a current_table for ID " .. current_id)
					end
					
					frame.EmptyBackground:Hide()
					--frame:SetNormalTexture(current_table[current_id].file)
					frame.Icon:SetTexture(current_table[current_id].file)
					frame:SetText(current_table[current_id].name)
				else
					--frame.EmptyBackground:Show()
					--frame:SetNormalTexture("Interface\\AuctionFrame\\AuctionHouse\\auctionhouse-itemicon-empty")
				end
			else
				print("[PlantProfitPredictor] Could not locate frame PPPBaseFrameBagsFrameMainRow" .. i .. j)
			end
		end
	end
end