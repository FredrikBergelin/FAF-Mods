local GameTick = GameTick

local modFolder = 'McBoomsMod'

local ArmyManager
local MexesManager
local UnitManager

local MEX_MANAGER_SORTING = false

local DEBUG_MODE = false
local ForcedUpdateNextTick = false

function ForcedUpdateUnits()
	ForcedUpdateNextTick = true
end

local debug_counter = 0

local function onArmyChanged()
	--inform the manager (and ui?) in the correct order
	MexesManager:clearAll()
	UnitManager:reset()
end

function Init()
	-- Call imports here so it doesnt mess up trying to load mod files in the hook
	ArmyManager = import('/mods/' .. modFolder .. '/modules/army/ArmyManager.lua').GetArmyManager()
	MexesManager = import('/mods/' .. modFolder .. '/modules/mex/MexesManager.lua').GetMexesManager()
	UnitManager = import('/mods/' .. modFolder .. '/modules/UnitManager.lua').GetUnitManager()

	MexesManager:setPerformSorting(MEX_MANAGER_SORTING)
	ArmyManager:addOnArmyChangedCallback(onArmyChanged)
end

function UpdateBeat()
	ArmyManager:update()
	UnitManager:update()
	MexesManager:update()

	if DEBUG_MODE then
		local tick = GameTick()
		if tick - 20 > debug_counter then
			debug_counter = tick
			UnitManager:printDebug()
			MexesManager:printDebug()
		end
	end
end