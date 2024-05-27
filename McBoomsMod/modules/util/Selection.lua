local SetIgnoreSelection = import('/lua/ui/game/gamemain.lua').SetIgnoreSelection

local CM_cache = false;
local c_unpack = unpack

function getCMCached()
    if not CM_cache then
        CM_cache = import('/lua/ui/game/commandmode.lua')
    end
    return CM_cache;
end

function Hidden(callback, ...)
    local CM = getCMCached()
    local current_command = CM.GetCommandMode()
    local old_selection = GetSelectedUnits() or {}

    SetIgnoreSelection(true)
    callback(c_unpack(arg))
    SelectUnits(old_selection)
    CM.StartCommandMode(current_command[1], current_command[2])
    SetIgnoreSelection(false)
end

function HiddenSelf(_self, _callback, ...)
    local CM = getCMCached()
    local current_command = CM.GetCommandMode()
    local old_selection = GetSelectedUnits() or {}

    SetIgnoreSelection(true)
    _callback(_self, c_unpack(arg))
    SelectUnits(old_selection)
    CM.StartCommandMode(current_command[1], current_command[2])
    SetIgnoreSelection(false)
end