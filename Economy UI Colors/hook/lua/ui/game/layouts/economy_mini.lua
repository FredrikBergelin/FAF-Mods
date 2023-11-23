local originalSetLayout = SetLayout

function SetLayout()
	originalSetLayout()
    local GUI = import('/lua/ui/game/economy.lua').GUI
	
    local function SetColors(group)
		group.income:SetColor(GUI.incomeColor)
		group.expense:SetColor(GUI.expenseColor)
	end
	
	SetColors(GUI.energy)
	SetColors(GUI.mass)
end
