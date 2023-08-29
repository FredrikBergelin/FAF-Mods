## config 

-- starts enabled or not?
local isEnabled = true

-- if this is true, then locked units are still selected if there is only one in the selection. 
local allowSelectionIfJustOne = true

-- limit the units the reduction happens to by blueprint id. If no blueprint ids are provided then ALL units are 
local blueprintIdArray = {  
	 "ual0101", "url0101", "xsl0101", "uel0101"
}

## end config
























local logEnabled = false
function Log(msg)
	if logEnabled then
		LOG(msg)
	end
end


Log("Selection Lock Initializing..")
local blueprintIds = { }
for k,v in blueprintIdArray do 
	blueprintIds[v] = 0 
end
local isNotLimitedByBlueprint = table.getn(blueprintIdArray) == 0

function ToggleEnabled()
	isEnabled = not isEnabled

	if isEnabled then
		print("Selection Lock - ENABLED")
	else
		print("Selection Lock - DISABLED")
	end
end



local dblClickStart = false
local dblClickId = false
local dblClickUnit = nil
local dblClickEnd = false

function isDoubleclick(newSelection)
	-- a double click is if 
	--   the first click is just one unit
	--   and the second click contains the same unit
	if dblClickStart then 
		dblClickEnd = newSelection[dblClickId] ~= nil
		Log("end?: " .. tostring(dblClickEnd))
		if dblClickEnd then 
			Log("***** double click")
			return true
		end
	end

	dblClickStart = table.getn(newSelection) == 1
	if dblClickStart then
		for entityid, unit in ipairs(newSelection) do
			dblClickId = entityid
			dblClickUnit = newSelection[dblClickId]
		end
	end
	Log("start?: " .. tostring(dblClickStart))

	--local diffTime = curTime - lastSelectionTime
	--if newSelection == lastSelection then
	--	if diffTime < 1.0 then
		--Log(curTime .. " -- " .. lastSelectionTime)
		--	Log("double tap detected")
		--end
	--end

	return false
end


local suppress = false
function OnSelectionChanged(oldSelection, newSelection, added, removed)

	if not isEnabled then 
		return false
	end

	if IsKeyDown('Shift') then
		return false
	end

	-- prevent inifite recursion
	if suppress then 
		Log("--OnSelectionChanged supressed")
		return false
	end

	Log("--OnSelectionChanged")


	local tobeSelected = {}
	local changesMade = false

	-- if its a double click on an assister, select all fellow assisters
	if isDoubleclick(newSelection) then
		Log("-- double click detected")

		local dblClickGuardedUnit = dblClickUnit:GetGuardedEntity() 
		local isAssisting = dblClickGuardedUnit and not dblClickGuardedUnit:IsDead()

		if isAssisting then 
			for entityid, unit in ipairs(newSelection) do
		
				local guardedUnit = unit:GetGuardedEntity() 
				
				if guardedUnit == dblClickGuardedUnit then
					Log("found a brother")
					table.insert(tobeSelected,unit)
					changesMade = true
				else
					Log("didnt find brother")
				end
			end
		end 
	end

	-- if double click didnt happen then select everything except assisters
	if not changesMade then

		if newSelection then
	
			local newSelectionCount = table.getn(newSelection)
			local reduceSelection = true
			if allowSelectionIfJustOne then 
				reduceSelection = newSelectionCount > 1
			end 
	
			if reduceSelection then
		
				for entityid, unit in ipairs(newSelection) do
		
					local guardedUnit = unit:GetGuardedEntity() 
					local isAssisting = guardedUnit and not guardedUnit:IsDead()
					local blueprintId = unit:GetBlueprint().BlueprintId
					local isApplicableBlueprint = isNotLimitedByBlueprint or blueprintIds[blueprintId] != nil
					local thisSkipped = isAssisting and isApplicableBlueprint
	
					if unit:IsInCategory("ENGINEER") then
						thisSkipped = false
					end
					
					if thisSkipped then
						changesMade = true
					else
						table.insert(tobeSelected,unit)
					end
	
				end
			end	
		end
	end

	if changesMade then 
		ForkThread(function() 
			suppress = true
			Log("--changing")
			SelectUnits(tobeSelected)
			suppress = false
		end)	
	end

	return changesMade

end
