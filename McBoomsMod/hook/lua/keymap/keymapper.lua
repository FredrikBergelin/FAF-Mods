local modFolder = 'McBoomsMod'
local mod_category = 'McBoomBoomsMod'
local order = 1
SetUserKeyAction("Remove from control group", {action = "UI_Lua import('/mods/"..modFolder.."/modules/util/Util.lua').RemoveFromGroups()", category = mod_category, order = order})