--Starting linenumber of this mod in worldview.lua for me for debug purposes: 1465
local modPath = "/mods/StrategicDefenceRangePreview/"
local commandMode = import('/lua/ui/game/commandmode.lua')
local Decal = import('/lua/user/userdecal.lua').UserDecal
local construction = import('/lua/ui/game/construction.lua')

--Global variables for whether the previews are alive, when a static ring has last been made and how many units are selected
local isDefencePreviewAlive = false
local isLinePreviewAlive = false
local lastCalled = CurrentTime()
local currentNumber = 0

--Rings for the defence ranges
local ringDefenceGroups = {
    defenceRange = {},
}
--Line consisting of rings
local lineMatrix = {}

--Manual circles
local circleMatrix = {}

--UnitIDs considered strategic or tactical
local strategicLauncherIDs = {"ueb2305", "urb2305", "uab2305", "xsb2305", "xsb2401", "ues0304", "urs0304", "uas0304", "xss0302"}
local tacticalLauncherIDs = {"ueb2108", "urb2108", "uab2108", "xsb2108"}
-- Include these ids in the tacticalLauncherIDs if you want cruisers/missile ships and nuke subs to have the tactical range preview aswell:
--"ues0202", "xss0202", "xas0306", "ues0304", "urs0304", "uas0304"

--idk
local function isAcceptablePreviewMode()
    local mode = commandMode.GetCommandMode()
    return not mode[2] or (mode[1] == "order" and (mode[2].name == "RULEUCC_Nuke" or mode[2].name == "RULEUCC_Tactical"))
end

--Evaluates whether a given unit is strategic or tactical or both
local function checkUnit(unit)
	local unitType = 0
	local both = false
	if (construction.checkMissileEnhancements(unit)) then
		unitType = 1
		return unitType
	end
	for _, tacticalUnit in ipairs(tacticalLauncherIDs) do
		if (unit:GetUnitId() == tacticalUnit) then
			unitType = 1
			both = true
		end
	end
	for _, strategicUnit in ipairs(strategicLauncherIDs) do
		if (unit:GetUnitId() == strategicUnit) then
			unitType = 2
			if (both == true) then
				unitType = 3
				return unitType
			end
		end
	end
	return unitType
end

--Given a set of selected units, a "line" consisting of many circles will be drawn 
--The line goes from the location of the unit towards the location of the mouse
--Depending on the current zoom, their size increases linearly 
local function createAndUpdateLines(unitType, selectedUnit, i)
	local currentZoom = GetCamera('WorldCamera'):GetZoom()
	if (unitType == 1) then
		countOfRings = 10
		scaleOfRings = 0.015 * currentZoom
	else
		countOfRings = 25
		scaleOfRings = 0.020 * currentZoom
	end
	local startPos = selectedUnit.GetPosition(selectedUnit)
	local endPos = GetMouseWorldPos()
	local stepLengthX = (endPos[1] - startPos[1]) / countOfRings
	local stepLengthY = (endPos[3] - startPos[3]) / countOfRings
	if (lineMatrix[i][0] == nil) then
		for j = 0, countOfRings do
			local line = Decal(GetFrame(0))
			line:SetTexture(modPath..'textures/line.dds')
			line:SetScale({scaleOfRings, 0, scaleOfRings})
			line:SetPosition({
				startPos[1] + j * stepLengthX,
				startPos[2],
				startPos[3] + j * stepLengthY
			})
			lineMatrix[i][j] = line
		end
	end
	if (lineMatrix[i][0] ~= nil) then
		for j = 0, countOfRings do
			lineMatrix[i][j]:SetScale({scaleOfRings, 0, scaleOfRings})
			lineMatrix[i][j]:SetPosition({
				startPos[1] + j * stepLengthX,
				startPos[2],
				startPos[3] + j * stepLengthY
			})
		end
	end
	isLinePreviewAlive = true
end

--Removes all segments of the line
local function removeLines()
    if (not isLinePreviewAlive) then
        return
    end
    for i in lineMatrix do
        for j in lineMatrix[i] do
            lineMatrix[i][j]:Destroy()
        end
    end
	lineMatrix = {}
    isLinePreviewAlive = false
end

--Creates a circle of variable radius and texture at the current mouse location, stores it within a table and sets the preview to true
local function createRangeRing(radius, type)
	if (not ringDefenceGroups.defenceRange[radius]) then
		local ring = Decal(GetFrame(0))
		ring:SetTexture(modPath..'textures/'..type)
		ring:SetScale({math.floor(2.05 * radius), 0, math.floor(2.05 * radius)})
		ring:SetPosition(GetMouseWorldPos())
		ringDefenceGroups.defenceRange[radius] = ring 
		isDefencePreviewAlive = true
	end
end

--Given what kind of unit a selected unit is, the createRangeRing function will be called with appropriate parameters
local function createRangeRings(unitType)
	local radiusStrategicDefence = 90
	local radiusTacticalDefenceAeon = 15
	local radiusTacticalDefenceRest = 31
	if (unitType == 1) then
		createRangeRing(radiusTacticalDefenceAeon, "tmd.dds")
		createRangeRing(radiusTacticalDefenceRest, "tmd.dds")
	end
	if (unitType == 2) then
		createRangeRing(radiusStrategicDefence, "smd.dds")
	end
	if (unitType == 3) then
		createRangeRing(radiusTacticalDefenceAeon, "tmd.dds")
		createRangeRing(radiusTacticalDefenceRest, "tmd.dds")
		createRangeRing(radiusStrategicDefence, "smd.dds")
	end
end

--Updates the position of all defence range decals to the current mouse location
local function updateRings() 
	for _, group in ringDefenceGroups do
        for __, ring in group do
            ring:SetPosition(GetMouseWorldPos())
        end
    end
end

--Removes all defence range decals and sets the preview to false
local function removeRings()
    if (not isDefencePreviewAlive) then
        return
    end
    for _, group in ringDefenceGroups do
        for j, ring in group do
            ring:Destroy()
            group[j] = nil
        end
    end
    isDefencePreviewAlive = false
end

--Gets the currently selected units and according to each unitType the create functions will be called with appropriate parameters
--If the unitcount within the selection changes, all circles will be made anew to incorporate the new units
local function createRings()
	local selectedUnits = GetSelectedUnits() or {}
	local count = 0
	for i, selectedUnit in ipairs(selectedUnits) do 
		count = i
	end
	if (currentNumber ~= count) then
		removeRings()
		removeLines()
		currentNumber = count
	end
	if (not isLinePreviewAlive) then
		for i, selectedUnit in ipairs(selectedUnits) do
			lineMatrix[i] = {}
		end
	end
	for i, selectedUnit in ipairs(selectedUnits) do 
		local unitType = checkUnit(selectedUnit)
		if (unitType == 0) then
			return
		end
		createRangeRings(unitType)
		createAndUpdateLines(unitType, selectedUnit, i)
	end
end

--Creates a static ring at the current mouse location if at least one unit in the current selection can at least fire a nuke
local function createStaticRing()
	local selectedUnits = GetSelectedUnits() or {}
	for _, selectedUnit in ipairs(selectedUnits) do 
		local unitType = checkUnit(selectedUnit)
		if (unitType >= 2) then	
			timeDelta = CurrentTime() - lastCalled 
			if (timeDelta > 0.35) then
				local ring = Decal(GetFrame(0))
				ring:SetTexture(modPath..'textures/'..'smd.dds')
				ring:SetScale({math.floor(2.05 * 90), 0, math.floor(2.05 * 90)})
				ring:SetPosition(GetMouseWorldPos())
				table.insert(circleMatrix, ring)
				lastCalled = CurrentTime()
				return
			end
		end
	end
end

--Removes all static rings
local function removeStaticRings()
	if (next(circleMatrix) == nil) then
		return
	end
	for _, ring in circleMatrix do
		ring:Destroy()
	end
	circleMatrix = {}
end

--Calls approriate functions when the right key is pressed or released such that the circles will be drawn, updated or deleted
local currentWorldView = WorldView 
WorldView = Class(currentWorldView, Control) {

    defenceKeyDynamic = "SHIFT",
	defenceKeyStaticCreate = "SPACE",
	defenceKeyStaticRemove = "CONTROL",

    OnUpdateCursor = function(self)
        if isAcceptablePreviewMode() then
			if (IsKeyDown(self.defenceKeyDynamic)) then
				createRings()
				updateRings()
			else
				removeRings()
				removeLines()
			end
			if (IsKeyDown(self.defenceKeyStaticCreate)) then
				createStaticRing()
			end
			if (IsKeyDown(self.defenceKeyStaticRemove)) then
				removeStaticRings()
			end
		end
        return currentWorldView.OnUpdateCursor(self)
    end,
}