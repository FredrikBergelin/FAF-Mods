local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')

local modFolder = 'McBoomsMod'

local ClickFunc = import('/mods/' .. modFolder .. '/modules/util/Util.lua').ClickFunc

MexRowButton = {}

function MexRowButton:new(_parent, _panel, _isUpgrading, _tech)
    local o = {}
    setmetatable(o,self)
    self.__index = self

    o.parent = _parent
    o.panel = _panel
    o.isUpgrading = _isUpgrading
    o.rowControl = false
    o.isExpanded = true
    o.tech = _tech

    local buttonBackground = UIUtil.SkinnableFile('/game/tab-l-btn/tab-close_btn_up.dds') --'/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
    o.bg = Bitmap(_parent, buttonBackground)

    o.bg.Height:Set(44)
    o.bg.Width:Set(30) --25

    o.bg.texture = Bitmap(o.bg)
    o.bg.texture.Height:Set(44)
    o.bg.texture.Width:Set(30)
    LayoutHelpers.AtLeftTopIn(o.bg.texture, o.bg, 0, 0)

    o.tooltipHeader = "Expander"
    o.tooltipText = "Use the following options to toggle multiple mex rows.\r\nSHIFT+LEFTCLICK = Same row type\r\nCTRL+LEFTCLICK = All rows\r\nALT+LEFTCLICK = Same tech"

    -- we need to change the tooltip text dynamically for this button:
    o.bg.HandleEvent = function(self, event)
        if o.tooltipHeader and o.tooltipText then
            if event.Type == 'MouseEnter' then
                ToolTip.CreateMouseoverDisplay(self,
                        {
                            text = o.tooltipHeader,
                            body = o.tooltipText
                        }, false, true
                )
            elseif event.Type == 'MouseExit' then
                ToolTip.DestroyMouseoverDisplay()
            end
        end
        return ClickFunc(self, event)
    end

    o.bg.texCollapse = UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_up.dds')
    o.bg.texExpand = UIUtil.UIFile('/game/tab-l-btn/tab-open_btn_up.dds')
    o.bg.texCollapseOver = UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_down.dds')
    o.bg.texExpandOver = UIUtil.UIFile('/game/tab-l-btn/tab-open_btn_down.dds')
    o.bg.texture:SetTexture(o.bg.texExpand)
    o.bg.mouseStateOver = false

    o.bg.onClickCustom = function(_event)
        --print("onclick custom handled")
        if _event.Type == 'MouseEnter' then
            o.bg.texture:SetTexture(o.isExpanded and o.bg.texExpandOver or o.bg.texCollapseOver)
            o.bg.mouseStateOver = true
        elseif _event.Type == 'MouseExit' then
            o.bg.texture:SetTexture(o.isExpanded and o.bg.texExpand or o.bg.texCollapse)
            o.bg.mouseStateOver = false
        elseif _event.Type == 'ButtonPress' then
            o:setExpanded(not o.isExpanded)

            if o.tech<=3 then
                if _event.Modifiers.Shift then
                    o.panel:setExpanders("type", o, o.isExpanded)
                elseif _event.Modifiers.Ctrl then
                    o.panel:setExpanders("all", o, o.isExpanded)
                elseif _event.Modifiers.Alt then
                    o.panel:setExpanders("tech", o, o.isExpanded)
                end
            end
            --o.isExpanded = not o.isExpanded
            --o.bg.texture:SetTexture(o.isExpanded and (o.bg.mouseStateOver and o.bg.texExpandOver or o.bg.texExpand) or (o.bg.mouseStateOver and o.bg.texCollapseOver or o.bg.texCollapse))
        end
    end

    return o
end

function MexRowButton:update()
    --if not self.tooltipSet and self.tooltipText then
    --    ToolTip.AddControlTooltip(self.bg, {text="Expander", body=self.tooltipText})
    --    self.tooltipSet = true
    --end
end

function MexRowButton:setExpanded(_b)
	self.isExpanded = _b
    local tex = self.bg.texExpand
    if self.isExpanded then
        tex = self.bg.mouseStateOver and self.bg.texExpandOver or self.bg.texExpand
    else
        tex = self.bg.mouseStateOver and self.bg.texCollapseOver or self.bg.texCollapse
    end
    self.bg.texture:SetTexture(tex)
end

function MexRowButton:getExpanded()
	return self.isExpanded
end

function MexRowButton:getControl()
	return self.bg
end