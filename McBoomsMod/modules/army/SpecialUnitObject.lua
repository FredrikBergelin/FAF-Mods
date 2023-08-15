local GetGameTimeSeconds = GetGameTimeSeconds

local modFolder = 'McBoomsMod'

local ProgressETA = import('/mods/' .. modFolder .. '/modules/util/ProgressETA.lua').ProgressETA
local BaseUnitObject = import('/mods/' .. modFolder .. '/modules/army/BaseUnitObject.lua').BaseUnitObject

SpecialUnitType = {
    NUKE = 1,
    ANTINUKE = 2,
    EXPERIMENTAL = 3,
}

local table_getsize = table.getsize

SpecialUnitObject = BaseUnitObject:inherit("SpecialUnitObject")

function SpecialUnitObject:update()
    BaseUnitObject.update(self)

    if self.unitType==SpecialUnitType.NUKE or self.unitType==SpecialUnitType.ANTINUKE then
        local missile_info = self.unit:GetMissileInfo()
        self.storedMissiles = missile_info.nukeSiloStorageCount + missile_info.tacticalSiloStorageCount
    end

    --self:setIsPaused( GetIsPaused( self.unitTable ) )

    --if self.unitType==SpecialUnitType.NUKE or self.unitType==SpecialUnitType.ANTINUKE then
        --self.eta:update(self.unit:GetWorkProgress())
    --else
        -- todo this will not work well for loaded saved games
        if not self.beenBuild then --todo when the unit has workprogress we should set it to beenbuild=true
            self.eta:update(self:getHpRatio())
            if self:getHpRatio()>=1 then
                self.beenBuild = true
            end
        else
            self.eta:update(self.unit:GetWorkProgress())
        end
    --end
end

function SpecialUnitObject:getEtaString()
    return self.eta:getEtaString()
end

function SpecialUnitObject:getEtaSeconds()
    return self.eta:getEta()
end

function SpecialUnitObject:isHasEta()
    return self.eta:isHasEta()
end

function SpecialUnitObject:getStoredMissiles()
    return self.storedMissiles
end

function SpecialUnitObject:GetUnitType()
   return self.unitType
end

function SpecialUnitObject:IsMissileSilo()
   return self.unitType==SpecialUnitType.NUKE or self.unitType==SpecialUnitType.ANTINUKE
end

function SpecialUnitObject:new(_unit, _type)
    local o = BaseUnitObject:new(_unit)
    setmetatable(o,self)
    self.__index = self

    o.unitType = _type
    o.storedMissiles = 0
    o.eta = ProgressETA:new(_unit:GetWorkProgress())
    o.beenBuild = false
   return o
end

function CreateSpecialUnitObject(_unit, _type)
    return SpecialUnitObject(_unit, _type)
end