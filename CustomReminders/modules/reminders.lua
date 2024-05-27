local alive = true

function remind(message, size, cycles)
	local data1 = {text = message, size = size, color = 'ffffffff', duration = 0.5, location = 'center'}
	local data2 = {text = message, size = size, color = 'ffff2222', duration = 0.5, location = 'center'}
	for i = 0, cycles do
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data1)
		WaitSeconds(0.5)
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data2)
		WaitSeconds(0.5)
	end
end

function main()
	ForkThread(radar)
	ForkThread(scout)
	ForkThread(resources)
	ForkThread(start)
end

function start()
	WaitSeconds(5)
	remind('Reminder Active', 40, 2)
end

function radar()
	WaitSeconds(295)
	while alive do
		remind('Radar', 35, 3)
		WaitSeconds(191)
	end
end

function scout()
	WaitSeconds(207)
	while alive do
		remind('Scout', 30, 2)
		WaitSeconds(127)
	end
end

function resources()
	WaitSeconds(125)
	local econData
	local mass
	local energy
	local maxMassStorage = 1
	while alive do
		if GetSimTicksPerSecond() > 0 then
			econData = GetEconomyTotals()
			mass = econData.stored['MASS']
			energy = econData.stored['ENERGY']
			maxMassStorage = econData.maxStorage['MASS']
			
			if maxMassStorage == 0 then
				alive = false
				break
			end
			
			if mass > 1000 or mass / maxMassStorage > 0.6 then
				remind('Spend mass', 45, 4)
			elseif mass < 20 then
				remind('Low mass', 25, 1)
			end
			if energy < 50 then
				remind('Low energy', 50, 4)
			end
		end
		WaitSeconds(25)
	end
end