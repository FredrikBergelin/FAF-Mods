function GlobalReturn(returnVal)
    _G.ConExecuteGlobalReturnValue = returnVal
    return returnVal
end

AnyUnitSelected = import('/mods/common/modules/misc.lua').AnyUnitSelected

function AnyHasCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return GlobalReturn(false)
    end

    for id, unit in units do
        if EntityCategoryContains(category, unit) then
            return GlobalReturn(true)
        end
    end

    return GlobalReturn(false)
end

function AllHaveCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return GlobalReturn(false)
    end

    for id, unit in units do
        if not EntityCategoryContains(category, unit) then
            return GlobalReturn(false)
        end
    end

    return GlobalReturn(true)
end

local isReplay = import("/lua/ui/game/gamemain.lua").GetReplayState()

local GetUpgradesOfUnit = false
if not isReplay then
    GetUpgradesOfUnit = import("/lua/ui/game/hotkeys/upgrade-structure.lua").GetUpgradesOfUnit
end

local TablEmpty = table.empty

function AnyUnitCanUpgrade()
    local units = GetSelectedUnits()

    if isReplay then
        return GlobalReturn(false)
    end

    if units == nil then
        return GlobalReturn(false)
    end

    for id, unit in units do
        local buildableStructures = GetUpgradesOfUnit(unit)
        if buildableStructures and not TablEmpty(buildableStructures) then
            return GlobalReturn(true)
        end
    end

    return GlobalReturn(false)
end
