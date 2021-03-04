PPPListOfAHItems = {}
for k,v in pairs(PPPPlants) do
	PPPListOfAHItems[k]=true
end
for k,v in pairs(PPPPigments) do
	PPPListOfAHItems[k]=true
end
for k,v in pairs(PPPAlchemyCreations) do
	PPPListOfAHItems[k]=true
end
for k,v in pairs(PPPInks) do
	PPPListOfAHItems[k]=true
end
for k,v in pairs(PPPInscriptionCreations) do
	PPPListOfAHItems[k]=true
end

function PPPFindXsInBag(list)
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

function PPPGetFormattedGoldString(starting)
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

function PPPCostPerUnit(item)
	if item and item[3] and item[10] then
		return item[10]/item[3]
	else
		print("[PlantProfitPredictor] Invalid PPPCostPerUnit(" .. (item or "nil") .. ")!")
	end
end

-- PPPMillingHistory = { {id=plant_id, output = {luminous= amount, tranquil=amount, umbral=amount}, mass=was_it_mass } }
PPPCurrentlyMilling = false
PPPCurrentMillingInfo = {}
PPPCurrentBag = {}
local last_bag = {}
function PPPUpdateInventory()
	last_bag = PPPCurrentBag
	PPPCurrentBag = PPPFindXsInBag(PPPListOfAHItems)
	
	-- check for any differences
	if PPPCurrentlyMilling then
		for id, count in pairs(PPPCurrentBag) do
			if last_bag[id] ~= count then
				if PPPCurrentMillingInfo.id == nil then
					if PPPPlants[id] then
						PPPCurrentMillingInfo.id=id
						for i=1,#PPPPlants[id].pigments do
							PPPCurrentMillingInfo.output[PPPPlants[id].pigments[i]] = 0
						end
					end
				else
					if PPPCurrentMillingInfo.id ~= nil then
						for k,v in pairs(PPPCurrentMillingInfo.output) do
							if id == k then
								PPPCurrentMillingInfo.output[id] = count - last_bag[id]
							end
						end
					end
				end
			end
		end
	end
end

function PPPStoredAHHasAllIngredients(creation)
	local has_all = true
	for k,v in pairs(creation.ingredients) do
		if not PPPAuctionHistory.items[k] then
			has_all = false
			print("[PlantProfitPredictor] I do not have an item ID " .. k .. " stored!")
		end
	end
	return has_all
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

function PPPGotoInscriptionPage()
	print("[PlantProfitPredictor] Going to Inscription Page!")
end


local function ToggleFrame()
	if PPPBaseFrame:IsVisible() then
		PPPBaseFrame:Hide()
	else
		PPPUpdatePlantCountFrame()
		PPPBaseFrame:Show()
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
			if PPPListOfAHItems[item_id] then
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
		
		if true then
			PPPBaseFrame:Show()
		end
		
		if PPPBaseFrame:IsVisible() then
			PPPUpdatePlantCountFrame() -- run this in case client starts with window open & code ran before saved variables loaded
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
		PPPMillingSpellcast(arg3)
	elseif event=="BAG_UPDATE" then
		if delayed_yet then
			PPPUpdateInventory()
			if PPPBaseFrame:IsVisible() then
				PPPUpdatePlantCountFrame()
			end
		end
	elseif event=="BAG_UPDATE_DELAYED" then
		delayed_yet = true
		PPPMillingBagUpdateDelayed()
	elseif event == "LOOT_CLOSED" then
		-- FinishedMillLooting()
		PPPMillingLootClosed()
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
