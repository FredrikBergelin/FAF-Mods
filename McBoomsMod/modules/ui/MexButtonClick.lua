local UIUtil = import('/lua/ui/uiutil.lua')

local modFolder = 'McBoomsMod'

local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local BaseButtonClick = import('/mods/' .. modFolder .. '/modules/ui/BaseButtonClick.lua').BaseButtonClick

local table_insert = table.insert
local table_getsize = table.getsize

MexButtonClick = BaseButtonClick:inherit("MexButtonClick")

function MexButtonClick:new()
    local o = BaseButtonClick:new()
    setmetatable(o,self)
    self.__index = self

    return o
end

function MexButtonClick:getClickOptionsText()
    local text = "Mex Button Options:\r\n\r\nSingleClick = Select/Apply To One\r\n DoubleClick = Select/Apply To Row\r\n\r\n[MouseButtons:]\r\n"
    text = text .. BaseButtonClick.getClickOptionsText(self)
    return text
end

local instance

function GetMexButtonClick()
    if not instance then
        instance = MexButtonClick:new()
    end
    return instance
end

function MexButtonOnClickFunc(_bg, _event)
    GetMexButtonClick():process(_bg.btnObject, _event)
end