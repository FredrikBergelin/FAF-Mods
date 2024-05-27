local Mods = import('/lua/mods.lua')

local _contextMenu
local _rings = {}

function CloseContextMenu()
    if _contextMenu then
        _contextMenu:Destroy()
        _contextMenu = nil
    end
end

function SetContextMenu(contextMenu)
    _contextMenu = contextMenu
end

function getRings()
    return _rings
end

function IsModInstalled(name, location, uid)
    if name == nil and location == nil and uid == nil then
        return false
    end

    for _, mod in Mods.GetUiMods() do
        if (name == nil or mod.name == name)
                and (location == nil or mod.location == location)
                and (uid == nil or mod.uid == uid) then
            return true
        end
    end

    return false
end

function IsCommandWheelAvailable()
    return IsModInstalled('Command Wheel', '/mods/commandwheel')
end