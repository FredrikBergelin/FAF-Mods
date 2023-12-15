local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions') -- Eg: ['Cycle next, defaults to closest'] = { action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()', ... },
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap') -- Eg: Tab = 'Cycle next, defaults to closest',

local Functions = import("/mods/MoreHotkeyLayouts/modules/functions.lua")
local AnyUnitSelected = import('/mods/common/modules/misc.lua').AnyUnitSelected
local CreateOrContinueSelection = import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection

local subHotkeys = nil
local subHotkey = nil

local storedUniqueIdentifier
local lastClickTime = -9999

local function Hotkey(hotkey, func)
	subHotkey = subHotkeys[hotkey]
	local currentTime = GetSystemTimeSeconds()
	local diffTime = currentTime - lastClickTime
	local decay = 0.002 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
	local inTime = diffTime < decay
	lastClickTime = currentTime

	if subHotkey ~= nil and inTime then
		ForkThread(subHotkey)
	else
		subHotkeys = nil
		func(hotkey)
	end
end

local function SubHotkeys(obj)
	subHotkeys = obj
end

local function SubHotkey(hotkey, func)
    local currentTime = GetSystemTimeSeconds()
	local diffTime = currentTime - lastClickTime
	local decay = 0.001 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')

	if storedUniqueIdentifier == hotkey and diffTime < decay then
		subHotkey = subHotkeys[hotkey]
	end

	storedUniqueIdentifier = hotkey

	func(hotkey)
end

local function AnyHasCategory(category)
    local units = GetSelectedUnits()

	if units == nil then
		return false
	end

    for id, unit in units do
		if EntityCategoryContains(category, unit) then
			return true
		end
	end

	return false
end

local function AllHaveCategory(category)
    local units = GetSelectedUnits()

	if units == nil then
		return false
	end

    for id, unit in units do
		if not EntityCategoryContains(category, unit) then
			return false
		end
	end

	return true
end

local isReplay = import("/lua/ui/game/gamemain.lua").GetReplayState()

local GetUpgradesOfUnit = false
if not isReplay then
	GetUpgradesOfUnit = import("/lua/ui/game/hotkeys/upgrade-structure.lua").GetUpgradesOfUnit
end

local TablEmpty = table.empty

local function AnyUnitCanUpgrade()
	local units = GetSelectedUnits()

	if isReplay then
		return false
	end

	if units == nil then
		return false
	end

	for id, unit in units do
		local buildableStructures = GetUpgradesOfUnit(unit)
		if buildableStructures and not TablEmpty(buildableStructures) then
			return true
		end
	end

	return false
end

-- ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("AlertExtended")'
-- ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("Util")'
-- ConExecute 'UI_Lua import("/mods/ChatWheel/modules/CWMain.lua").call()'
-- ConExecute 'UI_Lua import("/lua/ui/game/objectivedetail.lua").ToggleDisplay()'
-- ConExecute 'UI_Lua import("/lua/ui/game/connectivity.lua").CreateUI()'
-- ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTab("main")'

local customKeyMap = {

	['Esc'] = function() Hotkey('Esc', function(hotkey)
		print("Soft stop")
		ConExecute 'UI_Lua import("/lua/ui/game/orders.lua").SoftStop()'

		SubHotkeys({
			['Esc'] = function() SubHotkey('Esc', function(hotkey)
				print("Stop")
				ConExecute 'UI_Lua import("/lua/ui/game/orders.lua").Stop()'
			end) end,
		})
	end) end,
	['Shift-Esc'] = function() Hotkey('Shift-Esc', function(hotkey)
		-- TODO: Not working, also change hotkey?
		-- print("Undo last queued order")
		-- ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").UndoLastQueueOrder()'
	end) end,

	F1 = function() Hotkey('F1', function(hotkey)
		print("Onscreen Filter 1")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(1, false)'

		SubHotkeys({
			F1 = function() SubHotkey('F1', function(hotkey)
				print("All Filter 1")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(1, true)'
			end) end,
		})
	end) end,
	["Shift-F1"] = function() Hotkey('Shift-F1', function(hotkey)
		print("Add Onscreen Filter 1")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(1, false)'
		end)

		SubHotkeys({
			["Shift-F1"] = function() SubHotkey('Shift-F1', function(hotkey)
				print("Add All Filter 1")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(1, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F1"] = function() Hotkey('Ctrl-F1', function(hotkey)
		print("Create Filter 1")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(1, false)'

		SubHotkeys({
			["Ctrl-F1"] = function() SubHotkey('Ctrl-F1', function(hotkey)
				print("Save Filter 1")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(1, true)'
			end) end,
		})
	end) end,

	F2 = function() Hotkey('F2', function(hotkey)
		print("Onscreen Filter 2")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(2, false)'

		SubHotkeys({
			F2 = function() SubHotkey('F2', function(hotkey)
				print("All Filter 2")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(2, true)'
			end) end,
		})
	end) end,
	["Shift-F2"] = function() Hotkey('Shift-F2', function(hotkey)
		print("Add Onscreen Filter 2")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(2, false)'
		end)

		SubHotkeys({
			["Shift-F2"] = function() SubHotkey('Shift-F2', function(hotkey)
				print("Add All Filter 2")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(2, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F2"] = function() Hotkey('Ctrl-F2', function(hotkey)
		print("Create Filter 2")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(2, false)'

		SubHotkeys({
			["Ctrl-F2"] = function() SubHotkey('Ctrl-F2', function(hotkey)
				print("Save Filter 2")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(2, true)'
			end) end,
		})
	end) end,

	F3 = function() Hotkey('F3', function(hotkey)
		print("Onscreen Filter 3")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(3, false)'

		SubHotkeys({
			F3 = function() SubHotkey('F3', function(hotkey)
				print("All Filter 3")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(3, true)'
			end) end,
		})
	end) end,
	["Shift-F3"] = function() Hotkey('Shift-F3', function(hotkey)
		print("Add Onscreen Filter 3")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(3, false)'
		end)

		SubHotkeys({
			["Shift-F3"] = function() SubHotkey('Shift-F3', function(hotkey)
				print("Add All Filter 3")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(3, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F3"] = function() Hotkey('Ctrl-F3', function(hotkey)
		print("Create Filter 3")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(3, false)'

		SubHotkeys({
			["Ctrl-F3"] = function() SubHotkey('Ctrl-F3', function(hotkey)
				print("Save Filter 3")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(3, true)'
			end) end,
		})
	end) end,

	F4 = function() Hotkey('F4', function(hotkey)
		print("Onscreen Filter 4")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(4, false)'

		SubHotkeys({
			F4 = function() SubHotkey('F4', function(hotkey)
				print("All Filter 4")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(4, true)'
			end) end,
		})
	end) end,
	["Shift-F4"] = function() Hotkey('Shift-F4', function(hotkey)
		print("Add Onscreen Filter 4")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(4, false)'
		end)

		SubHotkeys({
			["Shift-F4"] = function() SubHotkey('Shift-F4', function(hotkey)
				print("Add All Filter 4")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(4, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F4"] = function() Hotkey('Ctrl-F4', function(hotkey)
		print("Create Filter 4")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(4, false)'

		SubHotkeys({
			["Ctrl-F4"] = function() SubHotkey('Ctrl-F4', function(hotkey)
				print("Save Filter 4")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(4, true)'
			end) end,
		})
	end) end,

	F5 = function() Hotkey('F5', function(hotkey)
		print("Onscreen Filter 5")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(5, false)'

		SubHotkeys({
			F5 = function() SubHotkey('F5', function(hotkey)
				print("All Filter 5")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(5, true)'
			end) end,
		})
	end) end,
	["Shift-F5"] = function() Hotkey('Shift-F5', function(hotkey)
		print("Add Onscreen Filter 5")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(5, false)'
		end)

		SubHotkeys({
			["Shift-F5"] = function() SubHotkey('Shift-F5', function(hotkey)
				print("Add All Filter 5")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(5, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F5"] = function() Hotkey('Ctrl-F5', function(hotkey)
		print("Create Filter 5")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(5, false)'

		SubHotkeys({
			["Ctrl-F5"] = function() SubHotkey('Ctrl-F5', function(hotkey)
				print("Save Filter 5")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(5, true)'
			end) end,
		})
	end) end,

	F6 = function() Hotkey('F6', function(hotkey)
		print("Onscreen Filter 6")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(6, false)'

		SubHotkeys({
			F6 = function() SubHotkey('F6', function(hotkey)
				print("All Filter 6")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(6, true)'
			end) end,
		})
	end) end,
	["Shift-F6"] = function() Hotkey('Shift-F6', function(hotkey)
		print("Add Onscreen Filter 6")
		Functions.AddToSelection(function()
			ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(6, false)'
		end)

		SubHotkeys({
			["Shift-F6"] = function() SubHotkey('Shift-F6', function(hotkey)
				print("Add All Filter 6")
				Functions.AddToSelection(function()
					ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").FilterSelect(6, true)'
				end)
			end) end,
		})
	end) end,
	["Ctrl-F6"] = function() Hotkey('Ctrl-F6', function(hotkey)
		print("Create Filter 6")
		ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").AddFilterSelection(6, false)'

		SubHotkeys({
			["Ctrl-F6"] = function() SubHotkey('Ctrl-F6', function(hotkey)
				print("Save Filter 6")
				ConExecute 'UI_Lua import("/mods/FilterSelection/modules/FilterSelection.lua").SaveFilterSelection(6, true)'
			end) end,
		})
	end) end,

	-- TODO: add all F groups when working

	["Ctrl-F12"] = function() Hotkey('Ctrl-F12', function(hotkey)
		print("PopupCreateUnitMenu")
		ConExecute 'PopupCreateUnitMenu'
	end) end,

	Backslash = function() Hotkey('Backslash', function(hotkey)
		print("Onscreen mass extractors")
		ConExecute("UI_SelectByCategory +inview MASSEXTRACTION")
	end) end,
	['Shift-Backslash'] = function() Hotkey('Shift-Backslash', function(hotkey)
		if AnyUnitSelected() then
			CreateOrContinueSelection(nil, "camera_create")
		else
			print("All mass extractors")
			ConExecute("UI_SelectByCategory MASSEXTRACTION")
		end
	end) end,
	['Ctrl-Backslash'] = function() Hotkey('Ctrl-Backslash', function(hotkey)
		CreateOrContinueSelection(nil, "camera_create")
	end) end,
	['Ctrl-Shift-Backslash'] = function() Hotkey('Ctrl-Shift-Backslash', function(hotkey)
		-- TODO: DeleteCamera
	end) end,
	['Alt-Backslash'] = function() Hotkey('Alt-Backslash', function(hotkey)
		-- TODO: GoToNextCamera
	end) end,

	-- 'UI_MakeSelectionSet 1'
	-- 'UI_ApplySelectionSet 1'
	-- 'UI_Lua import("/lua/ui/game/selection.lua").FactorySelection(1)'

	-- Ctrl-Z select_all_units_of_same_type
	-- Shift-T create_build_template

	-- ['T']                   = 'track_unit',
    -- ['Ctrl-Shift-T']        = 'track_unit_minimap',
    -- ['Ctrl-Alt-T']          = 'track_unit_second_mon',

	['1'] = function() Hotkey('1', function(hotkey)
		if AnyUnitSelected() then
			print("Filter T1")
			SelectUnits(EntityCategoryFilterDown(categories.TECH1, GetSelectedUnits() or {}))
		else
			print("Onscreen T1 units")
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH1 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits() or {}))

			SubHotkeys({
				['1'] = function() SubHotkey('1', function(hotkey)
					print("All Filter 1")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH1 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,
	['Shift-1'] = function() Hotkey('Shift-1', function(hotkey)
		print("Add Onscreen T1 units")
		Functions.AddToSelection(function()
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH1 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits() or {}))
		end)

		SubHotkeys({
			['Shift-1'] = function() SubHotkey('Shift-1', function(hotkey)
				print("Add All T1 units")
				Functions.AddToSelection(function()
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH1 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits() or {}))
				end)
			end) end,
		})
	end) end,

	['2'] = function() Hotkey('2', function(hotkey)
		if AnyUnitSelected() then
			print("Filter T2")
			SelectUnits(EntityCategoryFilterDown(categories.TECH2, GetSelectedUnits() or {}))
		else
			print("Onscreen T2 units")
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH2 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH2 - categories.ENGINEER, GetSelectedUnits() or {}))

			SubHotkeys({
				['2'] = function() SubHotkey('2', function(hotkey)
					print("All Filter 2")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH2 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH2 - categories.ENGINEER, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,

	['Shift-2'] = function() Hotkey('Shift-2', function(hotkey)
		print("Add Onscreen T2 units")
		Functions.AddToSelection(function()
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH2 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH2 - categories.ENGINEER, GetSelectedUnits() or {}))
		end)

		SubHotkeys({
			['Shift-2'] = function() SubHotkey('Shift-2', function(hotkey)
				print("Add All T2 units")
				Functions.AddToSelection(function()
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH2 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH2 - categories.ENGINEER, GetSelectedUnits() or {}))
				end)
			end) end,
		})
	end) end,

	['3'] = function() Hotkey('3', function(hotkey)
		if AnyUnitSelected() then
			print("Filter T3")
			SelectUnits(EntityCategoryFilterDown(categories.TECH3, GetSelectedUnits() or {}))
		else
			print("Onscreen T3 units")
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH3 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH3 - categories.ENGINEER, GetSelectedUnits() or {}))

			SubHotkeys({
				['3'] = function() SubHotkey('3', function(hotkey)
					print("All Filter 3")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH3 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH3 - categories.ENGINEER, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,

	['Shift-3'] = function() Hotkey('Shift-3', function(hotkey)
		print("Add Onscreen T3 units")
		Functions.AddToSelection(function()
			ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH3 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH3 - categories.ENGINEER, GetSelectedUnits() or {}))
		end)

		SubHotkeys({
			['Shift-3'] = function() SubHotkey('Shift-3', function(hotkey)
				print("Add All T3 units")
				Functions.AddToSelection(function()
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH3 ALLUNITS")
					SelectUnits(EntityCategoryFilterDown(categories.TECH3 - categories.ENGINEER, GetSelectedUnits() or {}))
				end)
			end) end,
		})
	end) end,

	['4'] = function() Hotkey('4', function(hotkey)
		if AnyUnitSelected() then
			print("Filter T4")
			SelectUnits(EntityCategoryFilterDown(categories.EXPERIMENTAL + categories.SUBCOMMANDER, GetSelectedUnits() or {}))
		else
			print("Onscreen T4")
			ConExecute("UI_SelectByCategory +inview EXPERIMENTAL ALLUNITS, SUBCOMMANDER")

			SubHotkeys({
				['4'] = function() SubHotkey('4', function(hotkey)
					print("All T4")
					ConExecute("UI_SelectByCategory EXPERIMENTAL ALLUNITS, SUBCOMMANDER")
				end) end,
			})
		end
	end) end,

	['Shift-4'] = function() Hotkey('Shift-4', function(hotkey)
		print("Add Onscreen T4 units")
		Functions.AddToSelection(function()
			ConExecute("UI_SelectByCategory +inview EXPERIMENTAL ALLUNITS, SUBCOMMANDER")
		end)

		SubHotkeys({
			['Shift-4'] = function() SubHotkey('Shift-4', function(hotkey)
				print("Add All T4 units")
				Functions.AddToSelection(function()
					ConExecute("UI_SelectByCategory EXPERIMENTAL ALLUNITS, SUBCOMMANDER")
				end)
			end) end,
		})
	end) end,

	['5'] = function() Hotkey('5', function(hotkey) end)
		ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").ACUSelectOCGoto()'
	end,
	['6'] = function() Hotkey('6', function(hotkey) end) end,
	['7'] = function() Hotkey('7', function(hotkey) end) end,
	['8'] = function() Hotkey('8', function(hotkey) end) end,
	['9'] = function() Hotkey('9', function(hotkey) end) end,
	['0'] = function() Hotkey('0', function(hotkey) end) end,

	Tab = function() Hotkey('Tab', function(hotkey)
		CreateOrContinueSelection("closest", "auto")
	end) end,
	['Shift-Tab'] = function() Hotkey('Shift-Tab', function(hotkey)
		CreateOrContinueSelection(nil, "camera")
	end) end,

	Q = function() Hotkey('Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
			print("Onscreen available engineers")
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))

			SubHotkeys({
				['Shift-1'] = function() SubHotkey('Shift-1', function(hotkey)
					print("Onscreen available T1+2 Engineers")
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH1, BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-2'] = function() SubHotkey('Shift-2', function(hotkey)
					print("All available T2+3 Engineers")
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH2, BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-3'] = function() SubHotkey('Shift-3', function(hotkey)
					print("Onscreen available T3 Engineers + SACU")
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH3, SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					print("Onscreen available SACU")
					ConExecute("UI_SelectByCategory +inview SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-4'] = function() SubHotkey('Shift-4', function(hotkey)
					print("Onscreen available Engineers and SACU")
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER, SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
			})
		end
	end) end,
	['Shift-Q'] = function() Hotkey('Shift-Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
			print("All available engineers")
            ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))

			SubHotkeys({
				['Shift-1'] = function() SubHotkey('Shift-1', function(hotkey)
					print("All available T1+2 Engineers")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH1, BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-2'] = function() SubHotkey('Shift-2', function(hotkey)					print("All available T1+2 Engineers")
					print("All available T2+3 Engineers")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH2, BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-3'] = function() SubHotkey('Shift-3', function(hotkey)
					print("All available T3 Engineers + SACU")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH3, SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					print("All available SACU")
					ConExecute("UI_SelectByCategory SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-4'] = function() SubHotkey('Shift-4', function(hotkey)
					print("All available Engineers and SACU")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER, SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
			})
		end
	end) end,
	['Ctrl-Q'] = function() Hotkey('Ctrl-Q', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		elseif AnyUnitSelected() then
			print("Assist Mode")
			ConExecute 'StartCommandMode order RULEUCC_Guard'
		else
			print("Onscreen idle engineers")
            ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER +inview +idle")

			SubHotkeys({
				['Ctrl-Q'] = function() SubHotkey('Ctrl-Q', function(hotkey)
					print("All idle engineers")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER +idle")
				end) end,
			})
		end
	end) end,
	['Ctrl-Shift-Q'] = function() Hotkey('Ctrl-Shift-Q', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		elseif AnyUnitSelected() then
			print("Assist Mode")
			ConExecute 'StartCommandMode order RULEUCC_Guard'
		else
			print("Onscreen idle engineers")
            ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER +inview +idle")

			SubHotkeys({
				['Ctrl-Q'] = function() SubHotkey('Ctrl-Q', function(hotkey)
					print("All idle engineers")
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER +idle")
				end) end,
			})
		end
	end) end,
	['Alt-Q'] = function() Hotkey('Alt-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").SelectPatrolUnits()'
	end) end,
	['Alt-Shift-Q'] = function() Hotkey('Alt-Shift-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").SelectPatrolUnits()'
	end) end,

	W = function() Hotkey('W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		else

		end
	end) end,
	['Shift-W'] = function() Hotkey('Shift-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		else

		end
	end) end,
	['Ctrl-W'] = function() Hotkey('Ctrl-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		elseif AllHaveCategory(categories.TACTICALMISSILEPLATFORM) then
			ConExecute 'StartCommandMode order RULEUCC_Tactical'
		elseif AllHaveCategory(categories.NUKE) then
			ConExecute 'StartCommandMode order RULEUCC_Nuke'
		elseif AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Ctrl-Shift-W'] = function() Hotkey('Ctrl-Shift-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		elseif AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Alt-W'] = function() Hotkey('Alt-W', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/distribute-queue.lua").DistributeOrders(true)'
	end) end,
	['Alt-Shift-W'] = function() Hotkey('Alt-Shift-W', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/distribute-queue.lua").DistributeOrders(true)'
	end) end,

	E = function() Hotkey('E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		elseif AllHaveCategory(categories.BOMB) then
			print("Detonate")
			ConExecute 'StartCommandMode order RULEUCC_SpecialAction'
			-- ConExecute 'StartCommandMode order RULEUTC_ProductionToggle'

		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		-- elseif AllHaveCategory(categories.AIR) then
		-- 	print("Dock")
		-- Doesnt work
		-- 	ConExecute 'StartCommandMode order RULEUCC_Dock'
		elseif AnyUnitSelected() then

			ConExecute 'StartCommandMode order RULEUCC_CallTransport'

			-- RULEUCC_Dive

			-- print("Add onscreen available transports")
			-- Functions.AddToSelection(function()
			-- 	ConExecute 'UI_SelectByCategory +inview AIR TRANSPORTATION'
			-- 	SelectUnits(Functions.FilterAvailableTransports())
			-- end)
		else
			-- TODO: Functions.AvailableTransport (no loaded units and not on a pickup order)
			-- print("Onscreen transports")
			-- ConExecute 'UI_SelectByCategory +inview AIR TRANSPORTATION'
			-- SelectUnits(Functions.FilterAvailableTransports())
		end
	end) end,
	['Shift-E'] = function() Hotkey('Shift-E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
			print("All bombers")
			ConExecute("UI_SelectByCategory AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits() or {}))
		end
	end) end,
	['Ctrl-E'] = function() Hotkey('Ctrl-E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) and not AnyHasCategory(categories.EXPERIMENTAL) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Repair'
		end
	end) end,
	['Ctrl-Shift-E'] = function() Hotkey('Ctrl-Shift-E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		end
	end) end,
	['Alt-E'] = function() Hotkey('Alt-E', function(hotkey)
	end) end,
	['Alt-Shift-E'] = function() Hotkey('Alt-Shift-E', function(hotkey)
	end) end,

	R = function() Hotkey('R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyUnitSelected() then

			ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetToMouseTargetOrDefault()'
			SubHotkeys({
				['1'] = function() SubHotkey('1', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Tech1")'
				end) end,
				['2'] = function() SubHotkey('2', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Tech2")'
				end) end,
				['3'] = function() SubHotkey('3', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Tech3")'
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("EXP")'
				end) end,

				Q = function() SubHotkey('Q', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Units")'
				end) end,
				W = function() SubHotkey('W', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Snipe")'
				end) end,
				E = function() SubHotkey('E', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Engies")'
				end) end,

				A = function() SubHotkey('A', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("ACU")'
				end) end,
				S = function() SubHotkey('S', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Mex")'
				end) end,
				D = function() SubHotkey('D', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Power")'
				end) end,
				F = function() SubHotkey('F', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Factory")'
				end) end,
				G = function() SubHotkey('G', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Torpedo")'
				end) end,

				Z = function() SubHotkey('Z', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Shields")'
				end) end,
				X = function() SubHotkey('X', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("DirectFire")'
				end) end,
				C = function() SubHotkey('C', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("AA")'
				end) end,
				V = function() SubHotkey('V', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("IndirectFire")'
				end) end,
			})
		end
	end) end,
	['Shift-R'] = function() Hotkey('Shift-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		elseif AnyUnitSelected() then
			-- Add all available transports
			print("Add All available transports")
			Functions.AddToSelection(function()
				ConExecute 'UI_SelectByCategory AIR TRANSPORTATION'
				SelectUnits(Functions.FilterAvailableTransports())
			end)
		else
			print("All transports")
			ConExecute 'UI_SelectByCategory AIR TRANSPORTATION'
		end
	end) end,
	['Ctrl-R'] = function() Hotkey('Ctrl-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
			print("Add range ring")
			ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
		end
	end) end,
	['Ctrl-Shift-R'] = function() Hotkey('Ctrl-Shift-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
			print("Delete closest range ring")
			ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()'
		end
	end) end,
	['Alt-R'] = function() Hotkey('Alt-R', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(true)'
	end) end,
	['Alt-Shift-R'] = function() Hotkey('Alt-Shift-R', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(false)'
	end) end,

	T = function() Hotkey('T', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		end
	end) end,
	['Shift-T'] = function() Hotkey('Shift-T', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		end
	end) end,

	Y = function() Hotkey('Y', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			-- Select Enhancements tab
			SubHotkeys({
				-- TODO: Make queueable targeting, by holding shift, it puts it after order finishes? 
				T = function() SubHotkey('T', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTechUpgrade()'
				end) end,
				U = function() SubHotkey('U', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderGunUpgrade()'
				end) end,
				G = function() SubHotkey('G', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderRASUpgrade()'
				end) end,
				H = function() SubHotkey('H', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderNanoUpgrade()'
				end) end,
				J = function() SubHotkey('J', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTorpedoUpgrade()'
				end) end,
				['6'] = function() SubHotkey('6', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTeleUpgrade()'
				end) end,
				['7'] = function() SubHotkey('7', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderSpecialUpgrade()'
				end) end
			})
		end
	end) end,
	['Shift-Y'] = function() Hotkey('Shift-Y', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		end
	end) end,

	U = function() Hotkey('U', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		end
	end) end,
	['Shift-U']  = function() Hotkey('U', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		end
	end) end,

	P = function() Hotkey('P', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/zoompopper.lua").ToggleZoomPop()'
	end) end,

	CapsLock = function() Hotkey('CapsLock', function(hotkey)
		if AnyUnitSelected() then
			import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(true)
		end
	end) end,
	['Shift-CapsLock'] = function() Hotkey('Shift-CapsLock', function(hotkey)
		if AnyUnitSelected() then
			import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(false)
		end
	end) end,
	['Ctrl-CapsLock'] = function() Hotkey('Ctrl-CapsLock', function(hotkey)
		-- Cancel all but one order
	end) end,
	['Alt-CapsLock'] = function() Hotkey('Alt-CapsLock', function(hotkey)
		-- Filter paused
	end) end,

	A = function() Hotkey('A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			local hoveredUnit = GetRolloverInfo().userUnit
			if hoveredUnit and not IsDestroyed(hoveredUnit) and hoveredUnit:IsInCategory('STRUCTURE') and
				(hoveredUnit:IsInCategory('MASSEXTRACTION') or hoveredUnit:IsInCategory('ARTILLERY') or hoveredUnit:IsInCategory('RADAR')  or hoveredUnit:IsInCategory('OMNI')) then
				ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/capping.lua").HotkeyToCap(true, true)'
			else
				ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()'
			end
		elseif not isReplay and AnyUnitCanUpgrade() then
			ConExecute 'UI_LUA import("/lua/keymap/hotbuild.lua").buildActionUpgrade()'
		else
			print("Onscreen fighters")
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits() or {}))
		end
	end) end,
	['Shift-A'] = function() Hotkey('Shift-A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			local hoveredUnit = GetRolloverInfo().userUnit
			if hoveredUnit and not IsDestroyed(hoveredUnit) and hoveredUnit:IsInCategory('STRUCTURE') then
				ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/capping.lua").HotkeyToCap(true, false)'
			else
				ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()'
			end
		elseif not isReplay and AnyUnitCanUpgrade() then
			ConExecute 'UI_LUA import("/lua/keymap/hotbuild.lua").buildActionUpgrade()'
		else
			print("All fighters")
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits() or {}))
		end
	end) end,
	['Ctrl-A'] = function() Hotkey('Ctrl-A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		else
			print("Onscreen air factories")
			ConExecute 'UI_SelectByCategory +inview FACTORY AIR'
		end
	end) end,
	['Ctrl-Shift-A'] = function() Hotkey('Ctrl-Shift-A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		else
			print("Onscreen air factories")
			ConExecute 'UI_SelectByCategory FACTORY AIR'
		end
	end) end,
	['Alt-A'] = function() Hotkey('Alt-A', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'

		-- print("Onscreen Similar units")
		-- Functions.SelectSimilarUnits("+inview")

		-- SubHotkeys({
		-- 	['Alt-S'] = function() SubHotkey('Alt-S', function(hotkey)
		-- 		print("All Similar units")
		-- 		Functions.SelectSimilarUnits()
		-- 	end) end,
		-- })
	end) end,
	['Alt-Shift-A'] = function() Hotkey('Alt-Shift-A', function(hotkey)

	end) end,

	S = function() Hotkey('S', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		else
			print("Onscreen intel planes")
            ConExecute 'UI_SelectByCategory +inview AIR INTELLIGENCE'
		end
	end) end,
	['Shift-S'] = function() Hotkey('Shift-S', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		else
			print("All intel planes")
            ConExecute 'UI_SelectByCategory AIR INTELLIGENCE'
		end
	end) end,
	['Ctrl-S'] = function() Hotkey('Ctrl-S', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_NavalFact")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_5")'
		else
			print("Onscreen naval factories")
			ConExecute 'UI_SelectByCategory +inview FACTORY NAVAL'
		end
	end) end,
	['Ctrl-Shift-S'] = function() Hotkey('Ctrl-Shift-S', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_NavalFact")'
		else
			print("All naval factories")
			ConExecute 'UI_SelectByCategory FACTORY NAVAL'
		end
	end) end,
	['Alt-S'] = function() Hotkey('Alt-S', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectRest()'
	end) end,

	D = function() Hotkey('D', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			print("Onscreen gunships")
			ConExecute 'UI_SelectByCategory +inview AIR GROUNDATTACK'
		end
	end) end,
	['Shift-D'] = function() Hotkey('Shift-D', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			print("All gunships")
			ConExecute 'UI_SelectByCategory AIR GROUNDATTACK'
		end
	end) end,
	['Ctrl-D'] = function() Hotkey('Ctrl-D', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_6")'
		else
			print("Onscreen land factories")
			ConExecute 'UI_SelectByCategory +inview FACTORY LAND'
		end
	end) end,
	['Ctrl-Shift-D'] = function() Hotkey('Ctrl-Shift-D', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		else
			print("All land factories")
			ConExecute 'UI_SelectByCategory FACTORY LAND'
		end
	end) end,
	['Alt-D'] = function() Hotkey('Alt-D', function(hotkey)
		CreateOrContinueSelection("damage", "auto")
	end) end,
	['Alt-Shift-D'] = function() Hotkey('Alt-Shift-D', function(hotkey) end) end,  

	F = function() Hotkey('F', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		else
			print("Onscreen bombers")
            ConExecute("UI_SelectByCategory +inview AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits() or {}))
		end
	end) end,
	['Shift-F'] = function() Hotkey('Shift-F', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		else
			print("All bombers")
            ConExecute("UI_SelectByCategory AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits() or {}))
		end
	end) end,
	['Ctrl-F'] = function() Hotkey('Ctrl-F', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_7")'
		else
			print("Onscreen factories")
			ConExecute 'UI_SelectByCategory +inview FACTORY'
		end
	end) end,
	['Ctrl-Shift-F'] = function() Hotkey('Ctrl-Shift-F', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		else
			print("All factories")
			ConExecute 'UI_SelectByCategory FACTORY'
		end
	end) end,
	['Alt-F'] = function() Hotkey('Alt-F', function(hotkey)
		CreateOrContinueSelection("furthest", "auto")
	end) end,
	['Alt-Shift-F'] = function() Hotkey('Alt-Shift-F', function(hotkey)
	end) end,

	G = function() Hotkey('G', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		else
			print("Onscreen torpedo bombers")
			ConExecute 'UI_SelectByCategory +inview AIR ANTINAVY'
		end
	end) end,
	['Shift-G'] = function() Hotkey('G', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		else
			print("All torpedo bombers")
			ConExecute 'UI_SelectByCategory AIR ANTINAVY'
		end
	end) end,
	['Ctrl-G'] = function() Hotkey('Ctrl-G', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_8")'
		end
	end) end,

	H = function() Hotkey('H', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_5")'
		end
	end) end,
	['Shift-H'] = function() Hotkey('Shift-H', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_5")'
		end
	end) end,

	J = function() Hotkey('J', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_6")'
		end
	end) end,
	['Shift-J'] = function() Hotkey('Shift-J', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_6")'
		end
	end) end,

	K = function() Hotkey('K', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_7")'
		end
	end) end,
	['Shift-K'] = function() Hotkey('Shift-K', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_7")'
		end
	end) end,

	L = function() Hotkey('L', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_8")'
		end
	end) end,
	['Shift-L'] = function() Hotkey('Shift-L', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_8")'
		end
	end) end,

	Chevron = function() Hotkey('Chevron', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			Functions.ToggleRepeatBuildOrSetTo(true)
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5, false)'
			import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
		end
	end) end,
	['Shift-Chevron'] = function() Hotkey('Shift-Chevron', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			Functions.ToggleRepeatBuildOrSetTo(false)
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5, false)'
			import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
		end
	end) end,
	['Ctrl-Chevron'] = function() Hotkey('Ctrl-Chevron', function(hotkey)
		ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/copy-queue.lua").CopyOrders(true)'
	end) end,
	['Ctrl-Shift-Chevron'] = function() Hotkey('Ctrl-Shift-Chevron', function(hotkey)
		ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/copy-queue.lua").CopyOrders(false)'
	end) end,
	['Alt-Chevron'] = function() Hotkey('Alt-Chevron', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/filter-engineers.lua").SelectHighestEngineerAndAssist()'
	end) end,
	['Alt-Shift-Chevron'] = function() Hotkey('Alt-Shift-Chevron', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/filter-engineers.lua").SelectHighestEngineerAndAssist()'
	end) end,

	Z = function() Hotkey('Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		else
			print("Onscreen indirect fire units")
			ConExecute("UI_SelectByCategory +inview LAND INDIRECTFIRE")
			SelectUnits(EntityCategoryFilterDown(categories.INDIRECTFIRE - categories.DIRECTFIRE - categories.EXPERIMENTAL, GetSelectedUnits() or {}))

			SubHotkeys({
				Z = function() SubHotkey('Z', function(hotkey)
					print("All indirect fire units")
					ConExecute("UI_SelectByCategory LAND INDIRECTFIRE")
					SelectUnits(EntityCategoryFilterDown(categories.INDIRECTFIRE - categories.DIRECTFIRE - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,
	['Shift-Z'] = function() Hotkey('Shift-Z', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		else
			print("Onscreen indirect fire units")
			Functions.AddToSelection(function()
				ConExecute("UI_SelectByCategory +inview LAND INDIRECTFIRE")
				SelectUnits(EntityCategoryFilterDown(categories.INDIRECTFIRE - categories.DIRECTFIRE - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
			end)

			SubHotkeys({
				['Shift-Z'] = function() SubHotkey('Shift-Z', function(hotkey)
					print("All indirect fire units")
					Functions.AddToSelection(function()
						ConExecute("UI_SelectByCategory LAND INDIRECTFIRE")
						SelectUnits(EntityCategoryFilterDown(categories.INDIRECTFIRE - categories.DIRECTFIRE - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
					end)
				end) end,
			})
		end
	end) end,
	['Ctrl-Z'] = function() Hotkey('Ctrl-Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_4")'
		end
	end) end,
	['Ctrl-Shift-Z'] = function() Hotkey('Ctrl-Shift-Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		end
	end) end,
	['Alt-Z'] = function() Hotkey('Alt-Z', function(hotkey)
		-- TODO: remove. Reason: Used to be able to select manually and only cycle those, but just causing confusion. We want to be able to run the hotkey even in the middle of a cycle to reset and see number of silos loaded. 
		-- SelectUnits(EntityCategoryFilterDown(categories.STRUCTURE + categories.TACTICALMISSILEPLATFORM, GetSelectedUnits() or {}))
		-- if not AnyUnitSelected() then
		-- 	ConExecute "UI_SelectByCategory STRUCTURE TACTICALMISSILEPLATFORM"
		-- end

		ConExecute "UI_SelectByCategory STRUCTURE TACTICALMISSILEPLATFORM"

		local emptySilos = 0
		local loadedSilos = 0
		local loadedMissiles = 0

		for key, unit in pairs(GetSelectedUnits() or {}) do
			local missile_info = unit:GetMissileInfo()
            local missilesCount = missile_info.nukeSiloStorageCount + missile_info.tacticalSiloStorageCount

			if missilesCount == 0 then
				emptySilos = emptySilos + 1
			else
				loadedSilos = loadedSilos + 1
				loadedMissiles = loadedMissiles + missilesCount
			end
		end

		print("TMLs:  "..loadedSilos.." / "..loadedMissiles.." <- "..emptySilos)

		if AllHaveCategory(categories.TACTICALMISSILEPLATFORM) then
			CreateOrContinueSelection("closest", "auto", "silo")
			ConExecute "StartCommandMode order RULEUCC_Tactical"
		else
			PlaySound(Sound { Cue = "UI_Menu_Error_01", Bank = "Interface" })
		end
        -- ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH3'
		-- if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH3) and AllHaveCategory(categories.STRUCTURE) then
		-- 	CreateOrContinueSelection("furthest", "auto")
		-- end
	end) end,
	['Alt-Shift-Z'] = function() Hotkey('Alt-Shift-Z', function(hotkey)
        -- ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH3'
		-- if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH3) and AllHaveCategory(categories.STRUCTURE) then
		-- 	CreateOrContinueSelection("furthest", "auto")
		-- 	ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
		-- 	ConExecute 'StartCommandMode order RULEUCC_Attack'
		-- end
	end) end,

	X = function() Hotkey('X', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		else
			print("Onscreen direct fire units")
			ConExecute("UI_SelectByCategory +inview LAND DIRECTFIRE")
			SelectUnits(EntityCategoryFilterDown(categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.COMMAND, GetSelectedUnits() or {}))

			SubHotkeys({
				X = function() SubHotkey('X', function(hotkey)
					print("All direct fire units")
					ConExecute("UI_SelectByCategory LAND DIRECTFIRE")
					SelectUnits(EntityCategoryFilterDown(categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.COMMAND, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,
	['Shift-X'] = function() Hotkey('Shift-X', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		else
			print("Onscreen direct fire units")
			Functions.AddToSelection(function()
				ConExecute("UI_SelectByCategory +inview LAND DIRECTFIRE")
				SelectUnits(EntityCategoryFilterDown(categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.COMMAND, GetSelectedUnits() or {}))
			end)

			SubHotkeys({
				['Shift-X'] = function() SubHotkey('Shift-X', function(hotkey)
					print("All direct fire units")
					Functions.AddToSelection(function()
						ConExecute("UI_SelectByCategory LAND DIRECTFIRE")
						SelectUnits(EntityCategoryFilterDown(categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.COMMAND, GetSelectedUnits() or {}))
					end)
				end) end,
			})
		end
	end) end,
	['Ctrl-X'] = function() Hotkey('Ctrl-X', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimentals")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
		end
	end) end,
	['Ctrl-Shift-X'] = function() Hotkey('Ctrl-Shift-X', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimentals")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
		else
			print("All indirect fire units")
			ConExecute("UI_SelectByCategory LAND INDIRECTFIRE")
		end
	end) end,
	['Alt-X'] = function() Hotkey('Alt-X', function(hotkey)
		CreateOrContinueSelection("health", "auto")
	end) end,

	C = function() Hotkey('C', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		else
			print("Onscreen AA units")
			ConExecute("UI_SelectByCategory +inview LAND ANTIAIR")
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.EXPERIMENTAL, GetSelectedUnits() or {}))

			SubHotkeys({
				C = function() SubHotkey('C', function(hotkey)
					print("All AA units")
					ConExecute("UI_SelectByCategory LAND ANTIAIR")
					SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,
	['Shift-C'] = function() Hotkey('Shift-C', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		else
			print("Onscreen AA units")
			Functions.AddToSelection(function()
				ConExecute("UI_SelectByCategory +inview LAND ANTIAIR")
				SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
			end)

			SubHotkeys({
				['Shift-C'] = function() SubHotkey('Shift-C', function(hotkey)
					print("All AA units")
					Functions.AddToSelection(function()
						ConExecute("UI_SelectByCategory LAND ANTIAIR")
						SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
					end)
				end) end,
			})
		end
	end) end,
	['Ctrl-C'] = function() Hotkey('Ctrl-C', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_6")'
		else
			print("Onscreen torpedo units")
			ConExecute("UI_SelectByCategory +inview LAND ANTINAVY")
		end
	end) end,
	['Ctrl-Shift-C'] = function() Hotkey('Ctrl-Shift-C', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_6")'
		else
			print("All torpedo units")
			ConExecute("UI_SelectByCategory LAND ANTINAVY")
		end
	end) end,
	['Alt-C'] = function() Hotkey('Alt-C', function(hotkey)
		CreateOrContinueSelection("closest", "auto")
	end) end,
	['Alt-Shift-C'] = function() Hotkey('Alt-Shift-C', function(hotkey)
	end) end,

	V = function() Hotkey('V', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		else
			print("Onscreen support units")
			ConExecute("UI_SelectByCategory +inview INTELLIGENCE LAND, COUNTERINTELLIGENCE LAND, SHIELD OVERLAYDEFENSE LAND")
			SelectUnits(EntityCategoryFilterDown(categories.LAND - categories.EXPERIMENTAL, GetSelectedUnits() or {}))

			SubHotkeys({
				['Shift-C'] = function() SubHotkey('Shift-C', function(hotkey)
					print("All support units")
					ConExecute("UI_SelectByCategory INTELLIGENCE LAND, COUNTERINTELLIGENCE LAND, SHIELD OVERLAYDEFENSE LAND")
					SelectUnits(EntityCategoryFilterDown(categories.LAND - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
				end) end,
			})
		end
	end) end,
	['Shift-V'] = function() Hotkey('Shift-V', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		else
			print("Add Onscreen support units")
			Functions.AddToSelection(function()
				ConExecute("UI_SelectByCategory +inview INTELLIGENCE LAND, COUNTERINTELLIGENCE LAND, SHIELD OVERLAYDEFENSE LAND")
				SelectUnits(EntityCategoryFilterDown(categories.LAND - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
			end)

			SubHotkeys({
				['Shift-C'] = function() SubHotkey('Shift-C', function(hotkey)
					print("Add All support units")
					Functions.AddToSelection(function()
						ConExecute("UI_SelectByCategory INTELLIGENCE LAND, COUNTERINTELLIGENCE LAND, SHIELD OVERLAYDEFENSE LAND")
						SelectUnits(EntityCategoryFilterDown(categories.LAND - categories.EXPERIMENTAL, GetSelectedUnits() or {}))
					end)
				end) end,
			})
		end
	end) end,
	['Ctrl-V'] = function() Hotkey('Ctrl-V', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Stations")'
		elseif AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_7")'
		end
	end) end,
	['Ctrl-Shift-V'] = function() Hotkey('Ctrl-Shift-V', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Stations")'
		end
	end) end,

	B = function() Hotkey('B', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_4")'
		end
	end) end,
	['Shift-B'] = function() Hotkey('Shift-B', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_4")'
		end
	end) end,

	N = function() Hotkey('N', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
		else
			SelectUnits(EntityCategoryFilterDown(categories.NUKE, GetSelectedUnits() or {}))

			if not AnyUnitSelected() then
				ConExecute "UI_SelectByCategory NUKE"
			end

			if AllHaveCategory(categories.NUKE) then
				CreateOrContinueSelection("closest", "auto", "silo")
				ConExecute "StartCommandMode order RULEUCC_Nuke"
			else
				PlaySound(Sound { Cue = "UI_Menu_Error_01", Bank = "Interface" })
			end
		end
	end) end,
	['Shift-N'] = function() Hotkey('Shift-N', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
		end
	end) end,
	['Alt-N'] = function() Hotkey('Alt-N', function(hotkey)

	end) end,

	M = function() Hotkey('M', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_6")'
		else

		end
	end) end,
	['Shift-M'] = function() Hotkey('Shift-M', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_6")'
		end
	end) end,

	Space = function() Hotkey('Space', function(hotkey)
		ConExecute 'UI_Lua import("/mods/SubGroups/modules/selection.lua").MultiSplit()'
	end) end,
	['Shift-Space'] = function() Hotkey('Shift-Space', function(hotkey)
		ConExecute 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitMouseOrthogonalAxis()'
	end) end,
	['Ctrl-Space'] = function() Hotkey('Ctrl-Space', function(hotkey)
		-- TODO: Group based on blueprint and split equally 
		-- ConExecute 'UI_Lua import("/mods/UI-Party/modules/unitsplit.lua").SplitGroups(2)'
		-- ConExecute 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(2)'
	end) end,
}

function RunCustom(key)
	ForkThread(customKeyMap[key])
end

function Init()
	from(customKeyMap).foreach(function(k, v)
		local name = string.gsub(k, "-", "_")

		userKeyActions['SHK '..name] = {
			action = 'UI_Lua import("/mods/MoreHotkeyLayouts/modules/main.lua").RunCustom("'..k..'")',
			category = 'SHK'
		}

		userKeyMap[k] = 'SHK '..name
	end)

	Prefs.SetToCurrentProfile('UserKeyActions', userKeyActions)
	Prefs.SetToCurrentProfile('UserKeyMap', userKeyMap)
end
