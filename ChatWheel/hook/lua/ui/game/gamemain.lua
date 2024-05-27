local KeyMapper = import('/lua/keymap/keymapper.lua')
KeyMapper.SetUserKeyAction('call chat wheel', {
    action = 'UI_Lua import("/mods/ChatWheel/modules/CWMain.lua").call()',
    category = 'Chat Wheel',
    order = 405
})
