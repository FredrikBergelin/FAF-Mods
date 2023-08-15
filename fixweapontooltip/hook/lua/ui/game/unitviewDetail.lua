


function isWeaponEqual(wp1,wp2)
    -- this function checks a few important keys to see if the weapons are identical
    -- which works better than only checking the display name
    -- because some mods don't bother changing the display name
    local compareKeys = {
        "DisplayName",
        "MuzzleSalvoSize","Damage","DamageToShields","RackSalvoChargeTime",
        "RackSalvoReloadTime","WeaponCategory","BeamLifetime","DamageRadius",
        "MinRadius","MaxRadius"
    }

    for i=1,table.getn(compareKeys) do
        local key = compareKeys[i]
    
        --if wp1[key] ~= nil or wp2[key] ~= nil then -- only perform the check if either is nil
        --    if wp1[key] == nil and wp2[key] ~= nil then return false end
        --    if wp1[key] ~= nil and wp2[key] == nil then return false end
            if wp1[key] ~= wp2[key] then return false end
        --end
    end

    return true
end


function WrapAndPlaceText(bp, builder, descID, control)
    local lines = {}
    local blocks = {}

    --Unit description
    local text = LOC(UnitDescriptions[descID])
    if text and text ~='' then
        table.insert(blocks, {color = UIUtil.fontColor,
            lines = WrapText(text, control.Value[1].Width(), function(text)
                return control.Value[1]:GetStringAdvance(text)
            end)})
        table.insert(blocks, {color = UIUtil.bodyColor, lines = {''}})
    end

    if builder and bp.EnhancementPresetAssigned then
        table.insert(lines, LOC('<LOC uvd_upgrades>')..':')
        for _, v in bp.EnhancementPresetAssigned.Enhancements do
            table.insert(lines, '    '..LOC(bp.Enhancements[v].Name))
        end
        table.insert(blocks, {color = 'FFB0FFB0', lines = lines})
    elseif bp then
        --Get not autodetected abilities
        if bp.Display.Abilities then
            for _, id in bp.Display.Abilities do
                local ability = ExtractAbilityFromString(id)
                if not IsAbilityExist[ability] then
                    table.insert(lines, LOC(id))
                end
            end
        end

        -- special check for blackops aeon t3 transport (remove this if fixed by faf devs)
        bp.General.TeleportDelay = bp.General.TeleportDelay or -1

        --Autodetect abilities exclude engineering
        for id, func in IsAbilityExist do
            if (id ~= 'ability_engineeringsuite') and (id ~= 'ability_building') and
               (id ~= 'ability_repairs') and (id ~= 'ability_reclaim') and (id ~= 'ability_capture') and func(bp) then
                local ability = LOC('<LOC '..id..'>')
                if GetAbilityDesc[id] then
                    local desc = GetAbilityDesc[id](bp) or ""
                    if desc ~= '' then
                        desc = ' - '..desc
                    end
                    ability = ability..desc
                end
                table.insert(lines, ability)
            end
        end
        if not table.empty(lines) then
            table.insert(lines, '')
        end
        table.insert(blocks, {color = 'FF7FCFCF', lines = lines})
        --Autodetect engineering abilities
        if IsAbilityExist.ability_engineeringsuite(bp) then
            lines = {}

            table.insert(lines, LOC('<LOC '..'ability_engineeringsuite'..'>')
                ..' - '..LOCF('<LOC uvd_BuildRate>', bp.Economy.BuildRate or -1)
                ..', '..LOCF('<LOC uvd_Radius>', bp.Economy.MaxBuildDistance or -1))
            local orders = LOC('<LOC order_0011>')
            if IsAbilityExist.ability_building(bp) then
                orders = orders..', '..LOC('<LOC order_0001>')
            end
            if IsAbilityExist.ability_repairs(bp) then
                orders = orders..', '..LOC('<LOC order_0005>')
            end
            if IsAbilityExist.ability_reclaim(bp) then
                orders = orders..', '..LOC('<LOC order_0006>')
            end
            if IsAbilityExist.ability_capture(bp) then
                orders = orders..', '..LOC('<LOC order_0007>')
            end
            table.insert(lines, orders)
            table.insert(lines, '')
            table.insert(blocks, {color = 'FFFFFFB0', lines = lines})
        end

        if options.gui_render_armament_detail == 1 then
            --Armor values
            lines = {}
            local armorType = bp.Defense.ArmorType
            if armorType and armorType ~= '' then
                local spaceWidth = control.Value[1]:GetStringAdvance(' ')
                local str = LOC('<LOC uvd_ArmorType>')..LOC('<LOC at_'..armorType..'>')
                local spaceCount = (195 - control.Value[1]:GetStringAdvance(str)) / spaceWidth
                str = str..string.rep(' ', spaceCount)..LOC('<LOC uvd_DamageTaken>')
                table.insert(lines, str)
                for _, armor in armorDefinition do
                    if armor[1] == armorType then
                        local row = 0
                        local armorDetails = ''
                        local elemCount = table.getsize(armor)
                        for i = 2, elemCount do
                            --if string.find(armor[i], '1.0') > 0 then continue end
                            local armorName = armor[i]
                            armorName = string.sub(armorName, 1, string.find(armorName, ' ') - 1)
                            armorName = LOC('<LOC an_'..armorName..'>')..' - '..string.format('%0.1f', tonumber(armor[i]:sub(armorName:len() + 2, armor[i]:len())) * 100)
                            if row < 1 then
                                armorDetails = armorName
                                row = 1
                            else
                                local spaceCount = (195 - control.Value[1]:GetStringAdvance(armorDetails)) / spaceWidth
                                armorDetails = armorDetails..string.rep(' ', spaceCount)..armorName
                                table.insert(lines, armorDetails)
                                armorDetails = ''
                                row = 0
                            end
                        end
                        if armorDetails ~= '' then
                            table.insert(lines, armorDetails)
                        end
                    end
                end
                table.insert(lines, '')
                table.insert(blocks, {color = 'FF7FCFCF', lines = lines})
            end
            --Weapons
            if not table.empty(bp.Weapon) then
                local weapons = {upgrades = {normal = {}, death = {}},
                                    basic = {normal = {}, death = {}}}
                for _, weapon in bp.Weapon do
                    if not weapon.WeaponCategory then continue end
                    local dest = weapons.basic
                    if weapon.EnabledByEnhancement then
                        dest = weapons.upgrades
                    end
                    if (weapon.FireOnDeath) or (weapon.WeaponCategory == 'Death') then
                        dest = dest.death
                    else
                        dest = dest.normal
                    end

                    local displayName = weapon.DisplayName
                    local num = 2 -- intentionally start at 2
                    while num < 100 do
                        if dest[displayName] then
                            if isWeaponEqual(dest[displayName].info,weapon) then
                                dest[displayName].count = dest[displayName].count + 1
                                break
                            else
                                displayName = weapon.DisplayName .. ' ' .. num
                                num = num + 1
                            end
                        else
                            dest[displayName] = {info = weapon, count = 1}
                            break
                        end
                    end
                end
                for k, v in weapons do
                    if not table.empty(v.normal) or not table.empty(v.death) then
                        table.insert(blocks, {color = UIUtil.fontColor, lines = {LOC('<LOC uvd_'..k..'>')..':'}})
                    end
                    local displayDPS, totalGroundDPS, totalAirDPS, totalNavyDPS = false, 0, 0, 0
                    local shortRange, longRange = 60, 120
                    local airWeapons, navyWeapons, shortRangeWeapons, mediumRangeWeapons, longRangeWeapons = 0, 0, 0, 0, 0
                    local totalShortRangeDPS, totalMediumRangeDPS, totalLongRangeDPS = 0, 0, 0

                    for name, weapon in v.normal do
                        local info = weapon.info
                        local weaponDetails1 = LOCStr(name)..' ('..LOCStr(info.WeaponCategory)..') '
                        if info.ManualFire then
                            weaponDetails1 = weaponDetails1..LOC('<LOC uvd_ManualFire>')
                        end
                        local weaponDetails2
                        if info.NukeInnerRingDamage then
                            weaponDetails2 = string.format(LOC('<LOC uvd_0014>Damage: %d - %d, Splash: %d - %d')..', '..LOC('<LOC uvd_Range>'),
                                info.NukeInnerRingDamage + info.NukeOuterRingDamage, info.NukeOuterRingDamage,
                                info.NukeInnerRingRadius, info.NukeOuterRingRadius, info.MinRadius, info.MaxRadius)
                        else
                            local MuzzleBones = 0
                            if info.MuzzleSalvoDelay > 0 then
                                MuzzleBones = info.MuzzleSalvoSize
                            elseif info.RackBones then
                                for _, v in info.RackBones do
                                    MuzzleBones = MuzzleBones + table.getsize(v.MuzzleBones)
                                end
                                if not info.RackFireTogether then
                                    MuzzleBones = MuzzleBones / table.getsize(info.RackBones)
                                end
                            else
                                MuzzleBones = 1
                            end

                            local Damage = info.Damage
                            if info.DamageToShields then
                                Damage = math.max(Damage, info.DamageToShields)
                            end
                            Damage = Damage * (info.DoTPulses or 1)
                            local ProjectilePhysics = __blueprints[info.ProjectileId].Physics
                            while ProjectilePhysics do
                                Damage = Damage * (ProjectilePhysics.Fragments or 1)
                                ProjectilePhysics = __blueprints[string.lower(ProjectilePhysics.FragmentId or '')].Physics
                            end

                            local ReloadTime = math.max((info.RackSalvoChargeTime or 0) + (info.RackSalvoReloadTime or 0) +
                                (info.MuzzleSalvoDelay or 0) * (info.MuzzleSalvoSize or 1), 1 / info.RateOfFire)

                            if not info.ManualFire and info.WeaponCategory ~= 'Kamikaze' then
                                local DPS = Damage * MuzzleBones
                                if info.BeamLifetime > 0 then
                                    DPS = DPS * info.BeamLifetime * 10
                                end
                                DPS = DPS / ReloadTime + (info.InitialDamage or 0)

                                -- Calculate total DPS

                                if DPS > 0 then
	                                local WeaponCount = weapon.count or 1
	                                local Category = info.WeaponCategory or ""
	                                local MaxRadius = info.MaxRadius or 0

	                                local WeaponDPS = DPS * WeaponCount
	                                if Category == "Anti Air" then
	                                	totalAirDPS = totalAirDPS + WeaponDPS
	                                	airWeapons = airWeapons + WeaponCount
	                                elseif Category == "Anti Navy" then
	                                	totalNavyDPS = totalNavyDPS + WeaponDPS
	                                	navyWeapons = navyWeapons + WeaponCount
	                                else
	                                	totalGroundDPS = totalGroundDPS + WeaponDPS

	                                	-- ranges
	                                	if MaxRadius <= shortRange then
	                                		totalShortRangeDPS = totalShortRangeDPS + WeaponDPS
	                                		shortRangeWeapons = shortRangeWeapons + WeaponCount
	                                	elseif MaxRadius <= longRange then
	                                		totalMediumRangeDPS = totalMediumRangeDPS + WeaponDPS
	                                		mediumRangeWeapons = mediumRangeWeapons + WeaponCount
	                                	elseif MaxRadius > longRange then
	                                		totalLongRangeDPS = totalLongRangeDPS + WeaponDPS
	                                		longRangeWeapons = longRangeWeapons + WeaponCount
	                                	end
	                                end

	                                if totalGroundDPS + totalAirDPS + totalNavyDPS > DPS then
	                                	-- only display DPS if we have more than one weapon, this is a very efficient way to check for that.
	                                	displayDPS = true
	                                end
	                            end

                                weaponDetails1 = weaponDetails1..LOCF('<LOC uvd_DPS>', DPS or -1)
                            end

                            weaponDetails2 = string.format(LOC('<LOC uvd_0010>Damage: %d, Splash: %d')..', '..LOC('<LOC uvd_Range>')..', '..LOC('<LOC uvd_Reload>'),
                                Damage, info.DamageRadius, info.MinRadius, info.MaxRadius, ReloadTime)
                        end
                        if weapon.count > 1 then
                            weaponDetails1 = weaponDetails1..' x'..weapon.count
                        end
                        table.insert(blocks, {color = UIUtil.fontColor, lines = {weaponDetails1}})
                        table.insert(blocks, {color = 'FFFFB0B0', lines = {weaponDetails2}})
                    end

                    if displayDPS then
                    	lines = {''}
                    	if totalGroundDPS > 0 then
                    		table.insert(lines,string.format("Direct Fire: %s weapons, %s DPS",shortRangeWeapons+mediumRangeWeapons+longRangeWeapons,math.round(totalGroundDPS)))
                    		if totalShortRangeDPS > 0 then table.insert(lines,string.format("    Short (<=%s): %s weapons, %s DPS",shortRange,shortRangeWeapons,math.round(totalShortRangeDPS))) end
                    		if totalMediumRangeDPS > 0 then table.insert(lines,string.format("    Medium (<=%s): %s weapons, %s DPS",longRange,mediumRangeWeapons,math.round(totalMediumRangeDPS))) end
                    		if totalLongRangeDPS > 0 then table.insert(lines,string.format("    Long (>%s): %s weapons, %s DPS",longRange,longRangeWeapons,math.round(totalLongRangeDPS))) end
                    	end
                    	if totalAirDPS > 0 then
                    		table.insert(lines,string.format("Anti Air: %s weapons, %s DPS",airWeapons,math.round(totalAirDPS)))
                    	end
                    	if totalNavyDPS > 0 then
                    		table.insert(lines,string.format("Anti Navy: %s weapons, %s DPS",airWeapons,math.round(totalNavyDPS)))
                    	end
                		table.insert(blocks, {color = UIUtil.fontColor, lines = lines})
                    end

                    lines = {}
                    for name, weapon in v.death do
                        local info = weapon.info
                        local weaponDetails = LOCStr(name)..' ('..LOCStr(info.WeaponCategory)..') '
                        if info.NukeInnerRingDamage then
                            weaponDetails = weaponDetails..LOCF('<LOC uvd_0014>Damage: %d - %d, Splash: %d - %d',
                                (info.NukeInnerRingDamage or -1) + (info.NukeOuterRingDamage or -1), info.NukeOuterRingDamage or -1,
                                info.NukeInnerRingRadius or -1, info.NukeOuterRingRadius or -1)
                        else
                            weaponDetails = weaponDetails..LOCF('<LOC uvd_0010>Damage: %d, Splash: %d',
                                info.Damage, info.DamageRadius)
                        end
                        if weapon.count > 1 then
                            weaponDetails = weaponDetails..' x'..weapon.count
                        end
                        table.insert(lines, weaponDetails)
                    end
                    if not table.empty(v.normal) or not table.empty(v.death) then
                        table.insert(lines, '')
                    end
                    table.insert(blocks, {color = 'FFFF0000', lines = lines})
                end
            end
        end
        --Other parameters
        lines = {}
        table.insert(lines, LOCF("<LOC uvd_0013>Vision: %d, Underwater Vision: %d, Regen: %0.1f, Cap Cost: %0.1f",
            bp.Intel.VisionRadius or -1, bp.Intel.WaterVisionRadius or -1, bp.Defense.RegenRate or -1, bp.General.CapCost or -1))

        if (bp.Physics.MotionType ~= 'RULEUMT_Air' and bp.Physics.MotionType ~= 'RULEUMT_None')
        or (bp.Physics.AltMotionType ~= 'RULEUMT_Air' and bp.Physics.AltMotionType ~= 'RULEUMT_None') then
            table.insert(lines, LOCF("<LOC uvd_0012>Speed: %0.1f, Reverse: %0.1f, Acceleration: %0.1f, Turning: %d",
                bp.Physics.MaxSpeed or -1, bp.Physics.MaxSpeedReverse or -1, bp.Physics.MaxAcceleration or -1, bp.Physics.TurnRate or -1))
        end

        table.insert(blocks, {color = 'FFB0FFB0', lines = lines})
    end
    CreateLines(control, blocks)
end