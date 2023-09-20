local CM = import("/lua/ui/game/commandmode.lua")
local KeyMapper = import('/lua/keymap/keymapper.lua')

local locked = false

function IsLocked()
    return locked
end

function Reset()
    ConExecute 'StartCommandMode order RULEUCC_Move'
end

function Test()
    
end

function Toggle()
    locked = not locked
    Reset()
end

function Cancel()
    locked = not locked
end

---comment
---@param commandMode CommandMode
---@param commandModeData CommandModeData
function OnCommandStarted(commandMode, commandModeData)
    if locked and (commandModeData and commandModeData.name ~= "RULEUCC_Move") then
        locked = false
        ForkThread(function ()
            ConExecute ('StartCommandMode order '..commandModeData.name)
        end)
    end
end

---comment
---@param commandMode CommandMode
---@param commandModeData CommandModeData
function OnCommandEnded(commandMode, commandModeData)
    if locked and (commandModeData and commandModeData.name == "RULEUCC_Move") then
        ForkThread(Reset)
    end
end

function Main(isReplay)
    if isReplay then return end

    CM.AddStartBehavior(OnCommandStarted)
    CM.AddEndBehavior(OnCommandEnded)
end

KeyMapper.SetUserKeyAction('Persistent move order', {
    action = 'UI_Lua import("/mods/Move/modules/Main.lua").Toggle()',
    category = 'orders'
})