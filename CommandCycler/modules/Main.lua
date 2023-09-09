local Util = import('/lua/utilities.lua')
local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')
local completeCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }
local completePartialCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }

local cycleOrder = ""

local currentUnit
local currentUnitWithoutOrderIndex
local selectionWithoutOrder
local selectionWithOrder
local commandMode
local commandModeData

KeyMapper.SetUserKeyAction('Cycle next, defaults to closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from closest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("closest")',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from furthest', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("furthest")',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from most damaged', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("damage")',
    category = 'Command Cycler'
})
KeyMapper.SetUserKeyAction('Cycle from most health', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection("health")',
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

    if table.getn(selectionWithoutOrder) == 0 then
        PlaySound(completeCycleSound)
        SelectUnits(nil)
        currentUnitWithoutOrderIndex = nil
        selectionWithoutOrder = selectionWithOrder
        selectionWithOrder = {}
        return
    end

    local mousePos = GetMouseWorldPos()
    local nextOrderValue = 99999999
    local nextUnit = nil
    local nextUnitIndex = nil

    if cycleOrder == "closest" then
        nextOrderValue = 99999999
    elseif cycleOrder == "furthest" then
        nextOrderValue = 0
    elseif cycleOrder == "damage" then
        nextOrderValue = 99999999
    elseif cycleOrder == "health" then
        nextOrderValue = 0
    end

    for key,unit in pairs(selectionWithoutOrder) do

        if unit:IsDead() then
            table.remove(selectionWithoutOrder, key)
        else
            local distanceToCursor
            local unitHealthPercent
            local bp
            if cycleOrder == "closest" then
                distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                if distanceToCursor < nextOrderValue then
                    nextOrderValue = distanceToCursor
                    nextUnit = unit
                    nextUnitIndex = key
                end
            elseif cycleOrder == "furthest" then
                distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                if distanceToCursor > nextOrderValue then
                    nextOrderValue = distanceToCursor
                    nextUnit = unit
                    nextUnitIndex = key
                end
            elseif cycleOrder == "damage" then
                bp = unit:GetBlueprint()
                unitHealthPercent = unit:GetHealth() / bp.Defense.MaxHealth

                if unitHealthPercent < nextOrderValue then
                    nextOrderValue = unitHealthPercent
                    nextUnit = unit
                    nextUnitIndex = key
                end

                if unitHealthPercent == 1 then
                    PlaySound(completePartialCycleSound)
                end
            elseif cycleOrder == "health" then
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

    if selectionWithoutOrder == nil or table.getn(selectionWithoutOrder) == 0 then
        Reset()
        return
    end

    currentUnit = nextUnit
    currentUnitWithoutOrderIndex = nextUnitIndex

    SelectUnits { nextUnit }
    CM.StartCommandMode(commandMode, commandModeData)

    selectionChangedSinceLastCycle = false
end

function CreateSelection(units)
    local selectedUnits = GetSelectedUnits()

    Reset()
    selectionWithoutOrder = selectedUnits
    selectionWithOrder = {}

    SelectNext()
end

function MoveCurrentToWithOrder()
    table.insert(selectionWithOrder, selectionWithoutOrder[currentUnitWithoutOrderIndex])
    table.remove(selectionWithoutOrder, currentUnitWithoutOrderIndex)
end

function CreateOrContinueSelection(order)
    if order == nil and cycleOrder == nil then
        cycleOrder = "closest"
    else
        cycleOrder = order
    end

    local selectedUnits = GetSelectedUnits()

    if selectedUnits then
        if table.getn(selectedUnits) > 1 then
            CreateSelection()
            return
        end

        if SelectionIsCurrent(selectedUnits) then
            MoveCurrentToWithOrder()
            SelectNext()
            return
        end
    end

    SelectNext()
end

function SelectAll()
    local unitsToSelect = table.unpack(selectionWithoutOrder)

    for _, v in ipairs(unitsToSelect) do
        table.insert(unitsToSelect, v)
    end

    table.insert(selectionWithoutOrder, selectionWithOrder)
    selectionWithOrder = {}

    SelectUnits(unitsToSelect)
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
    if selectionChangedSinceLastCycle then return end
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
