do
    local Prefs = import('/lua/user/prefs.lua')
	local options = Prefs.GetFromCurrentProfile('options')
    if options.gui_zoom_speed_large then
        LOG("Restoring cam_ZoomSpeedLarge")
        ConExecute("cam_ZoomSpeedLarge " .. tostring(options.gui_zoom_speed_large))
    end
    if options.gui_zoom_speed_small then
        LOG("Restoring cam_ZoomSpeedSmall")
        ConExecute("cam_ZoomSpeedSmall " .. tostring(options.gui_zoom_speed_small / 10))
    end
end