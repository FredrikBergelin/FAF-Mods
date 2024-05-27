local UIUtil = import('/lua/ui/uiutil.lua')

local _WHEEL_MIDDLE_SUPPLIERS = {}
local _WHEEL_SECTOR_SUPPLIERS = {}
local _WHEEL_ACTION_HANDLERS = {}
local _WHEEL_TEXTURE_PATHS = {}

function RegisterWheelMiddleSupplier(type, fn)
    _WHEEL_MIDDLE_SUPPLIERS[type] = fn
end

function RegisterWheelSectorSupplier(type, fn)
    _WHEEL_SECTOR_SUPPLIERS[type] = fn
end

function RegisterWheelTexturePath(type, path)
    _WHEEL_TEXTURE_PATHS[type] = path
end

function RegisterActionHandler(type, handler)
    _WHEEL_ACTION_HANDLERS[type] = handler
end

function createWheelMiddle(parent, config, data)
    return _WHEEL_MIDDLE_SUPPLIERS[config.Type](parent, config, data)
end

function createWheelSector(parent, config, data)
    return _WHEEL_SECTOR_SUPPLIERS[config.Type](parent, config, data)
end

function getWheelSectorTexture(type, count, num)
    return UIUtil.UIFile(_WHEEL_TEXTURE_PATHS[type] .. 'wheel_' .. count .. '_part_' .. num .. '.dds')
end

function getWheelMiddleTexture(type)
    return UIUtil.UIFile(_WHEEL_TEXTURE_PATHS[type] .. 'wheel_middle.dds')
end

function getActionHandler(type)
    return _WHEEL_ACTION_HANDLERS[type]
end
