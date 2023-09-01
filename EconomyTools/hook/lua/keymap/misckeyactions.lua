local KeyMapper = import("/lua/keymap/keymapper.lua")

local displayOrder = 1599
local function getDisplayOrder()
    displayOrder = displayOrder + 1
    return displayOrder
end

local category = "Economy"

KeyMapper.SetUserKeyAction("Automatically pause construction when low on energy", {
    action = 'UI_Lua import("/mods/AutoPause/main.lua").AutoPause()',
    category = category,
    order = getDisplayOrder()
})
