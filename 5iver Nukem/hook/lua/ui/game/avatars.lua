--local Lazy = import('/lua/lazyvar.lua')
--Lazy.ExtendedErrorMessages = true
isAutoSelection = false -- prevents sounds, construction bar change, and selection bracket change (see gamemain.OnSelectionChanged)
local counter = -55

controls.idleNukes = false

local oldCreateIdleTab = CreateIdleTab
function CreateIdleTab(unitData, id, expandFunc)
	local bg = oldCreateIdleTab(unitData, id, expandFunc)
	local oldbgUpdate = bg.Update
	
	bg.Update = function(self, units)
		oldbgUpdate(self, units)

		if self.id == 'nuke' then
			local sortedUnits = {}
			sortedUnits[4] = EntityCategoryFilterDown(categories.EXPERIMENTAL * categories.NUKE, self.allunits)
			sortedUnits[3] = EntityCategoryFilterDown(categories.TECH3 * categories.NUKE, self.allunits)
			sortedUnits[2] = EntityCategoryFilterDown(categories.TECH3 * categories.TACTICALMISSILEPLATFORM, self.allunits)
			sortedUnits[1] = EntityCategoryFilterDown(categories.TECH2 * categories.TACTICALMISSILEPLATFORM, self.allunits)
			
			local keyToIcon = {'TacticalT2','TacticalT3','NukeT3','NukeT4'}            
            
			local i = table.getn(sortedUnits)
            local needIcon = true
            while i > 0 do
                if table.getn(sortedUnits[i]) > 0 then
                    if needIcon then
                        if Factions[currentFaction].IdleNukeTextures[keyToIcon[i]] and DiskGetFileInfo('/textures/ui/common'..Factions[currentFaction].IdleNukeTextures[keyToIcon[i]]) then
                            self.icon:SetTexture('/textures/ui/common'..Factions[currentFaction].IdleNukeTextures[keyToIcon[i]])
                        else
                            self.icon:SetTexture(UIUtil.UIFile(Factions[currentFaction].IdleNukeTextures['T2']))
                        end
                        needIcon = false
                    end
                    for _, unit in sortedUnits[i] do
                        table.insert(self.units, unit)
                    end
                end
                i = i - 1
            end
		end
		self.count:SetText(table.getsize(self.allunits))
		
		if self.expandCheck.expandList then
			self.expandCheck.expandList:Update(self.allunits)
		end
	end
	
	return bg
end

local oldGetCheck = GetCheck
function GetCheck(id)
	oldGetCheck(id)
	
	if id == 'nuke' and controls.idleNukes then
		return controls.idleNukes.expandCheck
	end
end

function CreateIdleNukeList(parent, units)
	local group = Group(parent)
	
	local bgTop = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_t.dds'))
	local bgBottom = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_b.dds'))
	local bgStretch = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_m.dds'))
	
	group.Width:Set(bgTop.Width)
	group.Height:Set(1)
	
	bgTop.Bottom:Set(group.Top)
	bgBottom.Top:Set(group.Bottom)
	bgStretch.Top:Set(group.Top)
	bgStretch.Bottom:Set(group.Bottom)
	
	LayoutHelpers.AtHorizontalCenterIn(bgTop, group)
	LayoutHelpers.AtHorizontalCenterIn(bgBottom, group)
	LayoutHelpers.AtHorizontalCenterIn(bgStretch, group)
	
	group.connector = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/bracket_bmp.dds'))
	group.connector.Right:Set(function() return parent.Left() + 8 end)
	LayoutHelpers.AtVerticalCenterIn(group.connector, parent)
	
	LayoutHelpers.LeftOf(group, parent, 10)
	group.Top:Set(function() return math.max(controls.avatarGroup.Top()+10, (parent.Top() + (parent.Height() / 2)) - (group.Height() / 2)) end)
	
	group:DisableHitTest(true)
	
	group.icons = {}
	
	group.Update = function(self, unitData)
		local function CreateUnitEntry(techLevel, userUnits, icontexture)
			local entry = Group(self)
			
			entry.icon = Bitmap(entry)
			if DiskGetFileInfo('/textures/ui/common'..icontexture) then
				entry.icon:SetTexture('/textures/ui/common'..icontexture)
			else
				entry.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
			end
			entry.icon.Height:Set(34)
			entry.icon.Width:Set(34)
			LayoutHelpers.AtRightIn(entry.icon, entry, 22)
			LayoutHelpers.AtVerticalCenterIn(entry.icon, entry)
			
			entry.iconBG = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds'))
			LayoutHelpers.AtCenterIn(entry.iconBG, entry.icon)
			entry.iconBG.Depth:Set(function() return entry.icon.Depth() - 1 end)
			
			if techLevel == '4' then
				entry.techIcon = Bitmap(entry, UIUtil.SkinnableFile('/mods/5iver Nukem/textures/'..currentFaction..'/tech-4_bmp.dds'))
			else
				entry.techIcon = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-engineers-panel/tech-'..techLevel..'_bmp.dds'))
			end
			
			LayoutHelpers.AtLeftIn(entry.techIcon, entry)
			LayoutHelpers.AtVerticalCenterIn(entry.techIcon, entry.icon)
			
			entry.count = UIUtil.CreateText(entry, '', 20, UIUtil.bodyFont)
			entry.count:SetColor('ffffffff')
			entry.count:SetDropShadow(true)
			LayoutHelpers.AtRightIn(entry.count, entry.icon)
			LayoutHelpers.AtBottomIn(entry.count, entry.icon)
			
			entry.countBG = Bitmap(entry)
			entry.countBG:SetSolidColor('77000000')
			entry.countBG.Top:Set(function() return entry.count.Top() - 1 end)
			entry.countBG.Left:Set(function() return entry.count.Left() - 1 end)
			entry.countBG.Right:Set(function() return entry.count.Right() + 1 end)
			entry.countBG.Bottom:Set(function() return entry.count.Bottom() + 1 end)
			
			entry.countBG.Depth:Set(function() return entry.Depth() + 1 end)
			entry.count.Depth:Set(function() return entry.countBG.Depth() + 1 end)
			
			entry.Height:Set(function() return entry.iconBG.Height() end)
			entry.Width:Set(self.Width)
			
			entry.icon:DisableHitTest()
			entry.iconBG:DisableHitTest()
			entry.techIcon:DisableHitTest()
			entry.count:DisableHitTest()
			entry.countBG:DisableHitTest()
			
			entry.curIndex = 1
			entry.units = userUnits
			entry.HandleEvent = ClickFunc
			
			return entry
		end
		local nukes = {}
		nukes[4] = EntityCategoryFilterDown(categories.EXPERIMENTAL * categories.NUKE, unitData)
		nukes[3] = EntityCategoryFilterDown(categories.TECH3 * categories.NUKE, unitData)
        nukes[2] = EntityCategoryFilterDown(categories.TECH3 * categories.TACTICALMISSILEPLATFORM, unitData)
		nukes[1] = EntityCategoryFilterDown(categories.TECH2 * categories.TACTICALMISSILEPLATFORM, unitData)
		-- maybe check for BlackOPS mod or cycle through blueprints to see what is possible?
        local indexToIcon = {'2', '3', '3', '4'}
        local keyToIcon = {'TacticalT2','TacticalT3','NukeT3','NukeT4'}
        for index, units in nukes do
            local i = index
            if not self.icons[i] then
                self.icons[i] = CreateUnitEntry(indexToIcon[i], units, Factions[currentFaction].IdleNukeTextures[keyToIcon[index]])
                self.icons[i].priority = i
            end
            if table.getn(units) > 0 and not self.icons[i]:IsHidden() then
                self.icons[i].units = units
                self.icons[i].count:SetText(table.getn(units))
                self.icons[i].count:Show()
                self.icons[i].countBG:Show()
                self.icons[i].icon:SetAlpha(1)
            else
                self.icons[i].units = {}
                self.icons[i].count:Hide()
                self.icons[i].countBG:Hide()
                self.icons[i].icon:SetAlpha(.2)
            end
        end
		local prevGroup = false
		local groupHeight = 0
		for index, nukeGroup in nukes do
			local i = index
			if not self.icons[i] then continue end
			if prevGroup then
				LayoutHelpers.Above(self.icons[i], prevGroup)
			else
				LayoutHelpers.AtLeftIn(self.icons[i], self, 7)
				LayoutHelpers.AtBottomIn(self.icons[i], self, 2)
			end
			groupHeight = groupHeight + self.icons[i].Height()
			prevGroup = self.icons[i]
		end
		group.Height:Set(groupHeight)
	end
	
	group:Update(units)
	
	return group
end

local oldAvatarUpdate = AvatarUpdate
function AvatarUpdate()
	counter = counter + 1
	if counter >= 0 and math.mod(counter, 5) == 0 then
		oldAvatarUpdate()
		
		counter = 0
		--LOG("GetCommandMode = "..repr(import('/lua/ui/game/commandmode.lua').GetCommandMode()))
		if import('/lua/ui/game/commandmode.lua').GetCommandMode()[1] then
			return
		end
				
		--save current selection
		local selectedUnits = GetSelectedUnits()
		isAutoSelection = true
		
		--select nukes
		UISelectionByCategory('SILO * STRUCTURE', false, false, false, false)

		--get selected units and save to variable
		local nukesAll = GetSelectedUnits()
		
		--return selection to original
		SelectUnits(selectedUnits)
		isAutoSelection = false
		
		local nukes = {}

		if nukesAll then
			for i,v in ipairs(nukesAll) do
				if v:GetMissileInfo().nukeSiloStorageCount > 0 or v:GetMissileInfo().tacticalSiloStorageCount > 0 then
					table.insert(nukes, v)
				end
			end
		end
		--LOG('nukes = '..table.getn(nukes))
		if table.getn(nukes) == 0 then
			nukes = nil
		end
				
		local needsAvatarLayout = false
		
		if nukes then
			if controls.idleNukes then
				controls.idleNukes:Update(nukes)
			else
				--LOG("calling CreateIdleTab for nuke")
				controls.idleNukes = CreateIdleTab(nukes, 'nuke', CreateIdleNukeList)
				--LOG("after calling CreateIdleTab for nuke")
				if expandedCheck == 'nuke' then
					--LOG("if expandedCheck, before SetCheck")
					controls.idleNukes.expandCheck:SetCheck(true)
					--LOG("after SetCheck")
				end
				needsAvatarLayout = true
			end
		else
			if controls.idleNukes then
				controls.idleNukes:Destroy()
				controls.idleNukes = nil
				needsAvatarLayout = true
			end
		end
		
		if needsAvatarLayout then
			--LOG("before LayoutAvatars")
			import(UIUtil.GetLayoutFilename('avatars')).LayoutAvatars()
			--LOG("after LayoutAvatars")
		end
	end
end