local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')

local modFolder = 'McBoomsMod'

local BaseClass = import('/mods/' .. modFolder .. '/modules/BaseClass.lua').BaseClass
local CreateIndexedTable = import('/mods/' .. modFolder .. '/modules/util/IndexedTable.lua').CreateIndexedTable
local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local Colors = Util.Colors

BaseButton = BaseClass:inherit("BaseButton")

function BaseButton:new(_parent, _row)
    local o = BaseClass:new()
    setmetatable(o,self)
    self.__index = self

    local buttonBackground = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')

    o.iconSet = false
    o.tooltipSet = false
    o.tooltipText = "Hover the (?) icon for options."

    o.row = _row
    o.parent = _parent
    o.items = CreateIndexedTable()
    o.selectedUnitIndex = 1

	o.colors = import('/mods/' .. modFolder .. '/modules/util/Util.lua').Colors
    o.colWhite = 'ffffffff'
    o.colYellow = 'FFFFD700'
    o.colRed = 'FFFA8072'
    o.colBlue = 'FF6495ED'
	o.colBlack = 'FF000000'
	o.colPause = 'FF8B0000'

    o.bg = Bitmap(_parent, buttonBackground)
    o.bg.btnObject = o

	o.bg.Height:Set(44)
	o.bg.Width:Set(44)

	o.colorPane = Bitmap(o.bg)
	o.colorPane.Height:Set(32)
	o.colorPane.Width:Set(32)
	o.colorPane:SetSolidColor(Colors.Black)
    o.colorPane:SetAlpha(0.35)
	LayoutHelpers.AtLeftTopIn(o.colorPane, o.bg, 6, 6)

	o.marker = Bitmap(o.bg)
	o.marker:SetTexture(UIUtil.UIFile('/game/avatar/pulse-bars_bmp.dds'))
	o.marker.Height:Set(54)
	o.marker.Width:Set(54)
    o.marker:Hide()
	LayoutHelpers.AtLeftTopIn(o.marker, o.bg, -5, -5)

	o.icon = Bitmap(o.bg)
	o.icon.Height:Set(34)
	o.icon.Width:Set(34)
    o.icon:SetAlpha(0.3)
	LayoutHelpers.AtLeftTopIn(o.icon, o.bg, 5, 5)

    o.health = StatusBar(o.bg, 0, 1, false, false,
							UIUtil.UIFile('/game/unit_bmp/bar-info-back_bmp.dds'),
							UIUtil.UIFile('/game/unit_bmp/bar-02_bmp.dds'), true, "Unit RO Health Status Bar")

	o.health.Width:Set(32)
	o.health.Height:Set(0)
	LayoutHelpers.AtLeftTopIn(o.health, o.bg, 6, 5)

	o.progress = StatusBar(o.bg, 0, 1, false, false,
							UIUtil.UIFile('/game/unit-over/health-bars-back-1_bmp.dds'),
							UIUtil.UIFile('/game/unit-over/bar01_bmp.dds'), true, "Unit RO Health Status Bar")

	o.progress.Width:Set(32)
	o.progress.Height:Set(0)
	LayoutHelpers.AtLeftTopIn(o.progress, o.bg, 6, 8)

	--o.income = UIUtil.CreateText(o.icon, '', 10, UIUtil.bodyFont)
	--o.income:SetColor(o.colYellow)
	--o.income:SetDropShadow(true)
    --LayoutHelpers.AtBottomIn(o.income, o.icon, 15)
	--LayoutHelpers.AtRightIn(o.income, o.icon, 2)
	--self:createTextBG(o.bg, o.income, '77000000')

	o.count = UIUtil.CreateText(o.icon, '', 10, UIUtil.bodyFont)
	o.count:SetColor('ffffffff')
	o.count:SetDropShadow(true)
	LayoutHelpers.AtBottomIn(o.count, o.icon, 0)
	LayoutHelpers.AtRightIn(o.count, o.icon, 2)
	self:createTextBG(o.bg, o.count, '77000000')

    o.ms = UIUtil.CreateText(o.icon, '', 10, UIUtil.bodyFont)
	o.ms:SetColor(Colors.Blue)
	o.ms:SetDropShadow(true)
	LayoutHelpers.AtBottomIn(o.ms, o.icon, 0)
	LayoutHelpers.AtLeftIn(o.ms, o.icon, 2)
	self:createTextBG(o.bg, o.ms, '77000000')

	o.pauseIcon = Bitmap(o.bg)
	o.pauseIcon.Height:Set(32)
	o.pauseIcon.Width:Set(32)
	o.pauseIcon:SetTexture(UIUtil.UIFile('/game/strategicicons/pause_rest.dds'))
	LayoutHelpers.AtLeftTopIn(o.pauseIcon, o.bg, 6, 6)

    return o
end

function BaseButton:init()
    
end

function BaseButton:getNextItemIndex()
    if self.selectedUnitIndex > self.items:count() then
        self.selectedUnitIndex = 1
    end
    local index = self.selectedUnitIndex
    self.selectedUnitIndex = self.selectedUnitIndex + 1
    return index
end

function BaseButton:clear()
	self.items:clear()
end

function BaseButton:getControl()
	return self.bg
end

function BaseButton:Show()
	self.bg:Show()
end

function BaseButton:Hide()
	self.bg:Hide()
end

function BaseButton:updateIcon()
end

function BaseButton:updateTooltip()
end

function BaseButton:setPaused(_b)
	if _b then
		--self.marker:Show()
		self.colorPane:SetSolidColor(Colors.DarkRed)
		self.pauseIcon:Show()
	else
		--self.marker:Hide()
		self.colorPane:SetSolidColor(Colors.Black)
		self.pauseIcon:Hide()
	end
end

function BaseButton:update()
    self:setPaused(false)
	self.marker:Hide()
    self.count:SetText(self.items:count())
    self:updateIcon()
    self:updateTooltip()
end

function BaseButton:createTextBG(parent, control, color)
	local background = Bitmap(control)
	background:SetSolidColor(color)
	background.Top:Set(control.Top)
	background.Left:Set(control.Left)
	background.Right:Set(control.Right)
	background.Bottom:Set(control.Bottom)
	background.Depth:Set(function() return parent.Depth() + 1 end)
end

function BaseButton:setTooltipText(_s)
	self.tooltipText = _s
    self.tooltipSet = false
end

function BaseButton:getNameFromBp(bp)
	return LOC(bp.Description)
end