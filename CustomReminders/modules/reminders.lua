local alive = true

function remind(message, size, cycles, alternate)
	local data1 = {text = message, size = size, color = 'ffffffff', duration = 0.5, location = 'center'}
	local data2 = {text = message, size = size, color = 'ffff2222', duration = 0.5, location = 'center'}
	local data
	for i = 0, cycles do
		if alternate and (i == 1 or i == 3 or i == 5) then
			data = data2
		else
			data = data1
		end
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
		WaitSeconds(1.5)
	end
end

function main()
	ForkThread(radar)
	ForkThread(scout)
	ForkThread(resources)
	ForkThread(start)
end

function start()
	WaitSeconds(1)
	remind('Reminder Active: Scout, Radar, Resources', 20, 0)
end

function radar()
	WaitSeconds(295)
	while alive do
		remind('Radar', 20, 0)
		WaitSeconds(191)
	end
end

function scout()
	WaitSeconds(207)
	while alive do
		remind('Scout', 20, 0)
		WaitSeconds(127)
	end
end

function resources()
	WaitSeconds(124)
	local econData
	local mass
	local energy
	local energyOneSecAgo = econData.stored['ENERGY']
	local maxMassStorage = 1
	local maxEnergyStorage = 1
	WaitSeconds(1)
	while alive do
		if GetSimTicksPerSecond() > 0 then
			econData = GetEconomyTotals()
			mass = econData.stored['MASS']
			energy = econData.stored['ENERGY']
			maxMassStorage = econData.maxStorage['MASS']
			maxEnergyStorage = econData.maxStorage['ENERGY']

			if maxMassStorage == 0 then
				alive = false
				break
			end

			if energy < 1 then
				remind('Stalling Energy!!', 40, 0)
			elseif energy < energyOneSecAgo and energy / maxEnergyStorage < 0.35 then
				remind('Energy Critical!', 30, 0)
			elseif energy < energyOneSecAgo then
				remind('Energy needed', 20, 0)
			elseif maxEnergyStorage < 5000 and energy / maxEnergyStorage == 1 then
				remind('Energy Storage', 20, 0)
			end

			if mass > 500 and mass / maxMassStorage == 1 then
				remind('Spend Mass!!', 40, 0, true)
			elseif mass > 500 and mass / maxMassStorage > 0.90 then
				remind('Spend Mass!', 30, 0)
			elseif mass > 500 and mass / maxMassStorage > 0.6 then
				remind('Spend Mass', 20, 0)
			elseif mass < 1 then
				remind('Stalling Mass', 30, 0)
			elseif mass < 100 then
				remind('Low Mass', 20, 0)
			end

		end
		WaitSeconds(9)
		energyOneSecAgo = econData.stored['ENERGY']
		WaitSeconds(1)
	end
end