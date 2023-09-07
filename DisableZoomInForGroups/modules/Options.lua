local Options = UMT.Options
local OptionVar = UMT.OptionVar.Create

local modName = "DisableZoomInForGroups"

---@param option string
---@return OptionVar
local function ArialFontOptionVar(option)
    return OptionVar(modName, option, "Arial")
end

zoomLevel = OptionVar(modName, "zoomLevel", 20)


function Init(isReplay)

    local UIUtil = import('/lua/ui/uiutil.lua')

    Options.AddOptions(modName .. "General", "DisableZoomInForGroups",
        {
            Options.Slider("zoomLevel", 1, 3000, 1, zoomLevel, 4),
        })
end