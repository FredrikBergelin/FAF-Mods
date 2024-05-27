local WheelPanel = import("/mods/CommandWheel/modules/WheelPanel.lua").WheelPanel
local WheelFactory = import("/mods/CommandWheel/modules/WheelFactory.lua")
local Utils = import("/mods/CommandWheel/modules/common/Utils.lua")
local WheelMiddleEmpty = import("/mods/CommandWheel/modules/middle/WheelMiddleEmpty.lua").WheelMiddleEmpty
local WheelMiddleSimple = import("/mods/CommandWheel/modules/middle/WheelMiddleSimple.lua").WheelMiddleSimple
local WheelSectorSimple = import("/mods/CommandWheel/modules/sector/WheelSectorSimple.lua").WheelSectorSimple
local ActionHandlerKeyAction = import("/mods/CommandWheel/modules/handler/ActionHandlerKeyAction.lua")
local ActionHandlerPing = import("/mods/CommandWheel/modules/handler/ActionHandlerPing.lua")
local ActionHandlerTargetPriority = import("/mods/CommandWheel/modules/handler/ActionHandlerTargetPriority.lua")
local ActionHandlerChat = import("/mods/CommandWheel/modules/handler/ActionHandlerChat.lua")
local ActionHandlerGeneric = import("/mods/CommandWheel/modules/handler/ActionHandlerGeneric.lua")

local _wheel
local _wheelWorldPos
local _init = false

function InitCommandWheel()
    if _init then
        return
    end

    WheelFactory.RegisterWheelMiddleSupplier('EMPTY', WheelMiddleEmpty)
    WheelFactory.RegisterWheelMiddleSupplier('SIMPLE', WheelMiddleSimple)

    WheelFactory.RegisterWheelSectorSupplier('SIMPLE', WheelSectorSimple)

    WheelFactory.RegisterActionHandler('PING', ActionHandlerPing)
    WheelFactory.RegisterActionHandler('KEY_ACTION', ActionHandlerKeyAction)
    WheelFactory.RegisterActionHandler('TARGET_PRIORITY', ActionHandlerTargetPriority)
    WheelFactory.RegisterActionHandler('CHAT', ActionHandlerChat)
    WheelFactory.RegisterActionHandler('GENERIC', ActionHandlerGeneric)

    WheelFactory.RegisterWheelTexturePath('DEFAULT', '/mods/CommandWheel/textures/default/')

    _init = true
end

function OpenWheel(wheelConfig)
    InitCommandWheel()
    CloseWheel()

    if not wheelConfig then
        print('Wheel configuration not found')
        return
    end

    if Utils.IsNonEmptyArray(wheelConfig.Mods) then
        for _, mod in wheelConfig.Mods do
            if not Utils.IsModInstalled(mod.Name, mod.Location, mod.Uid) then
                print('Mod not installed. Name: ' .. mod.Name or ' .. ", Location: "' .. mod.Location or '' .. ", Uid: " .. mod.Uid or '')
                return
            end
        end
    end

    _wheelWorldPos = GetMouseWorldPos()
    _wheel = WheelPanel(GetFrame(0), wheelConfig, GetMouseScreenPos())
end

function GetWheel()
    return _wheel
end

function GetWheelWorldPos()
    return _wheelWorldPos
end

function CloseWheel()
    if _wheel then
        _wheel:Close()
        _wheel = nil
    end
end