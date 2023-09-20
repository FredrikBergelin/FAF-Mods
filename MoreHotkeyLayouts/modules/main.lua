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

	if subHotkey ~= nil then
		-- subHotkeys = nil
		ForkThread(subHotkey)
	else
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
	end) end,
	F2 = function() Hotkey('F2', function(hotkey)
		-- 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("AlertExtended")'
	end) end,
	F3 = function() Hotkey('F3', function(hotkey)
		-- 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("Util")'
	end) end,
	F4 = function() Hotkey('F4', function(hotkey)
		-- 'UI_Lua import("/mods/ChatWheel/modules/CWMain.lua").call()'
	end) end,

	Backslash = function() Hotkey('Backslash', function(hotkey)
		-- 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").ACUSelectOCGoto()'
	end) end,

	['1'] = function() Hotkey('1', function(hotkey) end) end,
	['2'] = function() Hotkey('2', function(hotkey) end) end,
	['3'] = function() Hotkey('3', function(hotkey) end) end,
	['4'] = function() Hotkey('4', function(hotkey) end) end,

	Tab = function() Hotkey('Tab', function(hotkey)
		-- 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest")'
	end) end,

	Q = function() Hotkey('Q', function(hotkey)
		if AnyUnitSelected() then
			print("Patrol Mode")
			ConExecute 'StartCommandMode order RULEUCC_Patrol'
		else
		end
	end) end,

	W = function() Hotkey('W', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("W_Factory")'
		elseif AnyUnitSelected() then
			print("Attack Mode")
			ConExecute 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()'
		end
	end) end,

	E = function() Hotkey('E', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("E_Factory")'
		elseif AnyUnitSelected() then
			print("Reclaim Mode")
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
			SubHotkeys({
				F1 = function() Repeater('F1', function(hotkey)
					print('Select T1 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', false)
				end) end,
				F2 = function() Repeater('F2', function(hotkey)
					print('Select T2 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('2', false)
				end) end,
				F3 = function() Repeater('F3', function(hotkey)
					print('Select T3 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', false)
				end) end,
				F4 = function() Repeater('F4', function(hotkey)
					print('Select SACU')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', false)
				end) end,
				['1'] = function() Repeater('1', function(hotkey)
					print('Select idle T1 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', true)
				end) end,
				['2'] = function() Repeater('2', function(hotkey)
					print('Select idle T2 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('2', true)
				end) end,
				['3'] = function() Repeater('3', function(hotkey)
					print('Select idle T3 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', true)
				end) end,
				['4'] = function() Repeater('4', function(hotkey)
					print('Select idle SACU')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('3', true)
				end) end,
			})
		end
	end) end,

	R = function() Hotkey('R', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/lua/keymap/hotbuild.lua").buildAction("R_Factory")'
		end
	end) end,

	CapsLock = function() Hotkey('CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").MultiPause(true)
	end) end,

	['Ctrl-CapsLock'] = function() Hotkey('Ctrl-CapsLock', function(hotkey)
		import("/mods/MultiHotkeys/modules/orders.lua").MultiPause(false)
	end) end,

	['Shift-CapsLock'] = function() Hotkey('Shift-CapsLock', function(hotkey)
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

	S = function() Hotkey('S', function(hotkey)
	end) end,

	D = function() Hotkey('D', function(hotkey)
	end) end,

	F = function() Hotkey('F', function(hotkey)
	end) end,

	Chevron = function() Hotkey('Chevron', function(hotkey)
		if AnyHasCategory(categories.ENGINEER) or AnyHasCategory(categories.FACTORY) then
			ConExecute 'UI_Lua import("/mods/HotkeyTechTabs/modules/UITabs.lua").SelectTab(5)'
		end
	end) end,

	Z = function() Hotkey('Z', function(hotkey)
		if AllHasCategory(categories.FACTORY) then
			print("Toggle repeat")
			ConExecute 'UI_Lua import("/lua/keymap/misckeyactions.lua").OCOrRepeatBuild()'
		end
	end) end,

	X = function() Hotkey('X', function(hotkey)
	end) end,

	C = function() Hotkey('C', function(hotkey)
	end) end,

	V = function() Hotkey('V', function(hotkey)
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
