local Button = import('/lua/maui/button.lua').Button
local PixelScaleFactor = LayoutHelpers.GetPixelScaleFactor()

ForkThread(function()
    WaitSeconds(5)
    while GetGameTimeSeconds() < 5 do
        WaitSeconds(0.1)
    end

    local ScenarioInfo = SessionGetScenarioInfo()

    -- simInit.lua shuffles certain spawns and breaks the mod
    local spawn = ScenarioInfo.Options.TeamSpawn
    local spawnsAreShuffled = false
    if spawn then
        if table.find({'random', 'balanced', 'balanced_flex'}, spawn) then
            spawnsAreShuffled = true
        elseif table.find({'random_reveal', 'balanced_reveal', 'balanced_flex_reveal'}, spawn) then
            return
        end
    end

    local saveData = {}
    doscript('/lua/dataInit.lua', saveData)
    doscript(ScenarioInfo.save, saveData)

    startPositions = {}
    for markerName, markerTable in saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers do
        if string.find(markerName, "ARMY_*") then
            startPositions[markerName] = markerTable.position
        end
    end

    local armyTable = GetArmiesTable().armiesTable
    if GetFocusArmy() > 0 then
        -- local factions = {
        --  [0] = "Uef",
        --  [1] = "Aeon",
        --  [2] = "Cybran",
        --  [3] = "Seraphim"
        -- }
        for armyIndex, armyData in armyTable do
            if (not armyData.civilian) and (not IsAlly(GetFocusArmy(), armyIndex)) then
                local nickname, faction, color
                if spawnsAreShuffled then
                    nickname, faction, color = 'Enemy', nil, 'white'
                else
                    nickname, faction, color = armyData.nickname, armyData.faction, armyData.color
                end
                -- local armyName = armyData.nickname
                -- if armyData.faction >= 0 and armyData.faction <= table.getn(factions) then
                --  armyName = armyName ..' [' .. factions[armyData.faction] .. ']'
                -- end
                createPositionMarker(nickname, faction, color, startPositions[armyData.name][1], startPositions[armyData.name][2], startPositions[armyData.name][3])
            end
        end
    end
end)


function createPositionMarker(nickname, faction, color, posX, posY, posZ)
    if not (posX or posY or posZ) then
        return 
    end 
    local pos = Vector(posX, posY, posZ)
    
    -- Bitmap of marker
    local posMarker = Bitmap(GetFrame(0))
    LayoutHelpers.SetDimensions(posMarker, 150, 25)
    posMarker.pos = pos
    posMarker.Depth:Set(10)
    posMarker:SetNeedsFrameUpdate(true)
    posMarker:DisableHitTest()
    
    -- Nickname
    posMarker.nickname = UIUtil.CreateText(posMarker, nickname, 12)
    posMarker.nickname:SetColor('white')
    posMarker.nickname:SetDropShadow(true)
    LayoutHelpers.AtCenterIn(posMarker.nickname, posMarker)
    posMarker.nickname:DisableHitTest()
    
    -- Army color line below the nickname
    posMarker.separator = Bitmap(posMarker)
    posMarker.separator:SetTexture('/mods/Reveal positions/textures/clear.dds')
    posMarker.separator.Left:Set(posMarker.nickname.Left)
    posMarker.separator.Right:Set(posMarker.nickname.Right)
    posMarker.separator.Height:Set(1)--                               |nickname|
    LayoutHelpers.Below(posMarker.separator, posMarker.nickname, 3)--    3px
    posMarker.separator:SetSolidColor(color)--                  |line|
    posMarker.separator:DisableHitTest()
    
    if faction then
        -- Bitmap of faction icon
        posMarker.faction=Bitmap(posMarker)
        posMarker.faction:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(faction)))
        LayoutHelpers.SetDimensions(posMarker.faction, 15, 15)
        LayoutHelpers.AtVerticalCenterIn(posMarker.faction, posMarker.nickname)--    distance
        LayoutHelpers.LeftOf(posMarker.faction, posMarker.nickname,4) --     |icon|   [4px]   |nickname|
        posMarker.faction:DisableHitTest()
        
        -- Fill the bitmap of faction icon by army color
        posMarker.color = Bitmap(posMarker.faction)
        LayoutHelpers.FillParent(posMarker.color, posMarker.faction)
        posMarker.color.Depth:Set(function() return posMarker.faction.Depth() - 1 end)
        posMarker.color:SetSolidColor(color)
        posMarker.color:DisableHitTest()
    end
    
    -- Invisible button that fill bitmap of marker
    local posMarkerButton = Button(posMarker, '/mods/Reveal positions/textures/clear.dds', '/mods/Reveal positions/textures/clear.dds', '/mods/Reveal positions/textures/clear.dds', '/mods/Reveal positions/textures/clear.dds')
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

        LayoutHelpers.AtLeftTopIn(posMarker, worldView, (pos.x - posMarker.Width() / 2) / PixelScaleFactor, (pos.y - posMarker.Height() / 2) / PixelScaleFactor + 1)
        LayoutHelpers.AtLeftTopIn(posMarkerButton, worldView, (pos.x - posMarker.Width() / 2) / PixelScaleFactor, (pos.y - posMarker.Height() / 2) / PixelScaleFactor + 1)
    end
    
    return posMarker
end