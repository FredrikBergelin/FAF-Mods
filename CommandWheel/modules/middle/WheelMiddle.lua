local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")
local Util = import('/lua/utilities.lua')
local Defaults = import("/mods/CommandWheel/modules/Constants.lua").Default

WheelMiddle = Class(Bitmap) {

    __init = function(self, parent, config, data)
        Bitmap.__init(self, parent, data)
        self._parent = parent
        self._config = config
        self._data = data

        self._radius = Utils.GetRelativeSize(config.Radius, parent.Width(), parent.Height()) or Defaults.Middle.Radius
        self.Width:Set(self._radius * 2)
        self.Height:Set(self._radius * 2)

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
    end,

    OnUnHover = function(self)
    end,

    IsInArea = function(self, x, y)
        return Util.GetDistanceBetweenTwoVectors(Vector(x, y, 0),  Vector(self._data.centerPos.x, self._data.centerPos.y, 0)) <= self._radius;
    end
}