local Text = import('/lua/maui/text.lua').Text
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

DEFAULT_TEXT_FONT = UIUtil.bodyFont
DEFAULT_TEXT_SIZE = 20
MIN_TEXT_SIZE = 10
MAX_TEXT_SIZE = 70
DEFAULT_TEXT_COLOR = 'ffffff'

RichText = Class(Bitmap) {
    __init = function(self, parent, items)
        Bitmap.__init(self, parent)

        self._parent = self
        self._size = {
            Width = 0,
            Height = 0
        }
        self._controls = self:CreateTextLine(items)

        LayoutHelpers.AtLeftTopIn(self, parent, 0, 0)
    end,

    CreateTextLine = function(self, items)
        local textControls = {};

        local y = 0

        for idx, item in items do
            local textControl = self:CreateText(item)

            if idx > 1 then
                y = textControls[idx - 1].Height() - textControl.Height()
            end

            LayoutHelpers.AtLeftTopIn(textControl, self, LayoutHelpers.InvScaleNumber(self._size.Width), LayoutHelpers.InvScaleNumber(y))

            self._size.Height = math.max(self._size.Height, textControl.Height())
            self._size.Width = self._size.Width + textControl.Width()

            table.insert(textControls, textControl)
        end

        return textControls
    end,

    CreateText = function(self, item)
        local font = item.Font or DEFAULT_TEXT_FONT
        local size = item.Size or DEFAULT_TEXT_SIZE
        local color = item.Color or DEFAULT_TEXT_COLOR

        if size < MIN_TEXT_SIZE then
            size = MIN_TEXT_SIZE
        elseif size > MAX_TEXT_SIZE then
            size = MAX_TEXT_SIZE
        end

        local textControl = Text(self)

        textControl:SetFont(font, LayoutHelpers.InvScaleNumber(size))
        textControl:SetColor(color)
        textControl:SetText(item.Value)
        textControl:DisableHitTest()
        textControl:SetDropShadow(true)

        return textControl
    end,

    GetSize = function(self)
        return self._size
    end
}