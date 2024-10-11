local Opt = UMT.Options.Opt
UMT.Options.Mods["SRDP"] = {
    previewKey = Opt "SHIFT",
}

function Main()
    local Options = UMT.Options
    local options = UMT.Options.Mods["SRDP"]
    Options.AddOptions("SRDP", "Smart Ring Display+",
        {
            Options.Strings("Preview key (restart required)",
                {
                    "SHIFT",
                    "CONTROL"
                },
                options.previewKey),

        })
end
