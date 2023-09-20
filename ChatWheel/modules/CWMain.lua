local Dragger = import('/lua/maui/dragger.lua').Dragger
local Prefs = import('/lua/user/prefs.lua')
local Window = import('/lua/maui/window.lua').Window
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local Text = import('/lua/maui/text.lua').Text
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Group = import('/lua/maui/group.lua').Group
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local CWheel = import("/mods/ChatWheel/modules/CWheel.lua").CWheel

DEBUG = false
local chatWheel = nil
local isReplay = import('/lua/ui/game/gamemain.lua').GetReplayState()
function call()
    if isReplay then return end
    if DEBUG then
        if chatWheel then
            chatWheel:Destroy()
            LOG('new chat wheel')
        end
        chatWheel = CWheel(GetFrame(0))
    elseif chatWheel then
        if IsDestroyed(chatWheel) then
            chatWheel = CWheel(GetFrame(0))
        else 
            chatWheel:Destroy()
        end
    else
        chatWheel = CWheel(GetFrame(0))
    end

end


