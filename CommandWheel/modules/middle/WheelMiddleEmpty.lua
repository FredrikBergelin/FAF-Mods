local WheelMiddle = import("/mods/CommandWheel/modules/middle/WheelMiddle.lua").WheelMiddle

WheelMiddleEmpty = Class(WheelMiddle) {
    __init = function(self, parent, config, data)
        WheelMiddle.__init(self, parent, config, data)
    end,

    OnAction = function(self)
    end,
}