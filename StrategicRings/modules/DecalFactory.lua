local Decal = import('/lua/user/userdecal.lua').UserDecal
local EscapeHandler = import('/lua/ui/dialogs/eschandler.lua')
local WorldView = import('/lua/ui/game/worldview.lua')

Textures = {
    RED = '/mods/StrategicRings/textures/ring_red.dds',
    YELLOW = '/mods/StrategicRings/textures/ring_yellow.dds',
    BLUE = '/mods/StrategicRings/textures/ring_blue.dds',
    VIOLET = '/mods/StrategicRings/textures/ring_violet.dds'
}

local activeRing
local oldWorldHandleEvent

function CreateRing(pos, radius, texture)
    local decal = Decal(GetFrame(0))
    decal:SetTexture(Textures[texture])
    decal:SetScale({math.floor(2.03 * radius), 0, math.floor(2.03 * radius)})
    local decalPos = Vector(pos.x, pos.y, pos.z)
    decal:SetPosition(decalPos)

    return {
        decal = decal,
        radius = radius,
        pos = decalPos
    }
end

function CreateRingDynamic(radius, texture, onCreate)
    if activeRing then
        return
    end

    RegisterEscapeHandler()
    RegisterWorldEventHandler(function(_, event)
        local mousePos = GetMouseWorldPos()

        if not activeRing then
            activeRing = CreateRing(mousePos, radius, texture)
        end

        if event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                onCreate(CreateRing(mousePos, radius, texture))

                if event.Modifiers.Shift then
                    return true
                end
            end

            DestroyActiveDecal()
            RestoreWorldEventHandler()

            return true
        else
            activeRing.decal:SetPosition(GetMouseWorldPos())
        end
    end)
end

function DestroyActiveDecal()
    if activeRing then
        activeRing.decal:Destroy()
        activeRing = nil
    end
end

function RegisterWorldEventHandler(handler)
    local worldview = WorldView.viewLeft
    oldWorldHandleEvent = worldview.HandleEvent

    worldview.HandleEvent = handler
end

function RestoreWorldEventHandler()
    if oldWorldHandleEvent then
        local worldview = WorldView.viewLeft
        worldview.HandleEvent = oldWorldHandleEvent
    end
end

function RegisterEscapeHandler()
    EscapeHandler.PushEscapeHandler(function()
        EscapeHandler.PopEscapeHandler()
        OnEscapePressed()
    end)
end

function OnEscapePressed()
    RestoreWorldEventHandler()
    DestroyActiveDecal()
end