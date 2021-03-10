local MAX_NUMBER_ROWS = 5
local MAX_NUMBER_COLS = 9


local selected_items = {}
function PPPBags_OnLoad(self)
	self.Icon:SetTexture(133633)
	self.Count:SetText(5)
end

function PPPBagsResetSelected()
	selected_items = {}
	PPPGotoBagsPage()
end

local current_bags_page = 1
local function GetCurrentIndex(row,col)
	return (((row*MAX_NUMBER_COLS)-MAX_NUMBER_COLS)+col)+(((MAX_NUMBER_COLS*MAX_NUMBER_ROWS)*current_bags_page)-(MAX_NUMBER_COLS*MAX_NUMBER_ROWS))
end

local function GetOrderedBag()
	local ordered_bag = {}
	for k,v in pairs(PPPCurrentBag) do
		if v>0 then
			ordered_bag[#ordered_bag+1]=k
		end
	end
	return ordered_bag
end

local function CheckIfInSelectedItems(item_id)
	for k,v in pairs(selected_items) do
		if v == item_id then
			return k
		end
	end
	return nil
end

function PPPBagsItem_OnClick(self)
	local location_string = string.sub(self:GetName(), -2)
	local row = string.sub(location_string,1,1)
	local col = string.sub(location_string,-1)
	
	local current_index = GetCurrentIndex(row,col)
	local ordered_bag = GetOrderedBag()
	
	if ordered_bag[current_index] then
		local already_index = CheckIfInSelectedItems(ordered_bag[current_index])
		if not already_index then
			PPPBaseFrameBagsFrameMainResetSelected:Enable()
			selected_items[#selected_items+1] = ordered_bag[current_index]
		else
			table.remove(selected_items,already_index)
			if #selected_items <= 0 then
				PPPBaseFrameBagsFrameMainResetSelected:Disable()
			end
		end
		
		PPPGotoBagsPage()
	end
	
end

local function TotalBagsProfit()
	local current_profit = 0
	for k,v in pairs(PPPCurrentBag) do
		current_profit = current_profit + (PPPCostPerUnit(PPPAuctionHistory.items[k])*PPPCurrentBag[k])
	end
	return current_profit
end

function PPPGotoBagsPage()
	PPPUpdateInventory()
	
	local ordered_bag = GetOrderedBag()

	PPPBottomBarButtons("PPPBaseFrameBagsFrameMain", current_bags_page, #ordered_bag/(MAX_NUMBER_ROWS*MAX_NUMBER_COLS))
	
	if PPPEditedBag then
		PPPBaseFrameBagsFrameMainResetBag:Show()
	elseif PPPBaseFrameBagsFrameMainResetBag:IsShown() then
		PPPBaseFrameBagsFrameMainResetBag:Hide()
	end
	
	-- make sure all selected still exist
	for k,v in pairs(selected_items) do
		if not PPPCurrentBag[v] or PPPCurrentBag[v] <= 0 then
			table.remove(selected_items,k)
		end
	end
	
	if #selected_items == 0 then
		PPPBaseFrameBagsFrameMainResetSelected:Disable()
	else
		PPPBaseFrameBagsFrameMainResetSelected:Enable()
	end
	
	local selected_profits = 0
	for i=1,MAX_NUMBER_ROWS do
		for j=1,MAX_NUMBER_COLS do
		
			-- offset
			local current_index = GetCurrentIndex(i,j)
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
					
					if PPPCurrentBag[current_id] % 1 ~= 0 then
						frame.Count:SetText(string.format("%.1f",PPPCurrentBag[current_id]))
					else
						frame.Count:SetText(PPPCurrentBag[current_id])
					end
					--frame:SetNormalTexture(current_table[current_id].file)
					frame.Icon:Show()
					frame.Icon:SetTexture(current_table[current_id].file)
					local tooltip_text = current_table[current_id].name
					if PPPAuctionHistory.items[current_id] then
						tooltip_text = tooltip_text .. "\n" .. PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[current_id]))
					end
					frame:SetText(tooltip_text)
					
					if CheckIfInSelectedItems(current_id) then
						if selected_profits and PPPAuctionHistory.items[current_id] then
							selected_profits = selected_profits + (PPPCostPerUnit(PPPAuctionHistory.items[current_id])*PPPCurrentBag[current_id])
						else
							selected_profits=nil
						end
						frame.IconPressed:Show()
					else
						frame.IconPressed:Hide()
					end
				else
					if frame.Count:GetText()~=""then
						frame.Count:SetText(nil)
					end
					frame.Icon:Hide()
					frame.IconPressed:Hide()
					--frame.EmptyBackground:Show()
					--frame:SetNormalTexture("Interface\\AuctionFrame\\AuctionHouse\\auctionhouse-itemicon-empty")
				end
			else
				print("[PlantProfitPredictor] Could not locate frame PPPBaseFrameBagsFrameMainRow" .. i .. j)
			end
		end
	end
	
	local base_frame = PPPBaseFrameBagsFrameMain
	if base_frame then
		base_frame.TotalProfits:SetText("Estimated profits: " .. PPPGetFormattedGoldString(TotalBagsProfit()))
		if selected_profits then
			base_frame.SelectedProfits:SetText("Estimated profits from selected: " ..PPPGetFormattedGoldString(selected_profits))
		end
	else
		print("[PlantProfitPredictor] Could not locate frame PPPBaseFrameBagsFrameMain")
	end
end

function PPPBagsChangePage(direction)
	if current_bags_page+direction > 0 or current_bags_page+direction > #PPPCurrentBag/(MAX_NUMBER_COLS*MAX_NUMBER_COLS) then
		current_bags_page = current_bags_page+direction
		PPPGotoBagsPage()
	else
		print("[PlantProfitPredictor] Invalid direction " .. direction)
	end
end

function PPPBagsResetBag()
	PPPEditedBag = false
	PPPUpdateInventory()
	PPPGotoBagsPage()
end
