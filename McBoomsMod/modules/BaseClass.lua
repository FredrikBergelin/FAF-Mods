BaseClass = {}
BaseClass.ClassType = "BaseClass"

function BaseClass:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self

    return o
end

function BaseClass:init()

end

function BaseClass:inherit(_type)
    local o = {}
    setmetatable(o, self)
    self.__index = self
	o.ClassType = _type;
    return o
end