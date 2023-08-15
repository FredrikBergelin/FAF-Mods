local KeyMapper = import('/lua/keymap/keymapper.lua')
local mod_category = 'GroupControls'
local order = 1
for v = 1, 10 do
  local v_string = tostring(v)
  order = order + 1
  KeyMapper.SetUserKeyAction('Append to control group' .. v_string, {action = "UI_Lua import('/mods/GroupControls/modules/groupcontrols.lua').AppendToGroup(" .. v_string .. ")", category = mod_category, order = order})
end
order = order + 1
KeyMapper.SetUserKeyAction("Delete control group", {action = "UI_Lua import('/mods/GroupControls/modules/groupcontrols.lua').DeleteFromGroup()", category = mod_category, order = order})
