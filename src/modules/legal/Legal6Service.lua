-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Legal6Service = {}
AgriLife.Legal6Service.__index = AgriLife.Legal6Service

local function round(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

local function clean(value, default)
    value = tostring(value or "")
    return value ~= "" and value or (default or "")
end

AgriLife.Legal6Service.STAGES = {
    current = 0,
    reminder = 1,
    formal_notice = 2,
    bailiff = 3,
    seizure = 4
}

function AgriLife.Legal6Service.new(core)
    return setmetatable({core = core, farms = {}}, AgriLife.Legal6Service)
end

function AgriLife.Legal6Service:createDefaultState()
    return {
        nextCaseId = 1,
        lastProcessedPeriodKey = 0,
        currentTaxProvision = 0,
        unpaidTaxes = 0,
        totalTaxesPaid = 0,
        totalPenaltiesPaid = 0,
        socialChargesPaid = 0,
        cases = {},
        history = {}
    }
end

function AgriLife.Legal6Service:getState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    if self.farms[farmId] == nil and create ~= false then
        self.farms[farmId] = self:createDefaultState()
    end
    return self.farms[farmId]
end

function AgriLife.Legal6Service:getFarm(farmId)
    return g_farmManager ~= nil and g_farmManager.getFarmById ~= nil and g_farmManager:getFarmById(tonumber(farmId) or 0) or nil
end

function AgriLife.Legal6Service:getPeriodKey()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local year = math.max(1, math.floor(tonumber(environment ~= nil and environment.currentYear) or 1))
    local period = clamp(math.floor(tonumber(environment ~= nil and environment.currentPeriod) or 1), 1, 12)
    return year * 12 + period
end

function AgriLife.Legal6Service:addMoney(farmId, amount)
    if g_currentMission ~= nil and g_currentMission.addMoney ~= nil then
        local callback = function() return g_currentMission:addMoney(amount, farmId, MoneyType ~= nil and (MoneyType.OTHER or MoneyType.PROPERTY_MAINTENANCE) or nil, true, true) end
        local ok, result
        if AgriLife.Integrity6Service ~= nil and AgriLife.Integrity6Service.executeTrusted ~= nil then ok, result = AgriLife.Integrity6Service.executeTrusted(self.core, farmId, "LEGAL", callback) else ok, result = pcall(callback) end
        return ok and result ~= false
    end
    local farm = self:getFarm(farmId)
    if farm ~= nil and farm.changeBalance ~= nil then
        local callback = function() return farm:changeBalance(amount, MoneyType ~= nil and MoneyType.OTHER or nil) end
        local ok, result
        if AgriLife.Integrity6Service ~= nil and AgriLife.Integrity6Service.executeTrusted ~= nil then ok, result = AgriLife.Integrity6Service.executeTrusted(self.core, farmId, "LEGAL", callback) else ok, result = pcall(callback) end
        return ok and result ~= false
    end
    return false
end

function AgriLife.Legal6Service:recordEconomy(farmId, category, amount, note)
    local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
    if economy ~= nil and economy.service ~= nil and economy.service.record ~= nil then
        economy.service:record(farmId, category, amount, "LEGAL", nil, note)
    end
end

function AgriLife.Legal6Service:getMode(farmId)
    local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
    local snapshot = economy ~= nil and economy.getSnapshot ~= nil and economy:getSnapshot(farmId) or nil
    return snapshot ~= nil and AgriLife.Economy6Service ~= nil and AgriLife.Economy6Service.MODES[snapshot.modeId] or nil
end

function AgriLife.Legal6Service:addHistory(state, kind, amount, note)
    table.insert(state.history, {
        periodKey = self:getPeriodKey(),
        kind = clean(kind, "OTHER"),
        amount = round(amount),
        note = clean(note)
    })
    while #state.history > 180 do table.remove(state.history, 1) end
end

function AgriLife.Legal6Service:findOpenCase(state)
    for _, case in ipairs(state.cases) do
        if case.status == "open" then return case end
    end
    return nil
end

function AgriLife.Legal6Service:openCase(farmId, amount, reason)
    local state = self:getState(farmId, true)
    local existing = self:findOpenCase(state)
    if existing ~= nil then
        existing.debt = round(existing.debt + math.max(0, tonumber(amount) or 0))
        existing.reason = clean(reason, existing.reason)
        return existing
    end
    local case = {
        id = string.format("LEGAL_%d_%05d", farmId, state.nextCaseId),
        status = "open",
        stage = "reminder",
        debt = round(math.max(0, tonumber(amount) or 0)),
        penalties = 0,
        reason = clean(reason, "Dette fiscale"),
        openedPeriodKey = self:getPeriodKey(),
        lastStagePeriodKey = self:getPeriodKey()
    }
    state.nextCaseId = state.nextCaseId + 1
    table.insert(state.cases, case)
    self:addHistory(state, "CASE_OPENED", case.debt, case.reason)
    return case
end

function AgriLife.Legal6Service:calculateMonthlyProvision(farmId)
    local farm = self:getFarm(farmId)
    local cash = math.max(0, tonumber(farm ~= nil and farm.money) or 0)
    local bank = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.bank or nil
    local bankSnapshot = bank ~= nil and bank.getSnapshot ~= nil and bank:getSnapshot(farmId) or nil
    local debt = math.max(0, tonumber(bankSnapshot ~= nil and bankSnapshot.agriLifeDebt) or 0)
    local mode = self:getMode(farmId)
    local modeFactor = mode ~= nil and (mode.taxRate or 0.18) / 0.18 or 1
    local taxableCapacity = math.max(0, cash - debt * 0.20 - 50000)
    return round((45 + taxableCapacity * 0.0015) * modeFactor)
end

function AgriLife.Legal6Service:processCase(case, periodKey, farmId)
    if case == nil or case.status ~= "open" or periodKey <= (case.lastStagePeriodKey or 0) then return end
    local stage = self.STAGES[case.stage] or 1
    stage = math.min(self.STAGES.seizure, stage + 1)
    for name, value in pairs(self.STAGES) do
        if value == stage then case.stage = name break end
    end
    local mode=self:getMode(farmId);local lateFeeFactor=mode~=nil and(tonumber(mode.lateFeeFactor)or 1)or 1
    case.penalties = round((case.penalties or 0) + (case.debt or 0) * (stage >= self.STAGES.bailiff and 0.04 or 0.015)*lateFeeFactor)
    case.lastStagePeriodKey = periodKey
end

function AgriLife.Legal6Service:processPeriodForFarm(farmId, periodKey)
    local economy=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.economy or nil;if economy~=nil and economy.isModuleAvailable~=nil and not economy:isModuleAvailable(farmId,"company") then return end
    if self.core ~= nil and self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then return end
    local state = self:getState(farmId, true)
    if state.lastProcessedPeriodKey <= 0 then state.lastProcessedPeriodKey = periodKey - 1 end
    if periodKey <= state.lastProcessedPeriodKey then return end
    for _ = 1, math.min(12, periodKey - state.lastProcessedPeriodKey) do
        local provision = self:calculateMonthlyProvision(farmId)
        state.currentTaxProvision = provision
        local farm = self:getFarm(farmId)
        if provision > 0 and farm ~= nil and (tonumber(farm.money) or 0) + 0.01 >= provision and self:addMoney(farmId, -provision) then
            state.totalTaxesPaid = round(state.totalTaxesPaid + provision)
            self:addHistory(state, "BUSINESS_TAX", provision, "Provision fiscale mensuelle")
            self:recordEconomy(farmId, "BUSINESS_TAX", -provision, "Provision fiscale mensuelle")
        else
            state.unpaidTaxes = round(state.unpaidTaxes + provision)
            self:openCase(farmId, provision, "Provision fiscale impayée")
        end
        self:processCase(self:findOpenCase(state), periodKey, farmId)
    end
    state.lastProcessedPeriodKey = periodKey
end

function AgriLife.Legal6Service:onPeriodChanged()
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return end
    local periodKey = self:getPeriodKey()
    for _, farmId in ipairs(self.core.context:getFarmIds()) do
        self:processPeriodForFarm(farmId, periodKey)
    end
end

function AgriLife.Legal6Service:settleDebt(farmId, requestedAmount)
    local state = self:getState(farmId, true)
    local case = self:findOpenCase(state)
    if case == nil then return AgriLife.Result.fail("LEGAL_NO_OPEN_CASE", "Aucune dette contentieuse") end
    local total = round((case.debt or 0) + (case.penalties or 0))
    local amount = math.min(total, math.max(0, tonumber(requestedAmount) or total))
    local farm = self:getFarm(farmId)
    if amount <= 0 or farm == nil or (tonumber(farm.money) or 0) + 0.01 < amount or not self:addMoney(farmId, -amount) then
        return AgriLife.Result.fail("LEGAL_FUNDS_LOW", "Trésorerie insuffisante pour régler la dette", {amount = amount})
    end
    local penaltyPart = math.min(case.penalties or 0, amount)
    case.penalties = round(math.max(0, (case.penalties or 0) - penaltyPart))
    case.debt = round(math.max(0, (case.debt or 0) - (amount - penaltyPart)))
    state.unpaidTaxes = round(math.max(0, state.unpaidTaxes - (amount - penaltyPart)))
    state.totalPenaltiesPaid = round(state.totalPenaltiesPaid + penaltyPart)
    if case.debt + case.penalties <= 0.01 then
        case.status = "closed"
        case.closedPeriodKey = self:getPeriodKey()
    end
    self:addHistory(state, "LEGAL_PAYMENT", amount, case.id)
    self:recordEconomy(farmId, "LEGAL_PAYMENT", -amount, case.id)
    return AgriLife.Result.ok("LEGAL_DEBT_PAID", "Paiement contentieux enregistré", {amount = amount, remaining = case.debt + case.penalties})
end

function AgriLife.Legal6Service:getSnapshot(farmId)
    local state = self:getState(farmId, true)
    local openCase = self:findOpenCase(state)
    return {
        farmId = tonumber(farmId) or 0,
        currentTaxProvision = state.currentTaxProvision,
        unpaidTaxes = state.unpaidTaxes,
        totalTaxesPaid = state.totalTaxesPaid,
        totalPenaltiesPaid = state.totalPenaltiesPaid,
        openCases = openCase ~= nil and 1 or 0,
        stage = openCase ~= nil and openCase.stage or "current",
        debt = openCase ~= nil and round((openCase.debt or 0) + (openCase.penalties or 0)) or 0,
        cases = state.cases,
        history = state.history
    }
end

function AgriLife.Legal6Service:sanitize(state)
    if type(state) ~= "table" then state = self:createDefaultState() end
    state.nextCaseId = math.max(1, math.floor(tonumber(state.nextCaseId) or 1))
    state.lastProcessedPeriodKey = math.max(0, math.floor(tonumber(state.lastProcessedPeriodKey) or 0))
    state.currentTaxProvision = math.max(0, tonumber(state.currentTaxProvision) or 0)
    state.unpaidTaxes = math.max(0, tonumber(state.unpaidTaxes) or 0)
    state.totalTaxesPaid = math.max(0, tonumber(state.totalTaxesPaid) or 0)
    state.totalPenaltiesPaid = math.max(0, tonumber(state.totalPenaltiesPaid) or 0)
    state.socialChargesPaid = math.max(0, tonumber(state.socialChargesPaid) or 0)
    state.cases = state.cases or {}
    state.history = state.history or {}
    return state
end

function AgriLife.Legal6Service:saveFarm(xmlFile, key, farmId)
    local state = self:sanitize(self:getState(farmId, true))
    local root = key .. ".state"
    xmlFile:setInt(root .. "#nextCaseId", state.nextCaseId)
    xmlFile:setInt(root .. "#lastProcessedPeriodKey", state.lastProcessedPeriodKey)
    xmlFile:setFloat(root .. "#currentTaxProvision", state.currentTaxProvision)
    xmlFile:setFloat(root .. "#unpaidTaxes", state.unpaidTaxes)
    xmlFile:setFloat(root .. "#totalTaxesPaid", state.totalTaxesPaid)
    xmlFile:setFloat(root .. "#totalPenaltiesPaid", state.totalPenaltiesPaid)
    xmlFile:setFloat(root .. "#socialChargesPaid", state.socialChargesPaid)
    for index, case in ipairs(state.cases) do
        local caseKey = string.format("%s.cases.case(%d)", key, index - 1)
        for _, name in ipairs({"id", "status", "stage", "reason"}) do xmlFile:setString(caseKey .. "#" .. name, clean(case[name])) end
        for _, name in ipairs({"debt", "penalties"}) do xmlFile:setFloat(caseKey .. "#" .. name, tonumber(case[name]) or 0) end
        for _, name in ipairs({"openedPeriodKey", "lastStagePeriodKey", "closedPeriodKey"}) do xmlFile:setInt(caseKey .. "#" .. name, math.floor(tonumber(case[name]) or 0)) end
    end
    for index, entry in ipairs(state.history) do
        local historyKey = string.format("%s.history.entry(%d)", key, index - 1)
        xmlFile:setInt(historyKey .. "#periodKey", math.floor(tonumber(entry.periodKey) or 0))
        xmlFile:setString(historyKey .. "#kind", clean(entry.kind))
        xmlFile:setFloat(historyKey .. "#amount", tonumber(entry.amount) or 0)
        xmlFile:setString(historyKey .. "#note", clean(entry.note))
    end
    return AgriLife.Result.ok("LEGAL_SAVED", "Fiscalité et contentieux sauvegardés")
end

function AgriLife.Legal6Service:loadFarm(xmlFile, key, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("LEGAL_LOAD_SKIPPED", "Aucune ferme") end
    local state = self:createDefaultState()
    if xmlFile ~= nil and key ~= nil then
        local root = key .. ".state"
        state.nextCaseId = xmlFile:getInt(root .. "#nextCaseId", 1)
        state.lastProcessedPeriodKey = xmlFile:getInt(root .. "#lastProcessedPeriodKey", 0)
        state.currentTaxProvision = xmlFile:getFloat(root .. "#currentTaxProvision", 0)
        state.unpaidTaxes = xmlFile:getFloat(root .. "#unpaidTaxes", 0)
        state.totalTaxesPaid = xmlFile:getFloat(root .. "#totalTaxesPaid", 0)
        state.totalPenaltiesPaid = xmlFile:getFloat(root .. "#totalPenaltiesPaid", 0)
        state.socialChargesPaid = xmlFile:getFloat(root .. "#socialChargesPaid", 0)
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(key .. ".cases.case", function(_, caseKey)
                table.insert(state.cases, {
                    id = xmlFile:getString(caseKey .. "#id", ""), status = xmlFile:getString(caseKey .. "#status", "open"), stage = xmlFile:getString(caseKey .. "#stage", "reminder"), reason = xmlFile:getString(caseKey .. "#reason", ""),
                    debt = xmlFile:getFloat(caseKey .. "#debt", 0), penalties = xmlFile:getFloat(caseKey .. "#penalties", 0), openedPeriodKey = xmlFile:getInt(caseKey .. "#openedPeriodKey", 0), lastStagePeriodKey = xmlFile:getInt(caseKey .. "#lastStagePeriodKey", 0), closedPeriodKey = xmlFile:getInt(caseKey .. "#closedPeriodKey", 0)
                })
            end)
            xmlFile:iterate(key .. ".history.entry", function(_, historyKey)
                table.insert(state.history, {periodKey = xmlFile:getInt(historyKey .. "#periodKey", 0), kind = xmlFile:getString(historyKey .. "#kind", "OTHER"), amount = xmlFile:getFloat(historyKey .. "#amount", 0), note = xmlFile:getString(historyKey .. "#note", "")})
            end)
        end
    end
    self.farms[farmId] = self:sanitize(state)
    return AgriLife.Result.ok("LEGAL_LOADED", "Fiscalité et contentieux chargés")
end

function AgriLife.Legal6Service:delete()
    self.farms = {}
    self.core = nil
end
