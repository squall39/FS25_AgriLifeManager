-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Bank, accounting and fiscal roadmap writing completion.
AgriLife = AgriLife or {}

AgriLife.BankRoadmap3Completion = AgriLife.BankRoadmap3Completion or {}
AgriLife.BankRoadmap3Completion.VERSION = "0.9.1.0"
AgriLife.BankRoadmap3Completion.SCHEMA_VERSION = 2

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(maximum, value))
end

local function round(value)
    value = tonumber(value) or 0
    if value >= 0 then return math.floor(value * 100 + 0.5) / 100 end
    return math.ceil(value * 100 - 0.5) / 100
end

local function copy(source)
    local result = {}
    if type(source) ~= "table" then return result end
    for key, value in pairs(source) do result[key] = value end
    return result
end

local function fiscalYearFromPeriodKey(periodKey)
    periodKey = math.max(1, math.floor(tonumber(periodKey) or 1))
    return math.max(0, math.floor((periodKey - 1) / 12))
end

local function periodRangeForFiscalYear(fiscalYear)
    fiscalYear = math.max(0, math.floor(tonumber(fiscalYear) or 0))
    return fiscalYear * 12 + 1, fiscalYear * 12 + 12
end

local function contains(value, token)
    return string.find(string.upper(tostring(value or "")), string.upper(tostring(token or "")), 1, true) ~= nil
end

local CATEGORY_RULES = {
    CONTRACT_COMPLETED = {group="revenue", account="SALES_CONTRACTS", profitability="contracts"},
    CONTRACT_COMPLETED_TOLERANCE = {group="revenue", account="SALES_CONTRACTS", profitability="contracts"},
    CONTRACT_EARLY_BONUS = {group="revenue", account="CONTRACT_BONUS", profitability="contracts"},
    CONTRACT_QUALITY_BONUS = {group="revenue", account="CONTRACT_BONUS", profitability="contracts"},
    CONTRACT_PRICE_DIFFERENCE = {group="revenue", account="CONTRACT_ADJUSTMENT", profitability="contracts"},
    MARKET_PRODUCTION_SALE = {group="revenue", account="ASSET_DISPOSAL", profitability="productions"},
    MARKET_FARMLAND_SALE = {group="revenue", account="LAND_DISPOSAL", profitability="land"},
    INSURANCE_PAYOUT = {group="otherIncome", account="INSURANCE_RECOVERY", profitability="insurance"},
    BENEFIT = {group="otherIncome", account="GRANTS", profitability="other"},

    PAYROLL_COMPANY_COST = {group="expense", account="PAYROLL", profitability="labour"},
    EMPLOYEE_TRAINING = {group="expense", account="TRAINING", profitability="labour"},
    EMPLOYMENT_TERMINATION = {group="expense", account="TERMINATION", profitability="labour"},
    INSURANCE_PREMIUM = {group="expense", account="INSURANCE", profitability="insurance"},
    MAINTENANCE = {group="expense", account="MAINTENANCE", profitability="workshop"},
    REPAIR = {group="expense", account="REPAIRS", profitability="workshop"},
    SERVICE = {group="expense", account="SERVICE", profitability="workshop"},
    TYRES = {group="expense", account="TYRES", profitability="workshop"},
    DIAGNOSTIC = {group="expense", account="DIAGNOSTIC", profitability="workshop"},
    WORKSHOP_STOCK = {group="expense", account="PARTS_STOCK", profitability="workshop"},
    USED_INSPECTION = {group="expense", account="ASSET_INSPECTION", profitability="equipment"},
    RENTAL_PAYMENT = {group="expense", account="RENTAL", profitability="rentals"},
    MARKET_RENT_PAYMENT = {group="expense", account="RENTAL", profitability="rentals"},
    LEASE_PAYMENT = {group="expense", account="LEASING", profitability="rentals"},
    LEGAL_PAYMENT = {group="expense", account="LEGAL", profitability="administration"},
    ADMINISTRATION = {group="expense", account="ADMINISTRATION", profitability="administration"},
    CONTRACT_PENALTY = {group="expense", account="CONTRACT_PENALTIES", profitability="contracts"},

    BANK_ACCOUNT_FEE = {group="financeExpense", account="BANK_FEES", profitability="finance"},
    BANK_INCIDENT_FEE = {group="financeExpense", account="BANK_INCIDENTS", profitability="finance"},
    BANK_LOAN_SETUP_FEE = {group="financeExpense", account="FINANCING_FEES", profitability="finance"},
    BANK_REFINANCE_FEE = {group="financeExpense", account="FINANCING_FEES", profitability="finance"},
    BANK_RESTRUCTURE_FEE = {group="financeExpense", account="FINANCING_FEES", profitability="finance"},
    BANK_EARLY_REPAY_FEE = {group="financeExpense", account="FINANCING_FEES", profitability="finance"},

    NEW_PURCHASE = {group="investment", account="EQUIPMENT_PURCHASE", profitability="equipment"},
    NEW_PURCHASE_ORDER = {group="investment", account="EQUIPMENT_PURCHASE", profitability="equipment"},
    USED_PURCHASE = {group="investment", account="EQUIPMENT_PURCHASE", profitability="equipment"},
    MARKET_FARMLAND_PURCHASE = {group="investment", account="LAND_PURCHASE", profitability="land"},
    MARKET_PRODUCTION_PURCHASE = {group="investment", account="PRODUCTION_PURCHASE", profitability="productions"},
    LEASE_DEPOSIT = {group="balance", account="LEASE_DEPOSIT", profitability="rentals"},
    RENTAL_DEPOSIT = {group="balance", account="RENTAL_DEPOSIT", profitability="rentals"},
    MARKET_RENT_DEPOSIT = {group="balance", account="RENTAL_DEPOSIT", profitability="rentals"},
    RENTAL_DEPOSIT_REFUND = {group="balance", account="RENTAL_DEPOSIT", profitability="rentals"},
    MARKET_RENT_DEPOSIT_REFUND = {group="balance", account="RENTAL_DEPOSIT", profitability="rentals"},

    BANK_LOAN_DISBURSEMENT = {group="financing", account="LOAN_PROCEEDS", profitability="finance"},
    BANK_PAYMENT = {group="financing", account="LOAN_REPAYMENT", profitability="finance"},
    BANK_EARLY_REPAYMENT = {group="financing", account="LOAN_REPAYMENT", profitability="finance"},
    BANK_REFINANCE_TRANSFER = {group="financing", account="REFINANCING", profitability="finance"},
    SOCIAL_CAPITAL = {group="equity", account="SHARE_CAPITAL", profitability="equity"},

    FISCAL_TAX_PAYMENT = {group="tax", account="BUSINESS_TAX", profitability="tax"},
    FISCAL_TAX_ARREARS = {group="tax", account="TAX_ARREARS", profitability="tax"},
    BUSINESS_TAX = {group="tax", account="BUSINESS_TAX", profitability="tax"},

    FS25_PRODUCT_SALE = {group="revenue", account="SALES_PRODUCTS", profitability="productions"},
    FS25_CONTRACT_INCOME = {group="revenue", account="SALES_SERVICES", profitability="contracts"},
    FS25_ANIMAL_INCOME = {group="revenue", account="ANIMAL_SALES", profitability="productions"},
    FS25_ASSET_SALE = {group="balance", account="ASSET_DISPOSAL", profitability="equipment"},
    FS25_LAND_SALE = {group="balance", account="LAND_DISPOSAL", profitability="land"},
    FS25_INPUT_PURCHASE = {group="expense", account="INPUTS", profitability="productions"},
    FS25_ENERGY_COST = {group="expense", account="ENERGY", profitability="productions"},
    FS25_VEHICLE_COST = {group="expense", account="VEHICLE_RUNNING", profitability="equipment"},
    FS25_PRODUCTION_COST = {group="expense", account="PRODUCTION_COSTS", profitability="productions"},
    FS25_CONTRACT_COST = {group="expense", account="CONTRACT_COSTS", profitability="contracts"},
    FS25_LABOUR_COST = {group="expense", account="LABOUR", profitability="labour"},
    FS25_RENTAL_COST = {group="expense", account="RENTAL", profitability="rentals"},
    FS25_ANIMAL_COST = {group="expense", account="ANIMAL_COSTS", profitability="productions"},
    FS25_EQUIPMENT_PURCHASE = {group="investment", account="EQUIPMENT_PURCHASE", profitability="equipment"},
    FS25_LAND_PURCHASE = {group="investment", account="LAND_PURCHASE", profitability="land"},
    FS25_LOAN_MOVEMENT = {group="financing", account="LOAN_MOVEMENT", profitability="finance"},
    FS25_OTHER_INCOME = {group="otherIncome", account="OTHER_INCOME", profitability="other"},
    FS25_OTHER_EXPENSE = {group="expense", account="OTHER_EXPENSE", profitability="other"}
}

local PROFITABILITY_KEYS = {"contracts", "productions", "inputs", "land", "equipment", "rentals", "workshop", "labour", "insurance", "administration", "finance", "tax", "other"}

if AgriLife.Bank6Service ~= nil then
    local Bank = AgriLife.Bank6Service
    local baseCalculateAnnualRate = Bank.calculateAnnualRate
    local baseCalculateCapacity = Bank.calculateCapacity
    local baseCalculateReviewHours = Bank.calculateReviewHours
    local baseAssessLoanApplication = Bank.assessLoanApplication
    local baseProfessionalAccounting = Bank.getProfessionalAccountingForYear
    local baseAccountingSnapshot = Bank.getAccountingSnapshot
    local baseCloseFiscalYear = Bank.closeFiscalYear
    local baseSaveFarm = Bank.saveFarm
    local baseLoadFarm = Bank.loadFarm
    local baseGetSnapshot = Bank.getSnapshot

    function Bank:getEconomyPolicy(farmId)
        local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        return economy ~= nil and economy.getModePolicy ~= nil and economy:getModePolicy(farmId) or {}
    end

    function Bank:getMarketService()
        local market = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.market or nil
        return market ~= nil and (market.service or market) or nil
    end

    function Bank:getMarketFinancingPressure(farmId, purpose)
        local market = self:getMarketService()
        purpose = tostring(purpose or "cash")
        if market == nil or market.getCategoryMultiplier == nil then
            return {index=1, trend=0, rateAdjustment=0, capacityFactor=1, decisionAdjustment=0, category="none"}
        end
        local category = "commodities"
        if purpose == "land" then category = "land"
        elseif purpose == "equipment" then category = "vehicles_new"
        elseif purpose == "building" or purpose == "production" then category = "productions"
        elseif purpose == "refinancing" then category = "rentals"
        elseif purpose == "cash" then category = "inputs" end
        local index = clamp(market:getCategoryMultiplier(farmId, category), 0.55, 1.70)
        local snapshot = market.getSnapshot ~= nil and market:getSnapshot(farmId) or nil
        local item = snapshot ~= nil and snapshot.categories ~= nil and snapshot.categories[category] or nil
        local trend = clamp(item ~= nil and item.trend or 0, -0.30, 0.30)
        local stress = clamp((index - 1) * 0.75 + trend * 1.5, -0.30, 0.35)
        return {
            category = category,
            index = index,
            trend = trend,
            stress = stress,
            rateAdjustment = clamp(stress * 0.018, -0.0040, 0.0075),
            capacityFactor = clamp(1 - math.max(0, stress) * 0.22 + math.max(0, -stress) * 0.08, 0.90, 1.06),
            decisionAdjustment = clamp(-stress * 12, -5, 4)
        }
    end

    function Bank:getProviderRiskProfile(farmId, providerId)
        local provider = self:getProvider(providerId)
        local modeId = tostring(self:getCareerModeId(farmId) or "normal")
        local competence = clamp(provider.competenceStars or provider.stars or provider.tier or 3, 1, 5)
        local reputation = clamp(provider.reputationStars or provider.stars or provider.tier or 3, 1, 5)
        local solidity = clamp(55 + competence * 7 + reputation * 4 + (provider.tier or 1) * 3, 55, 100)
        local appetite = clamp(58 + ((provider.capacityFactor or 1) - 1) * 170 - ((provider.minimumScore or 500) - 500) * 0.05, 25, 90)
        local severity = clamp(48 + ((provider.minimumScore or 500) - 500) * 0.055 - ((provider.capacityFactor or 1) - 1) * 70, 20, 90)
        if provider.agricultural == true then appetite = clamp(appetite + 5, 25, 95) end
        if modeId == "facile" then severity = clamp(severity - 8, 15, 90)
        elseif modeId == "difficile" then severity = clamp(severity + 10, 20, 98) end
        local speed = clamp(50 + competence * 7 - severity * 0.18, 25, 90)
        return {providerId=provider.id, solidity=round(solidity), riskAppetite=round(appetite), severity=round(severity), studySpeed=round(speed), agricultural=provider.agricultural == true}
    end

    function Bank:getAdvisorCompatibility(farmId, advisorId, providerId, purpose)
        local advisor = self:getAdvisor(advisorId)
        local provider = self:getProvider(providerId)
        local providerAccess = self:getProviderAccess(farmId, provider.id)
        local advisorAccess = self:getAdvisorAccess(farmId, advisor.id)
        local purposeMatched = advisor.preferredPurposes ~= nil and advisor.preferredPurposes[tostring(purpose or "cash")] == true
        local compatible = providerAccess ~= nil and providerAccess.unlocked == true and advisorAccess ~= nil and advisorAccess.unlocked == true and (advisor.minimumProviderTier or 1) <= (provider.tier or 1)
        local score = clamp((advisor.competenceStars or advisor.stars or 3) * 12 + (advisor.reputationStars or advisor.stars or 3) * 8 + (purposeMatched and 15 or 0), 0, 100)
        return {advisorId=advisor.id, providerId=provider.id, compatible=compatible, purposeMatched=purposeMatched, compatibilityScore=round(score), providerAccess=providerAccess, advisorAccess=advisorAccess}
    end

    function Bank:getBankConsultationOffers(farmId, purpose, amount, termMonths)
        purpose = tostring(purpose or "cash")
        amount = math.max(0, tonumber(amount) or 0)
        termMonths = math.max(12, math.floor(tonumber(termMonths) or 36))
        local rows = {}
        for _, providerId in ipairs(Bank.PROVIDER_ORDER or {}) do
            local provider = self:getProvider(providerId)
            local access = self:getProviderAccess(farmId, providerId)
            local risk = self:getProviderRiskProfile(farmId, providerId)
            local bestAdvisor = nil
            for _, advisorId in ipairs(Bank.ADVISOR_ORDER or {}) do
                local compatibility = self:getAdvisorCompatibility(farmId, advisorId, providerId, purpose)
                if compatibility.compatible and (bestAdvisor == nil or compatibility.compatibilityScore > bestAdvisor.compatibilityScore) then bestAdvisor = compatibility end
            end
            local indicativeRate = clamp(0.055 + (provider.rateAdjustment or 0) + (self:getBankDifficultyPolicy(farmId).rateAdjustment or 0) + self:getMarketFinancingPressure(farmId, purpose).rateAdjustment, 0.02, 0.20)
            table.insert(rows, {
                providerId=providerId,
                providerName=provider.name,
                providerTier=provider.tier,
                available=access ~= nil and access.unlocked == true,
                lockCode=access ~= nil and access.code or "",
                risk=risk,
                bestAdvisorId=bestAdvisor ~= nil and bestAdvisor.advisorId or "",
                advisorCompatibility=bestAdvisor ~= nil and bestAdvisor.compatibilityScore or 0,
                purpose=purpose,
                requestedAmount=round(amount),
                requestedTermMonths=termMonths,
                indicativeAnnualRate=indicativeRate,
                monthlyAccountFee=round(provider.monthlyFee or 0)
            })
        end
        table.sort(rows, function(a,b)
            if a.available ~= b.available then return a.available == true end
            if a.advisorCompatibility ~= b.advisorCompatibility then return a.advisorCompatibility > b.advisorCompatibility end
            return a.indicativeAnnualRate < b.indicativeAnnualRate
        end)
        return rows
    end

    function Bank:calculateAnnualRate(farmId, amount, termMonths)
        local rate = baseCalculateAnnualRate(self, farmId, amount, termMonths)
        local purpose = self._roadmap3PurposeContext or "cash"
        local market = self:getMarketFinancingPressure(farmId, purpose)
        return clamp(rate + market.rateAdjustment, 0.018, 0.22)
    end

    function Bank:calculateCapacity(farmId)
        local capacity = baseCalculateCapacity(self, farmId)
        local purpose = self._roadmap3PurposeContext or "cash"
        local market = self:getMarketFinancingPressure(farmId, purpose)
        local accounting = self.getAdvancedAccountingSnapshot ~= nil and self:getAdvancedAccountingSnapshot(farmId, false) or nil
        local cafFactor = 1
        if accounting ~= nil then
            local caf = tonumber(accounting.selfFinancingCapacity) or 0
            local debtService = math.max(1, tonumber(self:getMonthlyObligations(farmId)) or 0) * 12
            if caf > debtService * 2 then cafFactor = 1.08 elseif caf > debtService then cafFactor = 1.04 elseif caf < 0 then cafFactor = 0.82 elseif caf < debtService * 0.5 then cafFactor = 0.92 end
        end
        return round(clamp(capacity * market.capacityFactor * cafFactor, 0, Bank.MAX_CASH_LOAN))
    end

    function Bank:calculateReviewHours(farmId)
        local hours = baseCalculateReviewHours(self, farmId)
        local risk = self:getProviderRiskProfile(farmId, self:getFarmState(farmId, true).providerId)
        local speedFactor = clamp(1.25 - (risk.studySpeed / 100) * 0.50, 0.75, 1.12)
        return clamp(hours * speedFactor, 4.0, 20.0)
    end

    function Bank:getAccountSeparationAudit(farmId)
        local modeId = tostring(self:getCareerModeId(farmId) or "normal")
        local tolerance = modeId == "facile" and 3 or (modeId == "normal" and 1 or 0)
        local violations = {}
        for _, entry in ipairs(self:getEconomyLedger(farmId)) do
            local category = string.upper(tostring(entry.category or ""))
            local source = string.upper(tostring(entry.source or ""))
            local personalCategory = category:find("PERSONAL", 1, true) ~= nil or category == "HOUSING" or category == "PROVISIONAL_LICENCE_FINE"
            if personalCategory and source ~= "PERSONAL" and source ~= "AGRILIFE" and source ~= "PERIOD" then
                table.insert(violations, {id=entry.id, category=entry.category, source=entry.source, amount=entry.amount, periodKey=entry.periodKey})
            end
        end
        local excess = math.max(0, #violations - tolerance)
        return {modeId=modeId, tolerance=tolerance, violationCount=#violations, excessViolations=excess, compliant=excess == 0, financingPenalty=math.min(12, excess * (modeId == "difficile" and 4 or 2.5)), rows=violations}
    end

    function Bank:assessLoanApplication(farmId, amount, purpose)
        self._roadmap3PurposeContext = tostring(purpose or "cash")
        local assessment = baseAssessLoanApplication(self, farmId, amount, purpose)
        self._roadmap3PurposeContext = nil
        if type(assessment) ~= "table" then return assessment end
        local market = self:getMarketFinancingPressure(farmId, purpose)
        local advanced = self.getAdvancedAccountingSnapshot ~= nil and self:getAdvancedAccountingSnapshot(farmId, false) or nil
        local accountingAdjustment = 0
        if advanced ~= nil then
            if (advanced.selfFinancingCapacity or 0) > 0 then accountingAdjustment = accountingAdjustment + math.min(5, (advanced.selfFinancingCapacity or 0) / 50000) end
            if (advanced.overdueTax or 0) > 0 then accountingAdjustment = accountingAdjustment - math.min(12, (advanced.overdueTax or 0) / 1500) end
            if (advanced.netIncome or 0) < 0 then accountingAdjustment = accountingAdjustment - 5 end
        end
        local separation = self:getAccountSeparationAudit(farmId)
        local adjusted = clamp((tonumber(assessment.score) or 0) + market.decisionAdjustment + accountingAdjustment - (separation.financingPenalty or 0), 0, 100)
        assessment.baseDecisionScore = tonumber(assessment.score) or 0
        assessment.marketAdjustment = market.decisionAdjustment
        assessment.accountingAdjustment = round(accountingAdjustment)
        assessment.accountSeparationPenalty = round(-(separation.financingPenalty or 0))
        assessment.accountSeparation = separation
        assessment.marketPressure = market
        assessment.score = adjusted
        assessment.approved = adjusted + 0.001 >= (tonumber(assessment.threshold) or 0) and (tonumber(assessment.utilization) or 0) <= (tonumber(assessment.maximumUtilization) or 1) + 0.001
        if math.abs(market.decisionAdjustment) >= 2.5 then assessment.reasonCode = "market" end
        if accountingAdjustment <= -4 then assessment.reasonCode = "accounting" end
        assessment.determiningFactors = {
            {id="creditScore", value=tonumber(assessment.creditScore) or 0},
            {id="ownerReputation", value=tonumber(assessment.ownerReputation) or 0},
            {id="companyReputation", value=tonumber(assessment.companyReputation) or 0},
            {id="capacityUtilization", value=round((tonumber(assessment.utilization) or 0) * 100)},
            {id="market", value=round(market.decisionAdjustment)},
            {id="accounting", value=round(accountingAdjustment)},
            {id="legalPenalty", value=round(-(tonumber(assessment.legalPenalty) or 0))},
            {id="accountSeparation", value=round(-(separation.financingPenalty or 0))}
        }
        return assessment
    end

    function Bank:getAccountingRule(category, amount)
        category = tostring(category or "OTHER")
        local rule = CATEGORY_RULES[category]
        if rule ~= nil then return copy(rule) end
        amount = tonumber(amount) or 0
        if category == "EXTERNAL_DIFFERENCE" or category == "FS25_MONEY" then
            return {group=amount >= 0 and "revenue" or "expense", account=amount >= 0 and "FS25_REVENUE" or "FS25_EXPENSE", profitability="other"}
        end
        if contains(category, "FUEL") then return {group="expense", account="FUEL", profitability="inputs"} end
        if contains(category, "INPUT") or contains(category, "SEED") or contains(category, "FERTIL") then return {group="expense", account="INPUTS", profitability="inputs"} end
        if contains(category, "SALE") and amount >= 0 then return {group="revenue", account="SALES_OTHER", profitability="other"} end
        return {group=amount >= 0 and "otherIncome" or "expense", account="OTHER", profitability="other"}
    end

    function Bank:getAccountingJournal(farmId, filters)
        filters = type(filters) == "table" and filters or {}
        local periodFrom = math.max(0, math.floor(tonumber(filters.periodFrom) or 0))
        local periodTo = math.max(0, math.floor(tonumber(filters.periodTo) or 0))
        local accountFilter = tostring(filters.account or "")
        local groupFilter = tostring(filters.group or "")
        local sourceFilter = tostring(filters.source or "")
        local supplierFilter = tostring(filters.supplier or filters.counterparty or "")
        local contractFilter = tostring(filters.contractId or filters.contract or "")
        local flowFilter = tostring(filters.flowType or filters.type or "")
        local tagFilter = tostring(filters.tag or "")
        local query = string.lower(tostring(filters.query or ""))
        local limit = math.max(1, math.min(500, math.floor(tonumber(filters.limit) or 100)))
        local rows, debit, credit = {}, 0, 0
        for _, entry in ipairs(self:getEconomyLedger(farmId)) do
            if self:isProfessionalLedgerEntry(entry) then
                local periodKey = tonumber(entry.periodKey) or 0
                local accountingCategory = entry.accountingCategory or entry.category
                local rule = self:getAccountingRule(accountingCategory, entry.amount)
                local matches = (periodFrom <= 0 or periodKey >= periodFrom) and (periodTo <= 0 or periodKey <= periodTo)
                matches = matches and (accountFilter == "" or rule.account == accountFilter)
                matches = matches and (groupFilter == "" or rule.group == groupFilter)
                matches = matches and (sourceFilter == "" or tostring(entry.source or "") == sourceFilter)
                matches = matches and (supplierFilter == "" or tostring(entry.supplierId or entry.counterparty or "") == supplierFilter or tostring(entry.counterparty or "") == supplierFilter)
                matches = matches and (contractFilter == "" or tostring(entry.contractId or "") == contractFilter or tostring(entry.referenceId or "") == contractFilter)
                matches = matches and (flowFilter == "" or tostring(entry.flowType or "") == flowFilter)
                if matches and tagFilter ~= "" then matches = string.find("|" .. tostring(entry.tags or "") .. "|", "|" .. tagFilter .. "|", 1, true) ~= nil end
                if matches and query ~= "" then
                    local text = string.lower(table.concat({tostring(entry.category or ""), tostring(accountingCategory or ""), tostring(entry.source or ""), tostring(entry.note or ""), tostring(entry.counterparty or ""), tostring(entry.referenceId or ""), tostring(entry.tags or ""), tostring(rule.account)}, " "))
                    matches = string.find(text, query, 1, true) ~= nil
                end
                if matches then
                    local amount = round(entry.amount)
                    if amount >= 0 then credit = credit + amount else debit = debit + math.abs(amount) end
                    table.insert(rows, {id=entry.id, periodKey=periodKey, category=entry.category, accountingCategory=accountingCategory, source=entry.source, note=entry.note, amount=amount, debit=amount < 0 and math.abs(amount) or 0, credit=amount >= 0 and amount or 0, account=rule.account, group=rule.group, profitability=rule.profitability, counterparty=entry.counterparty, supplierId=entry.supplierId, referenceId=entry.referenceId, contractId=entry.contractId, flowType=entry.flowType, tags=entry.tags})
                end
            end
        end
        table.sort(rows, function(a,b) if a.periodKey ~= b.periodKey then return a.periodKey > b.periodKey end return tostring(a.id) > tostring(b.id) end)
        while #rows > limit do table.remove(rows) end
        return {rows=rows, count=#rows, debit=round(debit), credit=round(credit), net=round(credit-debit), filters={periodFrom=periodFrom, periodTo=periodTo, account=accountFilter, group=groupFilter, source=sourceFilter, supplier=supplierFilter, contractId=contractFilter, flowType=flowFilter, tag=tagFilter, query=query, limit=limit}}
    end

    function Bank:getDepreciableAssets(farmId)
        local assetsModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.assets or nil
        local service = assetsModule ~= nil and assetsModule.service or nil
        local state = service ~= nil and service.getState ~= nil and service:getState(farmId, false) or nil
        local rows = {}
        for _, purchase in ipairs(state ~= nil and state.purchases or {}) do
            local cost = math.max(0, tonumber(purchase.price) or tonumber(purchase.newValue) or 0)
            if cost > 0 then
                local used = tostring(purchase.sourceType or (tostring(purchase.offerId or "") ~= "" and "used" or "new")) == "used"
                local usefulLifeMonths = used and 60 or 84
                local salvageRate = used and 0.10 or 0.15
                local salvage = round(cost * salvageRate)
                table.insert(rows, {assetId=tostring(purchase.assetId or purchase.id or ""), name=tostring(purchase.name or ""), sourceType=used and "used" or "new", acquisitionCost=round(cost), acquisitionPeriodKey=math.max(1, math.floor(tonumber(purchase.purchasedPeriodKey) or tonumber(purchase.deliveredPeriodKey) or self:getCurrentPeriodKey())), usefulLifeMonths=usefulLifeMonths, salvageValue=salvage, depreciableBase=round(math.max(0, cost-salvage))})
            end
        end
        return rows
    end

    function Bank:getDepreciationForYear(farmId, fiscalYear)
        local firstPeriod, lastPeriod = periodRangeForFiscalYear(fiscalYear)
        local total, rows = 0, {}
        for _, asset in ipairs(self:getDepreciableAssets(farmId)) do
            local start = math.max(firstPeriod, asset.acquisitionPeriodKey)
            local depreciationEnd = asset.acquisitionPeriodKey + asset.usefulLifeMonths - 1
            local finish = math.min(lastPeriod, depreciationEnd)
            local months = math.max(0, finish - start + 1)
            local amount = round((asset.depreciableBase / math.max(1, asset.usefulLifeMonths)) * months)
            if amount > 0 then
                total = total + amount
                local elapsedBeforeYear = math.max(0, math.min(asset.usefulLifeMonths, firstPeriod - asset.acquisitionPeriodKey))
                local accumulatedBefore = round(asset.depreciableBase / asset.usefulLifeMonths * elapsedBeforeYear)
                table.insert(rows, {assetId=asset.assetId, name=asset.name, months=months, annualDepreciation=amount, accumulatedBefore=accumulatedBefore, carryingValueAfter=round(math.max(asset.salvageValue, asset.acquisitionCost - accumulatedBefore - amount)), usefulLifeMonths=asset.usefulLifeMonths, salvageValue=asset.salvageValue})
            end
        end
        return {fiscalYear=fiscalYear, total=round(total), rows=rows}
    end

    function Bank:getProfessionalAccountingForYear(farmId, fiscalYear)
        fiscalYear = math.max(0, math.floor(tonumber(fiscalYear) or fiscalYearFromPeriodKey(self:getCurrentPeriodKey())))
        local firstPeriod, lastPeriod = periodRangeForFiscalYear(fiscalYear)
        local revenue, otherIncome, expenses, financeExpenses, taxesPaid = 0, 0, 0, 0, 0
        local investmentCash, financingCash, equityCash, balanceCash = 0, 0, 0, 0
        local movements, byCategory = 0, {}
        local profitability = {}
        for _, key in ipairs(PROFITABILITY_KEYS) do profitability[key] = {income=0, expense=0, net=0} end

        for _, entry in ipairs(self:getEconomyLedger(farmId)) do
            local periodKey = tonumber(entry.periodKey) or 0
            if self:isProfessionalLedgerEntry(entry) and periodKey >= firstPeriod and periodKey <= lastPeriod then
                local amount = round(entry.amount)
                local accountingCategory = tostring(entry.accountingCategory or entry.category or "OTHER")
                local rule = self:getAccountingRule(accountingCategory, amount)
                byCategory[accountingCategory] = round((byCategory[accountingCategory] or 0) + amount)
                movements = movements + 1
                if rule.group == "revenue" then revenue = revenue + math.max(0, amount)
                elseif rule.group == "otherIncome" then otherIncome = otherIncome + math.max(0, amount)
                elseif rule.group == "expense" then expenses = expenses + math.abs(math.min(0, amount))
                elseif rule.group == "financeExpense" then financeExpenses = financeExpenses + math.abs(math.min(0, amount))
                elseif rule.group == "tax" then taxesPaid = taxesPaid + math.abs(math.min(0, amount))
                elseif rule.group == "investment" then investmentCash = investmentCash + amount
                elseif rule.group == "financing" then financingCash = financingCash + amount
                elseif rule.group == "equity" then equityCash = equityCash + amount
                elseif rule.group == "balance" then balanceCash = balanceCash + amount end

                local bucket = profitability[rule.profitability] or profitability.other
                if rule.group == "revenue" or rule.group == "otherIncome" then bucket.income = round(bucket.income + math.max(0, amount))
                elseif rule.group == "expense" or rule.group == "financeExpense" then bucket.expense = round(bucket.expense + math.abs(math.min(0, amount))) end
                bucket.net = round(bucket.income - bucket.expense)
            end
        end

        local depreciation = self:getDepreciationForYear(farmId, fiscalYear)
        local cashOperatingProfit = round(revenue + otherIncome - expenses - financeExpenses)
        local operatingProfit = round(revenue - expenses - depreciation.total)
        local profitBeforeTax = round(cashOperatingProfit - depreciation.total)
        local modePolicy = self:getEconomyPolicy(farmId) or {}
        local estimatedIncomeTax = round(math.max(0, profitBeforeTax) * clamp(modePolicy.taxRate or 0, 0, 0.60))
        local netIncome = round(profitBeforeTax - estimatedIncomeTax)
        local selfFinancingCapacity = round(netIncome + depreciation.total)
        return {
            fiscalYear=fiscalYear, revenue=round(revenue + otherIncome), operatingRevenue=round(revenue), otherIncome=round(otherIncome),
            cashExpenses=round(expenses + financeExpenses), operatingExpenses=round(expenses), financeExpenses=round(financeExpenses), taxesPaid=round(taxesPaid),
            depreciation=depreciation.total, depreciationSchedule=depreciation.rows, operatingProfit=operatingProfit, cashProfit=cashOperatingProfit,
            profitBeforeTax=profitBeforeTax, profit=profitBeforeTax, estimatedIncomeTax=estimatedIncomeTax, taxPayments=round(taxesPaid), netIncome=netIncome, selfFinancingCapacity=selfFinancingCapacity,
            movementCount=movements, byCategory=byCategory, profitability=profitability, investmentCash=round(investmentCash),
            financingCash=round(financingCash), equityCash=round(equityCash), balanceCash=round(balanceCash)
        }
    end

    function Bank:getOwnedMarketAssetValues(farmId)
        local market = self:getMarketService()
        local farmlandValue, productionValue, farmlandCount, productionCount = 0, 0, 0, 0
        if market ~= nil and market.getFarmlandMarketRows ~= nil then
            local ok, rows = pcall(market.getFarmlandMarketRows, market, farmId)
            if ok and type(rows) == "table" then
                for _, row in ipairs(rows) do
                    local owner = row.ownerFarmId
                    if owner == nil and market.getFarmlandOwner ~= nil then owner = market:getFarmlandOwner(row.id) end
                    if tonumber(owner) == tonumber(farmId) then farmlandCount = farmlandCount + 1; farmlandValue = farmlandValue + math.max(0, tonumber(row.marketPrice) or tonumber(row.basePrice) or 0) end
                end
            end
        end
        if market ~= nil and market.getProductionMarketRows ~= nil then
            local ok, rows = pcall(market.getProductionMarketRows, market, farmId)
            if ok and type(rows) == "table" then
                for _, row in ipairs(rows) do
                    local owner = row.ownerFarmId
                    if owner == nil and market.getProductionOwner ~= nil then owner = market:getProductionOwner(row.id) end
                    if tonumber(owner) == tonumber(farmId) then productionCount = productionCount + 1; productionValue = productionValue + math.max(0, tonumber(row.marketValue) or tonumber(row.referenceValue) or 0) end
                end
            end
        end
        return {farmland=round(farmlandValue), productions=round(productionValue), farmlandCount=farmlandCount, productionCount=productionCount, total=round(farmlandValue+productionValue)}
    end

    function Bank:getBalanceSheet(farmId, fiscalYear)
        fiscalYear = math.max(0, math.floor(tonumber(fiscalYear) or fiscalYearFromPeriodKey(self:getCurrentPeriodKey())))
        local farm = self:getFarm(farmId)
        local cash = round(farm ~= nil and farm.money or 0)
        local grossEquipment, accumulatedDepreciation = 0, 0
        local _, yearEnd = periodRangeForFiscalYear(fiscalYear)
        for _, asset in ipairs(self:getDepreciableAssets(farmId)) do
            if asset.acquisitionPeriodKey <= yearEnd then
                grossEquipment = grossEquipment + asset.acquisitionCost
                local elapsed = math.max(0, math.min(asset.usefulLifeMonths, yearEnd - asset.acquisitionPeriodKey + 1))
                accumulatedDepreciation = accumulatedDepreciation + math.min(asset.depreciableBase, asset.depreciableBase / asset.usefulLifeMonths * elapsed)
            end
        end
        grossEquipment = round(grossEquipment)
        accumulatedDepreciation = round(accumulatedDepreciation)
        local netEquipment = round(math.max(0, grossEquipment - accumulatedDepreciation))
        local debt = round(self:getAgriLifeDebt(farmId) + math.max(0, tonumber(farm ~= nil and farm.loan) or 0))
        local taxes = select(1, self:getOutstandingTax(farmId))
        local liabilities = round(debt + taxes)
        local marketAssets = self:getOwnedMarketAssetValues(farmId)
        local assets = round(cash + netEquipment + marketAssets.total)
        return {fiscalYear=fiscalYear, cash=cash, equipmentGross=grossEquipment, accumulatedDepreciation=accumulatedDepreciation, equipmentNet=netEquipment, farmland=marketAssets.farmland, productions=marketAssets.productions, farmlandCount=marketAssets.farmlandCount, productionCount=marketAssets.productionCount, totalAssets=assets, loans=debt, taxPayable=taxes, totalLiabilities=liabilities, equity=round(assets-liabilities)}
    end

    function Bank:getAdvancedAccountingSnapshot(farmId, includeJournal)
        local currentYear = fiscalYearFromPeriodKey(self:getCurrentPeriodKey())
        local statement = self:getProfessionalAccountingForYear(farmId, currentYear)
        local balance = self:getBalanceSheet(farmId, currentYear)
        local outstanding, overdue = self:getOutstandingTax(farmId)
        local debtService = round((tonumber(self:getMonthlyObligations(farmId)) or 0) * 12)
        local dscr = debtService > 0 and clamp((statement.selfFinancingCapacity or 0) / debtService, -9.99, 99) or 99
        local result = {
            fiscalYear=currentYear,
            revenue=statement.revenue,
            cashExpenses=statement.cashExpenses,
            depreciation=statement.depreciation,
            netIncome=statement.netIncome,
            selfFinancingCapacity=statement.selfFinancingCapacity,
            debtServiceAnnual=debtService,
            debtServiceCoverage=round(dscr),
            profitability=statement.profitability,
            balance=balance,
            outstandingTax=outstanding,
            overdueTax=overdue,
            taxRate=tonumber((self:getEconomyPolicy(farmId) or {}).taxRate) or 0,
            depreciationSchedule=statement.depreciationSchedule,
            multiYear={}
        }
        local accounting = self:ensureAccountingState(self:getFarmState(farmId, true))
        for _, record in ipairs(accounting.fiscalHistory or {}) do table.insert(result.multiYear, copy(record)) end
        if includeJournal ~= false then result.journal = self:getAccountingJournal(farmId, {limit=120}) end
        return result
    end

    function Bank:getAccountingSnapshot(farmId)
        local snapshot = baseAccountingSnapshot(self, farmId) or {}
        snapshot.advanced = self:getAdvancedAccountingSnapshot(farmId, false)
        snapshot.current = self:getProfessionalAccountingForYear(farmId, snapshot.currentYear or fiscalYearFromPeriodKey(self:getCurrentPeriodKey()))
        snapshot.balance = self:getBalanceSheet(farmId, snapshot.currentYear or fiscalYearFromPeriodKey(self:getCurrentPeriodKey()))
        snapshot.selfFinancingCapacity = snapshot.current.selfFinancingCapacity
        snapshot.depreciation = snapshot.current.depreciation
        snapshot.profitability = snapshot.current.profitability
        return snapshot
    end

    function Bank:closeFiscalYear(farmId, fiscalYear, automatic)
        local result = baseCloseFiscalYear(self, farmId, fiscalYear, automatic)
        if result ~= nil and result.ok and result.details ~= nil and result.details.record ~= nil then
            local record = result.details.record
            local statement = self:getProfessionalAccountingForYear(farmId, record.fiscalYear)
            record.depreciation = statement.depreciation
            record.cashProfit = statement.cashProfit
            record.selfFinancingCapacity = statement.selfFinancingCapacity
            record.netIncome = statement.netIncome
            record.balance = self:getBalanceSheet(farmId, record.fiscalYear)
        end
        return result
    end

    function Bank:getDetailedCreditAssessment(farmId, amount, termMonths, purpose)
        self._roadmap3PurposeContext = tostring(purpose or "cash")
        local preview = self:previewLoan(farmId, amount, termMonths, purpose)
        self._roadmap3PurposeContext = nil
        local assessment = self:assessLoanApplication(farmId, amount, purpose)
        local market = self:getMarketFinancingPressure(farmId, purpose)
        local accounting = self:getAdvancedAccountingSnapshot(farmId, false)
        local state = self:getFarmState(farmId, true)
        return {preview=preview, assessment=assessment, market=market, accounting=accounting, providerRisk=self:getProviderRiskProfile(farmId, state.providerId), consultation=self:getBankConsultationOffers(farmId, purpose, amount, termMonths)}
    end

    function Bank:getRoadmapWritingCompletion(farmId)
        local state = self:getFarmState(farmId, true)
        local relation = self:getRelationshipSnapshot(farmId)
        return {
            version=AgriLife.BankRoadmap3Completion.VERSION,
            difficultyDriven=true,
            providerRiskProfiles=true,
            detailedDecisionFactors=true,
            dynamicMarketFinancing=true,
            consultationOffers=true,
            advisorCompatibility=true,
            fixedTermRelationship=true,
            bankChangeAtMaturity=true,
            earlyTerminationConsequences=true,
            bankTermination=true,
            loanOriginPreserved=true,
            refinancing=true,
            professionalPersonalSeparation=true,
            transactionFiltering=true,
            detailedLoans=true,
            inheritedDebtSeparated=true,
            cashflowForecast=true,
            accountingExercise=true,
            categorizedProfitAndLoss=true,
            depreciation=true,
            simplifiedBalanceSheet=true,
            difficultyTaxation=true,
            taxDeadlines=true,
            annualClosing=true,
            multiYearHistory=true,
            selfFinancingCapacity=true,
            taxArrearsConsequences=true,
            profitabilityByActivity=true,
            accountSeparationAudit=true,
            accountSeparationDifficulty=true,
            vanillaLoanOperationsBlocked=true,
            relationshipStatus=tostring(relation ~= nil and relation.status or "none"),
            providerId=tostring(state.providerId or ""),
            advisorId=tostring(state.advisorId or "")
        }
    end

    function Bank:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local accounting = self:ensureAccountingState(self:getFarmState(farmId, true))
        for index, record in ipairs(accounting.fiscalHistory or {}) do
            local key = string.format("%s.accounting.fiscalHistory.record(%d)", moduleKey, index - 1)
            xmlFile:setFloat(key .. "#depreciation", tonumber(record.depreciation) or 0)
            xmlFile:setFloat(key .. "#cashProfit", tonumber(record.cashProfit) or 0)
            xmlFile:setFloat(key .. "#selfFinancingCapacity", tonumber(record.selfFinancingCapacity) or 0)
            xmlFile:setFloat(key .. "#netIncome", tonumber(record.netIncome) or tonumber(record.profit) or 0)
            if type(record.balance) == "table" then
                xmlFile:setFloat(key .. "#totalAssets", tonumber(record.balance.totalAssets) or 0)
                xmlFile:setFloat(key .. "#totalLiabilities", tonumber(record.balance.totalLiabilities) or 0)
                xmlFile:setFloat(key .. "#equity", tonumber(record.balance.equity) or 0)
            end
        end
        return result
    end

    function Bank:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local accounting = self:ensureAccountingState(self:getFarmState(farmId, true))
        local rows = {}
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".accounting.fiscalHistory.record", function(_, key)
                table.insert(rows, {
                    depreciation=xmlFile:getFloat(key .. "#depreciation", 0),
                    cashProfit=xmlFile:getFloat(key .. "#cashProfit", 0),
                    selfFinancingCapacity=xmlFile:getFloat(key .. "#selfFinancingCapacity", 0),
                    netIncome=xmlFile:getFloat(key .. "#netIncome", 0),
                    totalAssets=xmlFile:getFloat(key .. "#totalAssets", 0),
                    totalLiabilities=xmlFile:getFloat(key .. "#totalLiabilities", 0),
                    equity=xmlFile:getFloat(key .. "#equity", 0)
                })
            end)
        end
        for index, record in ipairs(accounting.fiscalHistory or {}) do
            local row = rows[index] or {}
            record.depreciation = row.depreciation or 0
            record.cashProfit = row.cashProfit or record.profit or 0
            record.selfFinancingCapacity = row.selfFinancingCapacity or 0
            record.netIncome = row.netIncome or record.profit or 0
            record.balance = {totalAssets=row.totalAssets or 0, totalLiabilities=row.totalLiabilities or 0, equity=row.equity or 0}
        end
        return result
    end

    function Bank:getSnapshot(farmId)
        local snapshot = baseGetSnapshot(self, farmId) or {}
        local purpose = "cash"
        snapshot.marketFinancing = self:getMarketFinancingPressure(farmId, purpose)
        snapshot.providerRisk = self:getProviderRiskProfile(farmId, snapshot.providerId)
        snapshot.accountingAdvanced = self:getAdvancedAccountingSnapshot(farmId, false)
        snapshot.roadmapWritingCompletion = self:getRoadmapWritingCompletion(farmId)
        return snapshot
    end
end

if AgriLife.BankModule ~= nil then
    AgriLife.BankModule.VERSION = "0.9.1.0"
    AgriLife.BankModule.SCHEMA_VERSION = math.max(tonumber(AgriLife.BankModule.SCHEMA_VERSION) or 1, 7)
    function AgriLife.BankModule:getBankConsultationOffers(...) return self.service:getBankConsultationOffers(...) end
    function AgriLife.BankModule:getDetailedCreditAssessment(...) return self.service:getDetailedCreditAssessment(...) end
    function AgriLife.BankModule:getAccountingJournal(...) return self.service:getAccountingJournal(...) end
    function AgriLife.BankModule:getDepreciationForYear(...) return self.service:getDepreciationForYear(...) end
    function AgriLife.BankModule:getBalanceSheet(...) return self.service:getBalanceSheet(...) end
    function AgriLife.BankModule:getAdvancedAccountingSnapshot(...) return self.service:getAdvancedAccountingSnapshot(...) end
    function AgriLife.BankModule:getAccountSeparationAudit(...) return self.service:getAccountSeparationAudit(...) end
    function AgriLife.BankModule:getRoadmapWritingCompletion(...) return self.service:getRoadmapWritingCompletion(...) end
    local baseDescriptor = AgriLife.BankModule.getDescriptor
    function AgriLife.BankModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.9.1.0"
        descriptor.schemaVersion = math.max(tonumber(descriptor.schemaVersion) or 1, 7)
        return descriptor
    end
end
