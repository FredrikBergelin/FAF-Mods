local ActionHandlerGeneric = import("/mods/CommandWheel/modules/handler/ActionHandlerGeneric.lua")

Wheels = {
    Alert = {
        Position = 'MOUSE',
        Ui = {
            Radius = 0.15,
            Middle = {
                Type = 'EMPTY',
                Texture = 'DEFAULT',
                Radius = 0.107,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'CHAT',
                Action = 'Energy Please!',
                Text = {
                    Value = 'E',
                    Size = 0.12,
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
                ActionType = 'PING',
                Text = {
                    Size = 0.12,
                    Color = 'ffffff'
                }
            }
        },
        Items = {
            {Action = 'alert', Text = {{Value = 'Alert', Color = 'ffd300', Size = 0.08}}},
            {Action = 'move', Text = {{Value = 'Move', Color = '10e7ff', Size = 0.08}}},
            {Action = 'attack', Text = {{Value = 'Attack', Color = 'c50000', Size = 0.08}}},
            {Action = 'marker', Text = {{Value = 'Marker', Color = 'ffffff', Size = 0.08}}}
        }
    },
    AlertExtended = {
        Position = 'MOUSE',
        Ui = {
            Radius = 0.2,
            Middle = {
                Type = 'EMPTY',
                Texture = 'DEFAULT',
                Radius = 0.095,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'CHAT',
                Action = 'Energy Please!',
                Text = {
                    Value = 'E',
                    Size = 0.07,
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
                ActionType = 'PING',
                Text = {
                    Size = 0.065,
                    Color = 'ffffff'
                }
            }
        },
        Items = {
            {Action = 'alert', Text = {{Value = 'Alert', Color = 'ffd300'}}},
            {Action = 'marker', MarkerNickname = true, MarkerText = 'T1 Eng', Text = {{Value = 'E1', Color = '4db366'}}},
            {Action = 'marker', MarkerNickname = true, MarkerText = 'T2 Eng',  Text = {{Value = 'E2', Color = '4db366'}}},
            {Action = 'marker', MarkerNickname = true, MarkerText = 'T3 Eng',  Text = {{Value = 'E3', Color = '4db366'}}},
            {Action = 'marker', MarkerTimestamp = true, MarkerText = '', Text = {{Value = 'Time', Color = '4db366'}}},
            {Action = 'marker', Text = {{Value = 'Marker', Color = 'ffffff'}}},
            {Action = 'move', Text = {{Value = 'Move', Color = '10e7ff'}}},
            {Action = 'attack', Text = {{Value = 'Attack', Color = 'c50000'}}},
        }
    },
    TargetPriority = {
        Mods = {{
            Name = 'Advanced Target Priorities',
            Location = '/mods/advanced target priorities'
        }},
        Position = 'MOUSE',
        Ui = {
            Radius = 0.25,
            Middle = {
                Type = 'EMPTY',
                Texture = 'DEFAULT',
                Radius = 0.095,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'TARGET_PRIORITY',
                Action = 'Default',
                Text = {
                    Value = 'DEF',
                    Size = 0.04,
                    Color = 'ffffff'
                }
            },
            Sector = {
                Type = 'SIMPLE',
                Texture = 'DEFAULT',
                Alpha = 0.4,
                Hover = {
                    Alpha = 0.7,
                },
                ActionType = 'TARGET_PRIORITY',
                Text = {
                    Size = 0.03,
                    Color = 'ffffff'
                }
            }
        },
        Items = {
            {Action = 'Engies', Text = {{Value = 'Eng', Color = '4a8a0a', Size = 0.04}, {Value = 'Engi'}}},
            {Action = 'Mex', Text = {{Value = '[M] ', Color = '4a8a0a', Size = 0.04}, {Value = 'Mex'}}},
            {Action = 'Power', Text = {{Value = '[P] ', Color = '4a8a0a', Size = 0.04}, {Value = 'Power'}}},
            {Action = 'PD', Text = {{Value = '[P] ', Color = 'e3cd09', Size = 0.04}, {Value = 'PD'}}},
            {Action = 'Shields', Text = {{Value = '[S] ', Color = 'e3cd09', Size = 0.04}, {Value = 'Shield'}}},
            {Action = 'Naval', Text = {{Value = '[N] ', Color = '7dd1ca', Size = 0.04}, {Value = 'Naval'}}},
            {Action = 'Destros', Text = {{Value = '[D] ', Color = '7dd1ca', Size = 0.04}, {Value = 'Destr'}}},
            {Action = 'Cruiser', Text = {{Value = '[C] ', Color = '7dd1ca', Size = 0.04}, {Value = 'Cruiser'}}},
            {Action = 'SMD', Text = {{Value = '[S] ', Color = '8f0909', Size = 0.04}, {Value = 'SMD'}}},
            {Action = 'EXP', Text = {{Value = '[E] ', Color = '8f0909', Size = 0.04}, {Value = 'EXP'}}},
            {Action = 'ACU', Text = {{Value = '[A] ', Color = 'ffffff', Size = 0.04}, {Value = 'ACU'}}},
            {Action = 'Units', Text = {{Value = '[U] ', Color = 'ffffff', Size = 0.04}, {Value = 'Unit'}}}
        }
    },
    TargetPriorityExtended = {
        Mods = {{
            Name = 'Advanced Target Priorities',
            Location = '/mods/advanced target priorities'
        }},
        Position = 'MOUSE',
        Ui = {
            Radius = 0.3,
            Middle = {
                Type = 'SIMPLE',
                Texture = 'DEFAULT',
                Radius = 0.075,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'TARGET_PRIORITY',
                Action = 'Default',
                Text = {
                    Value = 'DEF',
                    Size = 0.03,
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
                ActionType = 'TARGET_PRIORITY',
                Text = {
                    Size = 0.025,
                    Color = 'ffffff'
                }
            }
        },
        Items = {
            {Action = 'Mex', Text = {{Value = '[M] ', Color = '4db366', Size = 0.03}, {Value = 'Mex'}}},
            {Action = 'Power', Text = {{Value = '[W] ', Color = '4db366', Size = 0.03}, {Value = 'Power'}}},
            {Action = 'PD', Text = {{Value = '[P] ', Color = 'e3cd09', Size = 0.03}, {Value = 'PD'}}},
            {Action = 'Factory', Text = {{Value = '[F] ', Color = 'e3cd09', Size = 0.03}, {Value = 'Fact'}}},
            {Action = 'Shields', Text = {{Value = '[S] ', Color = 'e3cd09', Size = 0.03}, {Value = 'Shield'}}},
            {Action = 'Arty', Text = {{Value = '[A] ', Color = '804db3', Size = 0.03}, {Value = 'Arty'}}},
            {Action = 'AA', Text = {{Value = '[F] ', Color = '804db3', Size = 0.03}, {Value = 'AA'}}},
            {Action = 'Gunship', Text = {{Value = '[G] ', Color = '804db3', Size = 0.03}, {Value = 'Gunship'}}},
            {Action = 'Naval', Text = {{Value = '[N] ', Color = '7dd1ca', Size = 0.03}, {Value = 'Naval'}}},
            {Action = 'Destros', Text = {{Value = '[D] ', Color = '7dd1ca', Size = 0.03}, {Value = 'Destr'}}},
            {Action = 'Cruiser', Text = {{Value = '[C] ', Color = '7dd1ca', Size = 0.03}, {Value = 'Cruiser'}}},
            {Action = 'Bships', Text = {{Value = '[B] ', Color = '7dd1ca', Size = 0.03}, {Value = 'Bship'}}},
            {Action = 'SACU', Text = {{Value = '[S] ', Color = '8f0909', Size = 0.03}, {Value = 'SACU'}}},
            {Action = 'SMD', Text = {{Value = '[S] ', Color = '8f0909', Size = 0.03}, {Value = 'SMD'}}},
            {Action = 'EXP', Text = {{Value = '[E] ', Color = '8f0909', Size = 0.03}, {Value = 'EXP'}}},
            {Action = 'ACU', Text = {{Value = '[A] ', Color = 'ffffff', Size = 0.03}, {Value = 'ACU'}}},
            {Action = 'Units', Text = {{Value = '[U] ', Color = 'ffffff', Size = 0.03}, {Value = 'Unit'}}},
            {Action = 'Engies', Text = {{Value = '[E] ', Color = '4db366', Size = 0.03}, {Value = 'Engi'}}},
        }
    },
    Util = {
        Position = 'MOUSE',
        Ui = {
            Radius = 0.25,
            Middle = {
                Type = 'EMPTY',
                Texture = 'DEFAULT',
                Radius = 0.095,
                Alpha = 0.3,
                Hover = {
                    Alpha = 0.7
                },
                ActionType = 'KEY_ACTION',
                Action = 'select_commander',
                Text = {
                    Value = 'ACU',
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
                ActionType = 'KEY_ACTION',
                Text = {
                    Size = 0.03,
                    Color = 'ffffff'
                }
            }
        },
        Items = {
            {Action = 'select_naval', Text = {{Value = '[U] ', Color = '4db366', Size = 0.04}, {Value = 'Naval'}}},
            {Action = ActionHandlerGeneric.SelectLandAnriAir, ActionType='GENERIC', Text = {{Value = '[U] ', Color = '4db366', Size = 0.04}, {Value = 'AA'}}},
            {Action = 'select_all_air_factories', Text = {{Value = '[F] ', Color = '7dd1ca', Size = 0.04}, {Value = 'Air'}}},
            {Action = 'select_all_land_factories', Text = {{Value = '[F] ', Color = '7dd1ca', Size = 0.04}, {Value = 'Land'}}},
            {Action = ActionHandlerGeneric.GiveEnergy, ActionType='GENERIC', Text = {{Value = '[G] ', Color = '7f32a8', Size = 0.04}, {Value = 'Energy'}}},
            {Action = ActionHandlerGeneric.GiveMass, ActionType='GENERIC', Text = {{Value = '[G] ', Color = '7f32a8', Size = 0.04}, {Value = 'Mass'}}},
            {Action = ActionHandlerGeneric.SelectSnipeUnits, ActionType='GENERIC', Text = {{Value = '[A] ', Color = '8f0909', Size = 0.04}, {Value = 'Snipe'}}},
            {Action = 'select_air_transport', Text = {{Value = '[A] ', Color = '8f0909', Size = 0.04}, {Value = 'Trans'}}},
            {Action = 'select_anti_air_fighters', Text = {{Value = '[A] ', Color = '8f0909', Size = 0.04}, {Value = 'Fighter'}}},
            {Action = 'select_all_idle_airscouts', Text = {{Value = '[I] ', Color = 'e3cd09', Size = 0.04}, {Value = 'Scout'}}},
            {Action = ActionHandlerGeneric.SelectIdleEngineerOnScreen, ActionType='GENERIC', Text = {{Value = '[I] ', Color = 'e3cd09', Size = 0.04}, {Value = 'Engineer'}}},
            {Action = 'select_land', Text = {{Value = '[U] ', Color = '4db366', Size = 0.04}, {Value = 'Land'}}}
        }
    }
}
