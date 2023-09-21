local ContextMenu = import('/mods/StrategicRings/modules/ContextMenu.lua').ContextMenu
local ButtonPanel = import('/mods/StrategicRings/modules/ButtonPanel.lua').ButtonPanel
local Config = import('/mods/StrategicRings/modules/Config.lua')
local Actions = import('/mods/StrategicRings/modules/Actions.lua')
local StrategicRings = import('/mods/StrategicRings/modules/StrategicRings.lua')
local ActionHandlerRing = import('/mods/StrategicRings/modules/ActionHandlerRing.lua')

local _commandWheelInit = false

function InitCommandWheel()
    if _commandWheelInit then
        return
    end

    import("/mods/CommandWheel/modules/WheelFactory.lua").RegisterActionHandler('RING', ActionHandlerRing)
    _commandWheelInit = true
end

function OpenMenu(menuName)
    SelectUnits(nil)
    StrategicRings.CloseContextMenu()

    if Config.Menus[menuName] then
        CreateContextMenu(Config.Menus[menuName])
    else
        print('Menu [' .. menuName .. '] not found')
    end
end

function OpenWheel(wheelName)
    -- TODO: It opens now but stops working after adding a few rings??

    -- if not StrategicRings.IsCommandWheelAvailable() then
    --     print('\'Command Wheel\' mod not installed')
    --     return
    -- end

    InitCommandWheel()
    import("/mods/CommandWheel/modules/CommandWheel.lua").OpenWheel(Config.Wheels[wheelName])
end

function HoverRing()
    Actions.HoverRing();
end

function DeleteLast()
    Actions.DeleteLastAction();
end

function DeleteClosest()
    Actions.DeleteClosestAction();
end

function DeleteScreen()
    Actions.DeleteScreenAction();
end

function CreateContextMenu(menuConfig)
    local mousePosition = GetMouseScreenPos()
    local buttonPanel = ButtonPanel(GetFrame(0), menuConfig)

    buttonPanel.OnClick = OnMenuButtonClick
    local contextMenu = ContextMenu(GetFrame(0), buttonPanel, mousePosition)
    StrategicRings.SetContextMenu(contextMenu)
end

function OnMenuButtonClick(_, item)
    StrategicRings.CloseContextMenu()
    Actions.CreateRing(item)
end