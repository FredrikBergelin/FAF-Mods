local KeyMapper = import('/lua/keymap/keymapper.lua')

KeyMapper.SetUserKeyAction('Convert patrol to move', {action = "UI_Lua import('/mods/patrol2move/modules/module.lua').ConvertToMove()", category = 'orders', order = 45})

KeyMapper.SetUserKeyAction('Filter selection to units on patrol', {action = "UI_Lua import('/mods/patrol2move/modules/module.lua').SelectPatrolUnits()", category = 'orders', order = 45})