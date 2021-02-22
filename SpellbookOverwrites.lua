local currentTab = nil

PPPLineTabs = {
	{name="Plants",icon=136065,frames={"PPPBaseFramePlantFrame"},func="GotoPlantPage"},
	{name="Milling History",icon=236229,frames={"PPPBaseFrameMillingFrame"},func="GotoMillingPage"},
}

function PPPLineTab_OnClick(self)
	local id = self:GetID()
	if ( currrentTab ~= id ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
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
						print("[PlantProfitPredictor.SpellbookOverwrites:27] Could not find page " .. PPPLineTabs[i].frames[j] .. " (" .. i .. "." .. j .. ")!")
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
						print("[PlantProfitPredictor.SpellbookOverwrites:44] Could not find page " .. PPPLineTabs[i].frames[j] .. " (" .. i .. "." .. j .. ")!")
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
end
