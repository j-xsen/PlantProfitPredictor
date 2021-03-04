local CurrentPlants = PPPShadowlandsPlants
local CurrentAlchemy = PPPShadowlandsAlchemy
local MAX_NUMBER_MILLING_LIST = 12 -- max number of items displayed on the milling tab
local MAX_NUMBER_PLANTS = 6 -- how many plants can be shown on the plant page at once
local MAX_NUMBER_PIGMENTS = 3 -- how many pigments can be shown at once
local MAX_NUMBER_ALCHEMY_CREATIONS = 4 -- how many alchemy creations can we show per page
local MAX_NUMBER_ALCHEMY_INGREDIENTS = 6 -- how many alchemy ingredients can we show
local MAX_NUMBER_DEBUG_ITEMS_FOUND_ON_AH = 9 -- how many items found on the AH can we show per page
local DEBUG_MASSIVE_SAVES = false -- this should NOT!! be used in production. archives every relevant ah entry
local DEBUG_OPEN_ON_STARTUP = true -- should PPP open on startup?

local list_of_ah_items = {}
for k,v in pairs(PPPPlants) do
	list_of_ah_items[k]=true
end
for k,v in pairs(PPPPigments) do
	list_of_ah_items[k]=true
end
for k,v in pairs(PPPAlchemyCreations) do
	list_of_ah_items[k]=true
end
for k,v in pairs(PPPInks) do
	list_of_ah_items[k]=true
end

local function FindXsInBag(list)
	local total = {}
	for k,v in pairs(list) do
		total[k] = 0
	end
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = GetContainerItemID(bag, slot)
			if itemID then
				if list[itemID] ~= nil then
					total[itemID] = total[itemID] + select(2, GetContainerItemInfo(bag, slot))
				end
			end
		end
	end
	return total
end

local function GetFormattedGoldString(starting)
	if starting then
		local copper = starting % 100
		local silver = math.floor(starting/1e2) % 100
		local gold = math.floor(starting/1e4)
		local return_string = "|cffffff00" .. gold .. "g|r |cffb5b5bd" .. silver .. "s|r |cffaf633e" .. copper .. "c|r"
		return return_string
	else
		print("[PlantProfitPredictor] Invalid starting!")
		return nil
	end
end

local function CostPerUnit(item)
	if item and item[3] and item[10] then
		return item[10]/item[3]
	else
		print("[PlantProfitPredictor] Invalid CostPerUnit(" .. (item or "nil") .. ")!")
	end
end

-- PPPMillingHistory = { {id=plant_id, output = {luminous= amount, tranquil=amount, umbral=amount}, mass=was_it_mass } }
local currently_milling = false
local current_milling_info = {}
local last_bag = {}
local current_bag = {}
local function UpdateInventory()
	last_bag = current_bag
	current_bag = FindXsInBag(list_of_ah_items)
	
	-- check for any differences
	if currently_milling then
		for id, count in pairs(current_bag) do
			if last_bag[id] ~= count then
				if current_milling_info.id == nil then
					for k,v in pairs(PPPPlants) do
						if id == k then
							current_milling_info.id=k
							for i=1,#v.pigments do
								current_milling_info.output[v.pigments[i]] = 0
							end
						end
					end
				else
					if current_milling_info.id ~= nil then
						for k,v in pairs(current_milling_info.output) do
							if id == k then
								current_milling_info.output[id] = count - last_bag[id]
							end
						end
					end
				end
			end
		end
	end
end

local function FindCheapest(item_id)
	local minimum_price = nil
	if not DEBUG_MASSIVE_SAVES then
		print("[PlantProfitPredictor] Warning! You are running FindCheapest() without DEBUG_MASSIVE_SAVES enabled!")
	end
	if PPPAuctionHistory.items[item_id] then
		minimum_price = CostPerUnit(PPPAuctionHistory.items[item_id][1])
		for i=1,#PPPAuctionHistory.items[item_id] do
			if minimum_price > CostPerUnit(PPPAuctionHistory.items[item_id][i]) then
				minimum_price = CostPerUnit(PPPAuctionHistory.items[item_id][i])
			end
		end
	else
		print("[PlantProfitPredictor] Invalid item_id " .. item_id)
	end
	return minimum_price
end

local function UpdatePlantCountFrame()
	UpdateInventory()
	
	-- hide everything in case not needed
	for i=1,MAX_NUMBER_PLANTS do
		-- hide pigments too in case they're not needed
		for j=1,MAX_NUMBER_PIGMENTS do
			_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "PigmentButton" .. j]:Hide()
		end
		_G["PPPBaseFrameMillingFrameMainPlant" .. i]:Hide()
	end
	
	-- update plant count
	for i=1,#CurrentPlants do
		if i <= MAX_NUMBER_PLANTS then
			local frame_name = "PPPBaseFrameMillingFrameMainPlant" .. i .. "Name"
			frame = _G[frame_name]
			if frame then
				local possible_millings = math.floor(current_bag[CurrentPlants[i]] / 5)
				_G["PPPBaseFrameMillingFrameMainPlant" .. i]:Show()
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "PlantButton"]:SetNormalTexture(PPPPlants[CurrentPlants[i]].file)
				local plant_button_text = PPPPlants[CurrentPlants[i]].name
				if PPPAuctionHistory and PPPAuctionHistory.items[CurrentPlants[i]] then
					if DEBUG_MASSIVE_SAVES then
						plant_button_text = plant_button_text .. "\n" .. GetFormattedGoldString(FindCheapest(CurrentPlants[i]))
					else
						plant_button_text = plant_button_text .. "\n" .. GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[CurrentPlants[i]]))..
						                    "\n\n|cffffff00Estimated profits:|r\n" .. GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[CurrentPlants[i]])*current_bag[CurrentPlants[i]])
					end
				end
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "PlantButton"]:SetText(plant_button_text)
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "TimesCanMill"]:SetText("x" .. possible_millings)
				frame:SetText(PPPPlants[CurrentPlants[i]].name .. ": " .. current_bag[CurrentPlants[i]])
				
				-- clear arrow text
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText("|cffffff00Per milling of 5 plants:|r|cffffffff")
				
				local estimated_pigment_profit = 0
				local estimated_ink_profit = 0
				-- set texture and text of pigment buttons
				for j=1,#PPPPlants[CurrentPlants[i]].pigments do
					if j<=MAX_NUMBER_PIGMENTS then
						local current_text = _G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:GetText()
						if current_text ~= nil then
							_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. "\n" .. PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].name)
						else
							_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].name)
						end
						pigment_frame_name = "PPPBaseFrameMillingFrameMainPlant" .. i .. "PigmentButton" .. j
						pigment_frame = _G[pigment_frame_name]
						if pigment_frame then
							local pigment_item_id = PPPPlants[CurrentPlants[i]].pigments[j]
							if PPPAuctionHistory and PPPAuctionHistory.items[pigment_item_id] then
								pigment_frame:SetText(PPPPigments[pigment_item_id].name .. "\n" .. GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[pigment_item_id])))
							else
								pigment_frame:SetText(PPPPigments[pigment_item_id].name)
							end
							pigment_frame:Show()
							pigment_frame:SetNormalTexture(PPPPigments[pigment_item_id].file)
							
							-- update pigment estimate
							local total_milled = 0
							local times_milled = 0
							if PPPMillingHistory ~= nil then
								for k,v in pairs(PPPMillingHistory) do
									if v.id == CurrentPlants[i] then
										total_milled = total_milled + v.output[pigment_item_id]
										if v.mass_milled then
											times_milled = times_milled + 4
										else
											times_milled = times_milled + 1
										end
									end
								end
							end
							local current_text = _G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:GetText()
							if total_milled ~= 0 then
								local estimation_per_milling = (total_milled/times_milled)
								local estimated_i_profit = 0
								if PPPAuctionHistory and PPPAuctionHistory.items[pigment_item_id] then
									local estimated_profit = math.floor(estimation_per_milling*possible_millings)*CostPerUnit(PPPAuctionHistory.items[pigment_item_id])
									estimated_pigment_profit = estimated_pigment_profit + estimated_profit
									pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffff00Estimated profits:\n"..GetFormattedGoldString(estimated_profit))
									if PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink] then
										local estimated_i_profit = math.floor(estimation_per_milling*possible_millings)*CostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])
										estimated_ink_profit = estimated_ink_profit + estimated_i_profit
										pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffd200"..PPPInks[PPPPigments[pigment_item_id].ink].name.."\n"..GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])))
										pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffff00Estimated profits as inks:\n"..GetFormattedGoldString(estimated_i_profit))
									end
								end
								_G[pigment_frame_name .. "Count"]:SetText(string.format("%.1f",estimation_per_milling*possible_millings))
								_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. ": " .. string.format("%.1f",estimation_per_milling))
							else
								if PPPAuctionHistory and PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink] then
									pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffd200"..PPPInks[PPPPigments[pigment_item_id].ink].name.."\n"..GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])))
								end
								_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. ": 0")
								_G[pigment_frame_name .. "Count"]:SetText("0")
							end
						else
							print("[PlantProfitPredictor] Could not locate frame " .. pigment_frame_name)
						end
					else
						print("[PlantProfitPredictor] Too many pigments!")
					end
				end
				local current_text = _G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:GetText()
				local additional_text = "|r\n\n|cffffff00Estimated profits from pigments:|r\n|cffffffff" .. GetFormattedGoldString(estimated_pigment_profit) .. "|r"..
				                        "|r\n\n|cffffff00Estimated profits from inks:|r\n|cffffffff" .. GetFormattedGoldString(estimated_ink_profit).."|r"
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. additional_text)
			else
				print("[PlantProfitPredictor] Could not locate frame " .. frame_name)
			end
		else
			print("[PlantProfitPredictor] NEED NEW PAGE!!!")
		end
	end
end

local function FinishedMillLooting()
	if currently_milling then
		table.insert(PPPMillingHistory, 1, current_milling_info)
		currently_milling = false
		current_milling_info = {}
		PPPScrollBarUpdate()
		if PPPBaseFrameMillingFrame:IsVisible() then
			UpdatePlantCountFrame()
		end
	end
end

local function StoredAHHasAllIngredients(creation)
	local has_all = true
	for k,v in pairs(creation.ingredients) do
		if not PPPAuctionHistory.items[k] then
			has_all = false
			print("[PlantProfitPredictor] I do not have an item ID " .. k .. " stored!")
		end
	end
	return has_all
end


local current_alchemy_page = 1
local function UpdateAlchemyPage()
	UpdateInventory()
	
	-- bottom bar stuff
	PPPBaseFrameAlchemyFrameMainBottomBarPageNumber:SetText(current_alchemy_page)
	if current_alchemy_page == 1 then
		PPPBaseFrameAlchemyFrameMainBottomBarButtonLeft:Disable()
	else
		PPPBaseFrameAlchemyFrameMainBottomBarButtonLeft:Enable()
	end
	if current_alchemy_page >= #CurrentAlchemy / MAX_NUMBER_ALCHEMY_CREATIONS then
		PPPBaseFrameAlchemyFrameMainBottomBarButtonRight:Disable()
	else
		PPPBaseFrameAlchemyFrameMainBottomBarButtonRight:Enable()
	end
	
	-- display creation info
	local alchemy_offset = (current_alchemy_page * MAX_NUMBER_ALCHEMY_CREATIONS) - MAX_NUMBER_ALCHEMY_CREATIONS
	for i=1,MAX_NUMBER_ALCHEMY_CREATIONS do
		--if i<= MAX_NUMBER_ALCHEMY_CREATIONS then
		if i+alchemy_offset<=#CurrentAlchemy then
			local frame_name = "PPPBaseFrameAlchemyFrameMainCreation" .. i
			local frame = _G[frame_name]
			if frame then
				local creation_id = CurrentAlchemy[i+alchemy_offset]
				local creation_table = PPPAlchemyCreations[creation_id]
				frame:Show()
				_G[frame_name .. "CreationButton"]:SetNormalTexture(creation_table.file)
				local plant_button_text = creation_table.name
				if PPPAuctionHistory.items[creation_id] then
					if DEBUG_MASSIVE_SAVES then
						plant_button_text = plant_button_text .. "\n" .. GetFormattedGoldString(FindCheapest(creation_id))
					else
					
						plant_button_text = plant_button_text .. "\n" .. GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[creation_id]))
						if current_bag[creation_id] then
							plant_button_text = plant_button_text .. "\n\n|cffffff00Estimated profits:\n"..GetFormattedGoldString(CostPerUnit(PPPAuctionHistory.items[creation_id])*current_bag[creation_id])
						end
					end
				end
				_G[frame_name .. "CreationButton"]:SetText(plant_button_text)
				_G[frame_name .. "Name"]:SetText(creation_table.name)
				local ah_all_ingredients_stored = StoredAHHasAllIngredients(creation_table)
				local arrow_text = "|cffffff00Estimated cost to produce:|r"
				if not ah_all_ingredients_stored then
					arrow_text = arrow_text .. "|cffffffffUNKNOWN|r"
				end
				
				-- run through each ingredient
				local ingredient_number = 1
				local max_can_create = 0
				local total_creation_cost = 0
				-- hide each ingredient
				for j=1,MAX_NUMBER_ALCHEMY_INGREDIENTS do
					local ingredient_frame_name = frame_name.."IngredientButton"..j
					local frame = _G[ingredient_frame_name]
					if frame then
						_G[frame_name.."IngredientButton"..j]:Hide()
					else
						print("[PlantProfitPredictor] Could not locate frame " .. ingredient_frame_name)
					end
				end
				for k,v in pairs(creation_table.ingredients) do
					-- add to arrow
					if ah_all_ingredients_stored then
						local ingredient_cost = CostPerUnit(PPPAuctionHistory.items[k])*v
						arrow_text = arrow_text .."\n".. PPPPlants[k].name .. ": " .. GetFormattedGoldString(ingredient_cost)
						total_creation_cost = total_creation_cost + ingredient_cost
					end
					
					local can_create_with_this_ingredient = math.floor(current_bag[k] / v)
					if ingredient_number == 1 or can_create_with_this_ingredient < max_can_create then
						max_can_create = can_create_with_this_ingredient
					end
					if ingredient_number <= MAX_NUMBER_ALCHEMY_INGREDIENTS then
						local ingredient_frame_name = frame_name .. "IngredientButton" .. ingredient_number
						ingredient_frame = _G[ingredient_frame_name]
						if ingredient_frame then
							ingredient_frame:Show()
							ingredient_frame:SetNormalTexture(PPPPlants[k].file)
							ingredient_frame:SetText(PPPPlants[k].name .. "\n|cffffffffTotal in bags: " .. current_bag[k] .. "|r")
							_G[ingredient_frame_name .. "Count"]:SetText(v)
							_G[ingredient_frame_name .. "TimesCanCreate"]:SetText(can_create_with_this_ingredient)
						else
							print("[PlantProfitPredictor] Could not locate frame " .. frame_name .. "IngredientButton" .. ingredient_number)
						end
						ingredient_number = ingredient_number + 1
					else
						print("[PlantProfitPredictor] I'm not equipped to handle that many ingredients!")
					end
				end
				if ah_all_ingredients_stored then
					arrow_text = arrow_text .. "\n\nTotal: " .. GetFormattedGoldString(total_creation_cost)
				end
				_G[frame_name .. "Arrow"]:SetText(arrow_text)
				can_create_frame = _G[frame_name .. "TimesCanCreate"]:SetText("x" .. max_can_create)
			else
				print("[PlantProfitPredictor] Could not locate frame " .. frame_name)
			end
		--else
		--	print("[PlantProfitPredictor] Too many recipes! I need more pages!")
		--end
		else
			local frame_name = "PPPBaseFrameAlchemyFrameMainCreation" .. i
			local frame = _G[frame_name]
			if frame then
				frame:Hide()
			else
				print("[PlantProfitPredictor] Could not locate frame " .. frame_name)
			end
		end
	end
end
local function PPPAlchemyChangePage(direction)
	if current_alchemy_page+direction > 0 or current_alchemy_page+direction > #CurrentAlchemy/MAX_NUMBER_ALCHEMY_CREATIONS then
		current_alchemy_page = current_alchemy_page+direction
		UpdateAlchemyPage()
	else
		print("[PlantProfitPredictor] Invalid direction " .. direction)
	end
end
local function PPPInscriptionChangePage(direction)
	print("[PlantProfitPredictor] Change Inscription Page " .. direction)
end

function PPPChangePage(direction)
	if PPPCurrentTab==2 then
		PPPAlchemyChangePage(direction)
	elseif PPPCurrentTab==3 then
		
	else
		print("[PlantProfitPredictor] Invalid PPPCurrentTab " .. (PPPCurrentTab or "nil"))
	end
end

function PPPGotoPlantPage()
	UpdatePlantCountFrame()
end
function PPPGotoMillingPage()
	-- update information when going to milling page
	PPPScrollBarUpdate()
end
function PPPGotoAlchemyPage()
	-- stuff to do when going to alchemy page
	UpdateAlchemyPage()
end
function PPPGotoInscriptionPage()
	print("[PlantProfitPredictor] Going to Inscription Page!")
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
									  "\nCost Per Unit: "..CostPerUnit(item)
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
							  "\nCost Per Unit: "..CostPerUnit(item)
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
	for k,v in pairs(list_of_ah_items) do
		ah_items_checked_text = ah_items_checked_text .. "[" .. k .. "]\n"
	end
	PPPBaseFrameDebugFrameMainAHItemsChecked:SetText(ah_items_checked_text)
	
	local count_of_found_items = 0
	for k,v in pairs(PPPAuctionHistory.items) do
		count_of_found_items = count_of_found_items + 1
	end
	PPPBaseFrameDebugFrameMainSavedItemsCount:SetText("Number of items stored in PPPAuctionHistory: " .. count_of_found_items)
end

local function ToggleFrame()
	if PPPBaseFrame:IsVisible() then
		PPPBaseFrame:Hide()
	else
		UpdatePlantCountFrame()
		PPPBaseFrame:Show()
	end
end

function PPPScrollBarUpdate()
	local line, lineplusoffset
	FauxScrollFrame_Update(PPPBaseFrameMillingFrameLogScrollFrame,#PPPMillingHistory,12,25) -- (frame, total number, number shown, height)
	for line=1,MAX_NUMBER_MILLING_LIST do
		lineplusoffset = line + FauxScrollFrame_GetOffset(PPPBaseFrameMillingFrameLogScrollFrame)
		if lineplusoffset <= #PPPMillingHistory then
			local plant_name = nil
			local plant_file, plant_id
			for k,v in pairs(PPPPlants) do
				if k == PPPMillingHistory[lineplusoffset].id then
					_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "PlantButton"]:SetText(v.name)
					_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "PlantButton"]:SetNormalTexture(v.file)
					if PPPMillingHistory[lineplusoffset].mass_milled then
						_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "Name"]:SetText(v.name .. " x20")
					else
						_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "Name"]:SetText(v.name .. " x5")
					end
				end
			end
			
			local pigment_int = 1
			for k,v in pairs(PPPMillingHistory[lineplusoffset].output) do
				_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "PigmentButton" .. pigment_int .. "Count"]:SetText(v)
				_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "PigmentButton" .. pigment_int]:SetNormalTexture(PPPPigments[k].file)
				_G["PPPBaseFrameMillingFrameLogEntry" .. line .. "PigmentButton" .. pigment_int]:SetText(PPPPigments[k].name)
				pigment_int = pigment_int + 1
			end
			_G["PPPBaseFrameMillingFrameLogEntry" .. line]:Show()
		else
			_G["PPPBaseFrameMillingFrameLogEntry" .. line]:Hide()
		end
	end
end

local function ScanNewAHList()
	if C_AuctionHouse.GetNumReplicateItems()-1 ~= -1 then
		print("[PlantProfitPredictor] About to scan " .. C_AuctionHouse.GetNumReplicateItems()-1 .. " items.")
		PPPAuctionHistory.time_of_query = date()
		PPPAuctionHistory.items = {}
		local continuables = {}
		local relevant_item_count = 0
		for i = 0, C_AuctionHouse.GetNumReplicateItems()-1 do
			local item_name, _, count, _, _, _, _, min_bid, _, buyout_price, _, _, _, _, _, _, item_id, has_all_data = C_AuctionHouse.GetReplicateItemInfo(i)
			if list_of_ah_items[item_id] then
				if DEBUG_MASSIVE_SAVES then
					--print("[PlantProfitPredictor] Archiving every listing! You should not do this!")
					if not PPPAuctionHistory.items[item_id] then
						PPPAuctionHistory.items[item_id] = {}
					end
					PPPAuctionHistory.items[item_id][#PPPAuctionHistory.items[item_id]+1] = {C_AuctionHouse.GetReplicateItemInfo(i)}
					if not has_all_data then
						local item = Item:CreateFromItemID(item_id)
						continuables[item] = true
						item:ContinueOnItemLoad(function()
							if not PPPAuctionHistory.items[item_id] then
								PPPAuctionHistory[item_id] = {}
							end
							PPPAuctionHistory.items[item_id][#PPPAuctionHistory.items[item_id]+1] = {C_AuctionHouse.GetReplicateItemInfo(i)}
							continuables[item] = nil
						end)
					end
				else
					if PPPAuctionHistory.items[item_id] then
						if PPPAuctionHistory.items[item_id][10] / PPPAuctionHistory.items[item_id][3] > buyout_price / count then
							PPPAuctionHistory.items[item_id] = {C_AuctionHouse.GetReplicateItemInfo(i)}
						end
					else
						PPPAuctionHistory.items[item_id] = {C_AuctionHouse.GetReplicateItemInfo(i)}
					end
					if not has_all_data then
						local item=Item:CreateFromItemID(item_id)
						continuables[item] = true
						item:ContinueOnItemLoad(function()
							if PPPAuctionHistory.items[item_id][10]/PPPAuctionHistory.items[item_id][3] > buyout_price / count then
								PPPAuctionHistory.items[item] = {C_AuctionHouse.GetReplicateItemInfo(i)}
							end
							continuables[item] = nil
						end)
					end
				end
				relevant_item_count = relevant_item_count + 1
			end
		end		
		print("[PlantProfitPredictor] Finished scanning and found " .. relevant_item_count .. " relevant listings!")
	else
		print("[PlantProfitPredictor] No Auction House data to scan!")
	end
end

function PPPDebugButtonScanNewAHList()
	ScanNewAHList()
end

local first_query = false
local delayed_yet = false
local milled_waited_for_delay_yet = false
-- PPPAuctionHistory = { 
function PPPEventHandler(self, event, arg1, arg2, arg3)
	if event == "ADDON_LOADED" and arg1 == "PlantProfitPredictor" then
		-- check if saved variable exists
		if PPPMillingHistory == nil then
			PPPMillingHistory = {}
		end
		-- print(type(date()))
		if PPPAuctionHistory == nil then
			print("[PlantProfitPredictor] Open up the Auction House to store plant prices!")
			PPPAuctionHistory = {time_of_query=nil, items={}}
		end
		
		if DEBUG_OPEN_ON_STARTUP then
			PPPBaseFrame:Show()
		end
		
		if PPPBaseFrame:IsVisible() then
			UpdatePlantCountFrame() -- run this in case client starts with window open & code ran before saved variables loaded
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
		if arg3==51005 then
			milled_waited_for_delay_yet = false
			current_milling_info = {id=nil, output={},mass_milled=false}
			currently_milling = true
		elseif PPPMillingSpells[arg3] ~= nil then
			milled_waited_for_delay_yet = true
			current_milling_info = {id=PPPMillingSpells[arg3], output={},mass_milled=true}
			for i=1,#PPPPlants[PPPMillingSpells[arg3]].pigments do
				current_milling_info.output[PPPPlants[PPPMillingSpells[arg3]].pigments[i]] = 0
			end
			currently_milling = true
		end
	elseif event=="BAG_UPDATE" then
		if delayed_yet then
			UpdateInventory()
			if PPPBaseFrame:IsVisible() then
				UpdatePlantCountFrame()
			end
		end
	elseif event=="BAG_UPDATE_DELAYED" then
		delayed_yet = true
		if milled_waited_for_delay_yet == true then
			FinishedMillLooting()
		end
	elseif event == "LOOT_CLOSED" then
		-- FinishedMillLooting()
		milled_waited_for_delay_yet = true
	elseif event == "AUCTION_HOUSE_SHOW" then
		-- scan auction house
		print("[PlantProfitPredictor] Scanning Auction House if possible!")
		C_AuctionHouse.ReplicateItems()
		first_query = true		
	elseif event == "REPLICATE_ITEM_LIST_UPDATE" then
		-- list update
		if first_query then
			-- first time AH data updated
			--print(C_AuctionHouse.GetNumReplicateItems())
			print("[PlantProfitPredictor] Updating PPPAuctionHistory!")
			ScanNewAHList()
		end
		first_query = false
	end
end

function PlantProfitPredictor_OnLoad()
	PPPBaseFrame:RegisterEvent("ADDON_LOADED")
	PPPBaseFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	PPPBaseFrame:RegisterEvent("BAG_UPDATE")
	PPPBaseFrame:RegisterEvent("BAG_UPDATE_DELAYED")
	PPPBaseFrame:RegisterEvent("LOOT_CLOSED")
	PPPBaseFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	PPPBaseFrame:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
	PPPBaseFrame:SetScript("OnEvent", PPPEventHandler)
end

local function PlantProfitPredictor_SlashCommand(msg, editbox)
	ToggleFrame();
end

SLASH_PPP1 = "/ppp";
SLASH_PPP2 = "/plantprofitpredictor";
SlashCmdList["PPP"] = PlantProfitPredictor_SlashCommand;
