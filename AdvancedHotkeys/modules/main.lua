local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions')
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap')

modPath = '/mods/AdvancedHotkeys'
conditionalsPath = modPath .. '/modules/conditionals.lua'

local currentSubKeys = nil
local lastClickTime = -9999

advancedKeyMap = {
	['0'] = {
		{
			print = '0 was pressed',
		},
		{
			execute = 'StartCommandMode order RULEUCC_Patrol',
		},
		{
			conditionals = {
				{
					func = 'AllSelectedHaveCategory',
					args = 'categories.ENGINEER',
					checkFor = true,
				},
				{
					func = 'AllSelectedHaveCategory',
					args = 'categories.TECH1',
					checkFor = true,
				}
			},
			valid = {
				{
					print = 'Conditionals are Valid',
				},
			},
			invalid = {
				{
					print = 'Conditionals are Invalid',
				},
			},
		},
		{
			subkeys = {
				['0'] = {
					{
						print = 's 0',
					},
				},
			}
		}
	},
}

-- An advanced hotkey has been pressed, we determine if it should fetch the action from the regular keymap or from a stored subkey
function RouteHotkey(key)
	LOG('RouteHotkey(' .. key .. ')')

	local currentTime = GetSystemTimeSeconds()
	local diffTime = currentTime - lastClickTime
	lastClickTime = currentTime

	-- Try to get any stored subkey from last press
	local subKeyAction = currentSubKeys[key]

	if subKeyAction ~= nil then
		local decay = 0.002 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
		local inTime = diffTime < decay

		if inTime then
			-- Run the stored subkey action for this hotkey
			ExecuteRecursively(subKeyAction)
			return
		end
	end

	currentSubKeys = nil

	if advancedKeyMap[key] ~= nil then ExecuteRecursively(advancedKeyMap[key]) end
end

function CheckConditionals(conditionals)
	local valid = true

	for k, conditional in pairs(conditionals) do if not valid then break end
		local executable = GetConditionalExecutable(conditional)
		valid = conditional.checkFor == ConditionalConExecute(executable)
	end

	return valid
end

function ExecuteRecursively(entries)
	for entryKey, entry in entries do
		if entry['print'] ~= nil then print(entry['print']) end

		if entry['execute'] ~= nil then ConExecute(entry['execute']) end

		if entry['conditionals'] ~= nil then
			local valid = CheckConditionals(entry['conditionals'])

			if valid then
				if entry['valid'] ~= nil then ExecuteRecursively(entry['valid']) end
			else
				if entry['invalid'] ~= nil then ExecuteRecursively(entry['invalid']) end
			end
		end

		currentSubKeys = entry['subkeys']
	end
end

function GetConditionalExecutable(entry)
	return entry.execute or 'UI_Lua import("' .. (entry.path or
		conditionalsPath) .. '").' .. entry.func .. '(' .. entry.args .. ')'
end

function ConditionalConExecute(executable)
	ConExecute(executable)

	return GlobalConditionalBool
end

function InitAdvancedKeys()
	local hotkeysOrdered = import('/mods/AdvancedHotkeys/modules/allKeys.lua').keyOrder

	for i, v in hotkeysOrdered do
		local name = string.gsub(v, '-', '_')
		userKeyActions['AHK ' .. name] = {
			action = 'UI_Lua import("/mods/AdvancedHotkeys/modules/main.lua").RouteHotkey("' .. v .. '")',
			category = 'Advanced Hotkeys Override'
		}
		-- userKeyMap[v] = 'AHK ' .. name
	end

	Prefs.SetToCurrentProfile('UserKeyActions', userKeyActions)
	-- Prefs.SetToCurrentProfile('UserKeyMap', userKeyMap)
end

function LoadKeyMap()
	advancedKeyMap = GetPreference('AdvancedHotkeysKeyMap')
end
