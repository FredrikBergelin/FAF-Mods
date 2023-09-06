local oldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
    import('/mods/CommandCycler/modules/Main.lua').SelectionChanged(oldSelection, newSelection, added, removed)
    oldOnSelectionChanged(oldSelection, newSelection, added, removed)
end

do
    local OldCreateUI = CreateUI
    function CreateUI(isReplay)
        OldCreateUI(isReplay)
        import('/mods/CommandCycler/modules/Main.lua').Main(isReplay)
    end
end
