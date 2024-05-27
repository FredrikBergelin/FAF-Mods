local originalOnClickHandler = OnClickHandler

function OnClickHandler(button, modifiers)
        
	local item = button.Data
	local count = 1
	-- remove all units/upgrades from buildqueue without the first element
        if modifiers.Alt and item.type == 'item' then
            -- iterate over all units/upgrades in this queue
            for index, unitStack in currentCommandQueue do
        		count = unitStack.count
        		if (index == 1) then
          			count = count - 1
        		end
        		DecreaseBuildCountInQueue(index, count)
      		end
      	end

	-- call original function
	originalOnClickHandler(button, modifiers)
end