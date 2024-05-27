--local oldOnSync = OnSync

--FixedEcoData = { }

--function OnSync()

----	if Sync.FixedEcoData and not table.empty(Sync.FixedEcoData) then
----		FixedEcoData = table.merged(FixedEcoData, Sync.FixedEcoData)
----	end

----	if Sync.ReleaseIds and not table.empty(Sync.ReleaseIds) then
----		for id, v in Sync.ReleaseIds do
----			FixedEcoData[id] = nil
----		end
----	end

----	oldOnSync()

--end
