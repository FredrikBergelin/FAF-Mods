local originalCreateUI = CreateUI 
local reminders = import('/mods/CustomReminders/modules/reminders.lua').main

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  if not isReplay then
	ForkThread(reminders)
  end
end
