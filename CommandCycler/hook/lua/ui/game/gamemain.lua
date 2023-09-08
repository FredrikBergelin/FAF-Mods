local isHiddenSelect = import("/lua/ui/game/selection.lua").IsHidden
local GetHiddenSelect = import("/mods/UMT/modules/select.lua").GetHiddenSelect

local oldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
    if not isHiddenSelect() and not GetHiddenSelect() then
        import('/mods/CommandCycler/modules/Main.lua').SelectionChanged(oldSelection, newSelection, added, removed)
    end
    oldOnSelectionChanged(oldSelection, newSelection, added, removed)
end

do
    local OldCreateUI = CreateUI
    function CreateUI(isReplay)
        OldCreateUI(isReplay)
        import('/mods/CommandCycler/modules/Main.lua').Main(isReplay)
    end
end
