local Button = import('/lua/maui/button.lua').Button


ForkThread(function()
	WaitSeconds(5)
	while GetGameTimeSeconds() < 5 do
		WaitSeconds(0.1)
	end

	local saveData = {}
	doscript('/lua/dataInit.lua', saveData)
	doscript(SessionGetScenarioInfo().save, saveData)

	startPositions = {}
	for markerName, markerTable in saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers do
		if string.find(markerName, "ARMY_*") then
			startPositions[markerName] = markerTable.position
		end
	end

	local armyTable = GetArmiesTable().armiesTable
	if GetFocusArmy() > 0 then
		local factions = {
			[0] = "Uef",
			[1] = "Aeon",
			[2] = "Cybran",
			[3] = "Seraphim"
		}
		for armyIndex, armyData in armyTable do
			if (not armyData.civilian) and (not IsAlly(GetFocusArmy(), armyIndex)) then
				local armyName = armyData.nickname
				if armyData.faction >= 0 and armyData.faction <= table.getn(factions) then
					armyName = armyName--..' ['..factions[armyData.faction]..']'
				end
				createPositionMarker(armyData, startPositions[armyData.name][1], startPositions[armyData.name][2], startPositions[armyData.name][3])
			end
		end
	end
end)


function createPositionMarker(armyData, posX, posY, posZ)
	if not (posX or posY or posZ) then
		return 
	end 
	local pos = Vector(posX, posY, posZ)
	
	-- Bitmap of marker
	local posMarker = Bitmap(GetFrame(0))
	LayoutHelpers.SetDimensions(posMarker, 150, 30) -- Size of bitmap and also size of 
	posMarker.pos = pos
	posMarker.Depth:Set(10)
	posMarker:SetNeedsFrameUpdate(true)
	posMarker:DisableHitTest()
	
	-- Nickname
	posMarker.nickname = UIUtil.CreateText(posMarker, armyData.nickname, 12, 'Montserrat')
	posMarker.nickname:SetColor('white')
	posMarker.nickname:SetDropShadow(true)
	LayoutHelpers.AtCenterIn(posMarker.nickname, posMarker)
	posMarker.nickname:DisableHitTest()
	
	-- Army color line below the nickname
	posMarker.separator = Bitmap(posMarker)
    posMarker.separator:SetTexture('/mods/reveal_positions/textures/bg.dds')
    posMarker.separator.Left:Set(posMarker.nickname.Left)
    posMarker.separator.Right:Set(posMarker.nickname.Right)
	posMarker.separator.Height:Set(2)--								  |nickname|
	LayoutHelpers.Below(posMarker.separator, posMarker.nickname, 4)--	 4px
	posMarker.separator:SetSolidColor(armyData.color)--				    |line|
	posMarker.separator:DisableHitTest()
	
	-- Bitmap of faction icon
	posMarker.faction=Bitmap(posMarker)
    posMarker.faction:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(armyData.faction)))
	LayoutHelpers.SetDimensions(posMarker.faction, 15, 15)
	LayoutHelpers.AtCenterIn(posMarker.faction, posMarker.nickname)--	        distance
	LayoutHelpers.LeftOf(posMarker.faction, posMarker.nickname,4) --     |icon|   [4px]   |nickname|
	posMarker.faction:DisableHitTest()
	
	-- Fill the bitmap of faction icon by army color
	posMarker.color = Bitmap(posMarker.faction)
	LayoutHelpers.FillParent(posMarker.color, posMarker.faction)
	posMarker.color.Depth:Set(function() return posMarker.faction.Depth() - 1 end)
	posMarker.color:SetSolidColor(armyData.color)
	posMarker.color:DisableHitTest()
	
	-- "Invisible" button that fill the whole bitmap of market
	local posMarkerButton = Button(posMarker, '/mods/reveal_positions/textures/bg.dds', '/mods/reveal_positions/textures/bg.dds', '/mods/reveal_positions/textures/bg.dds', '/mods/reveal_positions/textures/bg.dds')
	LayoutHelpers.FillParent(posMarkerButton, posMarker.nickname)
	posMarkerButton.pos = pos
	posMarkerButton.Depth:Set(9)

	posMarkerButton:EnableHitTest(true)
	posMarkerButton.OnClick = function(self, event)
		posMarker:Destroy()
		posMarker = nil
		posMarkerButton:Destroy()
		posMarkerButton = nil
	end

	posMarker.OnFrame = function(self, delta)
		local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		local pos = worldView:Project(Vector(posMarker.pos.x, posMarker.pos.y, posMarker.pos.z))

		LayoutHelpers.AtLeftTopIn(posMarker, worldView, pos.x - posMarker.Width() / 2, pos.y - posMarker.Height() / 2 + 1)
		LayoutHelpers.AtLeftTopIn(posMarkerButton, worldView, pos.x - posMarker.Width() / 2, pos.y - posMarker.Height() / 2 + 1)
	end
	
	return posMarker
end