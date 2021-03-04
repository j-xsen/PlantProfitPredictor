local CurrentPlants = PPPShadowlandsPlants
local MAX_NUMBER_MILLING_LIST = 12 -- max number of items displayed on the milling tab
local MAX_NUMBER_PLANTS = 6 -- how many plants can be shown on the plant page at once
local MAX_NUMBER_PIGMENTS = 3 -- how many pigments can be shown at once
local function FinishedMillLooting()
	if PPPCurrentlyMilling then
		table.insert(PPPMillingHistory, 1, PPPCurrentMillingInfo)
		PPPCurrentlyMilling = false
		PPPCurrentMillingInfo = {}
		PPPScrollBarUpdate()
		if PPPBaseFrameMillingFrame:IsVisible() then
			PPPUpdatePlantCountFrame()
		end
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
function PPPUpdatePlantCountFrame()
	PPPUpdateInventory()
	
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
				local possible_millings = math.floor(PPPCurrentBag[CurrentPlants[i]] / 5)
				_G["PPPBaseFrameMillingFrameMainPlant" .. i]:Show()
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "PlantButton"]:SetNormalTexture(PPPPlants[CurrentPlants[i]].file)
				local plant_button_text = PPPPlants[CurrentPlants[i]].name
				if PPPAuctionHistory and PPPAuctionHistory.items[CurrentPlants[i]] then
					if DEBUG_MASSIVE_SAVES then
						plant_button_text = plant_button_text .. "\n" .. PPPGetFormattedGoldString(FindCheapest(CurrentPlants[i]))
					else
						plant_button_text = plant_button_text .. "\n" .. PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[CurrentPlants[i]]))..
						                    "\n\n|cffffff00Estimated profits:|r\n" .. PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[CurrentPlants[i]])*PPPCurrentBag[CurrentPlants[i]])
					end
				end
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "PlantButton"]:SetText(plant_button_text)
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "TimesCanMill"]:SetText("x" .. possible_millings)
				frame:SetText(PPPPlants[CurrentPlants[i]].name .. ": " .. PPPCurrentBag[CurrentPlants[i]])
				
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
								pigment_frame:SetText(PPPPigments[pigment_item_id].name .. "\n" .. PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[pigment_item_id])))
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
									local estimated_profit = math.floor(estimation_per_milling*possible_millings)*PPPCostPerUnit(PPPAuctionHistory.items[pigment_item_id])
									estimated_pigment_profit = estimated_pigment_profit + estimated_profit
									pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffff00Estimated profits:\n"..PPPGetFormattedGoldString(estimated_profit))
									if PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink] then
										local estimated_i_profit = math.floor(estimation_per_milling*possible_millings)*PPPCostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])
										estimated_ink_profit = estimated_ink_profit + estimated_i_profit
										pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffd200"..PPPInks[PPPPigments[pigment_item_id].ink].name.."\n"..PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])))
										pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffff00Estimated profits as inks:\n"..PPPGetFormattedGoldString(estimated_i_profit))
									end
								end
								_G[pigment_frame_name .. "Count"]:SetText(string.format("%.1f",estimation_per_milling*possible_millings))
								_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. ": " .. string.format("%.1f",estimation_per_milling))
							else
								if PPPAuctionHistory and PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink] then
									pigment_frame:SetText(pigment_frame:GetText() .. "\n\n|cffffd200"..PPPInks[PPPPigments[pigment_item_id].ink].name.."\n"..PPPGetFormattedGoldString(PPPCostPerUnit(PPPAuctionHistory.items[PPPPigments[pigment_item_id].ink])))
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
				local additional_text = "|r\n\n|cffffff00Estimated profits from pigments:|r\n|cffffffff" .. PPPGetFormattedGoldString(estimated_pigment_profit) .. "|r"..
				                        "|r\n\n|cffffff00Estimated profits from inks:|r\n|cffffffff" .. PPPGetFormattedGoldString(estimated_ink_profit).."|r"
				_G["PPPBaseFrameMillingFrameMainPlant" .. i .. "Arrow"]:SetText(current_text .. additional_text)
			else
				print("[PlantProfitPredictor] Could not locate frame " .. frame_name)
			end
		else
			print("[PlantProfitPredictor] NEED NEW PAGE!!!")
		end
	end
end

function PPPGotoMillingPage()
	-- update information when going to milling page
	PPPScrollBarUpdate()
end
function PPPGotoPlantPage()
	PPPUpdatePlantCountFrame()
end

local milled_waited_for_delay_yet = false
function PPPMillingSpellcast(spell_id)
	if spell_id==51005 then
		milled_waited_for_delay_yet = false
		PPPCurrentMillingInfo = {id=nil, output={},mass_milled=false}
		PPPCurrentlyMilling = true
	elseif PPPMillingSpells[spell_id] ~= nil then
		milled_waited_for_delay_yet = true
		PPPCurrentMillingInfo = {id=PPPMillingSpells[spell_id], output={},mass_milled=true}
		for i=1,#PPPPlants[PPPMillingSpells[spell_id]].pigments do
			PPPCurrentMillingInfo.output[PPPPlants[PPPMillingSpells[spell_id]].pigments[i]] = 0
		end
		PPPCurrentlyMilling = true
	end
end
function PPPMillingLootClosed()
	milled_waited_for_delay_yet = true
end
function PPPMillingBagUpdateDelayed()
	if milled_waited_for_delay_yet == true then
		FinishedMillLooting()
	end
end
