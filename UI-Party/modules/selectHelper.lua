-- this file stolen from Myxir
local oldSelection = nil
local isAutoSelection = false
local allUnits = {}
local lastFocusedArmy = 0


function SelectBegin()
	oldSelection = GetSelectedUnits() or {}
	isAutoSelection = true
end
function SelectEnd()
	-- TODO
	SelectUnits(oldSelection)
	isAutoSelection = false
end


function getAllUnits()
	return allUnits
end


function AddSelection()
	for _, unit in (GetSelectedUnits() or {}) do
		allUnits[unit:GetEntityId()] = unit
	end
end


function UpdateAllUnits()
	if GetFocusArmy() ~= lastFocusedArmy then
		Reset()
		lastFocusedArmy = GetFocusArmy()
	end

	AddSelection()
	
	-- Add focused (building or assisting), remove dead
	for entityid, unit in allUnits do
		if unit:IsDead() then
			allUnits[entityid] = nil
		elseif unit:GetFocus() and not unit:GetFocus():IsDead() then
			allUnits[unit:GetFocus():GetEntityId()] = unit:GetFocus()
		end
	end
end

local SetHiddenSelect = import("/mods/UMT/modules/select.lua").SetHiddenSelect

function Reset()
	local currentlySelected = GetSelectedUnits() or {}
	-- TODO
	SetHiddenSelect(true)
	isAutoSelection = true
	UISelectionByCategory("ALLUNITS", false, false, false, false)
	AddSelection()
	SelectUnits(currentlySelected)
	isAutoSelection = false
	SetHiddenSelect(false)
end


function IsAutoSelection()
	return isAutoSelection
end