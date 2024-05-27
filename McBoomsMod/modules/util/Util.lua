local GetSelectedUnits = GetSelectedUnits

local IssueUpgradeOrders = import('/lua/ui/game/construction.lua').IssueUpgradeOrders
local Selection = import("/lua/ui/game/selection.lua")
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local modFolder = 'McBoomsMod'

local Select = import('/mods/' .. modFolder .. '/modules/util/Selection.lua')

local nil_text = ""
local table_insert = table.insert
local table_remove = table.remove
local table_getsize = table.getsize

local unitsToUpgrade = false
local function SelectAndUpgradeUnitsCB(_units)
    SelectUnits(_units)

    local unit = _units[1]
    if unit and unit:GetBlueprint() and unit:GetBlueprint().General and unit:GetBlueprint().General.UpgradesTo then
        local bp = unit:GetBlueprint().General.UpgradesTo
        IssueUpgradeOrders(_units, bp)
    end
end

function SelectAndUpgradeUnits(_units)
    if _units and _units[1] then
        --unitsToUpgrade = _units
        Select.Hidden(SelectAndUpgradeUnitsCB, _units)
    end
end

function GetNilText()
    return nil_text
end

function GetBestEtaForSpecialUnits(_items)
    if _items and _items:count() > 0 then
        local bestEta = 1000000
        local etaStr = nil_text
        local bestItem = false
        local m = 0

        for i=1, _items:count() do
            local item = _items:get(i)

            m = m + item:getStoredMissiles()
            if item:isHasEta() and item:getEtaSeconds()<bestEta then --item:isHasEta()
                bestEta = item:getEtaSeconds()
                etaStr = item:getEtaString()
                bestItem = item
            end
        end
        return etaStr, bestItem, m
    end
    return false, false, 0
end

Colors ={
    White = 'ffffffff',
    Yellow = 'FFFFD700',
    Red = 'FFFA8072',
    Blue = 'FF6495ED',
	Black = 'FF000000',
	DarkRed = 'FF8B0000',
    Green = 'FF9ACD32',
    LightGreen = 'FFADFF2F',
}

-- basic click function handler that requires 'onClickCustom' to be set on the button
function ClickFunc(self, event)
    if self.onClickCustom then
        return self.onClickCustom(event)
    else
        print("click not handled")
    end
    --if event.Type == 'MouseEnter' then
    --elseif event.Type == 'MouseExit' then
    --elseif event.Type == 'ButtonPress' then
    --    return true
    --elseif event.Type == 'ButtonDClick' then
    --    return true
    --end
end

function PrintTable(_t, _name, _offset)
    print(_offset.."["..tostring(_name).."]")
    _offset = _offset.." "
    for k,v in _t do
        if type(v)=="table" then
            PrintTable(v, k, _offset)
        else
            print(_offset..tostring(k).." = "..tostring(v))
        end
    end
end

function IsSelected(_unit)
    local units = GetSelectedUnits()
    if units then
        for k,v in units do
            if v==_unit then
                return true
            end
        end
    end
    return false
end

function RemoveFromGroups()
    local units = GetSelectedUnits()
    if units then
        for _, unit in units do
            for _, group in unit:GetSelectionSets() do
                local groupTable = Selection.selectionSets[group]
                for index=table_getsize(groupTable), 1, -1 do
                    if unit:GetEntityId()==groupTable[index]:GetEntityId() then
                        table_remove(groupTable, index)
                    end
                end
                unit:RemoveSelectionSet(group)
            end
        end
    end
end

function CreateTextBG(_parent, _control, _color)
	local background = Bitmap(_control)
	background:SetSolidColor(_color)
	background.Top:Set(_control.Top)
	background.Left:Set(_control.Left)
	background.Right:Set(_control.Right)
	background.Bottom:Set(_control.Bottom)
	background.Depth:Set(function() return _parent.Depth() + 1 end)
end
