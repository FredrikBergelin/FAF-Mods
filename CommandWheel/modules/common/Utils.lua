local Mods = import('/lua/mods.lua')

function GetAngleCenter(angle1, angle2)
    local angleMiddle

    if angle1 > angle2 then
        angleMiddle = angle1 + (angle2 + (360 - angle1)) / 2
        if angleMiddle > 360 then
            angleMiddle = angleMiddle - 360
        end
    else
        angleMiddle = (angle1 + angle2) / 2
    end

    return angleMiddle
end

function GetRelativeSize(value, width, height)
    if not value then
        return nil
    end

    if value >= 1 then
        return math.floor(value)
    end

    if width and width > 1 and height and height > 1 then
        local base = math.min(width, height)
        return math.floor(math.abs(value * base))
    end

    return nil
end

function GetPointAngle(x1, y1, x2, y2)
    local pointAngle = math.deg(math.atan2(y2 - y1, x2 - x1))
    if pointAngle < 0 then
        pointAngle = 360 + pointAngle
    end

    return pointAngle
end

function AsMatrix(tableObj)
    if table.getn(tableObj) == 0 then
        return {tableObj}
    else
        return tableObj
    end
end

function IsNonEmptyArray(value)
    return value and type(value) == 'table' and table.getn(value) >= 1
end

function IsModInstalled(name, location, uid)
    if name == nil and location == nil and uid == nil then
        return false
    end

    for _, mod in Mods.GetUiMods() do
        if (name == nil or mod.name == name)
                and (location == nil or mod.location == location)
                and (uid == nil or mod.uid == uid) then
            return true
        end
    end

    return false
end