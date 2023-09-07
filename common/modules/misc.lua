local Prefs = import("/lua/user/prefs.lua")

local storedUniqueIdentifier
local lastClickTime = -9999

function SingleOrDoubleClick(uniqueIdentifier, singleClickFunction, doubleClickFunction, distinct)
	ForkThread(function()
        storedUniqueIdentifier = uniqueIdentifier
        local curTime = GetSystemTimeSeconds()
        local diffTime = curTime - lastClickTime
        local decay = 0.001 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
        lastClickTime = curTime

        WaitSeconds(decay)

        if uniqueIdentifier == storedUniqueIdentifier and diffTime < decay then
            storedUniqueIdentifier = nil
            doubleClickFunction()
        elseif lastClickTime == curTime then
            -- Only run the single click if we dont register a double click during the decay time 
            singleClickFunction()
        end
    end)
end