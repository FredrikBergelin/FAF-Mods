function CycleTemplates()
    local units = GetSelectedUnits()

    for i, unit in units do
        if unit:IsInCategory("ENGINEER") then
            if units then
                local tech2 = EntityCategoryFilterDown(categories.TECH2, units)
                local tech3 = EntityCategoryFilterDown(categories.TECH3, units)
                local sACUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, units)

                if next(sACUs) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = sACUs[1]:GetEntityId() } }, true)
                    SelectUnits(sACUs)
                elseif next(tech3) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech3[1]:GetEntityId() } }, true)
                    SelectUnits(tech3)
                elseif next(tech2) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech2[1]:GetEntityId() } }, true)
                    SelectUnits(tech2)
                else
                end
            end

            import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
            return
        end
    end
end

function UpgradeStructuresEngineersCycleTemplates()
    local units = GetSelectedUnits()

    for i, unit in units do
        if unit:IsInCategory("ENGINEER") then
            if units then
                local tech2 = EntityCategoryFilterDown(categories.TECH2, units)
                local tech3 = EntityCategoryFilterDown(categories.TECH3, units)
                local sACUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, units)

                if next(sACUs) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = sACUs[1]:GetEntityId() } }, true)
                    SelectUnits(sACUs)
                elseif next(tech3) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech3[1]:GetEntityId() } }, true)
                    SelectUnits(tech3)
                elseif next(tech2) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech2[1]:GetEntityId() } }, true)
                    SelectUnits(tech2)
                else
                end
            end

            import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
            return
        end
    end

    import("/lua/keymap/hotbuild.lua").buildActionUpgrade()
end

-- Decrease Unit count in factory queue
local DecreaseBuildCountInQueue = import("/lua/ui/game/construction.lua").DecreaseBuildCountInQueue
local RefreshUI = import("/lua/ui/game/construction.lua").RefreshUI
function RemoveLastItem()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits and selectedUnits[1]:IsInCategory "FACTORY" then
        local currentCommandQueue = SetCurrentFactoryForQueueDisplay(selectedUnits[1])
        local count = 1
        if IsKeyDown "Shift" then
            count = 5
        end
        DecreaseBuildCountInQueue(table.getsize(currentCommandQueue), count)
        ClearCurrentFactoryForQueueDisplay()
        RefreshUI()
    end
end

function UndoLastQueueOrder()
    local units = GetSelectedUnits()
    if (units ~= nil) then
        local u = units[1]
        local queue = SetCurrentFactoryForQueueDisplay(u);
        if queue ~= nil then
            local lastIndex = table.getn(queue)
            local count = 1
            if IsKeyDown('Shift') then
                count = 5
            end
            DecreaseBuildCountInQueue(lastIndex, count)
        end
    end
end

function UndoAllExceptCurrentQueueOrder()
    local units = GetSelectedUnits()
    if (units ~= nil) then
        local u = units[1]
        local queue = SetCurrentFactoryForQueueDisplay(u);
        if queue ~= nil then
            local lastIndex = table.getn(queue)
            local count = 1
            if IsKeyDown('Shift') then
                count = 5
            end
            DecreaseBuildCountInQueue(lastIndex, lastIndex - 1)
        end
    end
end

-- function toggleScript(name)
--     local selection = GetSelectedUnits()
--     local number = unitToggleRules[name]
--     local currentBit = GetScriptBit(selection, number)
--     ToggleScriptBit(selection, number, currentBit)
-- end

-- function toggleAllScript()
--     local selection = GetSelectedUnits()
--     for i = 0, 8 do
--         local currentBit = GetScriptBit(selection, i)
--         ToggleScriptBit(selection, i, currentBit)
--     end
-- end

unitToggleRules = {
    Shield = 0,
    Weapon = 1,
    Jamming = 2,
    Intel = 3,
    Production = 4,
    Stealth = 5,
    Gceneric = 6,
    Special = 7,
    Cloak = 8,
}

function GetOnValueForScriptBit(i)
    if i == 0 then return false end -- shield is weird and reversed... you need to set it to false to get it to turn off - unlike everything else
    return true
end

function SetProductionAndAbilities(setActive, abilities)
    local units = GetSelectedUnits()

    abilities = abilities or
    { "Pause", "Shield", "Weapon", "Jamming", "Intel", "Stealth", "Generic", "Special" } -- "Production" left out

    if setActive then
        PlaySound(Sound { Cue = "UI_Tab_Click_02", Bank = "Interface" })
    else
        PlaySound(Sound { Cue = "UI_Menu_Error_01", Bank = "Interface" })
    end

    if abilities[1] == "Pause" then
        SetPaused(units, not setActive)
    end

    from(abilities).foreach(function(i, a)
        LOG(i)
        local ruleNumber = unitToggleRules[a]
        LOG(ruleNumber)
        if ruleNumber then
            local onValue = GetOnValueForScriptBit(ruleNumber)
            LOG("onValue")
            LOG(onValue)
            ToggleScriptBit(units, ruleNumber, setActive and onValue or not onValue)
        end
    end)
end
