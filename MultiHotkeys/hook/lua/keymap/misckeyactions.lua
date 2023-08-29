local KeyMapper = import("/lua/keymap/keymapper.lua")

local displayOrder = 999
local function getDisplayOrder()
    displayOrder = displayOrder + 1
    return displayOrder
end

local displayCategory = "MultiHotkeys"

KeyMapper.SetUserKeyAction("Upgrade selected structures / Cycle templates for engineers", {
    action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").UpgradeSelectedUnits()',
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Select ACU / Enter OC mode / Goto ACU", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").ACUSelectOCGoto()",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T1 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(1, false)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T2 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(2, false)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T3 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(3, false)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All SACU", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectSACU(false)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T1 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(1, true)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T2 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(2, true)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T3 Engineers", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectEngineers(3, true)",
    category = displayCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle SACU", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").MultiSelectSACU(true)",
    category = displayCategory,
    order = getDisplayOrder()
})

function UpgradeSelectedUnits()
    local units = GetSelectedUnits()

    for i, unit in units do
        if unit:IsInCategory("ENGINEER") then
            if units then
                local tech2 = EntityCategoryFilterDown(categories.TECH2, units)
                local tech3 = EntityCategoryFilterDown(categories.TECH3, units)
                local sACUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, units)

                if next(sACUs) then
                    SimCallback({ Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = sACUs[1]:GetEntityId() } }, true)
                    SelectUnits(sACUs)
                elseif next(tech3) then
                    SimCallback({ Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech3[1]:GetEntityId() } }, true)
                    SelectUnits(tech3)
                elseif next(tech2) then
                    SimCallback({ Func = 'SelectHighestEngineerAndAssist', Args = { TargetId = tech2[1]:GetEntityId() } }, true)
                    SelectUnits(tech2)
                else end
            end

            import("/lua/keymap/hotbuild.lua").buildActionTemplate("")
            return
        end
    end

    import("/lua/keymap/hotbuild.lua").buildActionUpgrade()
end

-- Select ACU / OC mode/ Goto acu if not on screen
function ACUSelectOCGoto()
    local selection = GetSelectedUnits()
    if not table.empty(selection) and table.getn(selection) == 1 and selection[1]:IsInCategory "COMMAND" then
        import("/lua/ui/game/orders.lua").EnterOverchargeMode()
    else
        ConExecute "UI_SelectByCategory +nearest COMMAND"
        local acu = GetSelectedUnits()
        local worldview = import('/lua/ui/game/worldview.lua').viewLeft
        if acu and not worldview:GetScreenPos(acu[1]) then
            ConExecute "UI_SelectByCategory +nearest +goto COMMAND"
        end
    end
end

-- MultiSelect 
local lastClickMultiSelect = -9999
local totalClicksMultiSelect = 0
local lastMultiClickUniqueString = nil

-- Select nearest / onscreen / all engineers
function MultiSelectEngineers(techlevel, onlyIdle)
    local idleText = " "
    if onlyIdle then idleText = " +idle " end
    local uniqueString = "MultiSelectEngineers"..techlevel..idleText
    local currentTick = GameTick()
	local isDoubleClick = currentTick < lastClickMultiSelect + 5

    if uniqueString == lastMultiClickUniqueString and isDoubleClick then
        if totalClicksMultiSelect == 1 then
            ConExecute ("UI_SelectByCategory +inview"..idleText.."BUILTBYTIER3FACTORY ENGINEER TECH"..techlevel)
        else
            ConExecute ("UI_SelectByCategory"..idleText.."BUILTBYTIER3FACTORY ENGINEER TECH"..techlevel)
        end
    else
        totalClicksMultiSelect = 0
        ConExecute ("UI_SelectByCategory +nearest"..idleText.."BUILTBYTIER3FACTORY ENGINEER TECH"..techlevel)
    end

    lastMultiClickUniqueString = uniqueString
    totalClicksMultiSelect = totalClicksMultiSelect + 1
    lastClickMultiSelect = currentTick
end

-- Select nearest / onscreen / all SACU
function MultiSelectSACU(onlyIdle)
    local idleText = " "
    if onlyIdle then idleText = " +idle " end
    local uniqueString = "MultiSelectSACU"..idleText
    local currentTick = GameTick()
	local isDoubleClick = currentTick < lastClickMultiSelect + 5

    if uniqueString == lastMultiClickUniqueString and isDoubleClick then
        if totalClicksMultiSelect == 1 then
            ConExecute ("UI_SelectByCategory +inview"..idleText.."SUBCOMMANDER")
        else
            ConExecute ("UI_SelectByCategory"..idleText.."SUBCOMMANDER")
        end
    else
        totalClicksMultiSelect = 0
        ConExecute ("UI_SelectByCategory +nearest"..idleText.."SUBCOMMANDER")
    end

    lastMultiClickUniqueString = uniqueString
    totalClicksMultiSelect = totalClicksMultiSelect + 1
    lastClickMultiSelect = currentTick
end


-- Select nearest idle engineer / Reclaim mode
function ReclaimSelectIDLENearestT1()
    local selection = GetSelectedUnits()
    if table.empty(selection) then
        ConExecute "UI_SelectByCategory +inview +nearest +idle ENGINEER TECH1"
    else
        ConExecute "StartCommandMode order RULEUCC_Reclaim"
    end
end

-- Decrease Unit count in factory queue
local DecreaseBuildCountInQueue = import("/lua/ui/game/construction.lua").DecreaseBuildCountInQueue
local RefreshUI = import("/lua/ui/game/construction.lua").RefreshUI
function RemoveLastItem()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits and selectedUnits[1]:IsInCategory "FACTORY" then
        local currentCommandQueue = SetCurrentFactoryForQueueDisplay(selectedUnits[1])
        local count = 1
        if IsKeyDown "Shift" then
            count = 5
        end
        DecreaseBuildCountInQueue(table.getsize(currentCommandQueue), count)
        ClearCurrentFactoryForQueueDisplay()
        RefreshUI()
    end
end

-- Select nearest air scout / build sensors
function SelectAirScoutBuildIntel()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits then
        import("/lua/keymap/hotbuild.lua").buildAction "Sensors"
    else
        ConExecute "UI_SelectByCategory +nearest AIR INTELLIGENCE"
    end
end

function SelectNearestIdleTransportOrTransport()
    local selectedUnits = GetSelectedUnits()
    if selectedUnits then
        ConExecute "StartCommandMode order RULEUCC_Transport"
    else
        ConExecute "UI_SelectByCategory +nearest +idle AIR TRANSPORTATION"
    end
end

KeyMapper.SetUserKeyAction("Remove last queued unit in factory", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").RemoveLastItem()",
    category = "orders",
    order = 17
})

KeyMapper.SetUserKeyAction("Shift Remove last queued unit in factory", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").RemoveLastItem()",
    category = "orders",
    order = 18
})

KeyMapper.SetUserKeyAction("Select All IDLE engineers on screen not ACU", {
    action = "UI_SelectByCategory +inview +idle ENGINEER TECH1,ENGINEER TECH2,ENGINEER TECH3",
    category = "selection",
    order = 19
})

KeyMapper.SetUserKeyAction("Select Nearest IDLE T1 engineer / enter reclaim mode", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").ReclaimSelectIDLENearestT1()",
    category = "selection",
    order = 21
})

KeyMapper.SetUserKeyAction("Shift Select Nearest IDLE T1 engineer / enter reclaim mode", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").ReclaimSelectIDLENearestT1()",
    category = "selection",
    order = 22
})


KeyMapper.SetUserKeyAction("Select nearest air scout / build sensors", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").SelectAirScoutBuildIntel()",
    category = "selection",
    order = 23
})

KeyMapper.SetUserKeyAction("Shift Select nearest air scout / build sensors", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").SelectAirScoutBuildIntel()",
    category = "selection",
    order = 24
})

KeyMapper.SetUserKeyAction("Select nearest idle transport / transport order", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").SelectNearestIdleTransportOrTransport()",
    category = "selection",
    order = 25
})

KeyMapper.SetUserKeyAction("Shift Select nearest idle transport / transport order", {
    action = "UI_Lua import(\"/lua/keymap/misckeyactions.lua\").SelectNearestIdleTransportOrTransport()",
    category = "selection",
    order = 26
})


local function ExistGlobal(name)
    return rawget(_G, name) ~= nil
end

if ExistGlobal "UMT" and UMT.Version >= 8 then
    local LuaQ = UMT.LuaQ
    function OCOrRepeatBuild()
        local selection = GetSelectedUnits()
        if not selection then return end

        local isAllFactories = selection
            | LuaQ.all(function(_, unit) return unit:IsInCategory 'FACTORY' end)

        if not isAllFactories then
            import("/lua/ui/game/orders.lua").EnterOverchargeMode()
            return
        end

        local isRepeatBuild = selection
            | LuaQ.any(function(_, unit) return unit:IsRepeatQueue() end)
            and 'false'
            or 'true'
        for _, unit in selection do
            unit:ProcessInfo('SetRepeatQueue', isRepeatBuild)
        end
    end
else
    function OCOrRepeatBuild()
        print "THIS ACTION REQUIRES UI MOD TOOLS V8!"
    end
end

KeyMapper.SetUserKeyAction("Toggle repeat build of factories / OC mode", {
    action = "UI_Lua import('/lua/keymap/misckeyactions.lua').OCOrRepeatBuild()",
    category = "order"
})


KeyMapper.SetUserKeyAction("Order Tech upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderTechUpgrade()",
    category = "Upgrade"
})
KeyMapper.SetUserKeyAction("Order Engineering upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/SACUEnhancements.lua').OrderTechUpgrade()",
    category = "Upgrade"
})
KeyMapper.SetUserKeyAction("Order RAS upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderRASUpgrade()",
    category = "Upgrade"
})
KeyMapper.SetUserKeyAction("Order Gun upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderGunUpgrade()",
    category = "Upgrade"
})

KeyMapper.SetUserKeyAction("Order Shield / Stealth / Nano upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderNanoUpgrade()",
    category = "Upgrade"
})

KeyMapper.SetUserKeyAction("Order Laser / Chrono / Gun splash / Billy nuke upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderSpecialUpgrade()",
    category = "Upgrade"
})

KeyMapper.SetUserKeyAction("Order Tele upgrade", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/ACUEnhancements.lua').OrderTeleUpgrade()",
    category = "Upgrade"
})
