local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	if not GetPreference('UserKeyMapBackUpCreated') then
		SetPreference("UserKeyMapBackup", Prefs.GetFromCurrentProfile("UserKeyMap"))
		SetPreference('UserKeyMapBackUpCreated', true)
	end
end