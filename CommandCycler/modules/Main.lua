local Util = import('/lua/utilities.lua')
local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')
local completeCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }
local completePartialCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }

-- Static for now
local continious = false

local sortMode = "closest"
local cycleMode = "auto"
local specialMode

local currentUnit
local currentUnitWithoutOrderIndex
local selectionWithoutOrder
local selectionWithOrder
local commandMode
local commandModeData

KeyMapper.SetUserKeyAction('Cycle next, defaults to closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(nil, true)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('(Shift) Cycle next, defaults to closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(nil, false)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest", true)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('(Shift) Cycle from closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest", false)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from furthest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest", true)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('(Shift) Cycle from furthest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest", false)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from most damaged', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("damage", true)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('(Shift) Cycle from most damaged', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("damage", false)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from most health', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health", true)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('(Shift) Cycle from most health', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health", false)',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Select all and reset selection', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectAll()',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Select remaining, without command', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").SelectRest()',
    category = 'Command Cycler'
})

-- KeyMapper.SetUserKeyAction('Add one more unit to each selection', {
--     action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(true)',
--     category = 'Command Cycler'
-- })
-- KeyMapper.SetUserKeyAction('Select rest / all', {
--     action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection(true)',
--     category = 'Command Cycler'
-- })

local function Reset(deselect)
    currentUnit = nil
    currentUnitWithoutOrderIndex = nil
    selectionWithoutOrder = {}
    selectionWithOrder = {}
    commandMode = nil
    commandModeData = nil

    if deselect then
        SelectUnits(nil)
    end
end

-- TODO Remove, will be unnecessary
function ReduceIndex(index)
    if index > 1 then
        return (index - 1)
    -- To select the first the next function needs nil not 0
    else
        return nil
    end
end

local selectionChangedSinceLastCycle = true

-- Select next unit in the saved selection
function SelectNext()

    if not selectionWithoutOrder or table.getn(selectionWithoutOrder) == 0 then
        PlaySound(completeCycleSound)
        currentUnitWithoutOrderIndex = nil
        selectionWithoutOrder = selectionWithOrder
        selectionWithOrder = {}

        if not continious then
            if cycleMode ~= "camera" then
                SelectUnits(nil)
            end

            return
        end
    end

    local mousePos = GetMouseWorldPos()
    local nextOrderValue = 99999999
    local nextUnit = nil
    local nextUnitIndex = nil
    local missilesCount = false

    if specialMode == "silo" then
        if sortMode == "closest" then
            nextOrderValue = 99999999
            sortMode = "closest"
        elseif sortMode == "furthest" then
            nextOrderValue = 0
            sortMode = "furthest"
        end
    elseif sortMode == "closest" then
        nextOrderValue = 99999999
    elseif sortMode == "furthest" then
        nextOrderValue = 0
    elseif sortMode == "damage" then
        nextOrderValue = 99999999
    elseif sortMode == "health" then
        nextOrderValue = 0
    end

    LOG("SelectNext")

    for key, unit in pairs(selectionWithoutOrder) do

        if specialMode == "silo" then
            local missile_info = unit:GetMissileInfo()
            missilesCount = missile_info.nukeSiloStorageCount + missile_info.tacticalSiloStorageCount
            LOG("COUNT: "..missilesCount)
        end

        -- TODO: Sometimes it seems that it wont select when only one silo is loaded, but after adding logs and searching it works. Maybe something random but letting this be for now to see if it is solved.

        if unit:IsDead() then
            LOG(1)
            table.remove(selectionWithoutOrder, key)
        else
            if specialMode == "silo" and missilesCount == 0 then
                LOG(2)
                table.insert(selectionWithOrder, selectionWithoutOrder[key])
                table.remove(selectionWithoutOrder, key)
            else
                LOG(3)
                local distanceToCursor
                local unitHealthPercent
                local bp
                if sortMode == "closest" then
                    distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                    if distanceToCursor < nextOrderValue then
                        nextOrderValue = distanceToCursor
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif sortMode == "furthest" then
                    distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                    if distanceToCursor > nextOrderValue then
                        nextOrderValue = distanceToCursor
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif sortMode == "damage" then
                    bp = unit:GetBlueprint()
                    unitHealthPercent = unit:GetHealth() / bp.Defense.MaxHealth

                    if unitHealthPercent < nextOrderValue then
                        nextOrderValue = unitHealthPercent
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif sortMode == "health" then
                    bp = unit:GetBlueprint()
                    unitHealthPercent = unit:GetHealth() / bp.Defense.MaxHealth

                    if unitHealthPercent > nextOrderValue then
                        nextOrderValue = unitHealthPercent
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                end
            end
        end
    end

    if sortMode == "damage" and nextOrderValue == 1 then
        print("Remaining units have full health")
        PlaySound(completePartialCycleSound)
    end

    if selectionWithoutOrder == nil or table.getn(selectionWithoutOrder) == 0 then
        Reset()
        return
    end

    currentUnit = nextUnit
    currentUnitWithoutOrderIndex = nextUnitIndex

    if cycleMode == "camera" then
        local currentCamSettings = GetCamera('WorldCamera'):SaveSettings()
        local unitPos = nextUnit:GetPosition()

        MoveCurrentToWithOrder()
        -- if currentCamSettings.Focus == unitPos then
        --     LOG("SAME position")
        --     MoveCurrentToWithOrder()
        -- else
        --     LOG("DIFFERENT position")
        -- end

        currentCamSettings.Focus = unitPos
        GetCamera('WorldCamera'):RestoreSettings(currentCamSettings)
    else
        SelectUnits { nextUnit }

        CM.StartCommandMode(commandMode, commandModeData)
        selectionChangedSinceLastCycle = false
    end
end

function CreateSelection(units, sort, cycle, special)
    if sort ~= nil then
        sortMode = sort
    end

    -- auto, manual, toggle, camera
    if cycle then
        cycleMode = cycle
    end

    if special ~= nil then
        specialMode = special
    else
        specialMode = nil
    end

    Reset()
    selectionWithoutOrder = units or {}
    selectionWithOrder = {}
end

function MoveCurrentToWithOrder()
    table.insert(selectionWithOrder, selectionWithoutOrder[currentUnitWithoutOrderIndex])
    table.remove(selectionWithoutOrder, currentUnitWithoutOrderIndex)
end

-- TODO: Hotkey to get all of the current type of mex to assist, ie t1 upgrading first then t1, then t2 upgrading etc

function CreateOrContinueSelection(sort, cycle, special)
    local selected = GetSelectedUnits()

    LOG("SELECTED: "..table.getn(selected))

    if cycle == "camera_create" then
        CreateSelection(selected, "closest", "camera")
    elseif cycle == "camera" then
        SelectNext()
    elseif special == "silo" and selected and table.getn(selected) > 0 then
        LOG("silo")
        CreateSelection(selected, sort, cycle, "silo")
        SelectNext()
    elseif selected and table.getn(selected) > 1 then
        CreateSelection(selected, sort, cycle)
        SelectNext()
    elseif selected and SelectionIsCurrent(selected) then
        if cycle == "toggle" then
            if cycleMode == "auto" then cycleMode = "manual" elseif cycleMode == "manual" then cycleMode = "manual" end
                -- PrintAutoCycle(cycleMode)
            else
            MoveCurrentToWithOrder()
            SelectNext()
        end
    else
        SelectNext()
    end
end

function SelectAll()
    local allUnits = {}
    for _, v in ipairs(selectionWithoutOrder) do
        table.insert(allUnits, v)
    end
    for _, v in ipairs(selectionWithOrder) do
        table.insert(allUnits, v)
    end

    selectionWithoutOrder = allUnits
    selectionWithOrder = {}

    SelectUnits(selectionWithoutOrder)
end

function SelectRest()
    SelectUnits(selectionWithoutOrder)
end

function SelectionIsCurrent(units)
    if currentUnit == nil or currentUnit:IsDead() then
        return false
    end

    if units ~= nil then
        if table.getn(units) == 1 then
            if units[1] == currentUnit then
                return true
            end
        end
    end
    return false
end

function Main(isReplay)
    if isReplay then return end

    CM.AddStartBehavior(OnCommandStarted)
    --CM.AddEndBehavior(OnCommandEnded)
end

function SelectionChanged(oldSelection, newSelection, added, removed)
    local selection = GetSelectedUnits()
    if not selectionChangedSinceLastCycle and not SelectionIsCurrent(newSelection) then
        selectionChangedSinceLastCycle = true
    end
end

---comment
---@param cmdMode CommandMode
---@param cmdModeData CommandModeData
---@param command any
function OnCommandIssued(cmdMode, cmdModeData, command)
    if cycleMode ~= "auto" or selectionChangedSinceLastCycle then return end
    if command.CommandType == 'Guard' and not command.Target.EntityId then return end
    if command.CommandType == 'None' then return end

    MoveCurrentToWithOrder()
    ForkThread(SelectNext, false)
end

---comment
---@param cmdModeCommandMode
---@param cmdModeData CommandModeData
function OnCommandStarted(cmdMode, cmdModeData)
    if not selectionChangedSinceLastCycle then
        local cm = CM.GetCommandMode()
        commandMode, commandModeData = cm[1], cm[2]
    else
        return
    end
end
