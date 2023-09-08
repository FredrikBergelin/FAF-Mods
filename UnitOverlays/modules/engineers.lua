local LayoutHelpers = import("/lua/maui/layouthelpers.lua")
local Bitmap = import("/lua/maui/bitmap.lua").Bitmap
local Group = import("/lua/maui/group.lua").Group
local UIUtil = import("/lua/ui/uiutil.lua")
local Prefs = import("/lua/user/prefs.lua")
local AddBeatFunction = import("/lua/ui/game/gamemain.lua").AddBeatFunction
local LazyVar = import("/lua/lazyvar.lua")

local GetUnits = UMT.Units.GetFast
local Options = import("options.lua")
local LayoutFor = UMT.Layouter.ReusedLayoutFor

local engineersOption = Options.engineersOption
local factoriesOption = Options.factoriesOption
local supportCommanderOption = Options.supportCommanderOption
local commanderOverlayOption = Options.commanderOverlayOption
local siloOption = Options.siloOption
local massExtractorsOption = Options.massExtractorsOption

local engineersOverlay = engineersOption()
local factoriesOverlay = factoriesOption()
local commanderOverlay = commanderOverlayOption()
local supportCommanderOverlay = supportCommanderOption()
local siloOverlay = siloOption()
local massExtractorsOverlay = massExtractorsOption()

local overlays = UMT.Weak.Value {}

local Overlay = UMT.Views.UnitOverlay

local blinkState = true -- Should overlays that blinks be on
local frameCounter = 0

local EngineerOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.isIdle = false
        if unit:IsInCategory("TECH1") then
            self:SetTexture("/mods/UnitOverlays/textures/t1_idle.dds", 0)
        elseif unit:IsInCategory("TECH2") then
            self:SetTexture("/mods/UnitOverlays/textures/t2_idle.dds", 0)
        elseif unit:IsInCategory("TECH3") then
            self:SetTexture("/mods/UnitOverlays/textures/t3_idle.dds", 0)
        end
    end,

    OnFrame = function(self, delta)
        if self.isIdle and blinkState then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        if self.unit:IsDead() or not engineersOverlay then
            self:Destroy()
            return
        end
        self.isIdle = self.unit:IsIdle()
    end
}

local FactoryOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 0
        self.offsetY = 0
        self.isIdle = false
        self.showState = false

        local tempOverlays = {}

        if unit:IsInCategory("LAND") then
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/paused_factory_land.dds")
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/idle_factory_land.dds")
        elseif unit:IsInCategory("NAVAL") then
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/paused_factory_naval.dds")
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/idle_factory_naval.dds")
        elseif unit:IsInCategory("AIR") then
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/paused_factory_air.dds")
            table.insert(tempOverlays, "/mods/UnitOverlays/textures/idle_factory_air.dds")
        else
            WARN("------------NOT IN ANY CATEGORY-----------")
        end

        table.insert(tempOverlays, "/mods/UnitOverlays/textures/buildingEngineer.dds")
        table.insert(tempOverlays, "/mods/UnitOverlays/textures/repeat.dds")
        table.insert(tempOverlays, "/mods/UnitOverlays/textures/upgrading.dds")

        self:SetTexture(tempOverlays)

        LayoutHelpers.SetDimensions(self, 32, 32)
    end,

    OnFrame = function(self, delta)
        if self.showState then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        if self.unit:IsDead() or not factoriesOverlay then
            self:Destroy()
            return
        end

        if GetIsPaused { self.unit } then
            if blinkState then
                self:SetFrame(0)
                self.showState = true
            else
                self.showState = false
            end
        elseif self.unit:IsIdle() then
            if blinkState then
                self:SetFrame(1)
                self.showState = true
            else
                self.showState = false
            end
        elseif self.unit:IsRepeatQueue() and self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("ENGINEER") then
            self:SetFrame(2)
            self.showState = true
        elseif self.unit:IsRepeatQueue() then
            self:SetFrame(3)
            self.showState = true
        elseif self.unit:GetFocus() and self.unit:GetFocus():IsInCategory("FACTORY") then
            self:SetFrame(4)
            self.showState = true
        else
            self.showState = false
        end
    end
}

local SiloOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 5
        self.offsetY = 1
        self.hasSilo = false
        self:SetTexture("/mods/UnitOverlays/textures/loaded.dds", 0)
        LayoutHelpers.SetDimensions(self, 12, 12)
    end,

    OnFrame = function(self, delta)
        if self.hasSilo then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        if self.unit:IsDead() or not siloOverlay then
            self:Destroy()
            return
        end
        local mi = self.unit:GetMissileInfo()
        self.hasSilo = (mi.nukeSiloStorageCount > 0) or (mi.tacticalSiloStorageCount > 0)
    end
}
local MexOverlay = Class(Overlay)
{
    __init = function(self, parent, unit)
        Overlay.__init(self, parent, unit)
        self.offsetX = 5
        self.offsetY = -7
        self.isUpgrading = false
        self:SetTexture("/mods/UnitOverlays/textures/up.dds", 0)
        LayoutHelpers.SetDimensions(self, 12, 16)
    end,

    OnFrame = function(self, delta)
        if self.isUpgrading then
            self:Update()
        else
            self:Hide()
        end
    end,

    UpdateState = function(self)
        if self.unit:IsDead() or not massExtractorsOverlay then
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

    frameCounter = frameCounter + 1
    if (math.mod(frameCounter, 10) == 0) then
        blinkState = not blinkState
    end
end

local function CreateUnitOverlays()
    -- TODO
    local allunits = GetUnits()
    local worldView = import("/lua/ui/game/worldview.lua").viewLeft
    for id, unit in allunits do
        if IsDestroyed(overlays[id]) and not unit:IsDead() then
            if supportCommanderOverlay and unit:IsInCategory("SUBCOMMANDER") then
            elseif unit:IsInCategory("COMMAND") then
            elseif engineersOverlay and unit:IsInCategory("ENGINEER") then
                overlays[id] = EngineerOverlay(worldView, unit)
            elseif factoriesOverlay and unit:IsInCategory("FACTORY") then
                overlays[id] = FactoryOverlay(worldView, unit)
            elseif siloOverlay and unit:IsInCategory("SILO") then
                overlays[id] = SiloOverlay(worldView, unit)
            elseif massExtractorsOverlay and unit:IsInCategory("MASSEXTRACTION") and unit:IsInCategory("STRUCTURE") then
                overlays[id] = MexOverlay(worldView, unit)
            end
        end
    end
    UpdateOverlays()
end

function Init(isReplay)
    AddBeatFunction(CreateUnitOverlays, true)
    engineersOption.OnChange = function(var)
        engineersOverlay = var()
    end
    commanderOverlayOption.OnChange = function(var)
        commanderOverlay = var()
    end
    factoriesOption.OnChange = function(var)
        factoriesOverlay = var()
    end
    supportCommanderOption.OnChange = function(var)
        supportCommanderOverlay = var()
    end
    siloOption.OnChange = function(var)
        siloOverlay = var()
    end
    massExtractorsOption.OnChange = function(var)
        massExtractorsOverlay = var()
    end
end
