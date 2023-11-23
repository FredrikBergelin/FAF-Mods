local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	if not GetPreference('KeyMapBackUpCreated') then
		SetPreference("CustomKeyMaps.KeyMap0", Prefs.GetFromCurrentProfile("UserKeyMap"))
		SetPreference('KeyMapBackUpCreated', true)
	end
end