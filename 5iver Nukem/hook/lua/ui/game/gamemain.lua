-- THANK THAPEAR!
-- get the original OnSelectionChanged function
local oldOnSelectionChanged = OnSelectionChanged

function OnSelectionChanged(oldSelection, newSelection, added, removed)
   -- if it's not an auto selection
	if not import('/lua/ui/game/avatars.lua').isAutoSelection then
      -- do the old OnSelectionChanged
      oldOnSelectionChanged(oldSelection, newSelection, added, removed)
   end
end