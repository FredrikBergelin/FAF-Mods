
local modFolder = 'McBoomsMod'

local SpecialsButton = import('/mods/' .. modFolder .. '/modules/ui/SpecialsButton.lua').SpecialsButton
local BaseRow = import('/mods/' .. modFolder .. '/modules/ui/BaseRow.lua').BaseRow

local table_insert = table.insert

SpecialsRow = BaseRow:inherit("SpecialsRow")

function SpecialsRow:new(_parent, _expanderControl, _items, _experimentalRow)
    local o = BaseRow:new(_parent, _expanderControl, _items)
    setmetatable(o,self)
    self.__index = self

    o.experimentalRow = _experimentalRow
    o.addPause = false
    o.resetIconsOnClear = true

    o.typeCache = {}

    return o
end

function SpecialsRow:createNewButton()
    return SpecialsButton:new(self.parent, self, self.experimentalRow)
end

function SpecialsRow:update()
    BaseRow.update(self)

    local count = 0
    for _, list in self.items do
        if list:count()>0 then
            --self.expanderControl:getControl():Show()
            local btn
            if self.expanderControl.isExpanded then
                local c = 0
                for i,unitObj in list:indexedIterator() do
                    count = count + 1
                    btn = self:getButton(count)
                    btn.items:add( unitObj )
                    btn:Show()
                    btn:update()
                end
            else
                --here we must combine units into a single button
                for k,v in self.typeCache do
                    self.typeCache[k] = nil
                end
                local btnIndex = 1
                --btn = self:getButton(btnIndex)
                --self.typeCache[list:get(1):getName()] = btn
                for i,unitObj  in list:indexedIterator() do
                    if self.typeCache[unitObj:getName()] then
                        btn = self.typeCache[unitObj:getName()]
                    else
                        count = count + 1
                        btn = self:getButton(count)
                        self.typeCache[unitObj:getName()] = btn
                    end
                    btn.items:add(unitObj)
                    --btn:Show()
                    --btn:update()
                end
                for k,v in self.typeCache do
                    self.typeCache[k]:Show()
                    self.typeCache[k]:update()
                end
            end
        else
            --self.expanderControl:getControl():Hide()
        end
    end
end