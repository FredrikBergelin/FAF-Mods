local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldSetLayout = SetLayout
function SetLayout()
	oldSetLayout()
	
	if UIP.Enabled() and UIP.GetSetting("rearrangeBottomPanes") then 
		local control = import('/lua/ui/game/unitviewDetail.lua').View
		LayoutHelpers.AtBottomIn(control, control:GetParent(), 0)
		LayoutHelpers.AtLeftIn(control, control:GetParent(), 0)
		if (control.Description ~= nil) then
			control.Description.Left:Set(function() return 0 end)
			control.Description.Bottom:Set(function() return control.BG.Bottom() - 110 end)
			control.Description.Width:Set(329)
		else
			-- user options may have this turned off, in which case there would be null ref ex
		end
	end
end
