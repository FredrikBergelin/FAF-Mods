
--******************************************************************************************************
--** Copyright (c) 2023  Willem 'Jip' Wijnia
--**
--** Permission is hereby granted, free of charge, to any person obtaining a copy
--** of this software and associated documentation files (the "Software"), to deal
--** in the Software without restriction, including without limitation the rights
--** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--** copies of the Software, and to permit persons to whom the Software is
--** furnished to do so, subject to the following conditions:
--**
--** The above copyright notice and this permission notice shall be included in all
--** copies or substantial portions of the Software.
--**
--** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--** SOFTWARE.
--******************************************************************************************************

---@class ContextBasedTemplate
---@field Name string                           # Printed on screen when cycling the templates
---@field TemplateData BuildTemplate            # A regular build template, except that it is written in Pascal Case and usually the first unit is removed
---@field TemplateSortingOrder number           # Lower numbers end up first in the queue 
---@field TriggersOnUnit? EntityCategory        # When defined, includes this template when the unit the mouse is hovering over matches the categories
---@field TriggersOnLand? boolean               # When true, includes this template when the mouse is over land and not over a deposit
---@field TriggersOnWater? boolean              # When true, includes this template when the mouse is over water and not over a deposit
---@field TriggersOnMassDeposit? boolean        # When true, includes this template when the mouse is over a mass deposit
---@field TriggersOnHydroDeposit? boolean       # When true, includes this template when the mouse is over a hydrocarbon deposit

-- Entity categories that are considered valid: https://github.com/FAForever/fa/blob/deploy/fafdevelop/engine/Core/Categories.lua

---@type ContextBasedTemplate
CapExtractorWithStorages = {
    Name = 'Storages',
    TriggersOnUnit = categories.MASSEXTRACTION,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1106',
            33986,
            2,
            0
        },
        {
            'uab1106',
            33993,
            -2,
            0
        },
        {
            'uab1106',
            34000,
            0,
            -2
        },
        {
            'uab1106',
            34008,
            0,
            2
        },
    }
}

---@type ContextBasedTemplate
CapExtractorWithFabs = {
    Name = 'Storages and fabricators',
    TriggersOnUnit = categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
    TemplateSortingOrder = 101,
    TemplateData = {
        10,
        10,
        {
            'uab1106',
            30057,
            -2,
            0
        },
        {
            'uab1106',
            30070,
            2,
            0
        },
        {
            'uab1106',
            30083,
            0,
            -2
        },
        {
            'uab1106',
            30096,
            0,
            2
        },
        {
            'uab1104',
            30109,
            -4,
            0
        },
        {
            'uab1104',
            30134,
            -2,
            2
        },
        {
            'uab1104',
            30158,
            0,
            4
        },
        {
            'uab1104',
            30182,
            2,
            2
        },
        {
            'uab1104',
            30206,
            4,
            0
        },
        {
            'uab1104',
            30231,
            2,
            -2
        },
        {
            'uab1104',
            30255,
            0,
            -4
        },
        {
            'uab1104',
            30279,
            -2,
            -2
        }
    },
}

---@type ContextBasedTemplate
CapRadarWithPower = {
    Name = 'Power generators',
    TriggersOnUnit = (categories.RADAR + categories.OMNI) * categories.STRUCTURE,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1101',
            33986,
            2,
            0
        },
        {
            'uab1101',
            33993,
            -2,
            0
        },
        {
            'uab1101',
            34000,
            0,
            -2
        },
        {
            'uab1101',
            34008,
            0,
            2
        },
    }
}

---@type ContextBasedTemplate
CapT2ArtilleryWithPower = {
    Name = 'Power generators',
    TriggersOnUnit = categories.ARTILLERY * categories.STRUCTURE * categories.TECH2,
    TriggersOnSelection = categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.COMMAND,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1101',
            33986,
            2,
            0
        },
        {
            'uab1101',
            33993,
            -2,
            0
        },
        {
            'uab1101',
            34000,
            0,
            -2
        },
        {
            'uab1101',
            34008,
            0,
            2
        },
    }
}

---@type ContextBasedTemplate
CapT3FabricatorWithStorages = {
    Name = 'Storages',
    TriggersOnUnit = categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1106',
            2605,
            -2,
            4
        },
        {
            'uab1106',
            2621,
            0,
            4
        },
        {
            'uab1106',
            2636,
            2,
            4
        },
        {
            'uab1106',
            2651,
            4,
            2
        },
        {
            'uab1106',
            2666,
            4,
            0
        },
        {
            'uab1106',
            2680,
            4,
            -2
        },
        {
            'uab1106',
            2695,
            2,
            -4
        },
        {
            'uab1106',
            2710,
            0,
            -4
        },
        {
            'uab1106',
            2724,
            -2,
            -4
        },
        {
            'uab1106',
            2738,
            -4,
            -2
        },
        {
            'uab1106',
            2753,
            -4,
            0
        },
        {
            'uab1106',
            2767,
            -4,
            2
        }
    },
}

---@type ContextBasedTemplate
CapT3ArtilleryWithPower = {
    Name = 'Power generators',
    TriggersOnUnit = categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL),
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1301',
            5352,
            10,
            2
        },
        {
            'uab1301',
            5369,
            2,
            10
        },
        {
            'uab1301',
            5385,
            -6,
            2
        },
        {
            'uab1301',
            5408,
            2,
            -6
        }
    },
}

---@type ContextBasedTemplate
CapT3AirWithPower = {
    Name = 'Power generators',
    TriggersOnUnit = categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3,
    TemplateSortingOrder = 100,
    TemplateData = {
        24,
        24,
        {
            'zrb9602',
            12070,
            0,
            0
        },
        {
            'urb1301',
            12562,
            0,
            -8
        },
        {
            'urb1301',
            12665,
            8,
            0
        },
        {
            'urb1301',
            12769,
            0,
            8
        },
        {
            'urb1301',
            12904,
            -8,
            0
        }
    },
}

---@type ContextBasedTemplate
CapT3AirWithPowerAndAir = {
    Name = 'Grid',
    TriggersOnUnit = categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3,
    TemplateSortingOrder = 101,
    TemplateData = {
        24,
        24,
        {
            'zrb9602',
            12070,
            0,
            0
        },
        {
            'urb1301',
            12562,
            0,
            -8
        },
        {
            'urb1301',
            12665,
            8,
            0
        },
        {
            'urb1301',
            12769,
            0,
            8
        },
        {
            'urb1301',
            12904,
            -8,
            0
        },
        {
            'zrb9602',
            13081,
            -8,
            -8
        },
        {
            'zrb9602',
            13148,
            8,
            -8
        },
        {
            'zrb9602',
            13258,
            8,
            8
        },
        {
            'zrb9602',
            13363,
            -8,
            8
        }
    },
}

---@type ContextBasedTemplate
SurroundT3AirWithAir = {
    Name = 'More Air',
    TriggersOnUnit = categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3,
    TemplateSortingOrder = 102,
    TemplateData = {
        24,
        24,
        {
            'zrb9602',
            22263,
            0,
            0
        },
        {
            'zrb9602',
            22445,
            -8,
            -8
        },
        {
            'zrb9602',
            22552,
            8,
            -8
        },
        {
            'zrb9602',
            22654,
            8,
            8
        },
        {
            'zrb9602',
            22722,
            -8,
            8
        }
    },
}

---@type ContextBasedTemplate
CapT3PowerWithAir = {
    Name = 'Air Factories',
    TriggersOnUnit = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
    TemplateSortingOrder = 100,
    TemplateData = {
        24,
        24,
        {
            'urb1301',
            1168,
            0,
            0
        },
        {
            'zrb9602',
            1293,
            0,
            -8
        },
        {
            'zrb9602',
            1384,
            8,
            0
        },
        {
            'zrb9602',
            1501,
            0,
            8
        },
        {
            'zrb9602',
            1608,
            -8,
            0
        }
    },
}

---@type ContextBasedTemplate
CapT3PowerWithAirAndPower = {
    Name = 'Grid',
    TriggersOnUnit = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
    TemplateSortingOrder = 101,
    TemplateData = {
        24,
        24,
        {
            'urb1301',
            5142,
            0,
            0
        },
        {
            'zrb9602',
            5314,
            0,
            -8
        },
        {
            'zrb9602',
            5383,
            8,
            0
        },
        {
            'zrb9602',
            5444,
            0,
            8
        },
        {
            'zrb9602',
            5555,
            -8,
            0
        },
        {
            'urb1301',
            6748,
            8,
            -8
        },
        {
            'urb1301',
            6915,
            8,
            8
        },
        {
            'urb1301',
            7111,
            -8,
            8
        },
        {
            'urb1301',
            7268,
            -8,
            -8
        }
    },
}

---@type ContextBasedTemplate
SurroundT3PowerWithPower = {
    Name = 'More PGens',
    TriggersOnUnit = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
    TemplateSortingOrder = 102,
    TemplateData = {
        24,
        24,
        {
            'urb1301',
            22794,
            0,
            0
        },
        {
            'urb1301',
            23028,
            8,
            -8
        },
        {
            'urb1301',
            23122,
            8,
            8
        },
        {
            'urb1301',
            23215,
            -8,
            8
        },
        {
            'urb1301',
            23331,
            -8,
            -8
        }
    },
}



---@type ContextBasedTemplate
PointDefense = {
    Name = "Artillery",
    TriggersOnLand = true,
    TemplateSortingOrder = 10,
    TemplateData = {
        6,
        6,
        {
            'urb2303',
            208644,
            0,
            0
        },
        {
            'urb1101',
            208715,
            -2,
            0
        },
        {
            'urb1101',
            208721,
            0,
            2
        },
        {
            'urb1101',
            208728,
            0,
            -2
        },
        {
            'urb1101',
            208735,
            2,
            0
        }
    },
}

---@type ContextBasedTemplate
AirDefenseLand = {
    Name = "Shielded Artillery",
    TriggersOnLand = true,
    TemplateSortingOrder = 11,
    TemplateData = {
        14,
        14,
        {
            'urb2303',
            3323,
            0,
            0
        },
        {
            'urb1101',
            3382,
            -2,
            0
        },
        {
            'urb1101',
            3389,
            0,
            2
        },
        {
            'urb1101',
            3395,
            0,
            -2
        },
        {
            'urb1101',
            3403,
            2,
            0
        },
        {
            'urb4202',
            3410,
            -4,
            -4
        },
        {
            'urb4202',
            3443,
            4,
            -4
        },
        {
            'urb4202',
            3471,
            4,
            4
        },
        {
            'urb4202',
            3498,
            -4,
            4
        }
    },
}

---@type ContextBasedTemplate
ArtilleryHeavyFireStation = {
    Name = "Artillery Fire Station",
    TriggersOnLand = true,
    TemplateSortingOrder = 12,
    TemplateData = {
        18,
        12,
        {
            'urb4202',
            5423,
            0,
            0
        },
        {
            'urb2301',
            5484,
            0,
            -8
        },
        {
            'urb2301',
            5508,
            6,
            -6
        },
        {
            'urb2301',
            5573,
            -6,
            -6
        },
        {
            'urb4202',
            5620,
            -6,
            -2
        },
        {
            'urb4202',
            5654,
            6,
            -2
        },
        {
            'urb2204',
            5688,
            4,
            -8
        },
        {
            'urb2204',
            5783,
            -4,
            -8
        }
    },
}

---@type ContextBasedTemplate
NewPointDefense = {
    Name = "Point defense",
    TriggersOnLand = true,
    TemplateSortingOrder = 13,
    TemplateData = {
        3,
        3,
        {
            'uab2101',
            4646,
            0,
            0
        },
        {
            'uab5101',
            4749,
            -1,
            -1
        },
        {
            'uab5101',
            4753,
            0,
            -1
        },
        {
            'uab5101',
            4757,
            1,
            -1
        },
        {
            'uab5101',
            4761,
            1,
            0
        },
        {
            'uab5101',
            4765,
            1,
            1
        },
        {
            'uab5101',
            4769,
            0,
            1
        },
        {
            'uab5101',
            4773,
            -1,
            1
        },
        {
            'uab5101',
            4777,
            -1,
            0
        }
    },
}


---@type ContextBasedTemplate
AirDefenseWater = {
    Name = "Anti-air defense",
    TriggersOnWater = true,
    TemplateSortingOrder = 11,
    TemplateData = {
        3,
        3,
        {
            'uab2104',
            4646,
            0,
            0
        },
    },
}

---@type ContextBasedTemplate
TorpedoDefense = {
    Name = "Torpedo defense",
    TriggersOnWater = true,
    TemplateSortingOrder = 10,
    TemplateData = {
        3,
        3,
        {
            'uab2109',
            4646,
            0,
            0
        },
    },
}



---@type ContextBasedTemplate
T1Extractor = {
    Name = 'T2 + Storage',
    TriggersOnMassDeposit = true,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1202',
            1,
            0,
            0
        },
        {
            'uab1106',
            33986,
            2,
            0
        },
        {
            'uab1106',
            33993,
            -2,
            0
        },
        {
            'uab1106',
            34000,
            0,
            -2
        },
        {
            'uab1106',
            34008,
            0,
            2
        },
    }
}

---@type ContextBasedTemplate
T2ExtractorWithStorages = {
    Name = 'T3 + Storage',
    TriggersOnMassDeposit = true,
    TemplateSortingOrder = 101,
    TemplateData = {
        0,
        0,
        {
            'uab1302',
            1,
            0,
            0
        },
        {
            'uab1106',
            33986,
            2,
            0
        },
        {
            'uab1106',
            33993,
            -2,
            0
        },
        {
            'uab1106',
            34000,
            0,
            -2
        },
        {
            'uab1106',
            34008,
            0,
            2
        },
    }
}

---@type ContextBasedTemplate
T3ExtractorWithStorages = {
    Name = 'Extractor and storages',
    TriggersOnMassDeposit = true,
    TemplateSortingOrder = 102,
    TemplateData = {
        0,
        0,
        {
            'uab1302',
            1,
            0,
            0
        },
        {
            'uab1106',
            30057,
            -2,
            0
        },
        {
            'uab1106',
            30070,
            2,
            0
        },
        {
            'uab1106',
            30083,
            0,
            -2
        },
        {
            'uab1106',
            30096,
            0,
            2
        },
        {
            'uab1104',
            30109,
            -4,
            0
        },
        {
            'uab1104',
            30134,
            -2,
            2
        },
        {
            'uab1104',
            30158,
            0,
            4
        },
        {
            'uab1104',
            30182,
            2,
            2
        },
        {
            'uab1104',
            30206,
            4,
            0
        },
        {
            'uab1104',
            30231,
            2,
            -2
        },
        {
            'uab1104',
            30255,
            0,
            -4
        },
        {
            'uab1104',
            30279,
            -2,
            -2
        }
    },
}

---@type ContextBasedTemplate
T3ExtractorWithStoragesAndFabs = {
    Name = 'Extractor, storages and fabricators',
    TriggersOnMassDeposit = true,
    TemplateSortingOrder = 103,
    TemplateData = {
        18,
        18,
        {
            'urb1302',
            809,
            0,
            0
        },
        {
            'urb1106',
            1325,
            2,
            0
        },
        {
            'urb1106',
            1371,
            -2,
            0
        },
        {
            'urb1106',
            1417,
            0,
            -2
        },
        {
            'urb1106',
            1463,
            0,
            2
        },
        {
            'urb1104',
            6255,
            -2,
            -2
        },
        {
            'urb1104',
            6301,
            2,
            -2
        },
        {
            'urb1104',
            6361,
            2,
            2
        },
        {
            'urb1104',
            6429,
            -2,
            2
        },
        {
            'urb1104',
            6496,
            0,
            -4
        },
        {
            'urb1104',
            6539,
            4,
            0
        },
        {
            'urb1104',
            6570,
            0,
            4
        },
        {
            'urb1104',
            6642,
            -4,
            0
        },
        {
            'urb4202',
            6664,
            -4,
            -6
        },
        {
            'urb4202',
            6679,
            6,
            -4
        },
        {
            'urb4202',
            6693,
            4,
            6
        },
        {
            'urb4202',
            6707,
            -6,
            4
        }
    },
}

-- ---@type ContextBasedTemplate
-- T3ExtractorWithStoragesWithDefense = {
--     Name = 'Extractor and storages',
--     TriggersOnMassDeposit = true,
--     TemplateSortingOrder = 102,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1302',
--             1,
--             0,
--             0
--         },
--         {
--             'uab1106',
--             33986,
--             2,
--             0
--         },
--         {
--             'uab1106',
--             33993,
--             -2,
--             0
--         },
--         {
--             'uab1106',
--             34000,
--             0,
--             -2
--         },
--         {
--             'uab1106',
--             34008,
--             0,
--             2
--         },
--     }
-- }

-- ---@type ContextBasedTemplate
-- T2ExtractorWithStorages = {
--     Name = 'Extractor and storages',
--     TriggersOnMassDeposit = true,
--     TemplateSortingOrder = 103,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1202',
--             1,
--             0,
--             0
--         },
--         {
--             'uab1106',
--             33986,
--             2,
--             0
--         },
--         {
--             'uab1106',
--             33993,
--             -2,
--             0
--         },
--         {
--             'uab1106',
--             34000,
--             0,
--             -2
--         },
--         {
--             'uab1106',
--             34008,
--             0,
--             2
--         },
--     }
-- }

-- ---@type ContextBasedTemplate
-- T2ExtractorWithStoragesWithDefense = {
--     Name = 'Extractor and storages',
--     TriggersOnMassDeposit = true,
--     TemplateSortingOrder = 104,
--     TemplateData = {
--         14,
--         10,
--         {
--             'urb1202',
--             60722,
--             0,
--             0
--         },
--         {
--             'urb4202',
--             60802,
--             -4,
--             -4
--         },
--         {
--             'urb4202',
--             60867,
--             4,
--             -4
--         },
--         {
--             'urb1106',
--             60979,
--             2,
--             0
--         },
--         {
--             'urb1106',
--             60989,
--             0,
--             2
--         },
--         {
--             'urb1106',
--             60997,
--             -2,
--             0
--         },
--         {
--             'urb1106',
--             61016,
--             0,
--             -2
--         },
--         {
--             'urb2204',
--             62535,
--             0,
--             -4
--         },
--         {
--             'urb2301',
--             68771,
--             0,
--             -6
--         }
--     },
-- }



---@type ContextBasedTemplate
T1Hydrocarbon = {
    Name = 'Hydrocarbon',
    TriggersOnHydroDeposit = true,
    TemplateSortingOrder = 100,
    TemplateData = {
        0,
        0,
        {
            'uab1102',
            1,
            1,
            1
        },
    },
}

---@type ContextBasedTemplate
T1HydrocarbonWithPgens = {
    Name = 'With PGens',
    TriggersOnHydroDeposit = true,
    TemplateSortingOrder = 101,
    TemplateData = {
        20,
        26,
        {
            'urb1102',
            13450,
            0,
            0
        },
        {
            'urb1101',
            13632,
            -4,
            4
        },
        {
            'urb1101',
            13656,
            -4,
            6
        },
        {
            'urb1101',
            13676,
            -4,
            8
        },
        {
            'urb1101',
            13691,
            -4,
            10
        },
        {
            'urb1101',
            13706,
            -2,
            12
        },
        {
            'urb1101',
            13721,
            0,
            12
        },
        {
            'urb1101',
            13796,
            2,
            12
        },
        {
            'urb1101',
            13811,
            4,
            12
        },
        {
            'urb1101',
            13826,
            6,
            10
        },
        {
            'urb1101',
            13841,
            6,
            8
        },
        {
            'urb1101',
            13861,
            6,
            6
        },
        {
            'urb1101',
            13876,
            6,
            4
        },
        {
            'urb1101',
            13896,
            8,
            4
        },
        {
            'urb1101',
            13911,
            10,
            4
        },
        {
            'urb1101',
            13982,
            12,
            2
        },
        {
            'urb1101',
            14002,
            12,
            0
        },
        {
            'urb1101',
            14017,
            12,
            -2
        },
        {
            'urb1101',
            14032,
            12,
            -4
        },
        {
            'urb1101',
            14047,
            10,
            -6
        },
        {
            'urb1101',
            14062,
            8,
            -6
        },
        {
            'urb1101',
            14082,
            6,
            -6
        },
        {
            'urb1101',
            14102,
            4,
            -6
        },
        {
            'urb1101',
            14177,
            4,
            -8
        },
        {
            'urb1101',
            14192,
            4,
            -10
        },
        {
            'urb1101',
            14207,
            2,
            -12
        },
        {
            'urb1101',
            14222,
            0,
            -12
        },
        {
            'urb1101',
            14237,
            -2,
            -12
        },
        {
            'urb1101',
            14308,
            -4,
            -12
        },
        {
            'urb1101',
            14323,
            -6,
            -10
        },
        {
            'urb1101',
            14343,
            -6,
            -8
        },
        {
            'urb1101',
            14358,
            -6,
            -6
        },
        {
            'urb1101',
            14386,
            -6,
            -4
        }
    },
}

---@type ContextBasedTemplate
CapHydrocarbonWithPgens = {
    Name = 'Cap PGens',
    TriggersOnUnit = categories.HYDROCARBON,
    TemplateSortingOrder = 101,
    TemplateData = {
        20,
        26,
        {
            'urb1102',
            13450,
            0,
            0
        },
        {
            'urb1101',
            13632,
            -4,
            4
        },
        {
            'urb1101',
            13656,
            -4,
            6
        },
        {
            'urb1101',
            13676,
            -4,
            8
        },
        {
            'urb1101',
            13691,
            -4,
            10
        },
        {
            'urb1101',
            13706,
            -2,
            12
        },
        {
            'urb1101',
            13721,
            0,
            12
        },
        {
            'urb1101',
            13796,
            2,
            12
        },
        {
            'urb1101',
            13811,
            4,
            12
        },
        {
            'urb1101',
            13826,
            6,
            10
        },
        {
            'urb1101',
            13841,
            6,
            8
        },
        {
            'urb1101',
            13861,
            6,
            6
        },
        {
            'urb1101',
            13876,
            6,
            4
        },
        {
            'urb1101',
            13896,
            8,
            4
        },
        {
            'urb1101',
            13911,
            10,
            4
        },
        {
            'urb1101',
            13982,
            12,
            2
        },
        {
            'urb1101',
            14002,
            12,
            0
        },
        {
            'urb1101',
            14017,
            12,
            -2
        },
        {
            'urb1101',
            14032,
            12,
            -4
        },
        {
            'urb1101',
            14047,
            10,
            -6
        },
        {
            'urb1101',
            14062,
            8,
            -6
        },
        {
            'urb1101',
            14082,
            6,
            -6
        },
        {
            'urb1101',
            14102,
            4,
            -6
        },
        {
            'urb1101',
            14177,
            4,
            -8
        },
        {
            'urb1101',
            14192,
            4,
            -10
        },
        {
            'urb1101',
            14207,
            2,
            -12
        },
        {
            'urb1101',
            14222,
            0,
            -12
        },
        {
            'urb1101',
            14237,
            -2,
            -12
        },
        {
            'urb1101',
            14308,
            -4,
            -12
        },
        {
            'urb1101',
            14323,
            -6,
            -10
        },
        {
            'urb1101',
            14343,
            -6,
            -8
        },
        {
            'urb1101',
            14358,
            -6,
            -6
        },
        {
            'urb1101',
            14386,
            -6,
            -4
        }
    },
}

---@type ContextBasedTemplate
T1HydrocarbonWithAirFactories = {
    Name = 'With Air Factories',
    TriggersOnHydroDeposit = true,
    TemplateSortingOrder = 102,
    TemplateData = {
        16,
        22,
        {
            'urb1102',
            13450,
            0,
            0
        },
        {
            'urb0102',
            16351,
            1,
            7
        },
        {
            'urb0102',
            16489,
            7,
            -1
        },
        {
            'urb0102',
            16544,
            -1,
            -7
        }
    },
}

---@type ContextBasedTemplate
CapHydrocarbonWithAirFactories = {
    Name = 'Cap Air Factories',
    TriggersOnUnit = categories.HYDROCARBON,
    TemplateSortingOrder = 102,
    TemplateData = {
        16,
        22,
        {
            'urb1102',
            13450,
            0,
            0
        },
        {
            'urb0102',
            16351,
            1,
            7
        },
        {
            'urb0102',
            16489,
            7,
            -1
        },
        {
            'urb0102',
            16544,
            -1,
            -7
        }
    },
}