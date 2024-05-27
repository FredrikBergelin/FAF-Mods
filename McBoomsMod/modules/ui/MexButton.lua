local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')

local modFolder = 'McBoomsMod'

local CreateIndexedTable = import('/mods/' .. modFolder .. '/modules/util/IndexedTable.lua').CreateIndexedTable
local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local MexButtonOnClickFunc = import('/mods/' .. modFolder .. '/modules/ui/MexButtonClick.lua').MexButtonOnClickFunc
local BaseButton = import('/mods/' .. modFolder .. '/modules/ui/BaseButton.lua').BaseButton
local Colors = Util.Colors

local nil_text = ""

local table_insert = table.insert
local table_getsize = table.getsize

MexButton = BaseButton:inherit("MexButton")

function MexButton:new(_parent, _row, _addPause)
    local o = BaseButton:new(_parent, _row)
    setmetatable(o,self)
    self.__index = self

    o.isUpgrading = _addPause
    o.addPause = _addPause

    o.bg.HandleEvent = MexButtonOnClickFunc

    o.health.Height:Set(3)
    if o.isUpgrading then
        o.progress.Height:Set(3)
    else
        o.progress.Height:Set(0)
    end

	o.income = UIUtil.CreateText(o.icon, '', 10, UIUtil.bodyFont)
	o.income:SetColor(Colors.Yellow)
	o.income:SetDropShadow(true)
    LayoutHelpers.AtBottomIn(o.income, o.icon, 15)
	LayoutHelpers.AtRightIn(o.income, o.icon, 2)
	self:createTextBG(o.bg, o.income, '77000000')

    return o
end

function MexButton:init()
end

function MexButton:Show()
	BaseButton.Show(self)
    --if self.pauseBtn then
    --    self.pauseBtn:Show()
    --end
end

function MexButton:Hide()
	BaseButton.Hide(self)
    --if self.pauseBtn then
    --    self.pauseBtn:Hide()
    --end
end

function MexButton:updateIcon()
    if (not self.iconSet) and self.items:count() > 0 then
        local unitBluePrint = self.items:get(1):GetBlueprint()
        local iconName1 = GameCommon.GetCachedUnitIconFileNames(unitBluePrint)
		self.icon:SetTexture(iconName1)
        self.iconSet = true
    end
end

function MexButton:updateTooltip()
    if (not self.tooltipSet) and self.items:count() > 0 then
        local unitBluePrint = self.items:get(1):GetBlueprint()
        ToolTip.AddControlTooltip(self.bg, {text=self:getNameFromBp(unitBluePrint), body=self.tooltipText})
        self.tooltipSet = true
    end
end

function MexButton:update()
    BaseButton.update(self)

    if self.items:count()<=0 then
        return
    end

    if self.row:isExpanded() then --self.items:count()==1 then
        local item = self.items:get(1)
        local unit = item:getUnit()
        self.health:SetValue(unit:GetHealth()/unit:GetMaxHealth())
        self.progress:SetValue(unit:GetWorkProgress())
        if self.isUpgrading then
            self.income:SetText(item:getTotalBp())
            self.income:SetColor(item:getTotalBp()>0 and Colors.Yellow or Colors.Red)
            --self.pauseBtn.setPauseBtnState(mex:getIsPaused())
            --self.pauseBtn:Show()
            if item:getIsPaused() then
                self:setPaused(true)
            end
        end
        self.ms:SetText(self.items:get(1):GetNumStorages())
        self.ms:SetColor(Colors.Blue)
        if item:getIsSelected() then
            self.marker:Show()
        end
    else --if self.items:count()>1 then
        local hp = 0
        local hpTot = 0
        local pg = 0
        local pgTot = 0
        local pauseCnt = 0
        local selectCnt = 0
        local item, unit
        for i=1, self.items:count() do
            item = self.items:get(i)
            unit = self.items:get(i):getUnit()
            hp = hp + unit:GetHealth()
            hpTot = hpTot + unit:GetMaxHealth()
            pg = pg + unit:GetWorkProgress()
            pgTot = pgTot + 1.0
            if item:getIsPaused() then
                pauseCnt = pauseCnt + 1
            end
            if item:getIsSelected() then
                selectCnt = selectCnt + 1
            end
        end
        self.health:SetValue(hpTot>0 and (hp/hpTot) or 0)
        self.progress:SetValue(pgTot>0 and (pg/pgTot) or 0)
        self.ms:SetText(selectCnt > 0 and tostring(selectCnt) or Util.GetNilText())
        self.ms:SetColor(Colors.Green)
        self.income:SetText(pauseCnt > 0 and "P="..tostring(pauseCnt) or Util.GetNilText())
        self.income:SetColor(Colors.Red)


        if self.isUpgrading and self.items:get(1):getIsPaused() then
            self:setPaused(true)
        end
        if self.items:get(1):getIsSelected() then
            self.marker:Show()
        end
        --if self.pauseBtn then
        --    self.pauseBtn:Hide()
        --end
    end
end