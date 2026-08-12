-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - 0.9.2.0 Workshop / Insurance integration.
AgriLife = AgriLife or {}

local Insurance = AgriLife.Insurance6Service
local Workshop = AgriLife.Workshop6Service
if Insurance == nil then return end

Insurance.WORKSHOP_COMPLETION_VERSION = "0.9.2.0"
Insurance.WORKSHOP_TIER_RULES = {
    basic    = {mechanicalCoverage=0.00, assistanceCoverage=0.50, assistanceCap=500,  assistanceDeductible=100},
    standard = {mechanicalCoverage=0.60, assistanceCoverage=0.75, assistanceCap=1200, assistanceDeductible=50},
    premium  = {mechanicalCoverage=0.85, assistanceCoverage=1.00, assistanceCap=2500, assistanceDeductible=0}
}

local function round(value) return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100 end
local function claqp(value, minimum, maximum) return math.max(minimum, math.min(maximum, tonumber(value) or minimum)) end
local function upper(value) return string.upper(tostring(value or "")) end
local function tr(key)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, value = pcall(g_i18n.getText, g_i18n, key)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
    return tostring(key or "")
end

function Insurance:getWorkshopTierRules(policy)
    if policy == nil then return Insurance.WORKSHOP_TIER_RULES.basic end
    return Insurance.WORKSHOP_TIER_RULES[tostring(policy.tierId or "standard")] or Insurance.WORKSHOP_TIER_RULES.standard
end

function Insurance:getWorkshopService()
    if Workshop == nil then return nil end
    local module = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.workshop or nil
    return module ~= nil and (module.service or module) or Workshop
end

function Insurance:classifyWorkshopIncident(farmId, assetId, job)
    local workshop = self:getWorkshopService()
    local vehicle = workshop ~= nil and workshop.findVehicle ~= nil and workshop:findVehicle(farmId, assetId) or nil
    if vehicle == nil then return {class="UNKNOWN", eligible=false, reason="asset_missing", faults={}} end

    local period = workshop.getPeriodKey ~= nil and workshop:getPeriodKey() or self:getPeriodKey()
    local activeFaults = workshop.getActiveFaults ~= nil and workshop:getActiveFaults(vehicle) or (vehicle.faults or {})
    local relevant = {}
    local hasAccident, hasWarranty, hasIgnoredWarning, hasSuddenSevere = false, false, false, false
    local hasWear = false

    for _, fault in ipairs(activeFaults or {}) do
        if tostring(fault.status or "active") ~= "repaired" then
            local cause = upper(fault.cause or fault.source)
            local stage = math.max(1, math.floor(tonumber(fault.stage) or 1))
            local effect = workshop.getFaultEffect ~= nil and workshop:getFaultEffect(fault) or {}
            local severe = stage >= 3 or effect.stopEngine == true or effect.lockStart == true or effect.immobilize == true or effect.safetyCritical == true
            table.insert(relevant, {recordId=fault.recordId, id=fault.id, partFamily=fault.partFamily, cause=cause, stage=stage, severe=severe})
            if cause:find("ACCIDENT", 1, true) ~= nil or cause:find("COLLISION", 1, true) ~= nil or cause:find("IMPACT", 1, true) ~= nil then hasAccident = true end
            if workshop.getWarrantyCoverage ~= nil and tostring(fault.partFamily or "") ~= "" and workshop:getWarrantyCoverage(farmId, assetId, fault.partFamily) ~= nil then hasWarranty = true end
            if fault.detected == true and severe and (tonumber(fault.createdPeriodKey) or period) < period then hasIgnoredWarning = true end
            if severe and (tonumber(fault.createdPeriodKey) or period) >= period then hasSuddenSevere = true end
            if cause == "WEAR" or cause == "AGRILIFE" or cause == "" then hasWear = true end
        end
    end

    local overdue = vehicle.annualReviewOverdue == true or vehicle.technicalInspectionOverdue == true
    local class = "WEAR"
    local reason = "normal_wear"
    if hasAccident then class, reason = "ACCIDENT", "accident"
    elseif hasWarranty then class, reason = "WARRANTY", "active_warranty"
    elseif overdue then class, reason = "NEGLIGENCE", "maintenance_overdue"
    elseif hasIgnoredWarning then class, reason = "IGNORED_WARNING", "known_fault_ignored"
    elseif hasSuddenSevere then class, reason = "SUDDEN_BREAKDOWN", "sudden_mechanical_failure"
    elseif hasWear then class, reason = "WEAR", "normal_wear"
    else class, reason = "SUDDEN_BREAKDOWN", "mechanical_failure" end

    return {class=class, reason=reason, vehicle=vehicle, faults=relevant, maintenanceOverdue=overdue}
end

function Insurance:getWorkshopEligibleExpense(farmId, assetId, job)
    if type(job) ~= "table" then return 0, {provider="", parts=0, labor=0, delivery=0} end
    local provider = upper(job.provider)
    local parts = math.max(0, tonumber(job.partsCost) or 0)
    local labor = math.max(0, tonumber(job.laborCost) or 0)
    local delivery = math.max(0, tonumber(job.deliveryCost) or 0)
    local eligible = provider == "INTERNAL" and (parts + delivery) or (parts + labor + delivery)
    -- Recovery is settled by the separate assistance guarantee, never as repair labour.
    if upper(job.kind) == "RECOVERY" then eligible = 0 end
    return round(eligible), {provider=provider, parts=round(parts), labor=provider == "INTERNAL" and 0 or round(labor), delivery=round(delivery), internalLaborExcluded=provider == "INTERNAL"}
end

function Insurance:getWorkshopRepairCoverage(farmId, assetId, job)
    local policy = self:findPolicyForAsset(farmId, "vehicle", assetId)
    local incident = self:classifyWorkshopIncident(farmId, assetId, job)
    local eligibleExpense, breakdown = self:getWorkshopEligibleExpense(farmId, assetId, job)
    if policy == nil then return {eligible=false, reason="no_policy", incident=incident, eligibleExpense=eligibleExpense, expense=breakdown} end
    if eligibleExpense < 100 then return {eligible=false, reason="expense_too_low", policyId=policy.id, incident=incident, eligibleExpense=eligibleExpense, expense=breakdown} end

    local rules = self:getWorkshopTierRules(policy)
    local factor = 0
    local reason = incident.reason
    if incident.class == "ACCIDENT" then factor = 1
    elseif incident.class == "SUDDEN_BREAKDOWN" then factor = clamp(rules.mechanicalCoverage or 0, 0, 1)
    elseif incident.class == "WARRANTY" then reason = "warranty_precedes_insurance"
    elseif incident.class == "NEGLIGENCE" then reason = "maintenance_negligence"
    elseif incident.class == "IGNORED_WARNING" then reason = "ignored_warning"
    else reason = "wear_excluded" end

    local policyCovered = math.max(0, math.min(tonumber(policy.insuredValue) or eligibleExpense, eligibleExpense) * (tonumber(policy.coverage) or 0))
    local deductible = math.max(100, math.min(eligibleExpense, eligibleExpense * (tonumber(policy.deductible) or 0)))
    local estimated = round(math.max(0, policyCovered - deductible) * factor)
    estimated = math.min(estimated, eligibleExpense)
    return {
        eligible=factor > 0 and estimated > 0,
        reason=reason,
        policyId=policy.id,
        tierId=policy.tierId,
        incident=incident,
        coverageFactor=factor,
        policyCoverage=tonumber(policy.coverage) or 0,
        deductible=round(deductible),
        eligibleExpense=eligibleExpense,
        estimatedPayout=estimated,
        ownerRemainder=round(math.max(0, eligibleExpense-estimated)),
        expense=breakdown
    }
end

function Insurance:fileWorkshopRepairClaim(farmId, job)
    if type(job) ~= "table" then return AgriLife.Result.fail("INSURANCE_WORKSHOP_JOB_MISSING", tr("agrilife_workshop81_insurance_job_missing")) end
    local coverage = self:getWorkshopRepairCoverage(farmId, job.assetId, job)
    if coverage.eligible ~= true then return AgriLife.Result.fail("INSURANCE_WORKSHOP_NOT_COVERED", tr("agrilife_workshop81_insurance_not_covered"), coverage) end
    local cause = coverage.incident.class == "ACCIDENT" and "technical_accident_repair" or "mechanical_breakdown"
    local result = self:fileClaim(farmId, coverage.policyId, coverage.eligibleExpense, cause, "", job.assetId)
    if result == nil or result.ok ~= true then return result end
    local claim = self.getClaim ~= nil and self:getClaim(farmId, result.details ~= nil and result.details.claimId or "") or nil
    if claim ~= nil then
        claim.workshopJobId = tostring(job.id or "")
        claim.workshopIncidentClass = coverage.incident.class
        claim.workshopEligibleExpense = coverage.eligibleExpense
        claim.workshopCoverageFactor = coverage.coverageFactor
        claim.workshopOwnerRemainder = coverage.ownerRemainder
        claim.workshopProvider = upper(job.provider)
        claim.workshopExpenseParts = coverage.expense.parts
        claim.workshopExpenseLabor = coverage.expense.labor
        claim.workshopExpenseDelivery = coverage.expense.delivery
        if coverage.incident.class ~= "ACCIDENT" then
            claim.expectedPayout = round(math.min(coverage.eligibleExpense, coverage.estimatedPayout))
        end
    end
    if result.details ~= nil then
        result.details.expectedPayout = claim ~= nil and claim.expectedPayout or coverage.estimatedPayout
        result.details.eligibleExpense = coverage.eligibleExpense
        result.details.incidentClass = coverage.incident.class
        result.details.ownerRemainder = coverage.ownerRemainder
    end
    return result
end

function Insurance:settleWorkshopAssistance(farmId, assetId, incurredCost, jobId)
    incurredCost = round(math.max(0, tonumber(incurredCost) or 0))
    local policy = self:findPolicyForAsset(farmId, "vehicle", assetId)
    if policy == nil or incurredCost <= 0 then return AgriLife.Result.ok("INSURANCE_ASSISTANCE_NONE", tr("agrilife_workshop81_assistance_not_covered"), {payout=0, remainder=incurredCost}) end
    local rules = self:getWorkshopTierRules(policy)
    local coveredBase = math.min incurredCost, math.max(0, tonumber(rules.assistanceCap) or 0))
    local gross = coveredBase * clamp(rules.assistanceCoverage or 0, 0, 1)
    local payout = round(math.max(0, gross - math.max(0, tonumber(rules.assistanceDeductible) or 0)))
    payout = math.min(payout, incurredCost)
    if payout <= 0 then return AgriLife.Result.ok("INSURANCE_ASSISTANCE_NONE", tr("agrilife_workshop81_assistance_not_covered"), {policyId=policy.id,payout=0,remainder=incurredCost}) end
    if not self:addMoney(farmId, payout) then return AgriLife.Result.fail("INSURANCE_ASSISTANCE_PAYMENT_FAILED", tr("agrilife_workshop81_assistance_payment_failed"), {policyId=policy.id,payout=payout}) end
    local state = self:getState(farmId, true)
    state.totalPayouts = round((tonumber(state.totalPayouts) or 0) + payout)
    self:recordEconomy(farmId, "INSURANCE_ASSISTANCE_PAYOUT", payout, tostring(jobId or assetId))
    return AgriLife.Result.ok("INSURANCE_ASSISTANCE_PAID", tr("agrilife_workshop81_assistance_paid"), {policyId=policy.id,payout=payout,remainder=round(math.max(0,incurredCost-payout)),tierId=policy.tierId})
end

-- Persist Workshop-specific claim accounting without replacing the existing claims/liability schema.
local baseSaveWorkshopInsurance = Insurance.saveFarm
function Insurance:saveFarm(xmlFile, moduleKey, farmId)
    local result = baseSaveWorkshopInsurance(self, xmlFile, moduleKey, farmId)
    local state = self:getState(farmId, true)
    for index, claim in ipairs(state.claims or {}) do
        local key = string.format("%s.claims.claim(%d)", moduleKey, index-1)
        for _, name in ipairs({"workshopJobId","workshopIncidentClass","workshopProvider"}) do xmlFile:setString(key.."#"..name, tostring(claim[name] or "")) end
        for _, name in ipairs({"workshopEligibleExpense","workshopCoverageFactor","workshopOwnerRemainder","workshopExpenseParts","workshopExpenseLabor","workshopExpenseDelivery"}) do xmlFile:setFloat(key.."#"..name, tonumber(claim[name]) or 0) end
    end
    return result
end

local baseLoadWorkshopInsurance = Insurance.loadFarm
function Insurance:loadFarm(xmlFile, moduleKey, farmId)
    local result = baseLoadWorkshopInsurance(self, xmlFile, moduleKey, farmId)
    local state = self:getState(farmId, true)
    if xmlFile ~= nil and xmlFile.iterate ~= nil then
        local index = 0
        xmlFile:iterate(moduleKey..".claims.claim", function(_, key)
            index = index + 1
            local claim = state.claims[index]
            if claim ~= nil then
                claim.workshopJobId = xmlFile:getString(key.."#workshopJobId", "")
                claim.workshopIncidentClass = xmlFile:getString(key.."#workshopIncidentClass", "")
                claim.workshopProvider = xmlFile:getString(key.."#workshopProvider", "")
                for _, name in ipairs({"workshopEligibleExpense","workshopCoverageFactor","workshopOwnerRemainder","workshopExpenseParts","workshopExpenseLabor","workshopExpenseDelivery"}) do claim[name]=xmlFile:getFloat(key.."#"..name, 0) end
            end
        end)
    end
    return result
end

if Workshop ~= nil then
    function Workshop:getInsuranceRepairCoverage(farmId, assetId, job)
        local insurance = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insurance ~= nil and (insurance.service or insurance) or nil
        if service == nil or service.getWorkshopRepairCoverage == nil then return {eligible=false,reason="insurance_unavailable"} end
        return service:getWorkshopRepairCoverage(farmId, assetId, job)
    end

    function Workshop:fileWorkshopInsuranceClaim(farmId, jobId)
        local state = self:getState(farmId, true)
        local job = nil
        for _, candidate in ipairs(state.workshopJobs or {}) do if tostring(candidate.id or "") == tostring(jobId or "") then job=candidate;break end end
        if job == nil then return AgriLife.Result.fail("WORKSHOP81_INSURANCE_JOB_MISSING", tr("agrilife_workshop81_insurance_job_missing")) end
        local insurance = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
        local service = insurance ~= nil and (insurance.service or insurance) or nil
        if service == nil or service.fileWorkshopRepairClaim == nil then return AgriLife.Result.fail("WORKSHOP81_INSURANCE_UNAVAILABLE", tr("agrilife_workshop81_insurance_unavailable")) end
        local result = service:fileWorkshopRepairClaim(farmId, job)
        if result ~= nil and result.ok == true then job.insuranceClaimId = tostring(result.details ~= nil and result.details.claimId or "") end
        return result
    end
end
