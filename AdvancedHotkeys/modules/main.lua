local Prefs = import('/lua/user/prefs.lua')
local userKeyActions = Prefs.GetFromCurrentProfile('UserKeyActions') -- Eg: ['Cycle next, defaults to closest'] = { action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()', ... },
local userKeyMap = Prefs.GetFromCurrentProfile('UserKeyMap') -- Eg: Tab = 'Cycle next, defaults to closest',

modPath = '/mods/AdvancedHotkeys'
conditionalsPath = modPath .. '/modules/conditionals.lua'

local subHotkeys = nil
local subKeyAction = nil

local storedUniqueIdentifier
local lastClickTime = -9999

local function Hotkey(hotkey, func)
	subKeyAction = subHotkeys[hotkey]
	local currentTime = GetSystemTimeSeconds()
	local diffTime = currentTime - lastClickTime
	local decay = 0.002 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
	local inTime = diffTime < decay
	lastClickTime = currentTime

	if subKeyAction ~= nil and inTime then
		ForkThread(subKeyAction)
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
		subKeyAction = subHotkeys[hotkey]
	end

	storedUniqueIdentifier = hotkey

	func(hotkey)
end

local customKeyMap = {
	['0'] = {
		{
			print = 'pre',
		},
		{
			print = '0',
			immediate = {
				{
					print = 'immediate',
					executable = 'StartCommandMode order RULEUCC_Patrol'
				},
				{
					print = 'immediate, double print test',
				},
			},
			conditionals = {
				{
					func = 'AllHaveCategory',
					args = 'categories.ENGINEER',
					checkFor = true,
				}
			},
			valid = {
				{
					print = "valid",
				}
			},
			invalid = {
				{
					print = "invalid"
				}
			},
			finally = {
				{
					print = "finally"
				}
			},
			subHotkeys = {
				{
					['0'] = {

					}
				}
			}
		}
	},
}

function RouteHotkey(key)
	local keyAction = customKeyMap[key]

	ExecuteRecursively(keyAction)


	-- subKeyAction = subHotkeys[key]
	-- local currentTime = GetSystemTimeSeconds()
	-- lastClickTime = currentTime

	-- if subKeyAction ~= nil then
	-- 	local diffTime = currentTime - lastClickTime
	-- 	local decay = 0.002 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
	-- 	local inTime = diffTime < decay

	-- 	if inTime then
	-- 		ExecuteRecursively(subKeyAction)
	-- 	end
	-- else
	-- 	subHotkeys = nil
	-- 	ExecuteRecursively(keyAction)
	-- end
end

function SetSubKeys(table)
	for k, v in table do
		--
	end
end

function ExecuteRecursively(table)
	for eKey, entry in table do

		if entry["print"] ~= nil then print(entry["print"]) end
		if entry["executable"] ~= nil then ConExecute(entry["executable"]) end
		if entry["immediate"] ~= nil then ExecuteRecursively(entry["immediate"]) end

		if entry["conditionals"] ~= nil then
			local valid = true
			for cKey, conditional in pairs(entry["conditionals"]) do if not valid then break end
				local executable = GetExecutable(conditional)

				print(executable)

				valid = conditional.checkFor == ConditionalConExecute(executable)

				print(valid)
			end

			if valid then
				if entry["valid"] ~= nil then ExecuteRecursively(entry["valid"]) end
			else
				if entry["invalid"] ~= nil then ExecuteRecursively(entry["invalid"]) end
			end
		end

		if entry["finally"] ~= nil then ExecuteRecursively(entry["finally"]) end
		if entry["subkeys"] ~= nil then SetSubKeys(entry["subkeys"]) end
	end
end

function Init()
	for k, v in customKeyMap do
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

function GetExecutable(table)
	return table.executable or 'UI_Lua import("' .. (table.path or
		conditionalsPath) .. '").' .. table.func .. '(' .. table.args .. ')'
end

function ConditionalConExecute(executable)
	ConExecute(executable)

	return ConExecuteGlobalReturnValue
end
