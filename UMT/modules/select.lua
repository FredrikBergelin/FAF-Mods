---@deprecated
-- Hidden = UMT.Units.HiddenSelect

-- I found that when using UISelectionByCategory, hidden doesn't seem to register.
-- So this one can be set manually to account for those situations.
local isHiddenSelect = false

function SetHiddenSelect(state)
    isHiddenSelect = state
end

function GetHiddenSelect()
    return isHiddenSelect
end
