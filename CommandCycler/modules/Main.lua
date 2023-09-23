local Util = import('/lua/utilities.lua')
local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')
local completeCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }
local completePartialCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }

local cycleMode = ""

local currentUnit
local currentUnitWithoutOrderIndex
local selectionWithoutOrder
local selectionWithOrder
local commandMode
local commandModeData
local automaticallyCycle = true

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
    local onlyWithMissile = false
    local missilesCount = false

    if cycleMode == "closest" then
        nextOrderValue = 99999999
    elseif cycleMode == "closest_missile" then
        nextOrderValue = 99999999
        onlyWithMissile = true
    elseif cycleMode == "furthest" then
        nextOrderValue = 0
    elseif cycleMode == "furthest_missile" then
        nextOrderValue = 0
        onlyWithMissile = true
    elseif cycleMode == "damage" then
        nextOrderValue = 99999999
    elseif cycleMode == "health" then
        nextOrderValue = 0
    end

    for key,unit in pairs(selectionWithoutOrder) do

        if onlyWithMissile then
            local missile_info = self.unit:GetMissileInfo()
            missilesCount = missile_info.nukeSiloStorageCount + missile_info.tacticalSiloStorageCount
        end

        if unit:IsDead() then
            table.remove(selectionWithoutOrder, key)
        else
            if onlyWithMissile and missilesCount == 0 then
            else
                local distanceToCursor
                local unitHealthPercent
                local bp
                if cycleMode == "closest" then
                    distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                    if distanceToCursor < nextOrderValue then
                        nextOrderValue = distanceToCursor
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif cycleMode == "furthest" then
                    distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
                    if distanceToCursor > nextOrderValue then
                        nextOrderValue = distanceToCursor
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif cycleMode == "damage" then
                    bp = unit:GetBlueprint()
                    unitHealthPercent = unit:GetHealth() / bp.Defense.MaxHealth

                    if unitHealthPercent < nextOrderValue then
                        nextOrderValue = unitHealthPercent
                        nextUnit = unit
                        nextUnitIndex = key
                    end
                elseif cycleMode == "health" then
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

    if cycleMode == "damage" and nextOrderValue == 1 then
        PlaySound(completePartialCycleSound)
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

function PrintAutoCycle(autoCycle)
    if autoCycle then
        print("Automatic Cycling")
    else
        print("Manual cycling")
    end
end

function CreateOrContinueSelection(mode, autoCycle, toggleAutoCycle)
    if autoCycle == true or autoCycle == false then
        automaticallyCycle = autoCycle
        PrintAutoCycle(automaticallyCycle)
    end

    local selectedUnits = GetSelectedUnits()

    if selectedUnits then
        if table.getn(selectedUnits) > 1 then
            if mode == nil then
                cycleMode = "closest"
            else
                cycleMode = mode
            end
            if toggleAutoCycle == true then
                automaticallyCycle = false
                PrintAutoCycle(automaticallyCycle)
            end
            CreateSelection()
            return
        elseif SelectionIsCurrent(selectedUnits) then
            if toggleAutoCycle == true then
                automaticallyCycle = not automaticallyCycle
                PrintAutoCycle(automaticallyCycle)
            else
                MoveCurrentToWithOrder()
                SelectNext()
            end
            return
        end
    end

    SelectNext()
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
    if not automaticallyCycle or selectionChangedSinceLastCycle then return end
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
