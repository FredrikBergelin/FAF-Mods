local Chat = import('/lua/ui/game/chat.lua')

function Handle(item)
    if not item.Action then
        return
    end

    SessionSendChatMessage(Chat.FindClients(), {
        Chat = true,
        text = item.Action,
        to = item.MessageTo or 'allies'
    })
end