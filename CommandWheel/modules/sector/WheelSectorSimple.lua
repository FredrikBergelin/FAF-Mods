local WheelSector = import("/mods/CommandWheel/modules/sector/WheelSector.lua").WheelSector
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local RichText = import("/mods/CommandWheel/modules/common/RichText.lua").RichText
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")

WheelSectorSimple = Class(WheelSector) {
    __init = function(self, parent, config, data)
        WheelSector.__init(self, parent, config, data)

        if data.item.Text then
            self._textControl = self:CreateTextControl()
        end
    end,

    CreateTextControl = function(self)
        local textConfigs = self:CollectTextConfigs()
        local textControl = RichText(self, textConfigs)
        local textSize = textControl:GetSize()

        local angleMiddle = Utils.GetAngleCenter(self._data.angleStart, self._data.angleEnd)
        local radMiddle = math.rad(angleMiddle)

        local x = math.ceil((self._data.radius + self._data.radius / 1.5 * math.cos(radMiddle)) - textSize.Width / 2)
        local y = math.ceil((self._data.radius + self._data.radius / 1.5 * math.sin(radMiddle)) - textSize.Height / 2)

        LayoutHelpers.AtLeftTopIn(textControl, self, LayoutHelpers.InvScaleNumber(x), LayoutHelpers.InvScaleNumber(y))
    end,

    CollectTextConfigs = function(self)
        local textConfigs = {}

        local itemConfigs = Utils.AsMatrix(self._data.item.Text)
        for _, itemConfig in itemConfigs do
            local mergedConfig = table.merged(table.merged({}, self._config.Text or {}), itemConfig);
            mergedConfig.Size = Utils.GetRelativeSize(mergedConfig.Size, self._parent.Width(), self._parent.Height())
            table.insert(textConfigs, mergedConfig)
        end

        return textConfigs
    end
}