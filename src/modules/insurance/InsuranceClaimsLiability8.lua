-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Step 8 accident statements, liability and workshop/insurance settlement bridge.
AgriLife = AgriLife or {}

local Insurance = AgriLife.Insurance6Service
local Workshop = AgriLife.Workshop6Service
if Insurance == nil then return end

Insurance.LIABILITY_STATUS = {
    UNKNOWN = "UNKNOWN",
    NOT_RESPONSIBLE = "NOT_RESPONSIBLE",
    RESPONSIBLE = "RESPONSIBLE",
    SHARED = "SHARED"
}

local function round(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(maximum, value))
end

local function text(value, default)
    value = tostring(value or "")
    if value ~= "" then return value end
    return default or ""
end

local function bool(value)
    return value == true
end

local function upper(value)
    return string.upper(text(value))
end

local function lower(value)
    return string.lower(text(value))
end

local function isAccidentCause(cause)
    local value = lower(cause)
    return value:find("accident", 1, true) ~= nil
        or value:find("collision", 1, true) ~= nil
        or value:find("impact", 1, true) ~= nil
        or value:find("crash", 1, true) ~= nil
        or value:find("technical_accident", 1, true) ~= nil
end

local function normalizedLiability(status, share)
    status = upper(status)
    if status == Insurance.LIABILITY_STATUS.NOT_RESPONSIBLE then return status, 0 end
    if status == Insurance.LIABILITY_STATUS.RESPONSIBLE then return status, 1 end
    if status == Insurance.LIABILITY_STATUS.SHARED then
        share = clamp(share or 0.5, 0.01, 0.99)
        return status, share
    end
    return Insurance.LIABILITY_STATUS.UNKNOWN, 0
end

function Insurance:getClaim(farmId, claimId)
    claimId = tostring(claimId or "")
    for _, claim in ipairs(self:getState(farmId, true).claims or {}) do
        if tostring(claim.id or "") == claimId then return claim end
    end
    return nil
end

function Insurance:getActivePolicyByCategory(farmId, category)
    category = tostring(category or "")
    for _, policy in ipairs(self:getState(farmId, true).policies or {}) do
        if tostring(policy.category or "") == category and tostring(policy.status or "") == "active" then return policy end
    end
    return nil
end

function Insurance:initializeLiabilityClaim(farmId, claim)
    if type(claim) ~= "table" then return claim end
    claim.driverProfileId = text(claim.driverProfileId, claim.responsibleProfileId)
    claim.liabilityStatus, claim.liabilityShare = normalizedLiability(claim.liabilityStatus, claim.liabilityShare)
    claim.liabilityReason = text(claim.liabilityReason)
    claim.liabilitySource = text(claim.liabilitySource)
    claim.accidentId = text(claim.accidentId)
    claim.workshopJobId = text(claim.workshopJobId)
    claim.repairEstimate = math.max(0, tonumber(claim.repairEstimate) or 0)
    claim.repairEstimateFinal = claim.repairEstimateFinal == true
    claim.estimateSource = text(claim.estimateSource, claim.repairEstimate > 0 and "ACCIDENT" or "")
    claim.insurerRepairShare = math.max(0, tonumber(claim.insurerRepairShare) or 0)
    claim.ownerRepairShare = math.max(0, tonumber(claim.ownerRepairShare) or 0)
    claim.thirdPartyPresent = claim.thirdPartyPresent == true
    claim.thirdPartyId = text(claim.thirdPartyId)
    claim.thirdPartyDamageAmount = math.max(0, tonumber(claim.thirdPartyDamageAmount) or 0)
    claim.thirdPartyLiabilityPayout = math.max(0, tonumber(claim.thirdPartyLiabilityPayout) or 0)
    claim.ownerThirdPartyShare = math.max(0, tonumber(claim.ownerThirdPartyShare) or 0)
    claim.liabilityPolicyId = text(claim.liabilityPolicyId)
    claim.recourseAmount = math.max(0, tonumber(claim.recourseAmount) or 0)
    claim.recourseStatus = text(claim.recourseStatus, "NONE")
    claim.liabilityDecisionPeriodKey = math.max(0, math.floor(tonumber(claim.liabilityDecisionPeriodKey) or 0))
    claim.liabilityAppealed = claim.liabilityAppealed == true
    claim.appliedMalusShare = clamp(claim.appliedMalusShare or 0, 0, 1)
    claim.statement = type(claim.statement) == "table" and claim.statement or {}
    claim.statement.circumstanceCode = text(claim.statement.circumstanceCode)
    claim.statement.notes = text(claim.statement.notes)
    claim.statement.impactZone = text(claim.statement.impactZone)
    claim.statement.thirdPartyId = text(claim.statement.thirdPartyId, claim.thirdPartyId)
    claim.statement.photoCount = math.max(0, math.floor(tonumber(claim.statement.photoCount) or 0))
    claim.statement.witnessCount = math.max(0, math.floor(tonumber(claim.statement.witnessCount) or 0))
    claim.statement.playerAdmission = claim.statement.playerAdmission == true
    claim.statement.thirdPartyAdmission = claim.statement.thirdPartyAdmission == true
    claim.statement.officialFaultShare = claim.statement.officialFaultShare ~= nil and clamp(claim.statement.officialFaultShare, 0, 1) or nil
    return claim
end

function Insurance:calculateLiabilityAllocation(farmId, claim)
    claim = self:initializeLiabilityClaim(farmId, claim)
    local status, faultShare = normalizedLiability(claim.liabilityStatus, claim.liabilityShare)
    local estimate = round(math.max(0, tonumber(claim.repairEstimate) or tonumber(claim.damageAmount) or 0))
    local insurerRepair = 0
    local ownerRepair = estimate
    local recourse = 0

    if status == Insurance.LIABILITY_STATUS.NOT_RESPONSIBLE then
        insurerRepair = estimate
        ownerRepair = 0
        recourse = estimate
    elseif status == Insurance.LIABILITY_STATUS.SHARED then
        insurerRepair = round(estimate * (1 - faultShare))
        ownerRepair = round(estimate - insurerRepair)
        recourse = insurerRepair
    elseif status == Insurance.LIABILITY_STATUS.RESPONSIBLE then
        insurerRepair = 0
        ownerRepair = estimate
    end

    local thirdPartyDamage = round(math.max(0, tonumber(claim.thirdPartyDamageAmount) or 0))
    local thirdPartyCovered = 0
    local ownerThirdParty = 0
    local liabilityPolicy = self:getActivePolicyByCategory(farmId, "liability")
    if thirdPartyDamage > 0 and faultShare > 0 then
        local responsibleThirdPartyDamage = round(thirdPartyDamage * faultShare)
        if liabilityPolicy ~= nil then
            thirdPartyCovered = round(responsibleThirdPartyDamage * clamp(liabilityPolicy.coverage or 1, 0, 1))
            ownerThirdParty = round(math.max(0, responsibleThirdPartyDamage - thirdPartyCovered))
            claim.liabilityPolicyId = tostring(liabilityPolicy.id or "")
        else
            ownerThirdParty = responsibleThirdPartyDamage
            claim.liabilityPolicyId = ""
        end
    end

    claim.liabilityStatus = status
    claim.liabilityShare = faultShare
    claim.repairEstimate = estimate
    claim.insurerRepairShare = insurerRepair
    claim.ownerRepairShare = ownerRepair
    claim.thirdPartyLiabilityPayout = thirdPartyCovered
    claim.ownerThirdPartyShare = ownerThirdParty
    claim.recourseAmount = recourse
    if recourse > 0 and claim.thirdPartyPresent then
        claim.recourseStatus = claim.recourseStatus == "RECOVERED" and "RECOVERED" or "PENDING"
    elseif recourse <= 0 then
        claim.recourseStatus = "NONE"
    end

    return {
        status = status,
        faultShare = faultShare,
        repairEstimate = estimate,
        insurerRepairShare = insurerRepair,
        ownerRepairShare = ownerRepair,
        thirdPartyDamageAmount = thirdPartyDamage,
        thirdPartyLiabilityPayout = thirdPartyCovered,
        ownerThirdPartyShare = ownerThirdParty,
        recourseAmount = recourse,
        liabilityPolicyId = claim.liabilityPolicyId
    }
end

function Insurance:applyLiabilityMalus(farmId, claim)
    local state = self:getState(farmId, true)
    local previous = clamp(claim.appliedMalusShare or 0, 0, 1)
    local current = claim.liabilityStatus == Insurance.LIABILITY_STATUS.UNKNOWN and 0 or clamp(claim.liabilityShare or 0, 0, 1)
    local delta = current - previous
    if math.abs(delta) > 0.0001 then
        state.bonusMalus = clamp((tonumber(state.bonusMalus) or 1) + delta * 0.10, 0.60, 1.80)
        claim.appliedMalusShare = current
    end
end

function Insurance:setLiabilityDecision(farmId, claimId, status, faultShare, reason, source)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil then return AgriLife.Result.fail("INSURANCE_LIABILITY_CLAIM_MISSING", "Claim not found") end
    if claim.requiresLiability ~= true then return AgriLife.Result.fail("INSURANCE_LIABILITY_NOT_REQUIRED", "Liability decision is not required for this claim") end
    if claim.status == "paid" and claim.liabilityAppealed ~= true then return AgriLife.Result.fail("INSURANCE_LIABILITY_ALREADY_SETTLED", "Liability cannot be changed after settlement without an appeal") end

    local normalizedStatus, normalizedShare = normalizedLiability(status, faultShare)
    claim.liabilityStatus = normalizedStatus
    claim.liabilityShare = normalizedShare
    claim.liabilityReason = text(reason, normalizedStatus == Insurance.LIABILITY_STATUS.UNKNOWN and "Responsabilité à déterminer" or "Décision issue du constat")
    claim.liabilitySource = text(source, "EXPERTISE")
    claim.liabilityDecisionPeriodKey = normalizedStatus == Insurance.LIABILITY_STATUS.UNKNOWN and 0 or self:getPeriodKey()
    claim.liabilityAppealed = false
    self:calculateLiabilityAllocation(farmId, claim)
    self:applyLiabilityMalus(farmId, claim)
    self:recordEconomy(farmId, "INSURANCE_LIABILITY_DECISION", 0, string.format("%s/%s/%.2f", tostring(claim.id), normalizedStatus, normalizedShare))
    return AgriLife.Result.ok("INSURANCE_LIABILITY_DECIDED", "Accident liability decision recorded", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:submitAccidentStatement(farmId, claimId, statement)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil then return AgriLife.Result.fail("INSURANCE_STATEMENT_CLAIM_MISSING", "Claim not found") end
    statement = type(statement) == "table" and statement or {}
    claim = self:initializeLiabilityClaim(farmId, claim)
    local target = claim.statement
    target.circumstanceCode = text(statement.circumstanceCode, target.circumstanceCode)
    target.notes = text(statement.notes, target.notes)
    target.impactZone = text(statement.impactZone, target.impactZone)
    target.thirdPartyId = text(statement.thirdPartyId, target.thirdPartyId)
    target.photoCount = math.max(target.photoCount or 0, math.floor(tonumber(statement.photoCount) or 0))
    target.witnessCount = math.max(target.witnessCount or 0, math.floor(tonumber(statement.witnessCount) or 0))
    if statement.playerAdmission ~= nil then target.playerAdmission = statement.playerAdmission == true end
    if statement.thirdPartyAdmission ~= nil then target.thirdPartyAdmission = statement.thirdPartyAdmission == true end
    if statement.officialFaultShare ~= nil then target.officialFaultShare = clamp(statement.officialFaultShare, 0, 1) end
    claim.thirdPartyId = text(target.thirdPartyId, claim.thirdPartyId)
    claim.thirdPartyPresent = claim.thirdPartyId ~= "" or statement.thirdPartyPresent == true
    if statement.thirdPartyDamageAmount ~= nil then claim.thirdPartyDamageAmount = round(math.max(0, tonumber(statement.thirdPartyDamageAmount) or 0)) end
    local evidenceBonus = math.min(0.22, (target.photoCount or 0) * 0.025 + (target.witnessCount or 0) * 0.04)
    claim.documentationScore = clamp(math.max(claim.documentationScore or 0.55, 0.55 + evidenceBonus), 0, 1)
    self:calculateLiabilityAllocation(farmId, claim)
    return AgriLife.Result.ok("INSURANCE_STATEMENT_RECORDED", "Accident statement updated", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:requestLiabilityAssessment(farmId, claimId)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil then return AgriLife.Result.fail("INSURANCE_LIABILITY_CLAIM_MISSING", "Claim not found") end
    claim = self:initializeLiabilityClaim(farmId, claim)
    if claim.requiresLiability ~= true then return AgriLife.Result.fail("INSURANCE_LIABILITY_NOT_REQUIRED", "Liability decision is not required for this claim") end
    local statement = claim.statement or {}
    local share = statement.officialFaultShare
    if share ~= nil then
        if share <= 0.001 then return self:setLiabilityDecision(farmId, claim.id, "NOT_RESPONSIBLE", 0, "Responsabilité officielle du tiers", "OFFICIAL_STATEMENT") end
        if share >= 0.999 then return self:setLiabilityDecision(farmId, claim.id, "RESPONSIBLE", 1, "Responsabilité officielle du conducteur AgriLife", "OFFICIAL_STATEMENT") end
        return self:setLiabilityDecision(farmId, claim.id, "SHARED", share, "Responsabilité officiellement partagée", "OFFICIAL_STATEMENT")
    end
    if statement.playerAdmission and not statement.thirdPartyAdmission then
        return self:setLiabilityDecision(farmId, claim.id, "RESPONSIBLE", 1, "Responsabilité reconnue dans le constat", "STATEMENT")
    end
    if statement.thirdPartyAdmission and not statement.playerAdmission then
        return self:setLiabilityDecision(farmId, claim.id, "NOT_RESPONSIBLE", 0, "Responsabilité du tiers reconnue dans le constat", "STATEMENT")
    end
    if statement.playerAdmission and statement.thirdPartyAdmission then
        return self:setLiabilityDecision(farmId, claim.id, "SHARED", 0.5, "Responsabilité partagée selon les déclarations", "STATEMENT")
    end

    local circumstances = upper(statement.circumstanceCode)
    local playerFault = {
        PLAYER_REAR_END = true,
        PLAYER_REVERSED_INTO_THIRD_PARTY = true,
        PLAYER_RIGHT_OF_WAY_VIOLATION = true,
        PLAYER_LOST_CONTROL = true
    }
    local thirdPartyFault = {
        THIRD_PARTY_REAR_END = true,
        THIRD_PARTY_HIT_PARKED_ASSET = true,
        THIRD_PARTY_RIGHT_OF_WAY_VIOLATION = true,
        THIRD_PARTY_REVERSED_INTO_PLAYER = true
    }
    if playerFault[circumstances] then return self:setLiabilityDecision(farmId, claim.id, "RESPONSIBLE", 1, "Circonstances du constat attribuant la responsabilité au conducteur", "STATEMENT_RULES") end
    if thirdPartyFault[circumstances] then return self:setLiabilityDecision(farmId, claim.id, "NOT_RESPONSIBLE", 0, "Circonstances du constat attribuant la responsabilité au tiers", "STATEMENT_RULES") end
    if circumstances == "SHARED_INTERSECTION" or circumstances == "SHARED_MANEUVER" then return self:setLiabilityDecision(farmId, claim.id, "SHARED", 0.5, "Circonstances compatibles avec une responsabilité partagée", "STATEMENT_RULES") end

    claim.liabilityReason = "Constat insuffisant pour attribuer la responsabilité"
    claim.liabilitySource = "PENDING_EVIDENCE"
    return AgriLife.Result.fail("INSURANCE_LIABILITY_UNRESOLVED", "Liability remains undetermined: complete the accident statement", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:appealLiabilityDecision(farmId, claimId)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil or claim.requiresLiability ~= true then return AgriLife.Result.fail("INSURANCE_LIABILITY_APPEAL_INVALID", "Liability appeal is not available") end
    if claim.liabilityStatus == Insurance.LIABILITY_STATUS.UNKNOWN then return AgriLife.Result.fail("INSURANCE_LIABILITY_APPEAL_INVALID", "No liability decision exists yet") end
    claim.liabilityAppealed = true
    claim.status = "expertise"
    claim.liabilityReason = "Contre-expertise de responsabilité demandée"
    claim.liabilitySource = "APPEAL"
    return AgriLife.Result.ok("INSURANCE_LIABILITY_APPEAL_OPEN", "Liability counter-assessment opened", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:linkAccident(farmId, claimId, accident)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil or type(accident) ~= "table" then return AgriLife.Result.fail("INSURANCE_ACCIDENT_LINK_FAILED", "Claim or accident not found") end
    claim.accidentId = text(accident.id, claim.accidentId)
    claim.driverProfileId = text(accident.driverProfileId, text(accident.responsibleProfileId, claim.driverProfileId))
    if tonumber(accident.damageAmount) ~= nil and (claim.repairEstimate or 0) <= 0 then
        claim.repairEstimate = round(math.max(0, tonumber(accident.damageAmount) or 0))
        claim.estimateSource = "ACCIDENT"
        claim.repairEstimateFinal = false
    end
    if accident.thirdPartyId ~= nil then claim.thirdPartyId = text(accident.thirdPartyId) end
    if accident.thirdPartyPresent ~= nil then claim.thirdPartyPresent = accident.thirdPartyPresent == true end
    self:calculateLiabilityAllocation(farmId, claim)
    return AgriLife.Result.ok("INSURANCE_ACCIDENT_LINKED", "Accident linked to claim", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:linkWorkshopEstimate(farmId, claimId, jobId, repairEstimate)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil then return AgriLife.Result.fail("INSURANCE_WORKSHOP_LINK_FAILED", "Claim not found") end
    claim.workshopJobId = text(jobId)
    claim.repairEstimate = round(math.max(0, tonumber(repairEstimate) or tonumber(claim.damageAmount) or 0))
    claim.repairEstimateFinal = true
    claim.estimateSource = "WORKSHOP"
    self:calculateLiabilityAllocation(farmId, claim)
    self:syncWorkshopClaimSettlement(farmId, claim)
    return AgriLife.Result.ok("INSURANCE_WORKSHOP_ESTIMATE_LINKED", "Workshop estimate linked to claim", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:setThirdPartyDamageEstimate(farmId, claimId, amount, thirdPartyId)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil then return AgriLife.Result.fail("INSURANCE_THIRD_PARTY_CLAIM_MISSING", "Claim not found") end
    claim.thirdPartyDamageAmount = round(math.max(0, tonumber(amount) or 0))
    claim.thirdPartyId = text(thirdPartyId, claim.thirdPartyId)
    claim.thirdPartyPresent = claim.thirdPartyDamageAmount > 0 or claim.thirdPartyId ~= ""
    self:calculateLiabilityAllocation(farmId, claim)
    return AgriLife.Result.ok("INSURANCE_THIRD_PARTY_ESTIMATE_SET", "Third-party damage estimate recorded", self:getClaimLiabilitySnapshot(farmId, claim.id))
end

function Insurance:getClaimLiabilitySnapshot(farmId, claimId)
    local claim = type(claimId) == "table" and claimId or self:getClaim(farmId, claimId)
    if claim == nil then return nil end
    claim = self:initializeLiabilityClaim(farmId, claim)
    local allocation = self:calculateLiabilityAllocation(farmId, claim)
    return {
        claimId = claim.id,
        accidentId = claim.accidentId,
        workshopJobId = claim.workshopJobId,
        driverProfileId = claim.driverProfileId,
        liabilityStatus = claim.liabilityStatus,
        liabilityShare = claim.liabilityShare,
        liabilityReason = claim.liabilityReason,
        liabilitySource = claim.liabilitySource,
        repairEstimate = allocation.repairEstimate,
        estimateFinal = claim.repairEstimateFinal,
        insurerRepairShare = allocation.insurerRepairShare,
        ownerRepairShare = allocation.ownerRepairShare,
        thirdPartyPresent = claim.thirdPartyPresent,
        thirdPartyDamageAmount = allocation.thirdPartyDamageAmount,
        thirdPartyLiabilityPayout = allocation.thirdPartyLiabilityPayout,
        ownerThirdPartyShare = allocation.ownerThirdPartyShare,
        recourseAmount = allocation.recourseAmount,
        recourseStatus = claim.recourseStatus,
        claimStatus = claim.status,
        payout = tonumber(claim.payout) or 0,
        documentationScore = tonumber(claim.documentationScore) or 0,
        statement = claim.statement
    }
end

function Insurance:syncWorkshopClaimSettlement(farmId, claim)
    if type(claim) ~= "table" then return end
    local workshopModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.workshop or nil
    local workshop = workshopModule ~= nil and (workshopModule.service or workshopModule) or nil
    if workshop == nil or workshop.getState == nil then return end
    local state = workshop:getState(farmId, true)
    for _, job in ipairs(state.workshopJobs or {}) do
        if tostring(job.id or "") == tostring(claim.workshopJobId or "") or tostring(job.insuranceClaimId or "") == tostring(claim.id or "") then
            job.insuranceClaimId = tostring(claim.id or "")
            job.insuranceCoveredAmount = round(tonumber(claim.payout) or claim.insurerRepairShare or 0)
            job.ownerPayableAmount = round(math.max(0, (tonumber(job.totalCost) or claim.repairEstimate or 0) - job.insuranceCoveredAmount))
            job.liabilityStatus = claim.liabilityStatus
            job.liabilityShare = claim.liabilityShare
            job.claimSettlementStatus = claim.status
            if workshop.addLifeEvent ~= nil then
                workshop:addLifeEvent(farmId, job.assetId, "INSURANCE_SETTLEMENT", string.format("%s:insurance=%.2f:owner=%.2f", tostring(claim.id), job.insuranceCoveredAmount, job.ownerPayableAmount))
            end
        end
    end
end

local baseFileClaim = Insurance.fileClaim
function Insurance:fileClaim(farmId, policyId, damageAmount, cause, responsibleProfileId, assetId)
    local result = baseFileClaim(self, farmId, policyId, damageAmount, cause, responsibleProfileId, assetId)
    if result == nil or not result.ok then return result end
    local claim = self:getClaim(farmId, result.details ~= nil and result.details.claimId or "")
    if claim == nil then return result end
    local policy = self:getPolicy(farmId, policyId)
    claim.driverProfileId = text(responsibleProfileId)
    claim.requiresLiability = policy ~= nil and tostring(policy.category or "") == "vehicle" and isAccidentCause(cause)
    if claim.requiresLiability then
        claim = self:initializeLiabilityClaim(farmId, claim)
        claim.policyExpectedPayout = tonumber(claim.expectedPayout) or 0
        claim.repairEstimate = round(math.max(0, tonumber(damageAmount) or 0))
        claim.repairEstimateFinal = false
        claim.estimateSource = "ACCIDENT"
        claim.expectedPayout = 0
        claim.liabilityStatus = Insurance.LIABILITY_STATUS.UNKNOWN
        claim.liabilityShare = 0
        claim.liabilityReason = "Responsabilité à déterminer à partir du constat"
        claim.liabilitySource = "PENDING_STATEMENT"
        if claim.creationMalusNeutralized ~= true then
            local state = self:getState(farmId, true)
            state.bonusMalus = clamp((tonumber(state.bonusMalus) or 1) - 0.06, 0.60, 1.80)
            claim.creationMalusNeutralized = true
        end
        result.details.expectedPayout = 0
        result.details.liabilityStatus = claim.liabilityStatus
        result.details.liabilityRequired = true
    end
    return result
end

local baseSettleClaim = Insurance.settleClaim
function Insurance:settleClaim(farmId, claimId, expertFactor)
    local claim = self:getClaim(farmId, claimId)
    if claim ~= nil and claim.requiresLiability == true then
        if claim.liabilityStatus == Insurance.LIABILITY_STATUS.UNKNOWN then return AgriLife.Result.fail("INSURANCE_LIABILITY_PENDING", "Liability must be decided before settlement", self:getClaimLiabilitySnapshot(farmId, claim.id)) end
        self:calculateLiabilityAllocation(farmId, claim)
        claim.expectedPayout = round(claim.insurerRepairShare or 0)
    end
    local result = baseSettleClaim(self, farmId, claimId, expertFactor)
    claim = self:getClaim(farmId, claimId)
    if claim ~= nil and claim.requiresLiability == true then
        self:syncWorkshopClaimSettlement(farmId, claim)
        if claim.recourseAmount > 0 and claim.thirdPartyPresent then claim.recourseStatus = "PENDING" end
    end
    return result
end

local baseAssessClaim = Insurance.assessClaim
function Insurance:assessClaim(farmId, claimId)
    local claim = self:getClaim(farmId, claimId)
    if claim == nil or claim.requiresLiability ~= true then return baseAssessClaim(self, farmId, claimId) end
    claim = self:initializeLiabilityClaim(farmId, claim)
    if claim.status == "payment_pending" then return self:settleClaim(farmId, claim.id, 1) end
    if claim.liabilityStatus == Insurance.LIABILITY_STATUS.UNKNOWN then return AgriLife.Result.fail("INSURANCE_LIABILITY_PENDING", "Responsibility is still undetermined", self:getClaimLiabilitySnapshot(farmId, claim.id)) end
    if not claim.repairEstimateFinal then return AgriLife.Result.fail("INSURANCE_WORKSHOP_ESTIMATE_PENDING", "A final workshop estimate is required before the insurer settles the repair", self:getClaimLiabilitySnapshot(farmId, claim.id)) end

    local policy = self:getPolicy(farmId, claim.policyId)
    local rejected = false
    local reason = "Décision assurance conforme au constat"
    if policy == nil or tostring(policy.status or "") ~= "active" or (tonumber(policy.missedPremiums) or 0) >= 2 then
        rejected = true
        reason = "Refus : contrat véhicule non valide au moment du sinistre"
    elseif clamp(claim.documentationScore or 0.55, 0, 1) < 0.60 then
        rejected = true
        reason = "Refus : constat et justificatifs insuffisants"
    end

    self:calculateLiabilityAllocation(farmId, claim)
    if rejected then claim.expectedPayout = 0 else claim.expectedPayout = round(claim.insurerRepairShare or 0) end
    if not rejected and claim.liabilityStatus == Insurance.LIABILITY_STATUS.RESPONSIBLE then
        reason = "Conducteur responsable : réparations propres à la charge de l'exploitation"
    elseif not rejected and claim.liabilityStatus == Insurance.LIABILITY_STATUS.NOT_RESPONSIBLE then
        reason = "Conducteur non responsable : réparations prises en charge par l'assurance avec recours contre le tiers"
    elseif not rejected and claim.liabilityStatus == Insurance.LIABILITY_STATUS.SHARED then
        reason = string.format("Responsabilité partagée : %.0f%% à charge exploitation, %.0f%% pris en charge", (claim.liabilityShare or 0) * 100, (1 - (claim.liabilityShare or 0)) * 100)
    end

    local result = self:settleClaim(farmId, claim.id, 1)
    claim.assessmentReason = reason
    if result ~= nil and result.details ~= nil then
        result.details.assessmentReason = reason
        result.details.liability = self:getClaimLiabilitySnapshot(farmId, claim.id)
    end
    return result
end

local baseAppealClaim = Insurance.appealClaim
function Insurance:appealClaim(farmId, claimId)
    local claim = self:getClaim(farmId, claimId)
    if claim ~= nil and claim.requiresLiability == true and claim.liabilityStatus ~= Insurance.LIABILITY_STATUS.UNKNOWN then
        return self:appealLiabilityDecision(farmId, claimId)
    end
    return baseAppealClaim(self, farmId, claimId)
end

local baseSanitize = Insurance.sanitize
function Insurance:sanitize(state)
    state = baseSanitize(self, state)
    for _, claim in ipairs(state.claims or {}) do
        self:initializeLiabilityClaim(0, claim)
        if claim.requiresLiability == nil then claim.requiresLiability = tostring(claim.category or "") == "vehicle" and isAccidentCause(claim.cause) end
    end
    return state
end

local baseSaveFarm = Insurance.saveFarm
function Insurance:saveFarm(xmlFile, key, farmId)
    local result = baseSaveFarm(self, xmlFile, key, farmId)
    local state = self:getState(farmId, true)
    for index, claim in ipairs(state.claims or {}) do
        claim = self:initializeLiabilityClaim(farmId, claim)
        local claimKey = string.format("%s.claims.claim(%d)", key, index - 1)
        for _, field in ipairs({"driverProfileId", "liabilityStatus", "liabilityReason", "liabilitySource", "accidentId", "workshopJobId", "estimateSource", "recourseStatus", "liabilityPolicyId", "thirdPartyId"}) do
            xmlFile:setString(claimKey .. "#" .. field, text(claim[field]))
        end
        for _, field in ipairs({"liabilityShare", "repairEstimate", "policyExpectedPayout", "insurerRepairShare", "ownerRepairShare", "thirdPartyDamageAmount", "thirdPartyLiabilityPayout", "ownerThirdPartyShare", "recourseAmount", "appliedMalusShare"}) do
            xmlFile:setFloat(claimKey .. "#" .. field, tonumber(claim[field]) or 0)
        end
        xmlFile:setInt(claimKey .. "#liabilityDecisionPeriodKey", claim.liabilityDecisionPeriodKey or 0)
        xmlFile:setBool(claimKey .. "#requiresLiability", claim.requiresLiability == true)
        xmlFile:setBool(claimKey .. "#repairEstimateFinal", claim.repairEstimateFinal == true)
        xmlFile:setBool(claimKey .. "#creationMalusNeutralized", claim.creationMalusNeutralized == true)
        xmlFile:setBool(claimKey .. "#thirdPartyPresent", claim.thirdPartyPresent == true)
        xmlFile:setBool(claimKey .. "#liabilityAppealed", claim.liabilityAppealed == true)
        local statement = claim.statement or {}
        xmlFile:setString(claimKey .. "#statementCircumstanceCode", text(statement.circumstanceCode))
        xmlFile:setString(claimKey .. "#statementNotes", text(statement.notes))
        xmlFile:setString(claimKey .. "#statementImpactZone", text(statement.impactZone))
        xmlFile:setString(claimKey .. "#statementThirdPartyId", text(statement.thirdPartyId))
        xmlFile:setInt(claimKey .. "#statementPhotoCount", statement.photoCount or 0)
        xmlFile:setInt(claimKey .. "#statementWitnessCount", statement.witnessCount or 0)
        xmlFile:setBool(claimKey .. "#statementPlayerAdmission", statement.playerAdmission == true)
        xmlFile:setBool(claimKey .. "#statementThirdPartyAdmission", statement.thirdPartyAdmission == true)
        if statement.officialFaultShare ~= nil then xmlFile:setFloat(claimKey .. "#statementOfficialFaultShare", statement.officialFaultShare) end
    end
    return result
end

local baseLoadFarm = Insurance.loadFarm
function Insurance:loadFarm(xmlFile, key, farmId)
    local result = baseLoadFarm(self, xmlFile, key, farmId)
    local state = self:getState(farmId, true)
    if xmlFile ~= nil and xmlFile.iterate ~= nil then
        local index = 0
        xmlFile:iterate(key .. ".claims.claim", function(_, claimKey)
            index = index + 1
            local claim = state.claims[index]
            if claim ~= nil then
                for _, field in ipairs({"driverProfileId", "liabilityStatus", "liabilityReason", "liabilitySource", "accidentId", "workshopJobId", "estimateSource", "recourseStatus", "liabilityPolicyId", "thirdPartyId"}) do claim[field] = xmlFile:getString(claimKey .. "#" .. field, text(claim[field])) end
                for _, field in ipairs({"liabilityShare", "repairEstimate", "policyExpectedPayout", "insurerRepairShare", "ownerRepairShare", "thirdPartyDamageAmount", "thirdPartyLiabilityPayout", "ownerThirdPartyShare", "recourseAmount", "appliedMalusShare"}) do claim[field] = xmlFile:getFloat(claimKey .. "#" .. field, tonumber(claim[field]) or 0) end
                claim.liabilityDecisionPeriodKey = xmlFile:getInt(claimKey .. "#liabilityDecisionPeriodKey", claim.liabilityDecisionPeriodKey or 0)
                claim.requiresLiability = xmlFile:getBool(claimKey .. "#requiresLiability", claim.requiresLiability == true)
                claim.repairEstimateFinal = xmlFile:getBool(claimKey .. "#repairEstimateFinal", claim.repairEstimateFinal == true)
                claim.creationMalusNeutralized = xmlFile:getBool(claimKey .. "#creationMalusNeutralized", claim.creationMalusNeutralized == true)
                claim.thirdPartyPresent = xmlFile:getBool(claimKey .. "#thirdPartyPresent", claim.thirdPartyPresent == true)
                claim.liabilityAppealed = xmlFile:getBool(claimKey .. "#liabilityAppealed", claim.liabilityAppealed == true)
                local statement = claim.statement or {}
                statement.circumstanceCode = xmlFile:getString(claimKey .. "#statementCircumstanceCode", text(statement.circumstanceCode))
                statement.notes = xmlFile:getString(claimKey .. "#statementNotes", text(statement.notes))
                statement.impactZone = xmlFile:getString(claimKey .. "#statementImpactZone", text(statement.impactZone))
                statement.thirdPartyId = xmlFile:getString(claimKey .. "#statementThirdPartyId", text(statement.thirdPartyId))
                statement.photoCount = xmlFile:getInt(claimKey .. "#statementPhotoCount", statement.photoCount or 0)
                statement.witnessCount = xmlFile:getInt(claimKey .. "#statementWitnessCount", statement.witnessCount or 0)
                statement.playerAdmission = xmlFile:getBool(claimKey .. "#statementPlayerAdmission", statement.playerAdmission == true)
                statement.thirdPartyAdmission = xmlFile:getBool(claimKey .. "#statementThirdPartyAdmission", statement.thirdPartyAdmission == true)
                local official = xmlFile:getFloat(claimKey .. "#statementOfficialFaultShare", -1)
                statement.officialFaultShare = official >= 0 and clamp(official, 0, 1) or nil
                claim.statement = statement
                self:initializeLiabilityClaim(farmId, claim)
                self:calculateLiabilityAllocation(farmId, claim)
            end
        end)
    end
    return result
end

if Workshop ~= nil then
    function Workshop:findAccident(farmId, accidentId)
        for _, accident in ipairs(self:getState(farmId, true).accidents or {}) do if tostring(accident.id or "") == tostring(accidentId or "") then return accident end end
        return nil
    end

    function Workshop:getLatestAccidentForAsset(farmId, assetId)
        local list = self:getState(farmId, true).accidents or {}
        for index = #list, 1, -1 do if tostring(list[index].assetId or "") == tostring(assetId or "") then return list[index] end end
        return nil
    end

    function Workshop:getAccidentLiabilitySnapshot(farmId, accidentId)
        local accident = self:findAccident(farmId, accidentId)
        if accident == nil then return nil end
        local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
        local claim = service ~= nil and service.getClaimLiabilitySnapshot ~= nil and service:getClaimLiabilitySnapshot(farmId, accident.claimId) or nil
        return {accident = accident, claim = claim}
    end

    function Workshop:submitAccidentStatement(farmId, accidentId, statement)
        local accident = self:findAccident(farmId, accidentId)
        if accident == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_MISSING", "Accident not found") end
        local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
        if service == nil then return AgriLife.Result.fail("WORKSHOP_INSURANCE_UNAVAILABLE", "Insurance service unavailable") end
        if tostring(accident.claimId or "") == "" then
            local policy = service:findPolicyForAsset(farmId, "vehicle", accident.assetId)
            if policy == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_POLICY_MISSING", "No active vehicle policy for this accident") end
            local claimResult = service:fileClaim(farmId, policy.id, accident.damageAmount, accident.cause, accident.driverProfileId or accident.responsibleProfileId, accident.assetId)
            if claimResult == nil or not claimResult.ok then return claimResult end
            accident.claimId = claimResult.details.claimId
            service:linkAccident(farmId, accident.claimId, accident)
        end
        local result = service:submitAccidentStatement(farmId, accident.claimId, statement)
        if result ~= nil and result.ok then
            local claim = result.details
            accident.liabilityStatus = claim.liabilityStatus
            accident.liabilityShare = claim.liabilityShare
            accident.thirdPartyId = claim.statement ~= nil and claim.statement.thirdPartyId or accident.thirdPartyId
            accident.thirdPartyPresent = claim.thirdPartyPresent
            accident.statementStatus = "SUBMITTED"
        end
        return result
    end

    function Workshop:assessAccidentLiability(farmId, accidentId)
        local accident = self:findAccident(farmId, accidentId)
        if accident == nil or tostring(accident.claimId or "") == "" then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_CLAIM_MISSING", "Accident has no insurance claim") end
        local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
        local result = service ~= nil and service.requestLiabilityAssessment ~= nil and service:requestLiabilityAssessment(farmId, accident.claimId) or nil
        if result ~= nil and result.ok then accident.liabilityStatus = result.details.liabilityStatus; accident.liabilityShare = result.details.liabilityShare end
        return result or AgriLife.Result.fail("WORKSHOP_INSURANCE_UNAVAILABLE", "Insurance liability service unavailable")
    end

    function Workshop:setAccidentLiabilityDecision(farmId, accidentId, status, share, reason, source)
        local accident = self:findAccident(farmId, accidentId)
        if accident == nil or tostring(accident.claimId or "") == "" then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_CLAIM_MISSING", "Accident has no insurance claim") end
        local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
        local result = service ~= nil and service.setLiabilityDecision ~= nil and service:setLiabilityDecision(farmId, accident.claimId, status, share, reason, source) or nil
        if result ~= nil and result.ok then accident.liabilityStatus = result.details.liabilityStatus; accident.liabilityShare = result.details.liabilityShare end
        return result or AgriLife.Result.fail("WORKSHOP_INSURANCE_UNAVAILABLE", "Insurance liability service unavailable")
    end

    local baseReportAccidentLiability = Workshop.reportAccident
    function Workshop:reportAccident(farmId, assetId, damageAmount, responsibleProfileId, cause)
        local result = baseReportAccidentLiability(self, farmId, assetId, damageAmount, responsibleProfileId, cause)
        if result ~= nil and result.ok then
            local accident = self:findAccident(farmId, result.details ~= nil and result.details.accidentId or "")
            if accident ~= nil then
                accident.driverProfileId = text(responsibleProfileId)
                accident.liabilityStatus = Insurance.LIABILITY_STATUS.UNKNOWN
                accident.liabilityShare = 0
                accident.statementStatus = "PENDING"
                local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
                local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
                if service ~= nil and tostring(accident.claimId or "") ~= "" and service.linkAccident ~= nil then service:linkAccident(farmId, accident.claimId, accident) end
            end
        end
        return result
    end

    local baseCreateWorkshopJobLiability = Workshop.createWorkshopJob
    function Workshop:createWorkshopJob(farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        local result = baseCreateWorkshopJobLiability(self, farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        if result ~= nil and result.ok and kind == "REPAIR" and result.details ~= nil and result.details.job ~= nil then
            local job = result.details.job
            local accident = self:getLatestAccidentForAsset(farmId, assetId)
            if accident ~= nil and tostring(accident.claimId or "") ~= "" then
                local insuranceModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
                local service = insuranceModule ~= nil and (insuranceModule.service or insuranceModule) or nil
                if service ~= nil and service.linkWorkshopEstimate ~= nil then
                    job.insuranceClaimId = accident.claimId
                    service:linkWorkshopEstimate(farmId, accident.claimId, job.id, job.totalCost)
                    local claim = service:getClaim(farmId, accident.claimId)
                    if claim ~= nil and claim.liabilityStatus ~= Insurance.LIABILITY_STATUS.UNKNOWN and service.assessClaim ~= nil then service:assessClaim(farmId, accident.claimId) end
                end
            end
        end
        return result
    end

    local baseSaveWorkshopLiability = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, key, farmId)
        local result = baseSaveWorkshopLiability(self, xmlFile, key, farmId)
        local state = self:getState(farmId, true)
        for index, accident in ipairs(state.accidents or {}) do
            local accidentKey = string.format("%s.accidents.accident(%d)", key, index - 1)
            for _, field in ipairs({"driverProfileId", "liabilityStatus", "statementStatus", "thirdPartyId"}) do xmlFile:setString(accidentKey .. "#" .. field, text(accident[field])) end
            xmlFile:setFloat(accidentKey .. "#liabilityShare", tonumber(accident.liabilityShare) or 0)
            xmlFile:setBool(accidentKey .. "#thirdPartyPresent", accident.thirdPartyPresent == true)
        end
        for index, job in ipairs(state.workshopJobs or {}) do
            local jobKey = string.format("%s.roadmap8.jobs.job(%d)", key, index - 1)
            for _, field in ipairs({"liabilityStatus", "claimSettlementStatus"}) do xmlFile:setString(jobKey .. "#" .. field, text(job[field])) end
            for _, field in ipairs({"liabilityShare", "insuranceCoveredAmount", "ownerPayableAmount"}) do xmlFile:setFloat(jobKey .. "#" .. field, tonumber(job[field]) or 0) end
        end
        return result
    end

    local baseLoadWorkshopLiability = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, key, farmId)
        local result = baseLoadWorkshopLiability(self, xmlFile, key, farmId)
        local state = self:getState(farmId, true)
        if xmlFile ~= nil and xmlFile.iterate ~= nil then
            local accidentIndex = 0
            xmlFile:iterate(key .. ".accidents.accident", function(_, accidentKey)
                accidentIndex = accidentIndex + 1
                local accident = state.accidents[accidentIndex]
                if accident ~= nil then
                    accident.driverProfileId = xmlFile:getString(accidentKey .. "#driverProfileId", text(accident.driverProfileId, accident.responsibleProfileId))
                    accident.liabilityStatus = xmlFile:getString(accidentKey .. "#liabilityStatus", Insurance.LIABILITY_STATUS.UNKNOWN)
                    accident.statementStatus = xmlFile:getString(accidentKey .. "#statementStatus", "PENDING")
                    accident.thirdPartyId = xmlFile:getString(accidentKey .. "#thirdPartyId", "")
                    accident.liabilityShare = xmlFile:getFloat(accidentKey .. "#liabilityShare", 0)
                    accident.thirdPartyPresent = xmlFile:getBool(accidentKey .. "#thirdPartyPresent", false)
                end
            end)
            local jobIndex = 0
            xmlFile:iterate(key .. ".roadmap8.jobs.job", function(_, jobKey)
                jobIndex = jobIndex + 1
                local job = state.workshopJobs ~= nil and state.workshopJobs[jobIndex] or nil
                if job ~= nil then
                    job.liabilityStatus = xmlFile:getString(jobKey .. "#liabilityStatus", "")
                    job.claimSettlementStatus = xmlFile:getString(jobKey .. "#claimSettlementStatus", "")
                    job.liabilityShare = xmlFile:getFloat(jobKey .. "#liabilityShare", 0)
                    job.insuranceCoveredAmount = xmlFile:getFloat(jobKey .. "#insuranceCoveredAmount", 0)
                    job.ownerPayableAmount = xmlFile:getFloat(jobKey .. "#ownerPayableAmount", tonumber(job.totalCost) or 0)
                end
            end)
        end
        return result
    end
end

if AgriLife.InsuranceModule ~= nil then
    AgriLife.InsuranceModule.VERSION = "0.8.1.0"
    AgriLife.InsuranceModule.SCHEMA_VERSION = 3
    function AgriLife.InsuranceModule:getClaim(...) return self.service:getClaim(...) end
    function AgriLife.InsuranceModule:getClaimLiabilitySnapshot(...) return self.service:getClaimLiabilitySnapshot(...) end
    function AgriLife.InsuranceModule:submitAccidentStatement(...) return self.service:submitAccidentStatement(...) end
    function AgriLife.InsuranceModule:requestLiabilityAssessment(...) return self.service:requestLiabilityAssessment(...) end
    function AgriLife.InsuranceModule:setLiabilityDecision(...) return self.service:setLiabilityDecision(...) end
    function AgriLife.InsuranceModule:appealLiabilityDecision(...) return self.service:appealLiabilityDecision(...) end
    function AgriLife.InsuranceModule:linkWorkshopEstimate(...) return self.service:linkWorkshopEstimate(...) end
    function AgriLife.InsuranceModule:setThirdPartyDamageEstimate(...) return self.service:setThirdPartyDamageEstimate(...) end
    local baseDescriptor = AgriLife.InsuranceModule.getDescriptor
    function AgriLife.InsuranceModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.8.1.0"
        descriptor.schemaVersion = 3
        return descriptor
    end
end

if AgriLife.WorkshopModule ~= nil then
    AgriLife.WorkshopModule.VERSION = "0.8.1.0"
    AgriLife.WorkshopModule.SCHEMA_VERSION = 3
    function AgriLife.WorkshopModule:submitAccidentStatement(...) return self.service:submitAccidentStatement(...) end
    function AgriLife.WorkshopModule:assessAccidentLiability(...) return self.service:assessAccidentLiability(...) end
    function AgriLife.WorkshopModule:setAccidentLiabilityDecision(...) return self.service:setAccidentLiabilityDecision(...) end
    function AgriLife.WorkshopModule:getAccidentLiabilitySnapshot(...) return self.service:getAccidentLiabilitySnapshot(...) end
    local baseDescriptor = AgriLife.WorkshopModule.getDescriptor
    function AgriLife.WorkshopModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.8.1.0"
        descriptor.schemaVersion = 3
        return descriptor
    end
end
