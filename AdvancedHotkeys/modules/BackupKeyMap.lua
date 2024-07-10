local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	if not GetPreference('AdvancedHotkeys.UserKeyMapBackUpCreated') then
		SetPreference("AdvancedHotkeys.UserKeyMapBackup", Prefs.GetFromCurrentProfile("UserKeyMap"))
		SetPreference('AdvancedHotkeys.UserKeyMapBackUpCreated', true)
	end
end