function LayoutAvatars()
	local controls = import('/lua/ui/game/avatars.lua').controls

	local rightOffset, topOffset, space = 14, 14, -5
	
	local prevControl = false
	local height = 0
	for _, control in controls.avatars do
		if prevControl then
			control.Top:Set(function() return prevControl.Bottom() + space end)
			LayoutHelpers.AtRightIn(control, prevControl)
			height = height + (control.Bottom() - prevControl.Bottom())
		else
			LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset, topOffset)
			height = control.Height()
		end
		prevControl = control
	end
	if controls.idleEngineers then
		if prevControl then
			controls.idleEngineers.prevControl = prevControl
			controls.idleEngineers.Top:Set(function() return controls.idleEngineers.prevControl.Bottom() + space end)
			LayoutHelpers.AtRightIn(controls.idleEngineers, controls.idleEngineers.prevControl)
			height = height + (controls.idleEngineers.Bottom() - controls.idleEngineers.prevControl.Bottom())
		else
			LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset, topOffset)
			height = controls.idleEngineers.Height()
		end
		prevControl = controls.idleEngineers
	end
	if controls.idleNukes then
		if prevControl then
			controls.idleNukes.prevControl = prevControl
			controls.idleNukes.Top:Set(function() return controls.idleNukes.prevControl.Bottom() + space end)
			LayoutHelpers.AtRightIn(controls.idleNukes, controls.idleNukes.prevControl)
			height = height + (controls.idleNukes.Bottom() - controls.idleNukes.prevControl.Bottom())
		else
			LayoutHelpers.AtRightTopIn(controls.idleNukes, controls.avatarGroup, rightOffset, topOffset)
			height = controls.idleNukes.Height()
		end
		prevControl = controls.idleNukes
	end
	if controls.idleFactories then
		if prevControl then
			controls.idleFactories.prevControl = prevControl
			controls.idleFactories.Top:Set(function() return controls.idleFactories.prevControl.Bottom() + space end)
			LayoutHelpers.AtRightIn(controls.idleFactories, controls.idleFactories.prevControl)
			height = height + (controls.idleFactories.Bottom() - controls.idleFactories.prevControl.Bottom())
		else
			LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset, topOffset)
			height = controls.idleFactories.Height()
		end
	end

	controls.avatarGroup.Height:Set(function() return height - 5 end)
end