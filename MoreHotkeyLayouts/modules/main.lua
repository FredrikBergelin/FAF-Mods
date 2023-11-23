local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions') -- Eg: ['Cycle next, defaults to closest'] = { action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()', ... },
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap') -- Eg: Tab = 'Cycle next, defaults to closest',

local Functions = import("/mods/MoreHotkeyLayouts/modules/functions.lua")
local AnyUnitSelected = import('/mods/common/modules/misc.lua').AnyUnitSelected

local subHotkeys = nil
local subHotkey = nil

local storedUniqueIdentifier
local lastClickTime = -9999
local clickCount = 1

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
		clickCount = clickCount + 1
		subHotkey = subHotkeys[hotkey]
	else
		clickCount = 1
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

local CreateOrContinueSelection = import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection

local customKeyMap = {

	-- ['Esc'] = function() Hotkey('Esc', function(hotkey)
	-- end) end,

	F1 = function() Hotkey('F1', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("AlertExtended")'
	end) end,
	F2 = function() Hotkey('F2', function(hotkey)
		-- ConExecute 'UI_Lua import("/mods/ChatWheel/modules/CWMain.lua").call()'
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("Util")'
	end) end,
	F3 = function() Hotkey('F3', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("TargetPriorityExtended")'
	end) end,
	F4 = function() Hotkey('F4', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTab("diplomacy")'
	end) end,
	F5 = function() Hotkey('F5', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleScore()'
		-- Stops working after adding / removing a few rings, no error message
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenMenu("Default")'
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenWheel("Default")'
	end) end,
	F6 = function() Hotkey('F6', function(hotkey)
	end) end,
	F7 = function() Hotkey('F7', function(hotkey)
		-- 
	end) end,
	F8 = function() Hotkey('F8', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/objectivedetail.lua").ToggleDisplay()'
	end) end,
	F9 = function() Hotkey('F9', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/connectivity.lua").CreateUI()'
	end) end,
	F10 = function() Hotkey('F10', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTab("main")'
	end) end,
	F11 = function() Hotkey('F11', function(hotkey)
		ConExecute 'PopupCreateUnitMenu'
	end) end,
	F12 = function() Hotkey('F12', function(hotkey)
		ConExecute 'WIN_ToggleLogDialog'
	end) end,

	Backslash = function() Hotkey('Backslash', function(hotkey)
		ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").ACUSelectOCGoto()'
	end) end,
	['Shift-Backslash'] = function() Hotkey('Shift-Backslash', function(hotkey)
		CreateOrContinueSelection(nil, "camera")
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

	['1'] = function() Hotkey('1', function(hotkey)
		if AnyUnitSelected() then
			SelectUnits(EntityCategoryFilterDown(categories.TECH1, GetSelectedUnits()))
		else
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER1FACTORY TECH1 ALLUNITS")
			SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits()))

			SubHotkeys({
				['1'] = function() SubHotkey('1', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER1FACTORY TECH1")
				end) end,
			})
		end
	end) end,
	['2'] = function() Hotkey('2', function(hotkey)
		if AnyUnitSelected() then
			SelectUnits(EntityCategoryFilterDown(categories.TECH2, GetSelectedUnits()))
		else
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER2FACTORY TECH2")
			SelectUnits(EntityCategoryFilterDown(categories.TECH2 - categories.ENGINEER, GetSelectedUnits()))

			SubHotkeys({
				['2'] = function() SubHotkey('2', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER2FACTORY TECH2")
				end) end,
			})
		end
	end) end,
	['3'] = function() Hotkey('3', function(hotkey)
		if AnyUnitSelected() then
			SelectUnits(EntityCategoryFilterDown(categories.TECH3, GetSelectedUnits()))
		else
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY TECH3")
			SelectUnits(EntityCategoryFilterDown(categories.TECH3 - categories.ENGINEER, GetSelectedUnits()))

			SubHotkeys({
				['3'] = function() SubHotkey('3', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH3")
				end) end,
			})
		end
	end) end,
	['4'] = function() Hotkey('4', function(hotkey)
		if AnyUnitSelected() then
			SelectUnits(EntityCategoryFilterDown(categories.EXPERIMENTAL, GetSelectedUnits()))
		else
            ConExecute("UI_SelectByCategory +inview EXPERIMENTAL")

			SubHotkeys({
				['4'] = function() SubHotkey('3', function(hotkey)
					ConExecute("UI_SelectByCategory EXPERIMENTAL")
				end) end,
			})
		end
	end) end,
	-- Test
	['5'] = function() Hotkey('5', function(hotkey)
		-- ConExecute 'UI_SelectByCategory AIR TRANSPORTATION'
		SelectUnits(Functions.FilterAvailableTransports())
	end) end,
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
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH1")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))

			SubHotkeys({
				['1'] = function() SubHotkey('1', function(hotkey)
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['2'] = function() SubHotkey('2', function(hotkey)
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['3'] = function() SubHotkey('3', function(hotkey)
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					ConExecute("UI_SelectByCategory +inview SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
			})
		end
	end) end,
	['Shift-Q'] = function() Hotkey('Shift-Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
            ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH1")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))

			SubHotkeys({
				['1'] = function() SubHotkey('1', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-1'] = function() SubHotkey('Shift-1', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['2'] = function() SubHotkey('2', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-2'] = function() SubHotkey('Shift-2', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['3'] = function() SubHotkey('3', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-3'] = function() SubHotkey('Shift-3', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					ConExecute("UI_SelectByCategory SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
				['Shift-4'] = function() SubHotkey('Shift-4', function(hotkey)
					ConExecute("UI_SelectByCategory SUBCOMMANDER")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol", "AggressiveMove"}))
				end) end,
			})
		end
	end) end,
	['Ctrl-Q'] = function() Hotkey('Ctrl-Q', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		else
			print("Select patrollers")
			ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").SelectPatrolUnits()'
		end
	end) end,
	['Ctrl-Shift-Q'] = function() Hotkey('Ctrl-Shift-Q', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		else
			print("Convert to move")
			ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").ConvertToMove()'
		end
	end) end,
	['Alt-Q'] = function() Hotkey('Alt-Q', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/distribute-queue.lua").DistributeOrders(true)'
	end) end,
	['Alt-Shift-Q'] = function() Hotkey('Alt-Shift-Q', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/distribute-queue.lua").DistributeOrders(true)'
	end) end,

	W = function() Hotkey('W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		end
	end) end,
	['Shift-W'] = function() Hotkey('Shift-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		else
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
		end
	end) end,
	['Ctrl-W'] = function() Hotkey('Ctrl-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Ctrl-Shift-W'] = function() Hotkey('Ctrl-Shift-W', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Alt-W'] = function() Hotkey('Alt-W', function(hotkey) end) end,
	['Alt-Shift-W'] = function() Hotkey('Alt-Shift-W', function(hotkey) end) end,

	E = function() Hotkey('E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
            ConExecute("UI_SelectByCategory +inview AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))

			SubHotkeys({
				['E'] = function() SubHotkey('E', function(hotkey)
					ConExecute("UI_SelectByCategory AIR BOMBER")
					SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))
				end) end,
			})
		end
	end) end,
	['Shift-E'] = function() Hotkey('Shift-E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
			ConExecute("UI_SelectByCategory AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))
		end
	end) end,
	['Ctrl-E'] = function() Hotkey('Ctrl-E', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
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
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectRest()'
	end) end,
	['Alt-Shift-E'] = function() Hotkey('Alt-Shift-E', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
	end) end,

	R = function() Hotkey('R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		else
			-- TODO: Functions.AvailableTransport (no loaded units and not on a pickup order)
			ConExecute 'UI_SelectByCategory +inview AIR TRANSPORTATION'
			SelectUnits(Functions.FilterAvailableTransports())

			SubHotkeys({
				R = function() SubHotkey('R', function(hotkey)
					ConExecute 'UI_SelectByCategory +inview AIR TRANSPORTATION'
					SubHotkeys({
						R = function() SubHotkey('R', function(hotkey)
							ConExecute 'UI_SelectByCategory AIR TRANSPORTATION'
						end) end,
					})
				end) end,
			})
		end
	end) end,
	['Shift-R'] = function() Hotkey('Shift-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		else
			-- TODO: Functions.AvailableTransport (no loaded units and not on a pickup order)

			ConExecute 'UI_SelectByCategory AIR TRANSPORTATION'
			SelectUnits(Functions.FilterAvailableTransports())

			-- ConExecute 'UI_SelectByCategory +nearest +idle AIR TRANSPORTATION'
			-- SubHotkeys({
			-- 	R = function() SubHotkey('R', function(hotkey)
			-- 		ConExecute 'UI_SelectByCategory +inview +idle AIR TRANSPORTATION'
			-- 		SubHotkeys({
			-- 			R = function() SubHotkey('R', function(hotkey)
			-- 				ConExecute 'UI_SelectByCategory +idle AIR TRANSPORTATION'
			-- 			end) end,
			-- 		})
			-- 	end) end,
			-- })
		end
	end) end,
	['Ctrl-R'] = function() Hotkey('Ctrl-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		elseif AllHaveCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
			ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
		end
	end) end,
	['Ctrl-Shift-R'] = function() Hotkey('Ctrl-Shift-R', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		else
			ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()'
		end
	end) end,
	['Alt-R'] = function() Hotkey('Alt-R', function(hotkey)
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
	end) end,
	['Alt-Shift-R'] = function() Hotkey('Alt-Shift-R', function(hotkey)
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()'
	end) end,

	T = function() Hotkey('T', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetToMouseTargetOrDefault()'
			SubHotkeys({
				-- TODO: Make queueable targeting, by holding shift, it puts it after order finishes? 
				['2'] = function() SubHotkey('2', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("TorpBomber")'
				end) end,
				['3'] = function() SubHotkey('3', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Gunship")'
				end) end,
				['4'] = function() SubHotkey('4', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Bomber")'
				end) end,
				Q = function() SubHotkey('Q', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Arty")'
				end) end,
				W = function() SubHotkey('W', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Units")'
				end) end,
				E = function() SubHotkey('E', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Engies")'
				end) end,
				R = function() SubHotkey('R', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Snipe")'
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
				Z = function() SubHotkey('Z', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Shields")'
				end) end,
				X = function() SubHotkey('X', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("PD")'
				end) end,
				C = function() SubHotkey('C', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("AA")'
				end) end,
				V = function() SubHotkey('V', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("EXP")'
				end) end,
			})
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

	-- 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").UpgradeStructuresEngineersCycleTemplates()'
	-- function HotkeyToCap(ringAllFabricators, clearCommands)
	A = function() Hotkey('A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			local hoveredUnit = GetRolloverInfo().userUnit
			if hoveredUnit and not IsDestroyed(hoveredUnit) and hoveredUnit:IsInCategory('STRUCTURE') then
				ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/capping.lua").HotkeyToCap(true, true)'
			else
				ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()'
			end
		elseif not isReplay and AnyUnitCanUpgrade() then
			ConExecute 'UI_LUA import("/lua/keymap/hotbuild.lua").buildActionUpgrade()'
		else
			print("In-view fighters")
			ConExecute 'UI_SelectByCategory +inview AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))

			SubHotkeys({
				['A'] = function() SubHotkey('A', function(hotkey)
					print("All fighters")
					ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
					SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))
				end) end,
			})
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
			print("All Fighters")
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))
		end
	end) end,
	['Ctrl-A'] = function() Hotkey('Ctrl-A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		else
			ConExecute 'UI_SelectByCategory +inview FACTORY AIR'
		end
	end) end,
	['Ctrl-Shift-A'] = function() Hotkey('Ctrl-Shift-A', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		else
			ConExecute 'UI_SelectByCategory FACTORY AIR'
		end
	end) end,
	['Alt-A'] = function() Hotkey('Alt-A', function(hotkey)
		print("In-view Similar units")
		Functions.SelectSimilarUnits("+inview")

		SubHotkeys({
			['Alt-S'] = function() SubHotkey('Alt-S', function(hotkey)
				print("All Similar units")
				Functions.SelectSimilarUnits()
			end) end,
		})
	end) end,
	['Alt-Shift-A'] = function() Hotkey('Alt-Shift-A', function(hotkey)

	end) end,

	S = function() Hotkey('S', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		else
			print("In-view intel planes")
            ConExecute 'UI_SelectByCategory +inview AIR INTELLIGENCE'

			SubHotkeys({
				['S'] = function() SubHotkey('S', function(hotkey)
					print("All intel planes")
					ConExecute 'UI_SelectByCategory AIR INTELLIGENCE'
				end) end,
			})
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
		else
			ConExecute 'UI_SelectByCategory +inview FACTORY NAVAL'
		end
	end) end,
	['Ctrl-Shift-S'] = function() Hotkey('Ctrl-Shift-S', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_NavalFact")'
		else
			ConExecute 'UI_SelectByCategory FACTORY NAVAL'
		end
	end) end,
	['Alt-S'] = function() Hotkey('Alt-S', function(hotkey)

	end) end,

	D = function() Hotkey('D', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			print("All gunships")
			ConExecute 'UI_SelectByCategory +inview AIR GROUNDATTACK'

			SubHotkeys({
				['D'] = function() SubHotkey('D', function(hotkey)
					print("All gunships")
					ConExecute 'UI_SelectByCategory AIR GROUNDATTACK'
				end) end,
			})
		end
	end) end,
	['Shift-D'] = function() Hotkey('Shift-D', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			ConExecute 'UI_SelectByCategory AIR GROUNDATTACK'
		end
	end) end,
	['Ctrl-D'] = function() Hotkey('Ctrl-D', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		else
			ConExecute 'UI_SelectByCategory +inview FACTORY LAND'
		end
	end) end,
	['Ctrl-Shift-D'] = function() Hotkey('Ctrl-Shift-D', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		else
			ConExecute 'UI_SelectByCategory FACTORY LAND'
		end
	end) end,
	['Alt-D'] = function() Hotkey('Alt-D', function(hotkey)
		CreateOrContinueSelection("damage", "auto")
	end) end,
	['Alt-Shift-D'] = function() Hotkey('Alt-Shift-D', function(hotkey)
		CreateOrContinueSelection("health", "auto")
	end) end,

	F = function() Hotkey('F', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		elseif AllHaveCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
			print("All torpedo bombers")
			ConExecute 'UI_SelectByCategory +inview AIR ANTINAVY'

			SubHotkeys({
				['D'] = function() SubHotkey('D', function(hotkey)
					print("All torpedo bombers")
					ConExecute 'UI_SelectByCategory AIR ANTINAVY'
				end) end,
			})
		end
	end) end,
	['Shift-F'] = function() Hotkey('Shift-F', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		elseif AllHaveCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
            ConExecute 'UI_SelectByCategory AIR ANTINAVY'
		end
	end) end,
	['Ctrl-F'] = function() Hotkey('Ctrl-F', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		end
	end) end,
	['Ctrl-Shift-F'] = function() Hotkey('Ctrl-Shift-F', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		end
	end) end,
	['Alt-F'] = function() Hotkey('Alt-F', function(hotkey)
		CreateOrContinueSelection("furthest", "auto")
	end) end,
	['Alt-Shift-F'] = function() Hotkey('Alt-Shift-F', function(hotkey)
		CreateOrContinueSelection("closest", "auto")
	end) end,

	G = function() Hotkey('G', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		else
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(true)'
		end
	end) end,
	['Shift-G'] = function() Hotkey('G', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		else
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(false)'
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
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").CycleTemplates()'
		end
	end) end,
	['Shift-Chevron'] = function() Hotkey('Shift-Chevron', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			Functions.ToggleRepeatBuildOrSetTo(false)
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5, false)'
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").CycleTemplates()'
		end
	end) end,
	['Ctrl-Chevron'] = function() Hotkey('Ctrl-Chevron', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()' -- TODO
		end
	end) end,
	['Ctrl-Shift-Chevron'] = function() Hotkey('Ctrl-Shift-Chevron', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()' -- TODO
		end
	end) end,

	Z = function() Hotkey('Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		else
			ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH2'
			if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH2) and AllHaveCategory(categories.STRUCTURE) then
				CreateOrContinueSelection("closest", "auto")
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
			end
		end
	end) end,
	['Shift-Z'] = function() Hotkey('Shift-Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		else
			ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH2'
			if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH2) and AllHaveCategory(categories.STRUCTURE) then
				CreateOrContinueSelection("closest", "auto")
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
			end
		end
	end) end,
	['Ctrl-Z'] = function() Hotkey('Ctrl-Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		end
	end) end,
	['Ctrl-Shift-Z'] = function() Hotkey('Ctrl-Shift-Z', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		end
	end) end,
	['Alt-Z'] = function() Hotkey('Alt-Z', function(hotkey)
        ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH3'
		if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH3) and AllHaveCategory(categories.STRUCTURE) then
			CreateOrContinueSelection("furthest", "auto")
		end
	end) end,
	['Alt-Shift-Z'] = function() Hotkey('Alt-Shift-Z', function(hotkey)
        ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH3'
		if AllHaveCategory(categories.ARTILLERY) and AllHaveCategory(categories.TECH3) and AllHaveCategory(categories.STRUCTURE) then
			CreateOrContinueSelection("furthest", "auto")
			ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,

	X = function() Hotkey('X', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		elseif AllHaveCategory(categories.TACTICALMISSILEPLATFORM) then
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectTmlFireMissile()'
		elseif AllHaveCategory(categories.NUKE) then
			ConExecute 'StartCommandMode order RULEUCC_Nuke'
		else
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectTmlFireMissile()'
			if AllHaveCategory(categories.TACTICALMISSILEPLATFORM) then
				CreateOrContinueSelection("closest_missile", "auto") -- Manual cycle, tab, doesnt work properly
			end
		end
	end) end,
	['Shift-X'] = function() Hotkey('Shift-X', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		else
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectTmlFireMissile()'
		end
	end) end,
	['Ctrl-X'] = function() Hotkey('Ctrl-X', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		end
	end) end,
	['Ctrl-Shift-X'] = function() Hotkey('Ctrl-Shift-X', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		end
	end) end,
	['Alt-X'] = function() Hotkey('Alt-X', function(hotkey)
		ConExecute "UI_SelectByCategory NUKE"
		if AllHaveCategory(categories.NUKE) then
			CreateOrContinueSelection("furthest_missile", "auto")
		else
			PlaySound(Sound { Cue = "UI_Menu_Error_01", Bank = "Interface" })
		end
	end) end,

	C = function() Hotkey('C', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		end
	end) end,
	['Shift-C'] = function() Hotkey('Shift-C', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_2")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		end
	end) end,
	['Ctrl-C'] = function() Hotkey('Ctrl-C', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		end
	end) end,
	['Ctrl-Shift-C'] = function() Hotkey('Ctrl-Shift-C', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		end
	end) end,
	['Alt-C'] = function() Hotkey('Alt-C', function(hotkey)
		-- TODO
	end) end,

	V = function() Hotkey('V', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimentals")' -- TODO, doesn't work?
		end
	end) end,
	['Shift-V'] = function() Hotkey('Shift-V', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_3")'
		elseif AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimental")' -- TODO, doesn't work?
		end
	end) end,
	['Ctrl-V'] = function() Hotkey('Ctrl-V', function(hotkey)
		if AllHaveCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Stations")'
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
		else
			ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/copy-queue.lua").CopyOrders()'
		end
	end) end,
	['Shift-B'] = function() Hotkey('Shift-B', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_4")'
		else
			ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/copy-queue.lua").CopyOrders()'
		end
	end) end,

	N = function() Hotkey('N', function(hotkey)
		if AllHaveCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
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
