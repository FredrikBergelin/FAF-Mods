local UIP = import('/mods/UI-Party/modules/UI-Party.lua')


local oldCreateIdleTab = CreateIdleTab
function CreateIdleTab(unitData, id, expandFunc)
    local bg = oldCreateIdleTab(unitData, id, expandFunc)

	if (UIP.GetSetting("alertIdleFac")) then

		if (id == "factory") then
			bg.overlay = Bitmap(bg)
			LayoutHelpers.AtLeftTopIn(bg.overlay, bg, 12, 12)
			bg.overlay:SetSolidColor('aaFF0000')
			bg.overlay.Width:Set(22)
			bg.overlay.Height:Set(22)
			bg.overlay:DisableHitTest()
			bg.overlay.dir = -1
			bg.overlay.cycles = 0
			bg.overlay.OnFrame = function(self, delta)
					local newAlpha = self:GetAlpha() + (delta * 3 * self.dir)
					if newAlpha > 1 then
						newAlpha = 1
						self.dir = -1
						self.cycles = self.cycles + 1
						if self.cycles >= 5 then
							self:SetNeedsFrameUpdate(false)
						end
					elseif newAlpha < 0 then
						newAlpha = 0
						self.dir = 1
					end
					self:SetAlpha(newAlpha)
				end
			bg.overlay:SetNeedsFrameUpdate(true)

			--ShowBigRedScreen()
		end

	end

	return bg
end

function CreateIdleEngineerList(parent, units)
    local group = Group(parent)

    local bgTop = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_t.dds'))
    local bgBottom = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_b.dds'))
    local bgStretch = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_m.dds'))

    group.Width:Set(bgTop.Width)
    LayoutHelpers.SetHeight(group, 1)

    bgTop.Bottom:Set(group.Top)
    bgBottom.Top:Set(group.Bottom)
    bgStretch.Top:Set(group.Top)
    bgStretch.Bottom:Set(group.Bottom)

    LayoutHelpers.AtHorizontalCenterIn(bgTop, group)
    LayoutHelpers.AtHorizontalCenterIn(bgBottom, group)
    LayoutHelpers.AtHorizontalCenterIn(bgStretch, group)

    group.connector = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/bracket_bmp.dds'))
    LayoutHelpers.AnchorToLeft(group.connector, parent, -8)
    LayoutHelpers.AtVerticalCenterIn(group.connector, parent)

    LayoutHelpers.LeftOf(group, parent, 10)
    group.Top:Set(function() return math.max(controls.avatarGroup.Top()+10, (parent.Top() + (parent.Height() / 2)) - (group.Height() / 2)) end)

    group:DisableHitTest(true)

    group.icons = {}

    group.Update = function(self, unitData)
        local function CreateUnitEntry(techLevel, userUnits, icontexture)
            local entry = Group(self)

            entry.icon = Bitmap(entry)
            -- Iddle engineer icons groupwindow
            if UIUtil.UIFile(icontexture,true) then
                entry.icon:SetTexture(UIUtil.UIFile(icontexture,true))
            else
                entry.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
            end
            LayoutHelpers.SetDimensions(entry.icon, 34, 34)
            LayoutHelpers.AtRightIn(entry.icon, entry, 22)
            LayoutHelpers.AtVerticalCenterIn(entry.icon, entry)

            entry.iconBG = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds'))
            LayoutHelpers.AtCenterIn(entry.iconBG, entry.icon)
            LayoutHelpers.DepthUnderParent(entry.iconBG, entry.icon)

            entry.techIcon = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-engineers-panel/tech-'..techLevel..'_bmp.dds'))
            LayoutHelpers.AtLeftIn(entry.techIcon, entry)
            LayoutHelpers.AtVerticalCenterIn(entry.techIcon, entry.icon)

            entry.count = UIUtil.CreateText(entry, '', 20, UIUtil.bodyFont)
            entry.count:SetColor('ffffffff')
            entry.count:SetDropShadow(true)
            LayoutHelpers.AtRightIn(entry.count, entry.icon)
            LayoutHelpers.AtBottomIn(entry.count, entry.icon)

            entry.countBG = Bitmap(entry)
            entry.countBG:SetSolidColor('77000000')
            LayoutHelpers.AtLeftTopIn(entry.countBG, entry.count, -1, -1)
            LayoutHelpers.AtRightBottomIn(entry.countBG, entry.count, -1, -1)

            LayoutHelpers.DepthOverParent(entry.countBG, entry)
            LayoutHelpers.DepthOverParent(entry.count, entry.countBG)

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
        local engineers = {}
        engineers[5] = EntityCategoryFilterDown(categories.SUBCOMMANDER, unitData)
        engineers[4] = EntityCategoryFilterDown(categories.TECH3 - categories.SUBCOMMANDER, unitData)
        engineers[3] = EntityCategoryFilterDown(categories.FIELDENGINEER, unitData)
        engineers[2] = EntityCategoryFilterDown(categories.TECH2 - categories.FIELDENGINEER, unitData)
        engineers[1] = EntityCategoryFilterDown(categories.TECH1, unitData)

        local indexToIcon = {'1', '2', '2', '3', '3'}
        local keyToIcon = {'T1','T2','T2F','T3','SCU'}
        for index, units in engineers do
            local i = index
            -- ADDED SUPPORT FOR CUSTOM FACTIONS HAVING FIELD ENGINEERS
            if i == 3 and (not Factions[currentFaction].IdleEngTextures or not Factions[currentFaction].IdleEngTextures.T2F) then
                continue
            end
            if not self.icons[i] then
                self.icons[i] = CreateUnitEntry(indexToIcon[i], units, Factions[currentFaction].IdleEngTextures[keyToIcon[index]])
                self.icons[i].priority = i
            end
            if not table.empty(units) and not self.icons[i]:IsHidden() then
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
        for index, engGroup in engineers do
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

function CreateIdleFactoryList(parent, units)
    local bg = Bitmap(parent, UIUtil.SkinnableFile('/game/avatar-factory-panel/factory-panel_bmp.dds'))

    LayoutHelpers.AnchorToLeft(bg, parent, 86)
    bg.Top:Set(controls.avatarGroup.Top())

    local connector = Bitmap(bg, UIUtil.SkinnableFile('/game/avatar-factory-panel/bracket_bmp.dds'))
    LayoutHelpers.AtVerticalCenterIn(connector, parent)
    LayoutHelpers.AnchorToLeft(connector, parent, -7)

    bg:DisableHitTest(true)

    bg.icons = {}

    local iconData = {'LAND','AIR','NAVAL'}

    local idleTextures = Factions[currentFaction].IdleFactoryTextures

    local prevIcon = false
    for type, category in iconData do
        local function CreateIcon(texture)
            local icon = Bitmap(bg)
            -- Idle facory icons groupwindow
            if UIUtil.UIFile(texture,true) then
                icon:SetTexture(UIUtil.UIFile(texture,true))
            else
                icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
            end
            LayoutHelpers.SetDimensions(icon, 40, 40)

            icon.count = UIUtil.CreateText(icon, '', 20, UIUtil.bodyFont)
            icon.count:SetColor('ffffffff')
            LayoutHelpers.AtRightIn(icon.count, icon)
            LayoutHelpers.AtBottomIn(icon.count, icon)

            icon.countBG = Bitmap(icon)
            icon.countBG:SetSolidColor('77000000')
            LayoutHelpers.AtLeftTopIn(icon.countBG, icon.count, -1, -1)
            LayoutHelpers.AtRightBottomIn(icon.countBG, icon.count, -1, -1)

            icon.countBG.Depth:Set(function() return icon.Depth() + 1 end)
            icon.count.Depth:Set(function() return icon.countBG.Depth() + 1 end)

            icon.curIndex = 1
            icon.HandleEvent = ClickFunc

            return icon
        end
        bg.icons[category] = {}
        local table = bg.icons[category]
        for index=1, 3 do
            local i = index
            table[i] = CreateIcon(idleTextures[category][i])
            if i == 1 then
                if prevIcon then
                    LayoutHelpers.RightOf(table[i], prevIcon, 4)
                else
                    LayoutHelpers.AtLeftIn(table[i], bg, 38)
                    LayoutHelpers.AtBottomIn(table[i], bg, 10)
                end
                prevIcon = table[i]
            else
                LayoutHelpers.Above(table[i], table[i-1], 4)
            end
        end
    end

    bg.Update = function(self, unitData)
        local factories = {LAND = {}, AIR = {}, NAVAL = {}}
        for type, table in factories do
            table[1] = EntityCategoryFilterDown(categories.TECH1 * categories[type], unitData)
            table[2] = EntityCategoryFilterDown(categories.TECH2 * categories[type], unitData)
            table[3] = EntityCategoryFilterDown(categories.TECH3 * categories[type], unitData)
        end
        for type, icons in bg.icons do
            for index=1,3 do
                local i = index
                if not table.empty(factories[type][i]) then
                    bg.icons[type][i].units = factories[type][i]
                    bg.icons[type][i]:SetAlpha(1)
                    bg.icons[type][i].countBG:Show()
                    bg.icons[type][i].count:SetText(table.getn(factories[type][i]))
                else
                    bg.icons[type][i]:SetAlpha(.2)
                    bg.icons[type][i].countBG:Hide()
                    bg.icons[type][i].count:SetText('')
                end
            end
        end
    end

    bg:Update(units)

    return bg
end

-- local preContractState = false
-- function Contract()
--     preContractState = controls.avatarGroup:IsHidden()
--     -- controls.avatarGroup:Hide()
--     -- controls.collapseArrow:Hide()
-- end

--local bigRed;

--function CreateBigRedScreen()

--	if (UIP.GetSetting("immersionAcuDamage")) then

--		bigRed = Bitmap(GetFrame(0))
--		LayoutHelpers.AtLeftTopIn(bigRed, GetFrame(0), 7, 8)
--		bigRed.Left:Set(0)
--		bigRed.Top:Set(0)
--		bigRed:SetSolidColor('33FF0000')
--		bigRed.Width:Set(90)
--		bigRed.Height:Set(34)
--		bigRed.Width:Set(1920)
--		bigRed.Height:Set(1080)
--		bigRed:DisableHitTest()
--		bigRed:SetAlpha(0)
--		bigRed:SetNeedsFrameUpdate(false)

--	end
--end

--function ShowBigRedScreen()

--	if (UIP.GetSetting("immersionAcuDamage")) then

--		bigRed:SetAlpha(1)
--		bigRed:SetNeedsFrameUpdate(true)

--		bigRed.OnFrame = function(self, delta)
--			local newAlpha = self:GetAlpha() - 0.005
--			if newAlpha >= 0 then -- some rare bug here
--				self:SetAlpha(newAlpha)

--				if newAlpha == 0 then
--					bigRed:SetNeedsFrameUpdate(false)
--				end
--			end
--		end
--	end
--end

--CreateBigRedScreen()
