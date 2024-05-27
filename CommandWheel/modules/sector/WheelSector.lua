local WheelFactory = import("/mods/CommandWheel/modules/WheelFactory.lua")
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Defaults = import("/mods/CommandWheel/modules/Constants.lua").Default

WheelSector = Class(Bitmap) {
    __init = function(self, parent, config, data)
        Bitmap.__init(self, parent)

        self._parent = parent
        self._config = config
        self._data = data
        self._hovered = false

        self.Width:Set(data.radius * 2)
        self.Height:Set(data.radius * 2)
        self:SetAlpha(config.Alpha or Defaults.Alpha)
        self:SetNeedsFrameUpdate(true)
        self:SetTexture(WheelFactory.getWheelSectorTexture(config.Texture or Defaults.Texture, data.count, data.num))

        LayoutHelpers.AtCenterIn(self, parent, 0, 0)
    end,

    OnMotion = function(self, hovered)
        if hovered and not self._hovered then
            self:OnHover()
        elseif not hovered and self._hovered then
            self:OnUnHover()
        end

        self._hovered = hovered
    end,

    OnHover = function(self)
        self:SetAlpha(self._config.Hover.Alpha or Defaults.Hover.Alpha)
    end,

    OnUnHover = function(self)
        self:SetAlpha(self._config.Alpha or Defaults.Alpha)
    end,

    OnAction = function(self)
        WheelFactory.getActionHandler(self._data.item.ActionType or self._config.ActionType).Handle(self._data.item)
    end,

    IsInArea = function(self, pointAngle)
        return (pointAngle >= self._data.angleStart and pointAngle <= self._data.angleEnd)
                or ((self._data.angleEnd < self._data.angleStart)
                and ((pointAngle > self._data.angleStart) or (pointAngle < self._data.angleEnd)))
    end
}