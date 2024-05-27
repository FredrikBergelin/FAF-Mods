local oldSetLayout = SetLayout
function SetLayout()
    local controls = import('/lua/ui/game/minimap.lua').controls
	oldSetLayout()
	local clearTexture = '/mods/Advanced mini map/textures/clear.dds'
	
    local windowTextures = {
        tl = clearTexture,
        tr = clearTexture,
        tm = clearTexture,
        ml = clearTexture,
        m = clearTexture,
        mr = clearTexture,
        bl = clearTexture,
        bm = clearTexture,
        br = clearTexture,
        borderColor = 'ff415055',
    }
    controls.displayGroup:ApplyWindowTextures(windowTextures)
	
    -- controls.miniMap.GlowTL:SetTexture(clearTexture)
    -- controls.miniMap.GlowTR:SetTexture(clearTexture)
    -- controls.miniMap.GlowBR:SetTexture(clearTexture)
    -- controls.miniMap.GlowBL:SetTexture(clearTexture)
    -- controls.miniMap.GlowL:SetTexture(clearTexture)
    -- controls.miniMap.GlowR:SetTexture(clearTexture)
    -- controls.miniMap.GlowT:SetTexture(clearTexture)
    -- controls.miniMap.GlowB:SetTexture(clearTexture)
	
    controls.miniMap.DragTL:SetTexture(clearTexture)
    controls.miniMap.DragTR:SetTexture(clearTexture)
    controls.miniMap.DragBL:SetTexture(clearTexture)
    controls.miniMap.DragBR:SetTexture(clearTexture)
			
    controls.miniMap.DragTL.textures = {up = clearTexture,
            down = clearTexture,
            over = clearTexture}
            
    controls.miniMap.DragTR.textures = {up = clearTexture,
            down = clearTexture,
            over = clearTexture}
            
    controls.miniMap.DragBL.textures = {up = clearTexture,
            down = clearTexture,
            over = clearTexture}
            
    controls.miniMap.DragBR.textures = {up = clearTexture,
            down = clearTexture,
            over = clearTexture}
    local clientGroup = controls.displayGroup:GetClientGroup()
	
	--Fixed left side
    LayoutHelpers.AtLeftBottomIn(controls.miniMap.GlowBL, clientGroup, -2, -2) -- 0,-2
    LayoutHelpers.AtLeftTopIn(controls.miniMap.GlowTL, clientGroup, -2, -4) -- 0,-4
	
    LayoutHelpers.AtLeftTopIn(controls.miniMap, clientGroup, 8, 4)
    LayoutHelpers.AtRightBottomIn(controls.miniMap, clientGroup, 8, 6)
end