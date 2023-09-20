local Chat = import('/lua/ui/game/chat.lua')
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")

function Handle(item)
    if item.Action then
        item.Action()
        return
    end
end

function SelectSnipeUnits()
    ConExecute('UI_Lua import("/lua/keymap/smartSelection.lua").smartSelect("AIR -TRANSPORTATION -EXPERIMENTAL -ASF -SCOUT -FACTORY")')
    local units = GetSelectedUnits()
    units = EntityCategoryFilterDown((categories.AIR * categories.BOMBER) + (categories.AIR * categories.GROUNDATTACK), units)
    SelectUnits(units)
end

function SelectLandAnriAir()
    import("/lua/keymap/smartSelection.lua").smartSelect("LAND MOBILE ANTIAIR -EXPERIMENTAL")
end

function SelectIdleEngineerOnScreen()
    import("/lua/keymap/smartSelection.lua").smartSelect("ENGINEER -COMMAND -SUBCOMMANDER +inview +idle")
end

function GiveMass()
    GiveResource('Mass', {
        '^[mass]+$',
        '^[mass]+%s',
        '%s[mass]+$',
        '%s[mass]+%s'
    })
end

function GiveEnergy()
    GiveResource('Energy', {
        '^[e]+$',
        '^[e]+%s',
        '%s[e]+$',
        '%s[e]+%s',
        '^[energy]+$',
        '^[energy]+%s',
        '%s[energy]+$',
        '%s[energy]+%s'
    })
end

function GiveResource(type, patterns)
    local toArmyId = GetLastChatRequestArmy(patterns)
    if not toArmyId then
        toArmyId = GetLowestResourceOwnerArmy(type)
    end

    if not toArmyId then
        print('Ally not found')
        return
    end

    local armies = GetArmiesTable()
    local econData = GetEconomyTotals()
    local ratio = 0.5
    local toSend

    local args = {
        From = armies.focusArmy,
        To = toArmyId,
        Mass = 0,
        Energy = 0
    }

    if type == 'Mass' then
        toSend = math.floor((econData.stored.MASS or 0) * ratio)
    else
        toSend =  math.floor((econData.stored.ENERGY or 0) * ratio)
    end

    SessionSendChatMessage(Chat.FindClients(), {
        Chat = true,
        text = 'Sent ' .. toSend .. ' ' .. type .. ' to ' .. armies.armiesTable[toArmyId].nickname,
        to = 'allies'
    })

    args[type] = ratio
    SimCallback({
        Func = "GiveResourcesToPlayer",
        Args = args
    })
end

function GetLastChatRequestArmy(patterns)
    local chatHistory = import('/lua/ui/game/chat.lua').GetChatHistory()
    if not Utils.IsNonEmptyArray(chatHistory) then
        return
    end

    local armies = GetArmiesTable()
    local focusArmy = GetFocusArmy()

    local i = table.getn(chatHistory)
    while i > 0 do
        local chatLine = chatHistory[i]
        if chatLine.time < 15 and focusArmy ~= chatLine.armyID and IsAlly(armies.focusArmy, chatLine.armyID)
                and MatchesAny(chatLine.text, patterns) then
            return chatLine.armyID
        end

        i = i - 1
    end
end

function GetLowestResourceOwnerArmy(type)
    local scores = import('/lua/ui/game/score.lua').currentScores
    if not Utils.IsNonEmptyArray(scores) then
        print('Scores not available')
        return
    end

    local focusArmy = GetFocusArmy()
    local lowestResRate  = 1
    local lowestResRateArmy

    for armyId, score in scores do
        if focusArmy ~= armyId and IsAlly(focusArmy, armyId) and score.resources then
            local resRate

            if type == 'Mass' then
                resRate = score.resources.storage.storedMass / score.resources.storage.maxMass
            else
                resRate = score.resources.storage.storedEnergy / score.resources.storage.maxEnergy
            end

            if resRate <= lowestResRate then
                lowestResRate = resRate
                lowestResRateArmy = armyId
            end
        end
    end

    return lowestResRateArmy
end

function MatchesAny(text, patterns)
    local textLowered = string.lower(text)
    for _, pattern in patterns do
        if string.match(textLowered, pattern) then
            return true
        end
    end
    return false
end