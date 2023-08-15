local KeyMapper = import('/lua/keymap/keymapper.lua')
local KeyDescriptions = import('/lua/keymap/keydescriptions.lua').keyDescriptions

if KeyDescriptions['select_nearest_idle__land__factory'] == nil then
        KeyDescriptions['select_nearest_idle__land__factory'] = 'Select Nearest Idle Land Factory'
end

if KeyDescriptions['select_nearest_idle__air__factory'] == nil then
        KeyDescriptions['select_nearest_idle__air__factory'] = 'Select Nearest Idle Air Factory'
end

if KeyDescriptions['select_nearest_idle__naval__factory'] == nil then
        KeyDescriptions['select_nearest_idle__naval__factory'] = 'Select Nearest Idle Naval Factory'
end

if KeyDescriptions['select_nearest_idle__tech2_engineer'] == nil then
        KeyDescriptions['select_nearest_idle__tech2__engineer'] = 'Select Nearest Idle Tech2 Engineer'
end

if KeyDescriptions['select_nearest_idle__tech3_engineer'] == nil then
        KeyDescriptions['select_nearest_idle__tech3__engineer'] = 'Select Nearest Idle Tech3 Engineer'
end

if KeyDescriptions['select_nearest_tech2_engineer'] == nil then
        KeyDescriptions['select_nearest__tech2__engineer'] = 'Select Nearest Tech2 Engineer'
end

if KeyDescriptions['select_nearest__tech3_engineer'] == nil then
        KeyDescriptions['select_nearest__tech3__engineer'] = 'Select Nearest Tech3 Engineer'
end


KeyMapper.SetUserKeyAction('select_nearest_idle__land__factory', {action =  'UI_SelectByCategory +nearest +idle LAND FACTORY', category = 'selection', order = 97})
KeyMapper.SetUserKeyAction('select_nearest_idle__air__factory', {action =  'UI_SelectByCategory +nearest +idle AIR FACTORY', category = 'selection', order = 98})
KeyMapper.SetUserKeyAction('select_nearest_idle__naval__factory', {action =  'UI_SelectByCategory +nearest +idle NAVAL FACTORY', category = 'selection', order = 99})
KeyMapper.SetUserKeyAction('select_nearest_idle__tech2__engineer', {action =  'UI_SelectByCategory +nearest +idle TECH2 ENGINEER', category = 'selection', order = 100})
KeyMapper.SetUserKeyAction('select_nearest_idle__tech3__engineer', {action =  'UI_SelectByCategory +nearest +idle TECH3 ENGINEER', category = 'selection', order = 101})
KeyMapper.SetUserKeyAction('select_nearest__tech2__engineer', {action =  'UI_SelectByCategory +nearest TECH2 ENGINEER', category = 'selection', order = 102})
KeyMapper.SetUserKeyAction('select_nearest__tech3__engineer', {action =  'UI_SelectByCategory +nearest TECH3 ENGINEER', category = 'selection', order = 103})