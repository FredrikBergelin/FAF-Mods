local originalCreateUI = CreateUI
local CreateBackupKeyMap = import('/mods/AdvancedHotkeys/modules/BackupKeyMap.lua').BackupKeyMap

function CreateUI(isReplay)
	originalCreateUI(isReplay)
	ForkThread(CreateBackupKeyMap)
	import('/mods/AdvancedHotkeys/modules/main.lua').Init()
end
