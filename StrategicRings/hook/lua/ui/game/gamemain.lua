local KeyMapper = import('/lua/keymap/keymapper.lua')

KeyMapper.SetUserKeyAction('Delete last created ring', {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteLast()', category = 'StrategicRings', order = 800})
KeyMapper.SetUserKeyAction('Delete closest ring to mouse position', {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteClosest()', category = 'StrategicRings', order = 801})
KeyMapper.SetUserKeyAction('Delete all rings on screen', {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").DeleteScreen()', category = 'StrategicRings', order = 802})
KeyMapper.SetUserKeyAction('Create ring over hovered unit', {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").HoverRing()', category = 'StrategicRings', order = 803})

local orderNum = 810;

for name in import('/mods/StrategicRings/modules/Config.lua').Menus do
    KeyMapper.SetUserKeyAction('Open menu: '..name, {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenMenu("'..name..'")', category = 'StrategicRings', order = orderNum})
    orderNum = orderNum + 1
end

for name in import('/mods/StrategicRings/modules/Config.lua').Wheels do
    KeyMapper.SetUserKeyAction('Open wheel: '..name, {action = 'UI_Lua import("/mods/StrategicRings/modules/App.lua").OpenWheel("'..name..'")', category = 'StrategicRings', order = orderNum})
    orderNum = orderNum + 1
end