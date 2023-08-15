local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')

local modFolder = 'McBoomsMod'

local GetArmyManager = import('/mods/' .. modFolder .. '/modules/army/ArmyManager.lua').GetArmyManager
local SpecialsButtonOnClickFunc = import('/mods/' .. modFolder .. '/modules/ui/SpecialsButtonClick.lua').SpecialsButtonOnClickFunc
local BaseButton = import('/mods/' .. modFolder .. '/modules/ui/BaseButton.lua').BaseButton
local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local Colors = Util.Colors

local iconNameCache = {}
local headerTextCache = {}

SpecialsButton = BaseButton:inherit("SpecialsButton")

function SpecialsButton:new(_parent, _row, _isExperimental)
    local o = BaseButton:new(_parent, _row)
    setmetatable(o,self)
    self.__index = self

    o.isSpecialsButton = true
    o.isExperimental = _isExperimental
    o.addPause = not _isExperimental
    o.lastGameSecond = 0
    o.iconTexture = false
    o.expandedCache = o.row:isExpanded()

    --o.bg.HandleEvent = SpecialsButtonOnClickFunc

    o.tooltipHeader = "Unit"
    o.tooltipText = "Hover the (?) icon for options.\r\nAdditionally use ALT+LEFT mouse to send E.T.A. to chat."

    -- we need to change the tooltip text dynamically for this button:
    o.bg.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            ToolTip.CreateMouseoverDisplay(self,
                {
                    text = o.tooltipHeader,
                    body = o.tooltipText
                }, false, true
            )
        elseif event.Type == 'MouseExit' then
            ToolTip.DestroyMouseoverDisplay()
        end
        return SpecialsButtonOnClickFunc(self, event)
    end

    o.health.Height:Set(3)
    o.progress.Height:Set(3)

 	o.income = UIUtil.CreateText(o.icon, '', 10, UIUtil.fixedFont)
	o.income:SetColor(Colors.Yellow)
	o.income:SetDropShadow(true)
    LayoutHelpers.AtCenterIn(o.income, o.icon, 0, 0)
	o:createTextBG(o.bg, o.income, '77000000')

    return o
end

function SpecialsButton:init()
end

function SpecialsButton:updateIcon()
    if (not self.iconSet) and self.items:count() > 0 then
        local unitBluePrint = self.items:get(1):GetBlueprint()
        local iconName1
        if iconNameCache[unitBluePrint] then
            iconName1 = iconNameCache[unitBluePrint]
        else
            iconName1 = GameCommon.GetCachedUnitIconFileNames(unitBluePrint)
            iconNameCache[unitBluePrint] = iconName1
        end
        if self.iconTexture~=iconName1 then
            self.icon:SetTexture(iconName1)
            self.iconTexture = iconName1
        end
        self.iconSet = true
        self.tooltipSet = false
    end
end

function SpecialsButton:updateTooltip()
    if (not self.tooltipSet) and self.items:count() > 0 then
        local unitBluePrint = self.items:get(1):GetBlueprint()
        if headerTextCache[unitBluePrint] then
            self.tooltipHeader = headerTextCache[unitBluePrint]
        else
            local name
            if unitBluePrint.General and unitBluePrint.General.UnitName then
                --LOC(bp.Description)
                name = LOCF("%s: %s", unitBluePrint.General.UnitName, unitBluePrint.Description)
            else
                name = LOC(unitBluePrint.Description)
            end
            headerTextCache[unitBluePrint] = name
            self.tooltipHeader = name
        end
        self.tooltipSet = true
    end
end

function SpecialsButton:update()
    BaseButton.update(self)

    if self.items:count()<=0 then
        return
    end

    local forceUpdate = false
    if self.expandedCache ~= self.row:isExpanded() then
        forceUpdate = true
        self.expandedCache = self.row:isExpanded()
    end

    local progress = 0
    if self.row:isExpanded() then
        local item = self.items:get(1)
        local unit = item:getUnit()
        self.health:SetValue(unit:GetHealth()/unit:GetMaxHealth())
        progress = unit:GetWorkProgress()
        if item:getIsPaused() then
            self:setPaused(true)
        end
        --self.income:SetText(mex:getEtaString())
        if item:getStoredMissiles()>0 then
            self.ms:SetText(item:getStoredMissiles())
        else
            self.ms:SetText(Util.GetNilText())
        end
        if forceUpdate or self.lastGameSecond~=GetArmyManager():getGameSecondsRounded() then
            self.lastGameSecond = GetArmyManager():getGameSecondsRounded()
            self.income:SetText(item:getEtaString())
        end
        if item:getIsSelected() then
            self.marker:Show()
        end
    else
        local hp = 0
        local hpTot = 0
        local pg = 0
        local pgTot = 0
        local etaStr, item, m = Util.GetBestEtaForSpecialUnits(self.items)
        local pauseCnt = 0
        local selectCnt = 0
        local item, unit
        for i=1, self.items:count() do
            item = self.items:get(i)
            unit = item:getUnit()
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
        --self.progress:SetValue(pgTot>0 and (pg/pgTot) or 0)
        progress = pgTot>0 and (pg/pgTot) or 0
        if m>0 then
            self.ms:SetText(m)
        else
            self.ms:SetText(Util.GetNilText())
        end
        if forceUpdate or self.lastGameSecond~=GetArmyManager():getGameSecondsRounded() then
            self.lastGameSecond = GetArmyManager():getGameSecondsRounded()
            self.income:SetText(etaStr)
        end
        if self.items:get(1):getIsPaused() then
            self:setPaused(true)
        end
        if self.items:get(1):getIsSelected() then
            self.marker:Show()
        end
    end

    if progress > 0 then
        self.progress.Height:Set(3)
        self.progress:SetValue(progress)
    else
        self.progress.Height:Set(0)
    end
end