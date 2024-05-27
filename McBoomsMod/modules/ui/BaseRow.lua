local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local modFolder = 'McBoomsMod'

local BaseClass = import('/mods/' .. modFolder .. '/modules/BaseClass.lua').BaseClass

local table_insert = table.insert
local table_getsize = table.getsize

BaseRow = BaseClass:inherit("BaseRow")

function BaseRow:new(_parent, _expanderControl, _items)
    local o = BaseClass:new()
    setmetatable(o,self)
    self.__index = self

    o.parent = _parent
	o.expanderControl = _expanderControl
    o.expanderControl.rowControl = o
    o.controls = {}
    o.items = _items --CreateMexTable()
    o.expandedCache = _expanderControl:getExpanded()
    o.resetIconsOnClear = false

    return o
end

function BaseRow:init()

end

function BaseRow:clear()
    local resetIcons = true --false
    --if self:isExpanded() ~= self.expandedCache then
    --    resetIcons = true
    --    self.expandedCache = self:isExpanded()
    --end
    for i=1, table_getsize(self.controls) do
        self.controls[i]:clear()
        self.controls[i]:Hide()
        if self.resetIconsOnClear and resetIcons then
            self.controls[i].iconSet = false
        end
    end
end

function BaseRow:update()
    self:clear()
end

function BaseRow:isExpanded()
    return self.expanderControl.isExpanded
end

function BaseRow:Hide()
    for index,btn in ipairs(self.controls) do
        btn:Hide()
    end
end

function BaseRow:Show()
    for index,btn in ipairs(self.controls) do
        btn:Show()
    end
end

function BaseRow:createNewButton()
    error("BaseRow.createNewButton not implemented.")
end

-- this function gets a button at the specified index or creates a new one when it doesnt exist
function BaseRow:getButton(_index)
    if self.controls[_index] then
        return self.controls[_index]
    else
        if _index==table_getsize(self.controls)+1 then
            table_insert(self.controls, self:createNewButton())
            if _index==1 then
                LayoutHelpers.CenteredRightOf(self.controls[_index]:getControl(), self.expanderControl:getControl(), 0)
            else
                LayoutHelpers.RightOf(self.controls[_index]:getControl(), self.controls[_index-1]:getControl(), 0)
            end
            return self.controls[_index]
        else
            --the index is larger than next slot
            print("SpecialsRow:getButton is adding multiple new slots")
            for i=1,_index do
                if not self.controls[i] then
                    table_insert(self.controls, self:createNewButton())
                    if i==1 then
                        LayoutHelpers.CenteredRightOf(self.controls[i]:getControl(), self.expanderControl:getControl(), 0)
                    else
                        LayoutHelpers.RightOf(self.controls[i]:getControl(), self.controls[i-1]:getControl(), 0)
                    end
                end
            end
            return self.controls[_index]
        end
    end
end