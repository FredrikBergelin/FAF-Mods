-----------------------------------------------------------------
-- File: lua/ui/game/helptext.lua
-- Author: Ted Snook
-- Summary: Help Text Popup
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

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

local FormatKeyActionData

local keyActionTable
local keyActionsSection
local keyActionsContainer
local keyActionsFilter
local keyActionEntries = {}
local keyActionLinesVisible = {} -- store indexes of visible keyActionLines including headers and key entries

local keyActionLinesCollapsed = true

local keyBindingTable
local keyBindingsSection
local keyBindingsContainer
local keyBindingsFilter
local keyBindingsEntries = {}
local keyBindingsLinesVisible = {}

local keyword = ''

local keyActionsSectionWidth = 500


-- store info about current state of key categories and preserve their state between FormatData() calls
local keyGroups = {}
for order, category in keyCategoryOrder do
    local name = string.lower(category)
    keyGroups[name] = {}
    keyGroups[name].order = order
    keyGroups[name].name = name
    keyGroups[name].text = LOC(keyCategories[category])
    keyGroups[name].collapsed = keyActionLinesCollapsed
end

local function ConfirmNewKeyMap()
    KeyMapper.SaveUserKeyMap()
    IN_ClearKeyMap()
    IN_AddKeyMapTable(KeyMapper.GetKeyMappings(true))
    -- update hotbuild modifiers and re-initialize hotbuild labels
    if SessionIsActive() then
        import("/lua/keymap/hotbuild.lua").addModifiers()
        import("/lua/keymap/hotkeylabels.lua").init()
    end
end

local function ClearActionKey(action, currentKey)
    KeyMapper.ClearUserKeyMapping(currentKey)
    -- auto-clear shift action, e.g. 'shift_attack' for 'attack' action
    local target = KeyMapper.GetShiftAction(action, 'orders')
    if target and target.key then
        KeyMapper.ClearUserKeyMapping(target.key)
    end
end

local function EditActionKey(parent, action, currentKey)
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

    local helpText = MultiLineText(dialogContent, UIUtil.bodyFont, 16, UIUtil.fontColor)
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
            local keyMapping = KeyMapper.GetKeyMappingKeyBindings()
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
            keyActionTable = FormatKeyActionData()
            keyActionsContainer:Filter(keyword)
        end

        -- checks if this key is already assigned to some other action
        local keyMapping = KeyMapper.GetKeyMappingKeyBindings()
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

local function AssignCurrentSelection()
    for k, v in keyActionTable do
        if v.selected then
            EditActionKey(popup, v.action, v.key)
            break
        end
    end
end

local function UnbindCurrentSelection()
    for k, v in keyActionTable do
        if v.selected then
            ClearActionKey(v.action, v.key)
            break
        end
    end
    keyActionTable = FormatKeyActionData()
    keyActionsContainer:Filter(keyword)
end

local function GetLineColor(keyActionLineID, data)
    if data.type == 'header' then
        return 'FF282828' ----FF282828
    elseif data.type == 'spacer' then
        return '00000000' ----00000000
    elseif data.type == 'entry' then
        if data.selected then
            return UIUtil.factionBackColor
        elseif math.mod(keyActionLineID, 2) == 1 then
            return 'ff202020'
        else
            return 'FF343333'
        end
    else
        return 'FF6B0088'
    end
end

-- toggles expansion or collapse of keyActionLines with specified key category only if searching is not active
local function ToggleKeyActionLines(category)
    if keyword and string.len(keyword) > 0 then return end

    for k, v in keyActionTable do
        if v.category == category then
            if v.collapsed then
                v.collapsed = false
            else
                v.collapsed = true
            end
        end
    end
    if keyGroups[category].collapsed then
        keyGroups[category].collapsed = false
    else
        keyGroups[category].collapsed = true
    end
    keyActionsContainer:Filter(keyword)
end

local function SelectLine(dataIndex)
    for k, v in keyActionTable do
        v.selected = false
    end

    if keyActionTable[dataIndex].type == 'entry' then
        keyActionTable[dataIndex].selected = true
    end
    keyActionsContainer:Filter(keyword)
end

function CreateToggle(parent, bgColor, txtColor, bgSize, txtSize, txt)
    if not bgSize then bgSize = 20 end
    if not bgColor then bgColor = 'FF343232' end -- --FF343232
    if not txtColor then txtColor = UIUtil.factionTextColor end
    if not txtSize then txtSize = 18 end
    if not txt then txt = '?' end

    local button = Bitmap(parent)
    button:SetSolidColor(bgColor)
    button.Height:Set(bgSize)
    button.Width:Set(bgSize + 4)
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

-- create a keyActionLine with dynamically updating UI elements based on type of data keyActionLine
function CreateKeyActionLine()
    local keyActionLine = Bitmap(keyActionsContainer)
    keyActionLine.Left:Set(keyActionsContainer.Left)
    keyActionLine.Right:Set(keyActionsContainer.Right)
    LayoutHelpers.SetHeight(keyActionLine, 24)

    keyActionLine.description = UIUtil.CreateText(keyActionLine, '', 16, "Arial")
    keyActionLine.description:DisableHitTest()
    keyActionLine.description:SetClipToWidth(true)
    keyActionLine.description.Width:Set(function() return keyActionLine.Width() - 50 end)
    keyActionLine.description:SetAlpha(0.9)

    keyActionLine.Height:Set(24)
    keyActionLine.Width:Set(function() return keyActionLine.Right() - keyActionLine.Left() end)

    keyActionLine.statistics = UIUtil.CreateText(keyActionLine, '', 16, "Arial")
    keyActionLine.statistics:EnableHitTest()
    keyActionLine.statistics:SetColor('FF9A9A9A')
    keyActionLine.statistics:SetAlpha(0.9)

    Tooltip.AddControlTooltip(keyActionLine.statistics,
        {
            text = '<LOC key_binding_0014>Category Statistics',
            body = '<LOC key_binding_0015>Show total of bound actions and total of all actions in this category of keys'
        })

    LayoutHelpers.AtLeftIn(keyActionLine.description, keyActionLine, 40)
    LayoutHelpers.AtVerticalCenterIn(keyActionLine.description, keyActionLine)
    LayoutHelpers.AtRightIn(keyActionLine.statistics, keyActionLine, 10)
    LayoutHelpers.AtVerticalCenterIn(keyActionLine.statistics, keyActionLine)

    -- Remove keyActionLine.key and adjust HandleEvent function accordingly

    keyActionLine.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            keyActionLine:SetAlpha(0.9)
            keyActionLine.description:SetAlpha(1.0)
            keyActionLine.statistics:SetAlpha(1.0)
            PlaySound(Sound({ Cue = "UI_Menu_Rollover_Sml", Bank = "Interface" }))
        elseif event.Type == 'MouseExit' then
            keyActionLine:SetAlpha(1.0)
            keyActionLine.description:SetAlpha(0.9)
            keyActionLine.statistics:SetAlpha(0.9)
        elseif self.data.type == 'entry' then
            if event.Type == 'ButtonPress' then
                SelectLine(self.data.index)
                keyActionsFilter.text:AcquireFocus()
                return true
            elseif event.Type == 'ButtonDClick' then
                SelectLine(self.data.index)
                AssignCurrentSelection()
                return true
            end
        elseif self.data.type == 'header' and (event.Type == 'ButtonPress' or event.Type == 'ButtonDClick') then
            if string.len(keyword) == 0 then
                ToggleKeyActionLines(self.data.category)
                keyActionsFilter.text:AcquireFocus()

                if keyGroups[self.data.category].collapsed then
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

    keyActionLine.AssignKeyBinding = function(self)
        SelectLine(self.data.index)
        AssignCurrentSelection()
    end

    keyActionLine.UnbindKeyBinding = function(self)
        if keyActionTable[self.data.index].key then
            SelectLine(self.data.index)
            UnbindCurrentSelection()
        end
    end

    keyActionLine.toggle = CreateToggle(keyActionLine,
        'FF1B1A1A',
        UIUtil.factionTextColor,
        keyActionLine.description.Height() + 4, 18, '+')
    LayoutHelpers.AtLeftIn(keyActionLine.toggle, keyActionLine)
    LayoutHelpers.AtVerticalCenterIn(keyActionLine.toggle, keyActionLine)
    Tooltip.AddControlTooltip(keyActionLine.toggle,
        {
            text = '<LOC key_binding_0010>Toggle Category',
            body = '<LOC key_binding_0011>Toggle visibility of all actions for this category of keys'
        })

    keyActionLine.wikiButton = UIUtil.CreateBitmap(keyActionLine, '/textures/ui/common/mods/mod_url_website.dds')
    LayoutHelpers.SetDimensions(keyActionLine.wikiButton, 20, 20)
    LayoutHelpers.AtRightIn(keyActionLine.wikiButton, keyActionLine, 10)
    LayoutHelpers.AtVerticalCenterIn(keyActionLine.wikiButton, keyActionLine)
    keyActionLine.wikiButton:SetAlpha(0.5)
    keyActionLine.wikiButton.HandleEvent = function(self, event)
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

    import("/lua/ui/game/tooltip.lua").AddControlTooltipManual(keyActionLine.wikiButton,
        'Learn more on the Wiki of FAForever', ''
        , 0, 140, 6, 14, 14, 'left')

    keyActionLine.assignKeyButton = CreateToggle(keyActionLine,
        '645F5E5E',
        'FFAEACAC',
        keyActionLine.description.Height() + 4, 18, '+')
    LayoutHelpers.AtLeftIn(keyActionLine.assignKeyButton, keyActionLine)
    LayoutHelpers.AtVerticalCenterIn(keyActionLine.assignKeyButton, keyActionLine)
    Tooltip.AddControlTooltip(keyActionLine.assignKeyButton,
        {
            text = "<LOC key_binding_0003>Assign Key",
            body = '<LOC key_binding_0012>Opens a dialog that allows assigning key binding for a given action'
        })
    keyActionLine.assignKeyButton.OnMouseClick = function(self)
        keyActionLine:AssignKeyBinding()
        return true
    end


    keyActionLine.Update = function(self, data, keyActionLineID)
        keyActionLine:SetSolidColor(GetLineColor(keyActionLineID, data))
        keyActionLine.data = table.copy(data)

        if data.type == 'header' then
            if keyGroups[self.data.category].collapsed then
                self.toggle.txt:SetText('+')
            else
                self.toggle.txt:SetText('-')
            end
            local stats = keyGroups[data.category].visible
            keyActionLine.toggle:Show()
            keyActionLine.assignKeyButton:Hide()
            keyActionLine.wikiButton:Hide()
            keyActionLine.description:SetText(data.text)
            keyActionLine.description:SetFont(UIUtil.titleFont, 16)
            keyActionLine.description:SetColor(UIUtil.factionTextColor)
            keyActionLine.statistics:SetText(stats)
            LayoutHelpers.AtVerticalCenterIn(keyActionLine.description, keyActionLine, 2)
        elseif data.type == 'spacer' then
            keyActionLine.toggle:Hide()
            keyActionLine.assignKeyButton:Hide()
            keyActionLine.wikiButton:Hide()
            keyActionLine.description:SetText('')
            keyActionLine.statistics:SetText('')
        elseif data.type == 'entry' then
            keyActionLine.toggle:Hide()
            keyActionLine.description:SetText(data.text)
            keyActionLine.description:SetFont('Arial', 14)
            keyActionLine.description:SetColor(UIUtil.fontColor)
            keyActionLine.statistics:SetText('')
            keyActionLine.assignKeyButton:Show()

            if (data.wikiURL) then
                keyActionLine.wikiButton.url = tostring(data.wikiURL)
                keyActionLine.wikiButton:Show()
            else
                keyActionLine.wikiButton.url = ""
                keyActionLine.wikiButton:Hide()
            end
        end
    end
    return keyActionLine
end

function CreateKeyBindingLine()
    local keyBindingLine = Bitmap(keyBindingsContainer)
    keyBindingLine.Left:Set(keyBindingsContainer.Left)
    keyBindingLine.Right:Set(keyBindingsContainer.Right)
    LayoutHelpers.SetHeight(keyBindingLine, 24)

    keyBindingLine.description = UIUtil.CreateText(keyBindingLine, '', 16, "Arial")
    keyBindingLine.description:DisableHitTest()
    keyBindingLine.description:SetClipToWidth(true)
    keyBindingLine.description.Width:Set(function() return keyBindingLine.Width() - 50 end)
    keyBindingLine.description:SetAlpha(0.9)

    keyBindingLine.Height:Set(24)
    keyBindingLine.Width:Set(function() return keyBindingLine.Right() - keyBindingLine.Left() end)

    LayoutHelpers.AtLeftIn(keyBindingLine.description, keyBindingLine, 40)
    LayoutHelpers.AtVerticalCenterIn(keyBindingLine.description, keyBindingLine)

    -- Remove keyBindingLine.key and adjust HandleEvent function accordingly

    keyBindingLine.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            keyBindingLine:SetAlpha(0.9)
            keyBindingLine.description:SetAlpha(1.0)
            PlaySound(Sound({ Cue = "UI_Menu_Rollover_Sml", Bank = "Interface" }))
        elseif event.Type == 'MouseExit' then
            keyBindingLine:SetAlpha(1.0)
            keyBindingLine.description:SetAlpha(0.9)
        elseif self.data.type == 'entry' then
            if event.Type == 'ButtonPress' then
                SelectLine(self.data.index)
                keyBindingsFilter.text:AcquireFocus()
                return true
            elseif event.Type == 'ButtonDClick' then
                SelectLine(self.data.index)
                AssignCurrentSelection()
                return true
            end
        elseif self.data.type == 'header' and (event.Type == 'ButtonPress' or event.Type == 'ButtonDClick') then
            if string.len(keyword) == 0 then
                ToggleKeyBindingLines(self.data.category)
                keyBindingsFilter.text:AcquireFocus()

                if keyGroups[self.data.category].collapsed then
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

    keyBindingLine.AssignKeyBinding = function(self)
        SelectLine(self.data.index)
        AssignCurrentSelection()
    end

    keyBindingLine.UnbindKeyBinding = function(self)
        if keyBindingTable[self.data.index].key then
            SelectLine(self.data.index)
            UnbindCurrentSelection()
        end
    end

    keyBindingLine.toggle = CreateToggle(keyBindingLine,
        'FF1B1A1A',
        UIUtil.factionTextColor,
        keyBindingLine.description.Height() + 4, 18, '+')
    LayoutHelpers.AtLeftIn(keyBindingLine.toggle, keyBindingLine)
    LayoutHelpers.AtVerticalCenterIn(keyBindingLine.toggle, keyBindingLine)
    Tooltip.AddControlTooltip(keyBindingLine.toggle,
        {
            text = '<LOC key_binding_0010>Toggle Category',
            body = '<LOC key_binding_0011>Toggle visibility of all actions for this category of keys'
        })

    keyBindingLine.assignActionButton = CreateToggle(keyBindingLine,
        '645F5E5E',
        'FFAEACAC',
        keyBindingLine.description.Height() + 4, 18, '+')
    LayoutHelpers.AtLeftIn(keyBindingLine.assignActionButton, keyBindingLine)
    LayoutHelpers.AtVerticalCenterIn(keyBindingLine.assignActionButton, keyBindingLine)
    Tooltip.AddControlTooltip(keyBindingLine.assignActionButton,
        {
            text = "<LOC key_binding_0003>Assign Key",
            body = '<LOC key_binding_0012>Opens a dialog that allows assigning key binding for a given action'
        })
    keyBindingLine.assignActionButton.OnMouseClick = function(self)
        keyBindingLine:AssignKeyBinding()
        return true
    end


    keyBindingLine.Update = function(self, data, keyBindingLineID)
        keyBindingLine:SetSolidColor(GetLineColor(keyBindingLineID, data))
        keyBindingLine.data = table.copy(data)

        if data.type == 'header' then
            if keyGroups[self.data.category].collapsed then
                self.toggle.txt:SetText('+')
            else
                self.toggle.txt:SetText('-')
            end
            local stats = keyGroups[data.category].visible
            keyBindingLine.toggle:Show()
            keyBindingLine.assignActionButton:Hide()
            keyBindingLine.description:SetText(data.text)
            keyBindingLine.description:SetFont(UIUtil.titleFont, 16)
            keyBindingLine.description:SetColor(UIUtil.factionTextColor)
            LayoutHelpers.AtVerticalCenterIn(keyBindingLine.description, keyBindingLine, 2)
        elseif data.type == 'spacer' then
            keyBindingLine.toggle:Hide()
            keyBindingLine.assignActionButton:Hide()
            keyBindingLine.description:SetText('')
        elseif data.type == 'entry' then
            keyBindingLine.toggle:Hide()
            keyBindingLine.description:SetText(data.text)
            keyBindingLine.description:SetFont('Arial', 14)
            keyBindingLine.description:SetColor(UIUtil.fontColor)
            keyBindingLine.assignActionButton:Show()
        end
    end
    return keyBindingLine
end

function CloseUI()
    LOG('Keybindings CloseUI')
    if popup then
        popup:Close()
        popup = false
    end
end

function CreateUI()
    LOG('Keybindings CreateUI')
    if WorldIsLoading() or (import("/lua/ui/game/gamemain.lua").supressExitDialog == true) then
        return
    end

    if popup then
        CloseUI()
        return
    end
    keyword = ''
    keyActionTable = FormatKeyActionData()

    local screenWidth, screenHeight = GetFrame(0).Width(), GetFrame(0).Height()
    local dialogWidth, dialogHeight = screenWidth - 100, screenHeight - 100

    local dialogContent = Group(GetFrame(0))
    LayoutHelpers.SetDimensions(dialogContent, dialogWidth, dialogHeight)
    LayoutHelpers.AtLeftTopIn(dialogContent, GetFrame(0), 50, 50)

    popup = Popup(GetFrame(0), dialogContent)
    popup.OnShadowClicked = CloseUI
    popup.OnEscapePressed = CloseUI
    popup.OnDestroy = function(self)
        RemoveInputCapture(dialogContent)
    end

    local title = UIUtil.CreateText(dialogContent, LOC("<LOC key_binding_0000>Key Bindings"), 22)
    LayoutHelpers.AtTopIn(title, dialogContent, 12)
    LayoutHelpers.AtHorizontalCenterIn(title, dialogContent)

    local offset = dialogContent.Width() / 5.25

    popup.OnClosed = function(self)
        ConfirmNewKeyMap()
    end

    dialogContent.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            if event.KeyCode == UIUtil.VK_ESCAPE or event.KeyCode == UIUtil.VK_ENTER or event.KeyCode == 342 then
                CloseUI()
            end
        end
    end

    keyActionsSection = Group(dialogContent)

    LayoutHelpers.SetWidth(keyActionsSection, 500)
    LayoutHelpers.AtLeftIn(keyActionsSection, dialogContent, 20)
    LayoutHelpers.AtTopIn(keyActionsSection, dialogContent, 30)
    LayoutHelpers.AtBottomIn(keyActionsSection, dialogContent)

    keyActionsFilter = Bitmap(keyActionsSection)

    keyActionsFilter:SetSolidColor('FF282828')
    LayoutHelpers.AtLeftIn(keyActionsFilter, keyActionsSection, 25)
    LayoutHelpers.AtTopIn(keyActionsFilter, keyActionsSection, 30)
    keyActionsFilter.Width:Set(keyActionsSection.Width() - 25)
    keyActionsFilter.Height:Set(30)

    keyActionsFilter:EnableHitTest()
    import("/lua/ui/game/tooltip.lua").AddControlTooltip(keyActionsFilter,
        {
            text = '<LOC key_binding_0018>Key Binding Filter',
            body = '<LOC key_binding_0019>' ..
                'Filter all actions by typing action :' ..
                '\n\n Note that collapsing of key categories is disabled while this filter contains some text'
        }, nil)

    local text = 'Filter actions'
    keyActionsFilter.info = UIUtil.CreateText(keyActionsFilter, text, 16, UIUtil.titleFont)
    keyActionsFilter.info:SetColor('FF727171')
    keyActionsFilter.info:DisableHitTest()
    LayoutHelpers.AtLeftIn(keyActionsFilter.info, keyActionsFilter, 10)
    LayoutHelpers.AtVerticalCenterIn(keyActionsFilter.info, keyActionsFilter, 2)

    keyActionsFilter.text = Edit(keyActionsFilter)
    keyActionsFilter.text:SetForegroundColor('FFF1ECEC')
    keyActionsFilter.text:SetBackgroundColor('04E1B44A')
    keyActionsFilter.text:SetHighlightForegroundColor(UIUtil.highlightColor)
    keyActionsFilter.text:SetHighlightBackgroundColor("880085EF")
    keyActionsFilter.text.Height:Set(function() return keyActionsFilter.Bottom() - keyActionsFilter.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    LayoutHelpers.AtLeftIn(keyActionsFilter.text, keyActionsFilter, 5)
    LayoutHelpers.AtRightIn(keyActionsFilter.text, keyActionsFilter)
    LayoutHelpers.AtVerticalCenterIn(keyActionsFilter.text, keyActionsFilter)
    keyActionsFilter.text:AcquireFocus()
    keyActionsFilter.text:SetText('')
    keyActionsFilter.text:SetFont(UIUtil.titleFont, 16)
    keyActionsFilter.text:SetMaxChars(20)
    keyActionsFilter.text.OnTextChanged = function(self, newText, oldText)
        -- interpret plus chars as spaces for easier key filtering
        keyword = string.gsub(string.lower(newText), '+', ' ')
        keyword = string.gsub(string.lower(keyword), '  ', ' ')
        keyword = string.gsub(string.lower(keyword), '  ', ' ')
        if string.len(keyword) == 0 then
            for k, v in keyGroups do
                v.collapsed = true
            end
            for k, v in keyActionTable do
                v.collapsed = true
            end
        end
        keyActionsContainer:Filter(keyword)
        keyActionsContainer:ScrollSetTop(nil, 0)
    end

    keyActionsFilter.clear = UIUtil.CreateText(keyActionsFilter.text, 'X', 17, "Arial Bold")
    keyActionsFilter.clear:SetColor('FF8A8A8A')
    keyActionsFilter.clear:EnableHitTest()
    LayoutHelpers.AtVerticalCenterIn(keyActionsFilter.clear, keyActionsFilter.text, 1)
    LayoutHelpers.AtRightIn(keyActionsFilter.clear, keyActionsFilter.text, 9)

    keyActionsFilter.clear.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            keyActionsFilter.clear:SetColor('FFC9C7C7')
        elseif event.Type == 'MouseExit' then
            keyActionsFilter.clear:SetColor('FF8A8A8A')
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            keyActionsFilter.text:SetText('')
            keyActionsFilter.text:AcquireFocus()
        end
        return true
    end
    Tooltip.AddControlTooltip(keyActionsFilter.clear,
        {
            text = '<LOC key_binding_0016>Clear Filter',
            body = '<LOC key_binding_0017>Clears text that was typed in the filter field.'
        })

    keyActionsContainer = Group(keyActionsSection)
    LayoutHelpers.AtLeftIn(keyActionsContainer, keyActionsSection)
    LayoutHelpers.SetWidth(keyActionsContainer, keyActionsSectionWidth)
    LayoutHelpers.AnchorToBottom(keyActionsContainer, keyActionsFilter, 10)
    LayoutHelpers.AtBottomIn(keyActionsContainer, keyActionsSection, 10)

    keyActionsContainer.Height:Set(function() return keyActionsContainer.Bottom() - keyActionsContainer.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    keyActionsContainer.top = 0
    UIUtil.CreateLobbyVertScrollbar(keyActionsContainer)

    local index = 1
    keyActionEntries = {}
    keyActionEntries[index] = CreateKeyActionLine()
    LayoutHelpers.AtTopIn(keyActionEntries[1], keyActionsContainer)

    index = index + 1
    while keyActionEntries[table.getsize(keyActionEntries)].Top() + (2 * keyActionEntries[1].Height()) <
        keyActionsContainer.Bottom() do
        keyActionEntries[index] = CreateKeyActionLine()
        LayoutHelpers.Below(keyActionEntries[index], keyActionEntries[index - 1])
        index = index + 1
    end

    -- local height = keyActionsContainer.Height()
    -- local items = math.floor(keyActionsContainer.Height() / keyActionEntries[1].Height())

    local GetKeyActionLinesTotal = function()
        return table.getsize(keyActionEntries)
    end

    local function GetKeyActionLinesVisible()
        return table.getsize(keyActionLinesVisible)
    end

    -- Called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- axis can be "Vert" or "Horz"
    keyActionsContainer.GetScrollValues = function(self, axis)
        local size = GetKeyActionLinesVisible()
        local visibleMax = math.min(self.top + GetKeyActionLinesTotal(), size)
        return 0, size, self.top, visibleMax
    end

    -- Called when the scrollbar wants to scroll a specific number of keyActionLines (negative indicates scroll up)
    keyActionsContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- Called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    keyActionsContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * GetKeyActionLinesTotal())
    end

    -- Called when the scrollbar wants to set a new visible top keyActionLine
    keyActionsContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = GetKeyActionLinesVisible()
        self.top = math.max(math.min(size - GetKeyActionLinesTotal(), top), 0)
        self:CalcVisible()
    end

    -- Called to determine if the control is scrollable on a particular access. Must return true or false.
    keyActionsContainer.IsScrollable = function(self, axis)
        return true
    end

    -- Determines what control keyActionLines should be visible or not
    keyActionsContainer.CalcVisible = function(self)
        for i, keyActionLine in keyActionEntries do
            local id = i + self.top
            local index = keyActionLinesVisible[id]
            local data = keyActionTable[index]

            if data then
                keyActionLine:Update(data, id)
            else
                keyActionLine:SetSolidColor('00000000')
                keyActionLine.description:SetText('')
                keyActionLine.statistics:SetText('')
                keyActionLine.toggle:Hide()
                keyActionLine.assignKeyButton:Hide()
                keyActionLine.wikiButton:Hide()
            end
        end
        keyActionsFilter.text:AcquireFocus()
    end

    keyActionsContainer.HandleEvent = function(control, event)
        if event.Type == 'WheelRotation' then
            local keyActionLines = 1
            if event.WheelRotation > 0 then
                keyActionLines = -1
            end
            control:ScrollLines(nil, keyActionLines)
        end
    end
    -- filter all key-bindings by checking if either text, action, or a key contains target string
    keyActionsContainer.Filter = function(self, target)
        local headersVisible = {}
        keyActionLinesVisible = {}

        if not target or string.len(target) == 0 then
            keyActionsFilter.info:Show()
            for k, v in keyActionTable do
                if v.type == 'header' then
                    table.insert(keyActionLinesVisible, k)
                    keyGroups[v.category].visible = v.count
                    keyGroups[v.category].bindings = 0
                elseif v.type == 'entry' then
                    if not v.collapsed then
                        table.insert(keyActionLinesVisible, k)
                    end
                    if v.key then
                        keyGroups[v.category].bindings = keyGroups[v.category].bindings + 1
                    end
                end
            end
        else
            keyActionsFilter.info:Hide()
            for k, v in keyActionTable do
                local match = false
                if v.type == 'header' then
                    keyGroups[v.category].visible = 0
                    keyGroups[v.category].bindings = 0
                    if not headersVisible[k] then
                        headersVisible[k] = true
                        table.insert(keyActionLinesVisible, k)
                        keyGroups[v.category].collapsed = true
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
                            table.insert(keyActionLinesVisible, v.header)
                        end
                        keyGroups[v.category].collapsed = false
                        keyGroups[v.category].visible = keyGroups[v.category].visible + 1
                        table.insert(keyActionLinesVisible, k)
                        if v.key then
                            keyGroups[v.category].bindings = keyGroups[v.category].bindings + 1
                        end
                    end
                end
            end
        end
        self:CalcVisible()
    end

    -----------------------------------------------------------------

    keyBindingsSection = Group(dialogContent)

    LayoutHelpers.SetWidth(keyBindingsSection, dialogContent.Width() - (keyActionsSection.Width() + 100))
    LayoutHelpers.AtLeftIn(keyBindingsSection, dialogContent, keyActionsSection.Width() + 50)
    LayoutHelpers.AtTopIn(keyBindingsSection, dialogContent, 30)
    LayoutHelpers.AtBottomIn(keyBindingsSection, dialogContent)

    keyBindingsFilter = Bitmap(keyBindingsSection)

    keyBindingsFilter:SetSolidColor('FF282828')
    LayoutHelpers.AtLeftIn(keyBindingsFilter, keyBindingsSection, 25)
    LayoutHelpers.AtTopIn(keyBindingsFilter, keyBindingsSection, 30)
    keyBindingsFilter.Width:Set(keyBindingsSection.Width() - 50)
    keyBindingsFilter.Height:Set(30)

    keyBindingsFilter:EnableHitTest()
    import("/lua/ui/game/tooltip.lua").AddControlTooltip(keyBindingsFilter,
        {
            text = '<LOC key_binding_0018>Key Binding Filter',
            body = '<LOC key_binding_0019>' ..
                'Filter all actions by typing action :' ..
                '\n\n Note that collapsing of key categories is disabled while this filter contains some text'
        }, nil)

    local text = 'Filter key bindings'
    keyBindingsFilter.info = UIUtil.CreateText(keyBindingsFilter, text, 16, UIUtil.titleFont)
    keyBindingsFilter.info:SetColor('FF727171')
    keyBindingsFilter.info:DisableHitTest()
    LayoutHelpers.AtLeftIn(keyBindingsFilter.info, keyBindingsFilter, 10)
    LayoutHelpers.AtVerticalCenterIn(keyBindingsFilter.info, keyBindingsFilter, 2)

    keyBindingsFilter.text = Edit(keyBindingsFilter)
    keyBindingsFilter.text:SetForegroundColor('FFF1ECEC')
    keyBindingsFilter.text:SetBackgroundColor('04E1B44A')
    keyBindingsFilter.text:SetHighlightForegroundColor(UIUtil.highlightColor)
    keyBindingsFilter.text:SetHighlightBackgroundColor("880085EF")
    keyBindingsFilter.text.Height:Set(function() return keyBindingsFilter.Bottom() - keyBindingsFilter.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    LayoutHelpers.AtLeftIn(keyBindingsFilter.text, keyBindingsFilter, 5)
    LayoutHelpers.AtRightIn(keyBindingsFilter.text, keyBindingsFilter)
    LayoutHelpers.AtVerticalCenterIn(keyBindingsFilter.text, keyBindingsFilter)
    keyBindingsFilter.text:AcquireFocus()
    keyBindingsFilter.text:SetText('')
    keyBindingsFilter.text:SetFont(UIUtil.titleFont, 16)
    keyBindingsFilter.text:SetMaxChars(20)
    keyBindingsFilter.text.OnTextChanged = function(self, newText, oldText)
        -- interpret plus chars as spaces for easier key filtering
        keyword = string.gsub(string.lower(newText), '+', ' ')
        keyword = string.gsub(string.lower(keyword), '  ', ' ')
        keyword = string.gsub(string.lower(keyword), '  ', ' ')
        if string.len(keyword) == 0 then
            for k, v in keyGroups do
                v.collapsed = true
            end
            for k, v in keyBindingTable do
                v.collapsed = true
            end
        end
        keyBindingsContainer:Filter(keyword)
        keyBindingsContainer:ScrollSetTop(nil, 0)
    end

    keyBindingsFilter.clear = UIUtil.CreateText(keyBindingsFilter.text, 'X', 17, "Arial Bold")
    keyBindingsFilter.clear:SetColor('FF8A8A8A')
    keyBindingsFilter.clear:EnableHitTest()
    LayoutHelpers.AtVerticalCenterIn(keyBindingsFilter.clear, keyBindingsFilter.text, 1)
    LayoutHelpers.AtRightIn(keyBindingsFilter.clear, keyBindingsFilter.text, 9)

    keyBindingsFilter.clear.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            keyBindingsFilter.clear:SetColor('FFC9C7C7')
        elseif event.Type == 'MouseExit' then
            keyBindingsFilter.clear:SetColor('FF8A8A8A')
        elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            keyBindingsFilter.text:SetText('')
            keyBindingsFilter.text:AcquireFocus()
        end
        return true
    end
    Tooltip.AddControlTooltip(keyBindingsFilter.clear,
        {
            text = '<LOC key_binding_0016>Clear Filter',
            body = '<LOC key_binding_0017>Clears text that was typed in the filter field.'
        })

    keyBindingsContainer = Group(keyBindingsSection)
    LayoutHelpers.AtLeftIn(keyBindingsContainer, keyBindingsSection)
    LayoutHelpers.SetWidth(keyBindingsContainer, keyBindingsSection.Width())
    LayoutHelpers.AnchorToBottom(keyBindingsContainer, keyBindingsFilter, 10)
    LayoutHelpers.AtBottomIn(keyBindingsContainer, keyBindingsSection, 10)

    keyBindingsContainer.Height:Set(function() return keyBindingsContainer.Bottom() - keyBindingsContainer.Top() -
            LayoutHelpers.ScaleNumber(10)
    end)
    keyBindingsContainer.top = 0
    UIUtil.CreateLobbyVertScrollbar(keyBindingsContainer)

    local index = 1
    keyBindingsEntries = {}
    keyBindingsEntries[index] = CreateKeyBindingLine()
    LayoutHelpers.AtTopIn(keyBindingsEntries[1], keyBindingsContainer)

    index = index + 1
    while keyBindingsEntries[table.getsize(keyBindingsEntries)].Top() + (2 * keyBindingsEntries[1].Height()) <
        keyBindingsContainer.Bottom() do
        keyBindingsEntries[index] = CreateKeyBindingLine()
        LayoutHelpers.Below(keyBindingsEntries[index], keyBindingsEntries[index - 1])
        index = index + 1
    end

    -- local height = keyBindingsContainer.Height()
    -- local items = math.floor(keyBindingsContainer.Height() / keyBindingEntries[1].Height())

    local GetKeyActionLinesTotal = function()
        return table.getsize(keyBindingsEntries)
    end

    local function GetKeyActionLinesVisible()
        return table.getsize(keyBindingsLinesVisible)
    end

    -- Called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- axis can be "Vert" or "Horz"
    keyBindingsContainer.GetScrollValues = function(self, axis)
        local size = GetKeyActionLinesVisible()
        local visibleMax = math.min(self.top + GetKeyActionLinesTotal(), size)
        return 0, size, self.top, visibleMax
    end

    -- Called when the scrollbar wants to scroll a specific number of keyBindingLines (negative indicates scroll up)
    keyBindingsContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- Called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    keyBindingsContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * GetKeyActionLinesTotal())
    end

    -- Called when the scrollbar wants to set a new visible top keyBindingLine
    keyBindingsContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = GetKeyActionLinesVisible()
        self.top = math.max(math.min(size - GetKeyActionLinesTotal(), top), 0)
        self:CalcVisible()
    end

    -- Called to determine if the control is scrollable on a particular access. Must return true or false.
    keyBindingsContainer.IsScrollable = function(self, axis)
        return true
    end

    -- Determines what control keyBindingLines should be visible or not
    keyBindingsContainer.CalcVisible = function(self)
        for i, keyBindingLine in keyBindingsEntries do
            local id = i + self.top
            local index = keyBindingsLinesVisible[id]
            local data = keyBindingTable[index]

            if data then
                keyBindingLine:Update(data, id)
            else
                keyBindingLine:SetSolidColor('00000000')
                keyBindingLine.description:SetText('')
                keyBindingLine.statistics:SetText('')
                keyBindingLine.toggle:Hide()
                keyBindingLine.assignKeyButton:Hide()
                keyBindingLine.wikiButton:Hide()
            end
        end
        keyBindingsFilter.text:AcquireFocus()
    end

    keyBindingsContainer.HandleEvent = function(control, event)
        if event.Type == 'WheelRotation' then
            local keyBindingLines = 1
            if event.WheelRotation > 0 then
                keyBindingLines = -1
            end
            control:ScrollLines(nil, keyBindingLines)
        end
    end
    -- filter all key-bindings by checking if either text, action, or a key contains target string
    keyBindingsContainer.Filter = function(self, target)
        local headersVisible = {}
        keyBindingsLinesVisible = {}

        if not target or string.len(target) == 0 then
            keyBindingsFilter.info:Show()
            for k, v in keyBindingTable do
                if v.type == 'header' then
                    table.insert(keyBindingsLinesVisible, k)
                    keyGroups[v.category].visible = v.count
                    keyGroups[v.category].bindings = 0
                elseif v.type == 'entry' then
                    if not v.collapsed then
                        table.insert(keyBindingsLinesVisible, k)
                    end
                    if v.key then
                        keyGroups[v.category].bindings = keyGroups[v.category].bindings + 1
                    end
                end
            end
        else
            keyBindingsFilter.info:Hide()
            for k, v in keyBindingTable do
                local match = false
                if v.type == 'header' then
                    keyGroups[v.category].visible = 0
                    keyGroups[v.category].bindings = 0
                    if not headersVisible[k] then
                        headersVisible[k] = true
                        table.insert(keyBindingsLinesVisible, k)
                        keyGroups[v.category].collapsed = true
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
                            table.insert(keyBindingsLinesVisible, v.header)
                        end
                        keyGroups[v.category].collapsed = false
                        keyGroups[v.category].visible = keyGroups[v.category].visible + 1
                        table.insert(keyBindingsLinesVisible, k)
                        if v.key then
                            keyGroups[v.category].bindings = keyGroups[v.category].bindings + 1
                        end
                    end
                end
            end
        end
        self:CalcVisible()
    end

    -----------------------------------------------------------------

    keyActionsFilter.text:SetText('')
end

function SortKeyActionData(dataTable)
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

-- format all key data, group them based on key category or default to none category and finally sort all keys
function FormatKeyActionData()
    local keyData = {}
    local keyLookup = KeyMapper.GetKeyLookup()
    local keyActions = KeyMapper.GetKeyActions()

    -- reset previously formated key actions in all groups because they might have been re-mapped
    for category, group in keyGroups do
        group.actions = {}
    end
    -- group game keys and key defined in mods by their key category
    for k, v in keyActions do
        local category = string.lower(v.category or 'none')
        local keyForAction = keyLookup[k]

        -- create header if it doesn't exist
        if not keyGroups[category] then
            keyGroups[category] = {}
            keyGroups[category].actions = {}
            keyGroups[category].name = category
            keyGroups[category].collapsed = keyActionLinesCollapsed
            keyGroups[category].order = table.getsize(keyGroups) - 1
            keyGroups[category].text = v.category or keyCategories['none'].text
        end

        local data = {
            action = k,
            key = keyForAction,
            keyText = FormatKeyName(keyForAction),
            category = category,
            order = keyGroups[category].order,
            text = KeyMapper.GetActionName(k),
            wikiURL = v.wikiURL
        }
        table.insert(keyGroups[category].actions, data)
    end
    -- flatten all key actions to a list separated by a header with info about key category
    local index = 1
    for category, group in keyGroups do
        if not table.empty(group.actions) then
            keyData[index] = {
                type = 'header',
                id = index,
                order = keyGroups[category].order,
                count = table.getsize(group.actions),
                category = category,
                text = keyGroups[category].text,
                collapsed = keyGroups[category].collapsed
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
                    order = keyGroups[category].order,
                    collapsed = keyGroups[category].collapsed,
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

    SortKeyActionData(keyData)

    -- store index of a header keyActionLine for each key keyActionLine
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
