local function ExistGlobal(name)
    return rawget(_G, name) ~= nil
end

if ExistGlobal "UMT" and UMT.Version >= 8 then
    local OriginalCreateUI = CreateUI
    function CreateUI(isReplay)
        OriginalCreateUI(isReplay)

        local Options = import("/mods/DisableZoomInForGroups/modules/Options.lua")
        Options.Init(isReplay or IsObserver()) 
    end
else
    WARN("UI MOD TOOLS NOT FOUND!")
end