local _CreateUI = CreateUI
local Prefs = import('/lua/user/prefs.lua')

function BackupKeyMap()
	if not GetPreference('AdvancedHotkeysUserKeyMapBackupCreated') then
		local userKeyMap = Prefs.GetFromCurrentProfile("UserKeyMap")
		local userDebugKeyMap = Prefs.GetFromCurrentProfile("UserDebugKeyMap")
		local userKeyActions = Prefs.GetFromCurrentProfile("UserKeyActions")

		SetPreference('AdvancedHotkeysUserKeyMapBackup', userKeyMap)
		SetPreference('AdvancedHotkeysUserDebugKeyMapBackup', userDebugKeyMap)
		SetPreference('AdvancedHotkeysUserKeyActionsBackup', userKeyActions)

		Prefs.SetToCurrentProfile("UserDebugKeyMap", {})

		-- Don't set all, let user create one by one
		-- local keyActions = table.combine(
		-- 	import('/lua/keymap/keyactions.lua').keyActions,
		-- 	import('/lua/keymap/debugKeyActions.lua').debugKeyActions,
		-- 	userKeyActions
		-- )
		-- local userKeyMaps = table.combine(userKeyMap, userDebugKeyMap)
		-- local keymap = {}
		-- for k, v in pairs(userKeyMaps) do
		-- 	LOG(k)
		-- 	keymap[k] = {
		-- 		{
		-- 			{
		-- 				['execute'] = keyActions[v].action,
		-- 			}
		-- 		}
		-- 	}
		-- end
		-- SetPreference('AdvancedHotkeysKeyMap', keymap)
	end
end

function CreateUI(isReplay)
	_CreateUI(isReplay)

	BackupKeyMap()

	import('/mods/AdvancedHotkeys/modules/main.lua').InitAdvancedKeys()

	import('/mods/AdvancedHotkeys/modules/main.lua').LoadKeyMap()

	SetPreference('AdvancedHotkeysUserKeyMapBackupCreated', true)
end
