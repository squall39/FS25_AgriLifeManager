-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.Qualifications6Service = {}
AgriLife.Qualifications6Service.__index = AgriLife.Qualifications6Service

local function clamp(value, minimum, maximum) return math.max(minimum, math.min(maximum, tonumber(value) or minimum)) end
local function clean(value, default, maxLength) local text = tostring(value or default or ""); if maxLength ~= nil and #text > maxLength then text = string.sub(text, 1, maxLength) end; return text end
local function round(value) return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100 end

AgriLife.Qualifications6Service.DEFINITIONS = {
    phytosanitary = {titleKey = "agrilife_qualification_phytosanitary", minLevel = 3, baseCost = 700, permanent = true, category = "cropCare"},
    handling = {titleKey = "agrilife_qualification_handling", minLevel = 2, baseCost = 450, permanent = true, category = "handling"},
    forestry = {titleKey = "agrilife_qualification_forestry", minLevel = 4, baseCost = 900, permanent = true, category = "forestry"},
    transport = {titleKey = "agrilife_qualification_transport", minLevel = 3, baseCost = 650, permanent = true, category = "transport"},
    harvest = {titleKey = "agrilife_qualification_harvest", minLevel = 3, baseCost = 600, permanent = true, category = "harvest"},
    publicWorks = {titleKey = "agrilife_qualification_public_works", minLevel = 5, baseCost = 1100, permanent = true, category = "handling"}
}

function AgriLife.Qualifications6Service.new(core) return setmetatable({core = core, farms = {}}, AgriLife.Qualifications6Service) end
function AgriLife.Qualifications6Service:createDefaultState() return {nextRecordId = 1, profiles = {}, history = {}} end
function AgriLife.Qualifications6Service:getState(farmId, create) farmId = tonumber(farmId) or 0; if farmId <= 0 then return nil end; local state = self.farms[farmId]; if state == nil and create ~= false then state = self:createDefaultState(); self.farms[farmId] = state end; return state end
function AgriLife.Qualifications6Service:getProfileState(farmId, profileId, create)
    local state = self:getState(farmId, create); if state == nil then return nil end
    profileId = clean(profileId, "", 96); if profileId == "" then return nil end
    local profile = state.profiles[profileId]
    if profile == nil and create ~= false then profile = {qualifications = {}, attempts = {}, trainingHours = 0}; state.profiles[profileId] = profile end
    return profile
end
function AgriLife.Qualifications6Service:getPeriodKey() local environment = g_currentMission ~= nil and g_currentMission.environment or nil; local year = math.max(1, math.floor(tonumber(environment ~= nil and environment.currentYear) or 1)); local period = math.max(1, math.min(12, math.floor(tonumber(environment ~= nil and environment.currentPeriod) or 1))); return year * 12 + period end
function AgriLife.Qualifications6Service:getModeId(farmId) local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil; local snapshot = economy ~= nil and economy.getSnapshot ~= nil and economy:getSnapshot(farmId) or nil; return snapshot ~= nil and snapshot.modeId or "normal" end
function AgriLife.Qualifications6Service:getCareerSnapshot(farmId, profileId) local career = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.career or nil; return career ~= nil and career.getSnapshot ~= nil and career:getSnapshot(farmId, profileId) or nil end
function AgriLife.Qualifications6Service:getExamSnapshot(farmId, profileId) local exams = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.exams or nil; return exams ~= nil and exams.getSnapshot ~= nil and exams:getSnapshot(farmId, profileId) or nil end

function AgriLife.Qualifications6Service:hasGeneralLicence(farmId, profileId)
    local snapshot = self:getExamSnapshot(farmId, profileId)
    return snapshot ~= nil and (snapshot.licenceStatus == "obtained" or snapshot.licenceObtained == true or snapshot.hasLicence == true)
end

function AgriLife.Qualifications6Service:hasQualification(farmId, profileId, qualificationId)
    if qualificationId == nil or qualificationId == "" then return true end
    if qualificationId == "tractor" then return self:hasGeneralLicence(farmId, profileId) end
    local profile = self:getProfileState(farmId, profileId, false)
    local item = profile ~= nil and profile.qualifications[tostring(qualificationId)] or nil
    if item == nil or item.status ~= "obtained" then return false end
    if item.validUntilPeriodKey ~= nil and item.validUntilPeriodKey > 0 and self:getPeriodKey() > item.validUntilPeriodKey then return false end
    return true
end

function AgriLife.Qualifications6Service:getTrainingCost(farmId, qualificationId)
    local definition = self.DEFINITIONS[tostring(qualificationId or "")]; if definition == nil then return nil end
    local modeId = self:getModeId(farmId); local factor = modeId == "facile" and 0.65 or (modeId == "difficile" and 1.35 or 1)
    return round(definition.baseCost * factor)
end

function AgriLife.Qualifications6Service:getEligibility(farmId, profileId, qualificationId)
    local definition = self.DEFINITIONS[tostring(qualificationId or "")]
    if definition == nil then return {eligible = false, reason = "unknown", cost = 0} end
    if self:hasQualification(farmId, profileId, qualificationId) then return {eligible = false, reason = "already_obtained", cost = 0} end
    local career = self:getCareerSnapshot(farmId, profileId)
    local level = tonumber(career ~= nil and career.level) or 1
    local licenceRequired = self:getModeId(farmId) ~= "facile"
    if licenceRequired and not self:hasGeneralLicence(farmId, profileId) then return {eligible = false, reason = "general_licence_required", cost = self:getTrainingCost(farmId, qualificationId), requiredLevel = definition.minLevel} end
    if level < definition.minLevel then return {eligible = false, reason = "level_low", cost = self:getTrainingCost(farmId, qualificationId), requiredLevel = definition.minLevel, currentLevel = level} end
    return {eligible = true, reason = "ok", cost = self:getTrainingCost(farmId, qualificationId), requiredLevel = definition.minLevel, currentLevel = level}
end

function AgriLife.Qualifications6Service:chargeTraining(farmId, profileId, amount)
    amount = round(math.max(0, tonumber(amount) or 0))
    local economyModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
    local economy = economyModule ~= nil and economyModule.service or nil
    local ownerProfileId = economy ~= nil and economy.getOwnerProfileId ~= nil and tostring(economy:getOwnerProfileId(farmId) or "") or ""
    profileId = tostring(profileId or "")
    if economy ~= nil and profileId ~= "" and profileId == ownerProfileId and economy.getPersonalAccount ~= nil and economy.addPersonalMoney ~= nil then
        local account = economy:getPersonalAccount(farmId, profileId, true)
        if account ~= nil and (tonumber(account.balance) or 0) + 0.01 >= amount then
            local result = economy:addPersonalMoney(farmId, profileId, -amount, "QUALIFICATION_TRAINING", "Qualification professionnelle")
            return result ~= nil and result.ok == true
        end
        return false
    end
    local payrollModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.payroll or nil
    local payroll = payrollModule ~= nil and payrollModule.service or nil
    if payroll ~= nil and payroll.getFarmState ~= nil then
        local state = payroll:getFarmState(farmId, true); local employee = state ~= nil and state.employees ~= nil and state.employees[profileId] or nil
        if employee ~= nil and economy ~= nil and economy.addCompanyMoney ~= nil then
            local farm = g_farmManager ~= nil and g_farmManager.getFarmById ~= nil and g_farmManager:getFarmById(tonumber(farmId) or 0) or nil
            if farm ~= nil and (tonumber(farm.money) or 0) + 0.01 >= amount and economy:addCompanyMoney(farmId, -amount) then
                if economy.record ~= nil then economy:record(farmId, "EMPLOYEE_TRAINING", -amount, "QUALIFICATIONS", profileId, "Professional qualification training") end
                return true
            end
        end
    end
    return false
end

function AgriLife.Qualifications6Service:recordHistory(farmId, profileId, qualificationId, kind, cost, score)
    local state = self:getState(farmId, true)
    local record = {id = string.format("QUAL_%d_%06d", farmId, state.nextRecordId), periodKey = self:getPeriodKey(), profileId = tostring(profileId), qualificationId = tostring(qualificationId), kind = tostring(kind), cost = round(cost or 0), score = clamp(score or 0, 0, 100)}
    state.nextRecordId = state.nextRecordId + 1; table.insert(state.history, record); while #state.history > 180 do table.remove(state.history, 1) end; return record
end

function AgriLife.Qualifications6Service:completeTraining(farmId, profileId, qualificationId, score)
    local eligibility = self:getEligibility(farmId, profileId, qualificationId)
    if not eligibility.eligible then return AgriLife.Result.fail("QUALIFICATION_NOT_ELIGIBLE", eligibility.reason, eligibility) end
    score = clamp(score or 100, 0, 100)
    local modeId = self:getModeId(farmId); local threshold = modeId == "facile" and 60 or (modeId == "difficile" and 82 or 72)
    local profile = self:getProfileState(farmId, profileId, true)
    profile.attempts[qualificationId] = (tonumber(profile.attempts[qualificationId]) or 0) + 1
    if not self:chargeTraining(farmId, profileId, eligibility.cost) then return AgriLife.Result.fail("QUALIFICATION_FUNDS_LOW", "Insufficient personal funds", {cost = eligibility.cost}) end
    if score < threshold then self:recordHistory(farmId, profileId, qualificationId, "failed", eligibility.cost, score); return AgriLife.Result.fail("QUALIFICATION_FAILED", "Qualification failed", {score = score, threshold = threshold, cost = eligibility.cost}) end
    local definition = self.DEFINITIONS[qualificationId]
    profile.qualifications[qualificationId] = {status = "obtained", obtainedPeriodKey = self:getPeriodKey(), validUntilPeriodKey = definition.permanent and 0 or (self:getPeriodKey() + 36), score = score, attempts = profile.attempts[qualificationId]}
    self:recordHistory(farmId, profileId, qualificationId, "obtained", eligibility.cost, score)
    local journal = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.journal or nil
    if journal ~= nil and journal.record ~= nil then journal:record(farmId, "QUALIFICATION", "agrilife_journal_qualification_title", "agrilife_journal_qualification_msg", "info", "QUALIFICATIONS", -eligibility.cost, qualificationId) end
    return AgriLife.Result.ok("QUALIFICATION_OBTAINED", "Qualification obtained", {qualificationId = qualificationId, score = score, cost = eligibility.cost})
end

function AgriLife.Qualifications6Service:getSnapshot(farmId, profileId)
    local profile = self:getProfileState(farmId, profileId, true)
    local available = {}
    for id, definition in pairs(self.DEFINITIONS) do local eligibility = self:getEligibility(farmId, profileId, id); table.insert(available, {id = id, titleKey = definition.titleKey, category = definition.category, obtained = self:hasQualification(farmId, profileId, id), eligibility = eligibility}) end
    table.sort(available, function(a, b) return a.id < b.id end)
    return {generalLicence = self:hasGeneralLicence(farmId, profileId), qualifications = profile.qualifications, attempts = profile.attempts, available = available, history = self:getState(farmId, true).history}
end

function AgriLife.Qualifications6Service:saveFarm(xmlFile, moduleKey, farmId)
    if xmlFile == nil or moduleKey == nil then return AgriLife.Result.ok("QUALIFICATIONS_SAVE_SKIPPED", "No save target") end
    local state = self:getState(farmId, true); xmlFile:setInt(moduleKey .. ".state#nextRecordId", state.nextRecordId)
    local profileIndex = 0
    for profileId, profile in pairs(state.profiles) do
        local profileKey = string.format("%s.profiles.profile(%d)", moduleKey, profileIndex); xmlFile:setString(profileKey .. "#profileId", profileId); xmlFile:setFloat(profileKey .. "#trainingHours", profile.trainingHours or 0)
        local qIndex = 0; for qualificationId, item in pairs(profile.qualifications) do local key = string.format("%s.qualifications.qualification(%d)", profileKey, qIndex); xmlFile:setString(key .. "#id", qualificationId); xmlFile:setString(key .. "#status", item.status or "obtained"); xmlFile:setInt(key .. "#obtainedPeriodKey", item.obtainedPeriodKey or 0); xmlFile:setInt(key .. "#validUntilPeriodKey", item.validUntilPeriodKey or 0); xmlFile:setFloat(key .. "#score", item.score or 0); xmlFile:setInt(key .. "#attempts", item.attempts or 0); qIndex = qIndex + 1 end
        local aIndex = 0; for qualificationId, attempts in pairs(profile.attempts) do local key = string.format("%s.attempts.attempt(%d)", profileKey, aIndex); xmlFile:setString(key .. "#id", qualificationId); xmlFile:setInt(key .. "#count", attempts or 0); aIndex = aIndex + 1 end
        profileIndex = profileIndex + 1
    end
    for index, record in ipairs(state.history) do local key = string.format("%s.history.record(%d)", moduleKey, index - 1); xmlFile:setString(key .. "#id", record.id); xmlFile:setInt(key .. "#periodKey", record.periodKey); xmlFile:setString(key .. "#profileId", record.profileId); xmlFile:setString(key .. "#qualificationId", record.qualificationId); xmlFile:setString(key .. "#kind", record.kind); xmlFile:setFloat(key .. "#cost", record.cost); xmlFile:setFloat(key .. "#score", record.score) end
    return AgriLife.Result.ok("QUALIFICATIONS_SAVED", "Qualifications saved")
end

function AgriLife.Qualifications6Service:loadFarm(xmlFile, moduleKey, farmId)
    farmId = tonumber(farmId) or 0; if farmId <= 0 then return AgriLife.Result.ok("QUALIFICATIONS_CLIENT_LOAD_SKIPPED", "No farm qualification data") end
    local state = self:createDefaultState()
    if xmlFile ~= nil and moduleKey ~= nil then
        state.nextRecordId = xmlFile:getInt(moduleKey .. ".state#nextRecordId", 1)
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".profiles.profile", function(_, profileKey)
                local profileId = xmlFile:getString(profileKey .. "#profileId", ""); if profileId == "" then return end
                local profile = {qualifications = {}, attempts = {}, trainingHours = xmlFile:getFloat(profileKey .. "#trainingHours", 0)}
                xmlFile:iterate(profileKey .. ".qualifications.qualification", function(_, key) local id = xmlFile:getString(key .. "#id", ""); if id ~= "" then profile.qualifications[id] = {status = xmlFile:getString(key .. "#status", "obtained"), obtainedPeriodKey = xmlFile:getInt(key .. "#obtainedPeriodKey", 0), validUntilPeriodKey = xmlFile:getInt(key .. "#validUntilPeriodKey", 0), score = xmlFile:getFloat(key .. "#score", 0), attempts = xmlFile:getInt(key .. "#attempts", 0)} end end)
                xmlFile:iterate(profileKey .. ".attempts.attempt", function(_, key) local id = xmlFile:getString(key .. "#id", ""); if id ~= "" then profile.attempts[id] = xmlFile:getInt(key .. "#count", 0) end end)
                state.profiles[profileId] = profile
            end)
            xmlFile:iterate(moduleKey .. ".history.record", function(_, key) table.insert(state.history, {id = xmlFile:getString(key .. "#id", ""), periodKey = xmlFile:getInt(key .. "#periodKey", 0), profileId = xmlFile:getString(key .. "#profileId", ""), qualificationId = xmlFile:getString(key .. "#qualificationId", ""), kind = xmlFile:getString(key .. "#kind", "obtained"), cost = xmlFile:getFloat(key .. "#cost", 0), score = xmlFile:getFloat(key .. "#score", 0)}) end)
        end
    end
    self.farms[farmId] = state; return AgriLife.Result.ok("QUALIFICATIONS_LOADED", "Qualifications loaded")
end
function AgriLife.Qualifications6Service:delete() self.farms = {}; self.core = nil end

do
    local baseCompleteTraining = AgriLife.Qualifications6Service.completeTraining
    local baseGetSnapshot = AgriLife.Qualifications6Service.getSnapshot
    function AgriLife.Qualifications6Service:completeTraining(farmId, profileId, qualificationId, score)
        if self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer then return AgriLife.Result.fail("QUALIFICATION_SERVER_REQUIRED", "Server authority required") end
        local result = baseCompleteTraining(self, farmId, profileId, qualificationId, score)
        if result ~= nil and result.ok then
            local career = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.career or nil
            if career ~= nil and career.service ~= nil and career.service.recordQualification ~= nil then career.service:recordQualification(farmId, profileId, qualificationId) end
            local enterprise = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.enterprise or nil
            if enterprise ~= nil and enterprise.changeReputation ~= nil then enterprise:changeReputation(farmId, 0.20, "QUALIFICATION_OBTAINED", qualificationId) end
        end
        return result
    end
    function AgriLife.Qualifications6Service:getSnapshot(farmId, profileId)
        local snapshot = baseGetSnapshot(self, farmId, profileId)
        local count = 0
        for _, item in pairs(snapshot.qualifications or {}) do if item.status == "obtained" then count = count + 1 end end
        snapshot.qualificationCount = count
        snapshot.totalQualifications = count
        return snapshot
    end
end
