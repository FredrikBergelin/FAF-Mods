local trackedUnits = {}
local catCache = {}
local numrepeat = 20

function ConvertToMove()
	local units = GetSelectedUnits() or {}

	for index, unit in units do
		local commands = {}
		local comQ = unit:GetCommandQueue()

		local patrolCommands = {}

		for _, command in comQ do
			if (command.type == 'Patrol') then
				-- convert to Move				
				table.insert(patrolCommands, {
					["CommandType"] = "Move",
					["Position"] = command.position
				})
			else
				local target = command.Target or { ["EntityId"] = 0 }
				table.insert(command, {
					["CommandType"] = command.type,
					["Position"] = command.position,
					["EntityId"] = target.EntityId
				})
			end
		end

		if (table.getn(patrolCommands) > 1) then
			local i = 1
			while (i < numrepeat) do
				for _, v in ipairs(patrolCommands) do
					table.insert(commands, v)
				end
				i = i + 1
			end

			SimCallback({
				Func = "GiveOrders",
				Args = {
					unit_orders = commands,
					unit_id     = unit:GetEntityId(),
					From        = GetFocusArmy()
				}
			}, true)
		end
	end
end

function SelectPatrolUnits()
	local units = GetSelectedUnits() or {}
	local unitsToSelect = {}

	for index, unit in units do
		local commands = {}
		local comQ = unit:GetCommandQueue()

		local stopCommands = {}

		for _, command in comQ do
			if (command.type == 'Patrol') then
				table.insert(unitsToSelect, unit)
			end
		end
	end

	SelectUnits(unitsToSelect)
end
