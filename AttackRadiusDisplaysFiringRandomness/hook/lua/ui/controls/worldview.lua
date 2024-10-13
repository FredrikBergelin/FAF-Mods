local function AveragePositionOfUnits(units)
    local unitCount = table.getn(units)

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
---@return number
local function GetWeaponDamageSpread(weapon)
    local dist = VDist3(AveragePositionOfUnits(GetSelectedUnits()), GetMouseWorldPos())
    local weaponMaxRadius = weapon.MaxRadius
    local weaponMinRadius = weapon.MinRadius
    if weaponMinRadius and dist < weaponMinRadius then
        dist = weaponMinRadius
    elseif weaponMaxRadius and dist > weaponMaxRadius then
        dist = weaponMaxRadius
    end
    return (weapon.DamageRadius or 0) + (weapon.FixedSpreadRadius or (weapon.FiringRandomness or 0) / 12 * dist)
end

local maxSpreadWeaponCached

--- Get the maximum damage spread from multiple weapons, and cache the max spread weapon
---@param weapons WeaponBlueprint[]
---@return number
local function GetMaxDamageSpread(weapons)
    local maxRadius = 0
    for _, w in weapons do
        newRad = GetWeaponDamageSpread(w)
        if newRad > maxRadius then
            maxRadius = newRad
            maxSpreadWeaponCached = w
        end
    end
    return maxRadius
end

local function RadiusDecalScaleUpdate()
    return GetWeaponDamageSpread(maxSpreadWeaponCached) * 2
end

--- A generic decal texture / size computation function that uses the damage and spread radius
---@param predicate function<WeaponBlueprint[]>
---@return WorldViewDecalData[]
local function RadiusDecalFunction(predicate)
    local unitsToWeapons = GetSelectedWeaponsWithReticules(predicate)

    -- The maximum damage radius of a selected missile weapon.
    local maxRadius = 0
    for _, weapons in unitsToWeapons do
        if weapons then
            for _, w in weapons do
                if w.FixedSpreadRadius and w.FixedSpreadRadius + w.DamageRadius > maxRadius then
                    maxRadius = w.FixedSpreadRadius + w.DamageRadius
                elseif w.DamageRadius > maxRadius then
                    maxRadius = w.DamageRadius
                end
            end
        end
    end

    if maxRadius > 0 then
        return {
            {
                texture = "/textures/ui/common/game/AreaTargetDecal/weapon_icon_small.dds",
                scale = maxRadius * 2
            }
        }
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
                        decal:SetScale({ instance.scale, 1, instance.scale })
                        self.CursorDecalTrash:Add(decal);
                        self.Trash:Add(decal)
                    end
                end
            end

            -- update their locations
            for k, decal in self.CursorDecalTrash do
                decal:SetPosition(GetMouseWorldPos())
            end
        else
            -- command ended, destroy the current decals to make room for new decals
            self.CursorDecalTrash:Destroy();
        end
    end,

}
