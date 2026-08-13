-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.Dashboard6Service = {}
AgriLife.Dashboard6Service.__index = AgriLife.Dashboard6Service

local function module(core, id)
    return core ~= nil and core.registry ~= nil and core.registry.instances ~= nil and core.registry.instances[id] or nil
end

local function snapshot(instance, farmId)
    if instance ~= nil and instance.getSnapshot ~= nil then
        local ok, value = pcall(instance.getSnapshot, instance, farmId)
        if ok then return value end
    end
    return nil
end

function AgriLife.Dashboard6Service.new(core)
    return setmetatable({core = core}, AgriLife.Dashboard6Service)
end

function AgriLife.Dashboard6Service:getSnapshot(farmId)
    farmId = tonumber(farmId) or 0
    local bank = snapshot(module(self.core, "bank"), farmId) or {}
    local enterprise = snapshot(module(self.core, "enterprise"), farmId) or {}
    local career = snapshot(module(self.core, "career"), farmId) or {}
    local exams = snapshot(module(self.core, "exams"), farmId) or {}
    local qualifications = snapshot(module(self.core, "qualifications"), farmId) or {}
    local administration = snapshot(module(self.core, "administration"), farmId) or {}
    local contracts = snapshot(module(self.core, "commercialContracts"), farmId) or {}
    local market = snapshot(module(self.core, "market"), farmId) or {}
    local workshop = snapshot(module(self.core, "workshop"), farmId) or {}
    local assets = snapshot(module(self.core, "assets"), farmId) or {}
    local economy = snapshot(module(self.core, "economy"), farmId) or {}
    local relation = module(self.core, "bank") ~= nil and module(self.core, "bank").getRelationshipSnapshot ~= nil and module(self.core, "bank"):getRelationshipSnapshot(farmId) or nil

    local qualificationCount = 0
    if type(qualifications.qualifications) == "table" then
        for _, item in pairs(qualifications.qualifications) do
            if type(item) == "table" and tostring(item.status or "obtained") == "obtained" then qualificationCount = qualificationCount + 1 end
        end
    end
    if qualificationCount == 0 and type(qualifications.available) == "table" then
        for _, item in ipairs(qualifications.available) do if item.obtained == true then qualificationCount = qualificationCount + 1 end end
    end
    local administrationStatus = administration.statusId or administration.businessStatus or "small_farm"
    local administrationOpenSanctions = administration.openSanctions or administration.openSanctionCount or 0
    local administrationOpenEvents = administration.openEvents or administration.openEventCount or 0
    local unpaidSanctionAmount = 0
    for _, sanction in ipairs(administration.sanctions or {}) do
        if sanction.status ~= "paid" and sanction.status ~= "cancelled" then unpaidSanctionAmount = unpaidSanctionAmount + math.max(0, tonumber(sanction.amount) or 0) end
    end
    local insuranceCompliant = administration.insurance ~= nil and administration.insurance.compliant
    if insuranceCompliant == nil then insuranceCompliant = administration.insuranceCompliant end

    return {
        farmId = farmId,
        difficulty = economy.modeId,
        startupReady = economy.ready == true,
        cards = {
            bank = {
                cash = bank.cash or 0, debt = bank.agriLifeDebt or 0, score = bank.score or 0, rating = bank.rating or "standard",
                providerName = bank.providerName or bank.providerId or "", advisorName = bank.advisorName or bank.advisorId or "",
                providerReputationStars = bank.providerReputationStars or bank.providerStars or 0,
                providerCompetenceStars = bank.providerCompetenceStars or bank.providerStars or 0,
                advisorReputationStars = bank.advisorReputationStars or bank.advisorStars or 0,
                advisorCompetenceStars = bank.advisorCompetenceStars or bank.advisorStars or 0,
                relationship = relation,
                accountingResult = bank.accounting ~= nil and bank.accounting.current ~= nil and bank.accounting.current.profit or 0,
                outstandingTax = bank.accounting ~= nil and bank.accounting.outstandingTax or 0,
                cashflowForecast = bank.accounting ~= nil and bank.accounting.cashflow ~= nil and bank.accounting.cashflow.projectedNet or 0,
                netWorth = bank.accounting ~= nil and bank.accounting.balance ~= nil and bank.accounting.balance.netWorth or 0
            },
            enterprise = {
                employees = enterprise.activeEmployees or 0, available = enterprise.availableEmployees or 0,
                busy = enterprise.busyEmployees or 0, activeOrders = enterprise.activeOrders or 0,
                candidates = enterprise.candidateCount or 0, reputation = enterprise.reputation or 50
            },
            careerQualifications = {
                level = career.level or 1, totalXP = career.totalXP or 0, generalLicence = exams.licenceStatus or "unknown",
                examRunning = exams.examRunning == true, examProgress = exams.progress or 0, bestScore = exams.bestScore or exams.score or 0, lastResultScore = exams.lastResultScore or exams.bestScore or exams.score or 0,
                qualificationCount = qualificationCount,
                careerRecord = career.careerRecord
            },
            administration = {
                compliance = administration.complianceScore or 0, businessStatus = administrationStatus,
                statusLabelKey = administration.statusLabelKey,
                administrativeHealth = administration.health ~= nil and administration.health.score or administration.complianceScore or 0,
                businessSuspended = administration.restrictions ~= nil and administration.restrictions.businessSuspended == true,
                openSanctions = administrationOpenSanctions, unpaidAmount = unpaidSanctionAmount,
                openEvents = administrationOpenEvents, insuranceCompliant = insuranceCompliant
            },
            contractsMarkets = {
                activeContracts = contracts.activeContracts or 0, completedContracts = contracts.completedContracts or 0,
                failedContracts = contracts.failedContracts or 0, penaltyDue = contracts.penaltyDue or 0,
                commoditiesIndex = market.categories ~= nil and market.categories.commodities ~= nil and market.categories.commodities.index or 1,
                inputIndex = market.categories ~= nil and market.categories.inputs ~= nil and market.categories.inputs.index or 1,
                fuelIndex = market.categories ~= nil and market.categories.fuel ~= nil and market.categories.fuel.index or 1,
                opportunityCount = contracts.opportunityCount or 0
            },
            workshop = {
                vehicleCount = workshop.vehicleCount or 0, serviceDue = workshop.serviceDue or 0,
                breakdowns = workshop.breakdowns or 0, immobilized = workshop.immobilized or 0,
                activeLeases = assets.activeLeases or 0, usedOffers = assets.usedOfferCount or 0,
                fleetMarketValue = workshop.fleetMarketValue or 0,
                marketAssetMultiplier = workshop.marketAssetMultiplier or 1,
                inventory = workshop.inventory
            }
        }
    }
end

function AgriLife.Dashboard6Service:loadFarm(xmlFile, moduleKey, farmId) return AgriLife.Result.ok("DASHBOARD_LOAD_OK", "Dashboard has no persistent state") end
function AgriLife.Dashboard6Service:saveFarm(xmlFile, moduleKey, farmId) return AgriLife.Result.ok("DASHBOARD_SAVE_OK", "Dashboard has no persistent state") end
function AgriLife.Dashboard6Service:delete() self.core = nil end
