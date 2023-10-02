local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions')
	-- ['Cycle next, defaults to closest'] = {
	-- 	action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()',
	-- 	category = 'Command Cycler'
	-- },
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap')
	-- Tab = 'Cycle next, defaults to closest',

local SingleOrDoubleClick = import('/mods/common/modules/misc.lua').SingleOrDoubleClick -- (uniqueIdentifier, singleClickFunction, doubleClickFunction)
local ClickCount = import('/mods/common/modules/misc.lua').ClickCount -- (uniqueIdentifier)
local AnyUnitSelected = import('/mods/common/modules/misc.lua').AnyUnitSelected -- ()

local current = nil
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

local function Repeater(hotkey, func)
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

local function SubHotkeys(obj)
	subHotkeys = obj
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

local function AllHasCategory(category)
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

local GetUpgradesOfUnit = import("/lua/ui/game/hotkeys/upgrade-structure.lua").GetUpgradesOfUnit
local TablEmpty = table.empty

local function AnyUnitCanUpgrade()
    local units = GetSelectedUnits()

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

function ToggleRepeatBuildOrSetTo(setTo)
    local selection = GetSelectedUnits()
    if selection then
		local verifiedSetTo

		if setTo ~= nil then
			verifiedSetTo = setTo
		else
			for _, v in selection do
				if v:IsInCategory('FACTORY') then
					if v:IsRepeatQueue() then
						verifiedSetTo = true
					end
				end
			end
		end

		for _, v in selection do
			if verifiedSetTo then
				v:ProcessInfo('SetRepeatQueue', 'true')
			else
				v:ProcessInfo('SetRepeatQueue', 'false')
			end
		end
    end
end

local Functions = import("/mods/MoreHotkeyLayouts/modules/functions.lua")

local customKeyMap = {

	-- ['Esc'] = function() Hotkey('Esc', function(hotkey)
	-- 	ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("Util")'
	-- end) end,

	F1 = function() Hotkey('F1', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("Util")'
	end) end,
	F2 = function() Hotkey('F2', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("TargetPriorityExtended")'
	end) end,
	F3 = function() Hotkey('F3', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("AlertExtended")'
	end) end,
	F4 = function() Hotkey('F4', function(hotkey)
		ConExecute 'UI_Lua import("/mods/ChatWheel/modules/CWMain.lua").call()'
	end) end,
	F5 = function() Hotkey('F5', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTab("diplomacy")'
		-- Stops working after adding / removing a few rings, no error message
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenMenu("Default")'
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenWheel("Default")'
	end) end,
	F6 = function() Hotkey('F6', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleScore()'
	end) end,
	F7 = function() Hotkey('F7', function(hotkey)
		-- 
	end) end,
	F8 = function() Hotkey('F8', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/connectivity.lua").CreateUI()'
	end) end,
	F9 = function() Hotkey('F9', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/objectivedetail.lua").ToggleDisplay()'
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

	['1'] = function() Hotkey('1', function(hotkey) end) end,
	['2'] = function() Hotkey('2', function(hotkey) end) end,
	['3'] = function() Hotkey('3', function(hotkey) end) end,
	['4'] = function() Hotkey('4', function(hotkey) end) end,
	['5'] = function() Hotkey('5', function(hotkey) end) end,
	['6'] = function() Hotkey('6', function(hotkey) end) end,
	['7'] = function() Hotkey('7', function(hotkey) end) end,
	['8'] = function() Hotkey('8', function(hotkey) end) end,
	['9'] = function() Hotkey('9', function(hotkey) end) end,
	['0'] = function() Hotkey('0', function(hotkey) end) end,

	Tab = function() Hotkey('Tab', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(nil)'
	end) end,
	['Shift-Tab'] = function() Hotkey('Shift-Tab', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(nil, nil, true)'
	end) end,
	['Ctrl-Tab'] = function() Hotkey('Ctrl-Tab', function(hotkey)
		SubHotkeys({
			['1'] = function() Repeater('1', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest")'
			end) end,
			['2'] = function() Repeater('2', function(hotkey)
			end) end,
			['3'] = function() Repeater('3', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health")'
			end) end,
			['4'] = function() Repeater('4', function(hotkey)
			end) end,
		})
	end) end,

	Q = function() Hotkey('Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
            ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH1")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))

			SubHotkeys({
				['2'] = function() Repeater('2', function(hotkey)
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))
				end) end,
				['3'] = function() Repeater('3', function(hotkey)
					ConExecute("UI_SelectByCategory +inview BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))
				end) end,
			})
		end
	end) end,
	['Shift-Q']  = function() Hotkey('Shift-Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
            ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH1")
			SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))

			SubHotkeys({
				['2'] = function() Repeater('2', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH2")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))
				end) end,
				['3'] = function() Repeater('3', function(hotkey)
					ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY ENGINEER TECH3")
					SelectUnits(Functions.SelectedUnitsWithOnlyTheseCommands({"Idle", "Move", "Patrol"}))
				end) end,
			})
		end
	end) end,
	['Ctrl-Q'] = function() Hotkey('Ctrl-Q', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		end
	end) end,
	['Ctrl-Shift-Q'] = function() Hotkey('Ctrl-Shift-Q', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		end
	end) end,
	['Alt-Q'] = function() Hotkey('Alt-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").SelectPatrolUnits()'
	end) end,
	['Alt-Shift-Q'] = function() Hotkey('Alt-Shift-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").ConvertToMove()'
	end) end,

	W = function() Hotkey('W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		else
			ConExecute 'UI_SelectByCategory +inview AIR HIGHALTAIR ANTIAIR'
		end
	end) end,
	['Shift-W'] = function() Hotkey('Shift-W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		else
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
		end 
	end) end,
	['Ctrl-W'] = function() Hotkey('Ctrl-W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Ctrl-Shift-W'] = function() Hotkey('Ctrl-Shift-W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			ConExecute 'StartCommandMode order RULEUCC_Attack'
		end
	end) end,
	['Alt-W'] = function() Hotkey('Alt-W', function(hotkey)
	end) end,
	['Alt-Shift-W'] = function() Hotkey('Alt-Shift-W', function(hotkey)
	end) end,

	E = function() Hotkey('E', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
            ConExecute("UI_SelectByCategory +inview AIR BOMBER")
			SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))
		end
	end) end,
	['Shift-E'] = function() Hotkey('Shift-E', function(hotkey)
		ConExecute("UI_SelectByCategory AIR BOMBER")
		SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))
	end) end,
	['Ctrl-E'] = function() Hotkey('Ctrl-E', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
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
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		else
			-- Functions.NoLoadedUnits -- TODO
			ConExecute 'UI_SelectByCategory +inview +idle AIR TRANSPORTATION'
			SubHotkeys({
				R = function() Repeater('R', function(hotkey)
					ConExecute 'UI_SelectByCategory +inview +idle AIR TRANSPORTATION'
					SubHotkeys({
						R = function() Repeater('R', function(hotkey)
							ConExecute 'UI_SelectByCategory +idle AIR TRANSPORTATION'
						end) end,
					})
				end) end,
			})
		end
	end) end,
	['Shift-R'] = function() Hotkey('Shift-R', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		elseif AnyHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		else
			-- Functions.NoLoadedUnits -- TODO
			ConExecute 'UI_SelectByCategory +idle AIR TRANSPORTATION'
			SubHotkeys({
				R = function() Repeater('R', function(hotkey)
					ConExecute 'UI_SelectByCategory +inview +idle AIR TRANSPORTATION'
					SubHotkeys({
						R = function() Repeater('R', function(hotkey)
							ConExecute 'UI_SelectByCategory +idle AIR TRANSPORTATION'
						end) end,
					})
				end) end,
			})
		end
	end) end,
	['Ctrl-R'] = function() Hotkey('Ctrl-R', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		elseif AllHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		end
	end) end,
	['Ctrl-Shift-R'] = function() Hotkey('Ctrl-Shift-R', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_7")'
		end
	end) end,
	['Alt-R'] = function() Hotkey('Alt-R', function(hotkey)
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
	end) end,
	['Alt-Shift-R'] = function() Hotkey('Alt-Shift-R', function(hotkey)
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()'
	end) end,

	T = function() Hotkey('T', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetToMouseTargetOrDefault()'
			SubHotkeys({
				-- TODO: Make queueable targeting, by holding shift, it puts it after order finishes? 
				['2'] = function() Repeater('2', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("TorpBomber")'
				end) end,
				['3'] = function() Repeater('3', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Gunship")'
				end) end,
				['4'] = function() Repeater('4', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Bomber")'
				end) end,
				Q = function() Repeater('Q', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Arty")'
				end) end,
				W = function() Repeater('W', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Units")'
				end) end,
				E = function() Repeater('E', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Engies")'
				end) end,
				R = function() Repeater('R', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Snipe")'
				end) end,
				A = function() Repeater('A', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("ACU")'
				end) end,
				S = function() Repeater('S', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Mex")'
				end) end,
				D = function() Repeater('D', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Power")'
				end) end,
				F = function() Repeater('F', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Factory")'
				end) end,
				Z = function() Repeater('Z', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("Shields")'
				end) end,
				X = function() Repeater('X', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("PD")'
				end) end,
				C = function() Repeater('C', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("AA")'
				end) end,
				V = function() Repeater('V', function(hotkey)
					ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetWeaponPrioritiesHotkey("EXP")'
				end) end,
			})
		end
	end) end,

	['Ctrl-T'] = function() Hotkey('T', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		end
	end) end,

	-- 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(true)'
	-- 'UI_Lua import("/lua/ui/game/hotkeys/load-in-transport.lua").LoadIntoTransports(false)'

	Y = function() Hotkey('Y', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		else
			-- Select Enhancements tab
			SubHotkeys({
				-- TODO: Make queueable targeting, by holding shift, it puts it after order finishes? 
				T = function() Repeater('T', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTechUpgrade()'
				end) end,
				U = function() Repeater('U', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderGunUpgrade()'
				end) end,
				H = function() Repeater('H', function(hotkey)
					ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderNanoUpgrade()'
				end) end,
			})
		end
	end) end,

	U = function() Hotkey('U', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		end
	end) end,

	P = function() Hotkey('P', function(hotkey)
		ConExecute 'UI_Lua import("/lua/ui/game/zoompopper.lua").ToggleZoomPop()'
	end) end,

	CapsLock = function() Hotkey('CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(false)
	end) end,
	['Shift-CapsLock'] = function() Hotkey('Shift-CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(true)
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
		if AllHasCategory(categories.ENGINEER) then
			local hoveredUnit = GetRolloverInfo().userUnit
			if hoveredUnit and not IsDestroyed(hoveredUnit) and hoveredUnit:IsInCategory('STRUCTURE') then
				ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/capping.lua").HotkeyToCap(true, true)'
			else
				ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()'
			end
		elseif AnyUnitCanUpgrade() then
			ConExecute 'UI_LUA import("/lua/keymap/hotbuild.lua").buildActionUpgrade()'
		else
			print("In-view Fighters")
			ConExecute 'UI_SelectByCategory +inview AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))
		end
	end) end,
	['Shift-A'] = function() Hotkey('Shift-A', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			local hoveredUnit = GetRolloverInfo().userUnit
			if hoveredUnit and not IsDestroyed(hoveredUnit) and hoveredUnit:IsInCategory('STRUCTURE') then
				ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/capping.lua").HotkeyToCap(true, false)'
			else
				ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()'
			end
		elseif AnyUnitCanUpgrade() then
			ConExecute 'UI_LUA import("/lua/keymap/hotbuild.lua").buildActionUpgrade()'
		else
			print("All Fighters")
			ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
			SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))
		end
	end) end,
	['Ctrl-A'] = function() Hotkey('Ctrl-A', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		end
	end) end,
	['Ctrl-Shift-A'] = function() Hotkey('Ctrl-Shift-A', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AirFact")'
		end
	end) end,
	['Alt-A'] = function() Hotkey('Alt-A', function(hotkey)
		print("In-view Similar units")
		Functions.SelectSimilarUnits("+inview")

		SubHotkeys({
			['Alt-S'] = function() Repeater('Alt-S', function(hotkey)
				print("All Similar units")
				Functions.SelectSimilarUnits()
			end) end,
		})
	end) end,
	['Alt-Shift-A'] = function() Hotkey('Alt-Shift-A', function(hotkey)

	end) end,

	S = function() Hotkey('S', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		else
			print("In-view intel planes")
            ConExecute 'UI_SelectByCategory +inview AIR INTELLIGENCE'
		end
	end) end,
	['Shift-S'] = function() Hotkey('Shift-S', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		else
			print("All intel planes")
            ConExecute 'UI_SelectByCategory AIR INTELLIGENCE'
		end
	end) end,
	['Ctrl-S'] = function() Hotkey('Ctrl-S', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_NavalFact")'
		end
	end) end,
	['Ctrl-Shift-S'] = function() Hotkey('Ctrl-Shift-S', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_NavalFact")'
		end
	end) end,
	['Alt-S'] = function() Hotkey('Alt-S', function(hotkey)

	end) end,

	D = function() Hotkey('D', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_2")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			ConExecute 'UI_SelectByCategory +inview AIR GROUNDATTACK'

		end
	end) end,
	['Shift-D'] = function() Hotkey('Shift-D', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		else
			ConExecute 'UI_SelectByCategory AIR GROUNDATTACK'
		end
	end) end,
	['Ctrl-D'] = function() Hotkey('Ctrl-D', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		end
	end) end,
	['Ctrl-Shift-D'] = function() Hotkey('Ctrl-Shift-D', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_LandFact")'
		end
	end) end,
	['Alt-D'] = function() Hotkey('Alt-D', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("damage")'
	end) end,
	['Alt-Shift-D'] = function() Hotkey('Alt-Shift-D', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health")'
		-- ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/distribute-queue.lua").DistributeOrders(true)' -- ??
	end) end,

	F = function() Hotkey('F', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		elseif AllHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		else
            ConExecute 'UI_SelectByCategory +inview AIR ANTINAVY'
		end
	end) end,
	['Shift-F'] = function() Hotkey('Shift-F', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_3")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		else
            ConExecute 'UI_SelectByCategory AIR ANTINAVY'
		end
	end) end,
	['Ctrl-F'] = function() Hotkey('Ctrl-F', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		end
	end) end,
	['Ctrl-Shift-F'] = function() Hotkey('Ctrl-Shift-F', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Sonar")'
		end
	end) end,
	['Alt-F'] = function() Hotkey('Alt-F', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest")'
	end) end,
	['Alt-Shift-F'] = function() Hotkey('Alt-Shift-F', function(hotkey)
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest")'
	end) end,

	G = function() Hotkey('G', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_4")'
		end
	end) end,

	H = function() Hotkey('H', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_5")'
		end
	end) end,

	J = function() Hotkey('J', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_6")'
		end
	end) end,

	K = function() Hotkey('K', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_7")'
		end
	end) end,

	L = function() Hotkey('L', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_8")'
		end
	end) end,

	Chevron = function() Hotkey('Chevron', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ToggleRepeatBuildOrSetTo(false)
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5, false)'
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").CycleTemplates()'
		end
	end) end,
	['Shift-Chevron'] = function() Hotkey('Shift-Chevron', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ToggleRepeatBuildOrSetTo(true)
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5, false)'
			ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").CycleTemplates()'
		end
	end) end,
	['Ctrl-Chevron'] = function() Hotkey('Ctrl-Chevron', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()' -- TODO
		end
	end) end,
	['Ctrl-Shift-Chevron'] = function() Hotkey('Ctrl-Shift-Chevron', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/ui/game/hotkeys/context-based-templates.lua").Cycle()' -- TODO
		end
	end) end,


	Z = function() Hotkey('Z', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		end
	end) end,
	['Shift-Z'] = function() Hotkey('Shift-Z', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		end
	end) end,
	['Ctrl-Z'] = function() Hotkey('Ctrl-Z', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		end
	end) end,
	['Ctrl-Shift-Z'] = function() Hotkey('Ctrl-Shift-Z', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_MissileDef")'
		end
	end) end,
	['Alt-Z'] = function() Hotkey('Alt-Z', function(hotkey)
        ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH2'
		ConExecute 'StartCommandMode order RULEUCC_Attack'
	end) end,
	['Alt-Shift-Z'] = function() Hotkey('Alt-Shift-Z', function(hotkey)
        ConExecute 'UI_SelectByCategory STRUCTURE ARTILLERY TECH3'
		ConExecute 'StartCommandMode order RULEUCC_Attack'
	end) end,

	X = function() Hotkey('X', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		end
	end) end,
	['Shift-X'] = function() Hotkey('Shift-X', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_1")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_PD")'
		end
	end) end,
	['Ctrl-X'] = function() Hotkey('Ctrl-X', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		end
	end) end,
	['Ctrl-Shift-X'] = function() Hotkey('Ctrl-Shift-X', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ArtyMissiles")'
		end
	end) end,
	['Alt-X'] = function() Hotkey('Alt-X', function(hotkey)
		ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectTmlFireMissile()'
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest_missile")' -- Manual cycle, tab, doesnt work properly
	end) end,

	C = function() Hotkey('C', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_2")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		end
	end) end,
	['Shift-C'] = function() Hotkey('Shift-C', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_AntiAir")'
		end
	end) end,
	['Ctrl-C'] = function() Hotkey('Ctrl-C', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		end
	end) end,
	['Ctrl-Shift-C'] = function() Hotkey('Ctrl-Shift-C', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_TorpedoDef")'
		end
	end) end,
	['Alt-C'] = function() Hotkey('Alt-C', function(hotkey)
		ConExecute 'UI_LUA import("/lua/ui/game/hotkeys/copy-queue.lua").CopyOrders()'
	end) end,

	V = function() Hotkey('V', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_3")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimental")'
		end
	end) end,
	['Shift-V'] = function() Hotkey('Shift-V', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Experimental")'
		end
	end) end,
	['Ctrl-V'] = function() Hotkey('Ctrl-V', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Stations")'
		end
	end) end,
	['Ctrl-Shift-V'] = function() Hotkey('Ctrl-Shift-V', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Stations")'
		end
	end) end,

	B = function() Hotkey('B', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_4")'
		end
	end) end,

	N = function() Hotkey('N', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T3_5")'
		end
	end) end,
	['Alt-N'] = function() Hotkey('Alt-N', function(hotkey)
		ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectSmlFireMissile()'
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest_missile")' -- TODO
	end) end,

	M = function() Hotkey('M', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
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
		-- TODO: Group bsed on blueprint and split equally 
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
