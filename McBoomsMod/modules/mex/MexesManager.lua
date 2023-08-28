local Utilities = import('/lua/utilities.lua')

local modFolder = 'McBoomsMod'

CreateMex = import('/mods/' .. modFolder .. '/modules/mex/Mex.lua').CreateMex
local LinkedTable = import('/mods/' .. modFolder .. '/modules/util/LinkedTable.lua').LinkedTable
local MexSort = import('/mods/' .. modFolder .. '/modules/mex/MexSort.lua')
local GetUnitManager = import('/mods/' .. modFolder .. '/modules/UnitManager.lua').GetUnitManager

local table_insert = table.insert
-- Mexes Manager object

local function containsUnitFunc(_mex, _entityID)
   return _mex.entityID==_entityID
end

local function containsUnit(_linkedTable, _entityID)
   for mex in _linkedTable:iterator() do
      if mex.entityID==_entityID then
         return true
      end
   end
   return false
end

local function triggerCallbacks(_callbacks, _unit)
    for _,elem in _callbacks do
        if elem.table then
            elem.callback(elem.table, _unit)
        else
            elem.callback(_unit)
        end
    end
end

MexesManager = {}

function MexesManager:isMexUnitBuilding(_unit)
   local e = _unit:GetEconData()
   return e.energyRequested <=0
end

function MexesManager:onUnitAdded(_unit)
   if not self:addMexUnit(_unit) then
      self:addEngineerUnit(_unit)
   end
end

function MexesManager:onUnitRemoved(_unit)
   self:removeEngineer(_unit)
   self:removeMexUnit(_unit)
   self.building_mexes:remove(_unit)
end

function MexesManager:addMexUnit(_unit)
   --check if unit exists else add it.
   if _unit:IsDead() or (not EntityCategoryContains(categories.MASSEXTRACTION, _unit)) then
      return false
   end

   if self:isMexUnitBuilding(_unit) then
      if not self.building_mexes:contains(_unit) then
         self.building_mexes:add(_unit)
         return true
      end
   end

   --if not containsUnit(self.all_mexes, _unit:GetEntityId()) then
   if not self.all_mexes:containsFunc(containsUnitFunc, _unit:GetEntityId()) then
      --print("adding new mex "..tostring(_unit:GetEntityId()))
      local mex = CreateMex(_unit);
      self.all_mexes:add(mex)
      if mex:isUpgrading() then
         self.mex_per_cat[mex:getTech()].upgrading:add(mex)
      else
         self.mex_per_cat[mex:getTech()].normal:add(mex)
      end
      self:updateHome(_unit)
      self:updateMexHomeDistance(mex)
      triggerCallbacks(self.onMexAddedCallbacks, mex)
      --self:updateHome(_unit)
      return true
   end
end

function MexesManager:removeMexUnit(_unit)
   for mex in self.all_mexes:iterator() do
      if mex:getUnit()==_unit then
         self:removeMexObject(mex)
      end
   end
end

function MexesManager:removeMexObject(_mex)
   self.all_mexes:remove(_mex)
   for i=1,3 do
      local mexcat = self.mex_per_cat[self.cat_indexed[i]]
      mexcat.normal:remove(_mex)
      mexcat.upgrading:remove(_mex)
   end
   triggerCallbacks(self.onMexRemovedCallbacks, _mex)
end

function MexesManager:addEngineerUnit(_unit)
   if _unit:IsDead() or (not EntityCategoryContains(categories.ENGINEER, _unit)) then
      return
   end

   if not self.all_engineers:contains(_unit) then
      self.all_engineers:add(_unit)
   end
end

function MexesManager:removeEngineer(_unit)
   self.all_engineers:remove(_unit)
end

function MexesManager:checkAssistee(_unit)
   if _unit:IsDead() or (not EntityCategoryContains(categories.ENGINEER, _unit)) then
      return
   end

   --print("check assistee, focus = "..tostring(_unit:GetFocus() and _unit:GetFocus():GetEntityId() or "none"))
   if _unit:GetFocus() and (not _unit:GetFocus():IsDead()) then
      for mex in self.all_mexes:iterator() do
         if (not mex:isInvalid()) and mex:getUnit():GetFocus() and mex:getUnit():GetFocus():GetEntityId()==_unit:GetFocus():GetEntityId() then
            mex:addAssistee(_unit)
         end
      end
   end
end

function MexesManager:resetAssistees()
   for mex in self.all_mexes:iterator() do
      mex:resetAssistees()
   end
end

function MexesManager:safetyCheck()
   for unit in self.building_mexes:iterator() do
      if unit:IsDead() then
         self.building_mexes:remove(unit)
      end
   end
   for mex in self.all_mexes:iterator() do
      if mex:isInvalid() then
         self:removeMexObject(mex)
      end
   end
end

function MexesManager:getHomePosition()
   return self.homePosition
end

function MexesManager:updateHome(_unit)
   if not self.homePosition and not _unit:IsDead() then
      self.homePosition = _unit:GetPosition()
   end
end

function MexesManager:updateMexHomeDistance(_mex)
   if self.homePosition and not _mex:getHomeDistance() then
      _mex:setHomeDistance( Utilities.XZDistanceTwoVectors(self.homePosition, _mex:getUnit():GetPosition()) )
   end
end

function MexesManager:update()
   -- this prevents possible 'Game object has been destroyed' error when the game is closed
   self:safetyCheck()

   self:resetAssistees()

   for unit in self.building_mexes:iterator() do
      if not self:isMexUnitBuilding(unit) then
         self.building_mexes:remove(unit)
         self:addMexUnit(unit)
      end
   end

   for engineer in self.all_engineers:iterator() do
      if engineer:IsDead() then
         self:removeEngineer(engineer)
      else
         self:checkAssistee(engineer)
      end
   end

   for i=1,3 do
      local mexcat = self.mex_per_cat[self.cat_indexed[i]]

      for mex in mexcat.upgrading:iterator() do
         -- check paused and bp
         mex:update()
         self:updateMexHomeDistance(mex)
      end

      for mex in mexcat.normal:iterator() do
         mex:update()
         self:updateMexHomeDistance(mex)
         if mex:isUpgrading() then
            mexcat.normal:remove(mex)
            if not mexcat.upgrading:contains(mex) then
               mexcat.upgrading:add(mex)
            end
         end
      end

      --sort the lists
      if self.performSorting then
         --sorts on most suitable mex (todo: this may cause shifting when energy is low)
         mexcat.normal:sort()
         mexcat.upgrading:sort()
      else
         --we sort the list on natural ID, making sure first added/build are first in any row they are in
         mexcat.normal:sort(MexSort.MexSortNaturalID)
         mexcat.upgrading:sort(MexSort.MexSortNaturalID)
      end
   end
end

function MexesManager:hasMexesToUpgrade()
   return self.mex_per_cat[categories.TECH1].normal:count() > 0 or self.mex_per_cat[categories.TECH2].normal:count() > 0 or
            self.mex_per_cat[categories.TECH1].upgrading:count() > 0 or self.mex_per_cat[categories.TECH2].upgrading:count() > 0
end

function MexesManager:getCountTech(_tech)
   return self.mex_per_cat[_tech]:count()
end

function MexesManager:getCatFromIndex(_i)
   return self.cat_indexed[_i]
end

function MexesManager:getMexesForTech(_tech)
   return self.mex_per_cat[_tech]
end

function MexesManager:setPerformSorting(_b)
   self.performSorting = _b
end

function MexesManager:getPerformSorting()
   return self.performSorting
end

function MexesManager:getAllMexes()
   return self.all_mexes
end

function MexesManager:getAllEngineers()
   return self.all_engineers
end

function MexesManager:printDebug()
    print(":: MexesManager")
    print("   all_engineers: "..tostring( self.all_engineers:count() ))
    print("   building_mexes: "..tostring( self.building_mexes:count() ))
    print("   all_mexes: "..tostring( self.all_mexes:count() ))
end

function MexesManager:clearAll()
   self.all_engineers:clear()
   self.building_mexes:clear()
   self.all_mexes:clear()
   for i=1,3 do
      local mexcat = self.mex_per_cat[self.cat_indexed[i]]
      mexcat.normal:clear()
      mexcat.upgrading:clear()
   end
end

function MexesManager:addOnMexAddedCallback(_cb, _table)
    table_insert(self.onMexAddedCallbacks, {
        callback = _cb,
        table = _table
    })
end

function MexesManager:addOnMexRemovedCallback(_cb, _table)
    table_insert(self.onMexRemovedCallbacks, {
        callback = _cb,
        table = _table
    })
end

function MexesManager:new()
   local o = {}
   setmetatable(o,self)
   self.__index = self
   o.performSorting = false
   o.all_engineers = LinkedTable:new()
   o.building_mexes = LinkedTable:new()
   o.all_mexes = LinkedTable:new()
   o.all_mexes.sort_func = MexSort.MexSortNormal
   o.cat_indexed = {}
   o.cat_indexed[1] = categories.TECH1
   o.cat_indexed[2] = categories.TECH2
   o.cat_indexed[3] = categories.TECH3
   o.mex_per_cat = {}
   o.homePosition = false

   o.onMexAddedCallbacks = {}
   o.onMexRemovedCallbacks = {}

   for i=1,3 do
      o.mex_per_cat[o.cat_indexed[i]] = {
         normal = LinkedTable:new(),
         upgrading = LinkedTable:new()
      }
      o.mex_per_cat[o.cat_indexed[i]].normal.sort_func = MexSort.MexSortNormal
      o.mex_per_cat[o.cat_indexed[i]].upgrading.sort_func = MexSort.MexSortUpgrading
   end

   GetUnitManager():addOnAddedCallback(o.onUnitAdded, o)
   GetUnitManager():addOnRemovedCallback(o.onUnitRemoved, o)
   return o
end

local instance

function GetMexesManager()
   if not instance then
      instance = MexesManager:new()
   end
   return instance
end