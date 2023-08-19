local GetAllUnits = import('/mods/FilterSelection/modules/allunits.lua').GetAllUnits
local worldView = import('/lua/ui/game/worldview.lua').viewLeft
local Filters = {}

local TechCategoryList = {
	TECH1 = 'T1 ',
	TECH2 = 'T2 ',
	TECH3 = 'T3 ',
	EXPERIMENTAL = 'EXP ',
}

function AddFilterSelection(group)
	local SelectedUnits = GetSelectedUnits()
	local Names = {}
	Filters[group] = {}

	for _,unit in SelectedUnits do
		local id = unit:GetEntityId()
		local bp = unit:GetBlueprint()
		--LOG(repr(bp))
		if not isInTable(Filters[group],bp.BlueprintId) then
			Filters[group][id] = bp.BlueprintId
			Names[id] = TechCategoryList[bp.TechCategory]..LOC(bp.Description)
			--Names[id] = bp.General.UnitName
		end
	end
	message = 'Filter contains: '
	for _,unitName in Names do
		message = message..unitName..', '
	end
	print(message)
	--PrintText(message,28,"ff9161ff",1, 'centerbottom')
end

function FilterSelect(group)
	if Filters[group] == nil then return AddFilterSelection(group) end
	local allUnits = GetAllUnits()
	local SelectedUnits = {}
	for _,unit in allUnits do
		local id = unit:GetEntityId()
		local bp = unit:GetBlueprint().BlueprintId
		--LOG(repr(bp))
		if worldView:GetScreenPos(unit) and isInTable(Filters[group],bp) then
			table.insert(SelectedUnits,unit)
			--SelectedUnits[id] = unit
			--SelectedUnits[id] = id
		end
	end
	SelectUnits(SelectedUnits)
end

function isInTable(tabl,item)
	for _,tableItem in tabl do
		if tableItem == item then return true end
	end
	return false
end
