local KeyMapper = import("/lua/keymap/keymapper.lua")

local displayOrder = 999
local function getDisplayOrder()
    displayOrder = displayOrder + 1
    return displayOrder
end

local multiHotkeysCategory = "MultiHotkeys"

-- Selection
KeyMapper.SetUserKeyAction("Select ACU / Enter OC mode / Goto ACU", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").ACUSelectOCGoto()',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T1 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(1, false)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T2 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(2, false)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All T3 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(3, false)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All SACU", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectSACU(false)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T1 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(1, true)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T2 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(2, true)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle T3 Engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectEngineers(3, true)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Nearest / Onscreen / All Idle SACU", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectSACU(true)',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Onscreen / All Similar units", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectSimilarUnits()',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Onscreen Directfire Land units", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectDirectFireLandUnits()',
    category = multiHotkeysCategory,
    order = getDisplayOrder(),
})
KeyMapper.SetUserKeyAction("Onscreen Support Land units", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").MultiSelectSupportLandUnits()',
    category = multiHotkeysCategory,
    order = getDisplayOrder(),
})
KeyMapper.SetUserKeyAction("Nearest Idle Transport / Transport Order", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectNearestIdleTransportOrTransport()',
    category = "selection",
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Select All IDLE engineers on screen not ACU", {
    action = "UI_SelectByCategory +inview +idle ENGINEER TECH1,ENGINEER TECH2,ENGINEER TECH3",
    category = "selection",
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Select all TML if none selected + fire missile mode", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/selection.lua").SelectTmlFireMissile()',
    category = multiHotkeysCategory,
    order = getDisplayOrder()
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

local ordersCategory = "order"

-- Orders
KeyMapper.SetUserKeyAction("Toggle repeat build of Factories / OC mode", {
    action = 'UI_Lua import("/lua/keymap/misckeyactions.lua").OCOrRepeatBuild()',
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Upgrade selected structures / Cycle templates for engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").UpgradeStructuresEngineersCycleTemplates()',
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Shift Upgrade selected structures / Cycle templates for engineers", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").UpgradeStructuresEngineersCycleTemplates()',
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Remove last queued unit in factory", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").RemoveLastItem()',
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Shift Remove last queued unit in factory", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/orders.lua").RemoveLastItem()',
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Undo last queue order", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/orders.lua').UndoLastQueueOrder()",
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Shift Undo last queue order", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/orders.lua').UndoLastQueueOrder()",
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Undo all except current queue order", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/orders.lua').UndoAllExceptCurrentQueueOrder()",
    category = ordersCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Shift Undo all except current queue order", {
    action = "UI_Lua import('/mods/MultiHotkeys/modules/orders.lua').UndoAllExceptCurrentQueueOrder()",
    category = ordersCategory,
    order = getDisplayOrder()
})

local enhancementsCategory = "Enhancements"

-- Enhancements
KeyMapper.SetUserKeyAction("Order Tech upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTechUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order Engineering upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/SACUEnhancements.lua").OrderTechUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order RAS upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderRASUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order Gun upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderGunUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order Shield / Stealth / Nano upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderNanoUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order Laser / Chrono / Gun splash / Billy nuke upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderSpecialUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
KeyMapper.SetUserKeyAction("Order Tele upgrade", {
    action = 'UI_Lua import("/mods/MultiHotkeys/modules/ACUEnhancements.lua").OrderTeleUpgrade()',
    category = enhancementsCategory,
    order = getDisplayOrder()
})
