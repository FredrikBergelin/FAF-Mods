local CamInit = 600;
local mapSizeMax = 400;
local posX = 100;
local posY = 157;
-- CamInit by defaut for map size of 512
local mapSize = SessionGetScenarioInfo().size[1]
local CamInitMult = (mapSize/512)
local CamInitForThisMap = CamInit * CamInitMult

function HideMiniMap()
	local cam = GetCamera('WorldCamera')
	if cam then
		local curzoom = cam:GetZoom() 
		local maxzoom = cam:GetMaxZoom()
		local Targzoom = cam:GetTargetZoom()
	   local zoomRatio = (cam:GetTargetZoom() / cam:GetMaxZoom())
		--controls.miniMap.GlowTL = Bitmap(controls.miniMap)
		
		if zoomRatio > 0.5 then
			zoomRatio = 0.5
			end
		--import('/lua/ui/game/minimap.lua').resizeMiniMap(1-zoomRatio,mapSizeMax,posX,posY)  
		if curzoom <= CamInitForThisMap then
			if import('/lua/ui/game/minimap.lua').GetMinimapState() == false then
					import('/lua/ui/game/minimap.lua').ToggleMinimap()  
			end 
			else
				if import('/lua/ui/game/minimap.lua').GetMinimapState() == true then
					import('/lua/ui/game/minimap.lua').ToggleMinimap()  
			end
		end
	end


	
	
end
