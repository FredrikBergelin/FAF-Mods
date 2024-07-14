-----------------------------------------------------------------
-- File: lua/ui/game/helptext.lua
-- Author: Ted Snook
-- Summary: Help Text Popup
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

function tLOG(tbl, indent)
    if not indent then indent = 0 end
    local formatting = string.rep("  ", indent)
    if type(tbl) == "nil" then
        LOG(formatting .. "nil")
        return
    end
    if type(tbl) == "string" then
        LOG(formatting .. tbl)
        return
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "nil" then
            LOG(formatting .. "NIL")
        elseif type(v) == "table" then
            LOG(formatting)
            tLOG(v, indent + 1)
        elseif type(v) == 'boolean' then
            LOG(formatting .. tostring(v))
        else
            LOG(formatting)
            LOG(v)
        end
    end
end

-- This file is the F1 menu used for navigating and interacting with keybindings
local UIUtil        = import("/lua/ui/uiutil.lua")
local LayoutHelpers = import("/lua/maui/layouthelpers.lua")
local Group         = import("/lua/maui/group.lua").Group
local Bitmap        = import("/lua/maui/bitmap.lua").Bitmap
local Edit          = import("/lua/maui/edit.lua").Edit
local Popup         = import("/lua/ui/controls/popups/popup.lua").Popup
local Tooltip       = import("/lua/ui/game/tooltip.lua")
local MultiLineText = import("/lua/maui/multilinetext.lua").MultiLineText

local properKeyNames = import("/lua/keymap/properkeynames.lua").properKeyNames
local keyNames = import("/lua/keymap/keynames.lua").keyNames
local keyCategories = import("/lua/keymap/keycategories.lua").keyCategories
local keyCategoryOrder = import("/lua/keymap/keycategories.lua").keyCategoryOrder
local KeyMapper = import("/lua/keymap/keymapper.lua")

local popup = nil
local dialogContent

local TOP_PADDING = 50
local SIDE_PADDING = 10
local KEYBINDING_WIDTH = 210
local LEFTSIDE_WIDTH = 800
local BUTTON_PADDING = 10
local STANDARD_FONT_SIZE = 16
local HEADER_FONT_SIZE = 20
local LINEHEIGHT = 30
local BUTTON_FONTSIZE = 18

local LEFTSIDE_FormatData
local LEFTSIDE_Section
local LEFTSIDE_keyContainer
local LEFTSIDE_keyTable
local LEFTSIDE_keyFilter
local LEFTSIDE_keyEntries = {}
local LEFTSIDE_keyword = ''
local LEFTSIDE_linesVisible = {}
local LEFTSIDE_linesCollapsed = true
local LEFTSIDE_keyGroups = {}

for order, category in keyCategoryOrder do
    local name = string.lower(category)
    LEFTSIDE_keyGroups[name] = {}
    LEFTSIDE_keyGroups[name].order = order
    LEFTSIDE_keyGroups[name].name = name
    LEFTSIDE_keyGroups[name].text = LOC(keyCategories[category])
    LEFTSIDE_keyGroups[name].collapsed = LEFTSIDE_linesCollapsed
end
-- local function ResetBindingToDefaultKeyMap()
--     IN_ClearKeyMap()
--     KeyMapper.ResetUserKeyMapTo('defaultKeyMap.lua')
--     IN_AddKeyMapTable(KeyMapper.GetKeyActions())
--     LEFTSIDE_keyTable = LEFTSIDE_FormatData()
--     LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
-- end

-- local function ResetBindingToHotbuildKeyMap()
--     IN_ClearKeyMap()
--     KeyMapper.ResetUserKeyMapTo('hotbuildKeyMap.lua')
--     IN_AddKeyMapTable(KeyMapper.GetKeyActions())
--     LEFTSIDE_keyTable = LEFTSIDE_FormatData()
--     LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
-- end

-- local function ResetBindingToalternativeKeyMap()
--     IN_ClearKeyMap()
--     KeyMapper.ResetUserKeyMapTo('alternativeKeyMap.lua')
--     IN_AddKeyMapTable(KeyMapper.GetKeyActions())
--     LEFTSIDE_keyTable = LEFTSIDE_FormatData()
--     LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
-- end

local function LEFTSIDE_ConfirmNewKeyMap()
    KeyMapper.SaveUserKeyMap()
    IN_ClearKeyMap()
    IN_AddKeyMapTable(KeyMapper.GetKeyMappings(true))
    -- update hotbuild modifiers and re-initialize hotbuild labels
    if SessionIsActive() then
        import("/lua/keymap/hotbuild.lua").addModifiers()
        import("/lua/keymap/hotkeylabels.lua").init()
    end
end

local function LEFTSIDE_ClearActionKey(action, currentKey)
    KeyMapper.ClearUserKeyMapping(currentKey)
    -- auto-clear shift action, e.g. 'shift_attack' for 'attack' action
    local target = KeyMapper.GetShiftAction(action, 'orders')
    if target and target.key then
        KeyMapper.ClearUserKeyMapping(target.key)
    end
end

local function LEFTSIDE_EditActionKey(parent, action, currentKey)
    local dialogContent = Group(parent)
    LayoutHelpers.SetDimensions(dialogContent, 400, 170)

    local keyPopup = Popup(popup, dialogContent)

    local cancelButton = UIUtil.CreateButtonWithDropshadow(dialogContent, '/BUTTON/medium/', "<LOC _Cancel>")
    LayoutHelpers.AtBottomIn(cancelButton, dialogContent, 15)
    LayoutHelpers.AtRightIn(cancelButton, dialogContent, -2)
    cancelButton.OnClick = function(self, modifiers)
        keyPopup:Close()
    end

    local okButton = UIUtil.CreateButtonWithDropshadow(dialogContent, '/BUTTON/medium/', "<LOC _Ok>")
    LayoutHelpers.AtBottomIn(okButton, dialogContent, 15)
    LayoutHelpers.AtLeftIn(okButton, dialogContent, -2)

    local helpText = MultiLineText(dialogContent, UIUtil.bodyFont, STANDARD_FONT_SIZE, UIUtil.fontColor)
    LayoutHelpers.AtTopIn(helpText, dialogContent, 10)
    LayoutHelpers.AtHorizontalCenterIn(helpText, dialogContent)
    helpText.Width:Set(dialogContent.Width() - 10)
    helpText:SetText(LOC("<LOC key_binding_0002>Hit the key combination you'd like to assign"))
    helpText:SetCenteredHorizontally(true)

    local keyText = UIUtil.CreateText(dialogContent, FormatKeyName(currentKey), 24)
    keyText:SetColor(UIUtil.factionBackColor)
    LayoutHelpers.Above(keyText, okButton)
    LayoutHelpers.AtHorizontalCenterIn(keyText, dialogContent)

    dialogContent:AcquireKeyboardFocus(false)
    keyPopup.OnClose = function(self)
        dialogContent:AbandonKeyboardFocus()
    end

    local keyCodeLookup = KeyMapper.GetKeyCodeLookup()
    local keyAdder = {}
    local keyPattern

    local function AddKey(keyCode, modifiers)
        local key = keyCodeLookup[keyCode]
        if not key then
            return
        end

        local keyComboName = ""
        keyPattern = ""

        if key ~= 'Ctrl' and modifiers.Ctrl then
            keyPattern = keyPattern .. keyNames['11'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['11'] ]) .. "-"
        end

        if key ~= 'Alt' and modifiers.Alt then
            keyPattern = keyPattern .. keyNames['12'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['12'] ]) .. "-"
        end

        if key ~= 'Shift' and modifiers.Shift then
            keyPattern = keyPattern .. keyNames['10'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['10'] ]) .. "-"
        end

        keyPattern = keyPattern .. key
        keyComboName = keyComboName .. LOC(properKeyNames[key])

        keyText:SetText(keyComboName)
    end

    local oldHandleEvent = dialogContent.HandleEvent
    dialogContent.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            AddKey(event.RawKeyCode, event.Modifiers)
        end

        oldHandleEvent(self, event)
    end

    local function AssignKey()

        local function ClearShiftKey()
            KeyMapper.ClearUserKeyMapping("Shift-" .. keyPattern)
            LOG("Keybindings clearing Shift-" .. keyPattern)
        end

        local function MapKey()
            KeyMapper.SetUserKeyMapping(keyPattern, currentKey, action)

            -- auto-assign shift action, e.g. 'shift_attack' for 'attack' action
            local target = KeyMapper.GetShiftAction(action, 'orders')
            if target and not KeyMapper.ContainsKeyModifiers(keyPattern) then
                KeyMapper.SetUserKeyMapping('Shift-' .. keyPattern, target.key, target.name)
            end

            -- checks if hotbuild modifier keys are conflicting with already mapped actions
            local keyMapping = KeyMapper.GetKeyMappingDetails()
            if keyMapping[keyPattern] and keyMapping[keyPattern].category == "HOTBUILDING" then
                local hotKey = "Shift-" .. keyPattern
                if keyMapping[hotKey] then
                    UIUtil.QuickDialog(popup,
                        LOCF("<LOC key_binding_0006>The %s key is already mapped under %s category, are you sure you want to clear it for the following action? \n\n %s"
                            ,
                            hotKey, keyMapping[hotKey].category, keyMapping[hotKey].name),
                        "<LOC _Yes>", ClearShiftKey,
                        "<LOC _No>", nil, nil, nil, true,
                        { escapeButton = 2, enterButton = 1, worldCover = false })
                end
            end
            LEFTSIDE_keyTable = LEFTSIDE_FormatData()
            LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
        end

        -- checks if this key is already assigned to some other action
        local keyMapping = KeyMapper.GetKeyMappingDetails()
        if keyMapping[keyPattern] and keyMapping[keyPattern].id ~= action then
            UIUtil.QuickDialog(popup,
                LOCF("<LOC key_binding_0006>The %s key is already mapped under %s category, are you sure you want to clear it for the following action? \n\n %s"
                    ,
                    keyPattern, keyMapping[keyPattern].category, keyMapping[keyPattern].name),
                "<LOC _Yes>", MapKey,
                "<LOC _No>", nil, nil, nil, true,
                { escapeButton = 2, enterButton = 1, worldCover = false })
        else
            MapKey()
        end
    end

    okButton.OnClick = function(self, modifiers)
        AssignKey()
        keyPopup:Close()
    end
end

local function LEFTSIDE_AssignCurrentSelection()
    for k, v in LEFTSIDE_keyTable do
        if v.selected then
            LEFTSIDE_EditActionKey(popup, v.action, v.key)
            break
        end
    end
end

local function LEFTSIDE_UnbindCurrentSelection()
    for k, v in LEFTSIDE_keyTable do
        if v.selected then
            LEFTSIDE_ClearActionKey(v.action, v.key)
            break
        end
    end
    LEFTSIDE_keyTable = LEFTSIDE_FormatData()
    LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
end

local function LEFTSIDE_GetLineColor(lineID, data)
    if data.type == 'header' then
        return 'FF282828' ----FF282828
    elseif data.type == 'spacer' then
        return '00000000' ----00000000
    elseif data.type == 'entry' then
        if data.selected then
            return UIUtil.factionBackColor
        elseif math.mod(lineID, 2) == 1 then
            return 'ff202020' ----ff202020
        else
            return 'FF343333' ----FF343333
        end
    else
        return 'FF6B0088' ----FF9D06C6
    end
end

local function LEFTSIDE_ToggleLines(category)
    if LEFTSIDE_keyword and string.len(LEFTSIDE_keyword) > 0 then return end

    for k, v in LEFTSIDE_keyTable do
        if v.category == category then
            if v.collapsed then
                v.collapsed = false
            else
                v.collapsed = true
            end
        end
    end
    if LEFTSIDE_keyGroups[category].collapsed then
        LEFTSIDE_keyGroups[category].collapsed = false
    else
        LEFTSIDE_keyGroups[category].collapsed = true
    end
    LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
end

local function LEFTSIDE_SelectLine(dataIndex)
    for k, v in LEFTSIDE_keyTable do
        v.selected = false
    end

    if LEFTSIDE_keyTable[dataIndex].type == 'entry' then
        LEFTSIDE_keyTable[dataIndex].selected = true
    end
    LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
end

function LEFTSIDE_CreateToggle(parent, bgColor, txtColor, bgSize, txtSize, txt)
    if not bgSize then bgSize = 20 end
    if not bgColor then bgColor = 'FF343232' end
    if not txtColor then txtColor = UIUtil.factionTextColor end
    if not txtSize then txtSize = BUTTON_FONTSIZE end
    if not txt then txt = '?' end

    local button = Bitmap(parent)
    button:SetSolidColor(bgColor)
    button.Height:Set(bgSize)
    button.Width:Set(bgSize)
    button.txt = UIUtil.CreateText(button, txt, txtSize)
    button.txt:SetColor(txtColor)
    button.txt:SetFont(UIUtil.bodyFont, txtSize)
    LayoutHelpers.AtVerticalCenterIn(button.txt, button)
    LayoutHelpers.AtHorizontalCenterIn(button.txt, button)

    button:SetAlpha(0.8)
    button.txt:SetAlpha(0.8)

    button.OnMouseClick = function(self) -- override for mouse clicks
        return false
    end

    button.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            button:SetAlpha(1.0)
            button.txt:SetAlpha(1.0)
        elseif event.Type == 'MouseExit' then
            button:SetAlpha(0.8)
            button.txt:SetAlpha(0.8)
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            return button:OnMouseClick()
        end
        return false
    end

    return button
end

function LEFTSIDE_CreateLine()
    local line = Bitmap(LEFTSIDE_keyContainer)
    line.Left:Set(LEFTSIDE_keyContainer.Left)
    line.Right:Set(LEFTSIDE_keyContainer.Right)
    LayoutHelpers.SetHeight(line, LINEHEIGHT)

    line.key = UIUtil.CreateText(line, '', STANDARD_FONT_SIZE, "Arial")
    line.key:DisableHitTest()
    line.key:SetAlpha(0.9)

    line.description = UIUtil.CreateText(line, '', STANDARD_FONT_SIZE, "Arial")
    line.description:DisableHitTest()
    line.description:SetClipToWidth(true)
    line.description.Width:Set(line.Right() - line.Left() - KEYBINDING_WIDTH - LINEHEIGHT - BUTTON_PADDING)
    line.description:SetAlpha(0.9)

    line.Height:Set(LINEHEIGHT)
    line.Width:Set(function() return line.Right() - line.Left() end)

    line.statistics = UIUtil.CreateText(line, '', STANDARD_FONT_SIZE, "Arial")
    line.statistics:EnableHitTest()
    line.statistics:SetColor('FF9A9A9A')
    line.statistics:SetAlpha(0.9)

    Tooltip.AddControlTooltip(line.statistics,
        {
            text = '<LOC key_binding_0014>Category Statistics',
            body = '<LOC key_binding_0015>Show total of bound actions and total of all actions in this category of keys'
        })

    LayoutHelpers.AtLeftIn(line.description, line, (KEYBINDING_WIDTH + LINEHEIGHT + BUTTON_PADDING))
    LayoutHelpers.AtVerticalCenterIn(line.description, line)

    LayoutHelpers.LeftOf(line.key, line.description, (LINEHEIGHT + (BUTTON_PADDING * 2)))
    LayoutHelpers.AtVerticalCenterIn(line.key, line)
    LayoutHelpers.AtRightIn(line.statistics, line, 10)
    LayoutHelpers.AtVerticalCenterIn(line.statistics, line)

    line.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            line:SetAlpha(0.9)
            line.key:SetAlpha(1.0)
            line.description:SetAlpha(1.0)
            line.statistics:SetAlpha(1.0)
            PlaySound(Sound({ Cue = "UI_Menu_Rollover_Sml", Bank = "Interface" }))
        elseif event.Type == 'MouseExit' then
            line:SetAlpha(1.0)
            line.key:SetAlpha(0.9)
            line.description:SetAlpha(0.9)
            line.statistics:SetAlpha(0.9)
        elseif self.data.type == 'entry' then
            if event.Type == 'ButtonPress' then
                LEFTSIDE_SelectLine(self.data.index)
                LEFTSIDE_keyFilter.text:AcquireFocus()
                return true
            elseif event.Type == 'ButtonDClick' then
                LEFTSIDE_SelectLine(self.data.index)
                LEFTSIDE_AssignCurrentSelection()
                return true
            end
        elseif self.data.type == 'header' and (event.Type == 'ButtonPress' or event.Type == 'ButtonDClick') then
            if string.len(LEFTSIDE_keyword) == 0 then
                LEFTSIDE_ToggleLines(self.data.category)
                LEFTSIDE_keyFilter.text:AcquireFocus()

                if LEFTSIDE_keyGroups[self.data.category].collapsed then
                    self.toggle.txt:SetText('+')
                else
                    self.toggle.txt:SetText('-')
                end
                PlaySound(Sound({ Cue = "UI_Menu_MouseDown_Sml", Bank = "Interface" }))
                return true
            end
        end
        return false
    end

    line.AssignKeyBinding = function(self)
        LEFTSIDE_SelectLine(self.data.index)
        LEFTSIDE_AssignCurrentSelection()
    end

    line.UnbindKeyBinding = function(self)
        if LEFTSIDE_keyTable[self.data.index].key then
            LEFTSIDE_SelectLine(self.data.index)
            LEFTSIDE_UnbindCurrentSelection()
        end
    end

    line.toggle = LEFTSIDE_CreateToggle(
        line,
        'FF1B1A1A',
        UIUtil.factionTextColor,
        LINEHEIGHT,
        BUTTON_FONTSIZE,
        '+')

    LayoutHelpers.AtLeftIn(line.toggle, line, KEYBINDING_WIDTH)
    LayoutHelpers.AtVerticalCenterIn(line.toggle, line)

    Tooltip.AddControlTooltip(line.toggle,
        {
            text = '<LOC key_binding_0010>Toggle Category',
            body = '<LOC key_binding_0011>Toggle visibility of all actions for this category of keys'
        })

    line.wikiButton = UIUtil.CreateBitmap(line, '/textures/ui/common/mods/mod_url_website.dds')
    LayoutHelpers.SetDimensions(line.wikiButton, STANDARD_FONT_SIZE, STANDARD_FONT_SIZE)

    LayoutHelpers.LeftOf(line.wikiButton, line.description, (BUTTON_PADDING + LINEHEIGHT / 2 - STANDARD_FONT_SIZE / 2))
    LayoutHelpers.AtVerticalCenterIn(line.wikiButton, line.key)
    line.wikiButton:SetAlpha(0.5)
    line.wikiButton.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            self:SetAlpha(1.0, false)
        elseif event.Type == 'MouseExit' then
            self:SetAlpha(0.5, false)
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            local url = "http://wiki.faforever.com/" .. tostring(self.url)
            OpenURL(url)
        end
        return true
    end

    import("/lua/ui/game/tooltip.lua").AddControlTooltipManual(line.wikiButton, 'Learn more on the Wiki of FAForever', ''
        , 0, 140, 6, 14, 14, 'left')

    line.assignKeyButton = LEFTSIDE_CreateToggle(
        line,
        '645F5E5E',
        'FFAEACAC',
        LINEHEIGHT,
        BUTTON_FONTSIZE,
        '+')

    LayoutHelpers.AtLeftIn(line.assignKeyButton, line)
    LayoutHelpers.AtVerticalCenterIn(line.assignKeyButton, line)
    Tooltip.AddControlTooltip(line.assignKeyButton,
        {
            text = "<LOC key_binding_0003>Assign Key",
            body = '<LOC key_binding_0012>Opens a dialog that allows assigning key binding for a given action'
        })
    line.assignKeyButton.OnMouseClick = function(self)
        line:AssignKeyBinding()
        return true
    end

    line.unbindKeyButton = LEFTSIDE_CreateToggle(
        line,
        '645F5E5E',
        'FFAEACAC',
        LINEHEIGHT,
        BUTTON_FONTSIZE,
        'x')

    LayoutHelpers.AtRightIn(line.unbindKeyButton, line)
    LayoutHelpers.AtVerticalCenterIn(line.unbindKeyButton, line)
    Tooltip.AddControlTooltip(line.unbindKeyButton,
        {
            text = "<LOC key_binding_0007>Unbind Key",
            body = '<LOC key_binding_0013>Removes currently assigned key binding for a given action'
        })

    line.unbindKeyButton.OnMouseClick = function(self)
        line:UnbindKeyBinding()
        return true
    end

    line.Update = function(self, data, lineID)
        line:SetSolidColor(LEFTSIDE_GetLineColor(lineID, data))
        line.data = table.copy(data)

        if data.type == 'header' then
            if LEFTSIDE_keyGroups[self.data.category].collapsed then
                self.toggle.txt:SetText('+')
            else
                self.toggle.txt:SetText('-')
            end
            local stats = LEFTSIDE_keyGroups[data.category].bindings .. ' / ' ..
                LEFTSIDE_keyGroups[data.category].visible
            line.toggle:Show()
            line.assignKeyButton:Hide()
            line.unbindKeyButton:Hide()
            line.wikiButton:Hide()
            line.description:SetText(data.text)
            line.description:SetFont(UIUtil.titleFont, HEADER_FONT_SIZE)
            line.description:SetColor(UIUtil.factionTextColor)
            LayoutHelpers.AtVerticalCenterIn(line.description, line, 2)
            line.key:SetText('')
            line.statistics:SetText(stats)
        elseif data.type == 'spacer' then
            line.toggle:Hide()
            line.assignKeyButton:Hide()
            line.unbindKeyButton:Hide()
            line.wikiButton:Hide()
            line.key:SetText('')
            line.description:SetText('')
            line.statistics:SetText('')
        elseif data.type == 'entry' then
            line.toggle:Hide()
            line.key:SetText(data.keyText)
            line.key:SetColor('ffffffff')
            line.key:SetFont('Arial', STANDARD_FONT_SIZE)
            line.description:SetText(data.text)
            line.description:SetFont('Arial', STANDARD_FONT_SIZE)
            line.description:SetColor(UIUtil.fontColor)
            line.statistics:SetText('')
            line.unbindKeyButton:Show()
            line.assignKeyButton:Show()

            if (data.wikiURL) then
                line.wikiButton.url = tostring(data.wikiURL)
                line.wikiButton:Show()
            else
                line.wikiButton.url = ""
                line.wikiButton:Hide()
            end
        end
    end
    return line
end

function LEFTSIDE_SortData(dataTable)
    table.sort(dataTable, function(a, b)
        if a.order ~= b.order then
            return a.order < b.order
        else
            if a.category ~= b.category then
                return string.lower(a.category) < string.lower(b.category)
            else
                if a.type == 'entry' and b.type == 'entry' then
                    if string.lower(a.text) ~= string.lower(b.text) then
                        return string.lower(a.text) < string.lower(b.text)
                    else
                        return a.action < b.action
                    end
                else
                    return a.id < b.id
                end
            end
        end
    end)
end

function LEFTSIDE_FormatData()
    local keyData = {}
    local keyLookup = KeyMapper.GetKeyLookup()
    local keyActions = KeyMapper.GetKeyActions()

    -- reset previously formated key actions in all groups because they might have been re-mapped
    for category, group in LEFTSIDE_keyGroups do
        group.actions = {}
    end
    -- group game keys and key defined in mods by their key category
    for k, v in keyActions do
        local category = string.lower(v.category or 'none')
        local keyForAction = keyLookup[k]

        -- create header if it doesn't exist
        if not LEFTSIDE_keyGroups[category] then
            LEFTSIDE_keyGroups[category] = {}
            LEFTSIDE_keyGroups[category].actions = {}
            LEFTSIDE_keyGroups[category].name = category
            LEFTSIDE_keyGroups[category].collapsed = LEFTSIDE_linesCollapsed
            LEFTSIDE_keyGroups[category].order = table.getsize(LEFTSIDE_keyGroups) - 1
            LEFTSIDE_keyGroups[category].text = v.category or keyCategories['none'].text
        end

        local data = {
            action = k,
            key = keyForAction,
            keyText = FormatKeyName(keyForAction),
            category = category,
            order = LEFTSIDE_keyGroups[category].order,
            text = KeyMapper.GetActionName(k),
            wikiURL = v.wikiURL
        }
        table.insert(LEFTSIDE_keyGroups[category].actions, data)
    end
    -- flatten all key actions to a list separated by a header with info about key category
    local index = 1
    for category, group in LEFTSIDE_keyGroups do
        if not table.empty(group.actions) then
            keyData[index] = {
                type = 'header',
                id = index,
                order = LEFTSIDE_keyGroups[category].order,
                count = table.getsize(group.actions),
                category = category,
                text = LEFTSIDE_keyGroups[category].text,
                collapsed = LEFTSIDE_keyGroups[category].collapsed
            }
            index = index + 1
            for _, data in group.actions do
                keyData[index] = {
                    type = 'entry',
                    text = data.text,
                    action = data.action,
                    key = data.key,
                    keyText = LOC(data.keyText),
                    category = category,
                    order = LEFTSIDE_keyGroups[category].order,
                    collapsed = LEFTSIDE_keyGroups[category].collapsed,
                    id = index,
                    wikiURL = data.wikiURL,
                    filters = { -- create filter parameters for quick searching of keys
                        key = string.gsub(string.lower(data.keyText), ' %+ ', ' '),
                        text = string.lower(data.text or ''),
                        action = string.lower(data.action or ''),
                        category = string.lower(data.category or ''),
                    }
                }
                index = index + 1
            end
        end
    end

    LEFTSIDE_SortData(keyData)

    -- store index of a header line for each key line
    local header = 1
    for i, data in keyData do
        if data.type == 'header' then
            header = i
        elseif data.type == 'entry' then
            data.header = header
        end
        data.index = i
    end

    return keyData
end

local RIGHTSIDE_FormatData
local RIGHTSIDE_Section
local RIGHTSIDE_keyContainer
local RIGHTSIDE_keyTable
local RIGHTSIDE_keyFilter
local RIGHTSIDE_keyEntries = {}
local RIGHTSIDE_keyword = ''
local RIGHTSIDE_linesVisible = {}
local RIGHTSIDE_linesCollapsed = true
local RIGHTSIDE_keyGroups = {}

for order, category in keyCategoryOrder do
    local name = string.lower(category)
    RIGHTSIDE_keyGroups[name] = {}
    RIGHTSIDE_keyGroups[name].order = order
    RIGHTSIDE_keyGroups[name].name = name
    RIGHTSIDE_keyGroups[name].text = LOC(keyCategories[category])
    RIGHTSIDE_keyGroups[name].collapsed = RIGHTSIDE_linesCollapsed
end
local function RIGHTSIDE_ConfirmNewKeyMap()
    KeyMapper.SaveUserKeyMap()
    IN_ClearKeyMap()
    IN_AddKeyMapTable(KeyMapper.GetKeyMappings(true))
    -- update hotbuild modifiers and re-initialize hotbuild labels
    if SessionIsActive() then
        import("/lua/keymap/hotbuild.lua").addModifiers()
        import("/lua/keymap/hotkeylabels.lua").init()
    end
end

local function RIGHTSIDE_ClearActionKey(action, currentKey)
    KeyMapper.ClearUserKeyMapping(currentKey)
    -- auto-clear shift action, e.g. 'shift_attack' for 'attack' action
    local target = KeyMapper.GetShiftAction(action, 'orders')
    if target and target.key then
        KeyMapper.ClearUserKeyMapping(target.key)
    end
end

local function RIGHTSIDE_EditActionKey(parent, action, currentKey)
    local dialogContent = Group(parent)
    LayoutHelpers.SetDimensions(dialogContent, 400, 170)

    local keyPopup = Popup(popup, dialogContent)

    local cancelButton = UIUtil.CreateButtonWithDropshadow(dialogContent, '/BUTTON/medium/', "<LOC _Cancel>")
    LayoutHelpers.AtBottomIn(cancelButton, dialogContent, 15)
    LayoutHelpers.AtRightIn(cancelButton, dialogContent, -2)
    cancelButton.OnClick = function(self, modifiers)
        keyPopup:Close()
    end

    local okButton = UIUtil.CreateButtonWithDropshadow(dialogContent, '/BUTTON/medium/', "<LOC _Ok>")
    LayoutHelpers.AtBottomIn(okButton, dialogContent, 15)
    LayoutHelpers.AtLeftIn(okButton, dialogContent, -2)

    local helpText = MultiLineText(dialogContent, UIUtil.bodyFont, STANDARD_FONT_SIZE, UIUtil.fontColor)
    LayoutHelpers.AtTopIn(helpText, dialogContent, 10)
    LayoutHelpers.AtHorizontalCenterIn(helpText, dialogContent)
    helpText.Width:Set(dialogContent.Width() - 10)
    helpText:SetText(LOC("<LOC key_binding_0002>Hit the key combination you'd like to assign"))
    helpText:SetCenteredHorizontally(true)

    local keyText = UIUtil.CreateText(dialogContent, FormatKeyName(currentKey), 24)
    keyText:SetColor(UIUtil.factionBackColor)
    LayoutHelpers.Above(keyText, okButton)
    LayoutHelpers.AtHorizontalCenterIn(keyText, dialogContent)

    dialogContent:AcquireKeyboardFocus(false)
    keyPopup.OnClose = function(self)
        dialogContent:AbandonKeyboardFocus()
    end

    local keyCodeLookup = KeyMapper.GetKeyCodeLookup()
    local keyAdder = {}
    local keyPattern

    local function AddKey(keyCode, modifiers)
        local key = keyCodeLookup[keyCode]
        if not key then
            return
        end

        local keyComboName = ""
        keyPattern = ""

        if key ~= 'Ctrl' and modifiers.Ctrl then
            keyPattern = keyPattern .. keyNames['11'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['11'] ]) .. "-"
        end

        if key ~= 'Alt' and modifiers.Alt then
            keyPattern = keyPattern .. keyNames['12'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['12'] ]) .. "-"
        end

        if key ~= 'Shift' and modifiers.Shift then
            keyPattern = keyPattern .. keyNames['10'] .. "-"
            keyComboName = keyComboName .. LOC(properKeyNames[ keyNames['10'] ]) .. "-"
        end

        keyPattern = keyPattern .. key
        keyComboName = keyComboName .. LOC(properKeyNames[key])

        keyText:SetText(keyComboName)
    end

    local oldHandleEvent = dialogContent.HandleEvent
    dialogContent.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            AddKey(event.RawKeyCode, event.Modifiers)
        end

        oldHandleEvent(self, event)
    end

    local function AssignKey()

        local function ClearShiftKey()
            KeyMapper.ClearUserKeyMapping("Shift-" .. keyPattern)
            LOG("Keybindings clearing Shift-" .. keyPattern)
        end

        local function MapKey()
            KeyMapper.SetUserKeyMapping(keyPattern, currentKey, action)

            -- auto-assign shift action, e.g. 'shift_attack' for 'attack' action
            local target = KeyMapper.GetShiftAction(action, 'orders')
            if target and not KeyMapper.ContainsKeyModifiers(keyPattern) then
                KeyMapper.SetUserKeyMapping('Shift-' .. keyPattern, target.key, target.name)
            end

            -- checks if hotbuild modifier keys are conflicting with already mapped actions
            local keyMapping = KeyMapper.GetKeyMappingDetails()
            if keyMapping[keyPattern] and keyMapping[keyPattern].category == "HOTBUILDING" then
                local hotKey = "Shift-" .. keyPattern
                if keyMapping[hotKey] then
                    UIUtil.QuickDialog(popup,
                        LOCF("<LOC key_binding_0006>The %s key is already mapped under %s category, are you sure you want to clear it for the following action? \n\n %s"
                            ,
                            hotKey, keyMapping[hotKey].category, keyMapping[hotKey].name),
                        "<LOC _Yes>", ClearShiftKey,
                        "<LOC _No>", nil, nil, nil, true,
                        { escapeButton = 2, enterButton = 1, worldCover = false })
                end
            end
            RIGHTSIDE_keyTable = RIGHTSIDE_FormatData()
            RIGHTSIDE_keyContainer:Filter(RIGHTSIDE_keyword)
        end

        -- checks if this key is already assigned to some other action
        local keyMapping = KeyMapper.GetKeyMappingDetails()
        if keyMapping[keyPattern] and keyMapping[keyPattern].id ~= action then
            UIUtil.QuickDialog(popup,
                LOCF("<LOC key_binding_0006>The %s key is already mapped under %s category, are you sure you want to clear it for the following action? \n\n %s"
                    ,
                    keyPattern, keyMapping[keyPattern].category, keyMapping[keyPattern].name),
                "<LOC _Yes>", MapKey,
                "<LOC _No>", nil, nil, nil, true,
                { escapeButton = 2, enterButton = 1, worldCover = false })
        else
            MapKey()
        end
    end

    okButton.OnClick = function(self, modifiers)
        AssignKey()
        keyPopup:Close()
    end
end

local function RIGHTSIDE_AssignCurrentSelection()
    for k, v in RIGHTSIDE_keyTable do
        if v.selected then
            RIGHTSIDE_EditActionKey(popup, v.action, v.key)
            break
        end
    end
end

local function RIGHTSIDE_UnbindCurrentSelection()
    for k, v in RIGHTSIDE_keyTable do
        if v.selected then
            RIGHTSIDE_ClearActionKey(v.action, v.key)
            break
        end
    end
    RIGHTSIDE_keyTable = RIGHTSIDE_FormatData()
    RIGHTSIDE_keyContainer:Filter(RIGHTSIDE_keyword)
end

local function RIGHTSIDE_GetLineColor(lineID, data)
    if data.type == 'header' then
        return 'FF282828'
    elseif data.type == 'spacer' then
        return '00000000'
    elseif data.type == 'entry' then
        if data.selected then
            return UIUtil.factionBackColor
        elseif math.mod(lineID, 2) == 1 then
            return 'ff202020'
        else
            return 'FF343333'
        end
    else
        return 'FF6B0088'
    end
end

local function RIGHTSIDE_ToggleLines(category)
    if RIGHTSIDE_keyword and string.len(RIGHTSIDE_keyword) > 0 then return end

    for k, v in RIGHTSIDE_keyTable do
        if v.category == category then
            if v.collapsed then
                v.collapsed = false
            else
                v.collapsed = true
            end
        end
    end
    if RIGHTSIDE_keyGroups[category].collapsed then
        RIGHTSIDE_keyGroups[category].collapsed = false
    else
        RIGHTSIDE_keyGroups[category].collapsed = true
    end
    RIGHTSIDE_keyContainer:Filter(RIGHTSIDE_keyword)
end

local function RIGHTSIDE_SelectLine(dataIndex)
    for k, v in RIGHTSIDE_keyTable do
        v.selected = false
    end

    if RIGHTSIDE_keyTable[dataIndex].type == 'entry' then
        RIGHTSIDE_keyTable[dataIndex].selected = true
    end
    RIGHTSIDE_keyContainer:Filter(RIGHTSIDE_keyword)
end

function RIGHTSIDE_CreateToggle(parent, bgColor, txtColor, bgSize, txtSize, txt)
    if not bgSize then bgSize = 20 end
    if not bgColor then bgColor = 'FF343232' end
    if not txtColor then txtColor = UIUtil.fontColor end
    if not txtSize then txtSize = BUTTON_FONTSIZE end
    if not txt then txt = '?' end

    local button = Bitmap(parent) -- TODO
    button:SetSolidColor(bgColor)
    button.Height:Set(bgSize)
    button.Width:Set(bgSize)
    button.txt = UIUtil.CreateText(button, txt, txtSize) -- TODO
    button.txt:SetColor(txtColor)
    button.txt:SetFont(UIUtil.bodyFont, txtSize)
    LayoutHelpers.AtVerticalCenterIn(button.txt, button)
    LayoutHelpers.AtHorizontalCenterIn(button.txt, button)

    button:SetAlpha(0.8)
    button.txt:SetAlpha(0.8)

    button.OnMouseClick = function(self) -- override for mouse clicks
        return false
    end

    button.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            button:SetAlpha(1.0)
            button.txt:SetAlpha(1.0)
        elseif event.Type == 'MouseExit' then
            button:SetAlpha(0.8)
            button.txt:SetAlpha(0.8)
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            return button:OnMouseClick()
        end
        return false
    end

    return button
end

function RIGHTSIDE_CreateLine()
    local line = Bitmap(RIGHTSIDE_keyContainer)
    line.Left:Set(RIGHTSIDE_keyContainer.Left)
    line.Right:Set(RIGHTSIDE_keyContainer.Right)
    LayoutHelpers.SetHeight(line, LINEHEIGHT)

    line.description = UIUtil.CreateText(line, '', STANDARD_FONT_SIZE, "Arial")
    line.description:DisableHitTest()
    line.description:SetClipToWidth(true)
    line.description.Width:Set(line.Right() - line.Left())
    line.description:SetAlpha(0.9)

    line.Height:Set(LINEHEIGHT)
    line.Width:Set(function() return line.Right() - line.Left() end)

    LayoutHelpers.AtLeftIn(line.description, line, LINEHEIGHT + BUTTON_PADDING)
    LayoutHelpers.AtVerticalCenterIn(line.description, line)

    line.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            line:SetAlpha(0.9)
            line.description:SetAlpha(1.0)
            PlaySound(Sound({ Cue = "UI_Menu_Rollover_Sml", Bank = "Interface" }))
        elseif event.Type == 'MouseExit' then
            line:SetAlpha(1.0)
            line.description:SetAlpha(0.9)
        elseif self.data.type == 'entry' then
            if event.Type == 'ButtonPress' then
                RIGHTSIDE_SelectLine(self.data.index)
                RIGHTSIDE_keyFilter.text:AcquireFocus()
                return true
            elseif event.Type == 'ButtonDClick' then
                RIGHTSIDE_SelectLine(self.data.index)
                RIGHTSIDE_AssignCurrentSelection()
                return true
            end
        elseif self.data.type == 'header' and (event.Type == 'ButtonPress' or event.Type == 'ButtonDClick') then
            if string.len(RIGHTSIDE_keyword) == 0 then
                RIGHTSIDE_ToggleLines(self.data.category)
                RIGHTSIDE_keyFilter.text:AcquireFocus()

                if RIGHTSIDE_keyGroups[self.data.category].collapsed then
                    self.toggle.txt:SetText('+')
                else
                    self.toggle.txt:SetText('-')
                end
                PlaySound(Sound({ Cue = "UI_Menu_MouseDown_Sml", Bank = "Interface" }))
                return true
            end
        end
        return false
    end

    line.AssignKeyBinding = function(self)
        RIGHTSIDE_SelectLine(self.data.index)
        RIGHTSIDE_AssignCurrentSelection()
    end

    line.UnbindKeyBinding = function(self)
        if RIGHTSIDE_keyTable[self.data.index].key then
            RIGHTSIDE_SelectLine(self.data.index)
            RIGHTSIDE_UnbindCurrentSelection()
        end
    end

    line.toggle = RIGHTSIDE_CreateToggle(
        line,
        'FF1B1A1A',
        UIUtil.factionTextColor,
        LINEHEIGHT,
        BUTTON_FONTSIZE,
        '+')

    LayoutHelpers.AtLeftIn(line.toggle, line)
    LayoutHelpers.AtVerticalCenterIn(line.toggle, line)
    Tooltip.AddControlTooltip(line.toggle,
        {
            text = '<LOC key_binding_0010>Toggle Category',
            body = '<LOC key_binding_0011>Toggle visibility of all actions for this category of keys'
        })

    line.unbindKeyButton = RIGHTSIDE_CreateToggle(
        line,
        '645F5E5E',
        'FFAEACAC',
        LINEHEIGHT,
        BUTTON_FONTSIZE,
        'x')

    LayoutHelpers.AtRightIn(line.unbindKeyButton, line)
    LayoutHelpers.AtVerticalCenterIn(line.unbindKeyButton, line)
    Tooltip.AddControlTooltip(line.unbindKeyButton,
        {
            text = "<LOC key_binding_0007>Unbind Key",
            body = '<LOC key_binding_0013>Removes currently assigned key binding for a given action'
        })

    line.unbindKeyButton.OnMouseClick = function(self)
        line:UnbindKeyBinding()
        return true
    end

    line.Update = function(self, data, lineID)
        line:SetSolidColor(RIGHTSIDE_GetLineColor(lineID, data))
        line.data = table.copy(data)

        if data.type == 'header' then
            if RIGHTSIDE_keyGroups[self.data.category].collapsed then
                self.toggle.txt:SetText('+')
            else
                self.toggle.txt:SetText('-')
            end
            line.toggle:Show()
            line.unbindKeyButton:Hide()
            line.description:SetText(data.text)
            line.description:SetFont('Arial', HEADER_FONT_SIZE)
            line.description:SetColor(UIUtil.fontColor)
            line.description:SetColor('ffffffff')
        elseif data.type == 'spacer' then
            line.toggle:Hide()
            line.unbindKeyButton:Hide()
            line.description:SetText('')
        elseif data.type == 'entry' then
            line.toggle:Hide()
            line.description:SetText(data.text)
            line.description:SetFont('Arial', STANDARD_FONT_SIZE)
            line.description:SetColor(UIUtil.fontColor)
            line.unbindKeyButton:Show()
        end
    end
    return line
end

function RIGHTSIDE_SortData(dataTable)
    table.sort(dataTable, function(a, b)
        if a.order ~= b.order then
            return a.order < b.order
        else
            if a.category ~= b.category then
                return string.lower(a.category) < string.lower(b.category)
            else
                if a.type == 'entry' and b.type == 'entry' then
                    if string.lower(a.text) ~= string.lower(b.text) then
                        return string.lower(a.text) < string.lower(b.text)
                    else
                        return a.action < b.action
                    end
                else
                    return a.id < b.id
                end
            end
        end
    end)
end

function RIGHTSIDE_RECURSIVE_FORMATTING(k, entries)

    -- create header if it doesn't exist
    if not RIGHTSIDE_keyGroups[k] then
        RIGHTSIDE_keyGroups[k] = {}
        RIGHTSIDE_keyGroups[k].actions = {}
        RIGHTSIDE_keyGroups[k].name = k
        RIGHTSIDE_keyGroups[k].collapsed = RIGHTSIDE_linesCollapsed
        RIGHTSIDE_keyGroups[k].order = table.getsize(RIGHTSIDE_keyGroups) - 1
        RIGHTSIDE_keyGroups[k].text = k
    end

    local orderIndex = 1

    for entryKey, entry in entries do

        if entry["print"] ~= nil then
            table.insert(RIGHTSIDE_keyGroups[k].actions, {
                action = "ACTION",
                key = "KEY",
                keyText = '',
                category = k,
                order = RIGHTSIDE_keyGroups[k].order + orderIndex,
                text = entry['print'],
                wikiURL = entry.wikiURL
            })
            orderIndex = orderIndex + 1
        end

        if entry["executable"] ~= nil then
            table.insert(RIGHTSIDE_keyGroups[k].actions, {
                action = "ACTION",
                key = "KEY",
                keyText = '',
                category = k,
                order = RIGHTSIDE_keyGroups[k].order + orderIndex,
                text = entry['executable'],
                wikiURL = entries.wikiURL
            })
            orderIndex = orderIndex + 1
        end

        if entry["immediate"] ~= nil then
            -- RECURSIVE_FORMATTING(entry["immediate"])
        end

        if entry["conditionals"] ~= nil then
            if entry["valid"] ~= nil then
                -- RECURSIVE_FORMATTING(entry["valid"])
            end
            if entry["invalid"] ~= nil then
                -- RECURSIVE_FORMATTING(entry["invalid"])
            end
        end

        if entry["finally"] ~= nil then
            -- RECURSIVE_FORMATTING(entry["finally"])
        end

        if entry["subkeys"] ~= nil then
            -- RECURSIVE_FORMATTING(entry["subkeys"])
        end

    end
end

function RIGHTSIDE_FormatData()
    local keyData = {}
    local advancedKeyMap = GetPreference('AdvancedHotkeysKeyMap')

    -- reset previously formated key actions in all groups because they might have been re-mapped
    for category, group in RIGHTSIDE_keyGroups do
        group.actions = {}
    end

    for k, v in advancedKeyMap do
        RIGHTSIDE_RECURSIVE_FORMATTING(k, v)
    end

    -- flatten all key actions to a list separated by a header with info about key category
    local index = 1
    for category, group in RIGHTSIDE_keyGroups do
        if not table.empty(group.actions) then
            keyData[index] = {
                type = 'header',
                id = index,
                order = RIGHTSIDE_keyGroups[category].order,
                count = table.getsize(group.actions),
                category = category,
                text = RIGHTSIDE_keyGroups[category].text,
                collapsed = RIGHTSIDE_keyGroups[category].collapsed
            }
            index = index + 1
            for _, data in group.actions do
                keyData[index] = {
                    type = 'entry',
                    text = data.text,
                    action = data.action,
                    key = data.key,
                    keyText = LOC(data.keyText),
                    category = category,
                    order = RIGHTSIDE_keyGroups[category].order,
                    collapsed = RIGHTSIDE_keyGroups[category].collapsed,
                    id = index,
                    wikiURL = data.wikiURL,
                    filters = { -- create filter parameters for quick searching of keys
                        key = string.gsub(string.lower(data.keyText), ' %+ ', ' '),
                        text = string.lower(data.text or ''),
                        action = string.lower(data.action or ''),
                        category = string.lower(data.category or ''),
                    }
                }
                index = index + 1
            end
        end
    end

    RIGHTSIDE_SortData(keyData)

    -- store index of a header line for each key line
    local header = 1
    for i, data in keyData do
        if data.type == 'header' then
            header = i
        elseif data.type == 'entry' then
            data.header = header
        end
        data.index = i
    end

    return keyData
end

local function LEFTSIDE_CreateUI()
    LEFTSIDE_keyword = ''
    LEFTSIDE_keyTable = LEFTSIDE_FormatData()

    RIGHTSIDE_keyword = ''
    RIGHTSIDE_keyTable = RIGHTSIDE_FormatData()

    dialogContent = Group(GetFrame(0))
    LayoutHelpers.SetDimensions(dialogContent, GetFrame(0).Width() - 100, GetFrame(0).Height() - 150)
    LayoutHelpers.AtLeftTopIn(dialogContent, GetFrame(0), 50, 100)

    popup = Popup(GetFrame(0), dialogContent)
    popup.OnShadowClicked = CloseUI
    popup.OnEscapePressed = CloseUI
    popup.OnDestroy = function(self) RemoveInputCapture(dialogContent) end
    popup.OnClosed = function(self)
        LEFTSIDE_ConfirmNewKeyMap()
        RIGHTSIDE_ConfirmNewKeyMap()
    end

    local title = UIUtil.CreateText(dialogContent, LOC("<LOC key_binding_0000>Key Bindings"), 22)
    LayoutHelpers.AtTopIn(title, dialogContent, 12)
    LayoutHelpers.AtHorizontalCenterIn(title, dialogContent)

    local offset = dialogContent.Width() / 5.25

    -- local defaultButton = UIUtil.CreateButtonWithDropshadow(dialogContent, "/BUTTON/medium/",
    --     "<LOC key_binding_0004>Default Preset")
    -- LayoutHelpers.SetWidth(defaultButton, 200)
    -- LayoutHelpers.AtBottomIn(defaultButton, dialogContent, 10)
    -- LayoutHelpers.AtLeftIn(defaultButton, dialogContent,
    --     (offset - (defaultButton.Width() * 3 / 4)) / LayoutHelpers.GetPixelScaleFactor())
    -- defaultButton.OnClick = function(self, modifiers)
    --     UIUtil.QuickDialog(popup,
    --         "<LOC key_binding_0005>Are you sure you want to reset all key bindings to the default (GPG) preset?",
    --         "<LOC _Yes>", ResetBindingToDefaultKeyMap,
    --         "<LOC _No>", nil, nil, nil, true,
    --         { escapeButton = 2, enterButton = 1, worldCover = false })
    -- end
    -- Tooltip.AddControlTooltip(defaultButton,
    --     {
    --         text = "<LOC key_binding_0004>Default Preset",
    --         body = '<LOC key_binding_0022>Reset all key bindings to the default (GPG) preset'
    --     })

    -- local hotbuildButton = UIUtil.CreateButtonWithDropshadow(dialogContent, "/BUTTON/medium/",
    --     "<LOC key_binding_0009>Hotbuild Preset")
    -- LayoutHelpers.SetWidth(hotbuildButton, 200)
    -- LayoutHelpers.AtBottomIn(hotbuildButton, dialogContent, 10)
    -- LayoutHelpers.AtLeftIn(hotbuildButton, defaultButton,
    --     (offset + (defaultButton.Width() * 1 / 4)) / LayoutHelpers.GetPixelScaleFactor())
    -- hotbuildButton.OnClick = function(self, modifiers)
    --     UIUtil.QuickDialog(popup,
    --         "<LOC key_binding_0008>Are you sure you want to reset all key bindings to the hotbuild (FAF) preset?",
    --         "<LOC _Yes>", ResetBindingToHotbuildKeyMap,
    --         "<LOC _No>", nil, nil, nil, true,
    --         { escapeButton = 2, enterButton = 1, worldCover = false })
    -- end
    -- Tooltip.AddControlTooltip(hotbuildButton,
    --     {
    --         text = "<LOC key_binding_0009>Hotbuild Preset",
    --         body = '<LOC key_binding_0020>Reset all key bindings to the hotbuild (FAF) preset'
    --     })

    -- local alternativeButton = UIUtil.CreateButtonWithDropshadow(dialogContent, "/BUTTON/medium/",
    --     "<LOC key_binding_0025>Alternative Preset")
    -- LayoutHelpers.SetWidth(alternativeButton, 200)
    -- LayoutHelpers.AtBottomIn(alternativeButton, dialogContent, 10)
    -- LayoutHelpers.AtLeftIn(alternativeButton, hotbuildButton,
    --     (offset + (defaultButton.Width() * 1 / 4)) / LayoutHelpers.GetPixelScaleFactor())
    -- alternativeButton.OnClick = function(self, modifiers)
    --     UIUtil.QuickDialog(popup,
    --         "<LOC key_binding_0024>Are you sure you want to reset all key bindings to the alternative (FAF) preset?",
    --         "<LOC _Yes>", ResetBindingToalternativeKeyMap,
    --         "<LOC _No>", nil, nil, nil, true,
    --         { escapeButton = 2, enterButton = 1, worldCover = false })
    -- end
    -- Tooltip.AddControlTooltip(alternativeButton,
    --     {
    --         text = "<LOC key_binding_0025>Alternative Preset",
    --         body = '<LOC key_binding_0026>Reset all key bindings to the alternative (FAF) preset'
    --     })

    -- local closeButton = UIUtil.CreateButtonWithDropshadow(dialogContent, "/BUTTON/medium/", LOC("<LOC _Close>"))
    -- LayoutHelpers.SetWidth(closeButton, 200)
    -- LayoutHelpers.AtBottomIn(closeButton, dialogContent, 10)
    -- LayoutHelpers.AtLeftIn(closeButton, alternativeButton,
    --     (offset + (defaultButton.Width() * 1 / 4)) / LayoutHelpers.GetPixelScaleFactor())
    -- Tooltip.AddControlTooltip(closeButton,
    --     {
    --         text = '<LOC _Close>Close',
    --         body = '<LOC key_binding_0021>Closes this dialog and confirms assignments of key bindings'
    --     })
    -- closeButton.OnClick = function(self, modifiers)
    --     -- confirmation of changes will occur on OnClosed of this UI
    --     CloseUI()
    -- end

    dialogContent.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            if event.KeyCode == UIUtil.VK_ESCAPE or event.KeyCode == UIUtil.VK_ENTER or event.KeyCode == 342 then
                closeButton:OnClick()
            end
        end
    end

    -- LEFTSIDE -----------------------------------------------------------------

    LEFTSIDE_Section = Group(dialogContent)

    LayoutHelpers.SetWidth(LEFTSIDE_Section, LEFTSIDE_WIDTH)
    LayoutHelpers.AtLeftIn(LEFTSIDE_Section, dialogContent, SIDE_PADDING)
    LayoutHelpers.AtTopIn(LEFTSIDE_Section, dialogContent, TOP_PADDING)
    LayoutHelpers.AtBottomIn(LEFTSIDE_Section, dialogContent)

    LEFTSIDE_keyFilter = Bitmap(LEFTSIDE_Section)

    LEFTSIDE_keyFilter:SetSolidColor('FF282828')
    LayoutHelpers.AtLeftIn(LEFTSIDE_keyFilter, LEFTSIDE_Section)
    LayoutHelpers.AtTopIn(LEFTSIDE_keyFilter, LEFTSIDE_Section)
    LEFTSIDE_keyFilter.Width:Set(LEFTSIDE_Section.Width())
    LEFTSIDE_keyFilter.Height:Set(30)

    LEFTSIDE_keyFilter:EnableHitTest()
    import("/lua/ui/game/tooltip.lua").AddControlTooltip(LEFTSIDE_keyFilter,
        {
            text = '<LOC key_binding_0018>Key Binding Filter',
            body = '<LOC key_binding_0019>' ..
                'Filter all actions by typing either:' ..
                '\n - full key binding "CTRL+K"' ..
                '\n - partial key binding "CTRL"' ..
                '\n - full action name "Self-Destruct"' ..
                '\n - partial action name "Self"' ..
                '\n\n Note that collapsing of key categories is disabled while this filter contains some text'
        }, nil)

    local text = LOC("<LOC key_binding_filterInfo>Type key binding or name of action")
    LEFTSIDE_keyFilter.info = UIUtil.CreateText(LEFTSIDE_keyFilter, text, 17, UIUtil.titleFont)
    LEFTSIDE_keyFilter.info:SetColor('FF727171')
    LEFTSIDE_keyFilter.info:DisableHitTest()
    LayoutHelpers.AtHorizontalCenterIn(LEFTSIDE_keyFilter.info, LEFTSIDE_keyFilter, -7)
    LayoutHelpers.AtVerticalCenterIn(LEFTSIDE_keyFilter.info, LEFTSIDE_keyFilter, 2)

    LEFTSIDE_keyFilter.text = Edit(LEFTSIDE_keyFilter)
    LEFTSIDE_keyFilter.text:SetForegroundColor('FFF1ECEC')
    LEFTSIDE_keyFilter.text:SetBackgroundColor('04E1B44A')
    LEFTSIDE_keyFilter.text:SetHighlightForegroundColor(UIUtil.highlightColor)
    LEFTSIDE_keyFilter.text:SetHighlightBackgroundColor("880085EF")
    LEFTSIDE_keyFilter.text.Height:Set(function() return LEFTSIDE_keyFilter.Bottom() - LEFTSIDE_keyFilter.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    LayoutHelpers.AtLeftIn(LEFTSIDE_keyFilter.text, LEFTSIDE_keyFilter, 5)
    LayoutHelpers.AtRightIn(LEFTSIDE_keyFilter.text, LEFTSIDE_keyFilter)
    LayoutHelpers.AtVerticalCenterIn(LEFTSIDE_keyFilter.text, LEFTSIDE_keyFilter)
    LEFTSIDE_keyFilter.text:AcquireFocus()
    LEFTSIDE_keyFilter.text:SetText('')
    LEFTSIDE_keyFilter.text:SetFont(UIUtil.titleFont, 17)
    LEFTSIDE_keyFilter.text:SetMaxChars(20)
    LEFTSIDE_keyFilter.text.OnTextChanged = function(self, newText, oldText)
        -- interpret plus chars as spaces for easier key filtering
        LEFTSIDE_keyword = string.gsub(string.lower(newText), '+', ' ')
        LEFTSIDE_keyword = string.gsub(string.lower(LEFTSIDE_keyword), '  ', ' ')
        LEFTSIDE_keyword = string.gsub(string.lower(LEFTSIDE_keyword), '  ', ' ')
        if string.len(LEFTSIDE_keyword) == 0 then
            for k, v in LEFTSIDE_keyGroups do
                v.collapsed = true
            end
            for k, v in LEFTSIDE_keyTable do
                v.collapsed = true
            end
        end
        LEFTSIDE_keyContainer:Filter(LEFTSIDE_keyword)
        LEFTSIDE_keyContainer:ScrollSetTop(nil, 0)
    end

    LEFTSIDE_keyFilter.clear = UIUtil.CreateText(LEFTSIDE_keyFilter.text, 'X', 17, "Arial Bold")
    LEFTSIDE_keyFilter.clear:SetColor('FF8A8A8A')
    LEFTSIDE_keyFilter.clear:EnableHitTest()
    LayoutHelpers.AtVerticalCenterIn(LEFTSIDE_keyFilter.clear, LEFTSIDE_keyFilter.text, 1)
    LayoutHelpers.AtRightIn(LEFTSIDE_keyFilter.clear, LEFTSIDE_keyFilter.text, 9)

    LEFTSIDE_keyFilter.clear.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            LEFTSIDE_keyFilter.clear:SetColor('FFC9C7C7')
        elseif event.Type == 'MouseExit' then
            LEFTSIDE_keyFilter.clear:SetColor('FF8A8A8A')
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            LEFTSIDE_keyFilter.text:SetText('')
            LEFTSIDE_keyFilter.text:AcquireFocus()
        end
        return true
    end
    Tooltip.AddControlTooltip(LEFTSIDE_keyFilter.clear,
        {
            text = '<LOC key_binding_0016>Clear Filter',
            body = '<LOC key_binding_0017>Clears text that was typed in the filter field.'
        })

    LEFTSIDE_keyContainer = Group(LEFTSIDE_Section)
    LayoutHelpers.AtLeftIn(LEFTSIDE_keyContainer, LEFTSIDE_Section)
    LayoutHelpers.AtRightIn(LEFTSIDE_keyContainer, LEFTSIDE_Section)
    LayoutHelpers.AnchorToBottom(LEFTSIDE_keyContainer, LEFTSIDE_keyFilter, 10)
    LayoutHelpers.AtBottomIn(LEFTSIDE_keyContainer, LEFTSIDE_Section, SIDE_PADDING)
    LEFTSIDE_keyContainer.Height:Set(function() return LEFTSIDE_keyContainer.Bottom() - LEFTSIDE_keyContainer.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    LEFTSIDE_keyContainer.top = 0
    UIUtil.CreateLobbyVertScrollbar(LEFTSIDE_keyContainer)

    local index = 1
    LEFTSIDE_keyEntries = {}
    LEFTSIDE_keyEntries[index] = LEFTSIDE_CreateLine()
    LayoutHelpers.AtTopIn(LEFTSIDE_keyEntries[1], LEFTSIDE_keyContainer)

    index = index + 1
    while LEFTSIDE_keyEntries[table.getsize(LEFTSIDE_keyEntries)].Top() + (2 * LEFTSIDE_keyEntries[1].Height()) <
        LEFTSIDE_keyContainer.Bottom() do
        LEFTSIDE_keyEntries[index] = LEFTSIDE_CreateLine()
        LayoutHelpers.Below(LEFTSIDE_keyEntries[index], LEFTSIDE_keyEntries[index - 1])
        index = index + 1
    end

    -- Unused? Came with original file I think
    -- local height = LEFTSIDE_keyContainer.Height()
    -- local items = math.floor(LEFTSIDE_keyContainer.Height() / LEFTSIDE_keyEntries[1].Height())

    local LEFTSIDE_GetLinesTotal = function()
        return table.getsize(LEFTSIDE_keyEntries)
    end

    local function LEFTSIDE_GetLinesVisible()
        return table.getsize(LEFTSIDE_linesVisible)
    end

    -- Called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- axis can be "Vert" or "Horz"
    LEFTSIDE_keyContainer.GetScrollValues = function(self, axis)
        local size = LEFTSIDE_GetLinesVisible()
        local visibleMax = math.min(self.top + LEFTSIDE_GetLinesTotal(), size)
        return 0, size, self.top, visibleMax
    end

    -- Called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    LEFTSIDE_keyContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- Called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    LEFTSIDE_keyContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * LEFTSIDE_GetLinesTotal())
    end

    -- Called when the scrollbar wants to set a new visible top line
    LEFTSIDE_keyContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = LEFTSIDE_GetLinesVisible()
        self.top = math.max(math.min(size - LEFTSIDE_GetLinesTotal(), top), 0)
        self:CalcVisible()
    end

    -- Called to determine if the control is scrollable on a particular access. Must return true or false.
    LEFTSIDE_keyContainer.IsScrollable = function(self, axis)
        return true
    end

    -- Determines what control lines should be visible or not
    LEFTSIDE_keyContainer.CalcVisible = function(self)
        for i, line in LEFTSIDE_keyEntries do
            local id = i + self.top
            local index = LEFTSIDE_linesVisible[id]
            local data = LEFTSIDE_keyTable[index]

            if data then
                line:Update(data, id)
            else
                line:SetSolidColor('00000000')
                line.key:SetText('')
                line.description:SetText('')
                line.statistics:SetText('')
                line.toggle:Hide()
                line.assignKeyButton:Hide()
                line.unbindKeyButton:Hide()
                line.wikiButton:Hide()
            end
        end
        LEFTSIDE_keyFilter.text:AcquireFocus()
    end

    LEFTSIDE_keyContainer.HandleEvent = function(control, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            control:ScrollLines(nil, lines)
        end
    end
    -- filter all key-bindings by checking if either text, action, or a key contains target string
    LEFTSIDE_keyContainer.Filter = function(self, target)
        local headersVisible = {}
        LEFTSIDE_linesVisible = {}

        if not target or string.len(target) == 0 then
            LEFTSIDE_keyFilter.info:Show()
            for k, v in LEFTSIDE_keyTable do
                if v.type == 'header' then
                    table.insert(LEFTSIDE_linesVisible, k)
                    LEFTSIDE_keyGroups[v.category].visible = v.count
                    LEFTSIDE_keyGroups[v.category].bindings = 0
                elseif v.type == 'entry' then
                    if not v.collapsed then
                        table.insert(LEFTSIDE_linesVisible, k)
                    end
                    if v.key then
                        LEFTSIDE_keyGroups[v.category].bindings = LEFTSIDE_keyGroups[v.category].bindings + 1
                    end
                end
            end
        else
            LEFTSIDE_keyFilter.info:Hide()
            for k, v in LEFTSIDE_keyTable do
                local match = false
                if v.type == 'header' then
                    LEFTSIDE_keyGroups[v.category].visible = 0
                    LEFTSIDE_keyGroups[v.category].bindings = 0
                    if not headersVisible[k] then
                        headersVisible[k] = true
                        table.insert(LEFTSIDE_linesVisible, k)
                        LEFTSIDE_keyGroups[v.category].collapsed = true
                    end
                elseif v.type == 'entry' and v.filters then
                    if string.find(v.filters.text, target) then
                        match = true
                        v.filterMatch = 'text'
                    elseif string.find(v.filters.key, target) then
                        match = true
                        v.filterMatch = 'key'
                    elseif string.find(v.filters.action, target) then
                        match = true
                        v.filterMatch = 'action'
                    elseif string.find(v.filters.category, target) then
                        match = true
                        v.filterMatch = 'category'
                    else
                        match = false
                        v.filterMatch = nil
                    end
                    if match then
                        if not headersVisible[v.header] then
                            headersVisible[v.header] = true
                            table.insert(LEFTSIDE_linesVisible, v.header)
                        end
                        LEFTSIDE_keyGroups[v.category].collapsed = false
                        LEFTSIDE_keyGroups[v.category].visible = LEFTSIDE_keyGroups[v.category].visible + 1
                        table.insert(LEFTSIDE_linesVisible, k)
                        if v.key then
                            LEFTSIDE_keyGroups[v.category].bindings = LEFTSIDE_keyGroups[v.category].bindings + 1
                        end
                    end
                end
            end
        end
        self:CalcVisible()
    end
    LEFTSIDE_keyFilter.text:SetText('')
end

local function RIGHTSIDE_CreateUI()
    RIGHTSIDE_Section = Group(dialogContent)

    LayoutHelpers.SetWidth(RIGHTSIDE_Section, dialogContent.Width() - (LEFTSIDE_Section.Width() + (SIDE_PADDING * 6)))
    LayoutHelpers.AtLeftIn(RIGHTSIDE_Section, dialogContent, LEFTSIDE_Section.Width() + (SIDE_PADDING * 3))
    LayoutHelpers.AtTopIn(RIGHTSIDE_Section, dialogContent, TOP_PADDING)
    LayoutHelpers.AtBottomIn(RIGHTSIDE_Section, dialogContent)

    RIGHTSIDE_keyFilter = Bitmap(RIGHTSIDE_Section)

    RIGHTSIDE_keyFilter:SetSolidColor('FF282828')
    LayoutHelpers.AtLeftIn(RIGHTSIDE_keyFilter, RIGHTSIDE_Section)
    LayoutHelpers.AtTopIn(RIGHTSIDE_keyFilter, RIGHTSIDE_Section)
    RIGHTSIDE_keyFilter.Width:Set(RIGHTSIDE_Section.Width())
    RIGHTSIDE_keyFilter.Height:Set(30)

    RIGHTSIDE_keyFilter:EnableHitTest()
    import("/lua/ui/game/tooltip.lua").AddControlTooltip(RIGHTSIDE_keyFilter,
        {
            text = '<LOC key_binding_0018>Key Binding Filter',
            body = '<LOC key_binding_0019>' ..
                'Filter all actions by typing either:' ..
                '\n - full key binding "CTRL+K"' ..
                '\n - partial key binding "CTRL"' ..
                '\n - full action name "Self-Destruct"' ..
                '\n - partial action name "Self"' ..
                '\n\n Note that collapsing of key categories is disabled while this filter contains some text'
        }, nil)

    local text = LOC("<LOC key_binding_filterInfo>Type key binding or name of action")
    RIGHTSIDE_keyFilter.info = UIUtil.CreateText(RIGHTSIDE_keyFilter, text, 17, UIUtil.titleFont)
    RIGHTSIDE_keyFilter.info:SetColor('FF727171')
    RIGHTSIDE_keyFilter.info:DisableHitTest()
    LayoutHelpers.AtHorizontalCenterIn(RIGHTSIDE_keyFilter.info, RIGHTSIDE_keyFilter, -7)
    LayoutHelpers.AtVerticalCenterIn(RIGHTSIDE_keyFilter.info, RIGHTSIDE_keyFilter, 2)

    RIGHTSIDE_keyFilter.text = Edit(RIGHTSIDE_keyFilter)
    RIGHTSIDE_keyFilter.text:SetForegroundColor('FFF1ECEC')
    RIGHTSIDE_keyFilter.text:SetBackgroundColor('04E1B44A')
    RIGHTSIDE_keyFilter.text:SetHighlightForegroundColor(UIUtil.highlightColor)
    RIGHTSIDE_keyFilter.text:SetHighlightBackgroundColor("880085EF")
    RIGHTSIDE_keyFilter.text.Height:Set(function() return RIGHTSIDE_keyFilter.Bottom() - RIGHTSIDE_keyFilter.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    LayoutHelpers.AtLeftIn(RIGHTSIDE_keyFilter.text, RIGHTSIDE_keyFilter, 5)
    LayoutHelpers.AtRightIn(RIGHTSIDE_keyFilter.text, RIGHTSIDE_keyFilter)
    LayoutHelpers.AtVerticalCenterIn(RIGHTSIDE_keyFilter.text, RIGHTSIDE_keyFilter)
    RIGHTSIDE_keyFilter.text:AcquireFocus()
    RIGHTSIDE_keyFilter.text:SetText('')
    RIGHTSIDE_keyFilter.text:SetFont(UIUtil.titleFont, 17)
    RIGHTSIDE_keyFilter.text:SetMaxChars(20)
    RIGHTSIDE_keyFilter.text.OnTextChanged = function(self, newText, oldText)
        -- interpret plus chars as spaces for easier key filtering
        RIGHTSIDE_keyword = string.gsub(string.lower(newText), '+', ' ')
        RIGHTSIDE_keyword = string.gsub(string.lower(RIGHTSIDE_keyword), '  ', ' ')
        RIGHTSIDE_keyword = string.gsub(string.lower(RIGHTSIDE_keyword), '  ', ' ')
        if string.len(RIGHTSIDE_keyword) == 0 then
            for k, v in RIGHTSIDE_keyGroups do
                v.collapsed = true
            end
            for k, v in RIGHTSIDE_keyTable do
                v.collapsed = true
            end
        end
        RIGHTSIDE_keyContainer:Filter(RIGHTSIDE_keyword)
        RIGHTSIDE_keyContainer:ScrollSetTop(nil, 0)
    end

    RIGHTSIDE_keyFilter.clear = UIUtil.CreateText(RIGHTSIDE_keyFilter.text, 'X', 17, "Arial Bold")
    RIGHTSIDE_keyFilter.clear:SetColor('FF8A8A8A')
    RIGHTSIDE_keyFilter.clear:EnableHitTest()
    LayoutHelpers.AtVerticalCenterIn(RIGHTSIDE_keyFilter.clear, RIGHTSIDE_keyFilter.text, 1)
    LayoutHelpers.AtRightIn(RIGHTSIDE_keyFilter.clear, RIGHTSIDE_keyFilter.text, 9)

    RIGHTSIDE_keyFilter.clear.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            RIGHTSIDE_keyFilter.clear:SetColor('FFC9C7C7')
        elseif event.Type == 'MouseExit' then
            RIGHTSIDE_keyFilter.clear:SetColor('FF8A8A8A')
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            RIGHTSIDE_keyFilter.text:SetText('')
            RIGHTSIDE_keyFilter.text:AcquireFocus()
        end
        return true
    end
    Tooltip.AddControlTooltip(RIGHTSIDE_keyFilter.clear,
        {
            text = '<LOC key_binding_0016>Clear Filter',
            body = '<LOC key_binding_0017>Clears text that was typed in the filter field.'
        })

    RIGHTSIDE_keyContainer = Group(RIGHTSIDE_Section)
    LayoutHelpers.AtLeftIn(RIGHTSIDE_keyContainer, RIGHTSIDE_Section)
    LayoutHelpers.AtRightIn(RIGHTSIDE_keyContainer, RIGHTSIDE_Section)
    LayoutHelpers.AnchorToBottom(RIGHTSIDE_keyContainer, RIGHTSIDE_keyFilter, 10)
    LayoutHelpers.AtBottomIn(RIGHTSIDE_keyContainer, RIGHTSIDE_Section, SIDE_PADDING)
    RIGHTSIDE_keyContainer.Height:Set(function() return RIGHTSIDE_keyContainer.Bottom() - RIGHTSIDE_keyContainer.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    RIGHTSIDE_keyContainer.top = 0
    UIUtil.CreateLobbyVertScrollbar(RIGHTSIDE_keyContainer)

    local index = 1
    RIGHTSIDE_keyEntries = {}
    RIGHTSIDE_keyEntries[index] = RIGHTSIDE_CreateLine()
    LayoutHelpers.AtTopIn(RIGHTSIDE_keyEntries[1], RIGHTSIDE_keyContainer)

    index = index + 1
    while RIGHTSIDE_keyEntries[table.getsize(RIGHTSIDE_keyEntries)].Top() + (2 * RIGHTSIDE_keyEntries[1].Height()) <
        RIGHTSIDE_keyContainer.Bottom() do
        RIGHTSIDE_keyEntries[index] = RIGHTSIDE_CreateLine()
        LayoutHelpers.Below(RIGHTSIDE_keyEntries[index], RIGHTSIDE_keyEntries[index - 1])
        index = index + 1
    end

    -- Unused? Came with original file I think
    -- local height = RIGHTSIDE_keyContainer.Height()
    -- local items = math.floor(RIGHTSIDE_keyContainer.Height() / RIGHTSIDE_keyEntries[1].Height())

    local RIGHTSIDE_GetLinesTotal = function()
        return table.getsize(RIGHTSIDE_keyEntries)
    end

    local function RIGHTSIDE_GetLinesVisible()
        return table.getsize(RIGHTSIDE_linesVisible)
    end

    -- Called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- axis can be "Vert" or "Horz"
    RIGHTSIDE_keyContainer.GetScrollValues = function(self, axis)
        local size = RIGHTSIDE_GetLinesVisible()
        local visibleMax = math.min(self.top + RIGHTSIDE_GetLinesTotal(), size)
        return 0, size, self.top, visibleMax
    end

    -- Called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    RIGHTSIDE_keyContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- Called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    RIGHTSIDE_keyContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * RIGHTSIDE_GetLinesTotal())
    end

    -- Called when the scrollbar wants to set a new visible top line
    RIGHTSIDE_keyContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = RIGHTSIDE_GetLinesVisible()
        self.top = math.max(math.min(size - RIGHTSIDE_GetLinesTotal(), top), 0)
        self:CalcVisible()
    end

    -- Called to determine if the control is scrollable on a particular access. Must return true or false.
    RIGHTSIDE_keyContainer.IsScrollable = function(self, axis)
        return true
    end

    -- Determines what control lines should be visible or not
    RIGHTSIDE_keyContainer.CalcVisible = function(self)
        for i, line in RIGHTSIDE_keyEntries do
            local id = i + self.top
            local index = RIGHTSIDE_linesVisible[id]
            local data = RIGHTSIDE_keyTable[index]

            if data then
                line:Update(data, id)
            else
                line:SetSolidColor('00000000') ----00000000
                line.description:SetText('')
                line.toggle:Hide()
                line.unbindKeyButton:Hide()
            end
        end
        RIGHTSIDE_keyFilter.text:AcquireFocus()
    end

    RIGHTSIDE_keyContainer.HandleEvent = function(control, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            control:ScrollLines(nil, lines)
        end
    end
    -- filter all key-bindings by checking if either text, action, or a key contains target string
    RIGHTSIDE_keyContainer.Filter = function(self, target)
        local headersVisible = {}
        RIGHTSIDE_linesVisible = {}

        if not target or string.len(target) == 0 then
            RIGHTSIDE_keyFilter.info:Show()
            for k, v in RIGHTSIDE_keyTable do
                if v.type == 'header' then
                    table.insert(RIGHTSIDE_linesVisible, k)
                    RIGHTSIDE_keyGroups[v.category].visible = v.count
                    RIGHTSIDE_keyGroups[v.category].bindings = 0
                elseif v.type == 'entry' then
                    if not v.collapsed then
                        table.insert(RIGHTSIDE_linesVisible, k)
                    end
                    if v.key then
                        RIGHTSIDE_keyGroups[v.category].bindings = RIGHTSIDE_keyGroups[v.category].bindings + 1
                    end
                end
            end
        else
            RIGHTSIDE_keyFilter.info:Hide()
            for k, v in RIGHTSIDE_keyTable do
                local match = false
                if v.type == 'header' then
                    RIGHTSIDE_keyGroups[v.category].visible = 0
                    RIGHTSIDE_keyGroups[v.category].bindings = 0
                    if not headersVisible[k] then
                        headersVisible[k] = true
                        table.insert(RIGHTSIDE_linesVisible, k)
                        RIGHTSIDE_keyGroups[v.category].collapsed = true
                    end
                elseif v.type == 'entry' and v.filters then
                    if string.find(v.filters.text, target) then
                        match = true
                        v.filterMatch = 'text'
                    elseif string.find(v.filters.key, target) then
                        match = true
                        v.filterMatch = 'key'
                    elseif string.find(v.filters.action, target) then
                        match = true
                        v.filterMatch = 'action'
                    elseif string.find(v.filters.category, target) then
                        match = true
                        v.filterMatch = 'category'
                    else
                        match = false
                        v.filterMatch = nil
                    end
                    if match then
                        if not headersVisible[v.header] then
                            headersVisible[v.header] = true
                            table.insert(RIGHTSIDE_linesVisible, v.header)
                        end
                        RIGHTSIDE_keyGroups[v.category].collapsed = false
                        RIGHTSIDE_keyGroups[v.category].visible = RIGHTSIDE_keyGroups[v.category].visible + 1
                        table.insert(RIGHTSIDE_linesVisible, k)
                        if v.key then
                            RIGHTSIDE_keyGroups[v.category].bindings = RIGHTSIDE_keyGroups[v.category].bindings + 1
                        end
                    end
                end
            end
        end
        self:CalcVisible()
    end
    RIGHTSIDE_keyFilter.text:SetText('')
end

function CreateUI()
    LOG('Keybindings CreateUI')

    if WorldIsLoading() or (import("/lua/ui/game/gamemain.lua").supressExitDialog == true) then return end

    if popup then CloseUI() return end

    LEFTSIDE_CreateUI()

    RIGHTSIDE_CreateUI()
end

function CloseUI()
    LOG('Keybindings CloseUI')
    if popup then
        popup:Close()
        popup = false
    end
end

-- Needed elsewhere
function FormatKeyName(key)
    if not key then
        return ""
    end

    local function LookupToken(token)
        if properKeyNames[token] then
            return LOC(properKeyNames[token])
        else
            return token
        end
    end

    local result = ''

    while string.find(key, '-') do
        local loc = string.find(key, '-')
        local token = string.sub(key, 1, loc - 1)
        result = result .. LookupToken(token) .. ' + '
        key = string.sub(key, loc + 1)
    end

    return result .. LookupToken(key)
end

-- kept for mod backwards compatibility
local Text = import("/lua/maui/text.lua").Text
