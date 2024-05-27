local CommandWheel = import("/mods/CommandWheel/modules/CommandWheel.lua")

function Handle(item)
    if not item.Action then
        return
    end

    local pingType = item.Action;
    local position = CommandWheel.GetWheelWorldPos() or GetMouseWorldPos()

    local data = table.merged({
        Owner = GetFocusArmy() - 1,
        Type = pingType,
        Location = position
    }, import("/lua/ui/game/ping.lua").PingTypes[pingType])

    if pingType == 'marker' and item.MarkerText then
        local armies = GetArmiesTable()
        local army = armies.armiesTable[armies.focusArmy]
        local text = item.MarkerText

        if item.MarkerNickname then
            if text then
                text = text .. ': ' .. army.nickname
            else
                text = army.nickname
            end
        end

        if item.MarkerTimestamp then
            local time = math.ceil(GetGameTimeSeconds())
            local formattedTime = string.format("%.2d:%.2d", time / 60, math.mod(time, 60))

            if text then
                text = text .. ' [' .. formattedTime .. '] '
            else
                text = formattedTime
            end
        end

        data.Name = text
        data.Color = armies.armiesTable[armies.focusArmy].color

        SimCallback({
            Func = 'SpawnPing',
            Args = data
        })
    elseif pingType == 'marker' then
        import("/lua/ui/game/ping.lua").NamePing(function(name)
            local armies = GetArmiesTable()

            data.Name = name
            data.Color = armies.armiesTable[armies.focusArmy].color
            SimCallback({
                Func = 'SpawnPing',
                Args = data
            })
        end)
    else
        SimCallback({
            Func = 'SpawnPing',
            Args = data
        })
    end
end