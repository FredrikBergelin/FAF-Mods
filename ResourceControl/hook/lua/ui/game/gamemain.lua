local originalCreateUI = CreateUI

function CreateUI(isReplay)
	originalCreateUI(isReplay)
	import('/mods/ResourceControl/modules/overlays.lua').Init()
end
