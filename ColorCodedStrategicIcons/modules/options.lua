do
    -- local GlobalOptions = import("/mods/UMT/modules/GlobalOptions.lua")
    -- local OptionsUtils = import("/mods/UMT/modules/OptionsWindow.lua")
    local OptionVarCreate = import("/mods/UMT/modules/OptionVar.lua").Create

    local modName = "UnitOverlays"
    local function ModOptionVar(name, value)
        return OptionVarCreate(modName, name, value)
    end

    engineersOption = true
    factoriesOption = true
    siloOption = true
    massExtractorsOption = true

    -- engineersOption = ModOptionVar("engineersOverlay", true)
    -- factoriesOption = ModOptionVar("factoriesOverlay", true)
    -- siloOption = ModOptionVar("siloOverlay", true)
    -- massExtractorsOption = ModOptionVar("massExtractorsOverlay", true)

    -- function Main(isReplay)
    --     GlobalOptions.AddOptions(modName, "Unit Overlays",
    --         {
    --             OptionsUtils.Filter("Show engineers ovelays", engineersOption),
    --             OptionsUtils.Filter("Show factories ovelays", factoriesOption),
    --             OptionsUtils.Filter("Show Nukes and TMLs ovelays", siloOption),
    --             OptionsUtils.Filter("Show Mex ovelays", massExtractorsOption)
    --         })
    -- end
end
