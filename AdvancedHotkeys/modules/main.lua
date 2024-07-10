local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions') -- Eg: ['Cycle next, defaults to closest'] = { action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()', ... },
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap') -- Eg: Tab = 'Cycle next, defaults to closest',

modPath = '/mods/AdvancedHotkeys'
conditionalsPath = modPath .. '/modules/conditionals.lua'

local currentSubKeys = nil
local subKeyAction = nil

local lastClickTime = -9999

local keyMap = {
	['0'] = {
		{
			immediate = {
				{
					print = '0',
				},
			},
			conditionals = {
				{
					func = 'AllHaveCategory',
					args = 'categories.ENGINEER',
					checkFor = true,
				},
				{
					func = 'AllHaveCategory',
					args = 'categories.COMMAND',
					checkFor = true,
				}
			},
			valid = {},
			invalid = {},
			finally = {},
			subkeys = {
				['0'] = {
					{
						print = 's 0',
						subkeys = {
							['0'] = {
								{
									executable = 'StartCommandMode order RULEUCC_Patrol',
									print = 's 0 2',
								},

							},
							['9'] = {
								{
									print = 's 9 2',
								},
							}
						}
					},
				},
				['9'] = {
					{
						print = 's9',
					},
				}
			}
		}
	},
}

function RouteHotkey(key)
	local currentTime = GetSystemTimeSeconds()
	local diffTime = currentTime - lastClickTime

	lastClickTime = currentTime

	subKeyAction = currentSubKeys[key]

	if subKeyAction ~= nil then
		local decay = 0.002 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
		local inTime = diffTime < decay

		if inTime then
			ExecuteRecursively(subKeyAction)
			return
		end
	end

	currentSubKeys = nil
	if keyMap[key] ~= nil then ExecuteRecursively(keyMap[key]) end
end

function SetSubKeys(subkeys)
	currentSubKeys = subkeys
end

function CheckConditionals(conditionals)
	local valid = true

	for conditionalKey, conditional in pairs(conditionals) do if not valid then break end
		local executable = GetExecutable(conditional)

		print(executable)

		valid = conditional.checkFor == ConditionalConExecute(executable)

		print(valid)
	end

	return valid
end

function ExecuteRecursively(entries)
	for entryKey, entry in entries do

		if entry["print"] ~= nil then print(entry["print"]) end
		if entry["executable"] ~= nil then ConExecute(entry["executable"]) end
		if entry["immediate"] ~= nil then ExecuteRecursively(entry["immediate"]) end

		if entry["conditionals"] ~= nil then
			local valid = CheckConditionals(entry["conditionals"])

			if valid then
				if entry["valid"] ~= nil then ExecuteRecursively(entry["valid"]) end
			else
				if entry["invalid"] ~= nil then ExecuteRecursively(entry["invalid"]) end
			end
		end

		if entry["finally"] ~= nil then ExecuteRecursively(entry["finally"]) end

		SetSubKeys(entry["subkeys"])
	end
end

function Init()
	local keys = import('/mods/AdvancedHotkeys/modules/allKeys.lua').keys

	for k, v in keys do
		local name = string.gsub(k, "-", "_")
		userKeyActions['SHK ' .. name] = {
			action = 'UI_Lua import("/mods/AdvancedHotkeys/modules/main.lua").RouteHotkey("' .. k .. '")',
			category = 'SHK'
		}
		userKeyMap[k] = 'SHK ' .. name
	end

	Prefs.SetToCurrentProfile('UserKeyActions', userKeyActions)
	Prefs.SetToCurrentProfile('UserKeyMap', userKeyMap)
end

function GetExecutable(entry)
	return entry.executable or 'UI_Lua import("' .. (entry.path or
		conditionalsPath) .. '").' .. entry.func .. '(' .. entry.args .. ')'
end

function ConditionalConExecute(executable)
	ConExecute(executable)

	return ConExecuteGlobalReturnValue
end
