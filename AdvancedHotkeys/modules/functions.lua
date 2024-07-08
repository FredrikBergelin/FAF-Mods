function TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function AnyHasCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return false
    end

    for id, unit in units do
        if EntityCategoryContains(category, unit) then
            return true
        end
    end

    return false
end

local function AllHaveCategory(category)
    local units = GetSelectedUnits()

    if units == nil then
        return false
    end

    for id, unit in units do
        if not EntityCategoryContains(category, unit) then
            return false
        end
    end

    return true
end

local isReplay = import("/lua/ui/game/gamemain.lua").GetReplayState()

local GetUpgradesOfUnit = false
if not isReplay then
    GetUpgradesOfUnit = import("/lua/ui/game/hotkeys/upgrade-structure.lua").GetUpgradesOfUnit
end

local TablEmpty = table.empty

local function AnyUnitCanUpgrade()
    local units = GetSelectedUnits()

    if isReplay then
        return false
    end

    if units == nil then
        return false
    end

    for id, unit in units do
        local buildableStructures = GetUpgradesOfUnit(unit)
        if buildableStructures and not TablEmpty(buildableStructures) then
            return true
        end
    end

    return false
end

-- Unimplemented, but idea is to have a number of subhotkeys that can further filter down after selecting for example direct fire units, then say: Of those last selected, only T2 - so that it works with adding with shift without removing already selected units of other tech levels.
-- local selectionCategoriesSubHotkeys = {
-- 	['1'] = function() SubHotkey('1', function(hotkey)
-- 		print("All T1 units")
-- 		ConExecute("UI_SelectByCategory BUILTBYTIER3FACTORY TECH1 ALLUNITS")
-- 		SelectUnits(EntityCategoryFilterDown(categories.TECH1 - categories.ENGINEER, GetSelectedUnits() or {}))
-- 	end) end,
-- }

function AddToSelection(selectFunction)
    local selected = GetSelectedUnits() or {}

    selectFunction()

    for k, unit in GetSelectedUnits() or {} do
        table.insert(selected, unit)
    end

    SelectUnits(selected)
end

function SelectedUnitsWithOnlyTheseCommands(commands)
    local units = GetSelectedUnits() or {}
    local unitsToSelect = {}

    for index, unit in units do
        local comQ = unit:GetCommandQueue()

        local addUnit = true
        if (table.getn(comQ) == 0 and not TableContains(commands, "Idle")) then
            addUnit = false
        end

        for _, command in comQ do
            if (not TableContains(commands, command.type)) then
                addUnit = false
            end
        end

        if addUnit then
            table.insert(unitsToSelect, unit)
        end
    end

    return unitsToSelect
end

-- TransportUnloadSpecificUnits (only 3 search results in faf fa and didnt lead anywhere but apparently command [25])
function FilterAvailableTransports()
    -- local units = EntityCategoryFilterDown(categories.TRANSPORTATION, GetSelectedUnits())
    local units = GetSelectedUnits()
    local unitsToSelect = {}

    for index, unit in units do
        local comQ = unit:GetCommandQueue()
        local addUnit = true

        -- TransportReverseLoadUnits TransportLoadUnits TransportUnloadUnits Ferry

        for _, command in comQ do
            -- LOG(command.type)
            if (
                TableContains({ "TransportLoadUnits", "TransportUnloadUnits", "TransportReverseLoadUnits", "Ferry" },
                    command.type)) then
                addUnit = false
            end
        end
        -- LOG(addUnit)
        if addUnit then
            table.insert(unitsToSelect, unit)
        end
    end

    return unitsToSelect
end

function SelectSimilarUnits(scope)
    local str = ''
    local similarUnitsBlueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()
    similarUnitsBlueprints.foreach(function(k, v) str = str .. " " .. scope .. " " .. v.BlueprintId .. "," end)
    print("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE")
    ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to
end

function ToggleRepeatBuildOrSetTo(setTo)
    local selection = GetSelectedUnits()
    if selection then
        local verifiedSetTo

        if setTo ~= nil then
            verifiedSetTo = setTo
        else
            for _, v in selection do
                if v:IsInCategory('FACTORY') then
                    if v:IsRepeatQueue() then
                        verifiedSetTo = true
                    end
                end
            end
        end

        for _, v in selection do
            if verifiedSetTo then
                v:ProcessInfo('SetRepeatQueue', 'true')
            else
                v:ProcessInfo('SetRepeatQueue', 'false')
            end
        end
    end
end
