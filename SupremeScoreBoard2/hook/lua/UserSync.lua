local modPath = '/mods/SupremeScoreBoard2/'
local modTextures = modPath..'textures/'
local modScripts  = modPath..'modules/'

local log  = import(modScripts..'ext.logging.lua') 

--- table_empty(t) returns true iff t has no keys/values.
local function table_empty(t)
    if type(t) ~= 'table' then return true end
    return next(t) == nil
end

local orgOnSync = OnSync
function OnSync()
    orgOnSync()

    --if Sync.TeamEco then
     --   import('/lua/ui/game/economy.lua').TeamEco = Sync.TeamEco
    --end
    --LOG(">>>> HUSAR: " .. " OnSync... "  )
    --LOG("SSB OnSync... " .. table.getn(Sync) )

    if Sync.SharedScore then
        log.Trace('Sync.SharedScore ... ')

        --import('/lua/ui/game/score.lua').sharedScores = Sync.Score
        --import('/lua/ui/game/score.lua').SharedScore = Sync.SharedScore
        --import('/mods/SupremeScoreBoard2/lua/ui/game/score.lua').sharedScores = Sync.SharedScore
        --import('/lua/ui/game/score.lua').sharedScores = Sync.SharedScore
        --import('/mods/ecoInfo/modules/ecoinfoUi.lua').updateMultipleUIs(Sync.updateEcoInfoPanels)
    end
    --if Sync.updateEcoInfoPanels then
    --    import('/mods/ecoInfo/modules/ecoinfoUi.lua').updateMultipleUIs(Sync.updateEcoInfoPanels)
    --end
    --
    --if Sync.removeEcoInfoPanels then
    --    import('/mods/ecoInfo/modules/ecoinfoUi.lua').removeMultipleUIs(Sync.removeEcoInfoPanels)
    --end
    if Sync.FocusArmyChanged then
        log.Trace('Sync.FocusArmyChanged ' .. (GetFocusArmy() or '?'))
        --import('/lua/ui/game/avatars.lua').FocusArmyChanged()
        --import('/lua/ui/game/multifunction.lua').FocusArmyChanged()
    end

    if Sync.Events then
        import(modScripts .. 'score_events.lua').UpdateEvents(Sync.Events)
    end 

    if not table_empty(Sync.Score) then
        import(modScripts .. 'score_board.lua').currentScores = Sync.Score
        --import('/lua/ui/game/score.lua').currentScores = Sync.Score
        --if not Sync.FullScoreSync then
        --    import('/lua/ui/game/scoreaccum.lua').UpdateScoreData(Sync.Score)
        --end
    end

end
