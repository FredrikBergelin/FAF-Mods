function GlobalConditional(returnVal)
    if returnVal == nil then
        return _G.GlobalConditionalBool
    end

    _G.GlobalConditionalBool = returnVal
    return returnVal
end

function AnyUnitSelected()
    return GlobalConditional(import('/mods/common/modules/misc.lua').AnyUnitSelected())
end

function AnySelectedHasCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return GlobalConditional(false)
    end

    for id, unit in units do
        if EntityCategoryContains(category, unit) then
            return GlobalConditional(true)
        end
    end

    return GlobalConditional(false)
end

function AllSelectedHaveCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return GlobalConditional(false)
    end

    for id, unit in units do
        if not EntityCategoryContains(category, unit) then
            return GlobalConditional(false)
        end
    end

    return GlobalConditional(true)
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
        return GlobalConditional(false)
    end

    if units == nil then
        return GlobalConditional(false)
    end

    for id, unit in units do
        local buildableStructures = GetUpgradesOfUnit(unit)
        if buildableStructures and not TablEmpty(buildableStructures) then
            return GlobalConditional(true)
        end
    end

    return GlobalConditional(false)
end
