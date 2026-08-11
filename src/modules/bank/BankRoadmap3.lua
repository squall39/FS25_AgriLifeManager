-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code.

AgriLife = AgriLife or {}

AgriLife.BankRoadmap3 = AgriLife.BankRoadmap3 or {}
AgriLife.BankRoadmap3.VERSION = "0.7.0.0"
AgriLife.BankRoadmap3.SCHEMA_VERSION = 1

local function clamp(value, minimum, maximum)
    value = tonumber(value) or 0
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function roundCurrency(value)
    value = tonumber(value) or 0
    if value >= 0 then
        return math.floor(value * 100 + 0.5) / 100
    end
    return math.ceil(value * 100 - 0.5) / 100
end

local function copyTable(source)
    local result = {}
    if type(source) ~= "table" then return result end
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function stringContains(haystack, needle)
    haystack = string.lower(tostring(haystack or ""))
    needle = string.lower(tostring(needle or ""))
    if needle == "" then return true end
    return string.find(haystack, needle, 1, true) ~= nil
end

local function movementSort(a, b)
    local periodA = tonumber(a.periodKey) or 0
    local periodB = tonumber(b.periodKey) or 0
    if periodA ~= periodB then return periodA > periodB end

    local dayA = tonumber(a.day) or 0
    local dayB = tonumber(b.day) or 0
    if dayA ~= dayB then return dayA > dayB end

    local timeA = tonumber(a.dayTime) or 0
    local timeB = tonumber(b.dayTime) or 0
    if timeA ~= timeB then return timeA > timeB end

    return tostring(a.id or "") > tostring(b.id or "")
end

local function loanSort(a, b)
    local activeA = tostring(a.status or "") == "active" and 1 or 0
    local activeB = tostring(b.status or "") == "active" and 1 or 0
    if activeA ~= activeB then return activeA > activeB end

    local periodA = tonumber(a.createdPeriodKey) or 0
    local periodB = tonumber(b.createdPeriodKey) or 0
    if periodA ~= periodB then return periodA > periodB end

    return tostring(a.id or "") < tostring(b.id or "")
end

local function relationIsActive(relation)
    return relation ~= nil and tostring(relation.status or "") == "active" and (tonumber(relation.remainingMonths) or 0) > 0
end

local function getBankService(module)
    return module ~= nil and module.service or nil
end

local function normalizeTransactionFilters(filters)
    filters = type(filters) == "table" and filters or {}
    return {
        kind = tostring(filters.kind or ""),
        tag = tostring(filters.tag or ""),
        query = tostring(filters.query or ""),
        periodFrom = math.max(0, math.floor(tonumber(filters.periodFrom) or 0)),
        periodTo = math.max(0, math.floor(tonumber(filters.periodTo) or 0)),
        minimumAmount = filters.minimumAmount ~= nil and tonumber(filters.minimumAmount) or nil,
        maximumAmount = filters.maximumAmount ~= nil and tonumber(filters.maximumAmount) or nil,
        limit = math.max(1, math.min(160, math.floor(tonumber(filters.limit) or 40)))
    }
end

local function movementMatches(movement, filters)
    local amount = tonumber(movement.amount) or 0
    local periodKey = tonumber(movement.periodKey) or 0

    if filters.kind ~= "" and tostring(movement.kind or "") ~= filters.kind then return false end
    if filters.tag ~= "" and not stringContains(movement.tags, filters.tag) then return false end
    if filters.query ~= "" then
        local matchesQuery = stringContains(movement.kind, filters.query)
            or stringContains(movement.note, filters.query)
            or stringContains(movement.tags, filters.query)
            or stringContains(movement.id, filters.query)
        if not matchesQuery then return false end
    end
    if filters.periodFrom > 0 and periodKey < filters.periodFrom then return false end
    if filters.periodTo > 0 and periodKey > filters.periodTo then return false end
    if filters.minimumAmount ~= nil and amount < filters.minimumAmount then return false end
    if filters.maximumAmount ~= nil and amount > filters.maximumAmount then return false end

    return true
end

local function createRuntimeChecklist(snapshot, relation, accounting)
    local providerSelected = snapshot ~= nil and snapshot.providerSelected == true
    local advisorSelected = snapshot ~= nil and snapshot.advisorSelected == true
    local relationshipActive = relationIsActive(relation)
    local pendingApplication = snapshot ~= nil and (tonumber(snapshot.pendingApplicationCount) or 0) > 0
    local accountArrears = snapshot ~= nil and ((tonumber(snapshot.accountFeesArrears) or 0) + (tonumber(snapshot.incidentFeesArrears) or 0)) > 0.01
    local overdueTax = accounting ~= nil and (tonumber(accounting.overdueTax) or 0) > 0.01

    local nextAction = "BANK_READY"
    if not providerSelected then
        nextAction = "CHOOSE_PROVIDER"
    elseif not advisorSelected then
        nextAction = "CHOOSE_ADVISOR"
    elseif not relationshipActive then
        nextAction = "SIGN_RELATIONSHIP"
    elseif pendingApplication then
        nextAction = "WAIT_APPLICATION"
    elseif accountArrears or overdueTax then
        nextAction = "RESOLVE_ARREARS"
    end

    return {
        providerSelected = providerSelected,
        advisorSelected = advisorSelected,
        relationshipActive = relationshipActive,
        pendingApplication = pendingApplication,
        accountArrears = accountArrears,
        overdueTax = overdueTax,
        financingReady = providerSelected and advisorSelected and relationshipActive and not accountArrears,
        accountingReady = accounting ~= nil,
        nextAction = nextAction
    }
end

if AgriLife.Bank6Service ~= nil then
    function AgriLife.Bank6Service:getRoadmap3DebtSummary(farmId)
        local farm = self:getFarm(farmId)
        local vanillaDebt = math.max(0, tonumber(farm ~= nil and farm.loan) or 0)
        local agriLifeDebt = math.max(0, tonumber(self:getAgriLifeDebt(farmId)) or 0)
        local totalDebt = roundCurrency(vanillaDebt + agriLifeDebt)
        local monthly = roundCurrency(self:getMonthlyObligations(farmId))
        local cash = roundCurrency(tonumber(farm ~= nil and farm.money) or 0)

        return {
            vanillaDebt = roundCurrency(vanillaDebt),
            inheritedVanillaDebt = roundCurrency(vanillaDebt),
            agriLifeDebt = roundCurrency(agriLifeDebt),
            totalDebt = totalDebt,
            monthlyDebtService = monthly,
            cash = cash,
            netCashAfterDebt = roundCurrency(cash - totalDebt)
        }
    end

    function AgriLife.Bank6Service:getRoadmap3LoanDetails(farmId, loanId)
        local loan = self:findLoan(farmId, loanId)
        if loan == nil then return nil end

        local provider = self:getProvider(tostring(loan.providerId or ""))
        local advisor = self:getAdvisor(tostring(loan.advisorId or ""))
        local remainingMonths = math.max(0, (tonumber(loan.termMonths) or 0) - (tonumber(loan.monthsPaid) or 0))
        local balance = roundCurrency(tonumber(loan.balance) or 0)
        local monthlyPayment = roundCurrency(tonumber(loan.monthlyPayment) or 0)
        local futurePayments = roundCurrency(monthlyPayment * remainingMonths)
        local estimatedFutureInterest = roundCurrency(math.max(0, futurePayments - balance))

        return {
            id = tostring(loan.id or ""),
            status = tostring(loan.status or "active"),
            purpose = tostring(loan.purpose or "cash"),
            providerId = tostring(loan.providerId or ""),
            providerName = provider ~= nil and tostring(provider.name or "") or "",
            advisorId = tostring(loan.advisorId or ""),
            advisorName = advisor ~= nil and tostring(advisor.name or "") or "",
            originalPrincipal = roundCurrency(loan.originalPrincipal),
            remainingPrincipal = balance,
            annualRate = tonumber(loan.annualRate) or 0,
            termMonths = math.max(1, math.floor(tonumber(loan.termMonths) or 1)),
            monthsPaid = math.max(0, math.floor(tonumber(loan.monthsPaid) or 0)),
            remainingMonths = remainingMonths,
            monthlyPayment = monthlyPayment,
            interestPaid = roundCurrency(loan.totalInterestPaid),
            accruedInterest = roundCurrency(loan.accruedInterest),
            estimatedFutureInterest = estimatedFutureInterest,
            estimatedRemainingCost = futurePayments,
            missedPayments = math.max(0, math.floor(tonumber(loan.missedPayments) or 0)),
            restructureCount = math.max(0, math.floor(tonumber(loan.restructureCount) or 0)),
            createdPeriodKey = math.max(0, math.floor(tonumber(loan.createdPeriodKey) or 0))
        }
    end

    function AgriLife.Bank6Service:getRoadmap3Loans(farmId, includeClosed)
        local state = self:getFarmState(farmId, true)
        local result = {}

        for _, loan in ipairs(state ~= nil and state.loans or {}) do
            if includeClosed == true or tostring(loan.status or "active") == "active" then
                local details = self:getRoadmap3LoanDetails(farmId, loan.id)
                if details ~= nil then table.insert(result, details) end
            end
        end

        table.sort(result, loanSort)
        return result
    end

    function AgriLife.Bank6Service:getRoadmap3Transactions(farmId, filters)
        filters = normalizeTransactionFilters(filters)
        local state = self:getFarmState(farmId, true)
        local rows = {}
        local matched = 0
        local credit = 0
        local debit = 0

        for _, movement in ipairs(state ~= nil and state.bankMovements or {}) do
            if movementMatches(movement, filters) then
                matched = matched + 1
                local amount = roundCurrency(movement.amount)
                if amount >= 0 then credit = credit + amount else debit = debit + math.abs(amount) end
                table.insert(rows, copyTable(movement))
            end
        end

        table.sort(rows, movementSort)
        while #rows > filters.limit do table.remove(rows) end

        return {
            rows = rows,
            returned = #rows,
            matched = matched,
            totalCredit = roundCurrency(credit),
            totalDebit = roundCurrency(debit),
            net = roundCurrency(credit - debit),
            filters = filters
        }
    end

    function AgriLife.Bank6Service:getRoadmap3RelationshipTerms(farmId)
        local snapshot = self:getSnapshot(farmId)
        local relation = self.getRelationshipSnapshot ~= nil and self:getRelationshipSnapshot(farmId) or nil
        local provider = snapshot ~= nil and self:getProvider(snapshot.providerId) or nil
        local modeId = tostring(snapshot ~= nil and snapshot.bankModeId or self:getCareerModeId(farmId))
        local feeFactor = modeId == "facile" and 0.60 or (modeId == "difficile" and 1.35 or 1.00)
        local monthlyFee = tonumber(provider ~= nil and provider.monthlyFee) or 15
        local terms = {}

        for _, months in ipairs({12, 36, 60}) do
            local terminationFee = roundCurrency(math.max(150, monthlyFee * (months / 3)) * feeFactor)
            local relationshipBonus = months == 60 and 6 or (months == 36 and 3 or 1)
            table.insert(terms, {
                termMonths = months,
                earlyTerminationFee = terminationFee,
                relationshipBonus = relationshipBonus,
                available = relation == nil or not relationIsActive(relation)
            })
        end

        return terms
    end

    function AgriLife.Bank6Service:getRoadmap3FinancingAnalysis(farmId, amount, termMonths, purpose)
        amount = tonumber(amount) or 0
        termMonths = math.floor(tonumber(termMonths) or 0)
        purpose = tostring(purpose or "cash")

        local snapshot = self:getSnapshot(farmId)
        local relation = self.getRelationshipSnapshot ~= nil and self:getRelationshipSnapshot(farmId) or nil
        local preview = self:previewLoan(farmId, amount, termMonths, purpose)
        local assessment = nil
        if amount > 0 and self.assessLoanApplication ~= nil then
            assessment = self:assessLoanApplication(farmId, amount, purpose)
        end

        local blockers = {}
        if snapshot == nil or snapshot.providerSelected ~= true then table.insert(blockers, "PROVIDER_REQUIRED") end
        if snapshot == nil or snapshot.advisorSelected ~= true then table.insert(blockers, "ADVISOR_REQUIRED") end
        if not relationIsActive(relation) then table.insert(blockers, "RELATIONSHIP_CONTRACT_REQUIRED") end
        if preview == nil or preview.ok ~= true then table.insert(blockers, tostring(preview ~= nil and preview.code or "PREVIEW_UNAVAILABLE")) end

        local projectedMonthly = tonumber(snapshot ~= nil and snapshot.monthly) or 0
        if preview ~= nil and preview.ok == true and preview.details ~= nil then
            projectedMonthly = projectedMonthly + (tonumber(preview.details.monthlyPayment) or 0)
        end

        return {
            farmId = tonumber(farmId) or 0,
            amount = amount,
            termMonths = termMonths,
            purpose = purpose,
            preview = preview,
            assessment = assessment,
            relationship = relation,
            blockers = blockers,
            ready = #blockers == 0,
            currentMonthlyDebtService = roundCurrency(snapshot ~= nil and snapshot.monthly or 0),
            projectedMonthlyDebtService = roundCurrency(projectedMonthly),
            capacity = roundCurrency(snapshot ~= nil and snapshot.capacity or 0),
            score = tonumber(snapshot ~= nil and snapshot.score) or 0,
            rating = tostring(snapshot ~= nil and snapshot.rating or "")
        }
    end

    function AgriLife.Bank6Service:getRoadmap3ProfessionalAccount(farmId)
        local snapshot = self:getSnapshot(farmId)
        local debt = self:getRoadmap3DebtSummary(farmId)
        local accounting = self.getAccountingSnapshot ~= nil and self:getAccountingSnapshot(farmId) or nil
        local forecast = self.getCashflowForecast ~= nil and self:getCashflowForecast(farmId, 6) or nil

        return {
            cash = roundCurrency(snapshot ~= nil and snapshot.cash or 0),
            overdraftLimit = roundCurrency(snapshot ~= nil and snapshot.overdraftLimit or 0),
            overdraftUsed = roundCurrency(snapshot ~= nil and snapshot.overdraftUsed or 0),
            monthlyAccountFee = roundCurrency(snapshot ~= nil and snapshot.monthlyAccountFee or 0),
            accountFeesPaid = roundCurrency(snapshot ~= nil and snapshot.accountFeesPaid or 0),
            accountFeesArrears = roundCurrency(snapshot ~= nil and snapshot.accountFeesArrears or 0),
            incidentFeesPaid = roundCurrency(snapshot ~= nil and snapshot.incidentFeesPaid or 0),
            incidentFeesArrears = roundCurrency(snapshot ~= nil and snapshot.incidentFeesArrears or 0),
            loanFeesPaid = roundCurrency(snapshot ~= nil and snapshot.loanFeesPaid or 0),
            earlyRepayFeesPaid = roundCurrency(snapshot ~= nil and snapshot.earlyRepayFeesPaid or 0),
            totalInterestPaid = roundCurrency(snapshot ~= nil and snapshot.totalInterestPaid or 0),
            debt = debt,
            accounting = accounting,
            cashflow = forecast
        }
    end

    function AgriLife.Bank6Service:getRoadmap3Checklist(farmId)
        local snapshot = self:getSnapshot(farmId)
        local relation = self.getRelationshipSnapshot ~= nil and self:getRelationshipSnapshot(farmId) or nil
        local accounting = self.getAccountingSnapshot ~= nil and self:getAccountingSnapshot(farmId) or nil
        local runtime = createRuntimeChecklist(snapshot, relation, accounting)

        return {
            runtime = runtime,
            capabilities = {
                difficultyPolicy = self.getBankDifficultyPolicy ~= nil,
                providerAccess = self.getProviderAccess ~= nil,
                advisorAccess = self.getAdvisorAccess ~= nil,
                delayedCreditDecision = self.assessLoanApplication ~= nil and self.update ~= nil,
                relationshipContract = self.getRelationshipSnapshot ~= nil and self.signRelationshipContract ~= nil,
                relationshipRenewal = self.renewRelationshipContract ~= nil,
                relationshipTermination = self.terminateRelationshipContract ~= nil,
                bankTermination = self.terminateRelationshipByBank ~= nil,
                loanOriginTracking = self.getRoadmap3LoanDetails ~= nil,
                refinancing = self.previewRefinance ~= nil and self.requestRefinance ~= nil,
                transactionHistory = self.getRoadmap3Transactions ~= nil,
                cashflowForecast = self.getCashflowForecast ~= nil,
                accounting = self.getAccountingSnapshot ~= nil,
                fiscalClose = self.closeFiscalYear ~= nil,
                taxPayment = self.payTax ~= nil,
                inheritedVanillaDebt = true,
                earlyRepayment = self.repayEarly ~= nil,
                restructuring = self.restructureLoan ~= nil,
                overdraft = self.setOverdraftLimit ~= nil
            }
        }
    end

    function AgriLife.Bank6Service:getRoadmap3Snapshot(farmId)
        local snapshot = self:getSnapshot(farmId)
        if snapshot == nil then return nil end

        local relation = self.getRelationshipSnapshot ~= nil and self:getRelationshipSnapshot(farmId) or nil
        local accounting = self.getAccountingSnapshot ~= nil and self:getAccountingSnapshot(farmId) or nil
        local debt = self:getRoadmap3DebtSummary(farmId)
        local checklist = self:getRoadmap3Checklist(farmId)

        return {
            farmId = tonumber(farmId) or 0,
            difficulty = {
                id = tostring(snapshot.bankModeId or "normal"),
                capacityFactor = tonumber(snapshot.difficultyCapacityFactor) or 1,
                rateAdjustment = tonumber(snapshot.difficultyRateAdjustment) or 0,
                setupFeeFactor = tonumber(snapshot.difficultySetupFeeFactor) or 1,
                contributionRate = tonumber(snapshot.difficultyContributionRate) or 0
            },
            identity = {
                providerSelected = snapshot.providerSelected == true,
                providerId = tostring(snapshot.providerId or ""),
                providerName = tostring(snapshot.providerName or ""),
                providerTier = tonumber(snapshot.providerTier) or 1,
                providerTierName = tostring(snapshot.providerTierName or ""),
                advisorSelected = snapshot.advisorSelected == true,
                advisorId = tostring(snapshot.advisorId or ""),
                advisorName = tostring(snapshot.advisorName or ""),
                advisorTitle = tostring(snapshot.advisorTitle or ""),
                advisorTier = tonumber(snapshot.advisorTier) or 1,
                advisorTierName = tostring(snapshot.advisorTierName or "")
            },
            relationship = relation,
            credit = {
                score = tonumber(snapshot.score) or 0,
                rating = tostring(snapshot.rating or ""),
                capacity = roundCurrency(snapshot.capacity),
                bankRelationship = clamp(snapshot.bankRelationship, 0, 100),
                advisorTrust = clamp(snapshot.advisorTrust, 0, 100),
                ownerReputation = clamp(snapshot.ownerReputation, 0, 100),
                companyReputation = clamp(snapshot.companyReputation, 0, 100),
                pendingApplicationCount = tonumber(snapshot.pendingApplicationCount) or 0,
                applicationStatus = tostring(snapshot.applicationStatus or "none"),
                applicationRemainingMs = tonumber(snapshot.applicationRemainingMs) or 0,
                applicationDecisionScore = tonumber(snapshot.applicationDecisionScore) or 0,
                applicationDecisionThreshold = tonumber(snapshot.applicationDecisionThreshold) or 0,
                applicationDecisionReasonCode = tostring(snapshot.applicationDecisionReasonCode or "")
            },
            debt = debt,
            account = self:getRoadmap3ProfessionalAccount(farmId),
            loans = self:getRoadmap3Loans(farmId, true),
            transactions = self:getRoadmap3Transactions(farmId, {limit = 20}),
            accounting = accounting,
            relationshipTerms = self:getRoadmap3RelationshipTerms(farmId),
            checklist = checklist
        }
    end
end

if AgriLife.BankModule ~= nil then
    function AgriLife.BankModule:getRoadmap3Snapshot(farmId)
        local service = getBankService(self)
        if service == nil or service.getRoadmap3Snapshot == nil then return nil end
        if self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer then
            self:requestSnapshot(farmId, false)
            return nil
        end
        return service:getRoadmap3Snapshot(farmId)
    end

    function AgriLife.BankModule:getRoadmap3Checklist(farmId)
        local service = getBankService(self)
        return service ~= nil and service.getRoadmap3Checklist ~= nil and service:getRoadmap3Checklist(farmId) or nil
    end

    function AgriLife.BankModule:getRoadmap3Transactions(farmId, filters)
        local service = getBankService(self)
        return service ~= nil and service.getRoadmap3Transactions ~= nil and service:getRoadmap3Transactions(farmId, filters) or nil
    end

    function AgriLife.BankModule:getRoadmap3LoanDetails(farmId, loanId)
        local service = getBankService(self)
        return service ~= nil and service.getRoadmap3LoanDetails ~= nil and service:getRoadmap3LoanDetails(farmId, loanId) or nil
    end

    function AgriLife.BankModule:getRoadmap3FinancingAnalysis(farmId, amount, termMonths, purpose)
        local service = getBankService(self)
        return service ~= nil and service.getRoadmap3FinancingAnalysis ~= nil and service:getRoadmap3FinancingAnalysis(farmId, amount, termMonths, purpose) or nil
    end

    function AgriLife.BankModule:getRoadmap3ProfessionalAccount(farmId)
        local service = getBankService(self)
        return service ~= nil and service.getRoadmap3ProfessionalAccount ~= nil and service:getRoadmap3ProfessionalAccount(farmId) or nil
    end
end
