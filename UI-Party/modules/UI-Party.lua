local settings = import('/mods/UI-Party/modules/settings.lua')
local UnitWatcher = import('/mods/UI-Party/modules/unitWatcher.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
test = {};

function Init()

	import('/mods/UI-Party/modules/linq.lua')

	InitKeys()

	UnitWatcher.Init()

	GameMain.AddBeatFunction(OnBeat)
end

local wasWatching = false
local tick = 0
function OnBeat()
	tick = tick + 1
	if tick == 10 then
		local isWatching = GetSetting("watchUnits")
		if isWatching then
			UnitWatcher.OnBeat();
		end
		if wasWatching and not isWatching then
			UnitWatcher.Shutdown();
		end
		wasWatching = isWatching

		tick = 0
	end
end


function PlayErrorSound()
    local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
    PlaySound(sound)
end

function CreateUI(isReplay)

	import('/mods/UI-Party/modules/settings.lua').init()
	import('/mods/UI-Party/modules/ui.lua').init()
	import('/mods/UI-Party/modules/econtrol.lua').setEnabled(GetSetting("showEcontrol"))

end

function InitKeys()
	local KeyMapper = import('/lua/keymap/keymapper.lua')
	local order = 1700
	local cat = "UI Party"

	-- range(2,10).foreach(function(k,v)
	-- 	order = order + 1	
	-- 	KeyMapper.SetUserKeyAction('Split selection into ' .. v .. ' groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups(" .. v .. ")", category = cat, order = order,})
	-- end)

	-- range(1,10).foreach(function(k,v)
	-- 	order = order + 1
	-- 	KeyMapper.SetUserKeyAction('Select split group ' .. v, {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(" .. v .. ")", category = cat, order = order,})
	-- end)

	-- KeyMapper.SetUserKeyAction('Select next split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Select prev split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Select next split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Select prev split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Reselect Split Units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectSplitUnits()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Reselect Ordered Split Units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectOrderedSplitUnits()", category = cat, order = order,})

	-- KeyMapper.SetUserKeyAction('Split land units by role', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextLandUnitsGroupByRole()", category = cat, order = order,})
	-- KeyMapper.SetUserKeyAction('Quick switch observer mode', {action = "UI_Lua import('/mods/UI-Party/modules/observer.lua').QuickSwitch()", category = cat, order = order,})
end

function GetSettings()
	return settings.getPreferences()
end

function GetSetting(key)
	local val = GetSettings().global[key]
	if val == nil then
		WARN("Setting not found: " .. key)
	end
	return val
end
