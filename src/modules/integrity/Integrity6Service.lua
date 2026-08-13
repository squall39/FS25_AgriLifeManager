-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Integrity6Service = {}
AgriLife.Integrity6Service.__index = AgriLife.Integrity6Service

AgriLife.Integrity6Runtime = AgriLife.Integrity6Runtime or {
    activeService = nil,
    hookInstalled = false
}

local function round(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function clean(value, fallback)
    value = tostring(value or "")
    return value ~= "" and value or (fallback or "")
end

function AgriLife.Integrity6Service.new(core)
    return setmetatable({
        core = core,
        farms = {},
        pollElapsed = 0,
        trustedDepth = 0,
        trustedSource = nil
    }, AgriLife.Integrity6Service)
end

function AgriLife.Integrity6Service:createDefaultState()
    return {
        baselineSet = false,
        expectedBalance = 0,
        unresolvedDifference = 0,
        totalExternalDifference = 0,
        alertCount = 0,
        acknowledgedCount = 0,
        locked = false,
        lastAlertPeriodKey = 0,
        alerts = {}
    }
end

function AgriLife.Integrity6Service:getState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    if self.farms[farmId] == nil and create ~= false then
        self.farms[farmId] = self:createDefaultState()
    end
    return self.farms[farmId]
end

function AgriLife.Integrity6Service:getFarm(farmId)
    return g_farmManager ~= nil and g_farmManager.getFarmById ~= nil and g_farmManager:getFarmById(tonumber(farmId) or 0) or nil
end

function AgriLife.Integrity6Service:getBalance(farmId)
    local farm = self:getFarm(farmId)
    return farm ~= nil and round(farm.money) or nil
end

function AgriLife.Integrity6Service:getPeriodKey()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local year = math.max(1, math.floor(tonumber(environment ~= nil and environment.currentYear) or 1))
    local period = math.max(1, math.min(12, math.floor(tonumber(environment ~= nil and environment.currentPeriod) or 1)))
    return year * 12 + period
end

function AgriLife.Integrity6Service:getEconomy()
    return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
end

function AgriLife.Integrity6Service:getPolicy(farmId)
    local economy = self:getEconomy()
    local policy = economy ~= nil and economy.getModePolicy ~= nil and economy:getModePolicy(farmId) or nil
    return policy ~= nil and clean(policy.integrityPolicy, "record") or "record"
end

function AgriLife.Integrity6Service:recordEconomy(farmId, category, amount, source, note)
    local economy = self:getEconomy()
    if economy ~= nil and economy.service ~= nil and economy.service.record ~= nil then
        economy.service:record(farmId, category, amount, source, nil, note)
    end
end

function AgriLife.Integrity6Service:setBaseline(farmId)
    local balance = self:getBalance(farmId)
    local state = self:getState(farmId, true)
    if state == nil or balance == nil then return false end
    state.expectedBalance = balance
    state.baselineSet = true
    return true
end

function AgriLife.Integrity6Service:syncExpectedBalance(farmId)
    local state = self:getState(farmId, true)
    local balance = self:getBalance(farmId)
    if state ~= nil and balance ~= nil then
        state.expectedBalance = balance
        state.baselineSet = true
    end
end

function AgriLife.Integrity6Service:getMoneyTypeName(moneyType)
    if MoneyType ~= nil then
        for name, value in pairs(MoneyType) do
            if value == moneyType and type(name) == "string" then return name end
        end
    end
    return tostring(moneyType or "UNKNOWN")
end

function AgriLife.Integrity6Service:onMoneyAdded(mission, amount, farmId, moneyType)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return end
    farmId = tonumber(farmId) or 0
    amount = round(amount)
    if farmId <= 0 or amount == 0 then return end

    local moneyTypeName = self:getMoneyTypeName(moneyType)
    if self.trustedDepth > 0 then self:syncExpectedBalance(farmId);return end

    local state=self:getState(farmId,true)
    if state~=nil and state.baselineSet~=true then self:syncExpectedBalance(farmId)
    else
        local otherType=MoneyType~=nil and MoneyType.OTHER or nil
        local unclassified=moneyType==nil or(otherType~=nil and moneyType==otherType)or string.find(string.upper(moneyTypeName),"EASY",1,true)~=nil
        if amount>=1000 and unclassified and state~=nil then
            local actual=self:getBalance(farmId);local difference=actual~=nil and round(actual-(tonumber(state.expectedBalance)or actual))or amount
            if math.abs(difference)>=0.01 then self:registerDifference(farmId,difference,"Crédit externe non classé détecté via l'API monétaire FS25 ("..moneyTypeName..")")else self:syncExpectedBalance(farmId)end
        else self:syncExpectedBalance(farmId) end
    end
    self:recordEconomy(farmId, "FS25_MONEY", amount, "FS25", moneyTypeName)
end

function AgriLife.Integrity6Service:registerDifference(farmId, difference, note)
    difference = round(difference)
    if math.abs(difference) < 0.01 then return end
    local state = self:getState(farmId, true)
    if state == nil then return end

    local policy = self:getPolicy(farmId)
    state.expectedBalance = round((tonumber(state.expectedBalance) or 0) + difference)
    state.unresolvedDifference = round((tonumber(state.unresolvedDifference) or 0) + difference)
    state.totalExternalDifference = round((tonumber(state.totalExternalDifference) or 0) + difference)
    state.alertCount = (tonumber(state.alertCount) or 0) + 1
    state.lastAlertPeriodKey = self:getPeriodKey()

    if policy == "blockSuspiciousCredit" and difference >= 1000 then
        state.locked = true
    end

    table.insert(state.alerts, {
        periodKey = state.lastAlertPeriodKey,
        amount = difference,
        policy = policy,
        note = clean(note, "Direct company balance change outside the FS25 money API")
    })
    while #state.alerts > 40 do table.remove(state.alerts, 1) end

    local economy = self:getEconomy()
    if economy ~= nil and economy.service ~= nil and economy.service.recordExternalDifference ~= nil then
        economy.service:recordExternalDifference(farmId, difference, note)
    else
        self:recordEconomy(farmId, "EXTERNAL_DIFFERENCE", difference, "INTEGRITY", note)
    end
end

function AgriLife.Integrity6Service:pollFarm(farmId)
    local state = self:getState(farmId, true)
    local balance = self:getBalance(farmId)
    if state == nil or balance == nil then return end
    if not state.baselineSet then
        state.baselineSet = true
        state.expectedBalance = balance
        return
    end

    local difference = round(balance - (tonumber(state.expectedBalance) or balance))
    if math.abs(difference) >= 0.01 then
        self:registerDifference(farmId, difference, "Écart direct détecté entre le solde FS25 et le registre AgriLife")
    end
end

function AgriLife.Integrity6Service:update(dt)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return end
    self.pollElapsed = (tonumber(self.pollElapsed) or 0) + (tonumber(dt) or 0)
    if self.pollElapsed < 1500 then return end
    self.pollElapsed = 0
    for _, farmId in ipairs(self.core.context:getFarmIds()) do self:pollFarm(farmId) end
end

function AgriLife.Integrity6Service:canPerformFinancialAction(farmId)
    local state = self:getState(farmId, true)
    if state ~= nil and state.locked == true then
        return AgriLife.Result.fail("INTEGRITY_RECONCILIATION_REQUIRED", "Un écart financier suspect doit être rapproché avant cette opération", {
            unresolvedDifference = state.unresolvedDifference
        })
    end
    return AgriLife.Result.ok("INTEGRITY_CLEAR", "Financial integrity is clear")
end

function AgriLife.Integrity6Service:reconcile(farmId, actorProfileId, note)
    local people = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.people or nil
    if people == nil or people.service == nil or people.service.hasPermission == nil or not people.service:hasPermission(farmId, actorProfileId, "company.manage") then
        return AgriLife.Result.fail("INTEGRITY_PERMISSION", "Insufficient permission to reconcile the company ledger")
    end

    local state = self:getState(farmId, true)
    if state == nil then return AgriLife.Result.fail("INTEGRITY_STATE_MISSING", "Integrity state unavailable") end
    local amount = round(state.unresolvedDifference)
    if math.abs(amount) < 0.01 and not state.locked then
        return AgriLife.Result.ok("INTEGRITY_ALREADY_CLEAR", "Le registre est déjà rapproché")
    end

    state.unresolvedDifference = 0
    state.locked = false
    state.acknowledgedCount = (tonumber(state.acknowledgedCount) or 0) + 1
    self:syncExpectedBalance(farmId)
    self:recordEconomy(farmId, "INTEGRITY_RECONCILED", -amount, "INTEGRITY", clean(note, "Rapprochement manuel par " .. clean(actorProfileId, "owner")))
    return AgriLife.Result.ok("INTEGRITY_RECONCILED", "Le registre financier a été rapproché", {amount = amount})
end

function AgriLife.Integrity6Service:getSnapshot(farmId)
    local state = self:getState(farmId, true)
    return {
        farmId = tonumber(farmId) or 0,
        baselineSet = state.baselineSet == true,
        expectedBalance = round(state.expectedBalance),
        actualBalance = self:getBalance(farmId),
        unresolvedDifference = round(state.unresolvedDifference),
        totalExternalDifference = round(state.totalExternalDifference),
        alertCount = tonumber(state.alertCount) or 0,
        acknowledgedCount = tonumber(state.acknowledgedCount) or 0,
        locked = state.locked == true,
        policy = self:getPolicy(farmId),
        alerts = state.alerts
    }
end

function AgriLife.Integrity6Service:sanitize(state)
    if type(state) ~= "table" then state = self:createDefaultState() end
    state.baselineSet = state.baselineSet == true
    state.expectedBalance = round(state.expectedBalance)
    state.unresolvedDifference = round(state.unresolvedDifference)
    state.totalExternalDifference = round(state.totalExternalDifference)
    state.alertCount = math.max(0, math.floor(tonumber(state.alertCount) or 0))
    state.acknowledgedCount = math.max(0, math.floor(tonumber(state.acknowledgedCount) or 0))
    state.locked = state.locked == true
    state.lastAlertPeriodKey = math.max(0, math.floor(tonumber(state.lastAlertPeriodKey) or 0))
    state.alerts = state.alerts or {}
    return state
end

function AgriLife.Integrity6Service:saveFarm(xmlFile, key, farmId)
    local state = self:sanitize(self:getState(farmId, true))
    local root = key .. ".state"
    xmlFile:setBool(root .. "#baselineSet", state.baselineSet)
    xmlFile:setFloat(root .. "#expectedBalance", state.expectedBalance)
    xmlFile:setFloat(root .. "#unresolvedDifference", state.unresolvedDifference)
    xmlFile:setFloat(root .. "#totalExternalDifference", state.totalExternalDifference)
    xmlFile:setInt(root .. "#alertCount", state.alertCount)
    xmlFile:setInt(root .. "#acknowledgedCount", state.acknowledgedCount)
    xmlFile:setBool(root .. "#locked", state.locked)
    xmlFile:setInt(root .. "#lastAlertPeriodKey", state.lastAlertPeriodKey)
    for index, alert in ipairs(state.alerts) do
        local alertKey = string.format("%s.alerts.alert(%d)", key, index - 1)
        xmlFile:setInt(alertKey .. "#periodKey", tonumber(alert.periodKey) or 0)
        xmlFile:setFloat(alertKey .. "#amount", tonumber(alert.amount) or 0)
        xmlFile:setString(alertKey .. "#policy", clean(alert.policy, "record"))
        xmlFile:setString(alertKey .. "#note", clean(alert.note))
    end
    return AgriLife.Result.ok("INTEGRITY_SAVED", "Financial integrity state saved")
end

function AgriLife.Integrity6Service:loadFarm(xmlFile, key, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("INTEGRITY_LOAD_SKIPPED", "No farm") end
    local state = self:createDefaultState()
    if xmlFile ~= nil and key ~= nil then
        local root = key .. ".state"
        state.baselineSet = xmlFile:getBool(root .. "#baselineSet", false)
        state.expectedBalance = xmlFile:getFloat(root .. "#expectedBalance", 0)
        state.unresolvedDifference = xmlFile:getFloat(root .. "#unresolvedDifference", 0)
        state.totalExternalDifference = xmlFile:getFloat(root .. "#totalExternalDifference", 0)
        state.alertCount = xmlFile:getInt(root .. "#alertCount", 0)
        state.acknowledgedCount = xmlFile:getInt(root .. "#acknowledgedCount", 0)
        state.locked = xmlFile:getBool(root .. "#locked", false)
        state.lastAlertPeriodKey = xmlFile:getInt(root .. "#lastAlertPeriodKey", 0)
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(key .. ".alerts.alert", function(_, alertKey)
                table.insert(state.alerts, {
                    periodKey = xmlFile:getInt(alertKey .. "#periodKey", 0),
                    amount = xmlFile:getFloat(alertKey .. "#amount", 0),
                    policy = xmlFile:getString(alertKey .. "#policy", "record"),
                    note = xmlFile:getString(alertKey .. "#note", "")
                })
            end)
        end
    end
    self.farms[farmId] = self:sanitize(state)
    return AgriLife.Result.ok("INTEGRITY_LOADED", "Financial integrity state loaded")
end

function AgriLife.Integrity6Service:installMoneyHook()
    AgriLife.Integrity6Runtime.activeService = self
    if AgriLife.Integrity6Runtime.hookInstalled then return true end
    local missionClass=FSBaseMission or BaseMission
    if Utils == nil or Utils.appendedFunction == nil or missionClass == nil or missionClass.addMoney == nil then
        return false
    end
    missionClass.addMoney = Utils.appendedFunction(missionClass.addMoney, function(mission, amount, farmId, moneyType)
        local active = AgriLife ~= nil and AgriLife.Integrity6Runtime ~= nil and AgriLife.Integrity6Runtime.activeService or nil
        if active ~= nil then active:onMoneyAdded(mission, amount, farmId, moneyType) end
    end)
    AgriLife.Integrity6Runtime.hookInstalled = true
    return true
end

function AgriLife.Integrity6Service.executeTrusted(core, farmId, source, callback)
    local service = AgriLife.Integrity6Runtime ~= nil and AgriLife.Integrity6Runtime.activeService or nil
    if service ~= nil and service.core == core then
        service.trustedDepth = service.trustedDepth + 1
        service.trustedSource = clean(source, "AGRILIFE")
    end
    local ok, result = pcall(callback)
    if service ~= nil and service.core == core then
        service.trustedDepth = math.max(0, service.trustedDepth - 1)
        if service.trustedDepth == 0 then service.trustedSource = nil end
        service:syncExpectedBalance(farmId)
    end
    return ok, result
end

function AgriLife.Integrity6Service:delete()
    if AgriLife.Integrity6Runtime ~= nil and AgriLife.Integrity6Runtime.activeService == self then
        AgriLife.Integrity6Runtime.activeService = nil
    end
    self.farms = {}
    self.core = nil
end
