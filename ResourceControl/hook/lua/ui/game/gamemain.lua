import('/mods/ResourceControl/modules/linq.lua')

local _CreateUI = CreateUI
function CreateUI(isReplay)
	_CreateUI(isReplay)
	import('/mods/ResourceControl/modules/ui.lua').init()
	import('/mods/ResourceControl/modules/ecopanel.lua').setEnabled(true)
	import('/mods/ResourceControl/modules/overlays.lua').Init()
end
