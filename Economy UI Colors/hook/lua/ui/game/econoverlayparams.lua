EconOverlayParams = {
    positiveColor = import('/lua/ui/game/economy.lua').GUI.incomeColor,
    negativeColor = import('/lua/ui/game/economy.lua').GUI.expenseColor,
    leftTexture = import("/lua/ui/uiutil.lua").UIFile("/game/economic-overlay/econ_bmp_l.dds"),
    midTexture = import("/lua/ui/uiutil.lua").UIFile("/game/economic-overlay/econ_bmp_m.dds"),
    rightTexture = import("/lua/ui/uiutil.lua").UIFile("/game/economic-overlay/econ_bmp_r.dds"),
    fontName = "Ariel",
    fontSize = 9,
    energyTopOffset = 13.0,
    massTopOffset = 1.0,
}