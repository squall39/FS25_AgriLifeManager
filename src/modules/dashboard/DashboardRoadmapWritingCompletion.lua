-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - final dashboard writing completion for roadmap states.
AgriLife = AgriLife or {}

if AgriLife.Dashboard6Service ~= nil then
    local Dashboard = AgriLife.Dashboard6Service
    local baseGetSnapshot = Dashboard.getSnapshot

    local function module(core, id)
        return core ~= nil and core.registry ~= nil and core.registry.instances ~= nil and core.registry.instances[id] or nil
    end

    local function safeSnapshot(instance, farmId)
        if instance ~= nil and instance.getSnapshot ~= nil then
            local ok, value = pcall(instance.getSnapshot, instance, farmId)
            if ok and type(value) == "table" then return value end
        end
        return {}
    end

    function Dashboard:getSnapshot(farmId)
        local result = baseGetSnapshot(self, farmId) or {farmId=farmId, cards={}}
        result.cards = result.cards or {}
        result.cards.bank = result.cards.bank or {}
        result.cards.careerQualifications = result.cards.careerQualifications or {}

        local bank = module(self.core, "bank")
        local bankSnapshot = safeSnapshot(bank, farmId)
        local advanced = bank ~= nil and bank.getAdvancedAccountingSnapshot ~= nil and bank:getAdvancedAccountingSnapshot(farmId, false) or bankSnapshot.accountingAdvanced
        local relationship = bank ~= nil and bank.getRelationshipSnapshot ~= nil and bank:getRelationshipSnapshot(farmId) or bankSnapshot.relationship
        if type(relationship) == "table" then
            result.cards.bank.relationship = relationship
            result.cards.bank.relationshipStatus = tostring(relationship.status or "none")
            result.cards.bank.relationshipRemainingMonths = math.max(0, tonumber(relationship.remainingMonths) or 0)
            result.cards.bank.relationshipEndPeriodKey = math.max(0, tonumber(relationship.endPeriodKey) or 0)
        end
        if type(advanced) == "table" then
            result.cards.bank.netIncome = tonumber(advanced.netIncome) or 0
            result.cards.bank.selfFinancingCapacity = tonumber(advanced.selfFinancingCapacity) or 0
            result.cards.bank.depreciation = tonumber(advanced.depreciation) or 0
            result.cards.bank.outstandingTax = tonumber(advanced.outstandingTax) or result.cards.bank.outstandingTax or 0
            result.cards.bank.equity = advanced.balance ~= nil and tonumber(advanced.balance.equity) or 0
            result.cards.bank.debtServiceCoverage = tonumber(advanced.debtServiceCoverage) or 0
        end

        local exams = safeSnapshot(module(self.core, "exams"), farmId)
        local careerCard = result.cards.careerQualifications
        careerCard.attempts = math.max(0, tonumber(exams.attempts) or 0)
        careerCard.passes = math.max(0, tonumber(exams.passes) or 0)
        careerCard.historyCount = math.max(0, tonumber(exams.historyCount) or 0)
        careerCard.licenceNumber = tostring(exams.licenceNumber or "")
        careerCard.currentScore = tonumber(exams.score) or tonumber(careerCard.lastResultScore) or 0
        careerCard.errors = math.max(0, tonumber(exams.errors) or 0)
        careerCard.examPassed = tostring(exams.licenceStatus or "") == "obtained"

        local economy = safeSnapshot(module(self.core, "economy"), farmId)
        result.difficulty = tostring(economy.modeId or result.difficulty or "facile")
        local provisional = economy.provisionalLicence or {}
        careerCard.provisional = provisional
        careerCard.permitOptional = result.difficulty == "facile" and not careerCard.examPassed
        careerCard.examRequired = result.difficulty == "difficile" and not careerCard.examPassed
        careerCard.vehicleLocked = careerCard.examRequired and careerCard.examRunning ~= true
        return result
    end
end

if AgriLife.DashboardModule ~= nil then
    AgriLife.DashboardModule.VERSION = "0.9.1.0"
    local baseDescriptor = AgriLife.DashboardModule.getDescriptor
    function AgriLife.DashboardModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.9.1.0"
        return descriptor
    end
end
