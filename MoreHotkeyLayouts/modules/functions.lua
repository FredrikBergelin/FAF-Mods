function TableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

function SelectedUnitsWithOnlyTheseCommands(commands)
	local units = GetSelectedUnits() or {}
	local unitsToSelect = {}

	for index, unit in units do
		local comQ = unit:GetCommandQueue()

        LOG("commands getn " .. table.getn(commands))
        LOG("comQ getn " .. table.getn(commands))

        local addUnit = true
        if (table.getn(comQ) == 0 and not TableContains(commands, "Idle")) then
            LOG("No commands / Idle")
            addUnit = false
		end

		for _, command in comQ do
			if (not TableContains(commands, command.type)) then
                LOG("not TableContains")
                addUnit = false
            end
		end

        if addUnit then
            LOG("addUnit")
            table.insert(unitsToSelect, unit)
        end
	end

	return unitsToSelect
end

function SelectSimilarUnits(scope)
	local str = ''
    local similarUnitsBlueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()
    similarUnitsBlueprints.foreach(function(k,v) str = str .. " " .. scope .. " " .. v.BlueprintId .. "," end)

    ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to
end