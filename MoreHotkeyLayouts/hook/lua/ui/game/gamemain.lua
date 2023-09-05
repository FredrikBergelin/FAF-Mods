local originalCreateUI = CreateUI 
local CreateBackupKeyMap = import('/mods/MoreHotkeyLayouts/modules/BackupKeyMap.lua').BackupKeyMap

function CreateUI(isReplay) 
	originalCreateUI(isReplay) 
	ForkThread(CreateBackupKeyMap)
end