local originalCreateUI = CreateUI 
local doMiniMapZoom = import('/mods/ZeP_MiniMapZoom/MiniMapZoom.lua').HideMiniMap

do  
  AddBeatFunction(doMiniMapZoom)


end

