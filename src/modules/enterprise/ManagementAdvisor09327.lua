-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.ManagementAdvisor09327 = AgriLife.ManagementAdvisor09327 or {}
local Advisor = AgriLife.ManagementAdvisor09327
Advisor.VERSION = "0.9.3.27"
Advisor.MAX_HISTORY = 80

local function num(value, default)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
    return value
end
local function round(value) return math.floor(num(value, 0) * 100 + 0.5) / 100 end
local function clamp(value, minimum, maximum) return math.max(minimum, math.min(maximum, num(value, minimum))) end
local function text(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil and key ~= nil then
        local ok, value = pcall(g_i18n.getText, g_i18n, key)
        if ok and value ~= nil and tostring(value) ~= tostring(key) then return tostring(value) end
    end
    return tostring(fallback or key or "")
end
local function money(value)
    value = round(value)
    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        local ok, result = pcall(g_i18n.formatMoney, g_i18n, value, 0, true, true)
        if ok and result ~= nil then return tostring(result) end
    end
    return string.format("%.0f EUR", value)
end

function Advisor:getModule(core, id)
    return core ~= nil and core.registry ~= nil and core.registry.instances ~= nil and core.registry.instances[id] or nil
end

function Advisor:getSnapshot(core, id, farmId)
    local module = self:getModule(core, id)
    if module ~= nil and module.getSnapshot ~= nil then
        local ok, snapshot = pcall(module.getSnapshot, module, farmId)
        if ok then return snapshot end
    end
    return nil
end

function Advisor:getDifficulty(core, farmId)
    local economy = self:getSnapshot(core, "economy", farmId)
    return tostring(economy ~= nil and economy.modeId or "normal")
end

function Advisor:getMetrics(core, farmId)
    local economy = self:getSnapshot(core, "economy", farmId) or {}
    local bank = self:getSnapshot(core, "bank", farmId) or {}
    local payroll = self:getSnapshot(core, "payroll", farmId) or {}
    local company = self:getSnapshot(core, "company", farmId) or {}
    local legal = self:getSnapshot(core, "legal", farmId) or {}
    local contracts = self:getSnapshot(core, "contracts", farmId) or {}
    local farm = g_farmManager ~= nil and g_farmManager.getFarmById ~= nil and g_farmManager:getFarmById(tonumber(farmId) or 0) or nil
    local cash = num(bank.cash, num(economy.cash, num(farm ~= nil and farm.money, 0)))
    local monthlyPayroll = num(payroll.totalMonthlyPayroll, 0)
    local monthlyStructure = num(company.monthlyStructureCost, 0)
    local monthlyLoan = num(bank.monthlyLoanPayment, num(bank.activeLoanMonthlyPayment, 0))
    local monthlyBank = num(bank.monthlyAccountFee, 0)
    local monthlyCommitments = math.max(0, monthlyPayroll + monthlyStructure + monthlyLoan + monthlyBank)
    local debt = math.max(0, num(bank.agriLifeDebt, num(bank.totalDebt, 0)) + num(legal.debt, 0))
    local capacity = math.max(0, num(bank.borrowingCapacity, num(bank.capacity, 0)))
    local penaltyDue = math.max(0, num(contracts.penaltyDue, 0))
    local receivables = math.max(0, num(contracts.receivablesDue, 0))
    return {
        cash=round(cash), monthlyPayroll=round(monthlyPayroll), monthlyStructure=round(monthlyStructure), monthlyLoan=round(monthlyLoan),
        monthlyCommitments=round(monthlyCommitments), debt=round(debt), borrowingCapacity=round(capacity), legalDebt=round(num(legal.debt,0)),
        contractPenaltyDue=round(penaltyDue), receivables=round(receivables), activeContracts=math.max(0, math.floor(num(contracts.activeContracts,0))),
        creditScore=math.floor(num(bank.creditScore, num(bank.score, 0))), difficulty=self:getDifficulty(core,farmId)
    }
end

function Advisor:getThresholds(difficulty)
    if difficulty == "facile" then return {greenMonths=4, orangeMonths=2, minimumReserve=5000} end
    if difficulty == "difficile" then return {greenMonths=9, orangeMonths=4, minimumReserve=20000} end
    return {greenMonths=6, orangeMonths=3, minimumReserve=10000}
end

function Advisor:evaluateLiquidity(metrics, cashAfter, addedMonthlyCost)
    local thresholds = self:getThresholds(metrics.difficulty)
    local monthly = math.max(1, num(metrics.monthlyCommitments,0) + math.max(0,num(addedMonthlyCost,0)))
    local months = math.max(0, num(cashAfter,0)) / monthly
    local risk = "GREEN"
    if cashAfter < thresholds.minimumReserve or months < thresholds.orangeMonths then risk = "RED"
    elseif months < thresholds.greenMonths then risk = "ORANGE" end
    if metrics.legalDebt > 0 or metrics.contractPenaltyDue > 0 then
        if risk == "GREEN" then risk = "ORANGE" elseif risk == "ORANGE" and cashAfter < thresholds.minimumReserve*2 then risk = "RED" end
    end
    return risk, round(months), thresholds
end

function Advisor:buildVerdict(difficulty, risk)
    if difficulty == "difficile" and risk ~= "RED" then return "DIAGNOSTIC" end
    if risk == "GREEN" then return "FAVORABLE" end
    if risk == "ORANGE" then return "CAUTION" end
    return "UNFAVORABLE"
end

function Advisor:advise(core, farmId, decisionType, params)
    params = type(params)=="table" and params or {}
    decisionType = string.upper(tostring(decisionType or "GENERIC"))
    local m = self:getMetrics(core, farmId)
    local addedMonthly = 0
    local immediateCost = 0
    local expectedRevenue = math.max(0, num(params.expectedRevenue,0))
    local expectedCost = math.max(0, num(params.expectedCost,0))
    local alternative = ""

    if decisionType == "HIRE" or decisionType == "RECRUIT" then
        addedMonthly = math.max(0, num(params.monthlyEmployerCost, num(params.monthlySalary,0)*1.35))
    elseif decisionType == "BUY_FIELD" or decisionType == "BUY_ASSET" or decisionType == "BUY_VEHICLE" then
        immediateCost = math.max(0, num(params.purchaseCost, num(params.price,0)))
        if decisionType == "BUY_FIELD" and num(params.annualLeaseCost,0) > 0 then alternative = text("agrilife_advisor_alt_lease", "Consider leasing instead of buying.") end
    elseif decisionType == "LEASE" then
        immediateCost = math.max(0, num(params.deposit,0)); addedMonthly = math.max(0,num(params.monthlyPayment,0))
    elseif decisionType == "LOAN" then
        immediateCost = math.max(0,num(params.setupFee,0)); addedMonthly = math.max(0,num(params.monthlyPayment,0))
    elseif decisionType == "EARLY_REPAY" then
        immediateCost = math.max(0,num(params.amount,0)+num(params.fee,0))
    elseif decisionType == "ACCEPT_CONTRACT" then
        immediateCost = math.max(0, expectedCost * 0.15)
        addedMonthly = math.max(0, expectedCost / math.max(1,num(params.durationMonths,1)))
    elseif decisionType == "LEGAL_FORM" or decisionType == "ACTIVITY" or decisionType == "NETWORK" then
        immediateCost = math.max(0,num(params.cost,0)); addedMonthly = math.max(0,num(params.monthlyCost,0))
    else
        immediateCost = math.max(0,num(params.immediateCost,0)); addedMonthly = math.max(0,num(params.addedMonthlyCost,0))
    end

    local cashAfter = m.cash - immediateCost
    local risk, coverageMonths, thresholds = self:evaluateLiquidity(m, cashAfter, addedMonthly)
    if decisionType == "ACCEPT_CONTRACT" then
        local margin = expectedRevenue - expectedCost
        if expectedRevenue > 0 and margin <= 0 then risk = "RED"
        elseif expectedRevenue > 0 and margin/expectedRevenue < 0.12 and risk == "GREEN" then risk = "ORANGE" end
    end
    if immediateCost > m.cash and num(params.financedAmount,0) <= 0 then risk = "RED" end

    local verdict = self:buildVerdict(m.difficulty, risk)
    local lines = {
        string.format(text("agrilife_advisor_cash_after_fmt", "Cash after decision: %s"), money(cashAfter)),
        string.format(text("agrilife_advisor_commitments_fmt", "Monthly commitments: %s"), money(m.monthlyCommitments + addedMonthly)),
        string.format(text("agrilife_advisor_coverage_fmt", "Cash coverage: %.1f months"), coverageMonths),
        string.format(text("agrilife_advisor_debt_fmt", "AgriLife debt and disputes: %s"), money(m.debt))
    }
    if expectedRevenue > 0 or expectedCost > 0 then table.insert(lines,string.format(text("agrilife_advisor_margin_fmt","Expected margin: %s"),money(expectedRevenue-expectedCost))) end
    if m.contractPenaltyDue > 0 then table.insert(lines,string.format(text("agrilife_advisor_contract_due_fmt","Contract penalties due: %s"),money(m.contractPenaltyDue))) end
    if m.legalDebt > 0 then table.insert(lines,string.format(text("agrilife_advisor_legal_due_fmt","Legal debt: %s"),money(m.legalDebt))) end
    if alternative ~= "" then table.insert(lines,alternative) end

    local headlineKey = "agrilife_advisor_verdict_"..string.lower(verdict)
    local headline = text(headlineKey, verdict)
    if m.difficulty == "facile" then
        if verdict == "FAVORABLE" then headline = text("agrilife_advisor_easy_yes", "Yes, the farm can currently absorb this decision.")
        elseif verdict == "UNFAVORABLE" then headline = text("agrilife_advisor_easy_no", "No, current finances make this decision unsafe.")
        else headline = text("agrilife_advisor_easy_caution", "Possible, but the farm would lose a significant safety margin.") end
    elseif m.difficulty == "difficile" and verdict == "DIAGNOSTIC" then
        headline = text("agrilife_advisor_hard_diagnostic", "Diagnostic only: the final decision is yours.")
    end

    return AgriLife.Result.ok("MANAGEMENT_ADVICE_READY", "Management advice ready", {
        decisionType=decisionType, risk=risk, verdict=verdict, headline=headline, lines=lines, metrics=m,
        immediateCost=round(immediateCost), addedMonthlyCost=round(addedMonthly), cashAfter=round(cashAfter), coverageMonths=coverageMonths,
        minimumReserve=thresholds.minimumReserve, generatedPeriodKey=(function() local e=g_currentMission~=nil and g_currentMission.environment or nil;return math.max(1,math.floor(num(e~=nil and e.currentYear,1))*12+math.max(1,math.min(12,math.floor(num(e~=nil and e.currentPeriod,1))))) end)()
    })
end

function Advisor:formatAdvice(result)
    if result == nil or result.ok ~= true or result.details == nil then return text("agrilife_advisor_unavailable","Management advice unavailable.") end
    local d=result.details; local lines={tostring(d.headline or "")}
    for _,line in ipairs(d.lines or {}) do table.insert(lines,"- "..tostring(line)) end
    return table.concat(lines,"\n")
end

if AgriLife.Enterprise6Service ~= nil then
    local Enterprise = AgriLife.Enterprise6Service
    local baseCreate = Enterprise.createDefaultState
    function Enterprise:createDefaultState()
        local state = baseCreate(self)
        state.managementAdviceHistory = type(state.managementAdviceHistory)=="table" and state.managementAdviceHistory or {}
        state.nextAdviceId = math.max(1,math.floor(num(state.nextAdviceId,1)))
        return state
    end

    local baseGetState = Enterprise.getState
    function Enterprise:getState(farmId, create)
        local state=baseGetState(self,farmId,create)
        if state~=nil then state.managementAdviceHistory=type(state.managementAdviceHistory)=="table" and state.managementAdviceHistory or {};state.nextAdviceId=math.max(1,math.floor(num(state.nextAdviceId,1))) end
        return state
    end

    function Enterprise:getManagementAdvice(farmId, decisionType, params, record)
        local result = Advisor:advise(self.core, farmId, decisionType, params)
        if record == true and result ~= nil and result.ok == true then
            local state=self:getState(farmId,true);local d=result.details or{}
            local entry={id=string.format("ADV_%d_%06d",farmId,state.nextAdviceId),periodKey=d.generatedPeriodKey or 0,decisionType=tostring(d.decisionType or""),risk=tostring(d.risk or""),verdict=tostring(d.verdict or""),cashAfter=num(d.cashAfter,0),coverageMonths=num(d.coverageMonths,0),immediateCost=num(d.immediateCost,0),addedMonthlyCost=num(d.addedMonthlyCost,0)}
            state.nextAdviceId=state.nextAdviceId+1;table.insert(state.managementAdviceHistory,entry);while #state.managementAdviceHistory>Advisor.MAX_HISTORY do table.remove(state.managementAdviceHistory,1) end
            result.details.adviceId=entry.id
        end
        return result
    end

    function Enterprise:getManagementAdviceHistory(farmId)
        local state=self:getState(farmId,true);return state.managementAdviceHistory
    end

    local baseSnapshot = Enterprise.getSnapshot
    function Enterprise:getSnapshot(farmId)
        local snapshot=baseSnapshot(self,farmId) or {}
        local state=self:getState(farmId,true);snapshot.managementAdviceHistory=state.managementAdviceHistory;snapshot.managementAdviceCount=#state.managementAdviceHistory
        return snapshot
    end

    local baseSave = Enterprise.saveFarm
    function Enterprise:saveFarm(xmlFile,moduleKey,farmId)
        local result=baseSave(self,xmlFile,moduleKey,farmId);if result==nil or result.ok==false or xmlFile==nil or moduleKey==nil then return result end
        local state=self:getState(farmId,true);xmlFile:setInt(moduleKey..".advisor#nextId",math.floor(num(state.nextAdviceId,1)))
        for index,entry in ipairs(state.managementAdviceHistory or{}) do local key=string.format("%s.advisor.history.item(%d)",moduleKey,index-1);xmlFile:setString(key.."#id",tostring(entry.id or""));xmlFile:setInt(key.."#periodKey",math.floor(num(entry.periodKey,0)));xmlFile:setString(key.."#decisionType",tostring(entry.decisionType or""));xmlFile:setString(key.."#risk",tostring(entry.risk or""));xmlFile:setString(key.."#verdict",tostring(entry.verdict or""));xmlFile:setFloat(key.."#cashAfter",num(entry.cashAfter,0));xmlFile:setFloat(key.."#coverageMonths",num(entry.coverageMonths,0));xmlFile:setFloat(key.."#immediateCost",num(entry.immediateCost,0));xmlFile:setFloat(key.."#addedMonthlyCost",num(entry.addedMonthlyCost,0)) end
        return result
    end

    local baseLoad = Enterprise.loadFarm
    function Enterprise:loadFarm(xmlFile,moduleKey,farmId)
        local result=baseLoad(self,xmlFile,moduleKey,farmId);if result==nil or result.ok==false then return result end
        local state=self:getState(farmId,true);state.managementAdviceHistory={}
        if xmlFile~=nil and moduleKey~=nil then state.nextAdviceId=xmlFile:getInt(moduleKey..".advisor#nextId",1);if xmlFile.iterate~=nil then xmlFile:iterate(moduleKey..".advisor.history.item",function(_,key)table.insert(state.managementAdviceHistory,{id=xmlFile:getString(key.."#id",""),periodKey=xmlFile:getInt(key.."#periodKey",0),decisionType=xmlFile:getString(key.."#decisionType",""),risk=xmlFile:getString(key.."#risk",""),verdict=xmlFile:getString(key.."#verdict",""),cashAfter=xmlFile:getFloat(key.."#cashAfter",0),coverageMonths=xmlFile:getFloat(key.."#coverageMonths",0),immediateCost=xmlFile:getFloat(key.."#immediateCost",0),addedMonthlyCost=xmlFile:getFloat(key.."#addedMonthlyCost",0)})end) end end
        return result
    end
end

if AgriLife.EnterpriseModule ~= nil then
    function AgriLife.EnterpriseModule:getManagementAdvice(...) return self.service:getManagementAdvice(...) end
    function AgriLife.EnterpriseModule:getManagementAdviceHistory(...) return self.service:getManagementAdviceHistory(...) end
end
