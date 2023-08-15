chatColors = {'ffffffff', 'ffff4242', 'ffefff42','ff4fff42', 'ff42fff8', 'ff424fff', 'ffff42eb', 'ffff9f42', 'FFFFD700', 'FF87CEEB'}

local virtualCreateChatLines = CreateChatLines
function CreateChatLines()
	virtualCreateChatLines()
	for i, line in GUI.chatLines do
		line.name:SetDropShadow(true)
        line.text:SetDropShadow(true)
	end
end