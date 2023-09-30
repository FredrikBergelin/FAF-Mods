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

-- Select nearest / onscreen / all land intel units
function MultiSelectLandIntel()
    local uniqueString = "MultiSelectTorpedoBombers"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute 'UI_SelectByCategory +inview LAND INTELLIGENCE'
        else
            ConExecute 'UI_SelectByCategory LAND INTELLIGENCE'
        end
    else
        totalClicksMultiSelect = 0
        ConExecute 'UI_SelectByCategory +nearest LAND INTELLIGENCE'
    end

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all land bombers, not torpedo
function MultiSelectTorpedoBombers()
    local uniqueString = "MultiSelectTorpedoBombers"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute 'UI_SelectByCategory +inview AIR ANTINAVY'
        else
            ConExecute 'UI_SelectByCategory AIR ANTINAVY'
        end
    else
        totalClicksMultiSelect = 0
        ConExecute 'UI_SelectByCategory +nearest AIR ANTINAVY'
    end

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all land bombers, not torpedo
function MultiSelectIntelPlanes()
    local uniqueString = "MultiSelectDedicatedFighters"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute 'UI_SelectByCategory +inview AIR INTELLIGENCE'
        else
            ConExecute 'UI_SelectByCategory AIR INTELLIGENCE'
        end
    else
        totalClicksMultiSelect = 0
        ConExecute 'UI_SelectByCategory +nearest AIR INTELLIGENCE'
    end

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all land bombers, not torpedo
function MultiSelectDedicatedFighters()
    local uniqueString = "MultiSelectDedicatedFighters"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute 'UI_SelectByCategory +inview AIR HIGHALTAIR ANTIAIR'
        else
            ConExecute 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR'
        end
    else
        totalClicksMultiSelect = 0
        ConExecute 'UI_SelectByCategory +nearest AIR HIGHALTAIR ANTIAIR'
    end

    SelectUnits(EntityCategoryFilterDown(categories.ANTIAIR - categories.BOMBER, GetSelectedUnits()))

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all land bombers, not torpedo
function MultiSelectGunships()
    local uniqueString = "MultiSelectGunships"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute 'UI_SelectByCategory +inview AIR GROUNDATTACK'
        else
            ConExecute 'UI_SelectByCategory AIR GROUNDATTACK'
        end
    else
        totalClicksMultiSelect = 0
        ConExecute 'UI_SelectByCategory +nearest AIR GROUNDATTACK'
    end

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all land bombers, not torpedo
function MultiSelectLandBombers()
    local uniqueString = "MultiSelectLandBombers"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute("UI_SelectByCategory +inview AIR BOMBER")
        else
            ConExecute("UI_SelectByCategory AIR BOMBER")
        end
    else
        totalClicksMultiSelect = 0
        ConExecute("UI_SelectByCategory +nearest AIR BOMBER")
    end

    SelectUnits(EntityCategoryFilterDown(categories.BOMBER - categories.ANTINAVY, GetSelectedUnits()))

    SetClickData(uniqueString, currentTick)
end

-- Select nearest / onscreen / all transports.
function MultiSelectTransports()
    local uniqueString = "MultiSelectTransports"
    local currentTick = GameTick()

    if IsDoubleClick(uniqueString, currentTick, lastClickMultiSelect) then
        if totalClicksMultiSelect == 1 then
            ConExecute("UI_SelectByCategory +inview AIR TRANSPORTATION")
        else
            ConExecute("UI_SelectByCategory AIR TRANSPORTATION")
        end
    else
        totalClicksMultiSelect = 0
        ConExecute("UI_SelectByCategory +nearest AIR TRANSPORTATION")
    end

    SetClickData(uniqueString, currentTick)
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
    local selection = GetSelectedUnits()

    local launchers = {}
    if selection and not table.empty(selection) then
        from(selection).foreach(function(i, unit)
            if unit:IsInCategory("TACTICALMISSILEPLATFORM") and unit:IsInCategory("STRUCTURE") then
                table.insert(launchers, unit)
            end
        end)
    end

    if table.empty(launchers) then
        ConExecute "UI_SelectByCategory STRUCTURE TACTICALMISSILEPLATFORM"
    end

    ConExecute "StartCommandMode order RULEUCC_Tactical"
end

function SelectSmlFireMissile()
    local selection = GetSelectedUnits()

    local launchers = {}
    if selection and not table.empty(selection) then
        from(selection).foreach(function(i, unit)
            if unit:IsInCategory("NUKE") then
                -- TODO: or in category naval + strategic, and has missiles loaded (do same for tml?)
                table.insert(launchers, unit)
            end
        end)
    end

    if table.empty(launchers) then
        ConExecute "UI_SelectByCategory NUKE"
    end

    ConExecute "StartCommandMode order RULEUCC_Nuke"
end
