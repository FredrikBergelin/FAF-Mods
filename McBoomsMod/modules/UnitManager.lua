local GetFocusArmy = GetFocusArmy
local GameTick = GameTick

local modFolder = 'McBoomsMod'

local Select = import('/mods/' .. modFolder .. '/modules/util/Selection.lua')
local LinkedTable = import('/mods/' .. modFolder .. '/modules/util/LinkedTable.lua').LinkedTable
local IndexedTable = import('/mods/' .. modFolder .. '/modules/util/IndexedTable.lua').IndexedTable

local selectionUpdateTicks = 120
local lastSelectionUpdateTick = 0

local lastFocusedArmy = 0

local instance = false

local update_units = {}
local all_units = LinkedTable:new()
local focus_list = IndexedTable:new()

local table_insert = table.insert
local table_getsize = table.getsize

local function OnUpdateUnitsBySelection()
    update_units = {}

    UISelectionByCategory("ALLUNITS", false, false, false, false)
    for _, unit in GetSelectedUnits() or {} do
        update_units[unit:GetEntityId()] = unit
    end
end

local function UpdateUnitsBySelection()
    --print("Updating units by selection")
    Select.Hidden(OnUpdateUnitsBySelection)
end

local function UpdateUnitsByHierarchy(_parseFocus)
    for _, unit in (GetSelectedUnits() or {}) do
		update_units[unit:GetEntityId()] = unit
	end

	--add new units/buildings
    if _parseFocus then
        for _, unit in update_units do
            if not unit:IsDead() and unit:GetFocus() and not unit:GetFocus():IsDead() then
                update_units[unit:GetFocus():GetEntityId()] = unit:GetFocus()
            end
        end
    end
end

local function RequiresSelectionUpdate(_self, _tick)
    if _self.forceSelectionUpdate or GetFocusArmy() ~= lastFocusedArmy or _tick - selectionUpdateTicks > lastSelectionUpdateTick then
        lastFocusedArmy = GetFocusArmy()
        lastSelectionUpdateTick = _tick
        _self.forceSelectionUpdate = false
        return true
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

local function checkUnit(_self, _unit, _uuid)
    if _unit:IsDead() then
        update_units[_uuid] = nil
        if all_units:contains(_unit) then
            all_units:remove(_unit)
            triggerCallbacks(_self.onRemovedCallbacks, _unit)
        end
    else
        if not all_units:contains(_unit) then
            all_units:add(_unit)
            triggerCallbacks(_self.onAddedCallbacks, _unit)
        end
    end
end

UnitManager = {}

function UnitManager:reset()
    update_units = {}
    all_units:clear()
    focus_list:clear()
    self.forceSelectionUpdate = true
end

-- new update function requires less iteration over update_units
function UnitManager:update()
    self.currentTick = GameTick()

    if RequiresSelectionUpdate(self, self.currentTick) then
        UpdateUnitsBySelection()
    else
        UpdateUnitsByHierarchy(false)
    end

    focus_list:clear()

    for uuid, unit in update_units do
        checkUnit(self, unit, uuid)

        --check add new units/buildings
        if not unit:IsDead() and unit:GetFocus() and not unit:GetFocus():IsDead() then
            focus_list:add( unit:GetFocus() )
        end
    end

    if focus_list:count()>0 then
        for unit in focus_list:iterator() do
            checkUnit(self, unit, unit:GetEntityId() )
        end
    end
end

function UnitManager:addOnAddedCallback(_cb, _table)
    table_insert(self.onAddedCallbacks, {
        callback = _cb,
        table = _table
    })
end

function UnitManager:addOnRemovedCallback(_cb, _table)
    table_insert(self.onRemovedCallbacks, {
        callback = _cb,
        table = _table
    })
end

function UnitManager:getUnitCount()
    return all_units:count()
end

function UnitManager:printDebug()
    print(":: UnitManager")
    print("   update_units: "..tostring( table_getsize(update_units) ))
    print("   all_units: "..tostring( all_units:count() ))
end

function UnitManager:new()
    local o = {}
    setmetatable(o,self)
    self.__index = self

    o.currentTick = 0
    o.forceSelectionUpdate = false
    o.onAddedCallbacks = {}
    o.onRemovedCallbacks = {}

    return o
end

function GetUnitManager()
    if not instance then
        instance = UnitManager:new()
    end

    return instance
end

function ForcedUpdateUnits()
	GetUnitManager().forceSelectionUpdate = true
end