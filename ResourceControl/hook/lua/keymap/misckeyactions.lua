local KeyMapper = import('/lua/keymap/keymapper.lua')

--------HOTKEYS-----------

KeyMapper.SetUserKeyAction('Pause resource draining functions of selected units',
    { action = 'UI_Lua import("/mods/ResourceControl/modules/toggle.lua").SetResourceDrainForSelectedUnits(false)',
        category = 'Resource Control', order = 1 })

KeyMapper.SetUserKeyAction('Activate resource draining functions of selected units',
    { action = 'UI_Lua import("/mods/ResourceControl/modules/toggle.lua").SetResourceDrainForSelectedUnits(true)',
        category = 'Resource Control', order = 2 })
