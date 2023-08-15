local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')
local completeCycleSound = Sound { Cue = 'UI_Menu_Error_01', Bank = 'Interface', }

local currentIndex
local selection
local commandMode
local commandModeData
local currentUnit
local updateCommandMode

KeyMapper.SetUserKeyAction('Activate/return to individual cycling with saved command', {
    action = 'UI_Lua import("/mods/IndividualCommandCycler/modules/Main.lua").CreateOrContinueSelection()',
    category = 'Individual Command Cycler'
})

local function IsActive()
    return selection ~= nil
end

local function Reset(deselect)
    currentIndex = nil
    commandMode = nil
    commandModeData = nil
    currentUnit = nil
    if deselect then
        SelectUnits(nil)
    end
end

function ReduceIndex(index)
    if index > 1 then
        return (index - 1)
    -- To select the first the next function needs nil not 0
    else
        return nil
    end
end

-- Select next unit in the saved selection
function SelectNext(dontSelect)
    local unit
    local i = currentIndex

    repeat
        if selection == nil or table.getn(selection) == 0 then
            Reset()
            return
        end

        i, unit = next(selection, i)

        if i == nil then
            -- We reached the end
            PlaySound(completeCycleSound)
            SelectUnits(nil)
            currentIndex = nil
            return
        end

        -- if unit == nil then
        --     Reset()
        --     return
        -- else

        if unit:IsDead() then
            table.remove(selection, i)

        else
            currentIndex = i
            currentUnit = unit

            if not dontSelect then
                SelectUnits { unit }
                CM.StartCommandMode(commandMode, commandModeData)
            end

            return
        end
    until false
end

function SelectionIsCurrent(units)
    if currentUnit == nil then
        return false
    end
    if currentUnit:IsDead() then
        SelectNext(true)
    end

    if units ~= nil then
        if table.getn(units) == 1 then
            if units[1] == currentUnit then
                return true
            end
        end
    end
end

function CreateSelection(units)
    local selectedUnits = GetSelectedUnits()

    Reset()
    selection = selectedUnits

    SelectNext()
end

function SelectionChanged(oldSelection, newSelection, added, removed)
    updateCommandMode = false

    if table.getn(newSelection) == 0 then
        return
    end

    if SelectionIsCurrent(newSelection) then
        updateCommandMode = true
    end
end

---comment
---@param cmdMode CommandMode
---@param cmdModeData CommandModeData
---@param command any
function OnCommandIssued(cmdMode, cmdModeData, command)

    if not IsActive() then return end
    if not updateCommandMode then return end

    if command.CommandType == 'Guard' and not command.Target.EntityId then return end
    if command.CommandType == 'None' then return end

    ForkThread(SelectNext, false)
end

---comment
---@param cmdMode CommandMode
---@param cmdModeData CommandModeData
function OnCommandStarted(cmdMode, cmdModeData)
    if updateCommandMode then
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
            SelectNext()
            return
        end
    end

    currentIndex = ReduceIndex(currentIndex)
    SelectNext()

end

function Main(isReplay)
    if isReplay then return end

    CM.AddStartBehavior(OnCommandStarted)
    --CM.AddEndBehavior(OnCommandEnded)
end
