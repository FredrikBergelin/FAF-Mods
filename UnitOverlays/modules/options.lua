do
    local GlobalOptions = import("/mods/UMT/modules/GlobalOptions.lua")
    local OptionsUtils = import("/mods/UMT/modules/OptionsWindow.lua")
    local OptionVarCreate = import("/mods/UMT/modules/OptionVar.lua").Create

    local modName = "UnitOverlays"
    local function ModOptionVar(name, value)
        return OptionVarCreate(modName, name, value)
    end

    engineersOption = ModOptionVar("engineersOverlay", true)
    engineersWithNumbersOption = ModOptionVar("engineersWithNumbersOption", false)
    factoryOverlayWithTextOption = ModOptionVar("factoryOverlayWithTextOption", false)
    factoriesOption = ModOptionVar("factoriesOverlay", true)
    supportCommanderOption = ModOptionVar("supportCommanderOverlay", true)
    commanderOverlayOption = ModOptionVar("commanderOverlayOption", false)
    tacticalNukesOption = ModOptionVar("tacticalNukesOverlay", true)
    massExtractorsOption = ModOptionVar("massExtractorsOverlay", true)

    function Main(isReplay)
        GlobalOptions.AddOptions(modName, "Unit Overlays",
            {
                OptionsUtils.Filter("Show engineers ovelays", engineersOption),
                OptionsUtils.Filter("Show commander ovelays", commanderOverlayOption),
                OptionsUtils.Filter("Show engineers ovelays with numbers", engineersWithNumbersOption),
                OptionsUtils.Filter("Show factories ovelays", factoriesOption),
                OptionsUtils.Filter("Show facrory ovelays with text", factoryOverlayWithTextOption),
                OptionsUtils.Filter("Show Nukes and TMLs ovelays", tacticalNukesOption),
                OptionsUtils.Filter("Show Mex ovelays", massExtractorsOption)
            })
    end
end
