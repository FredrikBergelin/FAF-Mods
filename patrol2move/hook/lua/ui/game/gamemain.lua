local KeyMapper = import('/lua/keymap/keymapper.lua')

KeyMapper.SetUserKeyAction('Patrol2Move', {action = "UI_Lua import('/mods/patrol2move/modules/module.lua').ConvertToMove()", category = 'orders', order = 45})