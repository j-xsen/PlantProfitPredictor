local MAX_NUMBER_ALCHEMY_CREATIONS = 4 -- how many alchemy creations can we show per page
local MAX_NUMBER_ALCHEMY_INGREDIENTS = 6 -- how many alchemy ingredients can we show
local CurrentAlchemy = PPPShadowlandsAlchemy
local current_alchemy_page = 1
local function UpdateAlchemyPage()
	PPPUpdateInventory()
	
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
						plant_button_text = plant_button_text .. "\n" .. PPPGetFormattedGoldString(FindCheapest(creation_id))
					else
					
						plant_button_text = plant_button_text .. "\n" .. PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[creation_id]))
						if PPPCurrentBag[creation_id] then
							plant_button_text = plant_button_text .. "\n\n|cffffff00Estimated profits:\n"..PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[creation_id])*PPPCurrentBag[creation_id])
						end
					end
				end
				_G[frame_name .. "CreationButton"]:SetText(plant_button_text)
				_G[frame_name .. "Name"]:SetText(creation_table.name)
				local ah_all_ingredients_stored = PPPStoredAHHasAllIngredients(creation_table)
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
						local ingredient_cost = PPPCostPerUnit(PPPAuctionHistory.items[k])*v
						arrow_text = arrow_text .."\n".. PPPPlants[k].name .. ": " .. PPPGetFormattedGoldString(ingredient_cost)
						total_creation_cost = total_creation_cost + ingredient_cost
					end
					
					local can_create_with_this_ingredient = math.floor(PPPCurrentBag[k] / v)
					if ingredient_number == 1 or can_create_with_this_ingredient < max_can_create then
						max_can_create = can_create_with_this_ingredient
					end
					if ingredient_number <= MAX_NUMBER_ALCHEMY_INGREDIENTS then
						local ingredient_frame_name = frame_name .. "IngredientButton" .. ingredient_number
						ingredient_frame = _G[ingredient_frame_name]
						if ingredient_frame then
							ingredient_frame:Show()
							ingredient_frame:SetNormalTexture(PPPPlants[k].file)
							ingredient_frame:SetText(PPPPlants[k].name .. "\n|cffffffffTotal in bags: " .. PPPCurrentBag[k] .. "|r")
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
					arrow_text = arrow_text .. "\n\nTotal: " .. PPPGetFormattedGoldString(total_creation_cost)
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
function PPPGotoAlchemyPage()
	-- stuff to do when going to alchemy page
	UpdateAlchemyPage()
end