-- simple indexed table without remove functionality

IndexedTable = {}

function IndexedTable:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self
    o.t = {}
    o.table_count = 0
    o.sort_func = false

    return o
end

function IndexedTable:clear()
    for i=1,self.table_count do
        self.t[i] = nil
    end
    self.table_count = 0
end

function IndexedTable:count()
    return self.table_count
end

function IndexedTable:add(_elem)
    self.table_count = self.table_count + 1
    self.t[self.table_count] = _elem
end

function IndexedTable:get(_index)
    return self.t[_index]
end

function IndexedTable:iterator()
    local index = 0
    return function()
        index = index + 1
        return self.t[index]
    end
end

function IndexedTable:indexedIterator()
    local index = 0
    return function()
        index = index + 1
        local retval = self.t[index]
        if retval then
            return index, retval
        end
        return nil
    end
end

-- simple sorting from supplied sort function
-- sort function must return true if param A should be indexed higher than param B
function IndexedTable:sort()
    if self.sort_func and self.table_count>=2 then
        for i=2,self.table_count do
            local elem = self.t[i]
            local targ = i-1
            while targ>0 do
                if self.sort_func(elem, self.t[targ]) then
                    self.t[targ+1] = self.t[targ]
                    self.t[targ] = elem
                    targ = targ - 1
                else
                    break
                end
            end
        end
    end
end

function CreateIndexedTable()
    return IndexedTable:new()
end