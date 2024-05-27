local lowResourceColor = 'ffe826ff' --red default 'ffff0000'
local medResourceColor = 'ffffff00' --yellow default 'ffffff00'
local highResourceColor = 'ffb7e75f' --green default 'ffb7e75f'
local flashingResourceColor = 'ffffffff' --white default 'ffffffff'
local altResourceColor = 'ff404040' --gray default 'ff404040'

-- global for economy_mini.lua
GUI.incomeColor = 'ffb7e75f' --green default 'ffb7e75f'
GUI.expenseColor = 'ffe826ff' --red default 'fff30017'

local originalCreateUI = CreateUI
function CreateUI()
	originalCreateUI()
	
	local RewrittenFunction = function(self, state)
		if self.State ~= state then
			if state == lowResourceColor then
				self:SetTexture(UIUtil.UIFile('/game/resource-panel/alert-'..self.warningBitmap..'-panel_bmp.dds'))
				self.flashMod = 1.6
			elseif state == medResourceColor then
				self:SetTexture(UIUtil.UIFile('/game/resource-panel/caution-'..self.warningBitmap..'-panel_bmp.dds'))
				self.flashMod = 1.25
			end
			self.cycles = 0
			self.State = state
			self:SetNeedsFrameUpdate(true)
		end
	end
	
	GUI.energy.warningBG.SetToState = RewrittenFunction
	GUI.mass.warningBG.SetToState = RewrittenFunction
	
	-- CTRL+R economic overlay
	--local EconOverlayParams = import('/lua/ui/game/econoverlayparams.lua').EconOverlayParams
	-- EconOverlayParams.positiveColor = GUI.incomeColor
    -- EconOverlayParams.negativeColor = GUI.expenseColor
end


-- Eternal-: Fully hooked
--
--- Build a beat function for updating the UI suitable for the current options.
--
-- The UI must be constructed first.
function ConfigureBeatFunction()
    -- Create an update function for each resource type...

    --- Get a `getRateColour` function.
    --
    -- @param warnFull Should the returned getRateColour function use warning colours for fullness?
    local function fmtnum(n)
        return math.round(math.clamp(n, 0, 99999999))
    end

    local function getGetRateColour(warnFull, blink)
        local getRateColour
        -- Flags to make things blink.
        local blinkyFlag = true
        local blink = blink

        -- Counter to give up if the user stopped caring.
        local blinkyCounter = 0

        if warnFull then
            return function(rateVal, storedVal, maxStorageVal)
                local fractionFull = storedVal / maxStorageVal

                if rateVal < 0 then
                    if storedVal > 0 then
                        return medResourceColor
                    else
                        return lowResourceColor
                    end
                end

                -- Positive rate, check if we're wasting money (and flash irritatingly if so)
                if fractionFull >= 1 and blink then
                    blinkyCounter = blinkyCounter + 1
                    if blinkyCounter > 100 then
                        return flashingResourceColor
                    end

                    -- Display flashing gray-white if high on resource.
                    blinkyFlag = not blinkyFlag
                    if blinkyFlag then
                        return altResourceColor
                    else
                        return flashingResourceColor
                    end
                else
                    blinkyCounter = 0
                end

                return highResourceColor
            end
        else
            return function(rateVal, storedVal, maxStorageVal)
                local fractionFull = storedVal / maxStorageVal

                if rateVal < 0 then
                    if storedVal <= 0 then
                        return lowResourceColor
                    end

                    if fractionFull < 0.2 and blink then
                        -- Display flashing gray-white if low on resource.
                        blinkyFlag = not blinkyFlag
                        if blinkyFlag then
                            return altResourceColor
                        else
                            return flashingResourceColor
                        end
                    end

                    return medResourceColor
                end

                return highResourceColor
            end
        end
    end

    local function getResourceUpdateFunction(rType, vState, GUI)
        -- Closure copy
        local resourceType = rType
        local viewState = vState

        local storageBar = GUI.storageBar
        local curStorage = GUI.curStorage
        local maxStorage = GUI.maxStorage
        local incomeTxt = GUI.income
        local expenseTxt = GUI.expense
        local rateTxt = GUI.rate
        local warningBG = GUI.warningBG

        local reclaimDelta = GUI.reclaimDelta
        local reclaimTotal = GUI.reclaimTotal

        local econ_warnings = Prefs.GetOption('econ_warnings')
        local warnOnResourceFull = resourceType == "MASS" and econ_warnings
        local getRateColour = getGetRateColour(warnOnResourceFull, econ_warnings)

        local ShowUIWarnings
        if not econ_warnings then
            ShowUIWarnings = function() end
        else
            if warnOnResourceFull then
                ShowUIWarnings = function(effVal, storedVal, maxStorageVal)
                    if storedVal / maxStorageVal > 0.8 then
                        if effVal > 2.0 then
                            warningBG:SetToState(lowResourceColor)
                        elseif effVal > 1.0 then
                            warningBG:SetToState(medResourceColor)
                        elseif effVal < 1.0 then
                            warningBG:SetToState('hide')
                        end
                    else
                        warningBG:SetToState('hide')
                    end
                end
            else
                ShowUIWarnings = function(effVal, storedVal, maxStorageVal)
                    if storedVal / maxStorageVal < 0.2 then
                        if effVal < 0.25 then
                            warningBG:SetToState(lowResourceColor)
                        elseif effVal < 0.75 then
                            warningBG:SetToState(medResourceColor)
                        elseif effVal > 1.0 then
                            warningBG:SetToState('hide')
                        end
                    else
                        warningBG:SetToState('hide')
                    end
                end
            end
        end

        -- The quantity of the appropriate resource that had been reclaimed at the end of the last
        -- tick (captured into the returned closure).
        local lastReclaimTotal = 0
        local lastReclaimRate = 0

        -- Finally, glue all the bits together into a a resource-update function.
        return function()
            local econData = GetEconomyTotals()
            local simFrequency = GetSimTicksPerSecond()

            -- Deal with the reclaim column
            -------------------------------
            local totalReclaimed = econData.reclaimed[resourceType]

            -- Reclaimed this tick
            local thisTick = totalReclaimed - lastReclaimTotal

            -- Set a new lastReclaimTotal to carry over
            lastReclaimTotal = totalReclaimed

            -- The quantity we'd gain if we reclaimed at this rate for a full second.
            local reclaimRate = thisTick * simFrequency

            -- Set the text
            reclaimDelta:SetText('+' .. fmtnum(reclaimRate))
            reclaimTotal:SetText(fmtnum(totalReclaimed))

            -- Deal with the Storage
            ------------------------
            local maxStorageVal = econData.maxStorage[resourceType]
            local storedVal = econData.stored[resourceType]

            -- Set the bar fill
            storageBar:SetRange(0, maxStorageVal)
            storageBar:SetValue(storedVal)

            -- Set the text displays
            curStorage:SetText(math.round(storedVal))
            maxStorage:SetText(math.round(maxStorageVal))

            -- Deal with the income/expense column
            --------------------------------------
            local incomeVal = econData.income[resourceType]

            -- Should always be positive integer
            local incomeSec = math.max(0, incomeVal * simFrequency)
            local generatedIncome = incomeSec - lastReclaimRate

            -- How much are we wanting to drain?
            local expense
            if storedVal > 0.5 then
                expense = econData.lastUseActual[resourceType] * simFrequency
            else
                expense = econData.lastUseRequested[resourceType] * simFrequency
            end

            -- Set the text displays. incomeTxt should be only from non-reclaim.
            -- incomeVal is delayed by 1 tick when it comes to accounting for reclaim.
            -- This necessitates the use of the lastReclaimRate stored value.
            incomeTxt:SetText(string.format("+%d", fmtnum(generatedIncome)))
            expenseTxt:SetText(string.format("-%d", fmtnum(expense)))

            -- Store this tick's reclaimRate for next tick
            lastReclaimRate = reclaimRate

            -- Deal with the primary income/expense display
            -----------------------------------------------

            -- incomeSec and expense are already limit-checked and integers
            local rateVal = incomeSec - expense

            -- Calculate resource usage efficiency for % display mode
            local effVal
            if expense == 0 then
                effVal = incomeSec * 100
            else
                effVal = math.round((incomeSec / expense) * 100)
            end

            -- Choose to display efficiency or rate
            if States[viewState] == 2 then
                rateTxt:SetText(string.format("%d%%", math.min(effVal, 100)))
            else
                rateTxt:SetText(string.format("%+d", rateVal))
            end

            rateTxt:SetColor(getRateColour(rateVal, storedVal, maxStorageVal))

            if not UIState then
                return
            end

            ShowUIWarnings(effVal, storedVal, maxStorageVal)
        end
    end

    local massUpdateFunction = getResourceUpdateFunction('MASS', 'massViewState', GUI.mass)
    local energyUpdateFunction = getResourceUpdateFunction('ENERGY', 'energyViewState', GUI.energy)

    _BeatFunction = function()
        massUpdateFunction()
        energyUpdateFunction()
    end
end
