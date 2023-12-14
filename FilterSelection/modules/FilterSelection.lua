-- TEMP line

local GetAllUnits = import('/mods/FilterSelection/modules/allunits.lua').GetAllUnits
local worldView = import('/lua/ui/game/worldview.lua').viewLeft
local Prefs = import('/lua/user/prefs.lua')
local Filters = {}
local savedFilters = {}

local TechCategoryList = {
	TECH1 = 'T1 ',
	TECH2 = 'T2 ',
	TECH3 = 'T3 ',
	EXPERIMENTAL = 'EXP ',
}

function AddFilterSelection(group, add)
	local selectedUnits = GetSelectedUnits() or {}

	if table.getn(selectedUnits) == 0 then
		print("No units selected")
		return
	end

	local Names = {}

	if not add then
		Filters[group] = {}
	end

	for _,unit in selectedUnits do
		local id = unit:GetEntityId()
		local bp = unit:GetBlueprint()

		if not isInTable(Filters[group], bp.BlueprintId) then
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
end

function FilterSelect(group, allOnMap)
	if Filters[group] == nil then return AddFilterSelection(group) end
	local allUnits = GetAllUnits()
	local selectUnits = {}
	for _,unit in allUnits do
		local id = unit:GetEntityId()
		local bp = unit:GetBlueprint().BlueprintId

		if isInTable(Filters[group], bp) and (allOnMap or worldView:GetScreenPos(unit)) then
			table.insert(selectUnits, unit)
		end
	end

	SelectUnits(selectUnits)
end

function SaveFilterSelection(group)
	-- print("Save to Filter " .. group)
	-- local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction
	-- WARN("FilterSelection"..currentFaction)
    -- -- Prefs.SetToCurrentProfile("FilterSelection"..Factions[currentFaction + 1], Filters)
    -- Prefs.SetToCurrentProfile("FilterSelection"..currentFaction, Filters)
end

function isInTable(tabl, item)
	for _, tableItem in tabl do
		if tableItem == item then return true end
	end
	return false
end

function LoadPrefs()
	local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction
	WARN("LoadPrefs FilterSelection"..currentFaction)
    savedFilters = Prefs.GetFromCurrentProfile("FilterSelection"..currentFaction) or {}
	-- Filters = savedFilters
end
