local originalCreateUI = CreateUI 
local originalOnSelectionChanged = OnSelectionChanged
local UpdateAllUnits = import('/mods/FilterSelection/modules/allunits.lua').UpdateAllUnits
local KeyMapper = import('/lua/keymap/keymapper.lua')
KeyMapper.SetUserKeyAction('add filter 1', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').AddFilterSelection(1)", category = 'FilterSelection', order = 421,})
KeyMapper.SetUserKeyAction('add filter 2', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').AddFilterSelection(2)", category = 'FilterSelection', order = 422,})
KeyMapper.SetUserKeyAction('add filter 3', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').AddFilterSelection(3)", category = 'FilterSelection', order = 423,})
KeyMapper.SetUserKeyAction('add filter 4', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').AddFilterSelection(4)", category = 'FilterSelection', order = 424,})
KeyMapper.SetUserKeyAction('add filter 5', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').AddFilterSelection(5)", category = 'FilterSelection', order = 425,})

KeyMapper.SetUserKeyAction('select filter 1', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').FilterSelect(1)", category = 'FilterSelection', order = 426,})
KeyMapper.SetUserKeyAction('select filter 2', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').FilterSelect(2)", category = 'FilterSelection', order = 427,})
KeyMapper.SetUserKeyAction('select filter 3', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').FilterSelect(3)", category = 'FilterSelection', order = 428,})
KeyMapper.SetUserKeyAction('select filter 4', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').FilterSelect(4)", category = 'FilterSelection', order = 429,})
KeyMapper.SetUserKeyAction('select filter 5', {action = "UI_Lua import('/mods/FilterSelection/modules/FilterSelection.lua').FilterSelect(5)", category = 'FilterSelection', order = 430,})


function OnSelectionChanged(oldSelection, newSelection, added, removed)
   if not import('/mods/FilterSelection/modules/allunits.lua').IsAutoSelection() then
      originalOnSelectionChanged(oldSelection, newSelection, added, removed)
   end
end

function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  AddBeatFunction(UpdateAllUnits)

end
