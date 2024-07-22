local KeyMapper = import('/lua/keymap/keymapper.lua')
local functionsCategory = 'Advanced Hotkeys Functions'

--------HOTKEYS-----------

KeyMapper.SetUserKeyAction('Select Units', {action = 'UI_Lua import("/mods/AdvancedHotkeys/functions.lua").SelectedUnits()', category = functionsCategory, order = 1})
KeyMapper.SetUserKeyAction('Selected Units', {action = 'UI_Lua import("/mods/AdvancedHotkeys/functions.lua").SelectedUnits()', category = functionsCategory, order = 1})
KeyMapper.SetUserKeyAction('Filter Command Queue Contains Only', {action = 'UI_Lua import("/mods/AdvancedHotkeys/functions.lua").FilterCommandQueueContainsOnly()', category = functionsCategory, order = 1})

