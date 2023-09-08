local isAutoSelection = false
local allUnits = {}
local lastFocusedArmy = 0

function UpdateAllUnits()
	if GetFocusArmy() != lastFocusedArmy then
		Reset()
		lastFocusedArmy = GetFocusArmy()
	end

	AddSelection()

	-- Add focused (building or assisting)
	for _, unit in allUnits do
		if not unit:IsDead() and unit:GetFocus() and not unit:GetFocus():IsDead() then
			allUnits[unit:GetFocus():GetEntityId()] = unit:GetFocus()
		end
	end

	-- Remove dead
	for entityid, unit in allUnits do
		if unit:IsDead() then
			allUnits[entityid] = nil
		end
	end
end

local SetHiddenSelect = import("/mods/UMT/modules/select.lua").SetHiddenSelect

function Reset()
	local currentlySelected = GetSelectedUnits() or {}
	SetHiddenSelect(true)
	isAutoSelection = true
	--UISelectionByCategory("AIR", false, false, false, false)
	AddSelection()
	-- TODO
	SelectUnits(currentlySelected)
	isAutoSelection = false
	SetHiddenSelect(false)
end

function AddSelection()
	for _, unit in (GetSelectedUnits() or {}) do
		allUnits[unit:GetEntityId()] = unit
	end
end

function GetAllUnits()
	return allUnits
end

function IsAutoSelection()
	return isAutoSelection
end
