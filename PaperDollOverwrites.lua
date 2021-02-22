PPPSidebars = {
	{
		name="Plants";
		frame="PPPPlantFrame";
		icon = 136065;
		disabledTooltip = nil;
		IsActive = function() return true; end
	},{
		name="Milling";
		frame="PPPMillingFrame";
		icon = 236229;
		disabledTooltip = nil;
		IsActive = function() return true; end
	},
};

function PPPUpdateSidebarTabs()
	for i = 1, #PPPSidebars do
		local tab = _G["PPPSidebarButton"..i];
		if (tab) then
			if (_G[PPPSidebars[i].frame]:IsShown()) then
				tab.Hider:Hide();
				tab.Highlight:Hide();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.78906250, 0.95703125);
			else
				tab.Hider:Show();
				tab.Highlight:Show();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000);
				if ( PPPSidebars[i].IsActive() ) then
					tab:Enable();
				else
					tab:Disable();
				end
			end
		end
	end
end

function PPPSetSidebar(self, index)
	if (not _G[PPPSidebars[index].frame]:IsShown()) then
		for i = 1, #PPPSidebars do
			_G[PPPSidebars[i].frame]:Hide();
		end
		_G[PPPSidebars[index].frame]:Show();
		PaperDollFrame.currentSideBar = _G[PPPSidebars[index].frame];
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		PPPUpdateSidebarTabs();
	end
end

function PPPSidebarTab_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PPPSidebars[self:GetID()].name);
	if not self:IsEnabled() and self.disabledTooltip then
		local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
		GameTooltip_AddErrorLine(GameTooltip, disabledTooltipText, true);
	end
	GameTooltip:Show();
end