-- Select ACU / Overcharge mode / Goto ACU if not on screen
function ACUSelectOCGoto()
    local selection = GetSelectedUnits()
    if not table.empty(selection) and table.getn(selection) == 1 and selection[1]:IsInCategory "COMMAND" then
        import("/lua/ui/game/orders.lua").EnterOverchargeMode()
    else
        ConExecute "UI_SelectByCategory +nearest COMMAND"
        local acu = GetSelectedUnits()
        local worldview = import("/lua/ui/game/worldview.lua").viewLeft
        if acu and not worldview:GetScreenPos(acu[1]) then
            ConExecute "UI_SelectByCategory +nearest +goto COMMAND"
        end
    end
end

-- MultiSelect (click multiple time to extend selection. Eg: Nearest / OnScreen / All)
local lastClickMultiSelect = -9999
local totalClicksMultiSelect = 0
local lastMultiClickUniqueString = nil

local function IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect)
	return lastMultiClickUniqueString == uniqueString and currentTick < lastClickMultiSelect + 5
end

local function SetClickData(uniqueString, currentTick)
	lastMultiClickUniqueString = uniqueString
	totalClicksMultiSelect = totalClicksMultiSelect + 1
	lastClickMultiSelect = currentTick
end

-- Select nearest / onscreen / all engineers
function MultiSelectEngineers(techlevel, onlyIdle)
    local idleText = " "
    if onlyIdle then idleText = " +idle " end
    local uniqueString = "MultiSelectEngineers" .. techlevel .. idleText
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute("UI_SelectByCategory +inview" .. idleText .. "BUILTBYTIER3FACTORY ENGINEER TECH" .. techlevel)
        else
            ConExecute("UI_SelectByCategory" .. idleText .. "BUILTBYTIER3FACTORY ENGINEER TECH" .. techlevel)
        end
    else
        totalClicksMultiSelect = 0
        ConExecute("UI_SelectByCategory +nearest" .. idleText .. "BUILTBYTIER3FACTORY ENGINEER TECH" .. techlevel)
    end

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all SACU
function MultiSelectSACU(onlyIdle)
    local idleText = " "
    if onlyIdle then idleText = " +idle " end
    local uniqueString = "MultiSelectSACU" .. idleText
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute("UI_SelectByCategory +inview" .. idleText .. "SUBCOMMANDER")
        else
            ConExecute("UI_SelectByCategory" .. idleText .. "SUBCOMMANDER")
        end
    else
        totalClicksMultiSelect = 0
        ConExecute("UI_SelectByCategory +nearest" .. idleText .. "SUBCOMMANDER")
    end

	SetClickData(uniqueString, currentTick)
end

local similarUnitsBlueprints = {}
function MultiSelectSimilarUnits()
	local uniqueString = "MultiSelectSimilarUnits"
	local currentTick = GameTick()

	local str = ''
	if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
		if totalClicksMultiSelect == 1 then

			similarUnitsBlueprints.foreach(function(k,v) str = str .. v.BlueprintId .. "," end)

			ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to

		end
	else
		local units = GetSelectedUnits()
		if (units ~= nil) then
			similarUnitsBlueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()

			similarUnitsBlueprints.foreach(function(k,v) str = str .. "+inview " .. v.BlueprintId .. "," end)

			ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to

			totalClicksMultiSelect = 0
		else
			lastClickMultiSelect = -9999
		end
	end

	SetClickData(uniqueString, currentTick)
end

-- MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT
function MultiSelectDirectFireLandUnits()
	import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT')
end

-- (MOBILE LAND -DIRECTFIRE -ENGINEER) +(MOBILE LAND SCOUT)
function MultiSelectSupportLandUnits()
	import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND -DIRECTFIRE -ENGINEER')
	ForkThread(function()
		ConExecute("Ui_SelectByCategory +add +inview MOBILE LAND SCOUT")
	end)
end

function SelectNearestIdleTransportOrTransport()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits then
        ConExecute "StartCommandMode order RULEUCC_Transport"
    else
        ConExecute "UI_SelectByCategory +nearest +idle AIR TRANSPORTATION"
    end
end

function SelectTmlFireMissile()
    LOG("SelectTmlFireMissile")
    local selection = GetSelectedUnits()

    local tml = {}
    if selection and not table.empty(selection) then
        from(selection).foreach(function(i, unit)
            if unit:IsInCategory("TACTICALMISSILEPLATFORM") and unit:IsInCategory("STRUCTURE") then
                table.insert(tml, unit)
            end
        end)
    end

    if table.empty(tml) then
        ConExecute "UI_SelectByCategory STRUCTURE TACTICALMISSILEPLATFORM"
    end

    ConExecute "StartCommandMode order RULEUCC_Tactical"
end

-- -- Select nearest idle engineer/Reclaim mode
-- function ReclaimSelectIDLENearestT1()
--     local selection = GetSelectedUnits()
--     if table.empty(selection) then
--         ConExecute "UI_SelectByCategory +inview +nearest +idle ENGINEER TECH1"
--     else
--         ConExecute "StartCommandMode order RULEUCC_Reclaim"
--     end
-- end

-- -- Select nearest air scout/build sensors
-- function SelectAirScoutBuildIntel()
--     local selectedUnits = GetSelectedUnits()
--     if selectedUnits then
--         import("/lua/keymap/hotbuild.lua").buildAction "Sensors"
--     else
--         ConExecute "UI_SelectByCategory +nearest AIR INTELLIGENCE"
--     end
-- end
