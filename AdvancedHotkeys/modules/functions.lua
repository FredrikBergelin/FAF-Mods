function tLOG(this, key, indentLevel)
    if not indentLevel then indentLevel = 0 end

    local indent = string.rep('-   ', indentLevel)
    local first = indent .. tostring(key) .. ': '

    if type(this) == 'nil' then
        LOG(first .. 'nil')
        return
    elseif type(this) == 'string' then
        LOG(first .. '"' .. this .. '"')
        return
    elseif type(this) == 'boolean' then
        LOG(first .. tostring(this))
    elseif type(this) == 'table' then
        LOG(first .. "{")
        for key, value in this do
            tLOG(value, key, indentLevel + 1)
        end
        LOG(indent .. "}")
    end
end

local Conditionals = import("/mods/AdvancedHotkeys/modules/conditionals.lua")

function GlobalReturn(returnVal)

    tLOG(returnVal, 'returnVal')

    if returnVal == nil then
        return _G.GlobalReturnValue or nil -- access to nonexistent global variable "GlobalReturnValue"
    end

    _G.GlobalReturnValue = returnVal
    return _G.GlobalReturnValue
end

function TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Select()
    Select(GlobalReturn() or {})
end

function SelectedUnits()
    return GlobalReturn(GetSelectedUnits())
end

function FilterCommandQueueContainsOnly(commandList)
    local units = _G.GlobalReturnValue
    local validUnits = {}
    for _, unit in units do
        local comQ = unit:GetCommandQueue()
        local addUnit = true
        for _, command in comQ do
            if (
                TableContains(commandList,
                    command.type)) then
                addUnit = false
                break
            end
        end
        if addUnit then
            table.insert(validUnits, unit)
        end
    end
    return GlobalReturn(validUnits)
end

function CategoryFilterSelect(hotkey, message, categoriesString, entityCategories, filterPrintString,
                              filterEntityCategories)
    if Conditionals.AnySelectedHasCategory(filterEntityCategories or entityCategories) then
        print("Filter " .. (filterPrintString or message))
        Select(EntityCategoryFilterDown(filterEntityCategories or entityCategories, GetSelectedUnits() or {}))
    else
        print("Onscreen " .. message)
        ConExecute("UI_SelectByCategory +inview " .. categoriesString)
        Select(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
    end

    SubHotkeys({
        [hotkey] = function() SubHotkey(hotkey, function(hotkey)
                print("All " .. message)
                ConExecute("UI_SelectByCategory " .. categoriesString)
                Select(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
            end)
        end,
    })
end

function CategoryFilterAdd(hotkey, message, categoriesString, entityCategories)
    print("Add onscreen " .. message)

    AddToSelection(function()
        ConExecute("UI_SelectByCategory +inview " .. categoriesString)
        Select(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
    end)

    SubHotkeys({
        [hotkey] = function() SubHotkey(hotkey, function(hotkey)
                print("Add all " .. message)
                AddToSelection(function()
                    ConExecute("UI_SelectByCategory " .. categoriesString)
                    Select(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
                end)
            end)
        end,
    })
end

function AddToSelection(selectFunction)
    local selected = GetSelectedUnits() or {}

    selectFunction()

    for k, unit in GetSelectedUnits() or {} do
        table.insert(selected, unit)
    end

    Select(selected)
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
