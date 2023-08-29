do
    local OldCreateUI = CreateUI
    function CreateUI(isReplay)

        OldCreateUI(isReplay)
        import('/mods/MoveOnly/modules/Main.lua').Main(isReplay)

    end
end


