local WheelMiddle = import("/mods/CommandWheel/modules/middle/WheelMiddle.lua").WheelMiddle
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local RichText = import("/mods/CommandWheel/modules/common/RichText.lua").RichText
local WheelFactory = import("/mods/CommandWheel/modules/WheelFactory.lua")
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")
local Defaults = import("/mods/CommandWheel/modules/Constants.lua").Default

WheelMiddleSimple = Class(WheelMiddle) {
    __init = function(self, parent, config, data)
        WheelMiddle.__init(self, parent, config, data)

        self:SetAlpha(config.Alpha or Defaults.Alpha)
        self:SetTexture(WheelFactory.getWheelMiddleTexture(config.Texture or Defaults.Texture))

        if config.Text then
            self._textControl = self:CreateTextControl()
        end
    end,

    OnHover = function(self)
        self:SetAlpha(self._config.Hover.Alpha or Defaults.Hover.Alpha)
    end,

    OnUnHover = function(self)
        self:SetAlpha(self._config.Alpha or Defaults.Alphaa)
    end,

    OnAction = function(self)
        WheelFactory.getActionHandler(self._config.ActionType).Handle({Action = self._config.Action})
    end,

    CreateTextControl = function(self)
        local textConfigs = self:CollectTextConfigs()
        local textControl = RichText(self, textConfigs)
        local textSize = textControl:GetSize()

        local x = self._radius - textSize.Width / 2
        local y = self._radius - textSize.Height / 2

        LayoutHelpers.AtLeftTopIn(textControl, self, LayoutHelpers.InvScaleNumber(x), LayoutHelpers.InvScaleNumber(y))
    end,

    CollectTextConfigs = function(self)
        local textConfigs = {}

        local itemConfigs = Utils.AsMatrix(self._config.Text)
        for _, itemConfig in itemConfigs do
            itemConfig.Size = Utils.GetRelativeSize(itemConfig.Size, self._parent.Width(), self._parent.Height())
            table.insert(textConfigs, itemConfig)
        end

        return textConfigs
    end
}