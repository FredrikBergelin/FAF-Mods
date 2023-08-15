 
local UIUtil        = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local orgCreate = Create
function Create(parent)
    orgCreate(parent)

    -- local GUI = GetFrame(0)
    -- GUI.TestBtn = UIUtil.CreateButtonWithDropshadow(GUI, '/BUTTON/medium/', "TEST")
    -- GUI.TestBtn.Width:Set(90)
    -- GUI.TestBtn.Depth:Set(1000)
    -- GUI.TestBtn.OnClick = function()
    --     WARN('TEST.OnClick') 
    --     import('/mods/SupremeScoreBoard2/modules/test.lua').RunTest()
    -- end
    -- LayoutHelpers.LeftOf(GUI.TestBtn, controls.parent) 
    -- LayoutHelpers.AtTopIn(GUI.TestBtn, GUI, 15)
end
 