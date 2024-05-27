local modpath = '/mods/ui-party'
local uiPartyUi = import(modpath..'/modules/ui.lua')

local KeyMapper = import('/lua/keymap/keymapper.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local IntegerSlider = import('/lua/maui/slider.lua').IntegerSlider
local Tooltip = import('/lua/ui/game/tooltip.lua')

local settings = import(modpath..'/modules/settings.lua')
local savedPrefs = nil
local curPrefs = nil
local curY = 0
local curX = 30

local uiPanel = {
	main = nil,
	okButton = nil,
	cancelButton = nil,
}

local uiPanelSettings = {
	width = 500,
	textSize = {
		headline = 20,
		section = 16,
		option = 12,
	},
}

function CreateResetKeysControl(sv)
	local btn = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'Set', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
    Tooltip.AddButtonTooltip(btn, 'UIP_' .. sv.key)
	btn.OnClick = function(self)
		UIUtil.QuickDialog(uiPanel.main, "Really set the keys bindings?",
           "Yes", ResetKeys,
            "No", nil,
            nil, nil,
            true, 
            {escapeButton = 2, enterButton = 1, worldCover = false})
	end
	return btn
end

function ResetKeys()
	local keys = {
		['V'] = 'Select next split group',
		['Shift-V'] = 'Select next split group (shift)',
        ['Ctrl-Shift-Alt-V'] = 'Reselect Split Units',
        ['Ctrl-Alt-V'] = 'Reselect Ordered Split Units',
	}
	
	range(2,10).foreach(function(k,v)
		local action = 'Split selection into ' .. v .. ' groups'
		if v == 10 then v = 0 end
		local key = 'Ctrl-Alt-' .. v
		keys[key] = action
	end)	

	range(1,10).foreach(function(k,v)
		local action = 'Select split group ' .. v
		if v == 10 then v = 0 end
		local key = 'Alt-' .. v
		keys[key] = action
	end)

	from(keys).foreach(function(k,v)		
	    KeyMapper.SetUserKeyMapping(k,nil, v)
	end)

	UIUtil.ShowInfoDialog(uiPanel.main, "Bindings set", "Ok", nil, true)
end

function createPrefsUi()
	if uiPanel.main then
		uiPanel.main:Destroy()
		uiPanel.main = nil
		return
	end

	-- copy configs to local, to not mess with the original ones until they should save
	savedPrefs = settings.getPreferences()
	curPrefs = table.deepcopy(savedPrefs, {})
	
	-- make the ui	
	createMainPanel()
	curY = 0
	
	LayoutHelpers.CenteredAbove(UIUtil.CreateText(uiPanel.main, "ui party", uiPanelSettings.textSize.headline, UIUtil.bodyFont), uiPanel.main, curY - 30)
	curY = curY + 30
	createOptions(curY)
	
	curY = curY + 10
	
	createOkCancelButtons()
	uiPanel.main.Height:Set(curY + 30)
end


---------------------------------------------------------------------


function createMainPanel()
	posX = 100
	posY = 100
	
	uiPanel.main = Bitmap(GetFrame(0))
	uiPanel.main.Depth:Set(1199)
	LayoutHelpers.AtLeftTopIn(uiPanel.main, GetFrame(0), posX, posY)
	uiPanel.main:InternalSetSolidColor('dd000000')
	uiPanel.main.Width:Set(uiPanelSettings.width)
	uiPanel.main:Show()
end


function createOptions()	
	---- left side options
	
	local settingGroups = settings.getSettingDescriptions()

	from(settingGroups).foreach(function(gk, kv) 
	
		if kv.name ~= "Hidden" then

			curY = curY + 5
			LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, kv.name, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX, curY)
			curY = curY + 20

			from(kv.settings).foreach(function(sk, sv) 
	
				local indent = 5 + (sv.indent or 0) * 15
				

				if sv.type == "bool" then
					createSettingCheckbox(curX+indent, curY, 13, {"global", sv.key}, sv.name, sv.key)
				elseif sv.type == "number" then
					createSettingsSliderWithText(curX+indent, curY, sv.name, sv.min, sv.max, sv.valMult, {"global", sv.key}, sv.key)
				elseif sv.type == "custom" then
					LayoutHelpers.AtLeftTopIn(sv.control(sv), uiPanel.main, curX+indent, curY)
					LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, sv.name, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+100+indent, curY+7)
					curY = curY + 30
				else
					UipLog("Unknown settings type: " .. sv.type)
				end
			end)
		end
	end)

end




function createOkCancelButtons()
	
	local UIUtil = import('/lua/ui/uiutil.lua')

	local btnOk = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'OK', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
	LayoutHelpers.AtLeftTopIn(btnOk, uiPanel.main, curX, curY)
	btnOk.OnClick = function(self)
		settings.setAllGlobalValues(curPrefs.global)
		uiPartyUi.reloadAndApplyGlobalConfigs()
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end

	local btnCancel = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'Cancel', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
	LayoutHelpers.AtLeftTopIn(btnCancel, uiPanel.main, curX + 100, curY)
	btnCancel.OnClick = function(self)
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end

	curY = curY + 30
end


---------------------------------------------------------------------


function createSettingCheckbox(posX, posY, size, args, text, key)
	local value = curPrefs
	local argsCopy = args
	for _,v in args do
		value = value[v]
	end

	local box = UIUtil.CreateCheckbox(uiPanel.main, '/CHECKBOX/')
    Tooltip.AddCheckboxTooltip(box, 'UIP_' .. key)
	box.Height:Set(size)
	box.Width:Set(size)
	box:SetCheck(value, true)
	
	box.OnClick = function(self)
		if(box:IsChecked()) then
			setCurPrefByArgs(argsCopy, false)
			value = false
			box:SetCheck(false, true)
		else
			setCurPrefByArgs(argsCopy, true)
			value = true
			box:SetCheck(true, true)
		end
	end
	
	LayoutHelpers.AtLeftTopIn(box, uiPanel.main, posX, posY+1)
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, text, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, posX+15, curY)
	curY = curY + 20
	
end

function createSettingsSliderWithText(posX, posY, text, minVal, maxVal, valMult, args, key)
	
	-- value
	local value = curPrefs
	for i, v in args do
		value = value[v]
	end
	if value < minVal*valMult then
		value = minVal*valMult
	elseif value > maxVal*valMult then
		value = maxVal*valMult
	end
	
	-- value text
	local valueText = UIUtil.CreateText(uiPanel.main, string.format("%g",value), uiPanelSettings.textSize.option, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(valueText, uiPanel.main, posX + 350, posY)
	
	local slider = IntegerSlider(uiPanel.main, false, minVal,maxVal, 1, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds'))  
	LayoutHelpers.AtLeftTopIn(slider, uiPanel.main, posX + 150, posY)
	slider:SetValue(value/valMult)
	slider.OnValueChanged = function(self, newValue)
		
		valueText:SetText(string.format("%g",newValue*valMult))
		setCurPrefByArgs(args, newValue*valMult)
	end
    Tooltip.AddCheckboxTooltip(slider, 'UIP_' .. key)


	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, text, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+20, curY)

	curY = curY + 20

end



function setCurPrefByArgs(args, value)	
	num = table.getn(args)
	if num==2 then
		curPrefs[args[1]][args[2]] = value
	end
	if num==4 then
		curPrefs[args[1]][args[2]][args[3]][args[4]] = value
	end
end