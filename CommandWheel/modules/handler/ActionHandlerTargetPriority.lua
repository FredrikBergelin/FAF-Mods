local MiscKeyActions = import("/lua/keymap/misckeyactions.lua")

function Handle(item)
    if not item.Action then
        return
    end

    local prioritySettings = import('/lua/ui/game/orders.lua').GetPrioritySettings()
    if not prioritySettings or type(prioritySettings) ~= 'table' then
        print('Target priority not found')
        return
    end

    local priority = item.Action;
    MiscKeyActions.SetWeaponPriorities(prioritySettings.priorityTables[priority], priority, prioritySettings.exclusive[priority])
    MiscKeyActions.RecheckTargetsOfWeapons()
end