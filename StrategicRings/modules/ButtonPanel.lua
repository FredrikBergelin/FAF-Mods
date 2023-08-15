local Group = import('/lua/maui/group.lua').Group
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button

local UiConfig = {
    Panel = {
        PaddingX = 2,
        PaddingY = 2,
    },
    Column = {
        Width = 110,
        PaddingX = 0,
        PaddingY = 0,
    },
    Label = {
        Height = 20,
        FontSize = 16
    },
    Button = {
        Height = 30,
        FontSize = 12,
    }
}

ButtonPanel = Class(Group) {
    __init = function(self, GUI, columns)
        Group.__init(self, GUI)

        local height = 0
        local width = 0

        for idx, column in columns do
            local posX = UiConfig.Panel.PaddingX + (idx - 1) * UiConfig.Column.Width
            local posY = UiConfig.Panel.PaddingY

            local columnPanel = self:CreateColumn(column)
            LayoutHelpers.AtLeftTopIn(columnPanel, self, posX, posY)
            width = math.max(width, posX + UiConfig.Column.Width)
            height = math.max(height, columnPanel.Height())
        end

        self.Width:Set(LayoutHelpers.ScaleNumber(width + UiConfig.Panel.PaddingX))
        self.Height:Set(height + UiConfig.Panel.PaddingY * 2)
    end,

    CreateColumn = function(self, items)
        local columnPanel = Group(self)

        local width = UiConfig.Column.Width
        local height = 0

        for _, item in items do
            if item.Type == "Label" then
                local label = self:CreateLabel(columnPanel, item)
                LayoutHelpers.AtHorizontalCenterIn(label, columnPanel, 0)
                LayoutHelpers.AtTopIn(label, columnPanel, height)
                height = height + LayoutHelpers.InvScaleNumber(label.Height());

            elseif item.Type == "Button" then
                local btn = self:CreateButton(columnPanel, item)
                LayoutHelpers.AtLeftTopIn(btn, columnPanel, UiConfig.Column.PaddingX, height)
                height = height + LayoutHelpers.InvScaleNumber(btn.Height())
            end
        end

        columnPanel.Width:Set(LayoutHelpers.ScaleNumber(width))
        columnPanel.Height:Set(LayoutHelpers.ScaleNumber(height))

        return columnPanel;
    end,

    CreateButton = function(self, parent, item)
        local btn = Button(parent, UIUtil.UIFile('/scx_menu/operation-briefing/popup_btn_up.dds'),
                UIUtil.UIFile('/scx_menu/operation-briefing/popup_btn_down.dds'),
                UIUtil.UIFile('/scx_menu/operation-briefing/popup_btn_over.dds'),
                UIUtil.UIFile('/scx_menu/operation-briefing/popup_btn_dis.dds'))
        btn.Width:Set(LayoutHelpers.ScaleNumber(UiConfig.Column.Width - UiConfig.Column.PaddingX * 2))
        btn.Height:Set(LayoutHelpers.ScaleNumber(UiConfig.Button.Height))
        btn.label = UIUtil.CreateText(btn, item.Text, UiConfig.Button.FontSize, UIUtil.bodyFont)
        btn.label:DisableHitTest()

        local this = self;
        btn.OnClick = function(_, modifiers)
            this:OnClick(item, modifiers)
            return true
        end

        LayoutHelpers.AtCenterIn(btn.label, btn)

        return btn
    end,

    CreateLabel = function(_, parent, item)
        local label = UIUtil.CreateText(parent, item.Text, UiConfig.Label.FontSize, UIUtil.bodyFont)
        label.Height:Set(LayoutHelpers.ScaleNumber(UiConfig.Label.Height))
        label:SetDropShadow(true)
        return label
    end,

    OnClick = function(_, _, _)
    end
}
