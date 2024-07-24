--- Called by the engine when a new command has been issued by the player.
-- @param command Information surrounding the command that has been issued, such as its CommandType or its Target.
---@param command UserCommand
function OnCommandIssued(command)
    -- not command.Clear = when we hold shift, to queue up multiple commands.
    if not command.Clear then
        -- signal for OnCommandModeBeat to end commandMode at the next beat
        -- potentially removable? dont see the effect
        issuedOneCommand = true
    end

    -- If our callback returns true or we don't have a command type, we skip the rest of our logic
    if (OnCommandIssuedCallback[command.CommandType] and OnCommandIssuedCallback[command.CommandType](command))
    or command.CommandType == 'None' then
        -- we do still need to end the commandmode for things like HotBuild.
        if command.Clear then
            -- but only when not using the cheat menu, which should stay open.
            if modeData and not modeData.cheat or not modeData then
                EndCommandMode(true)
            end
        end
        return
    end
    
    if command.Clear then
        EndCommandMode(true)
        if command.CommandType ~= 'Stop'
        and TableGetN(command.Units) == 1
        and checkBadClean(command.Units[1]) then
            watchForQueueChange(command.Units[1])
        end
    end

    AddCommandFeedbackByType(command)
end