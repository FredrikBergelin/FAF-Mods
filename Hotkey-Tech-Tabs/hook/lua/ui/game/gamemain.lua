local modDir = '/mods/Hotkey-Tech-Tabs/'

local oldCreateUI = CreateUI
function CreateUI(isReplay)
	oldCreateUI(isReplay)
end 

local cat = 'UI Construction'
local idx = 1

local KeyMapper = import('/lua/keymap/keymapper.lua')
KeyMapper.SetUserKeyAction('Select tech T1 tab', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").SelectTab(1)', category = cat, order = idx}) idx = idx + 1
KeyMapper.SetUserKeyAction('Select tech T2 tab', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").SelectTab(2)', category = cat, order = (idx)}) idx = idx + 1
KeyMapper.SetUserKeyAction('Select tech T3 tab', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").SelectTab(3)', category = cat, order = (idx)}) idx = idx + 1
KeyMapper.SetUserKeyAction('Select tech T4 tab', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").SelectTab(4)', category = cat, order = (idx)}) idx = idx + 1
KeyMapper.SetUserKeyAction('Select Templates tab', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").SelectTab(5)', category = cat, order = idx}) idx = idx + 1
KeyMapper.SetUserKeyAction('Cycle tech Tabs forward', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").CycleTabs(true)', category = cat, order = idx}) idx = idx + 1
KeyMapper.SetUserKeyAction('Cycle tech Tabs backward (Shift)', {action = 'UI_Lua import("'..modDir..'modules/UITabs.lua").CycleTabs(false)', category = cat, order = idx}) idx = idx + 1
