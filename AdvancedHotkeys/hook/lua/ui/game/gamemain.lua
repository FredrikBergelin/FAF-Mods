local _CreateUI = CreateUI
local CreateBackupKeyMap = import('/mods/AdvancedHotkeys/modules/BackupKeyMap.lua').BackupKeyMap
local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	if not GetPreference('AdvancedHotkeysUserKeyMapBackupCreated') then
		local UserKeyMap = Prefs.GetFromCurrentProfile("UserKeyMap")
		local UserKeyActions = Prefs.GetFromCurrentProfile("UserKeyActions")

		SetPreference('AdvancedHotkeysUserKeyMapBackup', UserKeyMap)
		SetPreference('AdvancedHotkeysUserKeyActionsBackup', UserKeyActions)

		-- local keyActions = import('/lua/keymap/keyactions.lua').keyActions
		local keyActions = table.combine(
			import('/lua/keymap/keyactions.lua').keyActions,
			UserKeyActions
		)

		local keymap = {}

		if UserKeyMap ~= nil then
			for k, v in pairs(UserKeyMap) do
				LOG(k)
				keymap[k] = {
					{
						immediate = {
							{
								['executable'] = keyActions[v].action,
							}
						},
					}
				}
			end
		else
			LOG("UserKeyMap == nil")
		end

		SetPreference('AdvancedHotkeysKeyMap', keymap)
	end
end

function CreateUI(isReplay)
	_CreateUI(isReplay)

	BackupKeyMap()

	import('/mods/AdvancedHotkeys/modules/main.lua').InitAdvancedKeys()

	import('/mods/AdvancedHotkeys/modules/main.lua').LoadKeyMap()

	SetPreference('AdvancedHotkeysUserKeyMapBackupCreated', true)
end
