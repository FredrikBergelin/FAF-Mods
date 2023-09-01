local energyPercent = 0

function UpdateEconTotals()
	local econTotals = GetEconomyTotals()

	local globalEnergyMax = econTotals["maxStorage"]["ENERGY"]
	local globalEnergyCurrent = econTotals["stored"]["ENERGY"]

	energyPercent = 100 * (globalEnergyCurrent / globalEnergyMax)
	return energyPercent
end

function AutoPause()
	local totalSel = GetSelectedUnits()
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
