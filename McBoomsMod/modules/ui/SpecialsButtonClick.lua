local GetGameTimeSeconds = GetGameTimeSeconds

local UIUtil = import('/lua/ui/uiutil.lua')

local modFolder = 'McBoomsMod'

local Util = import('/mods/' .. modFolder .. '/modules/util/Util.lua')
local BaseButtonClick = import('/mods/' .. modFolder .. '/modules/ui/BaseButtonClick.lua').BaseButtonClick
local GetArmyManager = import('/mods/' .. modFolder .. '/modules/army/ArmyManager.lua').GetArmyManager

local table_insert = table.insert
local table_getsize = table.getsize
local enableEtaChatCooldown = false
local EtaChatCooldown = 0.5

SpecialsButtonClick = BaseButtonClick:inherit("SpecialsButtonClick")

function SpecialsButtonClick:new()
    local o = BaseButtonClick:new()
    setmetatable(o,self)
    self.__index = self

    o.lastEtaClick = 0

    return o
end

function SpecialsButtonClick:applyPause()
    return true
end

function SpecialsButtonClick:pauseOrUpgrade()
    self:pauseUnits()
end

function SpecialsButtonClick:getAllUnits()
    local units = {}
    local name = self.obj.items:get(1):getName()
    for _, list in self.obj.row.items do
        for i,unitObj in list:indexedIterator() do
            if unitObj:getName()==name then
                table_insert(units, unitObj:getUnit())
            end
        end
    end
    return units
end

function SpecialsButtonClick:upgradeUnits()
    -- not available for specials
end

function SpecialsButtonClick:sendEtaToAllies()
    if enableEtaChatCooldown and self.lastEtaClick > GetGameTimeSeconds()-EtaChatCooldown then
        print("E.T.A. to chat is still on cooldown!")
        return
    end
    self.lastEtaClick = GetGameTimeSeconds()
    local items = self.obj.items
    local eta, item, missiles = Util.GetBestEtaForSpecialUnits(items)
    if eta and item then
        if eta == "" then
            eta = "INFINITY"
        end
        local name = tostring(LOC(item:getName()))
        local text
        if item:IsMissileSilo() then
            if not item:isUnderConstruction() then
                text = "["..name.."] next missile E.T.A = "..tostring(eta)..", total loaded missiles = "..tostring(missiles)
            else
                text = "["..name.."] structure completion E.T.A = "..tostring(eta)..", total loaded missiles = "..tostring(missiles)
            end
        else
            if item:isUnderConstruction() then
                text = "["..name.."] completion E.T.A = "..tostring(eta)
            else
                text = "["..name.."] progress E.T.A = "..tostring(eta)
            end
        end
        GetArmyManager():sendChatAllies(text)
    end
end

SpecialsButtonClick.ClickOptions = {
    { Func = "selectUnits", Click = "Left", Ctrl = false, Alt = false, Shift = false, Text = "Select" },
    { Func = "selectUnits", Click = "Left", Ctrl = false, Alt = false, Shift = true, Text = "Append Select" },
    { Func = "sendEtaToAllies", Click = "Left", Ctrl = false, Alt = true, Shift = false, Text= "Send ETA Allied Chat" },
    { Func = "pauseOrUpgrade", Click = "Left", Ctrl = true, Alt = false, Shift = false, Text= "Pause" },
    { Func = "engineersAssistUnit", Click = "Right", Ctrl = false, Alt = false, Shift = false, Text = "Units Assist" },
    { Func = "engineersAssistUnit", Click = "Right", Ctrl = false, Alt = false, Shift = true, Text = "Units Append Assist" },
    { Func = "zoomToUnit", Click = "Right", Ctrl = true, Alt = false, Shift = false, Text = "Zoom To Unit" }
}

function SpecialsButtonClick:getClickOptionsText()
    local text = "\r\n[Exp\\Nuke\\AntiNuke:]\r\n"
    text = text .. BaseButtonClick.getClickOptionsText(self)
    return text
end

local instance

function GetSpecialsButtonClick()
    if not instance then
        instance = SpecialsButtonClick:new()
    end
    return instance
end

function SpecialsButtonOnClickFunc(_bg, _event)
    GetSpecialsButtonClick():process(_bg.btnObject, _event)
end