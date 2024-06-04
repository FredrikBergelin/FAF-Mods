local AddBeatFunction = import("/lua/ui/game/gamemain.lua").AddBeatFunction
local GetUnits = UMT.Units.GetFast
local overlays = UMT.Weak.Value {}
local Overlay = UMT.Views.UnitOverlay

local NoFireOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = -20
        self.isNoFire = false
        self:SetTexture("/mods/ResourceControl/overlays/no_attack_state.dds", 0)
    end,

    OnFrame = function(self, delta)
        if self.isNoFire then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        self.isNoFire = IsInNoFireState(self.unit)
    end
}

function IsInNoFireState(unit)
    local fireState = GetFireState({ unit })
    return fireState == 1
end

local function UpdateOverlays()
    for _, overlay in overlays do
        if IsDestroyed(overlay) then
            continue
        end
        overlay:UpdateState()
    end
end

local function CreateUnitOverlays()
    local allunits = GetUnits()
    local worldView = import("/lua/ui/game/worldview.lua").viewLeft
    for id, unit in allunits do
        if IsDestroyed(overlays[id]) and not unit:IsDead() then
            if IsInNoFireState(unit) then
                overlays[id] = NoFireOverlay(worldView, unit)
            end
        end
    end
    UpdateOverlays()
end

function Init(isReplay)
    AddBeatFunction(CreateUnitOverlays, true)
end
