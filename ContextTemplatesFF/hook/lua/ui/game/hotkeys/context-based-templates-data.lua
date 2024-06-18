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


-- RESET

PointDefense = nil
AirDefenseLand = nil
AirDefenseWater = nil
TorpedoDefense = nil

T3Extractor = nil
T3ExtractorWithStorages = nil
T3ExtractorWithStoragesAndFabs = nil
T1Hydrocarbon = nil

AppendExtractorWithStorages = nil
AppendExtractorWithFabs = nil

AppendRadarWithPower = nil
AppendOpticsWithPower = nil
AppendT2ArtilleryWithPower = nil
AppendT3FabricatorWithStorages = nil
AppendT3ArtilleryWithPower = nil
AppendSalvationWithPower = nil
AppendPowerGeneratorsToT2Artillery = nil
AppendPowerGeneratorsToT3Artillery = nil
AppendPowerGeneratorsToSalvation = nil
AppendPowerGeneratorsToEnergyStorage = nil
AppendPowerGeneratorsToTML = nil
AppendWallsToPointDefense = nil
AppendAirGrid = nil


---@type ContextBasedTemplate
T2ExtractorWithStorages = {
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
T3ExtractorWithStorages = {
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
T3ExtractorWithStoragesAndFabs = {
    Name = 'T3 + Storages + Fabs',
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
    Name = 'T3 + Storages + Fabs + Shields',
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

---@type ContextBasedTemplate
T1Hydro = {
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
T1HydroWithAirFac = {
    Name = 'With Air Factory',
    TriggersOnHydroDeposit = true,
    TemplateSortingOrder = 101,
    TemplateData = {
        12,
        16,
        {
            'urb1102',
            743,
            0,
            0
        },
        {
            'urb1101',
            1220,
            -4,
            -4
        },
        {
            'urb1101',
            1305,
            -4,
            -8
        },
        {
            'urb1101',
            1401,
            -2,
            -12
        },
        {
            'urb0102',
            1499,
            1,
            -7
        },
        {
            'urb1101',
            1655,
            2,
            -12
        },
        {
            'urb1101',
            1765,
            6,
            -10
        },
        {
            'urb1101',
            1862,
            6,
            -6
        },
        {
            'urb1101',
            1930,
            6,
            -4
        },
        {
            'urb1101',
            2048,
            6,
            -8
        },
        {
            'urb1101',
            2128,
            4,
            -12
        },
        {
            'urb1101',
            2228,
            0,
            -12
        },
        {
            'urb1101',
            2312,
            -4,
            -10
        },
        {
            'urb1101',
            2381,
            -4,
            -6
        }
    },
}


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
    }
}

-- ---@type ContextBasedTemplate
-- CapRadarWithPower = {
--     Name = 'Power generators',
--     TriggersOnUnit = (categories.RADAR + categories.OMNI) * categories.STRUCTURE,
--     TemplateSortingOrder = 100,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1101',
--             33986,
--             2,
--             0
--         },
--         {
--             'uab1101',
--             33993,
--             -2,
--             0
--         },
--         {
--             'uab1101',
--             34000,
--             0,
--             -2
--         },
--         {
--             'uab1101',
--             34008,
--             0,
--             2
--         },
--     }
-- }

-- ---@type ContextBasedTemplate
-- CapT2ArtilleryWithPower = {
--     Name = 'Power generators',
--     TriggersOnUnit = categories.ARTILLERY * categories.STRUCTURE * categories.TECH2,
--     TriggersOnSelection = categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.COMMAND,
--     TemplateSortingOrder = 100,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1101',
--             33986,
--             2,
--             0
--         },
--         {
--             'uab1101',
--             33993,
--             -2,
--             0
--         },
--         {
--             'uab1101',
--             34000,
--             0,
--             -2
--         },
--         {
--             'uab1101',
--             34008,
--             0,
--             2
--         },
--     }
-- }

-- ---@type ContextBasedTemplate
-- CapT3FabricatorWithStorages = {
--     Name = 'Storages',
--     TriggersOnUnit = categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
--     TemplateSortingOrder = 100,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1106',
--             2605,
--             -2,
--             4
--         },
--         {
--             'uab1106',
--             2621,
--             0,
--             4
--         },
--         {
--             'uab1106',
--             2636,
--             2,
--             4
--         },
--         {
--             'uab1106',
--             2651,
--             4,
--             2
--         },
--         {
--             'uab1106',
--             2666,
--             4,
--             0
--         },
--         {
--             'uab1106',
--             2680,
--             4,
--             -2
--         },
--         {
--             'uab1106',
--             2695,
--             2,
--             -4
--         },
--         {
--             'uab1106',
--             2710,
--             0,
--             -4
--         },
--         {
--             'uab1106',
--             2724,
--             -2,
--             -4
--         },
--         {
--             'uab1106',
--             2738,
--             -4,
--             -2
--         },
--         {
--             'uab1106',
--             2753,
--             -4,
--             0
--         },
--         {
--             'uab1106',
--             2767,
--             -4,
--             2
--         }
--     },
-- }

-- ---@type ContextBasedTemplate
-- CapT3ArtilleryWithPower = {
--     Name = 'Power generators',
--     TriggersOnUnit = categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL),
--     TemplateSortingOrder = 100,
--     TemplateData = {
--         0,
--         0,
--         {
--             'uab1301',
--             5352,
--             10,
--             2
--         },
--         {
--             'uab1301',
--             5369,
--             2,
--             10
--         },
--         {
--             'uab1301',
--             5385,
--             -6,
--             2
--         },
--         {
--             'uab1301',
--             5408,
--             2,
--             -6
--         }
--     },
-- }

---@type ContextBasedTemplate
CapT3AirWithPowerAndAir = {
    Name = 'Grid',
    TriggersOnUnit = categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3,
    TemplateSortingOrder = 100,
    TemplateData = {
        24,
        24,
        {
            'zrb9602',
            24644,
            0,
            0
        },
        {
            'urb1301',
            24728,
            0,
            -8
        },
        {
            'zrb9602',
            25027,
            8,
            -8
        },
        {
            'urb1301',
            25266,
            8,
            0
        },
        {
            'zrb9602',
            25547,
            8,
            8
        },
        {
            'urb1301',
            25727,
            0,
            8
        },
        {
            'zrb9602',
            25984,
            -8,
            8
        },
        {
            'urb1301',
            26152,
            -8,
            0
        },
        {
            'zrb9602',
            26457,
            -8,
            -8
        }
    },
}
---@type ContextBasedTemplate
CapT3AirWithPower = {
    Name = 'Power generators',
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
CapT3PowerWithAirAndPower = {
    Name = 'Grid',
    TriggersOnUnit = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
    TemplateSortingOrder = 100,
    TemplateData = {
        24,
        24,
        {
            'urb1301',
            20783,
            0,
            0
        },
        {
            'zrb9602',
            20948,
            0,
            -8
        },
        {
            'urb1301',
            21032,
            8,
            -8
        },
        {
            'zrb9602',
            21177,
            8,
            0
        },
        {
            'urb1301',
            21283,
            8,
            8
        },
        {
            'zrb9602',
            21396,
            0,
            8
        },
        {
            'urb1301',
            21488,
            -8,
            8
        },
        {
            'zrb9602',
            21639,
            -8,
            0
        },
        {
            'urb1301',
            21746,
            -8,
            -8
        }
    },
}
---@type ContextBasedTemplate
CapT3PowerWithAir = {
    Name = 'Air Factories',
    TriggersOnUnit = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
    TemplateSortingOrder = 101,
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
-- Old name to override existing templates
T2ArtilleryWithPgen = {
    Name = "Artillery",
    TriggersOnLand = true,
    TemplateSortingOrder = 11,
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
FireStation = {
    Name = "Fire Station",
    TriggersOnLand = true,
    TemplateSortingOrder = 12,
    TemplateData = {
        29,
        13.5,
        {
            'urb4202',
            313,
            0,
            0
        },
        {
            'urb2301',
            511,
            0,
            -8
        },
        {
            'urb2301',
            620,
            6,
            -6
        },
        {
            'urb2301',
            729,
            -6,
            -6
        },
        {
            'urb4202',
            852,
            -6,
            -2
        },
        {
            'urb4202',
            978,
            6,
            -2
        },
        {
            'urb2204',
            1104,
            4,
            -8
        },
        {
            'urb2204',
            1203,
            -4,
            -8
        },
        {
            'urb2101',
            4808,
            -1,
            -5
        },
        {
            'urb5101',
            4854,
            -2,
            -6
        },
        {
            'urb5101',
            4858,
            -1,
            -6
        },
        {
            'urb5101',
            4862,
            0,
            -6
        },
        {
            'urb5101',
            4866,
            0,
            -5
        },
        {
            'urb5101',
            4870,
            0,
            -4
        },
        {
            'urb5101',
            4874,
            -1,
            -4
        },
        {
            'urb5101',
            4878,
            -2,
            -4
        },
        {
            'urb5101',
            4882,
            -2,
            -5
        },
        {
            'urb2101',
            4886,
            1,
            -5
        },
        {
            'urb5101',
            4933,
            1,
            -6
        },
        {
            'urb5101',
            4937,
            2,
            -6
        },
        {
            'urb5101',
            4941,
            2,
            -5
        },
        {
            'urb5101',
            4945,
            2,
            -4
        },
        {
            'urb5101',
            4949,
            1,
            -4
        },
        {
            'urb5101',
            8526,
            -9,
            -10
        },
        {
            'urb5101',
            8530,
            -8,
            -10
        },
        {
            'urb5101',
            8534,
            -7,
            -10
        },
        {
            'urb5101',
            8538,
            -6,
            -10
        },
        {
            'urb5101',
            8542,
            -5,
            -10
        },
        {
            'urb5101',
            8546,
            -4,
            -10
        },
        {
            'urb5101',
            8550,
            -3,
            -10
        },
        {
            'urb5101',
            8554,
            -2,
            -10
        },
        {
            'urb5101',
            8558,
            -1,
            -10
        },
        {
            'urb5101',
            8562,
            0,
            -10
        },
        {
            'urb5101',
            8566,
            1,
            -10
        },
        {
            'urb5101',
            8570,
            2,
            -10
        },
        {
            'urb5101',
            8574,
            3,
            -10
        },
        {
            'urb5101',
            8578,
            4,
            -10
        },
        {
            'urb5101',
            8582,
            5,
            -10
        },
        {
            'urb5101',
            8586,
            6,
            -10
        },
        {
            'urb5101',
            8590,
            7,
            -10
        },
        {
            'urb5101',
            8646,
            8,
            -10
        },
        {
            'urb5101',
            8650,
            9,
            -10
        },
        {
            'urb5101',
            9348,
            10,
            -9
        },
        {
            'urb5101',
            9352,
            11,
            -8
        },
        {
            'urb5101',
            9356,
            12,
            -7
        },
        {
            'urb5101',
            9360,
            13,
            -6
        },
        {
            'urb5101',
            9364,
            14,
            -5
        },
        {
            'urb2101',
            9799,
            9,
            -9
        },
        {
            'urb2101',
            10214,
            -9,
            -9
        },
        {
            'urb5101',
            10826,
            -10,
            -9
        },
        {
            'urb5101',
            10830,
            -11,
            -8
        },
        {
            'urb5101',
            10834,
            -12,
            -7
        },
        {
            'urb5101',
            10838,
            -13,
            -6
        },
        {
            'urb5101',
            10842,
            -14,
            -5
        }
    },
}
---@type ContextBasedTemplate
FireStation2 = {
    Name = "Fire Station 2",
    TriggersOnLand = true,
    TemplateSortingOrder = 13,
    TemplateData = {
        27,
        23.5,
        {
            'urb4202',
            48539,
            0,
            0
        },
        {
            'urb2301',
            48665,
            0,
            -8
        },
        {
            'urb2301',
            48823,
            6,
            -6
        },
        {
            'urb2301',
            48932,
            -6,
            -6
        },
        {
            'urb4202',
            49041,
            -6,
            -2
        },
        {
            'urb4202',
            49183,
            6,
            -2
        },
        {
            'urb2204',
            49309,
            4,
            -8
        },
        {
            'urb2204',
            49408,
            -4,
            -8
        },
        {
            'urb4201',
            49506,
            -6,
            -8
        },
        {
            'urb4201',
            49579,
            6,
            -8
        },
        {
            'urb2303',
            49652,
            -2,
            -6
        },
        {
            'urb1101',
            49940,
            -2,
            -8
        },
        {
            'urb1101',
            49964,
            0,
            -6
        },
        {
            'urb1101',
            49988,
            -4,
            -6
        },
        {
            'urb1101',
            50012,
            -2,
            -4
        },
        {
            'urb2303',
            50036,
            2,
            -6
        },
        {
            'urb1101',
            50324,
            2,
            -8
        },
        {
            'urb1101',
            50348,
            4,
            -6
        },
        {
            'urb1101',
            50386,
            2,
            -4
        },
        {
            'urb3201',
            50425,
            0,
            -4
        },
        {
            'urb4202',
            50575,
            0,
            -12
        },
        {
            'urb4202',
            50702,
            -6,
            -12
        },
        {
            'urb4202',
            50828,
            6,
            -12
        },
        {
            'urb5101',
            51042,
            -10,
            -20
        },
        {
            'urb5101',
            51046,
            -9,
            -20
        },
        {
            'urb5101',
            51050,
            -8,
            -20
        },
        {
            'urb5101',
            51054,
            -7,
            -20
        },
        {
            'urb5101',
            51058,
            -6,
            -20
        },
        {
            'urb5101',
            51062,
            -5,
            -20
        },
        {
            'urb5101',
            51066,
            -4,
            -20
        },
        {
            'urb5101',
            51070,
            -3,
            -20
        },
        {
            'urb5101',
            51074,
            -2,
            -20
        },
        {
            'urb5101',
            51078,
            -1,
            -20
        },
        {
            'urb5101',
            51082,
            0,
            -20
        },
        {
            'urb5101',
            51086,
            1,
            -20
        },
        {
            'urb5101',
            51090,
            2,
            -20
        },
        {
            'urb5101',
            51094,
            3,
            -20
        },
        {
            'urb5101',
            51098,
            4,
            -20
        },
        {
            'urb5101',
            51148,
            5,
            -20
        },
        {
            'urb5101',
            51152,
            6,
            -20
        },
        {
            'urb5101',
            51156,
            7,
            -20
        },
        {
            'urb5101',
            51160,
            8,
            -20
        },
        {
            'urb5101',
            51164,
            9,
            -20
        },
        {
            'urb5101',
            51168,
            10,
            -20
        },
        {
            'urb2101',
            55444,
            9,
            -19
        },
        {
            'urb5101',
            58489,
            10,
            -19
        },
        {
            'urb5101',
            58493,
            11,
            -18
        },
        {
            'urb5101',
            58497,
            12,
            -17
        },
        {
            'urb5101',
            58501,
            13,
            -16
        },
        {
            'urb2101',
            58940,
            -9,
            -19
        },
        {
            'urb5101',
            59643,
            -10,
            -19
        },
        {
            'urb5101',
            59702,
            -11,
            -18
        },
        {
            'urb5101',
            59706,
            -12,
            -17
        },
        {
            'urb5101',
            59710,
            -13,
            -16
        }
    },
}


---@type ContextBasedTemplate
PointDefense = {
    Name = "Point defense",
    TriggersOnLand = true,
    TemplateSortingOrder = 15,
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

-- ---@type ContextBasedTemplate
-- TorpedoDefense = {
--     Name = "Torpedo defense",
--     TriggersOnWater = true,
--     TemplateSortingOrder = 10,
--     TemplateData = {
--         3,
--         3,
--         {
--             'uab2109',
--             4646,
--             0,
--             0
--         },
--     },
-- }
-- ---@type ContextBasedTemplate
-- AirDefenseWater = {
--     Name = "Anti-air defense",
--     TriggersOnWater = true,
--     TemplateSortingOrder = 11,
--     TemplateData = {
--         3,
--         3,
--         {
--             'uab2104',
--             4646,
--             0,
--             0
--         },
--     },
-- }
