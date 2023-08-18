local a, b = pcall(function()
	local CommonUnits = import('/mods/common/units.lua')
end)
if a == false then
	LOG("Crashed. Requires another ui mod to work: Common Mod Tools v1")

	local UIUtil = import('/lua/ui/uiutil.lua')
	UIUtil.CreateText(GetFrame(0), "Crashed. Requires another ui mod to work: Common Mod Tools v1", 20, UIUtil.bodyFont)
	return 0
end

local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

UIP.Init()

local oldCreateUI = CreateUI
function CreateUI(isReplay)

	oldCreateUI(isReplay)

	UIP.CreateUI(isReplay)

	ForkThread(function()

		local tabs = import('/lua/ui/game/tabs.lua')
		local mf = import('/lua/ui/game/multifunction.lua')

		if UIP.GetSetting("moveMainMenuToRight") then
			tabs.controls.parent.Left:Set(function() return GetFrame(0).Width()-500 end)
		end

		WaitSeconds(4)

		if UIP.GetSetting("hideMenusOnStart") then
			tabs.ToggleTabDisplay(false)
			mf.ToggleMFDPanel(false)
		end

	end)
end

local oldOnFirstUpdate = OnFirstUpdate
function OnFirstUpdate()
	if UIP.GetSetting("useAlternativeStartSequence") then
		AlternateStartSequence()
	else
		if UIP.GetSetting("zoomPopOverride") then
			ForkThread(function()
				import('/lua/ui/game/zoompopper.lua').Init()
				local cam = GetCamera('WorldCamera')
				cam:Reset()
			end)
		end
		oldOnFirstUpdate()
	end
end

function AlternateStartSequence()

	import("/lua/keymap/hotbuild.lua").init()
    EnableWorldSounds()
    import("/lua/usermusic.lua").StartPeaceMusic()

    local avatars = GetArmyAvatars()
    local armiesInfo = GetArmiesTable()
    local focusArmy = armiesInfo.focusArmy
    local playerArmy = armiesInfo.armiesTable[focusArmy]

	if avatars and avatars[1]:IsInCategory("COMMAND") then
        avatars[1]:SetCustomName(playerArmy.nickname)
        PlaySound(Sound {
            Bank = 'AmbientTest',
            Cue = 'AMB_Planet_Rumble_zoom'
        })
    end

	ForkThread(function()
		-- earlier unlock input
		if not IsNISMode() then
			import('/lua/ui/game/worldview.lua').UnlockInput()
		end
		-- split screen
		if UIP.GetSetting("startSplitScreen") then
			local Borders = import('/lua/ui/game/borders.lua')
			Borders.SplitMapGroup(true, true)
			import('/lua/ui/game/worldview.lua').Expand() -- required to initialize something else there is a crash
		end
		-- required else just zoom into middle all the time
		if UIP.GetSetting("zoomPopOverride") then
			WaitSeconds(0)
			import('/lua/ui/game/zoompopper.lua').Init()
		end
		-- 1nd cam zoom out
		local cam1 = GetCamera("WorldCamera")
		cam1:SetZoom(cam1:GetMaxZoom(),0)
		cam1:RevertRotation() -- UIZoomTo does something funny
		-- 2nd cam zoom out
		if UIP.GetSetting("startSplitScreen") then
			local cam2 = GetCamera("WorldCamera2")
			cam2:SetZoom(cam2:GetMaxZoom(),0)
			cam2:RevertRotation() -- UIZoomTo does something funny
		end
		-- need to wait before ui can hide, so slip in artistic camera transition
		WaitSeconds(1)
		if not GetReplayState() then
			-- left cam glides towards acu
			UIZoomTo(avatars, 1.2)

			WaitSeconds(1)
			cam1:SetZoom(import('/lua/ui/game/zoompopper.lua').GetPopLevel(),0.1) -- different zoom level to usual, not as close
			WaitSeconds(0)
			cam1:RevertRotation() -- UIZoomTo does something funny
		end
		-- select acu & start placing fac
		WaitSeconds(0)
		AddSelectUnits(avatars)
		import('/lua/keymap/hotbuild.lua').buildAction('Builders')
	end)

    FlushEvents()
    if not IsNISMode() then
        import("/lua/ui/game/worldview.lua").UnlockInput()
    end

    if not import("/lua/ui/campaign/campaignmanager.lua").campaignMode then
        import("/lua/ui/game/score.lua").CreateScoreUI()
    end

    if Prefs.GetOption('skin_change_on_start') ~= 'no' then
        if focusArmy >= 1 then
            local factionSkin = import("/lua/factions.lua").Factions[playerArmy.faction + 1].DefaultSkin
            if factionSkin then
                UIUtil.SetCurrentSkin(factionSkin)
                return
            end
        end
    end
    UIUtil.UpdateCurrentSkin()




	-- normal stuff
	import('/lua/keymap/hotbuild.lua').init()
	EnableWorldSounds()
	local avatars = GetArmyAvatars()
	if avatars and avatars[1]:IsInCategory("COMMAND") then
		local armiesInfo = GetArmiesTable()
		local focusArmy = armiesInfo.focusArmy
		local playerName = armiesInfo.armiesTable[focusArmy].nickname
		avatars[1]:SetCustomName(playerName)
	end
	import('/lua/UserMusic.lua').StartPeaceMusic()
	if not import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
		import('/lua/ui/game/score.lua').CreateScoreUI()
	end

	PlaySound( Sound { Bank='AmbientTest', Cue='AMB_Planet_Rumble_zoom'} )

	-- normal stuff
	if Prefs.GetOption('skin_change_on_start') ~= 'no' then
		local focusarmy = GetFocusArmy()
		local armyInfo = GetArmiesTable()
		if focusArmy >= 1 then
			local factionSkin = import("/lua/factions.lua").Factions[playerArmy.faction + 1].DefaultSkin
			if factionSkin then
				UIUtil.SetCurrentSkin(factionSkin)
				return
			end
		end
	end

end

-- local oldOnQueueChanged = OnQueueChanged
-- function OnQueueChanged(newQueue)
--     oldOnQueueChanged(newQueue)
-- end
