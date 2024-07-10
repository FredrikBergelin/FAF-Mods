local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	SetPreference("AdvancedHotkeys.UserKeyMapBackup", Prefs.GetFromCurrentProfile("UserKeyMap"))

	SetPreference('AdvancedHotkeys.UserKeyMapBackupCreated', true)
end

function TransferToAdvanced()
end
