local MainSelection = import("/lua/ui/game/selection.lua")

function AppendToGroup(numOfGroup)
  local setID = tostring(numOfGroup)
  local selectedUnits = GetSelectedUnits()
  if MainSelection.selectionSets[setID] then
    for index, unit in selectedUnits do
      unit:AddSelectionSet(setID)
      MainSelection.AddUnitToSelectionSet(setID, unit)
    end
  else
    MainSelection.AddSelectionSet(setID, selectedUnits)
  end
end

function DeleteFromGroup()
  local selectedUnits = GetSelectedUnits()
  if selectedUnits then
    for index, unit in selectedUnits do
      for group_index, group in unit:GetSelectionSets() do
        local unitsIndexes = {}
        for index2, unit2 in MainSelection.selectionSets[group] do
          if unit:GetEntityId() == unit2:GetEntityId() then
            table.insert(unitsIndexes, index2)
          end
        end
        for false_index, unit_index in unitsIndexes do
          table.remove(MainSelection.selectionSets[group], unit_index)
        end
        unit:RemoveSelectionSet(group)
      end
    end
  end
end
