local KeyMapper = import('/lua/keymap/keymapper.lua')
local KeyDescriptions = import('/lua/keymap/keydescriptions.lua').keyDescriptions


--Set game speed to -10
if KeyDescriptions['set_game_speed_minus_10'] == nil then
        KeyDescriptions['set_game_speed_minus_10'] = 'Set game speed to -10'
end

KeyMapper.SetUserKeyAction('set_game_speed_minus_10', {action = 'WLD_GameSpeed -10', category = 'game', order = 5,})


--Set game speed to +10
if KeyDescriptions['set_game_speed_plus_10'] == nil then
        KeyDescriptions['set_game_speed_plus_10'] = 'Set game speed to +10'
end

KeyMapper.SetUserKeyAction('set_game_speed_plus_10', {action = 'WLD_GameSpeed +10', category = 'game', order = 6,})


--Decrease game speed by -3
if KeyDescriptions['decrease_game_speed_by_3'] == nil then
        KeyDescriptions['decrease_game_speed_by_3'] = 'Decrease game speed by -3'
end

KeyMapper.SetUserKeyAction('decrease_game_speed_by_3', {action = 'UI_Lua import("/mods/AdditionalGameSpeedKeybinds/modules/simspeed.lua").ChangeSimRate(-3)', category = 'game', order = 7,})


--Increase game speed by 3
if KeyDescriptions['increase_game_speed_by_3'] == nil then
        KeyDescriptions['increase_game_speed_by_3'] = 'Increase game speed by +3'
end

KeyMapper.SetUserKeyAction('increase_game_speed_by_3', {action = 'UI_Lua import("/mods/AdditionalGameSpeedKeybinds/modules/simspeed.lua").ChangeSimRate(3)', category = 'game', order = 8,})


--Toggle the sim to run as fast as possible or normally
if KeyDescriptions['toggle_the_wind'] == nil then
        KeyDescriptions['toggle_the_wind'] = 'Toggle Run With The Wind'
end

KeyMapper.SetUserKeyAction('toggle_the_wind', {action = 'wld_RunWithTheWind', category = 'game', order = 9,})
