-- tLOG = import('/mods/common/modules/tools.lua').tLOG
-- TODO: WARNING: Error running lua command: ...mander forged alliance\mods\common\modules\tools.lua(13): attempt to concatenate local `k' (a table value)
function tLOG(tbl, indent)
	if not indent then indent = 0 end
	formatting = string.rep("  ", indent)
	if type(tbl) == "nil" then
		LOG(formatting .. "nil")
		return
	end
	if type(tbl) == "string" then
		LOG(formatting .. tbl)
		return
	end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "nil" then
			LOG(formatting .. "NIL")
		elseif type(v) == "table" then
			LOG(formatting)
			tLOG(v, indent + 1)
		elseif type(v) == 'boolean' then
			LOG(formatting .. tostring(v))
		else
			LOG(formatting)
			LOG(v)
		end
	end
end
