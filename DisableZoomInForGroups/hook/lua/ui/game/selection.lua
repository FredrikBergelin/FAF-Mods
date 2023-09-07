local Options = import("/mods/DisableZoomInForGroups/modules/Options.lua")

function DoubleTapBehavior(name, units)
    ---@type SelectionSetDoubleTapBehavior
    local doubleTapbehavior = Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_behavior')

    -- don't do anything
    if doubleTapbehavior == 'none' then
        return
    end

    -- time window in which we consider it to be a double tab
    local curTime = GetSystemTimeSeconds()
    local diffTime = curTime - lastSelectionTime
    if diffTime > 0.001 * Prefs.GetFromCurrentProfile('options.selection_sets_double_tap_decay') then
        lastSelectionName = nil
    end
    lastSelectionTime = curTime

    -- move camera to the selection in the case of a double tab
    if name == lastSelectionName then

        if next(units) then

            -- retrieve camera and its settings
            local cam = GetCamera('WorldCamera')
            local settings = cam:SaveSettings()

            UIZoomTo(units)
            cam:SetZoom(Options.zoomLevel(), 0)

            -- only zoom out, but not in
            if doubleTapbehavior == 'translate-zoom-out-only' then
                local zoom = cam:GetZoom()
                if zoom < settings.Zoom then
                    cam:SetZoom(settings.Zoom, 0)
                end

                -- do not adjust the zoom
            elseif doubleTapbehavior == 'translate' then
                cam:SetZoom(settings.Zoom, 0)
            end

            -- guarantee it looks like it should
            cam:RevertRotation()
        end

        lastSelectionName = nil
    else
        lastSelectionName = name
    end
end