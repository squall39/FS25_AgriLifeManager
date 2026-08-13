-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Company6Service = {}
AgriLife.Company6Service.__index = AgriLife.Company6Service
AgriLife.Company6Service.SCHEMA_VERSION = 1

AgriLife.Company6Service.LEGAL_FORMS = {
    { id = "EI",   labelKey = "agrilife_company6_form_EI",   minMembers = 1, maxMembers = 1,  ownerRole = "owner" },
    { id = "EARL", labelKey = "agrilife_company6_form_EARL", minMembers = 1, maxMembers = 10, ownerRole = "owner" },
    { id = "GAEC", labelKey = "agrilife_company6_form_GAEC", minMembers = 2, maxMembers = 10, ownerRole = "partner" },
    { id = "SCEA", labelKey = "agrilife_company6_form_SCEA", minMembers = 2, maxMembers = 100, ownerRole = "partner" },
    { id = "SARL", labelKey = "agrilife_company6_form_SARL", minMembers = 1, maxMembers = 100, ownerRole = "owner" },
    { id = "SAS",  labelKey = "agrilife_company6_form_SAS",  minMembers = 1, maxMembers = 999, ownerRole = "owner" },
    { id = "SASU", labelKey = "agrilife_company6_form_SASU", minMembers = 1, maxMembers = 1,  ownerRole = "owner" },
    { id = "CUMA", labelKey = "agrilife_company6_form_CUMA", minMembers = 4, maxMembers = 999, ownerRole = "partner" }
}

local function safeInt(value, fallback)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return fallback or 0 end
    return math.floor(value)
end

local function cleanText(value, fallback, maxLen)
    value = tostring(value or fallback or "")
    value = value:gsub("[%c]", " "):gsub("%s+", " ")
    value = value:match("^%s*(.-)%s*$") or value
    maxLen = maxLen or 80
    if #value > maxLen then value = value:sub(1, maxLen) end
    return value
end

function AgriLife.Company6Service.new(core)
    return setmetatable({ core = core, farms = {} }, AgriLife.Company6Service)
end

function AgriLife.Company6Service:getLegalForm(formId)
    formId = tostring(formId or "EI")
    for _, form in ipairs(self.LEGAL_FORMS) do
        if form.id == formId then return form end
    end
    return self.LEGAL_FORMS[1]
end

function AgriLife.Company6Service:getFarm(farmId)
    if g_farmManager == nil or g_farmManager.getFarmById == nil then return nil end
    return g_farmManager:getFarmById(tonumber(farmId) or 0)
end

function AgriLife.Company6Service:getPeriodKey()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local year = math.max(0, safeInt(environment ~= nil and environment.currentYear or 1, 1))
    local period = math.max(1, math.min(12, safeInt(environment ~= nil and environment.currentPeriod or 1, 1)))
    return year * 12 + period
end

function AgriLife.Company6Service:getMemberCount(farmId)
    local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
    local state = economy ~= nil and economy.service ~= nil and economy.service.getFarmState ~= nil and economy.service:getFarmState(farmId, false) or nil
    return 1 + (state ~= nil and type(state.associates) == "table" and #state.associates or 0)
end

function AgriLife.Company6Service:validateLegalForm(farmId, legalFormId, memberCount)
    local form = self:getLegalForm(legalFormId)
    memberCount = math.max(1, safeInt(memberCount, self:getMemberCount(farmId)))
    if memberCount < form.minMembers then
        return AgriLife.Result.fail("COMPANY_FORM_MEMBERS_REQUIRED", string.format("La forme %s exige au moins %d membre(s)", form.id, form.minMembers), { legalFormId=form.id, memberCount=memberCount, minMembers=form.minMembers, maxMembers=form.maxMembers })
    end
    if memberCount > form.maxMembers then
        return AgriLife.Result.fail("COMPANY_FORM_MEMBERS_EXCEEDED", string.format("La forme %s autorise au maximum %d membre(s)", form.id, form.maxMembers), { legalFormId=form.id, memberCount=memberCount, minMembers=form.minMembers, maxMembers=form.maxMembers })
    end
    return AgriLife.Result.ok("COMPANY_FORM_VALID", "Legal form membership is valid", { legalFormId=form.id, memberCount=memberCount, minMembers=form.minMembers, maxMembers=form.maxMembers })
end

function AgriLife.Company6Service:createDefaultState(farmId)
    local farm = self:getFarm(farmId)
    local farmName = farm ~= nil and (farm.name or farm.farmName) or nil
    return {
        legalFormId = "EI",
        companyName = cleanText(farmName, "Exploitation agricole", 80),
        registrationName = "",
        ownerProfileId = "",
        createdPeriodKey = 0,
        updatedPeriodKey = 0
    }
end

function AgriLife.Company6Service:getFarmState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local state = self.farms[farmId]
    if state == nil and create ~= false then
        state = self:createDefaultState(farmId)
        self.farms[farmId] = state
    end
    return state
end

function AgriLife.Company6Service:setIdentity(farmId, companyName, legalFormId, ownerProfileId)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then
        return AgriLife.Result.fail("COMPANY_SERVER_REQUIRED", "Company identity can only be changed by the server")
    end
    local state = self:getFarmState(farmId, true)
    if state == nil then return AgriLife.Result.fail("COMPANY_FARM_INVALID", "Invalid farm") end
    local form = self:getLegalForm(legalFormId)
    local memberValidation = self:validateLegalForm(farmId, form.id)
    if memberValidation == nil or memberValidation.ok ~= true then return memberValidation end
    local cleanCompanyName = cleanText(companyName, state.companyName, 80)
    if cleanCompanyName == "" then return AgriLife.Result.fail("COMPANY_NAME_INVALID", "Company name is required") end
    local previousFormId = state.legalFormId
    state.companyName = cleanCompanyName
    state.legalFormId = form.id
    state.ownerProfileId = cleanText(ownerProfileId, state.ownerProfileId, 96)
    local periodKey = self:getPeriodKey()
    if safeInt(state.createdPeriodKey, 0) <= 0 then state.createdPeriodKey = periodKey end
    state.updatedPeriodKey = periodKey
    if previousFormId ~= state.legalFormId then
        local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local economyState = economy ~= nil and economy.service ~= nil and economy.service.getFarmState ~= nil and economy.service:getFarmState(farmId, true) or nil
        if economyState ~= nil then
            economyState.legalHistory = economyState.legalHistory or {}
            table.insert(economyState.legalHistory, { periodKey=periodKey, kind="LEGAL_FORM_CHANGED", note=tostring(previousFormId).." -> "..tostring(state.legalFormId) })
        end
        if economy ~= nil and economy.service ~= nil and economy.service.record ~= nil then economy.service:record(farmId, "LEGAL_FORM_CHANGED", 0, "COMPANY", state.ownerProfileId, tostring(previousFormId).." -> "..tostring(state.legalFormId)) end
    end
    return AgriLife.Result.ok("COMPANY_IDENTITY_UPDATED", "Company identity updated", { legalFormId=state.legalFormId, companyName=state.companyName, memberCount=memberValidation.details.memberCount })
end

function AgriLife.Company6Service:getSnapshot(farmId)
    local state = self:getFarmState(farmId, true)
    if state == nil then return nil end
    local form = self:getLegalForm(state.legalFormId)
    return {
        farmId = tonumber(farmId) or 0,
        companyName = state.companyName,
        legalFormId = form.id,
        legalFormLabelKey = form.labelKey,
        minMembers = form.minMembers,
        maxMembers = form.maxMembers,
        memberCount = self:getMemberCount(farmId),
        ownerProfileId = state.ownerProfileId
    }
end

function AgriLife.Company6Service:saveFarm(xmlFile, moduleKey, farmId)
    local state = self:getFarmState(farmId, true)
    if state == nil then return AgriLife.Result.fail("COMPANY_FARM_INVALID", "Invalid farm") end
    xmlFile:setString(moduleKey .. ".identity#legalFormId", tostring(state.legalFormId or "EI"))
    xmlFile:setString(moduleKey .. ".identity#companyName", tostring(state.companyName or ""))
    xmlFile:setString(moduleKey .. ".identity#registrationName", tostring(state.registrationName or ""))
    xmlFile:setString(moduleKey .. ".identity#ownerProfileId", tostring(state.ownerProfileId or ""))
    xmlFile:setInt(moduleKey .. ".identity#createdPeriodKey", safeInt(state.createdPeriodKey, 0))
    xmlFile:setInt(moduleKey .. ".identity#updatedPeriodKey", safeInt(state.updatedPeriodKey, 0))
    return AgriLife.Result.ok("COMPANY_FARM_SAVED", "Company state saved")
end

function AgriLife.Company6Service:loadFarm(xmlFile, moduleKey, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("COMPANY_CLIENT_LOAD_SKIPPED", "No company state to load") end
    local state = self:createDefaultState(farmId)
    if xmlFile ~= nil and moduleKey ~= nil then
        state.legalFormId = self:getLegalForm(xmlFile:getString(moduleKey .. ".identity#legalFormId", state.legalFormId)).id
        state.companyName = cleanText(xmlFile:getString(moduleKey .. ".identity#companyName", state.companyName), state.companyName, 80)
        state.registrationName = cleanText(xmlFile:getString(moduleKey .. ".identity#registrationName", ""), "", 80)
        state.ownerProfileId = cleanText(xmlFile:getString(moduleKey .. ".identity#ownerProfileId", ""), "", 96)
        state.createdPeriodKey = safeInt(xmlFile:getInt(moduleKey .. ".identity#createdPeriodKey", 0), 0)
        state.updatedPeriodKey = safeInt(xmlFile:getInt(moduleKey .. ".identity#updatedPeriodKey", 0), 0)
    end
    self.farms[farmId] = state
    return AgriLife.Result.ok("COMPANY_FARM_LOADED", "Company state loaded")
end

function AgriLife.Company6Service:delete()
    self.farms = {}
    self.core = nil
end
