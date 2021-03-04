local MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH = 9 -- how many items found on the AH can we show per page
local DEBUG_MASSIVE_SAVES = false -- this should NOT!! be used in production. archives every relevant ah entry
local DEBUG_OPEN_ON_STARTUP = true -- should PPP open on startup?

local function FindCheapest(item_id)
	local minimum_price = nil
	if not DEBUG_MASSIVE_SAVES then
		print("[PlantProfitPredictor] Warning! You are running FindCheapest() without DEBUG_MASSIVE_SAVES enabled!")
	end
	if PPPAuctionHistory.items[item_id] then
		minimum_price = PPPCostPerUnit(PPPAuctionHistory.items[item_id][1])
		for i=1,#PPPAuctionHistory.items[item_id] do
			if minimum_price > PPPCostPerUnit(PPPAuctionHistory.items[item_id][i]) then
				minimum_price = PPPCostPerUnit(PPPAuctionHistory.items[item_id][i])
			end
		end
	else
		print("[PlantProfitPredictor] Invalid item_id " .. item_id)
	end
	return minimum_price
end

local DebugAHCurrentPage = 1
local DebugAHMassiveSavesCurrentPage = 1
local DebugAHCurrentFoundItem = nil
function PPPUpdateAHFoundItemsPage(direction)
	if direction == 1 or direction == -1 or direction == 0 then
		local new_page = DebugAHCurrentPage + direction
		if new_page > 0 then
			local ordered_found_ah_items = {}
			for k,v in pairs(PPPAuctionHistory.items) do
				ordered_found_ah_items[#ordered_found_ah_items+1] = k
			end
			local current_index = 1
			local offset = new_page * MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH - MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH
			while current_index <= MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH do
				if ordered_found_ah_items[current_index + offset] then
					_G["PPPBaseFrameDebugFrameMainAHItemFound" .. current_index]:SetText("[" .. ordered_found_ah_items[current_index+offset] .. "]")
					_G["PPPBaseFrameDebugFrameMainAHItemFound" .. current_index]:Show()
				else
					_G["PPPBaseFrameDebugFrameMainAHItemFound" .. current_index]:Hide()
				end
				current_index = current_index + 1
			end
			DebugAHCurrentPage = new_page
			PPPBaseFrameDebugFrameMainAHItemsFoundPageNumber:SetText(DebugAHCurrentPage)
			if DebugAHCurrentPage == 1 then
				PPPBaseFrameDebugFrameMainAHItemFoundPrevious:Disable()
			else
				PPPBaseFrameDebugFrameMainAHItemFoundPrevious:Enable()
			end
			if offset + MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH > #ordered_found_ah_items then
				PPPBaseFrameDebugFrameMainAHItemFoundNext:Disable()
			else
				PPPBaseFrameDebugFrameMainAHItemFoundNext:Enable()
			end
		else
			print("[PlantProfitPredictor] Invalid new_page " .. new_page)
		end
	elseif direction == 2 or direction == -2 or direction == -5 then
		if DEBUG_MASSIVE_SAVES then
			if DebugAHCurrentFoundItem then
				local new_page = DebugAHMassiveSavesCurrentPage
				if direction == 2 then
					new_page = DebugAHMassiveSavesCurrentPage + 1
				elseif direction == -2 then
					new_page = DebugAHMassiveSavesCurrentPage - 1
				end
				if new_page > 0 then
					local item = PPPAuctionHistory.items[DebugAHCurrentFoundItem][new_page]
					if item then
						local info_text = "name: "..item[1].."\ncount: "..item[3].."\nminBid: "..item[8].."\nbuyoutPrice: "..item[10]..
									  "\nbidAmount: "..item[11].."\nsaleStatus: "..item[16].."\nhasAllInfo: "..tostring(item[18])..
									  "\nCost Per Unit: "..PPPCostPerUnit(item)
						PPPBaseFrameDebugFrameMainAHItemFoundInfo:SetText(info_text)
						DebugAHMassiveSavesCurrentPage = new_page
						PPPBaseFrameDebugFrameMainAHItemsFoundMassivePageNumber:SetText(DebugAHMassiveSavesCurrentPage)
						if DebugAHMassiveSavesCurrentPage == 1 then
							PPPBaseFrameDebugFrameMainAHItemFoundMassiveSavePrevious:Disable()
						else
							PPPBaseFrameDebugFrameMainAHItemFoundMassiveSavePrevious:Enable()
						end
						if PPPAuctionHistory.items[DebugAHCurrentFoundItem] and #PPPAuctionHistory.items[DebugAHCurrentFoundItem] <= DebugAHMassiveSavesCurrentPage then
							PPPBaseFrameDebugFrameMainAHItemFoundMassiveSaveNext:Disable()
						else
							PPPBaseFrameDebugFrameMainAHItemFoundMassiveSaveNext:Enable()
						end
					else
						print("[PlantProfitPredictor] nil item on new_page " .. new_page)
					end
				else
					print("[PlantProfitPredictor] Invalid new_page " .. new_page)
				end
			else
				print("[PlantProfitPredictor] No current DebugAHCurrentFoundItem!")
			end
		else
			print("[PlantProfitPredictor] Attempted to use DEBUG_MASSIVE_SAVES' directions with it not active!")
		end
	else
		print("[PlantProfitPredictor] Invalid direction " .. direction)
	end
end
function PPPAHFoundItemClicked(button)
	local button_id = button:GetID()
	local ordered_found_ah_items = {}
	for k,v in pairs(PPPAuctionHistory.items) do
		ordered_found_ah_items[#ordered_found_ah_items+1] = k
	end
	
	local offset = DebugAHCurrentPage * MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH - MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH
	
	if ordered_found_ah_items[button_id + offset] then
		if DEBUG_MASSIVE_SAVES then
			DebugAHCurrentFoundItem = PPPAuctionHistory.items[ordered_found_ah_items[button_id+offset]][1][17]
			DebugAHMassiveSavesCurrentPage=1
			PPPBaseFrameDebugFrameMainAHItemFoundMassiveSaveNext:Show()
			PPPBaseFrameDebugFrameMainAHItemFoundMassiveSavePrevious:Show()
			PPPBaseFrameDebugFrameMainAHItemFoundInfoID:SetText("["..DebugAHCurrentFoundItem.."] x"..#PPPAuctionHistory.items[ordered_found_ah_items[button_id+offset]])
			PPPUpdateAHFoundItemsPage(-5)
		else
			PPPBaseFrameDebugFrameMainAHItemFoundInfoID:SetText("["..ordered_found_ah_items[button_id+offset].."]")
			local item = PPPAuctionHistory.items[ordered_found_ah_items[button_id+offset]]
			local info_text = "name: "..item[1].."\ncount: "..item[3].."\nminBid: "..item[8].."\nmidIncrement: "..item[9].."\nbuyoutPrice: "..item[10]..
							  "\nbidAmount: "..item[11].."\nsaleStatus: "..item[16].."\nhasAllInfo: "..tostring(item[18])
			local info_text = "name: "..item[1].."\ncount: "..item[3].."\nminBid: "..item[8].."\nbuyoutPrice: "..item[10]..
							  "\nbidAmount: "..item[11].."\nsaleStatus: "..item[16].."\nhasAllInfo: "..tostring(item[18])..
							  "\nCost Per Unit: "..PPPCostPerUnit(item)
			PPPBaseFrameDebugFrameMainAHItemFoundInfo:SetText(info_text)
		end
	else
		print("[PlantProfitPredictor] Invalid ordered_found_ah_items: button_id=" .. button_id .. " offset=" .. offset)
	end
end
function PPPGotoDebugPage()
	-- stuff to do when going to debug page
	PPPUpdateAHFoundItemsPage(0)
	
	-- update last ah scan
	if PPPAuctionHistory.time_of_query ~= nil then
		PPPBaseFrameDebugFrameMainLastAHScanTime:SetText("Last Auction House scan: " .. PPPAuctionHistory.time_of_query)
	else
		PPPBaseFrameDebugFrameMainLastAHScanTime:SetText("Last Auction House scan: N/A")
	end
	PPPBaseFrameDebugFrameMainLastAHScanCount:SetText("Number of replicate items stored: " .. C_AuctionHouse.GetNumReplicateItems())
	
	local ah_items_checked_text = "Items checked for on the AH:\n"
	for k,v in pairs(PPPListOfAHItems) do
		ah_items_checked_text = ah_items_checked_text .. "[" .. k .. "]\n"
	end
	PPPBaseFrameDebugFrameMainAHItemsChecked:SetText(ah_items_checked_text)
	
	local count_of_found_items = 0
	for k,v in pairs(PPPAuctionHistory.items) do
		count_of_found_items = count_of_found_items + 1
	end
	PPPBaseFrameDebugFrameMainSavedItemsCount:SetText("Number of items stored in PPPAuctionHistory: " .. count_of_found_items)
end

function PPPDebugButtonScanNewAHList()
	ScanNewAHList()
end
