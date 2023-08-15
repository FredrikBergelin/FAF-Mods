for i,v in ipairs(Factions) do
	if i == 1 then
		v.IdleNukeTextures = {
			TacticalT2 = '/icons/units/UEB2108_icon.dds',
			TacticalT3 = '/icons/units/BAB2308_icon.dds',
			NukeT3 = '/icons/units/UEB2305_icon.dds',
			NukeT4 = '/icons/units/XSB2401_icon.dds',
		} --UEF
	elseif i == 2 then
		v.IdleNukeTextures = {
			TacticalT2 = '/icons/units/UAB2108_icon.dds',
			TacticalT3 = '/icons/units/BAB2308_icon.dds',
			NukeT3 = '/icons/units/UAB2305_icon.dds',
			NukeT4 = '/icons/units/XSB2401_icon.dds',
		} --Aeon
	elseif i == 3 then
		v.IdleNukeTextures = {
			TacticalT2 = '/icons/units/URB2108_icon.dds',
			TacticalT3 = '/icons/units/BAB2308_icon.dds',
			NukeT3 = '/icons/units/URB2305_icon.dds',
			NukeT4 = '/icons/units/XSB2401_icon.dds',
		} --Cybran
	elseif i == 4 then
		v.IdleNukeTextures = {
			TacticalT2 = '/icons/units/XSB2108_icon.dds',
			TacticalT3 = '/icons/units/BAB2308_icon.dds',
			NukeT3 = '/icons/units/XSB2305_icon.dds',
			NukeT4 = '/icons/units/XSB2401_icon.dds',
		} --Seraphim
	end
end