local modPath = '/mods/SupremeScoreBoard2/'
local modScripts  = modPath..'modules/'

CurrentEvents = {}
CurrentEvents.ACUEntersTransporter = {}
CurrentEvents.ACUDestroyed = {}

function UpdateEvents(newEvents)
    -- insert every element
    if newEvents.ACUEntersTransporter then
        for i,acu in pairs(newEvents.ACUEntersTransporter) do
            table.insert(CurrentEvents.ACUEntersTransporter, acu)
        end
    end
    if newEvents.ACUDestroyed then
        for i,acu in pairs(newEvents.ACUDestroyed) do
            table.insert(CurrentEvents.ACUDestroyed, acu)
        end
    end
end