-- This function checks whether a unit (ACU oder SACU) has a tactical (nuke) missile upgrade installed
function checkMissileEnhancements(unit)
	local enhancements = EnhanceCommon.GetEnhancements(unit:GetEntityId())
	if enhancements.Back == "Missile" or enhancements.Back == "TacticalMissile" or enhancements.Back == "TacticalNukeMissile" then
		return true
	end
end