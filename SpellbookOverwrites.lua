local MAX_NUMBER_INNER_TABS = 2

local currentTab = nil

PPPLineTabs = {
	{name="Milling",icon=236229,frames={"PPPBaseFrameMillingFrame"},base_frame="PPPBaseFrameMillingFrame",func="PPPGotoPlantPage",
	 inner_tabs={{frame="Main",text="Predictions"},{frame="Log",text="Log"}}},
	--{name="Milling History",icon=236229,frames={"PPPBaseFrameMillingLogFrame"},func="PPPGotoMillingPage"},
	{name="Alchemy",icon=136240,frames={"PPPBaseFrameAlchemyFrame"},base_frame="PPPBaseFrameAlchemyFrame",func="PPPGotoAlchemyPage",
	 inner_tabs={{frame="Main",text="Creations"}}},
	{name="Debug",icon=136243,frames={"PPPBaseFrameDebugFrame"},base_frame="PPPBaseFrameDebugFrame",func="PPPGotoDebugPage",
	 inner_tabs={{frame="Main",text="Debug"}}},
}

local current_inner_tab = nil
local function ChangeInnerTab(new_page)
	new_page_id = new_page:GetID()
	if not new_page_id then
		print("[PlantProfitPredictor] nil new_page_id!")
	end
	new_page:Disable()
	if current_inner_tab then
		local tab_button = _G["PPPBaseFrameInnerTabButton" .. current_inner_tab]
		PanelTemplates_DeselectTab(tab_button)
		tab_button:Enable()
	end
	PanelTemplates_SelectTab(new_page)
	if current_inner_tab ~= new_page_id then
		if PPPLineTabs[currentTab].inner_tabs[current_inner_tab] then
			old_inner_tab = _G[PPPLineTabs[currentTab].base_frame .. PPPLineTabs[currentTab].inner_tabs[current_inner_tab].frame]
			if old_inner_tab then
				_G[PPPLineTabs[currentTab].base_frame .. PPPLineTabs[currentTab].inner_tabs[current_inner_tab].frame]:Hide()
			end
		end
		if PPPLineTabs[currentTab].inner_tabs[new_page_id] then
			_G[PPPLineTabs[currentTab].base_frame .. PPPLineTabs[currentTab].inner_tabs[new_page_id].frame]:Show()
		else
			print("[PlantProfitPredictor] Invalid inner_tab ID " .. new_page_id .. " for frame " .. PPPLineTabs[currentTab].base_frame)
		end
	end
	current_inner_tab = new_page_id
end

local function ResetTabs()
	for i=1,MAX_NUMBER_INNER_TABS do
		local current_tab = _G["PPPBaseFrameInnerTabButton" .. i]
		PanelTemplates_DeselectTab(current_tab)
		
		if PPPLineTabs[currentTab].inner_tabs[i] then
			current_tab:SetText(PPPLineTabs[currentTab].inner_tabs[i].text)
			current_tab:Show()
		else
			current_tab:Hide()
		end
	end
	current_inner_tab = nil
end

function PPPTabButton_OnClick(self)
	--ToggleSpellBook(self.bookType);
	ChangeInnerTab(self)
end

local saved_position = {} -- saves what inner tab of a tab was last used
function PPPLineTab_OnClick(self)
	local id = self:GetID()
	if ( currrentTab ~= id ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
		
		-- hide all inner tabs
		if currentTab then
			saved_position[currentTab] = current_inner_tab
			for i=1,#PPPLineTabs[currentTab].inner_tabs do
				_G[PPPLineTabs[currentTab].base_frame .. PPPLineTabs[currentTab].inner_tabs[i].frame]:Hide()
			end
		end
		
		currentTab = id
		
		for i=1,#PPPLineTabs do
			if i ~= id then
				-- stop that yellow
				_G["PPPLineTab"..i]:SetChecked(false)
				
				-- hide the content of that page
				for j=1,#PPPLineTabs[i].frames do
					local page = _G[PPPLineTabs[i].frames[j]]
					if page then
						if page:IsShown() then
							page:Hide()
						end
					else
						print("[PlantProfitPredictor.SpellbookOverwrites] Could not find page " .. PPPLineTabs[i].frames[j] .. " (" .. i .. "." .. j .. ")!")
					end
				end
			else
				-- begin that yellow
				_G["PPPLineTab"..i]:SetChecked(true)
				
				-- show the content of the page
				for j=1,#PPPLineTabs[i].frames do
					local page = _G[PPPLineTabs[i].frames[j]]
					if page then
						-- update whatever info is needed
						_G[PPPLineTabs[i].func]()
						
						-- show it
						page:Show()
					else
						print("[PlantProfitPredictor.SpellbookOverwrites] Could not find page " .. PPPLineTabs[i].frames[j] .. " (" .. i .. "." .. j .. ")!")
					end
				end
			end
		end
	else
		self:SetChecked(true)
	end

	-- Stop tab flashing
	if ( self ) then
		local tabFlash = _G[self:GetName().."Flash"];
		if ( tabFlash ) then
			tabFlash:Hide();
		end
	end
	
	ResetTabs()
	if saved_position[currentTab] then
		ChangeInnerTab(_G["PPPBaseFrameInnerTabButton" .. saved_position[currentTab]])
	else
		ChangeInnerTab(PPPBaseFrameInnerTabButton1)
	end
end
