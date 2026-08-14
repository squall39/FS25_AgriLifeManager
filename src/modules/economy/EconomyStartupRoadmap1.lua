-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
-- Roadmap step 1: startup state machine and startup invariants.

AgriLife = AgriLife or {}

if AgriLife.Economy6Service ~= nil then
    AgriLife.Economy6Service.STARTUP_STEP = {
        MIGRATION = "migration",
        TUTORIAL = "tutorial",
        DIFFICULTY = "difficulty",
        BANK = "bank",
        ADVISOR = "advisor",
        EXAM = "exam",
        READY = "ready"
    }

    function AgriLife.Economy6Service:getStartupStep(farmId)
        local state = self:getFarmState(farmId, true)
        if state == nil then return AgriLife.Economy6Service.STARTUP_STEP.TUTORIAL end

        if state.existingCareerDetected == true and state.existingCareerAcknowledged ~= true then
            return AgriLife.Economy6Service.STARTUP_STEP.MIGRATION
        end
        if state.tutorialChoiceMade ~= true then
            return AgriLife.Economy6Service.STARTUP_STEP.TUTORIAL
        end
        if state.modeChosen ~= true then
            return AgriLife.Economy6Service.STARTUP_STEP.DIFFICULTY
        end

        local policy = self:getModePolicy(farmId)
        if policy.bankRequired == true then
            if not self:isBankProviderSelected(farmId) then
                return AgriLife.Economy6Service.STARTUP_STEP.BANK
            end
            if not self:isBankAdvisorSelected(farmId) then
                return AgriLife.Economy6Service.STARTUP_STEP.ADVISOR
            end
        end

        if policy.licenceRequired == true and not self:isLicenceObtained(farmId) then
            return AgriLife.Economy6Service.STARTUP_STEP.EXAM
        end

        return AgriLife.Economy6Service.STARTUP_STEP.READY
    end

    function AgriLife.Economy6Service:getStartupSnapshot(farmId)
        farmId = tonumber(farmId) or 0
        local state = self:getFarmState(farmId, true)
        local policy = self:getModePolicy(farmId)
        local modeId = state ~= nil and tostring(state.modeId or "facile") or "facile"
        local mode = AgriLife.Economy6Service.MODES[modeId] or AgriLife.Economy6Service.MODES.facile

        -- This snapshot is requested on every root-page change. Resolve each
        -- cross-module dependency once instead of re-entering Bank and Exams
        -- through getStartupStep(), isReady() and the vehicle guard.
        local bankState = self:getBankState(farmId)
        local providerSelected = bankState ~= nil and bankState.providerSelected == true
        local advisorSelected = bankState ~= nil and bankState.advisorSelected == true

        local ownerProfileId = nil
        local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local company = instances ~= nil and instances.company or nil
        local companyService = company ~= nil and (company.service or company) or nil
        if companyService ~= nil and companyService.getFarmState ~= nil then
            local companyState = companyService:getFarmState(farmId, false)
            if companyState ~= nil and tostring(companyState.ownerProfileId or "") ~= "" then ownerProfileId = tostring(companyState.ownerProfileId) end
        end
        if ownerProfileId == nil then ownerProfileId = self:getOwnerProfileId(farmId) end
        local exams = instances ~= nil and instances.exams or nil
        local examSnapshot = exams ~= nil and exams.getSnapshot ~= nil and exams:getSnapshot(farmId, ownerProfileId) or nil
        local licenceObtained = examSnapshot ~= nil and tostring(examSnapshot.licenceStatus or "") == "obtained"
        local examRunning = examSnapshot ~= nil and examSnapshot.examRunning == true

        local currentPeriod = self:getCurrentPeriodKey()
        local provisional
        if mode.provisionalLicence ~= true then
            provisional = {enabled=false, active=false, expired=false, completed=licenceObtained}
        else
            local deadline = math.max(0, math.floor(tonumber(state ~= nil and state.provisionalDeadlinePeriodKey) or 0))
            local started = state ~= nil and state.provisionalLicenceStarted == true
            local expired = started and not licenceObtained and deadline > 0 and currentPeriod >= deadline
            provisional = {
                enabled=true, started=started, active=started and not licenceObtained and not expired, expired=expired,
                completed=licenceObtained or (state ~= nil and state.provisionalCompleted == true),
                startPeriodKey=math.max(0, math.floor(tonumber(state ~= nil and state.provisionalStartPeriodKey) or 0)),
                deadlinePeriodKey=deadline,
                remainingMonths=started and math.max(0, deadline-currentPeriod) or math.max(0, tonumber(mode.provisionalMonths) or 3),
                fineApplied=state ~= nil and state.provisionalFineApplied == true,
                fineAmount=math.max(0, tonumber(state ~= nil and state.provisionalFineAmount) or 0)
            }
        end

        local step = AgriLife.Economy6Service.STARTUP_STEP.TUTORIAL
        if state ~= nil and state.existingCareerDetected == true and state.existingCareerAcknowledged ~= true then
            step = AgriLife.Economy6Service.STARTUP_STEP.MIGRATION
        elseif state == nil or state.tutorialChoiceMade ~= true then
            step = AgriLife.Economy6Service.STARTUP_STEP.TUTORIAL
        elseif state.modeChosen ~= true then
            step = AgriLife.Economy6Service.STARTUP_STEP.DIFFICULTY
        elseif policy.bankRequired == true and not providerSelected then
            step = AgriLife.Economy6Service.STARTUP_STEP.BANK
        elseif policy.bankRequired == true and not advisorSelected then
            step = AgriLife.Economy6Service.STARTUP_STEP.ADVISOR
        elseif policy.licenceRequired == true and not licenceObtained then
            step = AgriLife.Economy6Service.STARTUP_STEP.EXAM
        else
            step = AgriLife.Economy6Service.STARTUP_STEP.READY
        end

        local ready = state ~= nil and state.tutorialChoiceMade == true and state.modeChosen == true and state.setupCompleted == true
        if ready and policy.companyRequired == true and state.statutesAccepted ~= true then ready = false end
        if ready and policy.bankRequired == true and not (providerSelected and advisorSelected) then ready = false end
        if ready and policy.licenceRequired == true and not licenceObtained then ready = false end

        local blockReason = nil
        if farmId <= 0 or state == nil or state.modeChosen ~= true then
            blockReason = "difficulty"
        elseif mode.id ~= "facile" and mode.bankRequired == true and not (providerSelected and advisorSelected) then
            blockReason = "bank"
        elseif mode.id == "difficile" and not licenceObtained and not examRunning then
            blockReason = "licence"
        end

        return {
            farmId = farmId,
            step = step,
            ready = ready,
            modeId = modeId,
            modeName = mode.name,
            modePolicy = policy,
            modeChosen = state ~= nil and state.modeChosen == true,
            setupCompleted = state ~= nil and state.setupCompleted == true,
            statutesAccepted = state ~= nil and state.statutesAccepted == true,
            tutorialChoiceMade = state ~= nil and state.tutorialChoiceMade == true,
            tutorialEnabled = state ~= nil and state.tutorialEnabled == true,
            tutorialCompleted = state ~= nil and state.tutorialCompleted == true,
            existingCareerDetected = state ~= nil and state.existingCareerDetected == true,
            existingCareerAcknowledged = state ~= nil and state.existingCareerAcknowledged == true,
            startingMoneyApplied = state ~= nil and state.startingMoneyApplied == true,
            startingMoney = policy.startingMoney,
            bankRequired = policy.bankRequired == true,
            bankSelected = providerSelected and advisorSelected,
            bankProviderSelected = providerSelected,
            bankAdvisorSelected = advisorSelected,
            licenceRequired = policy.licenceRequired == true,
            licenceObtained = licenceObtained,
            provisionalLicence = provisional,
            vehicleBlocked = blockReason ~= nil,
            vehicleBlockReason = blockReason
        }
    end

    function AgriLife.Economy6Service:validateStartupState(farmId)
        local state = self:getFarmState(farmId, false)
        if state == nil then
            return AgriLife.Result.ok("ECONOMY_STARTUP_EMPTY", "No startup state exists yet")
        end

        if state.setupCompleted == true and state.modeChosen ~= true then
            return AgriLife.Result.fail("ECONOMY_STARTUP_INVALID_MODE", "Setup is complete without a confirmed difficulty", {farmId = farmId})
        end
        if state.startingMoneyApplied == true and state.modeChosen ~= true then
            return AgriLife.Result.fail("ECONOMY_STARTUP_INVALID_MONEY", "Starting money was applied before the difficulty was confirmed", {farmId = farmId})
        end
        if state.modeChosen == true and state.tutorialChoiceMade ~= true then
            return AgriLife.Result.fail("ECONOMY_STARTUP_INVALID_TUTORIAL", "Difficulty was confirmed before the tutorial choice", {farmId = farmId})
        end
        if state.existingCareerDetected == true and state.modeChosen == true and state.existingCareerAcknowledged ~= true then
            return AgriLife.Result.fail("ECONOMY_STARTUP_INVALID_MIGRATION", "Existing career was activated before migration acknowledgement", {farmId = farmId})
        end

        return AgriLife.Result.ok("ECONOMY_STARTUP_VALID", "Startup state is coherent", {farmId = farmId, step = self:getStartupStep(farmId)})
    end

    local originalConfirmMode = AgriLife.Economy6Service.confirmMode
    function AgriLife.Economy6Service:confirmMode(farmId)
        local state = self:getFarmState(farmId, true)
        if state == nil then return AgriLife.Result.fail("ECONOMY_FARM_NOT_FOUND", "Farm not found") end
        if state.existingCareerDetected == true and state.existingCareerAcknowledged ~= true then
            return AgriLife.Result.fail("ECONOMY_EXISTING_CAREER_ACK_REQUIRED", "Acknowledge the existing FS25 career before confirming AgriLife difficulty")
        end
        if state.tutorialChoiceMade ~= true then
            return AgriLife.Result.fail("ECONOMY_TUTORIAL_CHOICE_REQUIRED", "Choose whether to follow the AgriLife tutorial before confirming difficulty")
        end
        return originalConfirmMode(self, farmId)
    end

    local originalTryAutoFinalizeStartup = AgriLife.Economy6Service.tryAutoFinalizeStartup
    function AgriLife.Economy6Service:tryAutoFinalizeStartup(farmId)
        local state = self:getFarmState(farmId, true)
        if state ~= nil and state.existingCareerDetected == true and state.existingCareerAcknowledged ~= true then
            return nil
        end
        return originalTryAutoFinalizeStartup(self, farmId)
    end

    local originalFinalizeSetup = AgriLife.Economy6Service.finalizeSetup
    function AgriLife.Economy6Service:finalizeSetup(farmId)
        local state = self:getFarmState(farmId, true)
        if state ~= nil and state.existingCareerDetected == true and state.existingCareerAcknowledged ~= true then
            return AgriLife.Result.fail("ECONOMY_EXISTING_CAREER_ACK_REQUIRED", "Acknowledge the existing FS25 career before activating AgriLife")
        end
        return originalFinalizeSetup(self, farmId)
    end

    local originalGetTutorialStep = AgriLife.Economy6Service.getTutorialStep
    function AgriLife.Economy6Service:getTutorialStep(farmId)
        local state = self:getFarmState(farmId, true)
        if state == nil then return originalGetTutorialStep(self, farmId) end
        if state.tutorialChoiceMade ~= true then return "choice" end
        if state.tutorialEnabled ~= true or state.tutorialCompleted == true then return "inactive" end

        local startupStep = self:getStartupStep(farmId)
        if startupStep == AgriLife.Economy6Service.STARTUP_STEP.MIGRATION then return "migration" end
        if startupStep == AgriLife.Economy6Service.STARTUP_STEP.DIFFICULTY then return "mode" end
        if startupStep == AgriLife.Economy6Service.STARTUP_STEP.BANK then return "bank" end
        if startupStep == AgriLife.Economy6Service.STARTUP_STEP.ADVISOR then return "advisor" end

        local policy = self:getModePolicy(farmId)
        if state.setupCompleted ~= true or (policy.companyRequired == true and state.statutesAccepted ~= true) then return "company" end
        if startupStep == AgriLife.Economy6Service.STARTUP_STEP.EXAM then return "exam" end
        return "finish"
    end
end

if AgriLife.EconomyModule ~= nil then
    function AgriLife.EconomyModule:getStartupStep(farmId)
        return self.service ~= nil and self.service:getStartupStep(farmId) or nil
    end

    function AgriLife.EconomyModule:getStartupSnapshot(farmId)
        return self.service ~= nil and self.service:getStartupSnapshot(farmId) or nil
    end

    function AgriLife.EconomyModule:validateStartupState(farmId)
        return self.service ~= nil and self.service:validateStartupState(farmId) or AgriLife.Result.fail("ECONOMY_UNAVAILABLE", "Economy unavailable")
    end
end
