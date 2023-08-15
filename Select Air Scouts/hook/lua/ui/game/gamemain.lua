local KeyMapper = import('/lua/keymap/keymapper.lua')
KeyMapper.SetUserKeyAction('Select Air Scouts', {action = "UI_SelectByCategory AIR INTELLIGENCE", category = 'selection', order = 35})