-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Step 8 insurance bonus/malus linked to accident liability.
AgriLife = AgriLife or {}

local Insurance = AgriLife.Insurance6Service
if Insurance == nil then return end

Insurance.BONUS_MALUS_RULES = {
    initial = 1.00,
    minimum = 0.50,
    maximum = 3.50,
    annualBonusFactor = 0.95,
    responsibleFactor = 1.25,
    sharedFactor = 1.125,
    rapidDescentCleanYears = 2,
    protectedBonusYears = 3
}
Insurance.BONUS_MALUS_CATEGORIES = {vehicle = true, liability = true, transport = true}

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(maximum, value))
end

local function round(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function floor2(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.000001) / 100
end

local function text(value, default)
    value = tostring(value or "")
    return value ~= "" and value or (default or "")
end

local function isMotorCategory(category)
    return Insurance.BONUS_MALUS_CATEGORIES[tostring(category or "")] == true
end

local function getClaimFactor(claim)
    if claim == nil or claim.requiresLiability ~= true then return 1 end
    if claim.liabilityStatus == Insurance.LIABILITY_STATUS.RESPONSIBLE then return Insurance.BONUS_MALUS_RULES.responsibleFactor end
    if claim.liabilityStatus == Insurance.LIABILITY_STATUS.SHARED then return Insurance.BONUS_MALUS_RULES.sharedFactor end
    return 1
end

function Insurance:ensureBonusMalusState(farmId)
    local state = self:getState(farmId, true)
    local rules = Insurance.BONUS_MALUS_RULES
    state.bonusMalus = clamp(state.bonusMalus or rules.initial, rules.minimum, rules.maximum)
    state.bonusMalusReviewPeriodKey = math.max(0, math.floor(tonumber(state.bonusMalusReviewPeriodKey) or 0))
    state.cleanInsuranceYears = math.max(0, math.floor(tonumber(state.cleanInsuranceYears) or 0))
    state.yearsAtMinimumBonus = math.max(0, math.floor(tonumber(state.yearsAtMinimumBonus) or 0))
    state.bonusProtectionAvailable = state.bonusProtectionAvailable == true
    state.bonusMalusHistory = type(state.bonusMalusHistory) == "table" and state.bonusMalusHistory or {}
    return state
end

function Insurance:hasBonusMalusPolicy(farmId)
    for _, policy in ipairs(self:getState(farmId, true).policies or {}) do
        if policy.status == "active" and isMotorCategory(policy.category) then return true end
    end
    return false
end

function Insurance:ensurePolicyReferencePremium(farmId, policy, coefficientBefore)
    if type(policy) ~= "table" then return end
    if not isMotorCategory(policy.category) then
        policy.referenceMonthlyPremium = math.max(0, tonumber(policy.referenceMonthlyPremium) or tonumber(policy.monthlyPremium) or 0)
        return
    end
    local coefficient = clamp(coefficientBefore or self:ensureBonusMalusState(farmId).bonusMalus, Insurance.BONUS_MALUS_RULES.minimum, Insurance.BONUS_MALUS_RULES.maximum)
    if tonumber(policy.referenceMonthlyPremium) == nil or tonumber(policy.referenceMonthlyPremium) <= 0 then
        policy.referenceMonthlyPremium = round(math.max(0, tonumber(policy.monthlyPremium) or 0) / math.max(0.01, coefficient))
    end
end

function Insurance:refreshBonusMalusPremiums(farmId, coefficientBefore)
    local state = self:ensureBonusMalusState(farmId)
    for _, policy in ipairs(state.policies or {}) do
        self:ensurePolicyReferencePremium(farmId, policy, coefficientBefore)
        if isMotorCategory(policy.category) then
            policy.monthlyPremium = round(math.max(0, tonumber(policy.referenceMonthlyPremium) or 0) * state.bonusMalus)
        end
    end
end

function Insurance:recordBonusMalusEvent(farmId, kind, previousCoefficient, newCoefficient, claimId, note)
    local state = self:ensureBonusMalusState(farmId)
    local entry = {
        periodKey = self:getPeriodKey(),
        kind = text(kind, "UPDATE"),
        previousCoefficient = round(previousCoefficient),
        newCoefficient = round(newCoefficient),
        claimId = text(claimId),
        note = text(note)
    }
    table.insert(state.bonusMalusHistory, entry)
    while #state.bonusMalusHistory > 80 do table.remove(state.bonusMalusHistory, 1) end
    self:recordEconomy(farmId, "INSURANCE_BONUS_MALUS", 0, string.format("%s/%.2f->%.2f/%s", entry.kind, entry.previousCoefficient, entry.newCoefficient, entry.claimId))
    return entry
end

function Insurance:getBonusMalusSnapshot(farmId)
    local state = self:ensureBonusMalusState(farmId)
    local coefficient = state.bonusMalus
    local status = "NEUTRAL"
    local rate = 0
    if coefficient < 1 then status = "BONUS"; rate = round((1 - coefficient) * 100)
    elseif coefficient > 1 then status = "MALUS"; rate = round((coefficient - 1) * 100) end
    local currentPeriod = self:getPeriodKey()
    local nextReview = state.bonusMalusReviewPeriodKey > 0 and state.bonusMalusReviewPeriodKey + 12 or currentPeriod + 12
    return {
        coefficient = coefficient,
        status = status,
        ratePercent = rate,
        premiumFactor = coefficient,
        cleanInsuranceYears = state.cleanInsuranceYears,
        yearsAtMinimumBonus = state.yearsAtMinimumBonus,
        bonusProtectionAvailable = state.bonusProtectionAvailable == true,
        lastReviewPeriodKey = state.bonusMalusReviewPeriodKey,
        nextReviewPeriodKey = nextReview,
        periodsUntilReview = math.max(0, nextReview - currentPeriod),
        history = state.bonusMalusHistory
    }
end

local baseQuoteBonusMalus = Insurance.quote
function Insurance:quote(farmId, category, insuredValue, tierId, risk)
    local result = baseQuoteBonusMalus(self, farmId, category, insuredValue, tierId, risk)
    if result == nil or not result.ok or result.details == nil then return result end
    local state = self:ensureBonusMalusState(farmId)
    if not isMotorCategory(category) and state.bonusMalus > 0 then
        result.details.monthlyPremium = round((tonumber(result.details.monthlyPremium) or 0) / state.bonusMalus)
    end
    result.details.bonusMalusCoefficient = isMotorCategory(category) and state.bonusMalus or 1
    result.details.bonusMalusApplied = isMotorCategory(category)
    return result
end

local baseBuyPolicyBonusMalus = Insurance.buyPolicy
function Insurance:buyPolicy(farmId, category, assetId, assetName, insuredValue, tierId, risk)
    local result = baseBuyPolicyBonusMalus(self, farmId, category, assetId, assetName, insuredValue, tierId, risk)
    if result == nil or not result.ok then return result end
    local state = self:ensureBonusMalusState(farmId)
    local policy = self:getPolicy(farmId, result.details ~= nil and result.details.policyId or "")
    if policy ~= nil then self:ensurePolicyReferencePremium(farmId, policy, state.bonusMalus) end
    if isMotorCategory(category) and state.bonusMalusReviewPeriodKey <= 0 then state.bonusMalusReviewPeriodKey = self:getPeriodKey() end
    if result.details ~= nil then result.details.bonusMalus = self:getBonusMalusSnapshot(farmId) end
    return result
end

local baseFileClaimBonusMalus = Insurance.fileClaim
function Insurance:fileClaim(farmId, policyId, damageAmount, cause, responsibleProfileId, assetId)
    local state = self:ensureBonusMalusState(farmId)
    local coefficientBefore = state.bonusMalus
    local result = baseFileClaimBonusMalus(self, farmId, policyId, damageAmount, cause, responsibleProfileId, assetId)
    if result ~= nil and result.ok then
        -- Legacy claims changed the coefficient at filing time. Step 8 waits for a liability decision instead.
        state.bonusMalus = coefficientBefore
        local claim = self.getClaim ~= nil and self:getClaim(farmId, result.details ~= nil and result.details.claimId or "") or nil
        if claim ~= nil then claim.creationMalusNeutralized = true end
    end
    return result
end

function Insurance:applyLiabilityMalus(farmId, claim)
    if type(claim) ~= "table" or claim.requiresLiability ~= true then return end
    local state = self:ensureBonusMalusState(farmId)
    local rules = Insurance.BONUS_MALUS_RULES
    local oldCoefficient = state.bonusMalus
    local previousFactor = math.max(0.01, tonumber(claim.appliedBonusMalusFactor) or 1)
    local desiredFactor = getClaimFactor(claim)

    if claim.bonusProtectionApplied == true and desiredFactor == 1 then
        state.bonusProtectionAvailable = true
        claim.bonusProtectionApplied = false
    end

    if desiredFactor > 1 and previousFactor == 1 and claim.bonusProtectionApplied ~= true
        and state.bonusMalus <= rules.minimum + 0.0001
        and state.yearsAtMinimumBonus >= rules.protectedBonusYears
        and state.bonusProtectionAvailable == true then
        desiredFactor = 1
        claim.bonusProtectionApplied = true
        state.bonusProtectionAvailable = false
    end

    if math.abs(desiredFactor - previousFactor) > 0.0001 then
        local neutralCoefficient = oldCoefficient / previousFactor
        local newCoefficient = floor2(clamp(neutralCoefficient * desiredFactor, rules.minimum, rules.maximum))
        state.bonusMalus = newCoefficient
        claim.appliedBonusMalusFactor = desiredFactor
        claim.appliedMalusShare = claim.liabilityStatus == Insurance.LIABILITY_STATUS.UNKNOWN and 0 or clamp(claim.liabilityShare or 0, 0, 1)
        self:refreshBonusMalusPremiums(farmId, oldCoefficient)
        self:recordBonusMalusEvent(farmId, desiredFactor > 1 and "MALUS" or "MALUS_REVERSAL", oldCoefficient, newCoefficient, claim.id, claim.liabilityStatus)
    elseif claim.appliedBonusMalusFactor == nil then
        claim.appliedBonusMalusFactor = desiredFactor
    end
end

function Insurance:hasResponsibleClaimBetween(farmId, startPeriodKey, endPeriodKey)
    for _, claim in ipairs(self:getState(farmId, true).claims or {}) do
        local decisionPeriod = math.max(0, math.floor(tonumber(claim.liabilityDecisionPeriodKey) or 0))
        if claim.requiresLiability == true and decisionPeriod > startPeriodKey and decisionPeriod <= endPeriodKey then
            if claim.liabilityStatus == Insurance.LIABILITY_STATUS.RESPONSIBLE or claim.liabilityStatus == Insurance.LIABILITY_STATUS.SHARED then return true end
        end
    end
    return false
end

function Insurance:processBonusMalusAnnualReview(farmId, currentPeriodKey)
    local state = self:ensureBonusMalusState(farmId)
    if not self:hasBonusMalusPolicy(farmId) then return end
    currentPeriodKey = math.max(0, math.floor(tonumber(currentPeriodKey) or self:getPeriodKey()))
    if state.bonusMalusReviewPeriodKey <= 0 then state.bonusMalusReviewPeriodKey = currentPeriodKey; return end

    local rules = Insurance.BONUS_MALUS_RULES
    while currentPeriodKey - state.bonusMalusReviewPeriodKey >= 12 do
        local reviewStart = state.bonusMalusReviewPeriodKey
        local reviewEnd = reviewStart + 12
        local hasResponsible = self:hasResponsibleClaimBetween(farmId, reviewStart, reviewEnd)
        local previousCoefficient = state.bonusMalus
        if not hasResponsible then
            state.cleanInsuranceYears = state.cleanInsuranceYears + 1
            local newCoefficient = floor2(clamp(previousCoefficient * rules.annualBonusFactor, rules.minimum, rules.maximum))
            if state.cleanInsuranceYears >= rules.rapidDescentCleanYears and newCoefficient > 1 then newCoefficient = 1 end
            state.bonusMalus = newCoefficient
            if newCoefficient <= rules.minimum + 0.0001 then
                state.yearsAtMinimumBonus = state.yearsAtMinimumBonus + 1
                if state.yearsAtMinimumBonus >= rules.protectedBonusYears then state.bonusProtectionAvailable = true end
            else
                state.yearsAtMinimumBonus = 0
            end
            self:refreshBonusMalusPremiums(farmId, previousCoefficient)
            self:recordBonusMalusEvent(farmId, "ANNUAL_BONUS", previousCoefficient, state.bonusMalus, "", "Année sans sinistre responsable")
        else
            state.cleanInsuranceYears = 0
            state.yearsAtMinimumBonus = 0
            self:recordBonusMalusEvent(farmId, "ANNUAL_REVIEW", previousCoefficient, previousCoefficient, "", "Sinistre responsable sur la période")
        end
        state.bonusMalusReviewPeriodKey = reviewEnd
    end
end

local baseProcessPeriodBonusMalus = Insurance.processPeriod
function Insurance:processPeriod(farmId, key)
    local state = self:ensureBonusMalusState(farmId)
    local coefficientBefore = state.bonusMalus
    baseProcessPeriodBonusMalus(self, farmId, key)
    -- Remove the legacy monthly reduction. The Step 8 CRM changes only at the annual review or after liability decisions.
    state.bonusMalus = coefficientBefore
    self:processBonusMalusAnnualReview(farmId, key)
end

local baseGetSnapshotBonusMalus = Insurance.getSnapshot
function Insurance:getSnapshot(farmId)
    local snapshot = baseGetSnapshotBonusMalus(self, farmId)
    if snapshot ~= nil then
        local bonusMalus = self:getBonusMalusSnapshot(farmId)
        snapshot.bonusMalus = bonusMalus.coefficient
        snapshot.bonusMalusDetails = bonusMalus
    end
    return snapshot
end

local baseSanitizeBonusMalus = Insurance.sanitize
function Insurance:sanitize(state)
    state = baseSanitizeBonusMalus(self, state)
    local rules = Insurance.BONUS_MALUS_RULES
    state.bonusMalus = clamp(state.bonusMalus or rules.initial, rules.minimum, rules.maximum)
    state.bonusMalusReviewPeriodKey = math.max(0, math.floor(tonumber(state.bonusMalusReviewPeriodKey) or 0))
    state.cleanInsuranceYears = math.max(0, math.floor(tonumber(state.cleanInsuranceYears) or 0))
    state.yearsAtMinimumBonus = math.max(0, math.floor(tonumber(state.yearsAtMinimumBonus) or 0))
    state.bonusProtectionAvailable = state.bonusProtectionAvailable == true
    state.bonusMalusHistory = type(state.bonusMalusHistory) == "table" and state.bonusMalusHistory or {}
    for _, policy in ipairs(state.policies or {}) do
        if tonumber(policy.referenceMonthlyPremium) == nil or tonumber(policy.referenceMonthlyPremium) <= 0 then
            local coefficient = isMotorCategory(policy.category) and state.bonusMalus or 1
            policy.referenceMonthlyPremium = round(math.max(0, tonumber(policy.monthlyPremium) or 0) / math.max(0.01, coefficient))
        end
    end
    for _, claim in ipairs(state.claims or {}) do
        claim.appliedBonusMalusFactor = math.max(0.01, tonumber(claim.appliedBonusMalusFactor) or 1)
        claim.bonusProtectionApplied = claim.bonusProtectionApplied == true
    end
    return state
end

local baseSaveFarmBonusMalus = Insurance.saveFarm
function Insurance:saveFarm(xmlFile, key, farmId)
    local result = baseSaveFarmBonusMalus(self, xmlFile, key, farmId)
    local state = self:ensureBonusMalusState(farmId)
    local root = key .. ".state"
    xmlFile:setInt(root .. "#bonusMalusReviewPeriodKey", state.bonusMalusReviewPeriodKey or 0)
    xmlFile:setInt(root .. "#cleanInsuranceYears", state.cleanInsuranceYears or 0)
    xmlFile:setInt(root .. "#yearsAtMinimumBonus", state.yearsAtMinimumBonus or 0)
    xmlFile:setBool(root .. "#bonusProtectionAvailable", state.bonusProtectionAvailable == true)
    for index, policy in ipairs(state.policies or {}) do
        local policyKey = string.format("%s.policies.policy(%d)", key, index - 1)
        xmlFile:setFloat(policyKey .. "#referenceMonthlyPremium", tonumber(policy.referenceMonthlyPremium) or tonumber(policy.monthlyPremium) or 0)
    end
    for index, claim in ipairs(state.claims or {}) do
        local claimKey = string.format("%s.claims.claim(%d)", key, index - 1)
        xmlFile:setFloat(claimKey .. "#appliedBonusMalusFactor", tonumber(claim.appliedBonusMalusFactor) or 1)
        xmlFile:setBool(claimKey .. "#bonusProtectionApplied", claim.bonusProtectionApplied == true)
    end
    for index, entry in ipairs(state.bonusMalusHistory or {}) do
        local historyKey = string.format("%s.bonusMalus.history.entry(%d)", key, index - 1)
        xmlFile:setInt(historyKey .. "#periodKey", entry.periodKey or 0)
        xmlFile:setString(historyKey .. "#kind", text(entry.kind))
        xmlFile:setFloat(historyKey .. "#previousCoefficient", tonumber(entry.previousCoefficient) or 1)
        xmlFile:setFloat(historyKey .. "#newCoefficient", tonumber(entry.newCoefficient) or 1)
        xmlFile:setString(historyKey .. "#claimId", text(entry.claimId))
        xmlFile:setString(historyKey .. "#note", text(entry.note))
    end
    return result
end

local baseLoadFarmBonusMalus = Insurance.loadFarm
function Insurance:loadFarm(xmlFile, key, farmId)
    local result = baseLoadFarmBonusMalus(self, xmlFile, key, farmId)
    local state = self:getState(farmId, true)
    if xmlFile ~= nil then
        local root = key .. ".state"
        state.bonusMalusReviewPeriodKey = xmlFile:getInt(root .. "#bonusMalusReviewPeriodKey", state.bonusMalusReviewPeriodKey or 0)
        state.cleanInsuranceYears = xmlFile:getInt(root .. "#cleanInsuranceYears", state.cleanInsuranceYears or 0)
        state.yearsAtMinimumBonus = xmlFile:getInt(root .. "#yearsAtMinimumBonus", state.yearsAtMinimumBonus or 0)
        state.bonusProtectionAvailable = xmlFile:getBool(root .. "#bonusProtectionAvailable", state.bonusProtectionAvailable == true)
        if xmlFile.iterate ~= nil then
            local policyIndex = 0
            xmlFile:iterate(key .. ".policies.policy", function(_, policyKey)
                policyIndex = policyIndex + 1
                local policy = state.policies[policyIndex]
                if policy ~= nil then policy.referenceMonthlyPremium = xmlFile:getFloat(policyKey .. "#referenceMonthlyPremium", tonumber(policy.referenceMonthlyPremium) or tonumber(policy.monthlyPremium) or 0) end
            end)
            local claimIndex = 0
            xmlFile:iterate(key .. ".claims.claim", function(_, claimKey)
                claimIndex = claimIndex + 1
                local claim = state.claims[claimIndex]
                if claim ~= nil then
                    claim.appliedBonusMalusFactor = xmlFile:getFloat(claimKey .. "#appliedBonusMalusFactor", tonumber(claim.appliedBonusMalusFactor) or 1)
                    claim.bonusProtectionApplied = xmlFile:getBool(claimKey .. "#bonusProtectionApplied", claim.bonusProtectionApplied == true)
                end
            end)
            state.bonusMalusHistory = {}
            xmlFile:iterate(key .. ".bonusMalus.history.entry", function(_, historyKey)
                table.insert(state.bonusMalusHistory, {
                    periodKey = xmlFile:getInt(historyKey .. "#periodKey", 0),
                    kind = xmlFile:getString(historyKey .. "#kind", ""),
                    previousCoefficient = xmlFile:getFloat(historyKey .. "#previousCoefficient", 1),
                    newCoefficient = xmlFile:getFloat(historyKey .. "#newCoefficient", 1),
                    claimId = xmlFile:getString(historyKey .. "#claimId", ""),
                    note = xmlFile:getString(historyKey .. "#note", "")
                })
            end)
        end
    end
    self:sanitize(state)
    self:refreshBonusMalusPremiums(farmId, state.bonusMalus)
    return result
end

if AgriLife.InsuranceModule ~= nil then
    AgriLife.InsuranceModule.VERSION = "0.8.1.0"
    AgriLife.InsuranceModule.SCHEMA_VERSION = 4
    function AgriLife.InsuranceModule:getBonusMalusSnapshot(...) return self.service:getBonusMalusSnapshot(...) end
    local baseDescriptorBonusMalus = AgriLife.InsuranceModule.getDescriptor
    function AgriLife.InsuranceModule.getDescriptor()
        local descriptor = baseDescriptorBonusMalus()
        descriptor.version = "0.8.1.0"
        descriptor.schemaVersion = 4
        return descriptor
    end
end
