local CurrentPlants = PPPShadowlandsPlants
local CurrentAlchemy = PPPShadowlandsAlchemy
local MAX_NUMBER_MILLING_LIST = 12 -- max number of items displayed on the milling tab
local MAX_NUMBER_PLANTS = 6 -- how many plants can be shown on the plant page at once
local MAX_NUMBER_PIGMENTS = 3 -- how many pigments can be shown at once
local MAX_NUMBER_ALCHEMY_CREATIONS = 1 -- how many alchemy creations can we show per page
local MAX_NUMBER_ALCHEMY_INGREDIENTS = 6 -- how many alchemy ingredients can we show

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

-- PPPMillingHistory = { {id=plant_id, output = {luminous= amount, tranquil=amount, umbral=amount}, mass=was_it_mass } }
local currently_milling = false
local current_milling_info = {}
local last_bag = {}
local current_bag = {}
local function UpdateInventory()
	last_bag = current_bag
	list_of_items = {}
	for k,v in pairs(PPPPlants) do
		list_of_items[k] = 0
	end
	for k,v in pairs(PPPPigments) do
		list_of_items[k] = 0
	end
	current_bag = FindXsInBag(list_of_items)
	
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

local function UpdatePlantCountFrame()
	UpdateInventory()
	
	-- hide everything in case not needed
	for i=1,MAX_NUMBER_PLANTS do
		-- hide pigments too in case they're not needed
		for j=1,MAX_NUMBER_PIGMENTS do
			_G["PPPBaseFramePlantFramePlant" .. i .. "PigmentButton" .. j]:Hide()
		end
		_G["PPPBaseFramePlantFramePlant" .. i]:Hide()
	end
	
	-- update plant count
	for i=1,#CurrentPlants do
		if i <= MAX_NUMBER_PLANTS then
			local frame_name = "PPPBaseFramePlantFramePlant" .. i .. "Name"
			frame = _G[frame_name]
			if frame then
				local possible_millings = math.floor(current_bag[CurrentPlants[i]] / 5)
				_G["PPPBaseFramePlantFramePlant" .. i]:Show()
				_G["PPPBaseFramePlantFramePlant" .. i .. "PlantButton"]:SetNormalTexture(PPPPlants[CurrentPlants[i]].file)
				_G["PPPBaseFramePlantFramePlant" .. i .. "PlantButton"]:SetText(PPPPlants[CurrentPlants[i]].name)
				_G["PPPBaseFramePlantFramePlant" .. i .. "TimesCanMill"]:SetText("x" .. possible_millings)
				frame:SetText(PPPPlants[CurrentPlants[i]].name .. ": " .. current_bag[CurrentPlants[i]])
				
				-- clear arrow text
				_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText("|cffffff00Per milling of 5 plants:|r|cffffffff")
				
				-- set texture and text of pigment buttons
				for j=1,#PPPPlants[CurrentPlants[i]].pigments do
					if j<=MAX_NUMBER_PIGMENTS then
						local current_text = _G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:GetText()
						if current_text ~= nil then
							_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText(current_text .. "\n" .. PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].name)
						else
							_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText(PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].name)
						end
						pigment_frame_name = "PPPBaseFramePlantFramePlant" .. i .. "PigmentButton" .. j
						pigment_frame = _G[pigment_frame_name]
						if pigment_frame then
							pigment_frame:Show()
							pigment_frame:SetText(PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].name)
							pigment_frame:SetNormalTexture(PPPPigments[PPPPlants[CurrentPlants[i]].pigments[j]].file)
							
							-- update pigment estimate
							local total_milled = 0
							local times_milled = 0
							if PPPMillingHistory ~= nil then
								for k,v in pairs(PPPMillingHistory) do
									if v.id == CurrentPlants[i] then
										total_milled = total_milled + v.output[PPPPlants[CurrentPlants[i]].pigments[j]]
										if v.mass_milled then
											times_milled = times_milled + 4
										else
											times_milled = times_milled + 1
										end
									end
								end
							end
							local current_text = _G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:GetText()
							if total_milled ~= 0 then
								local estimation_per_milling = (total_milled/times_milled)
								_G[pigment_frame_name .. "Count"]:SetText(string.format("%.1f",estimation_per_milling*possible_millings))
								_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText(current_text .. ": " .. string.format("%.1f",estimation_per_milling))
							else
								_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText(current_text .. ": 0")
								_G[pigment_frame_name .. "Count"]:SetText("0")
							end
						else
							print("[PlantProfitPredictor.lua:172] Could not locate frame " .. pigment_frame_name)
						end
					else
						print("[PlantProfitPredictor] Too many pigments!")
					end
				end
				local current_text = _G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:GetText()
				_G["PPPBaseFramePlantFramePlant" .. i .. "Arrow"]:SetText(current_text .. "|r")
			else
				print("[PlantProfitPredictor.lua:193] Could not locate frame " .. frame_name)
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
		if PPPBaseFramePlantFrame:IsVisible() then
			UpdatePlantCountFrame()
		end
	end
end

local function UpdateAlchemyPage()
	for i=1,#CurrentAlchemy do
		if i<= MAX_NUMBER_ALCHEMY_CREATIONS then
			local frame_name = "PPPBaseFrameAlchemyFrameCreation" .. i
			local frame = _G[frame_name]
			if frame then
				frame:Show()
				_G[frame_name .. "Button"]:SetNormalTexture(PPPAlchemyCreations[CurrentAlchemy[i]].file)
				_G[frame_name .. "Button"]:SetText(PPPAlchemyCreations[CurrentAlchemy[i]].name)
				_G[frame_name .. "Name"]:SetText(PPPAlchemyCreations[CurrentAlchemy[i]].name)
				
				-- run through each ingredient
				local ingredient_number = 1
				for k,v in pairs(PPPAlchemyCreations[CurrentAlchemy[i]].ingredients) do
					if ingredient_number <= MAX_NUMBER_ALCHEMY_INGREDIENTS then
						local ingredient_frame_name = frame_name .. "IngredientButton" .. ingredient_number
						ingredient_frame = _G[ingredient_frame_name]
						if ingredient_frame then
							ingredient_frame:Show()
							ingredient_frame:SetNormalTexture(PPPPlants[k].file)
							ingredient_frame:SetText(PPPPlants[k].name)
							_G[ingredient_frame_name .. "Count"]:SetText(v)
						else
							print("[PlantProfitPredictor] Could not locate frame " .. frame_name .. "IngredientButton" .. ingredient_number)
						end
						ingredient_number = ingredient_number + 1
					else
						print("[PlantProfitPredictor] TOO MANY INGREDIENTS!!!")
					end
				end
			else
				print("[PlantProfitPredictor] Could not locate frame " .. frame_name)
			end
		else
			print("[PlantProfitPredictor] NEED NEW PAGE!!!")
		end
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
	FauxScrollFrame_Update(PPPBaseFrameMillingFrameScrollFrame,#PPPMillingHistory,12,25) -- (frame, total number, number shown, height)
	for line=1,12 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(PPPBaseFrameMillingFrameScrollFrame)
		if lineplusoffset <= #PPPMillingHistory then
			local plant_name = nil
			local plant_file, plant_id
			for k,v in pairs(PPPPlants) do
				if k == PPPMillingHistory[lineplusoffset].id then
					_G["PPPBaseFrameMillingFrameEntry" .. line .. "PlantButton"]:SetText(v.name)
					_G["PPPBaseFrameMillingFrameEntry" .. line .. "PlantButton"]:SetNormalTexture(v.file)
					if PPPMillingHistory[lineplusoffset].mass_milled then
						_G["PPPBaseFrameMillingFrameEntry" .. line .. "Name"]:SetText(v.name .. " x20")
					else
						_G["PPPBaseFrameMillingFrameEntry" .. line .. "Name"]:SetText(v.name .. " x5")
					end
				end
			end
			
			local pigment_int = 1
			for k,v in pairs(PPPMillingHistory[lineplusoffset].output) do
				_G["PPPBaseFrameMillingFrameEntry" .. line .. "PigmentButton" .. pigment_int .. "Count"]:SetText(v)
				_G["PPPBaseFrameMillingFrameEntry" .. line .. "PigmentButton" .. pigment_int]:SetNormalTexture(PPPPigments[k].file)
				_G["PPPBaseFrameMillingFrameEntry" .. line .. "PigmentButton" .. pigment_int]:SetText(PPPPigments[k].name)
				pigment_int = pigment_int + 1
			end
			_G["PPPBaseFrameMillingFrameEntry" .. line]:Show()
		else
			_G["PPPBaseFrameMillingFrameEntry" .. line]:Hide()
		end
	end
end

local delayed_yet = false
local milled_waited_for_delay_yet = false
function PPPEventHandler(self, event, arg1, arg2, arg3)
	if event == "ADDON_LOADED" and arg1 == "PlantProfitPredictor" then
		-- check if saved variable exists
		if PPPMillingHistory == nil then
			PPPMillingHistory = {}
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
	end
end

function PlantProfitPredictor_OnLoad()
	PPPBaseFrame:RegisterEvent("ADDON_LOADED")
	PPPBaseFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	PPPBaseFrame:RegisterEvent("BAG_UPDATE")
	PPPBaseFrame:RegisterEvent("BAG_UPDATE_DELAYED")
	PPPBaseFrame:RegisterEvent("LOOT_CLOSED")
	PPPBaseFrame:SetScript("OnEvent", PPPEventHandler)
end

local function PlantProfitPredictor_SlashCommand(msg, editbox)
	ToggleFrame();
end

SLASH_PPP1 = "/ppp";
SLASH_PPP2 = "/plantprofitpredictor";
SlashCmdList["PPP"] = PlantProfitPredictor_SlashCommand;
