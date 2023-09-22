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
	local decay = 0.004 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
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

local customKeyMap = {

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
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
	end) end,
	F6 = function() Hotkey('F6', function(hotkey)
		ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()'
	end) end,
	F7 = function() Hotkey('F7', function(hotkey)
		-- Stops working after adding / removing a few rings, no error message
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenMenu("Default")'
		-- ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenWheel("Default")'
	end) end,
	F8 = function() Hotkey('F8', function(hotkey)
	end) end,
	F9 = function() Hotkey('F9', function(hotkey)
	end) end,
	F10 = function() Hotkey('F10', function(hotkey)
	end) end,
	F11 = function() Hotkey('F11', function(hotkey)
	end) end,
	F12 = function() Hotkey('F12', function(hotkey)
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
		ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()'
	end) end,
	['Ctrl-Tab'] = function() Hotkey('Ctrl-Tab', function(hotkey)
		SubHotkeys({
			['1'] = function() Repeater('1', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest")'
			end) end,
			['2'] = function() Repeater('2', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest")'
			end) end,
			['3'] = function() Repeater('3', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health")'
			end) end,
			['4'] = function() Repeater('4', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("damage")'
			end) end,
			['A'] = function() Repeater('A', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()'
			end) end,
			['Q'] = function() Repeater('Q', function(hotkey)
				ConExecute 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectRest()'
			end) end,
		})
	end) end,

	Q = function() Hotkey('Q', function(hotkey)
		if AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
		end
	end) end,
	['Alt-Q'] = function() Hotkey('Alt-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").SelectPatrolUnits()'
	end) end,
	['Ctrl-Shift-Q'] = function() Hotkey('Ctrl-Shift-Q', function(hotkey)
		ConExecute 'UI_Lua import("/mods/patrol2move/modules/module.lua").ConvertToMove()'
	end) end,

	W = function() Hotkey('W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		end
	end) end,
	['Shift-W'] = function() Hotkey('Shift-W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_1")'
		elseif AnyUnitSelected() then
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		end
	end) end,
	['Ctrl-W'] = function() Hotkey('Ctrl-W', function(hotkey)
		ConExecute 'StartCommandMode order RULEUCC_Attack'
	end) end,
	['Alt-W'] = function() Hotkey('Alt-W', function(hotkey)
		ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetToMouseTargetOrDefault()'
	end) end,

	E = function() Hotkey('E', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_2")'
		elseif AnyUnitSelected() then
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
			SubHotkeys({
				F1 = function() Repeater('F1', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', false)
				end) end,
				F2 = function() Repeater('F2', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('2', false)
				end) end,
				F3 = function() Repeater('F3', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', false)
				end) end,
				F4 = function() Repeater('F4', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectSACU(false)
				end) end,
				['1'] = function() Repeater('1', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', true)
				end) end,
				['2'] = function() Repeater('2', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('2', true)
				end) end,
				['3'] = function() Repeater('3', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', true)
				end) end,
				['4'] = function() Repeater('4', function(hotkey)
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectSACU(true)
				end) end,
			})
		end
	end) end,

	R = function() Hotkey('R', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_3")'
		else
			ConExecute 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()'
		end
	end) end,

	T = function() Hotkey('T', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_4")'
		elseif AllHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Transport'
		else
			ConExecute "UI_SelectByCategory +nearest +idle AIR TRANSPORTATION"
		end
	end) end,

	Y = function() Hotkey('Y', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_5")'
		end
	end) end,

	U = function() Hotkey('U', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T1_6")'
		end
	end) end,

	CapsLock = function() Hotkey('CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(true)
	end) end,
	['Shift-CapsLock'] = function() Hotkey('Shift-CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").SetProductionAndAbilities(false)
	end) end,
	['Ctrl-CapsLock'] = function() Hotkey('Ctrl-CapsLock', function(hotkey)
		ToggleRepeatBuildOrSetTo(true)
	end) end,
	['Alt-CapsLock'] = function() Hotkey('Alt-CapsLock', function(hotkey)
		ToggleRepeatBuildOrSetTo(false)
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

	S = function() Hotkey('S', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
		end
	end) end,
	['Shift-S'] = function() Hotkey('Shift-S', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_T2_1")'
		elseif AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Mex")'
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

	D = function() Hotkey('D', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
		end
	end) end,
	['Shift-D'] = function() Hotkey('Shift-D', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Power")'
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

	F = function() Hotkey('F', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
		elseif AllHasCategory(categories.TRANSPORTATION) then
			ConExecute 'StartCommandMode order RULEUCC_Ferry'
		end
	end) end,
	['Shift-F'] = function() Hotkey('Shift-F', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_Radar")'
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

	Chevron = function() Hotkey('Chevron', function(hotkey)
		if AnyHasCategory(categories.ENGINEER) or AnyHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5)'
		end
	end) end,

	Z = function() Hotkey('Z', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("HBO_ShieldsStealth")'
		elseif AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").OCOrRepeatBuild()'
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
	end) end,
	['Ctrl-Alt-X'] = function() Hotkey('Ctrl-Alt-X', function(hotkey)
		ConExecute 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectSmlFireMissile()'
	end) end,

	C = function() Hotkey('C', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
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

	V = function() Hotkey('V', function(hotkey)
		if AllHasCategory(categories.ENGINEER) then
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
