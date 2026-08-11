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
        local state = self:getFarmState(farmId, true)
        local policy = self:getModePolicy(farmId)
        local provisional = self:getProvisionalLicenceStatus(farmId)
        local step = self:getStartupStep(farmId)
        local blockReason = self:getVehicleControlBlockReason(farmId)

        return {
            farmId = tonumber(farmId) or 0,
            step = step,
            ready = self:isReady(farmId),
            modeId = state ~= nil and state.modeId or "facile",
            modeChosen = state ~= nil and state.modeChosen == true,
            tutorialChoiceMade = state ~= nil and state.tutorialChoiceMade == true,
            tutorialEnabled = state ~= nil and state.tutorialEnabled == true,
            existingCareerDetected = state ~= nil and state.existingCareerDetected == true,
            existingCareerAcknowledged = state ~= nil and state.existingCareerAcknowledged == true,
            startingMoneyApplied = state ~= nil and state.startingMoneyApplied == true,
            startingMoney = policy.startingMoney,
            bankRequired = policy.bankRequired == true,
            bankProviderSelected = self:isBankProviderSelected(farmId),
            bankAdvisorSelected = self:isBankAdvisorSelected(farmId),
            licenceRequired = policy.licenceRequired == true,
            licenceObtained = self:isLicenceObtained(farmId),
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
