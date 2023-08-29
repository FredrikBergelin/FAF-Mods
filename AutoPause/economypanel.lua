local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local borders = import('/lua/ui/game/borders.lua').GetMapGroup()
local ToolTip = import('/lua/ui/game/tooltip.lua')
local EffectHelpers = import('/lua/maui/effecthelpers.lua')
local GPGSelection = import('/lua/ui/game/selection.lua')
local selectionSets = GPGSelection.selectionSets
local Keymapper = import('/lua/keymap/keymapper.lua')

local panel = false
local splitPanel = false

local massConsumedText = false
local energyConsumedText = false

local massReqText = false
local energyReqText = false

local fabTitleText = false
local fabEnergyUseText = false

local panelUpdateThread = false

local energyPercent = 0

local autoFabsOn = false
local FabsTech2 = {}
local FabsTech3 = {}
local t2FabsUse = 0
local t3FabsUse = 0
local numT2Fabs = 0
local numT3Fabs = 0
local numT2On = 0
local numT3On = 0

local BPt2EUse = 150
local BPt3EUse = 3500
local BPt2MProd = 1
local BPt3MProd = 12


function UpdateEconTotals()
   local econTotals = GetEconomyTotals()

   local globalEnergyMax = econTotals["maxStorage"]["ENERGY"]
   local globalEnergyCurrent = econTotals["stored"]["ENERGY"]

   energyPercent = 100 * (globalEnergyCurrent / globalEnergyMax)
   return energyPercent
end



function UpdateEconValues()
   local simFrequency = GetSimTicksPerSecond()

   local econTotals = GetEconomyTotals()

   local massReqTotal = econTotals["lastUseRequested"]["MASS"] * simFrequency
   local energyReqTotal = econTotals["lastUseRequested"]["ENERGY"] * simFrequency

   local massUseTotal = econTotals["income"]["MASS"] * simFrequency
   local energyUseTotal = econTotals["income"]["ENERGY"] * simFrequency

   local massUse = 0
   local energyUse = 0
   local massReq = 0
   local energyReq = 0

   -- Calculate economy of selected units
   local totalSel = GetSelectedUnits()
   totalSel = ValidateUnitsList(totalSel)
   if totalSel then
      for i, unit in totalSel do
         local econData = unit:GetEconData()
         massReq = massReq + econData["massRequested"]
         energyReq = energyReq + econData["energyRequested"]
         massUse = massUse + econData["massConsumed"]
         energyUse = energyUse + econData["energyConsumed"]
      end
   end

   -- maths and display
   local massReqDisplay = math.min(massReq, 999999)
   local massReqPercent = 0
   if massReqTotal > 0 then
      massReqPercent = math.ceil((100 * massReq) / massReqTotal)
   end

   local massUseDisplay = math.min(massUse, 999999)
   local massUsePercent = 0
   if massUseTotal > 0 then
      massUsePercent = math.ceil((100 * massUse) / massUseTotal)
   end

   local energyReqDisplay = math.min(energyReq, 999999)
   local energyReqPercent = 0
   if energyReqTotal > 0 then
      energyReqPercent = math.ceil((100 * energyReq) / energyReqTotal)
   end

   local energyUseDisplay = math.min(energyUse, 999999)
   local energyUsePercent = 0
   if energyUseTotal > 0 then
      energyUsePercent = math.ceil((100 * energyUse) / energyUseTotal)
   end

   massReqText:SetText("M Req: ( " .. massReqPercent .. "% ) -" .. massReqDisplay)
   massConsumedText:SetText("M Use: ( " .. massUsePercent .. "% ) -" .. massUseDisplay)

   energyReqText:SetText("E Req: ( " .. energyReqPercent .. "% ) -" .. energyReqDisplay)
   energyConsumedText:SetText("E Use: ( " .. energyUsePercent .. "% ) -" .. energyUseDisplay)

end

function ShowEcon()
   if panel then
      if panel:IsHidden() then
         UpdateFabs()
--         if autoFabsOn then AllFabsOff() end
         showEffect(panel, splitPanel)
      else  
         hideEffect(panel, splitPanel)
      end   
   end  
end


function AutoPause()
   local totalSel = GetSelectedUnits()
   totalSel = ValidateUnitsList(totalSel)
   if totalSel then
      for i, unit in totalSel do
         local currUnit = unit

         -- Update thread, per unit.
         if (currUnit:GetWorkProgress() > 0) and (currUnit.AutoUpdateThread == nil) then
            -- Set label in name
            unit.originalName = unit:GetCustomName(unit)
            local newName = "[AUTOPAUSE]"
            if unit.originalName then
               newName = unit.originalName .. " " .. newName
            end
            unit:SetCustomName(newName)

            currUnit.AutoUpdateThread = ForkThread(function()
                       local prevProgress = 0
                       while not currUnit:IsDead() do
                          -- If we're done, return to original name and end.
                          if currUnit:GetWorkProgress() < prevProgress then
                             EndAutoPause(currUnit)
                             KillThread(CurrentThread()) 
                          end

                          prevProgress = currUnit:GetWorkProgress()

                          -- Otherwise check and pause
                          UpdateEconTotals()
                          if not GetIsPaused({currUnit}) and (energyPercent < 70) then                          
                             SetPaused({currUnit}, true)
                          elseif GetIsPaused({currUnit}) and (energyPercent > 90) then                          
                             SetPaused({currUnit}, false)
                          end   
                          WaitSeconds(0.5)
                       end
                       currUnit.AutoUpdateThread = nil
                    end)
         end
            -- End update thread.
      end
   end


end

function EndAutoPause(currUnit)
   SetPaused({currUnit}, false)

   if currUnit.originalName then
      currUnit:SetCustomName(currUnit.originalName)
      currUnit.originalName = nil
   else
      currUnit:SetCustomName("")
   end
   currUnit.AutoUpdateThread = nil
end

function UpdateFabs()
   local oldselection = GetSelectedUnits()
   
   -- Get T2 massfabs
   UISelectionByCategory("MASSFABRICATION * STRUCTURE * TECH2", false, false, false, false)
   FabsTech2 = GetSelectedUnits()
   if FabsTech2 == nil then FabsTech2 = {} end

   -- Get T3 massfabs
   UISelectionByCategory("MASSFABRICATION * STRUCTURE * TECH3", false, false, false, false)
   FabsTech3 = GetSelectedUnits()
   if FabsTech3 == nil then FabsTech3 = {} end

   SelectUnits(oldselection)
end

function SetFab(fab, on)
   if on then
      ToggleScriptBit({fab}, 4, true)
   else
      ToggleScriptBit({fab}, 4, false)
   end  
end

function GetFab(fab)
   return (GetScriptBit({fab}, 4) == false)
end

function AllFabsOff()
   FabsTech2 = ValidateUnitsList(FabsTech2)
   if FabsTech2 then
      for i, fab in FabsTech2 do
         SetFab(fab, false)
      end
   end

   FabsTech3 = ValidateUnitsList(FabsTech3)
   if FabsTech3 then
      for i, fab in FabsTech3 do
         SetFab(fab, false)
      end
   end
end

function UpdateMassFabEUse()
   numT2On = 0
   numT3On = 0

   local simFrequency = GetSimTicksPerSecond()
   local econTotals = GetEconomyTotals()
   local energyUseTotal = econTotals["income"]["ENERGY"] * simFrequency

   local energyUse = 0
   FabsTech2 = ValidateUnitsList(FabsTech2)
   numT2Fabs = table.getn(FabsTech2)
   if FabsTech2 then
      for i, fab in FabsTech2 do
         local econData = fab:GetEconData()
         energyUse = energyUse + econData["energyConsumed"]
         if GetFab(fab) then 
            numT2On = numT2On + 1
         end    
      end
   end
   t2FabsUse = energyUse

   FabsTech3 = ValidateUnitsList(FabsTech3)
   numT3Fabs = table.getn(FabsTech3)
   if FabsTech3 then
      for i, fab in FabsTech3 do
         local econData = fab:GetEconData()
         energyUse = energyUse + econData["energyConsumed"]
         if GetFab(fab) then 
            numT3On = numT3On + 1
         end    
      end
   end
   t3FabsUse = energyUse - t2FabsUse

   local energyUseDisplay = math.min(energyUse, 999999)
   local energyUsePercent = 0
   if energyUseTotal > 0 then
      energyUsePercent = math.ceil((100 * energyUse) / energyUseTotal)
   end

   fabEnergyUseText:SetText("E Use: ( " .. energyUsePercent .. "% ) -" .. energyUseDisplay)

   -- Handle the title string
   fabTitle = "Fabs( " .. numT2On+numT3On .. " / " .. numT2Fabs + numT3Fabs .. " )"
   if autoFabsOn then
      fabTitle = fabTitle .. " [AUTO]"
   end  
   fabTitleText:SetText(fabTitle)

end

function DoAutoFabs()
   -- If we're not managing, and not displaying the panel, then nothing to do
   if panel:IsHidden() and not autoFabsOn then return end

   -- Update panel
   UpdateMassFabEUse()

   -- If we're not managing, stop here
   if not autoFabsOn then return end   

   local simFrequency = GetSimTicksPerSecond()
   local econTotals = GetEconomyTotals()

   local energyMax = econTotals["maxStorage"]["ENERGY"]
   local energyCurrent = econTotals["stored"]["ENERGY"]

   local energyIncome = econTotals["income"]["ENERGY"] * simFrequency
   local energyUse = econTotals["lastUseActual"]["ENERGY"] * simFrequency
   local energyNet = energyIncome - energyUse

   local projectedNet = energyNet

   -- If storage is low, turn off all fabs
   if (energyCurrent / energyMax) < 0.9 then
      AllFabsOff()
      return
   end

   if projectedNet < 0 then
      --------------------------------
      -- turn off fabs if income is -ve
      if (projectedNet < (-BPt3EUse)) and numT3On > 0 then
         for i, fab in FabsTech3 do
            if GetFab(fab) then 
               -- If we find an active fab, turn it off and return the energy
               local econData = fab:GetEconData()
               projectedNet = projectedNet + econData["energyConsumed"]
               SetFab(fab, false)
               numT3On = numT3On - 1
               -- If we're in +ves then stop
               if not projectedNet < 0 then break end
            end    
         end
      end  
      if projectedNet < 0 and numT2On > 0 then
         for i, fab in FabsTech2 do
            if GetFab(fab) then 
               -- If we find an active fab, turn it off and return the energy
               local econData = fab:GetEconData()
               projectedNet = projectedNet + econData["energyConsumed"]
               SetFab(fab, false)
               numT2On = numT2On - 1
               -- If we're in +ves then stop
               if not projectedNet < 0 then break end
            end    
         end
      end
      -----------------------------------
   else
      ---------------------------------
      -- Turn on fabs if we have spare income
      local desiredNumT2 = numT2On
      local desiredNumT3 = numT3On

      if projectedNet > BPt2EUse then
         if (projectedNet > BPt3EUse) and ((numT3Fabs - desiredNumT3) > 0) then
            -- If we have spare T3 fabs and enough energy, turn it on
            projectedNet = projectedNet - BPt3EUse
            desiredNumT3 = desiredNumT3 + 1
         elseif ((numT2Fabs - desiredNumT2) > 0) then
            -- Otherwise if we have spare t2 fabs, turn it on.
            projectedNet = projectedNet - BPt2EUse
            desiredNumT2 = desiredNumT2 + 1
--         else break 
         end
      end  

      -- we want to replace T3s with equivalent energy amounts of T2s, because they give more mass
      local ratioT2T3 = math.floor(BPt3EUse / BPt2EUse)
      while ((numT2Fabs - desiredNumT2) > ratioT2T3) and (desiredNumT3 > 0) do
         desiredNumT2 = desiredNumT2 + ratioT2T3
         desiredNumT3 = desiredNumT3 - 1         
      end   

      -- Turn on massfabs
      if FabsTech2 then
         for i, fab in FabsTech2 do
            if not GetFab(fab) and numT2On < desiredNumT2 then
               SetFab(fab, true)
               numT2On = numT2On + 1
               if numT2On == desiredNumT2 then break end
            end    
         end
      end

      if FabsTech3 then
         for i, fab in FabsTech3 do
            if not GetFab(fab) and numT3On < desiredNumT3 then
               SetFab(fab, true)
               numT3On = numT3On + 1
               if numT3On == desiredNumT3 then break end
            end    
         end
      end   
      --------------------------------
   end 


end

function ToggleAutoFabs()
   if autoFabsOn then
      autoFabsOn = false
   else  
      autoFabsOn = true
   end   
end

-------------------------------------------
function CreatePanel(parent)
	local panel = Bitmap(parent)
	panel:SetTexture('/mods/AutoPause/textures/panel.dds')
	panel.Right:Set(function() return parent.Right() - 100 end)
	panel.Top:Set(function() return parent.Top() + 100 end)
	panel.Depth:Set(100)
	panel.Width:Set(200)
	panel.Height:Set(130)
	return panel
end

function CreateSplitControls(parent)
	local splitgroup = Group(parent)
	splitgroup.Left:Set(parent.Left)
	splitgroup.Top:Set(function() return parent.Top() + 5 end)
	splitgroup.Right:Set(parent.Right)
	splitgroup.Height:Set(130)
    -- 5, 23, 45, 63, 85, 100
	massReqText = UIUtil.CreateText(splitgroup, "M Req:", 15)
	LayoutHelpers.AtLeftTopIn(massReqText, splitgroup, 15, 23)

	massConsumedText = UIUtil.CreateText(splitgroup, "M Use:", 15)
	LayoutHelpers.AtLeftTopIn(massConsumedText, splitgroup, 15, 5)

	energyReqText = UIUtil.CreateText(splitgroup, "E Req:", 15)
	LayoutHelpers.AtLeftTopIn(energyReqText, splitgroup, 15, 63)

	energyConsumedText = UIUtil.CreateText(splitgroup, "E Use:", 15)
	LayoutHelpers.AtLeftTopIn(energyConsumedText, splitgroup, 15, 45)

    fabTitleText = UIUtil.CreateText(splitgroup, "Fabs", 15)
	LayoutHelpers.AtLeftTopIn(fabTitleText, splitgroup, 15, 85)

    fabEnergyUseText = UIUtil.CreateText(splitgroup, "E Use:", 15)
	LayoutHelpers.AtLeftTopIn(fabEnergyUseText, splitgroup, 15, 100)

	return splitgroup
end

function hideEffect(control, subcontrol1)
	control:DisableHitTest(true)
    control:SetNeedsFrameUpdate(true)

	local timefade = 0.1
	local time1 = 0.1
	local time2 = 0.2
	local minHeight = 16
    local timeAccum = 0

	EffectHelpers.FadeOut(subcontrol1, timefade)
	
    control.OnFrame = function(self, elapsedTime)
        timeAccum = timeAccum + elapsedTime
		if timeAccum >= (time1 + time2) then
            self:SetNeedsFrameUpdate(false)
            self:Hide()
			self.Left:Set(function() return self.Right() - 3 end)
		elseif timeAccum >= time1 then
			self.Left:Set(function() return self.Right() - self.BitmapWidth()*((time2+time1 - timeAccum)/(time2)) end)
			self.Bottom:Set(function() return self.Top() + minHeight end)
		else
			self.Bottom:Set(function() return self.Top() + minHeight + (self.BitmapHeight() - minHeight)*((time1 - timeAccum)/(time1)) end )
		end
    end
end

function showEffect(control, subcontrol1)
	control:Show()
    control:SetNeedsFrameUpdate(true)

	local timefade = 0.1
	local time1 = 0.2
	local time2 = 0.1
	local minHeight = 16
    local timeAccum = 0

    control.OnFrame = function(self, elapsedTime)
        timeAccum = timeAccum + elapsedTime
		if timeAccum >= (time1 + time2) then
			self:EnableHitTest(true)
            self:SetNeedsFrameUpdate(false)
			LayoutHelpers.ResetLeft(self)
			LayoutHelpers.ResetBottom(self)
			EffectHelpers.FadeIn(subcontrol1, timefade)
		elseif timeAccum >= time1 then
			self.Bottom:Set(function() return self.Top() + minHeight + (self.BitmapHeight() - minHeight)*((timeAccum - time1)/(time2)) end )
			self.Left:Set(function() return self.Right() - self.BitmapWidth() end)
        else
			self.Left:Set(function() return self.Right() - self.BitmapWidth()*((timeAccum)/(time1)) end)
        end
     end
end

function Init()
	panel = CreatePanel(borders)
	splitPanel = CreateSplitControls(panel)

    panelUpdateThread = ForkThread(function()
                                      while panel do
                                         if not panel:IsHidden() then
                                            UpdateEconValues()
                                         end
                                         DoAutoFabs()
                                         WaitSeconds(1)
                                      end   
                                   end)

    hideEffect(panel, splitPanel) -- start hidden

    --AddConsoleOutputReciever(function(output) LOG(output) end) -- For con_listcommands

	local newSelectionsMap = {    
	}
	IN_AddKeyMapTable(newSelectionsMap)

    local replacementMap = {
    ['Semicolon']          = {action =	 'UI_Lua import("/mods/AutoPause/economypanel.lua").ShowEcon()'}, 
    ['Shift-Semicolon']    = {action =	 'UI_Lua import("/mods/AutoPause/economypanel.lua").AutoPause()'}, 
    ['Shift-Ctrl-Semicolon']    = {action =	 'UI_Lua import("/mods/AutoPause/economypanel.lua").ToggleAutoFabs()'}, 
    }

    IN_AddKeyMapTable(replacementMap)
end
