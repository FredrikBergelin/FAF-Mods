-- tLOG = import('/mods/common/modules/tools.lua').tLOG

function tLOG(this, key, indentLevel)
    if not indentLevel then indentLevel = 0 end

    local indent = string.rep('-   ', indentLevel)
    local first = indent .. tostring(key) .. ': '

    if type(this) == 'nil' then
        LOG(first .. 'nil')
        return
    elseif type(this) == 'string' then
        LOG(first .. '"' .. this .. '"')
        return
    elseif type(this) == 'boolean' then
        LOG(first .. tostring(this))
    elseif type(this) == 'function' then
        LOG(first .. 'function')
    elseif type(this) == 'table' then
        LOG(first .. "{")
        for key, value in this do
            tLOG(value, key, indentLevel + 1)
        end
        LOG(indent .. "}")
    end
end
