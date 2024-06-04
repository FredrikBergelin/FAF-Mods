local unitToggleRules = {
	Shield = 0,
	Weapon = 1,
	Jamming = 2,
	Intel = 3,
	Production = 4,
	Stealth = 5,
	Generic = 6,
	Special = 7,
	Cloak = 8,
}

function GetOnValueForScriptBit(i)
	if i == 0 then return false end -- shield is weird and reversed... you need to set it to false to get it to turn off - unlike everything else
	return true
end

function hasEnergyWeapon(unitBlueprint)
	if unitBlueprint.Weapon then
		for _, weapon in ipairs(unitBlueprint.Weapon) do
			if weapon.EnergyRequired and weapon.EnergyRequired > 0 then
				return true
			end
		end
	end
	return false
end

function SetResourceDrainForSelectedUnits(setActive, abilities)
	local units = GetSelectedUnits()

	abilities = abilities or
		{ "Pause", "Shield", "Weapon", "Jamming", "Intel", "Stealth", "Generic", "Special", "Cloak", "EnergyDrainWeapons" } -- "Production" left out so you wont lose your mex income.

	if setActive then
		PlaySound(Sound { Cue = "UI_Tab_Click_02", Bank = "Interface" })
	else
		PlaySound(Sound { Cue = "UI_Menu_Error_01", Bank = "Interface" })
	end

	if contains(abilities, "Pause") then
		SetPaused(units, not setActive)
	end

	if contains(abilities, "EnergyDrainWeapons") then
		for _, unit in ipairs(units) do
			local blueprint = unit:GetBlueprint()
			local hasEnergyWeapon = false

			if blueprint.Weapon then
				for _, weapon in ipairs(blueprint.Weapon) do
					if weapon.EnergyDrainPerSecond and weapon.EnergyDrainPerSecond > 0 then
						hasEnergyWeapon = true
						break
					end
				end
			end

			if hasEnergyWeapon then
				if setActive then
					ToggleFireState({ unit }, 1) -- Set ground fire state
				else
					ToggleFireState({ unit }, 3) -- Set hold fire state
				end
			end
		end
	end

	from(abilities).foreach(function(i, a)
		local ruleNumber = unitToggleRules[a]
		if ruleNumber then
			local onValue = GetOnValueForScriptBit(ruleNumber)
			ToggleScriptBit(units, ruleNumber, (setActive and onValue) or (not setActive and not onValue))
		end
	end)
end

function contains(table, val)
	for i, v in ipairs(table) do
		if v == val then
			return true
		end
	end
	return false
end
