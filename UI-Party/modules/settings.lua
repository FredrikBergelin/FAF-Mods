local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Prefs = import('/lua/user/prefs.lua')
local savedPrefs = Prefs.GetFromCurrentProfile("Party-UI Settings")
local settingDescriptions
local UIUtil = import('/lua/ui/uiutil.lua')
local SettingsUi = import('/mods/UI-Party/modules/settingsUi.lua')

function getSettingDescriptions()
	return settingDescriptions
end

function init()
	-- settings
	if not savedPrefs then
		savedPrefs = {}
	end

	settingDescriptions = {

		{ name = "Start Sequence", settings = {
			{ key="useAlternativeStartSequence", type="bool", default=true, name="Use Alternative Start Sequence", description="Different zoom in.\r\nAcu is selected earlier.\r\nFirst fac placement started." },
			{ indent = 1, key="startSplitScreen", type="bool", default=true, name="Start Split Screen", description="The game starts in split screen mode.\r\nLeft screen zooms in.\r\nRight screen zooms out.\r\nUser can control acu earlier.\r\nAcu is automatically set in place-land-factory mode.\r\nRequires alternative start sequence." },
		}},

		{ name = "Zoom Pop", settings = {
			{ key="zoomPopOverride", type="bool", default=true, name="Fix Zoom Pop Accuracy", description="Reimplements zoom pop to be more accurate. To see the problem with old zoom pop, zoom out, hover a fac near a mex then pop in ... you will be at some random place nearby. In the new implementation the hovering fac is pretty much in the same place as before you popped." },
			{ key="zoomPopSpeed", type="number", default=0.08, name="Zoom Pop Speed", description="Speed up/slow down the pop animation. (Zero = disabled).", min=0, max=10, valMult=0.01  },
		}},

		{ name = "UI", settings = {
			{ key="showEcontrol", type="bool", default=true, name="Show ECOntrol (slow?)", description="Show a user interface with a summary of your economy" },
			{ indent = 1, key="showEcontrolResources", type="bool", default=true, name="Show resource summary", description="Shows what you are spending your mass/energy on" },
			{ key="rearrangeBottomPanes", type="bool", default=true, name="Move bottom panes", description="Reorders the selected-unit-info pane and the orders pane to take up less vertical space. (For wide monitors)" },
			{ key="hideMenusOnStart", type="bool", default=true, name="Hide misc menus", description="On startup, collapse the multifunction (pings) and tabs (main menu)" },
		}},

		{ name = "Analysis", settings = {
			{ key="watchUnits", type="bool", default=true, name="Watch units (slow?)", description="Mod analyzes units" },
			{ indent = 1, key="showAdornments", type="bool", default=true, name="Show Adornments (slow?)", description="Display symbols if unit is being assisted, is locked, is repeating. Requires Watch units" },
			{ indent = 1, key="alertUpgradeFinished", type="bool", default=true, name="Alert when upgrade structure/acu finished", description="Beeps and messages you whenever a structure (eg: mex/factory/radar) or acu has finished upgrading. Requires Watch units. Acu upgrades also requires Notify mod" },
			{ indent = 1, key="setGroundFireOnAttack", type="bool", default=true, name="Start in ground fire mode", description="Sets it so all units are ground firing. This is because normal fire mode is useless and ground fire does the same except allows you to fire at ground as well." },
			{ indent = 1, key="factoriesStartWithRepeatOn", type="bool", default=false, name="Factories repeat always", description="Factories will repeat unless you assist another factory or manually turn it off (and even then it will be turned back on if you stop your factory).\r\n\r\nFactories start in repeat mode. Repeat mode is also turned on whenever the Stop command is issued. Repeat is turned OFF automatically when they assist another factory.\r\n\r\nThese changes include more exotic factories like Quantum Gateways and experimentals that can produce units like the Fatboy. Warning: Rebind your repeat key first ... otherwise you will be turning your facs OFF repeat out of habit" },
			{ indent = 1, key="factoriesRepeatOnStop", type="bool", default=false, name="Factories set to repeat after being stopped", description="Factories will repeat unless you assist another factory or manually turn it off (and even then it will be turned back on if you stop your factory).\r\n\r\nFactories start in repeat mode. Repeat mode is also turned on whenever the Stop command is issued. Repeat is turned OFF automatically when they assist another factory.\r\n\r\nThese changes include more exotic factories like Quantum Gateways and experimentals that can produce units like the Fatboy. Warning: Rebind your repeat key first ... otherwise you will be turning your facs OFF repeat out of habit" },
			{ indent = 1, key="alertIdleFac", type="bool", default=true, name="Highglight idle factory in avatars", description="Beeps and show big red marker on the avatars pane, whenever there is an idle fac" },
		}},

		{ name = "Split Screen", settings = {
			{ key="smallerContructionTabWhenSplitScreen", type="bool", default=true, name="Construction to left", description="Construction menu just spans left screen (not both)" },
			{ key="moveAvatarsToLeftSplitScreen", type="bool", default=true, name="Avatars to left", description="Move the avatars (idle engies pane) to the left screen." },
			{ key="moveMainMenuToRight", type="bool", default=true, name="Main menu to right", description="Move the tabs (main menu) to the right screen." },
		}},

		{ name = "Hidden", settings = {
			{ key="xOffset", default=345 },
			{ key="yOffset", default=50 },
		}},
	}

	local tooltips = import('/lua/ui/help/tooltips.lua').Tooltips

	if not savedPrefs.global then
		savedPrefs.global = {}
	end

	local keys = from({})
	from(settingDescriptions).foreach(function(gk, kv)
		from(kv.settings).foreach(function(sk, sv)

			-- make defaults
			keys.addValue(sv.key)
			if savedPrefs.global[sv.key] == nil then
				savedPrefs.global[sv.key] = sv.default
			end

			-- add tooltips
			tooltips["UIP_"..sv.key] = {
				title = sv.name,
				description = sv.description,
				keyID = "UIP_"..sv.key,
			}
		end)
	end)

	-- clear old stuff
	local g = from(savedPrefs.global)
	g.foreach(function(gk, gv)
		if not keys.contains(gk) then
			g.removeKey(gk)
		end
	end)

	-- correct x/y if outside the window
	if (savedPrefs.global.xOffset < 0 or savedPrefs.global.xOffset > GetFrame(0).Width()) then
		savedPrefs.global.xOffset = GetFrame(0).Width()/2
	end
	if (savedPrefs.global.yOffset < 0 or savedPrefs.global.yOffset > GetFrame(0).Height()) then
		savedPrefs.global.yOffset = GetFrame(0).Height()/2
	end

	savePreferences()
end

function savePreferences()
	Prefs.SetToCurrentProfile("Party-UI Settings", savedPrefs)
	Prefs.SavePreferences()
end

function getPreferences()
	return savedPrefs
end

function setAllGlobalValues(t)
	for id, value in t do
		savedPrefs.global[id] = value
	end
	savePreferences()
	import('/mods/UI-Party/modules/econtrol.lua').setEnabled(savedPrefs.global.showEcontrol)
end

function setXYvalues(posX, posY)
	savedPrefs.global.xOffset = posX
	savedPrefs.global.yOffset = posY
	savePreferences()
end

