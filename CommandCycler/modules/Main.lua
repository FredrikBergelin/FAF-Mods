local Util = import('/lua/utilities.lua')
local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')
local completeCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }

local currentUnitIndex
local selection = {}
local selectionWithOrder = {}
local selectionWithoutOrder = {}
local commandMode
local commandModeData
local currentUnit
local selectionIsCurrent

KeyMapper.SetUserKeyAction('Activate/return to individual cycling with saved command', {
    action = 'UI_Lua import("/mods/CommandCycler/modules/Main.lua").CreateOrContinueSelection()',
    category = 'Individual Command Cycler'
})

local function Reset(deselect)
    currentUnitIndex = nil
    commandMode = nil
    commandModeData = nil
    currentUnit = nil
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

-- Select next unit in the saved selection
function SelectNext()

    if table.getn(selectionWithoutOrder) == 0 then
        PlaySound(completeCycleSound)
        SelectUnits(nil)
        currentUnitIndex = nil
        selectionWithoutOrder = selectionWithOrder
        selectionWithOrder = {}
        return
    end

    local mousePos = GetMouseWorldPos()
    local shortestDistance = 99999999
    local closestUnit = nil
    local closestUnitIndex = nil

    for key,unit in pairs(selectionWithoutOrder) do

        if unit:IsDead() then
            table.remove(selection, key)
            table.remove(selectionWithoutOrder, key)
        else

            local distanceToCursor = Util.GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())

            if distanceToCursor < shortestDistance then
                shortestDistance = distanceToCursor
                closestUnit = unit
                closestUnitIndex = key
            end
        end
    end

    if selectionWithoutOrder == nil or table.getn(selectionWithoutOrder) == 0 then
        Reset()
        return
    end

    currentUnit = closestUnit
    currentUnitIndex = closestUnitIndex

    SelectUnits { closestUnit }
    CM.StartCommandMode(commandMode, commandModeData)

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

function CreateSelection(units)
    local selectedUnits = GetSelectedUnits()

    Reset()
    selection = selectedUnits
    selectionWithoutOrder = selectedUnits
    selectionWithOrder = {}

    SelectNext()
end

function SelectionChanged(oldSelection, newSelection, added, removed)
    selectionIsCurrent = false

    if SelectionIsCurrent(newSelection) then
        selectionIsCurrent = true
    end
end

function MoveCurrentToWithOrder()
    table.insert(selectionWithOrder, selectionWithoutOrder[currentUnitIndex])
    table.remove(selectionWithoutOrder, currentUnitIndex)
end

---comment
---@param cmdMode CommandMode
---@param cmdModeData CommandModeData
---@param command any
function OnCommandIssued(cmdMode, cmdModeData, command)
    if not selectionIsCurrent then return end
    if command.CommandType == 'Guard' and not command.Target.EntityId then return end
    if command.CommandType == 'None' then return end

    MoveCurrentToWithOrder()
    ForkThread(SelectNext, false)
end

---comment
---@param cmdModeCommandMode
---@param cmdModeData CommandModeData
function OnCommandStarted(cmdMode, cmdModeData)
    if selectionIsCurrent then
        local cm = CM.GetCommandMode()
        commandMode, commandModeData = cm[1], cm[2]
    else
        return
    end
end

function CreateOrContinueSelection()
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

function Main(isReplay)
    if isReplay then return end

    CM.AddStartBehavior(OnCommandStarted)
    --CM.AddEndBehavior(OnCommandEnded)
end
