local next = next
local tableGetN = table.getn
local tableInsert = table.insert
local unpack = unpack
local GetMouseWorldPos = GetMouseWorldPos
local VDist3 = VDist3

local function AveragePositionOfUnits(units)
    local unitCount = tableGetN(units)

    local px = 0
    local py = 0
    local pz = 0
    for k = 1, unitCount do
        local ux, uy, uz = unpack(units[k]:GetPosition())
        px = px + ux
        py = py + uy
        pz = pz + uz
    end

    px = px / unitCount
    py = py / unitCount
    pz = pz / unitCount

    return {
        px,
        py,
        pz
    }

end

--- Get the weapon "damage spread", which is how much the weapon's damage spreads out depending on the distance to target
---@param weapon WeaponBlueprint
---@param dist number distance between unit and target
---@return number
local function GetWeaponDamageSpread(weapon, dist)
    local weaponMaxRadius = weapon.MaxRadius
    local weaponMinRadius = weapon.MinRadius
    if weaponMinRadius and dist < weaponMinRadius then
        dist = weaponMinRadius
    elseif weaponMaxRadius and dist > weaponMaxRadius then
        dist = weaponMaxRadius
    end
    return (weapon.DamageRadius or 0) + (weapon.FixedSpreadRadius or (weapon.FiringRandomness or 0) / 10 * dist)
end

local maxSpreadWeaponCached

local GetMaxDamageSpread
--- Init version of the function. Checks data format and then replaces itself with the appropriate version and returns its output.
---@param unitsToWeapons table<UnitId, WeaponBlueprint[] | false> | table<UnitId, WeaponBlueprint | false>
---@return number
GetMaxDamageSpread = function(unitsToWeapons)
    -- data structure after https://github.com/FAForever/fa/pull/6028
    if not next(unitsToWeapons).MaxRadius then
        --- Get the maximum damage spread from multiple weapons, and cache the max spread weapon
        ---@param unitsToWeapons table<UnitId, WeaponBlueprint[] | false>
        ---@return number
        GetMaxDamageSpread = function(unitsToWeapons)
            -- cache for performance
            local distance = VDist3(AveragePositionOfUnits(GetSelectedUnits()), GetMouseWorldPos())

            local maxRadius
            local newRad
            for _, weapons in unitsToWeapons do
                if weapons then
                    for _, w in weapons do
                        newRad = GetWeaponDamageSpread(w, distance)
                        if newRad > maxRadius then
                            maxRadius = newRad
                            maxSpreadWeaponCached = w
                        end
                    end
                end
            end
            return maxRadius
        end
    else -- data structure before PR #6028
        ---@param unitsToWeapons table<UnitId, WeaponBlueprint | false>
        ---@return number
        GetMaxDamageSpread = function(unitsToWeapons)
            -- cache for performance
            local distance = VDist3(AveragePositionOfUnits(GetSelectedUnits()), GetMouseWorldPos())

            local maxRadius
            local newRad
            for _, w in unitsToWeapons do
                if w then
                    newRad = GetWeaponDamageSpread(w, distance)
                    if newRad > maxRadius then
                        maxRadius = newRad
                        maxSpreadWeaponCached = w
                    end
                end
            end
            return maxRadius
        end
    end
    return GetMaxDamageSpread(unitsToWeapons)
end

local function RadiusDecalScaleUpdate()
    return GetWeaponDamageSpread(maxSpreadWeaponCached,
        VDist3(AveragePositionOfUnits(GetSelectedUnits()), GetMouseWorldPos())) * 2
end

--- A generic decal texture / size computation function that uses the damage and spread radius
---@param predicate function<WeaponBlueprint[]>
---@return WorldViewDecalData[]
RadiusDecalFunction = function(predicate)
    local unitsToWeapons = GetSelectedWeaponsWithReticules(predicate)

    local maxRadius = GetMaxDamageSpread(unitsToWeapons)
    if maxRadius > 0 then
        local damageRadius = maxSpreadWeaponCached.DamageRadius
        local decalData = {}
        if damageRadius > 0 then
            decalData = {
                { --Damage radius display
                    texture = "/textures/ui/common/game/AreaTargetDecal/weapon_icon_small.dds",
                    scale = damageRadius * 2
                }
            }
        end
        if damageRadius ~= maxRadius then
            tableInsert(decalData,
                { --Inaccuracy display
                    texture = "/textures/ui/common/game/AreaTargetDecal/nuke_icon_inner.dds",
                    scaleUpdateFunction = RadiusDecalScaleUpdate
                }
            )
        end

        return decalData
    end

    return false
end

local oldWorldView = WorldView

WorldView = Class(oldWorldView) {

    --- Manages the decals of a cursor event
    ---@param self WorldView
    ---@param identifier CommandCap
    ---@param enabled boolean
    ---@param changed boolean
    ---@param getDecalsBasedOnSelection function # See the radial decal functions
    OnCursorDecals = function(self, identifier, enabled, changed, getDecalsBasedOnSelection)
        if enabled then
            if changed then

                -- prepare decals based on the selection
                local data = getDecalsBasedOnSelection()
                if data then
                    -- clear out old decals, if they exist
                    self.CursorDecalTrash:Destroy();
                    for k, instance in data do
                        local decal = UserDecal()
                        decal:SetTexture(instance.texture)

                        local scaleUpdate = instance.scaleUpdateFunction
                        if scaleUpdate then
                            decal.scaleUpdate = scaleUpdate
                        else
                            local scale = instance.scale
                            decal:SetScale({ scale, 1, scale })
                        end

                        self.CursorDecalTrash:Add(decal);
                        self.Trash:Add(decal)
                    end
                end
            end

            -- update their scale and then locations
            for k, decal in self.CursorDecalTrash do
                if decal.scaleUpdate then
                    local scale = decal.scaleUpdate()
                    decal:SetScale({ scale, 1, scale })
                end
                decal:SetPosition(GetMouseWorldPos())
            end
        else
            -- command ended, destroy the current decals to make room for new decals
            self.CursorDecalTrash:Destroy();
        end
    end,

}
