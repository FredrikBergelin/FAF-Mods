local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Group = import('/lua/maui/group.lua').Group
local WheelFactory = import("/mods/CommandWheel/modules/WheelFactory.lua")
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")
local WorldView = import('/lua/ui/game/worldview.lua')
local Prefs = import('/lua/user/prefs.lua')
local Defaults = import("/mods/CommandWheel/modules/Constants.lua").Default

local oldWorldHandleEvent
local START_ANGLE = {
    [4] = 45,
    [8] = 22.5,
    [12] = 0,
    [18] = 0
}

WheelPanel = Class(Group) {
    __init = function(self, parent, config, mousePos)
        Group.__init(self, parent)

        local itemsCount = table.getn(config.Items)
        if not START_ANGLE[itemsCount] then
            print('Item count not supported: ' .. itemsCount)
            return
        end

        self._hoveredControl = nil
        self._config = config
        self._radius = Utils.GetRelativeSize(config.Ui.Radius, parent.Width(), parent.Height()) or Defaults.Radius
        self._mouseX = mousePos.x
        self._mouseY = mousePos.y
        self._trigger = Prefs.GetFromCurrentProfile('options').cw_trigger or config.Trigger or Defaults.Trigger

        if config.Position == 'MOUSE' then
            self._centerPos = mousePos
        else
            self._centerPos = Vector(parent.Width() / 2, parent.Height() / 2, 0)
        end

        self.Width:Set(self._radius * 2)
        self.Height:Set(self._radius * 2)
        LayoutHelpers.AtLeftTopIn(self, parent, LayoutHelpers.InvScaleNumber(self._centerPos.x - self._radius), LayoutHelpers.InvScaleNumber(self._centerPos.y - self._radius))

        self.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
        self:SetNeedsFrameUpdate(true)
        self:AcquireKeyboardFocus(true)
        self:RegisterWorldEventHandler(function(_, event)
            self:HandleWorldEvent(event)
        end)

        self._controls = {
            middle = self:CreateWheelMiddle(),
            sectors = self:CreateWheelSectors()
        }
    end,

    HandleEvent = function(self, event)
        if event.Type == 'MouseMotion' then
            self._mouseX = event.MouseX
            self._mouseY = event.MouseY
        elseif event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                self:OnAction()
            else
                self:Close()
            end
        elseif event.Type == 'KeyDown' then
            if event.KeyCode == UIUtil.VK_ESCAPE then
                self:Close()
            end
        elseif event.Type == 'KeyUp' then
            if self._trigger == 'KEY_HOLD' then
                self:Close()
            elseif self._trigger == 'KEY_UP' then
                self:OnAction()
            end
        end
    end,

    HandleWorldEvent = function(self, event)
        if event.Type == 'ButtonPress' then
            self:Close()
        end
    end,

    OnFrame = function(self)
        self._hoveredControl = nil

        local isInMiddle = self._controls.middle:IsInArea(self._mouseX, self._mouseY)
        if isInMiddle then
            self._controls.middle:OnMotion(true)
            self._hoveredControl = self._controls.middle
        else
            self._controls.middle:OnMotion(false)
        end

        local pointAngle = Utils.GetPointAngle(self._centerPos.x, self._centerPos.y, self._mouseX, self._mouseY)
        for _, sectorControl in self._controls.sectors do
            if not isInMiddle and sectorControl:IsInArea(pointAngle) then
                sectorControl:OnMotion(true)
                self._hoveredControl = sectorControl
            else
                sectorControl:OnMotion(false)
            end
        end
    end,

    OnAction = function(self)
        if self._hoveredControl == nil then
            return
        end

        self:Close()
        self._hoveredControl:OnAction()
    end,

    CollectSectors = function(self)
        local sectors = {}

        local itemsCount = table.getn(self._config.Items)
        local angleStart = START_ANGLE[itemsCount]
        local angleStep = 360 / itemsCount

        for idx, item in self._config.Items do
            local angleEnd = angleStart + angleStep
            if angleEnd > 360 then
                angleEnd = angleEnd - 360
            end

            table.insert(sectors, {
                item = item,
                num = idx,
                count = itemsCount,
                centerPos = self._centerPos,
                radius = self._radius,
                angleStart = angleStart,
                angleEnd = angleEnd
            })
            angleStart = angleEnd
        end

        return sectors
    end,

    CreateWheelMiddle = function(self)
        return WheelFactory.createWheelMiddle(self, self._config.Ui.Middle, {
            centerPos = self._centerPos
        })
    end,

    CreateWheelSectors = function(self)
        local sectorControls = {}
        local sectors = self:CollectSectors()

        for _, sector in sectors do
            table.insert(sectorControls, WheelFactory.createWheelSector(self, self._config.Ui.Sector, sector))
        end

        return sectorControls
    end,

    RegisterWorldEventHandler = function(_, handler)
        local worldview = WorldView.viewLeft
        oldWorldHandleEvent = worldview.HandleEvent

        worldview.HandleEvent = handler
    end,

    RestoreWorldEventHandler = function(_)
        if oldWorldHandleEvent then
            local worldview = WorldView.viewLeft
            worldview.HandleEvent = oldWorldHandleEvent
        end
    end,

    Close = function(self)
        self:Destroy()
        self:RestoreWorldEventHandler()
    end
}