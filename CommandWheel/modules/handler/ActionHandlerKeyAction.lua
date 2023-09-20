local KeyMapper = import('/lua/keymap/keymapper.lua')

function Handle(item)
    if not item.Action then
        return
    end

    local keyAction = KeyMapper.GetKeyActions()[item.Action]
    if not keyAction then
        print('Key Action not found: ' .. item.Action)
        return
    end

    ConExecute(keyAction.action)
end