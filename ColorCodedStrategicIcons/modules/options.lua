local Options = UMT.Options
local Opt = UMT.Options.Opt

UMT.Options.Mods["ColorCodedStrategicIcons"] = {
    mexOverlay = Opt(true),
    engineersOverlay = Opt(true),
    sacuOverlay = Opt(true),
    factoriesOverlay = Opt(true),
    stationarySiloOverlay = Opt(true),
    mobileSiloOverlay = Opt(true),
}

function Main()
    local options = UMT.Options.Mods["ColorCodedStrategicIcons"]
    Options.AddOptions("ColorCodedStrategicIcons", "Color Coded Strategic Icons - Overlays", {
        Options.Filter("Upgrading MEX", options.mexOverlay),
        Options.Filter("Idle engineers", options.engineersOverlay),
        Options.Filter("Idle SACU", options.sacuOverlay),
        Options.Filter("Idle/upgrading/repeating factory", options.factoriesOverlay),
        Options.Filter("Missile count of stationary silos", options.stationarySiloOverlay),
        Options.Filter("Missile count of mobile silos", options.mobileSiloOverlay),
    })
end
