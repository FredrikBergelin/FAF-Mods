local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')

local modFolder = 'McBoomsMod'

local GetMexesManager = import('/mods/' .. modFolder .. '/modules/mex/MexesManager.lua').GetMexesManager
local MexRowButton = import('/mods/' .. modFolder .. '/modules/ui/MexRowButton.lua').MexRowButton
--local MainBeat = import('/mods/' .. modFolder .. '/modules/MainBeat.lua')
local MexRow = import('/mods/' .. modFolder .. '/modules/ui/MexRow.lua').MexRow
local SpecialsRow = import('/mods/' .. modFolder .. '/modules/ui/SpecialsRow.lua').SpecialsRow
local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local ForcedUpdateUnits = import('/mods/' .. modFolder .. '/modules/UnitManager.lua').ForcedUpdateUnits
local GetArmyManager = import('/mods/' .. modFolder .. '/modules/army/ArmyManager.lua').GetArmyManager

local instance = false

MexPanel = {}

function getInstance()
    if not instance then
        instance = MexPanel:new()
    end
    return instance
end

function MexPanel:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self

    o.x = 0
	o.y = 420
    o.controls = {}

    return o
end

function MexPanel:onCreate(_isReplay, _x, _y)
    if _isReplay then
        return
    end
    --print("creating panel")
    self.x = _x or self.x;
    self.y = _y or self.y;

    self.parent = import('/lua/ui/game/borders.lua').GetMapGroup()
    self.mexManager = GetMexesManager()
    self:createPanel()
end

function MexPanel:setExpanders(_rule, _callingControl, _expanded)
    if _rule=="all" then
        for i=1,3 do
            self.controls[i].expanderA:setExpanded(_expanded)
            if i<=2 then
                self.controls[i].expanderB:setExpanded(_expanded)
            end
        end
    elseif _rule=="type" then
        for i=1,3 do
            if not _callingControl.isUpgrading then
                self.controls[i].expanderA:setExpanded(_expanded)
            else
                if i<=2 then
                    self.controls[i].expanderB:setExpanded(_expanded)
                end
            end
        end
    elseif _rule=="tech" then
        local tech = _callingControl.tech
        if tech and tech>=1 and tech<=3 then
            self.controls[tech].expanderA:setExpanded(_expanded)
            if tech<=2 then
                self.controls[tech].expanderB:setExpanded(_expanded)
            end
        end
    end
end

function MexPanel:update()
    if self.mexManager then
        for i=1,4 do
            self.controls[i].expanderA:update()
            self.controls[i].rowA:update()

            if i~=3 then
                self.controls[i].expanderB:update()
                self.controls[i].rowB:update()
            end
        end
    end
end

function MexPanel:createPanel()
    self.controls = {}

    for tech = 1, 3 do
        local cat = self.mexManager:getCatFromIndex(tech)
        local mexcat = self.mexManager:getMexesForTech(cat)

        self.controls[tech] = {}

        self.controls[tech].icon = Bitmap(self.parent)
        self.controls[tech].icon:SetTexture(UIUtil.UIFile('/game/construct-tech_btn/t' .. tech .. '_btn_up.dds')) --UIUtil.UIFile('/game/avatar-engineers-panel/tech-' .. tech .. '_bmp.dds')

        self.controls[tech].expanderA = MexRowButton:new(self.parent, self, false, tech)
        self.controls[tech].expanderA:setExpanded(false)
        if tech==1 then
            LayoutHelpers.AtLeftTopIn(self.controls[tech].expanderA:getControl(), self.parent, self.x, self.y)
        else
            LayoutHelpers.AtLeftTopIn(self.controls[tech].expanderA:getControl(), self.parent, self.x, self.y + ((tech-1)*130))
        end
        if tech <= 2 then
            self.controls[tech].expanderB = MexRowButton:new(self.parent, self, true, tech)
            LayoutHelpers.Below(self.controls[tech].expanderB:getControl(), self.controls[tech].expanderA:getControl(), 0)
        end

        LayoutHelpers.Above(self.controls[tech].icon, self.controls[tech].expanderA:getControl(), 5)


        self.controls[tech].rowA = MexRow:new(self.parent, self.controls[tech].expanderA, mexcat.normal, false)
        if tech <= 2 then
            self.controls[tech].rowB = MexRow:new(self.parent, self.controls[tech].expanderB, mexcat.upgrading, true)
        end
    end

    self.controls[4] = {}
    local exp = self.controls[4]

    exp.icon = Bitmap(self.parent)
    exp.icon:SetTexture(UIUtil.UIFile('/game/construct-tech_btn/t4_btn_up.dds'))

    exp.expanderA = MexRowButton:new(self.parent, self, true, 4)
    exp.expanderA.tooltipText = "Expand or collapse this row."
    LayoutHelpers.AtLeftTopIn(exp.expanderA:getControl(), self.parent, self.x, self.y + ((4-1)*140) - 70)
    exp.expanderB = MexRowButton:new(self.parent, self, true, 4)
    exp.expanderB.tooltipText = "Expand or collapse this row."
    LayoutHelpers.Below(exp.expanderB:getControl(), exp.expanderA:getControl(), 0)

    LayoutHelpers.Above(exp.icon, exp.expanderA:getControl(), 5)

    local army = GetArmyManager()
    exp.rowA = SpecialsRow:new(self.parent, exp.expanderA, army:getExpsLists(), true)
    exp.rowB = SpecialsRow:new(self.parent, exp.expanderB, {army:getNukes(), army:getAntiNukes()}, false)

    --construction-tab_btn/experimental_icon_bmp

    self.info = MexPanelInfo:new(self.parent)
    LayoutHelpers.CenteredAbove(self.info.bg, self.controls[1].icon, 0)

    ToolTip.AddControlTooltip(self.info.bg, {text="Info", body=self.info.tooltipText})
end

MexPanelInfo = {}

function MexPanelInfo:new(_parent)
    local o = {}
    setmetatable(o,self)
    self.__index = self

    local buttonBackground = UIUtil.SkinnableFile('/dialogs/help/help-sm_btn.dds') --'/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
    o.bg = Bitmap(_parent, buttonBackground)
    o.bg.obj = o

    o.bg.Height:Set(40)
    o.bg.Width:Set(44)

    --local mexButtonClick = import('/mods/' .. modFolder .. '/modules/ui/MexButtonClick.lua').GetMexButtonClick()
    --o.tooltipText = "Mex Button Options:\r\n\r\nSingleClick = Select/Apply To One\r\n DoubleClick = Select/Apply To Row\r\n\r\nMouseButtons:\r\nLEFT = Upgrade/Pause\r\nCTTL+LEFT = Select\r\nCTRL+SHIFT+LEFT = Append Select\r\nRIGHT = Units Assist\r\nSHIFT+RIGHT = Units Append Assist\r\nCTRL+RIGHT = ZoomTo Mex"
    o.tooltipText = import('/mods/' .. modFolder .. '/modules/ui/MexButtonClick.lua').GetMexButtonClick():getClickOptionsText()
    o.tooltipText = o.tooltipText .. "\r\n" .. import('/mods/' .. modFolder .. '/modules/ui/SpecialsButtonClick.lua').GetSpecialsButtonClick():getClickOptionsText()
    o.bg:SetAlpha(0)

    o.bg.texture = Bitmap(o.bg)
    o.bg.texture.Height:Set(40)
    o.bg.texture.Width:Set(44)
    o.bg.texture:SetTexture(UIUtil.UIFile('/dialogs/help/help-sm_btn.dds'))
    LayoutHelpers.AtLeftTopIn(o.bg.texture, o.bg, 0, 0)

    return o
end