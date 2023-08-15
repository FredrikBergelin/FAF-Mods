
local drawnotified = {}
function Resetdrawnotified()
    drawnotified = {}
end

function DoGameResultNew(armyID, result, currentEvents, _Resultstring, _Announces)
    local Resultstring = {}
    if armyID ~= GetFocusArmy() then
        Resultstring = _Resultstring.OtherArmy
    else 
        Resultstring = _Resultstring.MyArmy
    end

    if result == 'victory' then
        _Announces.AnnounceVictory(armyID, Resultstring.victory)
        return
    end

    if result ~= 'defeat' then
        return
    end

    local whokilledwho = {}
    local acuDestroyed = currentEvents.ACUDestroyed or {}
    for i,acu in pairs(acuDestroyed) do
        whokilledwho[acu.KilledArmy] = acu.InstigatorArmy
        -- print(acu.KilledArmy .. ' killed by ' .. acu.InstigatorArmy)
    end

    local message = ''

    local killerId = whokilledwho[armyID]

    if whokilledwho[killerId] == armyID then
        -- check if draw has been notified before
        if drawnotified[armyID] == nil and drawnotified[killerId] == nil then
            message = ' '.. LOC(Resultstring['draw']).. ' ' 
            _Announces.AnnounceDraw(armyID, message, killerId)
            drawnotified[armyID] = true
            drawnotified[killerId] = true
        end
    elseif killerId ~= nil then
        message = ' '.. LOC(Resultstring['defeat']).. ' ' 
        _Announces.AnnounceDeath(armyID, message, killerId)
    else

        -- ctrl + k
        message = ' killed by suicide '
        _Announces.AnnounceDeath(armyID, message, armyID)
    end
end
