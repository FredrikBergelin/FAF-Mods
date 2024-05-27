local GameMain = import('/lua/ui/game/gamemain.lua')
local Config = import('/mods/CommandWheel/modules/Config.lua')
local CommandWheel = import("/mods/CommandWheel/modules/CommandWheel.lua")

function OpenWheel(wheelName)
    if GameMain.GetReplayState() then
        return
    end

    CommandWheel.OpenWheel(Config.Wheels[wheelName])
end