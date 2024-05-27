local KeyMapper = import('/lua/keymap/keymapper.lua')
local Config = import('/mods/CommandWheel/modules/Config.lua')

local commandWheelOrderNum = 1600

for name in Config.Wheels do
    KeyMapper.SetUserKeyAction('Open wheel: '..name, {action = 'UI_Lua import("/mods/CommandWheel/modules/App.lua").OpenWheel("'..name..'")', category = 'Command Wheel', order = commandWheelOrderNum})
    commandWheelOrderNum = commandWheelOrderNum + 1
end