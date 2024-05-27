
local modFolder = 'McBoomsMod'

local MexSort = import('/mods/' .. modFolder .. '/modules/mex/MexSort.lua')
local MexButton = import('/mods/' .. modFolder .. '/modules/ui/MexButton.lua').MexButton
local BaseRow = import('/mods/' .. modFolder .. '/modules/ui/BaseRow.lua').BaseRow


MexRow = BaseRow:inherit("MexRow")

function MexRow:new(_parent, _expanderControl, _items, _addPause)
    local o = BaseRow:new(_parent, _expanderControl, _items)
    setmetatable(o,self)
    self.__index = self

    o.upgradeRow = _addPause
    o.addPause = _addPause
    if _addPause then --todo remove this?
        o.items.sort_func = MexSort.MexSortUpgrading
    else
        o.items.sort_func = MexSort.MexSortNormal
    end

    return o
end

function MexRow:createNewButton()
    return MexButton:new(self.parent, self, self.addPause)
end

function MexRow:update()
    BaseRow.update(self)

    if self.items:count()>0 then
        --self.expanderControl:getControl():Show()
        local btn
        if self.expanderControl.isExpanded then
            for i,mex in self.items:indexedIterator() do
                btn = self:getButton(i)
                btn.items:add(mex)
                btn:Show()
                btn:update()
            end
        else
            --here we must combine mexes into a single button
            local btnIndex = 1
            local lastMex = false
            btn = self:getButton(btnIndex)
            for i,mex in self.items:indexedIterator() do
                btn.items:add(mex)
                lastMex = mex
            end
            btn:Show()
            btn:update()
        end
    else
        --self.expanderControl:getControl():Hide()
    end
end