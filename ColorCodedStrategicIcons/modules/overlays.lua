local LayoutHelpers = import("/lua/maui/layouthelpers.lua")
local AddBeatFunction = import("/lua/ui/game/gamemain.lua").AddBeatFunction

local GetUnits = UMT.Units.GetFast
local Options = import("options.lua")

-- local engineersOption = Options.engineersOption
-- local factoriesOption = Options.factoriesOption
-- local siloOption = Options.siloOption
-- local massExtractorsOption = Options.massExtractorsOption

-- local engineersOverlay = engineersOption()
-- local factoriesOverlay = factoriesOption()
-- local siloOverlay = siloOption()
-- local massExtractorsOverlay = massExtractorsOption()

local overlays = UMT.Weak.Value {}

local Overlay = UMT.Views.UnitOverlay

local EngineerOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.isIdle = false
        if unit:IsInCategory("TECH1") then
            self:SetTexture("/mods/ColorCodedStrategicIcons/overlays/t1_idle.dds", 0)
        elseif unit:IsInCategory("TECH2") then
            self:SetTexture("/mods/ColorCodedStrategicIcons/overlays/t2_idle.dds", 0)
        elseif unit:IsInCategory("TECH3") and not unit:IsInCategory("SUBCOMMANDER") then
            self:SetTexture("/mods/ColorCodedStrategicIcons/overlays/t3_idle.dds", 0)
        elseif unit:IsInCategory("SUBCOMMANDER") then
            self:SetTexture("/mods/ColorCodedStrategicIcons/overlays/sacu_idle.dds", 0)
        end
    end,

    OnFrame = function(self, delta)
        if self.isIdle then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not engineersOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end
        self.isIdle = self.unit:IsIdle()
    end
}

local StationaryFactoryOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.isIdle = false

        local tempOverlays = {}

        if unit:IsInCategory("LAND") then
            table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/paused_factory_land.dds")
        elseif unit:IsInCategory("NAVAL") then
            table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/paused_factory_naval.dds")
        elseif unit:IsInCategory("AIR") then
            table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/paused_factory_air.dds")
        elseif unit:IsInCategory("GATE") then
            table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/paused_factory_gate.dds")
        end

        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_upgrading.dds")
        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_eng.dds")
        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_repeat.dds")

        self:SetTexture(tempOverlays)

        LayoutHelpers.SetDimensions(self, 32, 32)
    end,

    OnFrame = function(self, delta)
        self:Update()
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not factoriesOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end

        if GetIsPaused { self.unit } or self.unit:IsIdle() then
            self:SetFrame(0)
        elseif self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("FACTORY") then
            self:SetFrame(1)
        elseif self.unit:IsRepeatQueue() and self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("ENGINEER") then
            self:SetFrame(2)
        elseif self.unit:IsRepeatQueue() then
            self:SetFrame(3)
        else
            self:Hide()
        end
    end
}

local MobileFactoryOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.isIdle = false

        local tempOverlays = {}

        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_paused.dds")
        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_upgrading.dds")
        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_eng.dds")
        table.insert(tempOverlays, "/mods/ColorCodedStrategicIcons/overlays/fact_repeat.dds")

        self:SetTexture(tempOverlays)

        LayoutHelpers.SetDimensions(self, 32, 32)
    end,

    OnFrame = function(self, delta)
        self:Update()
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not factoriesOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end

        if GetIsPaused { self.unit } or self.unit:IsIdle() then
            self:SetFrame(0)
        elseif self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("FACTORY") then
            self:SetFrame(1)
        elseif self.unit:IsRepeatQueue() and self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("ENGINEER") then
            self:SetFrame(2)
        elseif self.unit:IsRepeatQueue() then
            self:SetFrame(3)
        else
            self:Hide()
        end
    end
}

local MissileSiloOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.siloStorageCount = 0

        self:SetTexture({
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_0.dds",
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_1.dds",
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_2.dds",
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_3.dds",
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_4.dds",
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_plus.dds", --TODO
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_plus.dds", --TODO
            "/mods/ColorCodedStrategicIcons/overlays/missile_loaded_plus.dds",
        })
    end,

    OnFrame = function(self, delta)
        self:Update()
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not siloOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end
        local mi = self.unit:GetMissileInfo()
        self.siloStorageCount = (mi.nukeSiloStorageCount or 0) + (mi.tacticalSiloStorageCount or 0)

        if self.siloStorageCount == 0 then
            self:SetFrame(0)
        elseif self.siloStorageCount == 1 then
            self:SetFrame(1)
        elseif self.siloStorageCount == 2 then
            self:SetFrame(2)
        elseif self.siloStorageCount == 3 then
            self:SetFrame(3)
        elseif self.siloStorageCount == 4 then
            self:SetFrame(4)
        elseif self.siloStorageCount == 5 then
            self:SetFrame(5)
        elseif self.siloStorageCount == 6 then
            self:SetFrame(6)
        elseif self.siloStorageCount > 6 then
            self:SetFrame(7)
        end
    end
}

local AntiNukeSiloOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.siloStorageCount = 0
        self:SetTexture({
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_0.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_1.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_2.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_3.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_4.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_5.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_6.dds",
            "/mods/ColorCodedStrategicIcons/overlays/antimissile_loaded_plus.dds",
        })
    end,

    OnFrame = function(self, delta)
        self:Update()
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not siloOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end
        local mi = self.unit:GetMissileInfo()
        self.siloStorageCount = (mi.nukeSiloStorageCount or 0) + (mi.tacticalSiloStorageCount or 0)

        if self.siloStorageCount == 0 then
            self:SetFrame(0)
        elseif self.siloStorageCount == 1 then
            self:SetFrame(1)
        elseif self.siloStorageCount == 2 then
            self:SetFrame(2)
        elseif self.siloStorageCount == 3 then
            self:SetFrame(3)
        elseif self.siloStorageCount == 4 then
            self:SetFrame(4)
        elseif self.siloStorageCount > 4 then
            self:SetFrame(5)
        end
    end
}

local MexOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 7
        self.offsetY = -7
        self.isUpgrading = false
        self:SetTexture("/mods/ColorCodedStrategicIcons/overlays/upgrading.dds", 0)
        LayoutHelpers.SetDimensions(self, 9, 10)
    end,

    OnFrame = function(self, delta)
        if self.isUpgrading then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        -- if self.unit:IsDead() or not massExtractorsOverlay then
        if self.unit:IsDead() then
            self:Destroy()
            return
        end
        self.isUpgrading = self.unit:GetWorkProgress() > 0
    end
}

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
            if unit:IsInCategory("ENGINEER") then
                overlays[id] = EngineerOverlay(worldView, unit)
            elseif unit:IsInCategory("FACTORY") and not unit:IsInCategory("EXTERNALFACTORYUNIT") and
                not unit:IsInCategory("EXPERIMENTAL") and not unit:IsInCategory("CRABEGG") then
                overlays[id] = StationaryFactoryOverlay(worldView, unit)
            elseif unit:IsInCategory("SILO") and
                (unit:IsInCategory("TACTICALMISSILEPLATFORM") or unit:IsInCategory("NUKE")) then
                overlays[id] = MissileSiloOverlay(worldView, unit)
            elseif unit:IsInCategory("SILO") and unit:IsInCategory("ANTIMISSILE") and
                unit:IsInCategory("TECH3") then
                overlays[id] = AntiNukeSiloOverlay(worldView, unit)
            elseif unit:IsInCategory("MASSEXTRACTION") and unit:IsInCategory("STRUCTURE") then
                overlays[id] = MexOverlay(worldView, unit)
            end
        end
    end
    UpdateOverlays()
end

function Init(isReplay)
    AddBeatFunction(CreateUnitOverlays, true)
end
