local modFolder = 'McBoomsMod'

local GetArmyManager = import('/mods/' .. modFolder .. '/modules/army/ArmyManager.lua').GetArmyManager
local BaseUnitObject = import('/mods/' .. modFolder .. '/modules/army/BaseUnitObject.lua').BaseUnitObject

-- Mex object
local table_getsize = table.getsize

Mex = BaseUnitObject:inherit("Mex")

function Mex:getAssistees()
   return self.assistees
end

function Mex:addAssistee(_unit)
   if not self.assistees[_unit:GetEntityId()] then
      --print("add assistee success")
      self.assistees[_unit:GetEntityId()] = _unit
   end
end

function Mex:resetAssistees()
   for entityid, unit in self.assistees do
      self.assistees[entityid] = nil
   end
end

function Mex:getTech()
   return self.category
end

function Mex:getTechLevel()
   return self.techLevel
end

function Mex:isUpgrading()
   return self.unit:GetFocus() and EntityCategoryContains(categories.MASSEXTRACTION, self.unit:GetFocus())
end

function Mex:getStorageBuff()
   if self.category == categories.TECH1 then
      return 0.25
   elseif self.category == categories.TECH2 then
      return 0.75
   elseif self.category == categories.TECH3 then
      return 2.25
   end
end

function Mex:getBpMassPerSec()
   local bp = self.unit:GetBlueprint()
   if bp.Economy and bp.Economy.ProductionPerSecondMass then
      return bp.Economy.ProductionPerSecondMass
   end
   return 0
end

--todo this function fails due to inconsistency in econdata between ticks
--todo some ticks the massProduced can be 3-4 times what the extractor can actually produce
function Mex:calculateNumStoragesTryout()
   --determine the surrounding storages
   local e = self.unit:GetEconData()
   local base = self:getBpMassPerSec()
   local buffBase = self:getStorageBuff()

   local max = base+(buffBase*4)
   if e.massProduced>max then
      return
   end
   --print("Base = "..tostring(base)..", buff = "..tostring(buffBase))
   --import('/mods/' .. modFolder .. '/modules/util/Util.lua').PrintTable(e, "--- Econ ---", "")

   --if e.massProduced <= base then
   --   self.numStorages = 0
   if self.numStorages<=3 and e.massProduced >= (base+(buffBase*4))-0.05 then
      self.numStorages = 4
      print("Base = "..tostring(base)..", buff = "..tostring(buffBase))
      import('/mods/' .. modFolder .. '/modules/util/Util.lua').PrintTable(e, "--- Econ ---", "")
   elseif self.numStorages<=2 and e.massProduced >= (base+(buffBase*3))-0.05 then
      self.numStorages = 3
   elseif self.numStorages<=1 and e.massProduced >= (base+(buffBase*2))-0.05 then
      self.numStorages = 2
   elseif self.numStorages<=0 and e.massProduced >= (base+(buffBase*1))-0.05 then
      self.numStorages = 1
   end
end

function Mex:calculateNumStorages()
   --determine the surrounding storages
   if self.armyManager:isCanCountMS() then
      local e = self.unit:GetEconData()
      local ratio = e.energyRequested>0 and (e.energyConsumed/e.energyRequested) or 1.0
      local base = self:getBpMassPerSec()
      local buffBase = self:getStorageBuff()

      local max = (base+(buffBase*4)) * ratio
      if e.massProduced>max then
         return
      end

      if e.massProduced <= base * ratio then
         self.numStorages = 0
      elseif e.massProduced <= (base+(buffBase*1)) * ratio then
         self.numStorages = 1
      elseif e.massProduced <= (base+(buffBase*2)) * ratio then
         self.numStorages = 2
      elseif e.massProduced <= (base+(buffBase*3)) * ratio then
         self.numStorages = 3
      elseif e.massProduced <= (base+(buffBase*4)) * ratio then
         self.numStorages = 4
      end
   end
end

function Mex:GetNumStorages()
   return self.numStorages
end

function Mex:calculateBp()
   self.totalBuildPower = (not self:getIsPaused()) and self.unit:GetBuildRate() or 0

   if table_getsize(self.assistees)>0 then
       for uid,ass_unit in self.assistees do
           self.totalBuildPower = self.totalBuildPower + ass_unit:GetBuildRate()
           --print("assistee bp = "..tostring(ass_unit:GetBuildRate()))
       end
   end
end

function Mex:getTotalBp()
   return self.totalBuildPower
end

function Mex:update()
   BaseUnitObject.update(self)

   self:calculateNumStorages()
   self:calculateBp()
end

function Mex:getHomeDistance()
   return self.homeDistance
end

function Mex:setHomeDistance(_dist)
   self.homeDistance = _dist
end

function Mex:getLastMexDistance()
   return self.lastMexDistance
end

function Mex:setLastMexDistance(_dist)
   self.lastMexDistance = _dist
end

function Mex:debugPrint()
   print("["..tostring(self.entityID).."] P = "..tostring(self.isPaused)..", TECH = "..tostring(self.techLevel)..", HD = "..string.format("%+d",self.homeDistance or -1)..", LMD = "..string.format("%+d", self.lastMexDistance or -1))
end

function Mex:new(_unit)
   local o = BaseUnitObject:new(_unit)
   setmetatable(o,self)
   self.__index = self

   o.assistees = {}
   o.category = categories.TECH1
   o.techLevel = 1
   o.totalBuildPower = 0
   o.numStorages = 0
   o.armyManager = GetArmyManager()
   o.homeDistance = false
   o.lastMexDistance = false

   if EntityCategoryContains(categories.TECH1, o.unit) then
      o.category = categories.TECH1;
      o.techLevel = 1
   elseif EntityCategoryContains(categories.TECH2, o.unit) then
      o.category = categories.TECH2;
      o.techLevel = 2
   elseif EntityCategoryContains(categories.TECH3, o.unit) then
      o.category = categories.TECH3;
      o.techLevel = 3
   else
      print("Mex tech unclassified")
   end

   return o
end

function CreateMex(_unit)
   return Mex:new(_unit)
end
