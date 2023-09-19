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

local function Wrapper(hotkey, func)
	LOG("Wrapper "..hotkey)

	local subHotkey = subHotkeys[hotkey]
	subHotkeys = nil

	if subHotkey ~= nil then
		LOG("Subkey exists")
		ForkThread(subHotkey)
	else
		func(hotkey)
	end
end

local function SetSubHotkeys(obj)
	subHotkeys = obj
end

local customKeyMap = {

	E = function() Wrapper('E', function(hotkey)
		if AnyUnitSelected() then
			print("Reclaim Mode")
			ConExecute 'StartCommandMode order RULEUCC_Reclaim'
		else
			SetSubHotkeys({
				['1'] = function() Wrapper('1', function(hotkey)
					print(' --> '..hotkey..': Select Nearest T1 Engineer')
					import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', false)
					SetSubHotkeys({
						['1'] = function() Wrapper('1', function(hotkey)
							print(' --> '..hotkey..': Select T1 Engineers on screen')
							import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', false)
							SetSubHotkeys({
								['1'] = function() Wrapper('1', function(hotkey)
									print(' --> '..hotkey..': Select T1 Engineers on map')
									import('/mods/MultiHotkeys/modules/selection.lua').MultiSelectEngineers('1', false)
								end) end,
							})
						end) end,
					})
				end) end,
			})
		end
	end) end,

	H = function()
			Wrapper('H', function(hotkey)
			subHotkeys = nil
		end)
	end,

	['1'] = function() Wrapper('1', function(hotkey)
		subHotkeys = nil
	end) end,
}

function RunCustom(key)
	ForkThread(customKeyMap[key])
end

function Init()
	from(customKeyMap).foreach(function(k, v)
		userKeyActions['SHK '..k] = {
			action = 'UI_Lua import("/mods/MoreHotkeyLayouts/modules/main.lua").RunCustom("'..k..'")',
			category = 'SHK'
		}
		userKeyMap[k] = 'SHK '..k
	end)

	Prefs.SetToCurrentProfile('UserKeyActions', userKeyActions)
	Prefs.SetToCurrentProfile('UserKeyMap', userKeyMap)
end
