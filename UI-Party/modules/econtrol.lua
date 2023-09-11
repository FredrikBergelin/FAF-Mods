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
	PRODUCTION = "PRODUCTION",
	UPKEEP = "UPKEEP"
}

local workerTypes = {
	WORKING = "WORKING",
	PAUSED = "PAUSED"
}

local resourceTypes = from({
	{ name = "Mass",   econDataKey = "massConsumed" },
	{ name = "Energy", econDataKey = "energyConsumed" },
})

local unitTypes

function GetUnitType(unit)
	local unitType = unitTypes.first(function(k, unitType)
		return EntityCategoryContains(unitType.category, unit)
	end)

	if (unitType == nil) then
		unitType = unitTypes.last()
	end

	return unitType
end


function GetWorkers(unitType, spendType)
	local unitType = unitType
	local workers = nil
	if spendType == spendTypes.PRODUCTION then
		workers = unitType.productionUnits
	elseif spendType == spendTypes.UPKEEP then
		workers = unitType.upkeepUnits
	end
	return ValidateUnitsList(workers)
end

function DisableWorkers(unitType, spendType)
	local unitType = unitType
	local workers = GetWorkers(unitType, spendType)
	if table.getn(workers) == 0 then

	else
		if spendType == spendTypes.PRODUCTION then
			for k, v in unitType.productionUnits do
				table.insert(unitType.pausedProductionUnits, v)
			end
			SetPaused(workers, true)
		elseif spendType == spendTypes.UPKEEP then
			local totalUpkeepMass = 0
			for k, v in pairs(workers) do
				local econData = GetEconData(v)
				if econData["massConsumed"] > 0 then
					table.insert(unitType.pausedProductionUnits, v)
					SetPaused(workers, true)
				end
			end

			for k, v in unitType.upkeepUnits do
				table.insert(unitType.pausedUpkeepUnits, v)
			end

			DisableUnitsAbility(workers)
		end
	end
end

function SelectWorkers(unitType, spendType)
	local unitType = unitType
	local workers = GetWorkers(unitType, spendType)
end

function GetPaused(unitType, spendType)
	local unitType = unitType
	local workers = nil

	if spendType == spendTypes.PRODUCTION then
		workers = unitType.pausedProductionUnits
	elseif spendType == spendTypes.UPKEEP then
		workers = unitType.pausedUpkeepUnits
	end

	local stillPaused = {}
	for k, v in ValidateUnitsList(workers) do
		if GetIsPausedBySpendType({ v }, spendType) then
			table.insert(stillPaused, v)
		end
	end
	-- could check still working on same project here
	return stillPaused
end

function GetIsPausedBySpendType(units, spendType)
	if spendType == spendTypes.PRODUCTION then
		return GetIsPaused(units)
	elseif spendType == spendTypes.UPKEEP then
		return GetIsUnitAbilityEnabled(units)
	end
end

function EnablePaused(unitType, spendType)
	local pauseUnits = GetPaused(unitType, spendType)
	local unitType = unitType
	if spendType == spendTypes.PRODUCTION then
		SetPaused(pauseUnits, false)
		unitType.pausedProductionUnits = {}
	elseif spendType == spendTypes.UPKEEP then
		EnableUnitsAbility(pauseUnits)
		unitType.pausedUpkeepUnits = {}
	end
	-- unitBox.SetOn(false)
end

function SelectPaused(unitType)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitType
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


local energyPercent = 0

function UpdateEconTotals()
	local econTotals = GetEconomyTotals()

	local globalEnergyMax = econTotals["maxStorage"]["ENERGY"]
	local globalEnergyCurrent = econTotals["stored"]["ENERGY"]

	energyPercent = 100 * (globalEnergyCurrent / globalEnergyMax)
	return energyPercent
end

function ActivateAutoPause(totalSel)
	-- local totalSel = GetSelectedUnits()
	totalSel = ValidateUnitsList(totalSel)
	if totalSel then
		for i, unit in totalSel do
			local currUnit = unit

			-- Update thread, per unit.
			if (currUnit:GetWorkProgress() > 0) and (currUnit.AutoUpdateThread == nil) then
				-- Set label in name
				unit.originalName = unit:GetCustomName(unit)
				local newName = "[AUTOPAUSE]"
				if unit.originalName then
					newName = unit.originalName .. " " .. newName
				end
				unit:SetCustomName(newName)

				currUnit.AutoUpdateThread = ForkThread(function()
					local prevProgress = 0
					while not currUnit:IsDead() do
						-- If we're done, return to original name and end.
						if currUnit:GetWorkProgress() < prevProgress then
							EndAutoPause(currUnit)
							KillThread(CurrentThread())
						end

						prevProgress = currUnit:GetWorkProgress()

						-- Otherwise check and pause
						UpdateEconTotals()
						if not GetIsPaused({ currUnit }) and (energyPercent < 70) then
							SetPaused({ currUnit }, true)
						elseif GetIsPaused({ currUnit }) and (energyPercent > 90) then
							SetPaused({ currUnit }, false)
						end
						WaitSeconds(0.5)
					end
					currUnit.AutoUpdateThread = nil
				end)
			end
			-- End update thread.
		end
	end
end

function EndAutoPause(currUnit)
	SetPaused({ currUnit }, false)

	if currUnit.originalName then
		currUnit:SetCustomName(currUnit.originalName)
		currUnit.originalName = nil
	else
		currUnit:SetCustomName("")
	end
	currUnit.AutoUpdateThread = nil
end

local hoverUnitType = nil
local selectedUnitType = nil

function RootEvents(self, event, unitType)
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
				if unitType.typeUi.productionUnitsBox ~= nil then EnablePaused(unitType) end
				if unitType.typeUi.upkeepUnitsBox ~= nil then EnablePaused(unitType.typeUi.upkeepUnitsBox) end
			else
				local pausedUnits = {}
				if unitType.typeUi.productionUnitsBox ~= nil then
					pausedUnits = from(pausedUnits).concat(from(GetPaused(unitType.typeUi.productionUnitsBox))).toArray()
				end

				if unitType.typeUi.upkeepUnitsBox ~= nil then
					pausedUnits = from(pausedUnits).concat(from(GetPaused(unitType.typeUi.upkeepUnitsBox))).toArray()
				end

				SelectUnits(pausedUnits)
			end
		else
			if event.Modifiers.Right then
				if unitType.typeUi.productionUnitsBox ~= nil then DisableWorkers(unitType.typeUi.productionUnitsBox) end
				if unitType.typeUi.upkeepUnitsBox ~= nil then DisableWorkers(unitType.typeUi.upkeepUnitsBox) end
			else
				-- if selectedUnitType ~= nil then
				-- 	selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
				-- end

				local allUnits = from(unitType.productionUnits).concat(from(unitType.upkeepUnits)).toArray()
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

function IconEvents(self, event, unitType)
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Ctrl and event.Modifiers.Alt then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		elseif event.Modifiers.Ctrl then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		elseif event.Modifiers.Alt then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		else
			if event.Modifiers.Left then
				local allUnits = from(unitType.productionUnits).concat(from(unitType.upkeepUnits)).toArray()
				SelectUnits(allUnits)
			elseif event.Modifiers.Right then
				local allUnits = from(unitType.productionUnits).concat(from(unitType.upkeepUnits)).toArray()
				ActivateAutoPause(allUnits)
			end
		end
	end
	return true

	-- EnablePaused(unitBox)
	-- SelectPaused(unitBox)
	-- DisableWorkers(unitBox)
	-- SelectWorkers(unitBox)

end

function UsageContainerEvents(self, event, unitType)
	if event.Type == 'ButtonPress' then
		if event.Modifiers.Ctrl and event.Modifiers.Alt then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		elseif event.Modifiers.Ctrl then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		elseif event.Modifiers.Alt then
			if event.Modifiers.Left then
			elseif event.Modifiers.Right then
			end
		else
			if event.Modifiers.Left then
				LOG("Select all units")
				local allUnits = from(unitType.productionUnits).concat(from(unitType.upkeepUnits)).toArray()
				SelectUnits(allUnits)
			elseif event.Modifiers.Right then
			end
		end
	end

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
		return data
	else
		-- legacy broken way, works in ui mod
		return unit:GetEconData()
	end
end

outerPadding = 3
usageContainerWidth = 100
barSeparationY = 1
iconSize = 25

rootWidth = usageContainerWidth * 2 + (outerPadding * 4) + iconSize
iconLeftIn = usageContainerWidth + (outerPadding * 2)
typeHeight = iconSize + (outerPadding * 2)
leftBarsRight = outerPadding + usageContainerWidth
leftBarsLeftIn = outerPadding
rightBarsLeftIn = usageContainerWidth + (outerPadding * 2) + iconSize + outerPadding
usageContainerHeight = (iconSize / 2) - barSeparationY
topBarTopIn = outerPadding
bottomBarTopIn = outerPadding + usageContainerHeight + (barSeparationY * 2)

function DoUpdate()
	if UIP.GetSetting("showEcontrolResources") then
		UpdateResourcesUi()
	end
end

function UpdateResourcesUi()
	local units = from(CommonUnits.Get())

	unitTypes.foreach(function(k, unitType)
		unitType.productionUnits = {}
		unitType.upkeepUnits = {}
	end)

	-- set unittype resource usages to 0
	resourceTypes.foreach(function(k, resourceType)
		resourceType.productionUsage = 0
		resourceType.upkeepUsage = 0
		unitTypes.foreach(function(k, unitType)
			local unitTypeUsage = unitType.usage[resourceType.name]
			unitTypeUsage.productionUsage = 0
			unitTypeUsage.upkeepUsage = 0
		end)
	end)

	-- fill unittype resources with real data
	units.foreach(function(k, unit)
		local econData = GetEconData(unit)
		local unitToGetDataFrom = nil
		local isUpkeep = false

		if (econData == nil) then
			return
		end

		if unit:GetFocus() then
			unitToGetDataFrom = unit:GetFocus()
			isUpkeep = false
		else
			unitToGetDataFrom = unit
			-- LOG("1: isUpkeep = true")
			isUpkeep = true
		end

		local unitType = GetUnitType(unitToGetDataFrom)

		local unitHasUsage = false
		resourceTypes.foreach(function(k, resourceType)
			local usage = econData[resourceType.econDataKey]

			if (usage > 0) then
				local unitTypeUsage = unitType.usage[resourceType.name]
				if (isUpkeep) then
					-- LOG("2: resourceType.upkeepUsage + usage")

					resourceType.upkeepUsage = resourceType.upkeepUsage + usage
					unitTypeUsage.upkeepUsage = unitTypeUsage.upkeepUsage + usage
				else
					resourceType.productionUsage = resourceType.productionUsage + usage
					unitTypeUsage.productionUsage = unitTypeUsage.productionUsage + usage
				end
				unitHasUsage = true
			end
		end)

		if unitHasUsage then
			if (isUpkeep) then
				-- LOG("3: unitHasUsage table.insert(unitType.upkeepUnits, unit)")
				table.insert(unitType.upkeepUnits, unit)
			else
				-- LOG("productionUnits")
				table.insert(unitType.productionUnits, unit)
			end
		end

		-- TODO:
		-- if unitHasUsage then
		-- 	if (isUpkeep) then
		-- 		if unit:IsInCategory 'COMMAND' then
		-- 			LOG("COMMAND")
		-- 			table.insert(unitType.productionUnits, unit)
		-- 		else
		-- 			table.insert(unitType.upkeepUnits, unit)
		-- 		end
		-- 	else
		-- 		table.insert(unitType.productionUnits, unit)
		-- 	end
		-- end
	end)

	-- update ui
	local relayoutRequired = false
	unitTypes.foreach(function(k, unitType)
		resourceTypes.foreach(function(k, resourceType)
			local unitTypeUsage = unitType.usage[resourceType.name]
			local resourceTypeUsageTotal = resourceType.productionUsage + resourceType.upkeepUsage

			if resourceTypeUsageTotal == 0 then
				unitTypeUsage.productionContainer.bar.Width:Set(0)
				unitTypeUsage.upkeepContainer.bar.Width:Set(0)
			else
				local productionValue = unitTypeUsage.productionUsage
				local upkeepValue = unitTypeUsage.upkeepUsage

				productionValue = productionValue / resourceTypeUsageTotal * usageContainerWidth
				upkeepValue = upkeepValue / resourceTypeUsageTotal * usageContainerWidth

				productionValue = math.ceil(productionValue)
				upkeepValue = math.ceil(upkeepValue)

				-- Percentify
				if (productionValue > 0 and productionValue < 1) then productionValue = 1 end
				if (upkeepValue > 0 and upkeepValue < 1) then upkeepValue = 1 end

				local shouldShow = productionValue + upkeepValue > 0
				if (shouldShow and unitType.typeUi.uiRoot:IsHidden()) then
					unitType.typeUi.uiRoot:Show()
					-- unitType.typeUi.Clear()
					relayoutRequired = true
				end

				local top = unitType.typeUi.uiRoot:Top()
				local left = unitType.typeUi.uiRoot:Left()
				unitTypeUsage.productionContainer.bar.Width:Set(productionValue)

				-- LOG("unitTypeUsage.upkeepContainer.bar.Width:Set(upkeepValue): " .. tostring(upkeepValue))
				-- LOG(unitTypeUsage.upkeepContainer.bar)

				unitTypeUsage.upkeepContainer.bar.Width:Set(upkeepValue)
				if resourceType.name == "MASS" then
					unitTypeUsage.upkeepContainer.bar.Top:Set(top + outerPadding)
				elseif resourceType.name == "ENERGY" then
					unitTypeUsage.upkeepContainer.bar.Top:Set(top + outerPadding + usageContainerHeight + barSeparationY)
				end

				unitTypeUsage.upkeepContainer.bar.Left:Set(left + outerPadding + usageContainerWidth - upkeepValue) --  + leftBarsRight
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
	return sorted
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


function UsageContainer(typeUi, unitType, spendType, color)
	local container = Bitmap(typeUi.uiRoot)
	container.Width:Set(usageContainerWidth)
	container.Height:Set(usageContainerHeight)
	container:InternalSetSolidColor("30"..color)

	container.bar = Bitmap(container)
	container.bar.Width:Set(10)
	container.bar.Height:Set(usageContainerHeight)
	container.bar:InternalSetSolidColor(color)
	container.bar:DisableHitTest()
	LayoutHelpers.AtLeftIn(container.bar, container, 0)
	LayoutHelpers.AtTopIn(container.bar, container, 0)

	return container
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
			unitType.productionPaused = false
			unitType.upkeepPaused = false
			unitType.pausedProductionUnits = {}
			unitType.pausedUpkeepUnits = {}
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

		-- Loop
		unitTypes.foreach(function(k, unitType)
			local typeUi = {}
			unitType.typeUi = typeUi

			-- Root
			typeUi.uiRoot = Bitmap(uiRoot)
			typeUi.uiRoot.Width:Set(rootWidth)
			typeUi.uiRoot.Height:Set(typeHeight)
			typeUi.uiRoot:InternalSetSolidColor('aa000000')
			typeUi.uiRoot:Hide()
			LayoutHelpers.AtLeftIn(typeUi.uiRoot, uiRoot, 0)
			LayoutHelpers.AtTopIn(typeUi.uiRoot, uiRoot, 0)
			typeUi.uiRoot.HandleEvent = function(self, event) return RootEvents(self, event, unitType) end

			-- Icon
			typeUi.stratIcon = Bitmap(typeUi.uiRoot)
			local iconName = '/mods/UI-Party/textures/category_icons/' .. unitType.icon .. '.dds'
			typeUi.stratIcon:SetTexture(iconName)
			typeUi.stratIcon.Height:Set(iconSize) -- typeUi.stratIcon.BitmapHeight
			typeUi.stratIcon.Width:Set(iconSize)
			LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, iconLeftIn)
			LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)
			typeUi.stratIcon.HandleEvent = function(self, event) return IconEvents(self, event, unitType) end

			-- Production Energy Bar
			typeUi.productionEnergyContainer = UsageContainer(typeUi, unitType, spendTypes.PRODUCTION, "ff0000")
			LayoutHelpers.AtLeftIn(typeUi.productionEnergyContainer, typeUi.uiRoot, rightBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.productionEnergyContainer, typeUi.uiRoot, topBarTopIn)
			typeUi.productionEnergyContainer.HandleEvent = function(self, event) return UsageContainerEvents(self, event, unitType) end

			-- Production Mass Bar
			typeUi.productionMassContainer = UsageContainer(typeUi, unitType, spendTypes.PRODUCTION, "00ffff")
			LayoutHelpers.AtLeftIn(typeUi.productionMassContainer, typeUi.uiRoot, rightBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.productionMassContainer, typeUi.uiRoot, bottomBarTopIn)
			typeUi.productionMassContainer.HandleEvent = function(self, event) return UsageContainerEvents(self, event, unitType) end

			-- Upkeep Energy Bar
			typeUi.upkeepEnergyContainer = UsageContainer(typeUi, unitType, spendTypes.UPKEEP, "ffa500")
			LayoutHelpers.AtLeftIn(typeUi.upkeepEnergyContainer, typeUi.uiRoot, leftBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.upkeepEnergyContainer, typeUi.uiRoot, topBarTopIn)
			typeUi.upkeepEnergyContainer.HandleEvent = function(self, event) return UsageContainerEvents(self, event, unitType) end

			-- Upkeep Mass Bar
			typeUi.upkeepMassContainer = UsageContainer(typeUi, unitType, spendTypes.UPKEEP, "00ff00")
			LayoutHelpers.AtLeftIn(typeUi.upkeepMassContainer, typeUi.uiRoot, leftBarsLeftIn)
			LayoutHelpers.AtTopIn(typeUi.upkeepMassContainer, typeUi.uiRoot, bottomBarTopIn)
			typeUi.upkeepMassContainer.HandleEvent = function(self, event) return UsageContainerEvents(self, event, unitType) end

			unitType.usage["Mass"] = {
				productionContainer = typeUi.productionMassContainer,
				upkeepContainer = typeUi.upkeepMassContainer,
				text = typeUi.massText,
				upkeepText = typeUi.massUpkeepText,
			}

			unitType.usage["Energy"] = {
				productionContainer = typeUi.productionEnergyContainer,
				upkeepContainer = typeUi.upkeepEnergyContainer,
				text = typeUi.energyText,
				upkeepText = typeUi.energyUpkeepText,
			}

			-- typeUi.massProductionBar:Hide()
			-- typeUi.massUpkeepBar:Hide()
			-- typeUi.energyProductionBar:Hide()
			-- typeUi.energyUpkeepBar:Hide()
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
