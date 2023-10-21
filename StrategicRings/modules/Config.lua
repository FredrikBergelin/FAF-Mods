local UnitUtils = import('/mods/StrategicRings/modules/UnitUtil.lua')

Menus = {
    -- TODO colors
    Default = {
        {
            {Type = "Label", Text = "Tactical"},
            {Type = "Button", Text = "TMD", Radius = 31, Texture = "RED", Static = false},
            {Type = "Button", Text = "TMD (Aeon)", Radius = 12.5, Texture = "RED", Static = false},
            {Type = "Button", Text = "TML", Radius = 256, Texture = "BLUE", Static = false},
            {Type = "Label", Text = "Strategic"},
            {Type = "Button", Text = "SMD", Radius = 90, Texture = "RED", Static = false},
            {Type = "Button", Text = "Nuke (Inner)", Radius = 30, Texture = "BLUE", Static = false},
        },
        {
            {Type = "Label", Text = "Warfare"},
            {Type = "Button", Text = "PD1", Radius = 26, Texture = "YELLOW", Static = false},
            {Type = "Button", Text = "PD2 | TL", Radius = 50, Texture = "YELLOW", Static = false},
            {Type = "Button", Text = "PD3", Radius = 70, Texture = "YELLOW", Static = false},
            {Type = "Button", Text = "Arty", Radius = 128, Texture = "YELLOW", Static = false},
            {Type = "Button", Text = "SAM", Radius = 60, Texture = "YELLOW", Static = false}
        },
        {
            {Type = "Label", Text = "Vision"},
            {Type = "Button", Text = "Radar1", Radius = 115, Texture = "VIOLET", Static = false},
            {Type = "Button", Text = "Omni | Radar2", Radius = 200, Texture = "VIOLET", Static = false},
            {Type = "Label", Text = "Util"},
            {Type = "Button", Text = "Delete", Action = "DELETE_CLOSEST"},
            {Type = "Button", Text = "Delete All", Action = "DELETE_SCREEN"}
        }
    }
}

Wheels = {
    Default = {
        Position = 'MOUSE',
        Ui = {
            Radius = 0.25,
            Middle = {
                Type = 'SIMPLE',
                Texture = 'DEFAULT',
                Radius = 0.095,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'RING',
                Action = 'DELETE_SCREEN',
                Text = {
                    Value = 'DEL',
                    Size = 0.04,
                    Color = 'ffffff'
                }
            },
            Sector = {
                Type = 'SIMPLE',
                Texture = 'DEFAULT',
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7,
                },
                ActionType = 'RING',
                Text = {
                    Size = 0.03,
                    Color = 'ffffff'
                }
            }
        },
        -- TODO colors
        Items = {
            {Radius = 26, Texture = "YELLOW", Static = false, Text = {{Value = '[P] ', Color = 'ffd300', Size = 0.04}, {Value = 'PD1'}}},
            {Radius = 50, Texture = "YELLOW", Static = false, Text = {{Value = '[P] ', Color = 'ffd300', Size = 0.04}, {Value = 'PD2/TL'}}},
            {Radius = 128, Texture = "YELLOW", Static = false, Text = {{Value = '[A] ', Color = 'ffd300', Size = 0.04}, {Value = 'ARTY'}}},
            {Radius = 70, Texture = "YELLOW", Static = false, Text = {{Value = '[P] ', Color = 'ffd300', Size = 0.04}, {Value = 'PD3'}}},
            {Radius = 256, Texture = "BLUE", Static = false, Text = {{Value = '[T] ', Color = '10e7ff', Size = 0.04}, {Value = 'TML'}}},
            {Radius = 30, Texture = "BLUE", Static = false, Text = {{Value = '[N] ', Color = '8f0909', Size = 0.04}, {Value = 'NUKE'}}},
            {Radius = 200, Texture = "VIOLET", Static = false, Text = {{Value = '[R] ', Color = '7f32a8', Size = 0.04}, {Value = 'Omni/Radar2'}}},
            {Radius = 115, Texture = "VIOLET", Static = false, Text = {{Value = '[R] ', Color = '7f32a8', Size = 0.04}, {Value = 'Radar1'}}},
            {Radius = 60, Texture = "YELLOW", Static = false, Text = {{Value = '[S] ', Color = 'ffd300', Size = 0.04}, {Value = 'SAM'}}},
            {Radius = 90, Texture = "RED", Static = false, Text = {{Value = '[S] ', Color = '8f0909', Size = 0.04}, {Value = 'SMD'}}},
            {Radius = 12.5, Texture = "RED", Static = false, Text = {{Value = '[T] ', Color = '10e7ff', Size = 0.04}, {Value = 'TMD (A)'}}},
            {Radius = 31, Texture = "RED", Static = false, Text = {{Value = '[T] ', Color = '10e7ff', Size = 0.04}, {Value = 'TMD'}}},
        }
    }
}

Hover = {
    DirectFire = {
        Texture = "DIRECTFIRE",
        Category = (categories.STRUCTURE * categories.DIRECTFIRE),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetLongestRangeWeapon
    },
    IndirectFire = {
        Texture = "INDIRECTFIRE",
        Category = (categories.STRUCTURE * categories.INDIRECTFIRE - categories.TACTICALMISSILEPLATFORM),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetLongestRangeWeapon
    },
    TML = {
        Texture = "TML",
        Category = (categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetLongestRangeWeapon
    },
    AntiAir = {
        Texture = "ANTIAIR",
        Category = (categories.STRUCTURE * categories.ANTIAIR),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetLongestRangeWeapon
    },
    AntiNavy = {
        Texture = "ANTINAVY",
        Category = (categories.STRUCTURE * categories.ANTINAVY),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetLongestRangeWeapon
    },
    AntiMissile = {
        Texture = "PROTECTION",
        Category = (categories.STRUCTURE * categories.ANTIMISSILE)
            + (categories.STRUCTURE * categories.SHIELD),
        Predicate = UnitUtils.HasWeapon,
        Supplier = UnitUtils.GetShortestRangeWeapon
    },
    Radar = {
        Texture = "RADAR",
        Category = categories.STRUCTURE * categories.INTELLIGENCE,
        Predicate = UnitUtils.HasRadar, Supplier = UnitUtils.GetRadarRange
    },
    Omni = {
        Texture = "OMNI",
        Category = categories.STRUCTURE * categories.INTELLIGENCE,
        Predicate = UnitUtils.HasOmni,
        Supplier = UnitUtils.GetOmniRange
    },
}