 -- https://github.com/FAForever/fa/blob/develop/lua/sim/score.lua#L203
--  for unitId, stats in brain.UnitStats do
--      if Score.blueprints[unitId] == nil then
--          Score.blueprints[unitId] = {}
--      end
--      for statName, value in stats do
--          Score.blueprints[unitId][statName] = value
--      end
--  end


function RunTest()
    WARN('TEST.RunTest') 

    -- sim.Score:
--    local score = import('/lua/ui/game/score.lua').currentScores 
--    table.print(score, 'score', WARN)

  --  local senderUI = GetFrame(0)
  --  import('/mods/SupremeScoreBoard2/modules/score_board.lua').AnnounceUnit(1, 'test AnnounceUnit2')
   -- import('/mods/SupremeScoreBoard2/modules/score_popup.lua').Show(1, 'test AnnounceUnit2')

 --  local numbers = { 0.1, 0.02 } -- , 0.003, 0.0004, 0.00005
 --  
 --  for i, num in numbers do
 --       WARN(round1(num, 1) .. " <= math.round_ORG(" .. num .. ", 1) ")
 --       WARN(round2(num, 1) .. " <= math.round_NEW(" .. num .. ", 1) ")
 --  end
 --  for i, num in numbers do
 --       WARN(round1(num, 2) .. " <= math.round_ORG(" .. num .. ", 2) ")
 --       WARN(round2(num, 2) .. " <= math.round_NEW(" .. num .. ", 2) ")
 --  end
--   for i, num in numbers do
--        WARN(round1(num, 2) .. " <= math.round_ORG(" .. num .. ", 3) ")
--        WARN(round2(num, 2) .. " <= math.round_NEW(" .. num .. ", 3) ")
--   end
      --  WARN("_G.Version " .. _G.Version ) 

--   for name, val in _G do
--        if type(val) == 'string' then
--            WARN(name .. " " .. val ) 
--        end
--   end

   local listTableFull = { 1, 2, 3 }
   local listTableEmpty = { }
   local hashTableFull = { one = 1, two = 2, three = 3 }
   local hashTableEmpty = { one = false }
   
 --  WARN(tostring(table_empty_NEW(listTableFull)) .. " << table.empty_NEW(listTableFull) ")
 --  WARN(tostring(table_empty_ORG(listTableFull)) .. " << table.empty_ORG(listTableFull) ")
 --
 --  WARN(tostring(table_empty_NEW(listTableEmpty)) .. " << table.empty_NEW(listTableEmpty) ")
 --  WARN(tostring(table_empty_ORG(listTableEmpty)) .. " << table.empty_ORG(listTableEmpty) ")
 --
 --  WARN(tostring(table_empty_NEW(hashTableFull)) .. " << table.empty_NEW(hashTableFull) ")
 --  WARN(tostring(table_empty_ORG(hashTableFull)) .. " << table.empty_ORG(hashTableFull) ")
 --
 --  WARN(tostring(table_empty_NEW(hashTableEmpty)) .. " << table.empty_NEW(hashTableEmpty) ")
 --  WARN(tostring(table_empty_ORG(hashTableEmpty)) .. " << table.empty_ORG(hashTableEmpty) ")
end

function table_empty_ORG(t)
    return table.getn(t) == 0
end

function table_empty_NEW(t)
    return next(t) == nil
end

function round1(num, idp)
    if not idp then
        return math.floor(num + .5)
    else
        return tonumber( string.format("%." .. (idp or 0) .. "f", num))
    end
end

function round2(num, idp)
--    local mult = 10^idp
    local mult = math.pow(10, idp)
    return math.floor(num * mult + 0.5) / mult
    -- TODO test:
--    if idp and idp>0 then
--      local mult = 10^idp
--      return math.floor(num * mult + 0.5) / mult
--    end
--    return math.floor(num + 0.5)
end