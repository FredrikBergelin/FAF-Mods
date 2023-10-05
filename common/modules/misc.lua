local Prefs = import("/lua/user/prefs.lua")

local storedUniqueIdentifier
local clickCount = 1
local lastClickTime = -9999

function SingleOrDoubleClick(uniqueIdentifier, singleClickFunction, doubleClickFunction, distinct)
	ForkThread(function()
        storedUniqueIdentifier = uniqueIdentifier
        local currentTime = GetSystemTimeSeconds()
        local diffTime = currentTime - lastClickTime
        local decay = 0.001 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')
        lastClickTime = currentTime

        WaitSeconds(decay)

        if uniqueIdentifier == storedUniqueIdentifier and diffTime < decay then
            storedUniqueIdentifier = nil
            doubleClickFunction()
        elseif lastClickTime == currentTime then
            -- Only run the single click if we dont register a double click during the decay time 
            singleClickFunction()
        end
    end)
end

function ClickCount(uniqueIdentifier)
    local currentTime = GetSystemTimeSeconds()

    if storedUniqueIdentifier == uniqueIdentifier then
        local diffTime = currentTime - lastClickTime
        local decay = 0.001 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay')

        if diffTime < decay then
            clickCount = clickCount + 1
        else
            clickCount = 1
        end
    else
        clickCount = 1
    end

    lastClickTime = currentTime
    storedUniqueIdentifier = uniqueIdentifier

    return clickCount
end

function AnyUnitSelected()
    local units = GetSelectedUnits()
    if (units ~= nil) then
        return true
    else
        return false
    end
end

-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating

function ArrayRemove(t, fnKeep)
    local j, n = 1, table.getn(t)

    for i=1,n do
        if (fnKeep(t, i, j)) then
            if (i ~= j) then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        else
            t[i] = nil
        end
    end

    return t
end

-- function ArrayRemove(t, fnKeep)
--     LOG("ArrayRemove")

--     local j = 1
--     local n = table.getn(t)

--     for i=1, n do
--         if (fnKeep(t, i, j)) then
--             -- Move i's kept value to j's position, if it's not already there.
--             if (i ~= j) then
--                 t[j] = t[i]
--                 t[i] = nil
--             end
--             j = j + 1 -- Increment position of where we'll place the next kept value.
--         else
--             t[i] = nil
--         end
--     end

--     return t
-- end
