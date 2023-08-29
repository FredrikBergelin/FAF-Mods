function UpgradeStructuresEngineersCycleTemplates()
    local units = GetSelectedUnits()

    for i, unit in units do
        if unit:IsInCategory("ENGINEER") then
            if units then
                local tech2 = EntityCategoryFilterDown(categories.TECH2, units)
                local tech3 = EntityCategoryFilterDown(categories.TECH3, units)
                local sACUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, units)

                if next(sACUs) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = sACUs[1]:GetEntityId() } }, true)
                    SelectUnits(sACUs)
                elseif next(tech3) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech3[1]:GetEntityId() } }, true)
                    SelectUnits(tech3)
                elseif next(tech2) then
                    SimCallback(
                        { Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech2[1]:GetEntityId() } }, true)
                    SelectUnits(tech2)
                else
                end
            end

            import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
            return
        end
    end

    import("/lua/keymap/hotbuild.lua").buildActionUpgrade()
end

-- Decrease Unit count in factory queue
local DecreaseBuildCountInQueue = import("/lua/ui/game/construction.lua").DecreaseBuildCountInQueue
local RefreshUI = import("/lua/ui/game/construction.lua").RefreshUI
function RemoveLastItem()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits and selectedUnits[1]:IsInCategory "FACTORY" then
        local currentCommandQueue = SetCurrentFactoryForQueueDisplay(selectedUnits[1])
        local count = 1
        if IsKeyDown "Shift" then
            count = 5
        end
        DecreaseBuildCountInQueue(table.getsize(currentCommandQueue), count)
        ClearCurrentFactoryForQueueDisplay()
        RefreshUI()
    end
end

function UndoLastQueueOrder()
	local units = GetSelectedUnits()
	if (units ~= nil) then
		local u = units[1]
		local queue = SetCurrentFactoryForQueueDisplay(u);
		if queue ~= nil then
			local lastIndex = table.getn(queue)
			local count = 1
			if IsKeyDown('Shift') then
				count = 5
			end
			DecreaseBuildCountInQueue(lastIndex, count)
		end
	end
end

function UndoAllExceptCurrentQueueOrder()
	local units = GetSelectedUnits()
	if (units ~= nil) then
		local u = units[1]
		local queue = SetCurrentFactoryForQueueDisplay(u);
		if queue ~= nil then
			local lastIndex = table.getn(queue)
			local count = 1
			if IsKeyDown('Shift') then
				count = 5
			end
			DecreaseBuildCountInQueue(lastIndex, lastIndex - 1)
		end
	end
end
