local KeyMapper = import('/lua/keymap/keymapper.lua')
local modFolder = 'McBoomsMod'
local virtualCreateUI = CreateUI

local MainBeat = import('/mods/'..modFolder..'/modules/MainBeat.lua')
local MexPanelInstance
local isReplay

function ModMainUpdate()
	if not isReplay then
		MainBeat.UpdateBeat()
		MexPanelInstance:update()
	end
end

function CreateUI(_isReplay)
	virtualCreateUI(_isReplay)

	isReplay = _isReplay

	MainBeat.Init()

	MexPanelInstance = import('/mods/' .. modFolder .. '/modules/ui/MexPanel.lua').getInstance()

	MexPanelInstance:onCreate(isReplay, 0, 220)

	AddBeatFunction(ModMainUpdate)
end