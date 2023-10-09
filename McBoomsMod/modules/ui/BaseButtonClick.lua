local UIUtil = import('/lua/ui/uiutil.lua')

local modFolder = 'McBoomsMod'

local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local BaseClass = import('/mods/' .. modFolder .. '/modules/BaseClass.lua').BaseClass

local table_insert = table.insert
local table_getsize = table.getsize

BaseButtonClick = BaseClass:inherit("BaseButtonClick")

function BaseButtonClick:new()
    local o = BaseClass:new()
    setmetatable(o,self)
    self.__index = self

    return o
end

function BaseButtonClick:selectionContainsEngineers(_units)
    if not _units then return false end
    for _,unit in _units do
        if EntityCategoryContains(categories.ENGINEER, unit) then
            return true
        end
    end
end

function BaseButtonClick:selectionGetEngineers(_units)
    local list = {}
    if _units then
        for _,unit in _units do
            if EntityCategoryContains(categories.ENGINEER, unit) then
                table_insert(list, unit)
            end
        end
    end
    return list
end

function BaseButtonClick:getButtonNextUnit()
    local index = self.obj:getNextItemIndex()
    if index>=1 and index<=self.obj.items:count() then
        return { self.obj.items:get(index):getUnit() }
    else
        return {}
    end
end

function BaseButtonClick:getSingleUnit()
    if self.obj.items:count()<1 then
        return {}
    end
    return { self.obj.items:get(1):getUnit() }
end

function BaseButtonClick:getAllUnits()
    local units = {}
    for mex in self.obj.row.items:iterator() do
        table_insert(units, mex:getUnit())
    end
    return units
end

function BaseButtonClick:getAllUnitsToRight()
    local clickedUnit = self.obj.items:get(1):getUnit()
    local selectUnit = false
    local units = {}
    for mex in self.obj.row.items:iterator() do
        local currentUnit = mex:getUnit()
        if selectUnit == false and clickedUnit == currentUnit then
            selectUnit = true
        end
        if selectUnit then
            table_insert(units, mex:getUnit())
        end
    end
    return units
end

function BaseButtonClick:getAllUnitsToLeft()
    local clickedUnit = self.obj.items:get(1):getUnit()
    local selectUnit = true
    local units = {}
    for mex in self.obj.row.items:iterator() do
        local currentUnit = mex:getUnit()
        if selectUnit == true and clickedUnit == currentUnit then
            selectUnit = false
            table_insert(units, mex:getUnit())
        end
        if selectUnit then
            table_insert(units, mex:getUnit())
        end
    end
    return units
end

function BaseButtonClick:pauseOrUpgrade()
    if self.obj.isUpgrading then
        self:pauseUnits()
    else
        self:upgradeUnits()
    end
end

function BaseButtonClick:pauseUnits()
    local isPaused = GetIsPaused(self:getSingleUnit())
    if self.singleUnit then
        SetPaused(self:getSingleUnit(), not isPaused)
    else
        local units
        if isPaused then
            units = self:getAllUnitsToLeft()
        else
            units = self:getAllUnitsToRight()
        end
        SetPaused(units, not isPaused)
    end
end

function BaseButtonClick:upgradeUnits()
    if self.singleUnit then
        Util.SelectAndUpgradeUnits(self:getSingleUnit())
    else
        Util.SelectAndUpgradeUnits(self:getAllUnitsToLeft())
    end
end

function BaseButtonClick:selectUnits()
    local units = {}

    if self.obj.row:isExpanded() then
        units = self.singleUnit and self:getSingleUnit() or self:getAllUnits()
    else
        units = self.singleUnit and self:getButtonNextUnit() or self:getAllUnits()
    end

    local selectUnits = units

    --if shift add units to current selection
    if self.event.Modifiers.Shift then
        selectUnits = GetSelectedUnits() or {}
        for _,u in units do
            table_insert(selectUnits, u)
        end
    end
    SelectUnits(selectUnits)
end

function BaseButtonClick:zoomToUnit()
    if self.singleUnit then
        if self.obj.row:isExpanded() then
            UISelectAndZoomTo(self:getSingleUnit()[1])
        else
            UISelectAndZoomTo(self:getButtonNextUnit()[1])
        end
    end
end

function BaseButtonClick:engineersAssistUnit()
    local append = self.event.Modifiers.Shift

    if self.hasEngineers then
        local engies = self:selectionGetEngineers(self.units)
        local units = {}
        if self.singleUnit then
            if self.obj.row:isExpanded() then
                units = self:getSingleUnit()
            else
                units = self:getButtonNextUnit()
            end
        else
            units = self:getAllUnits()
        end

        if table_getsize(units)<=0 or table_getsize(engies)<=0 then
            return
        end

        for i,eng in engies do
            local commands = {}

            if append then
                local q = eng:GetCommandQueue() or {}
                if q then
                    for k,v in q do
                        if v and v.type and (v.position or v.entityid) then
                            table_insert(commands, {
                                CommandType = v.type,
                                Position = v.position,
                                EntityId = v.entityid,
                            })
                        end
                    end
                end
            end

            for _,unit in units do
                SimCallback({
                    Func = 'RingWithStorages',
                    Args = {
                        target = unit:GetEntityId()
                    }
                }, true)
            end
        end
    end
end

function BaseButtonClick:processMouseMoveEvents(_event)
    if _event.Type == 'MouseEnter' then
        self.obj.icon:SetAlpha(0.6)
        if self.cursor then
            GetCursor():SetTexture(UIUtil.GetCursor(self.cursor))
        end
    elseif _event.Type == 'MouseExit' then
        self.obj.icon:SetAlpha(0.3)
        GetCursor():Reset()
    end
end

BaseButtonClick.ClickOptions = {
    { Func = "pauseOrUpgrade", Click = "Left", Ctrl = false, Alt = false, Shift = false, Text= "Pause/Upgrade" },
    { Func = "selectUnits", Click = "Left", Ctrl = true, Alt = false, Shift = false, Text = "Select" },
    { Func = "selectUnits", Click = "Left", Ctrl = true, Alt = false, Shift = true, Text = "Append Select" },
    { Func = "engineersAssistUnit", Click = "Right", Ctrl = false, Alt = false, Shift = false, Text = "Units Assist" },
    { Func = "engineersAssistUnit", Click = "Right", Ctrl = false, Alt = false, Shift = true, Text = "Units Append Assist" },
    { Func = "zoomToUnit", Click = "Right", Ctrl = true, Alt = false, Shift = false, Text = "Zoom To Unit" }
}

function BaseButtonClick:getClickOptionsText()
    local text = ""
    for index,option in self.ClickOptions do
        if option.Alt then
            text = text .. "ALT+"
        elseif option.Ctrl then
            text = text .. "CTRL+"
        elseif option.Shift then
            text = text .. "SHIFT+"
        end
        text = text .. option.Click .. " = " .. option.Text
        if index<table_getsize(self.ClickOptions) then
            text = text .. "\r\n"
        end
    end
    return text
end

function BaseButtonClick:processClickEvents(_event)
    for _,option in self.ClickOptions do
        if _event.Modifiers[option.Click] then
            if option.Ctrl == (_event.Modifiers.Ctrl or false) and option.Alt == (_event.Modifiers.Alt or false) and option.Shift == (_event.Modifiers.Shift or false) then
                --print("Click event = "..tostring(option.Text))
                if option.Func == "zoomToUnit" then
                    local unitsInSelection = GetSelectedUnits()
                    self[option.Func](self)
                    -- restore selection
                    if unitsInSelection and table.getn(unitsInSelection) > 0 then
                        SelectUnits(unitsInSelection)
                    end
                else
                    self[option.Func](self)
                end
                return true
            end
        end
    end
end

function BaseButtonClick:process(_obj, _event)
    self.obj = _obj
    self.event = _event
    self.units = GetSelectedUnits()
    self.hasEngineers = self:selectionContainsEngineers(self.units)
    self.cursor = false
    self.singleUnit = _event.Type == 'ButtonPress'

    if _event.Type == 'ButtonPress' or _event.Type == 'ButtonDClick' then
        if self:processClickEvents(_event) then
            return true;
        end
    end

    return self:processMouseMoveEvents(_event)
end

local instance

function GetBaseButtonClick()
    if not instance then
        instance = BaseButtonClick:new()
    end
    return instance
end

function BaseButtonOnClickFunc(_bg, _event)
    GetBaseButtonClick():process(_bg.btnObject, _event)
end