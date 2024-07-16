function TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function CategoryFilterSelect(hotkey, message, categoriesString, entityCategories, filterPrintString, filterEntityCategories)
    if Functions.AnyHasCategory(filterEntityCategories or entityCategories) then
        print("Filter " .. (filterPrintString or message))
        SelectUnits(EntityCategoryFilterDown(filterEntityCategories or entityCategories, GetSelectedUnits() or {}))
    else
        print("Onscreen " .. message)
        ConExecute("UI_SelectByCategory +inview " .. categoriesString)
        SelectUnits(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
    end

    SubHotkeys({
        [hotkey] = function() SubHotkey(hotkey, function(hotkey)
                print("All " .. message)
                ConExecute("UI_SelectByCategory " .. categoriesString)
                SelectUnits(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
            end)
        end,
    })
end

function CategoryFilterAdd(hotkey, message, categoriesString, entityCategories)
    print("Add onscreen " .. message)

    Functions.AddToSelection(function()
        ConExecute("UI_SelectByCategory +inview " .. categoriesString)
        SelectUnits(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
    end)

    SubHotkeys({
        [message] = function() SubHotkey(message, function(hotkey)
                print("Add all " .. message)
                Functions.AddToSelection(function()
                    ConExecute("UI_SelectByCategory " .. categoriesString)
                    SelectUnits(EntityCategoryFilterDown(entityCategories, GetSelectedUnits() or {}))
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
