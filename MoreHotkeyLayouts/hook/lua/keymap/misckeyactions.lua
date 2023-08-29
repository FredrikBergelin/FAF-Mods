local KeyMapper = import('/lua/keymap/keymapper.lua')
local Prefs = import('/lua/user/prefs.lua')


function SetActiveHotkeyLayout(KeyMapNumber)
	Prefs.SetToCurrentProfile("UserKeyMap", GetPreference("CustomKeyMaps.KeyMap" .. KeyMapNumber))
	KeyMapper.SaveUserKeyMap()
    IN_ClearKeyMap()
    IN_AddKeyMapTable(KeyMapper.GetKeyMappings(true))
    import('/lua/keymap/hotbuild.lua').addModifiers()
    import('/lua/keymap/hotkeylabels.lua').init()
	print("KeyMap" .. KeyMapNumber)
end

function SaveKeyMap(KeyMapNumber)
	SetPreference("CustomKeyMaps.KeyMap" .. KeyMapNumber, Prefs.GetFromCurrentProfile("UserKeyMap"))
	print("Saved KeyMap" .. KeyMapNumber)
end


--------HOTKEYS-----------

--KeyMap0
KeyMapper.SetUserKeyAction('Activate backup of original KeyMap (from when this mod was first installed)', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(0)', category = 'More Hotkey Layouts', order = 169})

--KeyMap1
KeyMapper.SetUserKeyAction('Activate KeyMap1', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(1)', category = 'More Hotkey Layouts', order = 170})
KeyMapper.SetUserKeyAction('Shift_Activate KeyMap1', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(1)', category = 'More Hotkey Layouts', order = 171})
KeyMapper.SetUserKeyAction('Save all current keybindings as KeyMap1', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SaveKeyMap(1)', category = 'More Hotkey Layouts', order = 172})

--KeyMap2
KeyMapper.SetUserKeyAction('Activate KeyMap2', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(2)', category = 'More Hotkey Layouts', order = 173})
KeyMapper.SetUserKeyAction('Shift_Activate KeyMap2', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(2)', category = 'More Hotkey Layouts', order = 174})
KeyMapper.SetUserKeyAction('Save all current keybindings as KeyMap2', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SaveKeyMap(2)', category = 'More Hotkey Layouts', order = 175})

--KeyMap3
KeyMapper.SetUserKeyAction('Activate KeyMap3', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(3)', category = 'More Hotkey Layouts', order = 173})
KeyMapper.SetUserKeyAction('Shift_Activate KeyMap3', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(3)', category = 'More Hotkey Layouts', order = 174})
KeyMapper.SetUserKeyAction('Save all current keybindings as KeyMap3', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SaveKeyMap(3)', category = 'More Hotkey Layouts', order = 175})

--KeyMap4
KeyMapper.SetUserKeyAction('Activate KeyMap4', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(4)', category = 'More Hotkey Layouts', order = 173})
KeyMapper.SetUserKeyAction('Shift_Activate KeyMap4', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(4)', category = 'More Hotkey Layouts', order = 174})
KeyMapper.SetUserKeyAction('Save all current keybindings as KeyMap4', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SaveKeyMap(4)', category = 'More Hotkey Layouts', order = 175})

--KeyMap5
KeyMapper.SetUserKeyAction('Activate KeyMap5', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(5)', category = 'More Hotkey Layouts', order = 173})
KeyMapper.SetUserKeyAction('Shift_Activate KeyMap5', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SetActiveHotkeyLayout(5)', category = 'More Hotkey Layouts', order = 174})
KeyMapper.SetUserKeyAction('Save all current keybindings as KeyMap5', {action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").SaveKeyMap(5)', category = 'More Hotkey Layouts', order = 175})

