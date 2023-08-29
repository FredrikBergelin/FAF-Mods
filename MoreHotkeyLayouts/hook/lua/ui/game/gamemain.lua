local originalCreateUI = CreateUI 
local CreateBackupKeyMap = import('/mods/More Hotkey Layouts/modules/BackupKeyMap.lua').BackupKeyMap

function CreateUI(isReplay) 
	originalCreateUI(isReplay) 
	ForkThread(CreateBackupKeyMap)
end