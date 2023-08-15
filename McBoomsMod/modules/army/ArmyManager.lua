local GameTick = GameTick
local GetFocusArmy = GetFocusArmy
local GetEconomyTotals = GetEconomyTotals
local GetSimTicksPerSecond = GetSimTicksPerSecond
local GetGameTimeSeconds = GetGameTimeSeconds
local ScoreSyncData = import('/lua/ui/game/score.lua')
local GetArmyData = import('/lua/ui/game/chat.lua').GetArmyData
local FindClients = import('/lua/ui/game/chat.lua').FindClients

local modFolder = 'McBoomsMod'

local LinkedTable = import('/mods/' .. modFolder .. '/modules/util/LinkedTable.lua').LinkedTable
local GetUnitManager = import('/mods/' .. modFolder .. '/modules/UnitManager.lua').GetUnitManager
local SpecialUnits = import('/mods/' .. modFolder .. '/modules/army/SpecialUnitObject.lua')
local SpecialUnitObject = SpecialUnits.SpecialUnitObject
local SpecialUnitType = SpecialUnits.SpecialUnitType

local math_mod = math.mod
local table_insert = table.insert
local table_getsize = table.getsize

local function triggerCallbacks(_callbacks, _newArmy)
    for _,elem in _callbacks do
        if elem.table then
            elem.callback(elem.table, _newArmy)
        else
            elem.callback(_newArmy)
        end
    end
end

ArmyManager = {}

function ArmyManager:addOnArmyChangedCallback(_cb, _table)
    table_insert(self.onArmyChangedCallbacks, {
        callback = _cb,
        table = _table
    })
end

function ArmyManager:GetMyUnitCount()
	return self.myUnitsSize
end

function ArmyManager:GetSyncUnitCount()
	return self.syncUnitsSize
end

local testTick = 0
function ArmyManager:update()
    if self.currentArmy ~= GetFocusArmy() then
        self.currentArmy = GetFocusArmy()
        self:clearAllSpecials()
        triggerCallbacks(self.onArmyChangedCallbacks, self.currentArmy)
    end


    local econ = GetEconomyTotals()
    local tps = GetSimTicksPerSecond()

    self.econData.mass.rate = (econ.income.MASS * tps) - (econ.lastUseRequested.MASS * tps)
    self.econData.mass.stored = econ.stored.MASS

    self.econData.energy.rate = (econ.income.ENERGY * tps) - (econ.lastUseRequested.ENERGY * tps)
    self.econData.energy.stored = econ.stored.ENERGY

    self.gameSecondsRounded = GetGameTimeSeconds()>0  and (GetGameTimeSeconds() - math_mod(GetGameTimeSeconds(), 1.0)) or 0
    --GetGameTime(), gameSpeed, GetSimRate()
    if GameTick()-60 > testTick then
        testTick = GameTick()
    end

	if ScoreSyncData.currentScores then
		local s = ScoreSyncData.currentScores

		if s[GetFocusArmy()] and s[GetFocusArmy()].general and s[GetFocusArmy()].general.currentunits then
			local syncCount = s[GetFocusArmy()].general.currentunits

			self.syncUnitsSize = syncCount
			self.myUnitsSize = GetUnitManager():getUnitCount()
		end
	end

    self:updateSpecials()
end

function ArmyManager:getGameSecondsRounded()
    return self.gameSecondsRounded
end

function ArmyManager:getMassRate()
    return self.econData.mass.rate
end

function ArmyManager:getMassStored()
    return self.econData.mass.stored
end

function ArmyManager:getEnergyRate()
    return self.econData.energy.rate
end

function ArmyManager:getEnergyStored()
    return self.econData.energy.stored
end

function ArmyManager:updateCanCountMS()
    if self:getEnergyStored() < 0.5 then
        self.canCountMS = false
    elseif self:getMassStored() < 0.5 then
        self.canCountMS = self:getMassRate() > 0
    else
        self.canCountMS = true
    end
end

function ArmyManager:isCanCountMS()
    return self.canCountMS
end

function ArmyManager:onUnitAdded(_unit)
    if _unit:IsInCategory("EXPERIMENTAL") then
        -- add experimental
        self:addExperimental(_unit)
    elseif _unit:IsInCategory("SILO") and not _unit:IsInCategory("NAVAL") then
        if _unit:IsInCategory("NUKE") then
            --add nuke silo
            self:addNuke(_unit)
        elseif _unit:IsInCategory("ANTIMISSILE") then
            --add antinuke silo
            self:addAntiNuke(_unit)
        end
    end
end

function ArmyManager:onUnitRemoved(_unit)
    self:removeNuke(_unit)
    self:removeAntiNuke(_unit)
    self:removeExperimental(_unit)
end

function ArmyManager:addNuke(_unit)
    if not self:containsUnit(self.nukeSilos, _unit) then
        local obj = SpecialUnitObject:new(_unit, SpecialUnitType.NUKE)
        self.nukeSilos:add(obj)
    end
end

function ArmyManager:removeNuke(_unit)
    for unitObj in self.nukeSilos:iterator() do
        if unitObj:getUnit()==_unit then
            self.nukeSilos:remove(unitObj)
            return
        end
    end
end

function ArmyManager:addAntiNuke(_unit)
    if not self:containsUnit(self.antiNukeSilos, _unit) then
        local obj = SpecialUnitObject:new(_unit, SpecialUnitType.ANTINUKE)
        self.antiNukeSilos:add(obj)
    end
end

function ArmyManager:removeAntiNuke(_unit)
    for unitObj in self.nukeSilos:iterator() do
        if unitObj:getUnit()==_unit then
            self.nukeSilos:remove(unitObj)
            return
        end
    end
end

function ArmyManager:addExperimental(_unit)
    if not self:containsUnit(self.exps, _unit) then
        local obj = SpecialUnitObject:new(_unit, SpecialUnitType.EXPERIMENTAL)
        self.exps:add(obj)
        self:getExpsTypeList(obj:getName()):add(obj)
    end
end

function ArmyManager:removeExperimental(_unit)
    for unitObj in self.exps:iterator() do
        if unitObj:getUnit()==_unit then
            self.exps:remove(unitObj)
            self:getExpsTypeList(unitObj:getName()):remove(unitObj)
            return
        end
    end
end

function ArmyManager:containsUnit(_linkedTable, _entityID)
   for unitObj in _linkedTable:iterator() do
      if unitObj.entityID==_entityID then
         return true
      end
   end
   return false
end

function ArmyManager:safetyCheck()
    for nuke in self.nukeSilos:iterator() do
        if nuke:isInvalid() then
            self.nukeSilos:remove(nuke)
        end
    end

    for antinuke in self.antiNukeSilos:iterator() do
        if antinuke:isInvalid() then
            self.antiNukeSilos:remove(antinuke)
        end
    end

    for xp in self.exps:iterator() do
        if xp:isInvalid() then
            self.exps:remove(xp)
            self:getExpsTypeList(xp:getName()):remove(xp)
        end
    end
end

function ArmyManager:updateSpecials()
    self:safetyCheck()

    for nuke in self.nukeSilos:iterator() do
        nuke:update()
    end

    for antinuke in self.antiNukeSilos:iterator() do
        antinuke:update()
    end

    for xp in self.exps:iterator() do
        xp:update()
    end
end

function ArmyManager:clearAllSpecials()
    self.nukeSilos:clear()
    self.antiNukeSilos:clear()
    self.exps:clear()
    for k,v in self.expsPerType do
        self.expsPerType[k] = nil
    end
end

function ArmyManager:getExpsTypeList(_name)
    if not self.expsPerType[_name] then
        self.expsPerType[_name] = LinkedTable:new()
    end
    return self.expsPerType[_name]
end

function ArmyManager:getExpsLists()
    return self.expsPerType
end

function ArmyManager:getNukes()
    return self.nukeSilos
end

function ArmyManager:getAntiNukes()
    return self.antiNukeSilos
end

function ArmyManager:sendChatAllies(_text)
    if SessionIsReplay() then
        return
    end
    local from = GetArmyData(GetFocusArmy()).nickname -- ScoresCache[GetFocusArmy()].name
    SessionSendChatMessage(FindClients(), { from = from,
                    to = 'allies', Chat = true, text = _text })
end

function ArmyManager:new()
   local o = {}
   setmetatable(o,self)
   self.__index = self

    o.nukeSilos = LinkedTable:new()
    o.antiNukeSilos = LinkedTable:new()
    o.exps = LinkedTable:new()
    o.expsPerType = {}

    o.myUnitsSize = 0
    o.syncUnitsSize = 0

    o.currentArmy = 0

    o.canCountMS = true
    o.gameSecondsRounded = 0

    o.onArmyChangedCallbacks = {}

    o.econData = {
        mass = {
            rate = 0,
            stored = 0,
        },
        energy = {
            rate = 0,
            stored = 0,
        }
    }

   GetUnitManager():addOnAddedCallback(o.onUnitAdded, o)
   GetUnitManager():addOnRemovedCallback(o.onUnitRemoved, o)
   return o
end

local instance

function GetArmyManager()
   if not instance then
      instance = ArmyManager:new()
   end
   return instance
end