do
    table.insert(options.gameplay.items, 2,
    {
        title = "Zoom Acceleration (Coarse)",
        key = 'gui_zoom_speed_large',
        type = 'slider',
        default = 5,
        set = function(key,value,startup)
            LOG("Setting cam_ZoomSpeedLarge")
            ConExecute("cam_ZoomSpeedLarge " .. tostring(value))
        end,
        custom = {
            min = 1,
            max = 100,
            inc = 1,
        },
    })
    table.insert(options.gameplay.items, 3,
    {
        title = "Zoom Acceleration (Fine)",
        key = 'gui_zoom_speed_small',
        type = 'slider',
        default = 5,
        set = function(key,value,startup)
            LOG("Setting cam_ZoomSpeedSmall")
            ConExecute("cam_ZoomSpeedSmall " .. tostring(value / 10))
        end,
        custom = {
            min = 1,
            max = 100,
            inc = 1,
        },
    })
end
