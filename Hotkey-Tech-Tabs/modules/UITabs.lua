local LUGConstr = import('/lua/ui/game/construction.lua')


local lastTab = 0
local currTab = 0

function SelectTab(tab)
	if LUGConstr.controls.constructionGroup:IsHidden() then return end
	currTab = LUGConstr.GetCurrentTechTab()

	if tab == currTab then 
		tab = lastTab
	else
		lastTab = currTab
	end

	local ret = LUGConstr.SetCurrentTechTab(tab)
	if ret then
		PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Tab_Click_02'}))
		currTab = LUGConstr.GetCurrentTechTab()
	end

	return ret
end

function CycleTabs(dir)
	if LUGConstr.controls.constructionGroup:IsHidden() then return end
	dir = dir or false
	local nextTab = LUGConstr.GetCurrentTechTab()

	if dir then
		repeat
			nextTab = nextTab + 1
			if(nextTab > 5) then nextTab = 1 end
		until(SelectTab(nextTab) == true)
	else
		repeat
			nextTab = nextTab - 1
			if(nextTab < 1) then nextTab = 5 end
		until(SelectTab(nextTab) == true)
	end

end

function OnChangeDetected()
	local a, b = pcall(function()
		LOG("HTT-OnChangeDetected")
	end)
	if not a then LOG("UI-OnChangeDetected RESULT: ", a, b) end
end
OnChangeDetected()
