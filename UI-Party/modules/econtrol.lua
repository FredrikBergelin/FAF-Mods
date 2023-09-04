local CommonUnits = import('/mods/common/units.lua')
local UnitHelper = import('/mods/ui-party/modules/unitHelper.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group
local Text = import('/lua/maui/text.lua').Text
local UIUtil = import('/lua/ui/uiutil.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local spendTypes = {
	PROD = "PROD",
	MAINT = "MAINT"
}

local workerTypes = {
	WORKING = "WORKING",
	PAUSED = "PAUSED"
}

local resourceTypes = from({
	{ name = "Mass",   econDataKey = "massConsumed" },
	{ name = "Energy", econDataKey = "energyConsumed" },
})

local unitTypes;

function GetUnitType(unit)
	local unitType = unitTypes.first(function(k, unitType)
		return EntityCategoryContains(unitType.category, unit)
	end)

	if (unitType == nil) then
		unitType = unitTypes.last()
	end

	return unitType
end

function OnUnitBoxClick(self, event, unitBox)
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Ctrl then
			if event.Modifiers.Right then
				EnablePaused(unitBox)
			else
				SelectPaused(unitBox)
			end
		else
			if event.Modifiers.Right then
				DisableWorkers(unitBox)
			else
				SelectWorkers(unitBox)
			end
		end
	end
end

function GetWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = nil
	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.prodUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.maintUnits
	end
	return ValidateUnitsList(workers)
end

function DisableWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	if table.getn(workers) == 0 then

	else
		if unitBox.spendType == spendTypes.PROD then
			for k, v in unitType.prodUnits do
				table.insert(unitType.pausedProdUnits, v)
			end
			SetPaused(workers, true)
		elseif unitBox.spendType == spendTypes.MAINT then
			local totalMaintMass = 0
			for k, v in pairs(workers) do
				local econData = GetEconData(v)
				if econData["massConsumed"] > 0 then
					table.insert(unitType.pausedProdUnits, v)
					SetPaused(workers, true)
				end
			end

			for k, v in unitType.maintUnits do
				table.insert(unitType.pausedMaintUnits, v)
			end

			DisableUnitsAbility(workers)
		end
	end
end

function SelectWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	SelectUnits(workers)
end

function GetPaused(unitBox)
	local unitType = unitBox.unitType
	local workers = nil

	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.pausedProdUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.pausedMaintUnits
	end

	local stillPaused = {}
	for k, v in ValidateUnitsList(workers) do
		if GetIsPausedBySpendType({ v }, unitBox.spendType) then
			table.insert(stillPaused, v)
		end
	end
	-- could check still working on same project here
	return stillPaused
end

function GetIsPausedBySpendType(units, spendType)
	if spendType == spendTypes.PROD then
		return GetIsPaused(units)
	elseif spendType == spendTypes.MAINT then
		return GetIsUnitAbilityEnabled(units)
	end
end

function EnablePaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	if unitBox.spendType == spendTypes.PROD then
		SetPaused(pauseUnits, false)
		unitType.pausedProdUnits = {}
	elseif unitBox.spendType == spendTypes.MAINT then
		EnableUnitsAbility(pauseUnits)
		unitType.pausedMaintUnits = {}
	end
	-- unitBox.SetOn(false)
end

function SelectPaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	SelectUnits(pauseUnits)
end

--unitToggleRules = {
--    Shield =  0,
--    Weapon = 1, --?
--    Jamming = 2,
--    Intel = 3,
--    Production = 4, --?
--    Stealth = 5,
--    Generic = 6,
--    Special = 7,
--	  Cloak = 8,}

function GetOnValueForScriptBit(i)
	if i == 0 then return false end -- shield is weird and reversed... you need to set it to false to get it to turn off - unlike everything else
	return true
end

function DisableUnitsAbility(units)
	for i = 0, 8 do
		ToggleScriptBit(units, i, not GetOnValueForScriptBit(i))
	end
end

function EnableUnitsAbility(units)
	for i = 0, 8 do
		ToggleScriptBit(units, i, GetOnValueForScriptBit(i))
	end
end

function GetIsUnitAbilityEnabled(units)
	for i = 0, 8 do
		if GetScriptBit(units, i) == GetOnValueForScriptBit(i) then
			return true
		end
	end
	return false
end

local hoverUnitType = nil
local selectedUnitType = nil

function OnClick(self, event, unitType)
	if event.Type == 'MouseExit' then
		if hoverUnitType ~= nil then
			hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
		end
		hoverUnitType = nil
	end
	if event.Type == 'MouseEnter' then
		hoverUnitType = unitType
	end
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Ctrl then
			if event.Modifiers.Right then
				if unitType.typeUi.prodUnitsBox ~= nil then EnablePaused(unitType.typeUi.prodUnitsBox) end
				if unitType.typeUi.maintUnitsBox ~= nil then EnablePaused(unitType.typeUi.maintUnitsBox) end
			else
				local pausedUnits = {}
				if unitType.typeUi.prodUnitsBox ~= nil then
					pausedUnits = from(pausedUnits).concat(from(GetPaused(unitType.typeUi.prodUnitsBox))).toArray()
				end

				if unitType.typeUi.maintUnitsBox ~= nil then
					pausedUnits = from(pausedUnits).concat(from(GetPaused(unitType.typeUi.maintUnitsBox))).toArray()
				end

				SelectUnits(pausedUnits)
			end
		else
			if event.Modifiers.Right then
				if unitType.typeUi.prodUnitsBox ~= nil then DisableWorkers(unitType.typeUi.prodUnitsBox) end
				if unitType.typeUi.maintUnitsBox ~= nil then DisableWorkers(unitType.typeUi.maintUnitsBox) end
			else
				-- if selectedUnitType ~= nil then
				-- 	selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
				-- end

				local allUnits = from(unitType.prodUnits).concat(from(unitType.maintUnits)).toArray()
				SelectUnits(allUnits)
			end
		end
	end

	-- if hoverUnitType ~= nil then
	-- 	hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('11ffffff')
	-- end
	-- if selectedUnitType ~= nil then
	-- 	selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('33ffffff')
	-- end

	return true
end

function GetEconData(unit)
	local mi = unit:GetMissileInfo()
	if (mi.nukeSiloBuildCount > 0 or mi.tacticalSiloBuildCount > 0) then
		-- special favour to silo stuff
		return unit:GetEconData()
	end

	if Sync.FixedEcoData ~= nil then
		local data = FixedEcoData[unit:GetEntityId()]
		return data;
	else
		-- legacy broken way, works in ui mod
		return unit:GetEconData()
	end
end

outerPadding = 3
barWidth = 100
barSeparationY = 1
iconSize = 25

rootWidth = barWidth * 2 + (outerPadding * 4) + iconSize
iconLeftIn = barWidth + (outerPadding * 2)
typeHeight = iconSize + (outerPadding * 2)
leftBarsRight = outerPadding + barWidth
rightBarsLeftIn = barWidth + (outerPadding * 2) + iconSize + outerPadding
barHeight = (iconSize / 2) - barSeparationY
topBarTopIn = outerPadding
bottomBarTopIn = outerPadding + barHeight + (barSeparationY * 2)

function DoUpdate()
	if UIP.GetSetting("showEcontrolResources") then
		UpdateResourcesUi();
	end
end

function UpdateResourcesUi()
	local units = from(CommonUnits.Get())

	unitTypes.foreach(function(k, unitType)
		unitType.prodUnits = {}
		unitType.maintUnits = {}
	end)

	-- set unittype resource usages to 0
	resourceTypes.foreach(function(k, rType)
		rType.usage = 0
		rType.maintUsage = 0
		unitTypes.foreach(function(k, unitType)
			local unitTypeUsage = unitType.usage[rType.name]
			unitTypeUsage.usage = 0
			unitTypeUsage.maintUsage = 0
		end)
	end)

	-- fill unittype resources with real data
	units.foreach(function(k, unit)
		local econData = GetEconData(unit)
		local unitToGetDataFrom = nil
		local isMaint = false

		if (econData == nil) then
			return;
		end

		if unit:GetFocus() then
			unitToGetDataFrom = unit:GetFocus()
			isMaint = false
		else
			unitToGetDataFrom = unit
			isMaint = true
		end

		local unitType = GetUnitType(unitToGetDataFrom)

		local unitHasUsage = false
		resourceTypes.foreach(function(k, rType)
			local usage = econData[rType.econDataKey]

			if (usage > 0) then
				local unitTypeUsage = unitType.usage[rType.name]
				if (isMaint) then
					rType.maintUsage = rType.maintUsage + usage
					unitTypeUsage.maintUsage = unitTypeUsage.maintUsage + usage
				else
					rType.usage = rType.usage + usage
					unitTypeUsage.usage = unitTypeUsage.usage + usage
				end
				unitHasUsage = true
			end
		end)

		if unitHasUsage then
			if (isMaint) then
				-- LOG("isMaint")
				table.insert(unitType.maintUnits, unit)
			else
				-- LOG("prodUnits")
				table.insert(unitType.prodUnits, unit)
			end
		end

		if unitHasUsage then
			if (isMaint) then
				if unit:IsInCategory 'COMMAND' then
					LOG("COMMAND")
					table.insert(unitType.prodUnits, unit)
				else
					table.insert(unitType.maintUnits, unit)
				end
			else
				table.insert(unitType.prodUnits, unit)
			end
		end
	end)

	-- update ui
	local relayoutRequired = false
	unitTypes.foreach(function(k, unitType)
		resourceTypes.foreach(function(k, rType)
			local unitTypeUsage = unitType.usage[rType.name]
			local rTypeUsageTotal = rType.usage + rType.maintUsage

			if rTypeUsageTotal == 0 then
				unitTypeUsage.bar.Width:Set(0)
				unitTypeUsage.maintBar.Width:Set(0)
			else
				local bv = unitTypeUsage.usage
				local bmv = unitTypeUsage.maintUsage
				local percentify = true
				if (percentify) then
					bv = bv / rTypeUsageTotal * barWidth
					bmv = bmv / rTypeUsageTotal * barWidth
				end

				bv = math.ceil(bv)
				bmv = math.ceil(bmv)

				if (bv > 0 and bv < 1) then bv = 1 end
				if (bmv > 0 and bmv < 1) then bmv = 1 end

				local shouldShow = bv + bmv > 0
				if (shouldShow and unitType.typeUi.uiRoot:IsHidden()) then
					unitType.typeUi.uiRoot:Show()
					unitType.typeUi.Clear()
					relayoutRequired = true
				end

				local top = unitType.typeUi.uiRoot:Top()
				local left = unitType.typeUi.uiRoot:Left()
				unitTypeUsage.bar.Width:Set(bv)
				unitTypeUsage.maintBar.Width:Set(bmv)
				if rType.name == "MASS" then
					unitTypeUsage.maintBar.Top:Set(top + outerPadding)
				elseif rType.name == "ENERGY" then
					unitTypeUsage.maintBar.Top:Set(top + outerPadding + barHeight + barSeparationY)
				end

				unitTypeUsage.maintBar.Right:Set(left + leftBarsRight)
			end
		end)
	end)

	if relayoutRequired then
		local y = 0
		unitTypes.foreach(function(k, unitType)
			if not unitType.typeUi.uiRoot:IsHidden() then
				unitType.typeUi.uiRoot:Top(y)
				LayoutHelpers.AtTopIn(unitType.typeUi.uiRoot, UIP.econtrol.ui, y)
				y = y + unitType.typeUi.uiRoot:Height()
			end
		end)
		UIP.econtrol.ui.Height:Set(y)
	end
end

function GetUpgradingUnits(category)
	local units = from(category.units).where(function(k, u) return u:GetWorkProgress() < 1 and u:GetWorkProgress() > 0 end)
		.toArray()
	local sorted = dosort(units, function(u) return u:GetWorkProgress() end)
	return sorted
end

function dosort(t, func)
	local keys = {}
	for k, v in t do keys[table.getn(keys) + 1] = k end
	table.sort(keys, function(a, b) return func(t[a]) > func(t[b]) end)
	local sorted = {}
	local i = 1
	while keys[i] do
		sorted[i] = t[keys[i]]
		i = i + 1
	end
	return sorted;
end

function IsMexCategoryMatch(mexCategory, unit)
	if unit.isUpgradee then
		return false
	end

	if not EntityCategoryContains(mexCategory.categories, unit) then
		return false
	end

	if unit.isUpgrader ~= mexCategory.isUpgrading then
		return false
	end

	if mexCategory.isPaused ~= nil then
		if GetIsPaused({ unit }) ~= mexCategory.isPaused then
			return false
		end
	end

	return true
end

local hoverMexCategoryType
function OnMexCategoryUiClick(self, event, category)
	if event.Type == 'MouseExit' then
		if hoverMexCategoryType ~= nil then
			hoverMexCategoryType.ui:InternalSetSolidColor('aa000000')
		end
		hoverMexCategoryType = nil
	end
	if event.Type == 'MouseEnter' then
		hoverMexCategoryType = category
	end
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Right then
			if category.isPaused ~= nil then
				if event.Modifiers.Ctrl then
					local sorted = GetUpgradingUnits(category)
					local best = sorted[1]

					if category.isPaused then
						-- unpause the best
						SetPaused({ best }, false)
					else
						-- pause all except the best
						local worst = sorted[table.getn(sorted)]
						SetPaused({ worst }, true)
					end
				else
					SetPaused(category.units, not category.isPaused)
				end
			end
		else
			if event.Modifiers.Ctrl then
				local sorted = GetUpgradingUnits(category)
				local best = sorted[1]
				SelectUnits({ best })
			else
				SelectUnits(category.units)
			end
		end
	end

	if hoverMexCategoryType ~= nil then
		hoverMexCategoryType.ui:InternalSetSolidColor('11ffffff')
	end

	return true
end

function UnitBox(typeUi, unitType, spendType, workerType)
	local group = Group(typeUi.uiRoot);
	group.Width:Set(20)
	group.Height:Set(22)

	local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
	local button = Bitmap(group, buttonBackgroundName)
	button.Width:Set(20)
	button.Height:Set(22)
	LayoutHelpers.AtLeftIn(button, group, 0)
	LayoutHelpers.AtVerticalCenterIn(button, group, 0)

	-- local check2 = Bitmap(group)
	-- check2.Width:Set(12)
	-- check2.Height:Set(12)
	-- check2:InternalSetSolidColor('bbff0000')
	-- LayoutHelpers.AtLeftIn(check2, group, 4)
	-- LayoutHelpers.AtVerticalCenterIn(check2, group, 0)

	-- local check = Bitmap(group, '/textures/ui/uef/game/temp_textures/checkmark.dds')
	-- check.Width:Set(8)
	-- check.Height:Set(8)
	-- LayoutHelpers.AtLeftIn(check, group, 6)
	-- LayoutHelpers.AtVerticalCenterIn(check, group, 0)

	local unitBox = {
		group = group,
		button = button,
		-- check = check,
		unitType = unitType,
		spendType = spendType,
		workerType = workerType,
	};

	unitBox.SetOn = function(val)
		if val then
			-- check:Show()
		else
			-- check:Hide()
		end
	end

	unitBox.SetAltOn = function(val)
		if val then
			-- check2:Show()
		else
			-- check2:Hide()
		end
	end

	-- unitBox.SetOn(false);
	-- unitBox.SetAltOn(false);
	group.HandleEvent = function(self, event)
		OnUnitBoxClick(self, event, unitBox)
		return true;
	end

	return unitBox
end

function SpendingBar(typeUi, unitType, spendType, workerType)
	local group = Group(typeUi.uiRoot);
	group.Width:Set(20)
	group.Height:Set(22)

	local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
	local button = Bitmap(group, buttonBackgroundName)
	button.Width:Set(20)
	button.Height:Set(22)
	LayoutHelpers.AtLeftIn(button, group, 0)
	LayoutHelpers.AtVerticalCenterIn(button, group, 0)

	-- local check2 = Bitmap(group)
	-- check2.Width:Set(12)
	-- check2.Height:Set(12)
	-- check2:InternalSetSolidColor('bbff0000')
	-- LayoutHelpers.AtLeftIn(check2, group, 4)
	-- LayoutHelpers.AtVerticalCenterIn(check2, group, 0)

	-- local check = Bitmap(group, '/textures/ui/uef/game/temp_textures/checkmark.dds')
	-- check.Width:Set(8)
	-- check.Height:Set(8)
	-- LayoutHelpers.AtLeftIn(check, group, 6)
	-- LayoutHelpers.AtVerticalCenterIn(check, group, 0)

	local unitBox = {
		group = group,
		button = button,
		-- check = check,
		unitType = unitType,
		spendType = spendType,
		workerType = workerType,
	};

	unitBox.SetOn = function(val)
		if val then
			-- check:Show()
		else
			-- check:Hide()
		end
	end

	unitBox.SetAltOn = function(val)
		if val then
			-- check2:Show()
		else
			-- check2:Hide()
		end
	end

	-- unitBox.SetOn(false);
	-- unitBox.SetAltOn(false);
	group.HandleEvent = function(self, event)
		OnUnitBoxClick(self, event, unitBox)
		return true;
	end

	return unitBox
end

function buildUi()
	local a, b = pcall(function()
		UIP.econtrol = {}
		unitTypes = from({
			{
				name = "Land Units",
				category = categories.LAND * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.LAND * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.LAND * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER,
				icon = "icon_land_category",
				spacer = 0
			},
			-- { name = "T1 Land Units", category = categories.LAND * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land1_generic_rest", spacer = 0 },
			-- { name = "T2 Land Units", category = categories.LAND * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land2_generic_rest", spacer = 0 },
			-- { name = "T3 Land Units", category = categories.LAND * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land3_generic_rest", spacer = 0 },

			{
				name = "Air Units",
				category = categories.AIR * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.AIR * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.AIR * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER,
				icon = "icon_air_category",
				spacer = 0
			},
			-- { name = "T1 Air Units", category = categories.AIR * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter1_generic_rest", spacer = 0 },
			-- { name = "T2 Air Units", category = categories.AIR * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter2_generic_rest", spacer = 0 },
			-- { name = "T3 Air Units", category = categories.AIR * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter3_generic_rest", spacer = 0 },

			{
				name = "Naval Units",
				category = categories.NAVAL * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.NAVAL * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER +
					categories.NAVAL * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER,
				icon =
				"icon_navy_category",
				spacer = 0
			},
			-- { name = "T1 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship1_generic_rest", spacer = 0 },
			-- { name = "T2 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship2_generic_rest", spacer = 0 },
			-- { name = "T3 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship3_generic_rest", spacer = 0 },

			{
				name = "Shields",
				category = categories.STRUCTURE * categories.SHIELD,
				icon =
				"icon_shield_category",
				spacer = 0
			},
			{
				name = "Intel",
				category = categories.STRUCTURE * categories.RADAR +
					categories.STRUCTURE * categories.OMNI + categories.STRUCTURE * categories.SONAR + categories
					.MOBILESONAR,
				icon =
				"icon_intel_category",
				spacer = 0
			},
			-- { name = "Sonar", category = categories.STRUCTURE * categories.SONAR + categories.MOBILESONAR, icon = "icon_structure_intel", spacer = 0  },
			{
				name = "Stealth",
				category = categories.STRUCTURE * categories.COUNTERINTELLIGENCE,
				icon =
				"icon_counterintel_category",
				spacer = 0
			},
			{
				name = "Energy production",
				category = categories.STRUCTURE * categories.ENERGYPRODUCTION,
				icon =
				"icon_energy_category",
				spacer = 0
			},
			{
				name = "Energy storage",
				category = categories.STRUCTURE * categories.ENERGYSTORAGE,
				icon =
				"icon_energy_storage_category",
				spacer = 0
			},
			{
				name = "Mass extraction",
				category = categories.MASSEXTRACTION + categories.MASSSTORAGE +
					categories.STRUCTURE * categories.MASSFABRICATION,
				icon =
				"icon_mass_category",
				spacer = 0
			},
			{
				name = "Silos",
				category = categories.SILO,
				icon =
				"icon_nuke_category",
				spacer = 0
			},
			{
				name = "Factories",
				category = categories.STRUCTURE * categories.FACTORY - categories.GATE,
				icon =
				"icon_factory_category",
				spacer = 0
			},
			{
				name = "Military",
				category = categories.STRUCTURE * categories.DEFENSE +
					categories.STRUCTURE * categories.STRATEGIC,
				icon =
				"icon_defense_category",
				spacer = 0
			},
			{
				name = "Experimentals",
				category = categories.EXPERIMENTAL,
				icon =
				"icon_experimental_category",
				spacer = 0
			},
			{
				name = "ACU",
				category = categories.COMMAND,
				icon =
				"icon_commander_category",
				spacer = 0
			},
			{
				name = "SACU",
				category = categories.SUBCOMMANDER,
				icon =
				"icon_commander_category",
				spacer = 0
			},
			{
				name = "Engineers",
				category = categories.ENGINEER,
				icon =
				"icon_engineer_category",
				spacer = 0
			},
			{
				name = "Everything",
				category = categories.ALLUNITS,
				icon =
				"strat_attack_ping_rest",
				spacer = 0
			},
		})

		unitTypes.foreach(function(k, unitType)
			unitType.usage = {}
			unitType.pausedProdUnits = {}
			unitType.pausedMaintUnits = {}
		end)

		local dragger = import('/mods/UI-Party/modules/ui.lua').buttons.dragButton
		local uiRoot = Bitmap(dragger)
		UIP.econtrol.ui = uiRoot
		uiRoot.Width:Set(42)
		uiRoot.Width:Set(0)
		uiRoot.Height:Set(100)
		uiRoot.Depth:Set(99)
		uiRoot:DisableHitTest()
		LayoutHelpers.AtLeftIn(uiRoot, dragger, 0)
		LayoutHelpers.AtTopIn(uiRoot, dragger, 45)

		function CreateText(text, x)
			local t = UIUtil.CreateText(uiRoot, text, 9, UIUtil.bodyFont)
			t.Width:Set(5)
			t.Height:Set(5)
			t:SetNewColor('ffaaaaaa')
			t:DisableHitTest()
			LayoutHelpers.AtLeftIn(t, uiRoot, x)
			LayoutHelpers.AtTopIn(t, uiRoot, -12)
		end

		-- CreateText("B", col0 + 5)
		-- CreateText("U", col1 + 5)
		-- CreateText("Resources", col3)


		-- Loop
		unitTypes.foreach(function(k, unitType)
			local typeUi = {}
			unitType.typeUi = typeUi

			typeUi.uiRoot = Bitmap(uiRoot)

			-- TODO: Move
			-- typeUi.uiRoot.HandleEvent = function(self, event) return OnClick(self, event, unitType) end

			typeUi.uiRoot.Width:Set(rootWidth)
			typeUi.uiRoot.Height:Set(typeHeight)
			typeUi.uiRoot:InternalSetSolidColor('aa000000')
			typeUi.uiRoot:Hide()
			LayoutHelpers.AtLeftIn(typeUi.uiRoot, uiRoot, 0)
			LayoutHelpers.AtTopIn(typeUi.uiRoot, uiRoot, 0)

			typeUi.stratIcon = Bitmap(typeUi.uiRoot)
			local iconName = '/mods/UI-Party/textures/category_icons/' .. unitType.icon .. '.dds'
			typeUi.stratIcon:SetTexture(iconName)
			typeUi.stratIcon.Height:Set(iconSize) -- typeUi.stratIcon.BitmapHeight
			typeUi.stratIcon.Width:Set(iconSize)
			LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, iconLeftIn)
			LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)

			-- typeUi.prodUnitsBox = UnitBox(typeUi, unitType, spendTypes.PROD, workerTypes.WORKING)
			-- LayoutHelpers.AtLeftIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, col0)
			-- LayoutHelpers.AtVerticalCenterIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, 0)

			-- typeUi.maintUnitsBox = UnitBox(typeUi, unitType, spendTypes.MAINT, workerTypes.WORKING)
			-- LayoutHelpers.AtLeftIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, col1)
			-- LayoutHelpers.AtVerticalCenterIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, 0)

			typeUi.Clear = function()
				-- typeUi.prodUnitsBox.check:Hide()
				-- typeUi.maintUnitsBox.check:Hide()
			end

			typeUi.energyBar = Bitmap(typeUi.uiRoot)
			typeUi.energyBar.Width:Set(10)
			typeUi.energyBar.Height:Set(barHeight)
			typeUi.energyBar:InternalSetSolidColor('orange')
			typeUi.energyBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyBar, typeUi.uiRoot, rightBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.energyBar, typeUi.uiRoot, topBarTopIn)

			typeUi.massBar = Bitmap(typeUi.uiRoot)
			typeUi.massBar.Width:Set(10)
			typeUi.massBar.Height:Set(barHeight)
			typeUi.massBar:InternalSetSolidColor('lime')
			typeUi.massBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massBar, typeUi.uiRoot, rightBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.massBar, typeUi.uiRoot, bottomBarTopIn)

			typeUi.energyMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.energyMaintBar.Width:Set(10)
			typeUi.energyMaintBar.Height:Set(barHeight)
			typeUi.energyMaintBar:InternalSetSolidColor('orange')
			typeUi.energyMaintBar:DisableHitTest()
			LayoutHelpers.AtRightIn(typeUi.energyMaintBar, typeUi.stratIcon, 0)
			LayoutHelpers.AtTopIn(typeUi.energyMaintBar, typeUi.uiRoot, topBarTopIn)

			typeUi.massMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.massMaintBar.Width:Set(10)
			typeUi.massMaintBar.Height:Set(barHeight)
			typeUi.massMaintBar:InternalSetSolidColor('lime')
			typeUi.massMaintBar:DisableHitTest()
			LayoutHelpers.AtRightIn(typeUi.massMaintBar, typeUi.stratIcon, 0)
			LayoutHelpers.AtTopIn(typeUi.massMaintBar, typeUi.uiRoot, bottomBarTopIn)

			unitType.usage["Mass"] = {
				bar = typeUi.massBar,
				maintBar = typeUi.massMaintBar,
				text = typeUi.massText,
				maintText = typeUi.massMaintText,
			}

			unitType.usage["Energy"] = {
				bar = typeUi.energyBar,
				maintBar = typeUi.energyMaintBar,
				text = typeUi.energyText,
				maintText = typeUi.energyMaintText,
			}

			typeUi.massBar:Hide()
			typeUi.massMaintBar:Hide()
			typeUi.energyBar:Hide()
			typeUi.energyMaintBar:Hide()
		end)

		UIP.econtrol.beat = DoUpdate
		GameMain.AddBeatFunction(UIP.econtrol.beat)

		DoUpdate()
	end)

	if not a then
		WARN("UI PARTY RESULT: ", a, b)
	end
end

function setEnabled(value)
	-- tear down old ui
	if rawget(UIP, "econtrol") ~= nil then
		if UIP.econtrol.ui then UIP.econtrol.ui:Destroy() end
		if UIP.econtrol.beat then GameMain.RemoveBeatFunction(UIP.econtrol.beat) end
		UIP.econtrol = nil
	end

	-- build new ui
	if value then
		buildUi()
	end
end
