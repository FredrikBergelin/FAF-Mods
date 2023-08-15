local Actions = import('/mods/StrategicRings/modules/Actions.lua')

function Handle(item)
    local actions = Actions.GetActions()

    if item.Action and actions[item.Action] then
        actions[item.Action]()
        return
    elseif item.Action then
        print('Action \'' .. item.Action .. '\' not supported')
        return
    end

    Actions.CreateRing(item)
end