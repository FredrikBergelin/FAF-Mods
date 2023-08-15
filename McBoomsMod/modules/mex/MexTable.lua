MexTable = {}

function MexTable:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self
    o.t = {}
    o.table_count = 0
    o.sort_func = false

    return o
end

function MexTable:clear()
    for i=1,self.table_count do
        self.t[i] = nil
    end
    self.table_count = 0
end

function MexTable:count()
    return self.table_count
end

function MexTable:add(_elem)
    self.table_count = self.table_count + 1
    self.t[self.table_count] = _elem
end

function MexTable:get(_index)
    return self.t[_index]
end

-- simple sorting from supplied sort function
-- sort function must return true if param A should be indexed higher than param B
function MexTable:sort()
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

function CreateMexTable()
    return MexTable:new()
end