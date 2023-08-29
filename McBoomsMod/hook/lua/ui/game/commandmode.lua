local CreateMex = import('/mods/McBoomsMod/modules/mex/MexesManager.lua').CreateMex

local function UpgradeUnit(unit)
    ForkThread(
        function()
            ---@type UserUnit
            local units = { unit }
            if not IsDestroyed(unit) and not unit:GetFocus() then
                import("/lua/ui/game/selection.lua").Hidden(
                    function()
                        SelectUnits(units)
                        IssueBlueprintCommand("UNITCOMMAND_Upgrade", unit:GetBlueprint().General.UpgradesTo, 1, true)
                    end
                )

                WaitSeconds(0.5)

                SetPaused(units, true)
            end
        end
    )
end

local lastClickTick = -9999

function OnGuardUpgrade(guardees, unit)
    if EntityCategoryContains(categories.MASSEXTRACTION * categories.TECH1, unit) and
        Prefs.GetFromCurrentProfile('options.assist_to_upgrade') == 'Tech1Extractors'
    then
        UpgradeUnit(unit)
    end

    if EntityCategoryContains(categories.MASSEXTRACTION * categories.TECH2, unit) then
        local currentTick = GameTick()

        -- Check if ringed already, if it is then upgrade
        local mex = CreateMex(unit);
        local numStorages

        local isDoubleClick = currentTick < lastClickTick + 5
        if isDoubleClick and IsKeyDown('Shift') then
            UpgradeUnit(unit)
        elseif mex.armyManager:isCanCountMS() then
            local e = mex.unit:GetEconData()
            local ratio = e.energyRequested>0 and (e.energyConsumed/e.energyRequested) or 1.0
            local base = mex:getBpMassPerSec()
            local buffBase = mex:getStorageBuff()

            local max = (base+(buffBase*4)) * ratio
            if e.massProduced>max then
                return
            end

            if e.massProduced <= base * ratio then
                numStorages = 0
            elseif e.massProduced <= (base+(buffBase*1)) * ratio then
                numStorages = 1
            elseif e.massProduced <= (base+(buffBase*2)) * ratio then
                numStorages = 2
            elseif e.massProduced <= (base+(buffBase*3)) * ratio then
                numStorages = 3
            elseif e.massProduced <= (base+(buffBase*4)) * ratio then
                numStorages = 4
            end

            if numStorages == 4 then
                UpgradeUnit(unit)
            end
        end
        lastClickTick = currentTick
    end
end