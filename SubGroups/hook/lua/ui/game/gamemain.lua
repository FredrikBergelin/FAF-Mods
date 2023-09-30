local oldOnSelectionChanged = OnSelectionChanged

local isHiddenSelect = import("/lua/ui/game/selection.lua").IsHidden
local GetHiddenSelect = import("/mods/UMT/modules/select.lua").GetHiddenSelect

local SetLayerSplit = import('/mods/SubGroups/modules/selection.lua').SetLayerSplit

function OnSelectionChanged(oldSelection, newSelection, added, removed)
    if not isHiddenSelect() and not GetHiddenSelect() then
        if newSelection and table.getn(newSelection) > 0 then
            SetLayerSplit(true)
        end
    end
    oldOnSelectionChanged(oldSelection, newSelection, added, removed)
end

local KeyMapper = import('/lua/keymap/keymapper.lua')

local displayOrder = 999
function getDisplayOrder()
    displayOrder = displayOrder + 1
    return displayOrder
end

local categoryName = 'Extended Subgroups'

KeyMapper.SetUserKeyAction('split_next', {
    action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitNext()',
    category = categoryName,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction('split_mouse_axis_orthogonal', {
    action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitMouseOrthogonalAxis()',
    category = categoryName,
    order = getDisplayOrder()
})

-- KeyMapper.SetUserKeyAction('NAME', {
--     action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").FUNCTION()',
--     category = categoryName,
--     order = getDisplayOrder()
-- })

--     },
--     ['split_major_axis'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitMajorAxis()',
--         category = 'selectionSubgroups',
--     },
--     ['split_minor_axis'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitMinorAxis()',
--         category = 'selectionSubgroups',
--     },
--     ['split_mouse_axis'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitMouseAxis()',
--         category = 'selectionSubgroups',
--     },

--     ['split_engineer_tech'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitEngineerTech()',
--         category = 'selectionSubgroups',
--     },
--     ['split_tech'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitTech()',
--         category = 'selectionSubgroups',
--     },
--     ['split_layer'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitLayer()',
--         category = 'selectionSubgroups',
--     },
--     ['split_into_groups_1'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(1)',
--         category = 'selectionSubgroups',
--     },
--     ['split_into_groups_2'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(2)',
--         category = 'selectionSubgroups',
--     },
--     ['split_into_groups_4'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(4)',
--         category = 'selectionSubgroups',
--     },
--     ['split_into_groups_8'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(8)',
--         category = 'selectionSubgroups',
--     },
--     ['split_into_groups_16'] = {
--         action = 'UI_Lua import("/mods/SubGroups/modules/selection.lua").SplitIntoGroups(16)',
--         category = 'selectionSubgroups',
--     },
-- }