OLDReceiveChatFromSim = ReceiveChatFromSim

function ReceiveChatFromSim(sender, msg)
	if(msg.to == GetArmyData(GetFocusArmy()).nickname) then
	    -- this is a direct message to the user.  by default, it's muted
    else if(sender ~= GetArmyData(GetFocusArmy()).nickname) then 
		-- the send of the message is not the user of the mod.  by default, the message is muted
	else
		-- otherwise, the chat message is displayed as normal
		OLDReceiveChatFromSim(sender, msg)
	end
end

-- this lua file affects CHAT but not PINGS

-- this mod will silence all chat messages except from the user of the mod.  You can continue to chat and you can see your own chat messages.
-- but you won't see chat messages from other people
-- you could edit the if-then logic to do things like: only hide chat messages from people who are blacklisted; or only show chat messages from people who are whitelisted