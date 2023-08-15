local Util = import('/lua/utilities.lua')
local StrategicRings = import('/mods/StrategicRings/modules/StrategicRings.lua')
local DecalFactory = import('/mods/StrategicRings/modules/DecalFactory.lua')
local Config = import('/mods/StrategicRings/modules/Config.lua')

local ACTION_DELETE_CLOSEST = "DELETE_CLOSEST"
local ACTION_DELETE_LAST = "DELETE_LAST"
local ACTION_DELETE_SCREEN = "DELETE_SCREEN"
local ACTION_HOVER_RING = "HOVER_RING"

local _actions = {}

function DeleteLastAction()
    local count = table.getn(StrategicRings.getRings())
    if count <= 0 then
        return
    end

    StrategicRings.getRings()[count].decal:Destroy()
    table.remove(StrategicRings.getRings(), count)
end
_actions[ACTION_DELETE_LAST] = DeleteLastAction

function DeleteClosestAction()
    local count = table.getn(StrategicRings.getRings())
    if count <= 0 then
        return
    end

    local closest = {idx = nil, distance = nil, inner = nil}
    local mousePos = GetMouseWorldPos()

    for idx, ring in StrategicRings.getRings() do
        local distanceToCenter = Util.GetDistanceBetweenTwoVectors(mousePos, ring.pos)
        local distance = math.abs(distanceToCenter - ring.item.Radius)
        local inner = distanceToCenter <= ring.item.Radius;

        if not closest.distance
                or (inner and not closest.inner)
                or (inner == closest.inner and distance < closest.distance)
        then
            closest.idx = idx
            closest.distance = distance
            closest.inner = inner
        end
    end

    StrategicRings.getRings()[closest.idx].decal:Destroy()
    table.remove(StrategicRings.getRings(), closest.idx)
end
_actions[ACTION_DELETE_CLOSEST] = DeleteClosestAction

function DeleteScreenAction()
    local view = import('/lua/ui/game/worldview.lua').viewLeft

    local i = 1
    while i <= table.getn(StrategicRings.getRings()) do
        if OnScreen(view, StrategicRings.getRings()[i].pos) then
            StrategicRings.getRings()[i].decal:Destroy()
            table.remove(StrategicRings.getRings(), i)
        else
            i = i + 1
        end
    end
end
_actions[ACTION_DELETE_SCREEN] = DeleteScreenAction

function HoverRing()
    local rolloverInfo = GetRolloverInfo()
    if not rolloverInfo or rolloverInfo.blueprintId == 'unknown' then
        return
    end

    local blueprint = __blueprints[rolloverInfo.blueprintId];

    for _, config in Config.Hover do
        if (not config.Category or EntityCategoryContains(config.Category, blueprint.BlueprintId))
            and (not config.Predicate or config.Predicate(blueprint))
            and config.Supplier then
            CreateRing({
                Radius = config.Supplier(blueprint),
                Texture = config.Texture,
                Static = true
            })

            return
        end
    end
end
_actions[ACTION_HOVER_RING] = HoverRing

function CreateRing(item)
    if item.Action then
        _actions[item.Action]()
        return true
    end

    if item.Static == false then
        DecalFactory.CreateRingDynamic(item.Radius, item.Texture, function(ring)
            table.insert(StrategicRings.getRings(),{
                decal = ring.decal,
                pos = ring.pos,
                item = item
            })
        end)
    else
        local ring = DecalFactory.CreateRing(GetMouseWorldPos(), item.Radius, item.Texture)
        table.insert(StrategicRings.getRings(),{
            decal = ring.decal,
            pos = ring.pos,
            item = item
        })
    end
end

function OnScreen(view, pos)
    local proj = view:Project(Vector(pos[1], pos[2], pos[3]))
    return not (proj.x < 0 or proj.y < 0 or proj.x > view.Width() or proj.y > view:Height())
end

function GetActions()
    return _actions
end