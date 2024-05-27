local GetGameTimeSeconds = GetGameTimeSeconds

local modFolder = 'McBoomsMod'

local BaseClass = import('/mods/' .. modFolder .. '/modules/BaseClass.lua').BaseClass
local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')

local naturalIdCounter = 0
local function getNaturalID()
   naturalIdCounter = naturalIdCounter + 1
   return naturalIdCounter
end

BaseUnitObject = BaseClass:inherit("BaseUnitObject")

function BaseUnitObject:getUnit()
   return self.unit
end

function BaseUnitObject:GetEntityId()
   return self.entityID
end

function BaseUnitObject:IsDead()
   return self.unit:IsDead()
end

function BaseUnitObject:GetFocus()
   return self.unit:GetFocus()
end

function BaseUnitObject:GetPosition()
   return self.unit:GetPosition()
end

function BaseUnitObject:GetBlueprint()
   return self.unit:GetBlueprint()
end

function BaseUnitObject:GetBuildRate()
   return self.unit:GetBuildRate()
end

function BaseUnitObject:isUnderConstruction()
   local e = self.unit:GetEconData()
   return e.energyRequested <=0
end

function BaseUnitObject:setIsPaused(_paused)
    if self.isPaused ~= _paused then
        self.isPaused = _paused
        SetPaused( self.unitTable, self.isPaused )
        self.pauseSetTicks = 10
    end
end

function BaseUnitObject:getIsPaused()
    return self.isPaused
end

function BaseUnitObject:setIsSelected(_b)
    self.isSelected = _b
end

function BaseUnitObject:getIsSelected()
    return self.isSelected
end

function BaseUnitObject:getNaturalID()
   return self.naturalID
end

function BaseUnitObject:getWorkProgress()
    return self.unit:GetWorkProgress()
end

function BaseUnitObject:getHpRatio()
    return self.unit:GetMaxHealth() > 0 and self.unit:GetHealth()/self.unit:GetMaxHealth() or 0
end

function BaseUnitObject:getName()
    return self.name
end

function BaseUnitObject:isInvalid()
   return (not self.unit) or (self.unit:IsDead()) or (not self.unit.GetEntityId)
end

function BaseUnitObject:update()
    if self.pauseSetTicks>0 then
        self.pauseSetTicks = self.pauseSetTicks - 1
    else
       self.isPaused = GetIsPaused( self.unitTable )
    end
    self:setIsSelected( Util.IsSelected( self.unit ) )
end

function BaseUnitObject:new(_unit, _ignorePause)
    local o = BaseClass:new()
    setmetatable(o,self)
    self.__index = self

    o.unit = _unit
    o.entityID = _unit:GetEntityId()
    o.unitTable = { _unit }
    o.naturalID = getNaturalID()
    o.beenBuild = false
    o.ignorePause = _ignorePause or false
    o.isPaused = ((not o.ignorePause) and GetIsPaused( o.unitTable )) or false
    o.isSelected = false
    o.bp = _unit:GetBlueprint()
    o.name = (o.bp and o.bp.General and o.bp.General.UnitName) or (o.bp and o.bp.Description) or "UNKNOWN"
    o.pauseSetTicks = 0

    return o
end