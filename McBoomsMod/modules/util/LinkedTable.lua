-- A table with linked elements
-- The index functions such as 'get' 'insertAt' may potentially be a bit slower
-- However removing entries and the iterators are fast.
-- McBoomBoom

local function create_elem(_val)
    local e = {}
    e.value = _val
    e.up = false
    e.down = false
    return e
end

local function getElem(_self, _index)
    if _self.first then
        local c = 1
        local elem = _self.first
        while true do
            if c==_index then
                return elem
            end
            elem = elem.down
            c = c+1
            if not elem then
                return
            end
        end
    end
end

local c_unpack = unpack

LinkedTable = {}

function LinkedTable:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self
    o.t = {}
    o.table_count = 0
    o.sort_func = false
    o.first = false
    o.last = false

    return o
end

function LinkedTable:clear()
    for val in self:iterator() do
        self.t[val] = nil
    end
    self.first = false
    self.last = false
    self.table_count = 0
end

function LinkedTable:contains(_value)
    return self.t[_value]~=nil
end

function LinkedTable:containsFunc(_func, ...)
    for val in self:iterator() do
        if _func(val, c_unpack(arg)) then return true end
    end
    return false;
end

function LinkedTable:getFirst()
    if self.first then return self.first.value end
end

function LinkedTable:getLast()
    if self.last then return self.last.value end
end

function LinkedTable:count()
    return self.table_count
end

function LinkedTable:add(_value)
    if _value==nil then
        error("Warning: LinkedTable values may not be nil!")
        return
    end
    if self.t[_value] then
        error("Warning: LinkedTable values must be unique!")
        self:remove(_value)
    end
    local elem = create_elem(_value)
    self.t[_value] = elem
    if self.last then
        elem.up = self.last
        self.last.down = elem
    end
    self.last = elem
    if self.table_count==0 then
        self.first = elem
    end
    --print("adding "..tostring(elem.value))
    self.table_count = self.table_count + 1
end

function LinkedTable:insertAt(_index, _value)
    if _value==nil then
        error("Warning: LinkedTable values may not be nil!")
        return
    end
    if _index<=0 or _index>self.table_count+1 then
        error("Warning: LinkedTable InsertAt index out of bounds!")
        return
    end
    if self.t[_value] then
        error("Warning: LinkedTable values must be unique!")
        self:remove(_value)
    end
    local target_elem = false
    if _index==1 then
        if self.table_count==0 then
            self:add(_value)
            return
        else
            target_elem = self.first
        end
    elseif _index==self.table_count then
        target_elem = self.last
    elseif _index==self.table_count+1 then
        self:add(_value)
        return
    else
        target_elem = getElem(self, _index)
    end

    if target_elem then
        local elem = create_elem(_value)
        self.t[_value] = elem
        if target_elem.up then
            target_elem.up.down = elem
            elem.up = target_elem.up
        end
        target_elem.up = elem
        elem.down = target_elem

        if self.first == target_elem then
            self.first = elem
        end

        self.table_count = self.table_count + 1
    else
        error("Warning: LinkedTable 'insertAt' failed to insert element!")
    end
end

function LinkedTable:remove(_value)
    if self.t[_value] then
        local elem = self.t[_value]
        self.t[_value] = nil

        if elem.up then
            elem.up.down = elem.down
        end
        if elem.down then
            elem.down.up = elem.up
        end
        if self.last and self.last==elem then
            self.last = elem.up
        end
        if self.first and self.first==elem then
            self.first = elem.down
        end

        self.table_count = self.table_count - 1
    end
end

function LinkedTable:removeAt(_index)
    if _index<=0 or _index>self.table_count then
        error("Warning: LinkedTable 'removeAt' index out of bounds!")
        return
    end

    local val = self:get(_index)
    self:remove(val)
end

function LinkedTable:get(_index)
    if _index<=0 or _index>self.table_count then
        error("Warning: LinkedTable 'get' index out of bounds!")
        return
    end
    local elem = getElem(self, _index)
    if elem then
        return elem.value
    end
end

function LinkedTable:iterator()
    local elem = self.first
    return function()
        local retval = elem
        elem = elem and elem.down
        return retval and retval.value or nil
    end
end

function LinkedTable:indexedIterator()
    local elem = self.first
    local index = 0
    return function()
        index = index + 1
        local retval = elem
        elem = elem and elem.down
        if retval and retval.value then
            return index, retval.value
        end
        return nil
    end
end

-- simple sorting from supplied sort function
-- sort function must return true if param A should be indexed higher than param B
function LinkedTable:sort(_sort_func)
    if (self.sort_func or _sort_func) and self.table_count>=2 then
        local func = _sort_func or self.sort_func
        local elem = self.first
        if elem and elem.down then
            elem = elem.down
            local next
            while elem do
                next = elem.down
                while true do
                    if elem.up and func(elem.value, elem.up.value) then
                        local replaced = elem.up
                        if self.first == replaced then self.first = elem end
                        if self.last == elem then self.last = replaced end
                        if replaced.up then replaced.up.down = elem end
                        elem.up = replaced.up
                        replaced.down = elem.down
                        if elem.down then
                            elem.down.up = replaced
                        end
                        elem.down = replaced
                        replaced.up = elem
                    else
                        break
                    end
                end
                elem = next
            end
        end
    end
end

function CreateLinkedTable()
    return LinkedTable:new()
end