function HasOmni(blueprint)
    return blueprint.Intel.OmniRadius and blueprint.Intel.OmniRadius > 0
end

function GetOmniRange(blueprint)
    return blueprint.Intel.OmniRadius
end

function HasRadar(blueprint)
    return blueprint.Intel.RadarRadius and blueprint.Intel.RadarRadius
end

function GetRadarRange(blueprint)
    return blueprint.Intel.RadarRadius
end

function HasShield(blueprint)
    return blueprint.Defense and blueprint.Defense.Shield and blueprint.Defense.Shield.ShieldSize and blueprint.Defense.Shield.ShieldSize > 0
end

function GetShieldRadius(blueprint)
    return blueprint.Defense.Shield.ShieldSize / 2
end

function HasWeapon(blueprint)
    return blueprint.Weapon and type(blueprint.Weapon) =='table' and table.getn(blueprint.Weapon) > 0
end

function GetLongestRangeWeapon(blueprint)
    local range = 0

    for _, weapon in blueprint.Weapon do
        if weapon.MaxRadius and weapon.MaxRadius <= 4000 then
            range = math.max(range, weapon.MaxRadius)
        end
    end

    return range
end


function GetShortestRangeWeapon(blueprint)
    local range = 4000

    for _, weapon in blueprint.Weapon do
        if weapon.MaxRadius and weapon.MaxRadius <= 4000 and weapon.MaxRadius > 0 then
            range = math.min(range, weapon.MaxRadius)
        end
    end

    return range
end