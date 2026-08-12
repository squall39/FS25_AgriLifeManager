-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.0 - accident declarations, owner insurance authority and total-loss handling.
AgriLife = AgriLife or {}

local Workshop = AgriLife.Workshop6Service
local Insurance = AgriLife.Insurance6Service

local function text(v, fallback)
    v = tostring(v or "")
    if v ~= "" then return v end
    return tostring(fallback or "")
end

local function clamp(v, a, b)
    return math.max(a, math.min(b, tonumber(v) or a))
end

local function round(v)
    return math.floor((tonumber(v) or 0) * 100 + 0.5) / 100
end

local function getModuleService(core, id)
    local instance = core ~= nil and core.registry ~= nil and core.registry.instances ~= nil and core.registry.instances[id] or nil
    return instance ~= nil and (instance.service or instance) or nil
end

if Workshop ~= nil and Insurance ~= nil then
    Workshop.ACCIDENT_AUTHORITY_VERSION = "0.9.3.0"

    function Workshop:getPeopleService93()
        return getModuleService(self.core, "people")
    end

    function Workshop:getEnterpriseService93()
        return getModuleService(self.core, "enterprise")
    end

    function Workshop:getInsuranceService93()
        return getModuleService(self.core, "insurance")
    end

    function Workshop:getFarmOwnerProfileId93(farmId)
        local people = self:getPeopleService93()
        if people ~= nil and people.resolveFarmOwner ~= nil then
            local owner = people:resolveFarmOwner(farmId, nil, false)
            if owner ~= nil and tostring(owner) ~= "" then return tostring(owner) end
        end
        local company = getModuleService(self.core, "company")
        local snapshot = company ~= nil and company.getSnapshot ~= nil and company:getSnapshot(farmId) or nil
        return snapshot ~= nil and text(snapshot.ownerProfileId) or ""
    end

    function Workshop:getActiveAIEmployeeForAsset93(farmId, assetId)
        local enterprise = self:getEnterpriseService93()
        if enterprise == nil or enterprise.getState == nil then return nil end
        local state = enterprise:getState(farmId, false)
        if state == nil then return nil end
        for index = #(state.orders or {}), 1, -1 do
            local order = state.orders[index]
            local status = tostring(order.status or "")
            if (status == "active" or status == "starting" or status == "paused") and (tostring(order.vehicleId or "") == tostring(assetId or "") or tostring(order.toolId or "") == tostring(assetId or "")) then
                return {
                    profileId = text(order.profileId),
                    driverType = "AI_WORKER",
                    orderId = text(order.id),
                    executor = text(order.executor, "FS25")
                }
            end
        end
        return nil
    end

    function Workshop:getAccidentDriverContext93(farmId, runtimeVehicle, assetId)
        local people = self:getPeopleService93()
        if people ~= nil and people.getConnectedPlayerContexts ~= nil then
            for _, context in ipairs(people:getConnectedPlayerContexts() or {}) do
                local sameVehicle = context.vehicle == runtimeVehicle
                if not sameVehicle and context.vehicle ~= nil and runtimeVehicle ~= nil then
                    local contextRoot = context.vehicle.getRootVehicle ~= nil and context.vehicle:getRootVehicle() or context.vehicle
                    local runtimeRoot = runtimeVehicle.getRootVehicle ~= nil and runtimeVehicle:getRootVehicle() or runtimeVehicle
                    sameVehicle = contextRoot == runtimeRoot
                end
                if tonumber(context.farmId) == tonumber(farmId) and sameVehicle and text(context.profileId) ~= "" then
                    return {
                        profileId = text(context.profileId),
                        driverType = "PLAYER",
                        connected = true,
                        displayName = text(context.displayName, context.name)
                    }
                end
            end
        end
        local ai = self:getActiveAIEmployeeForAsset93(farmId, assetId)
        if ai ~= nil and ai.profileId ~= "" then return ai end
        return {
            profileId = self:getFarmOwnerProfileId93(farmId),
            driverType = "UNASSIGNED",
            connected = false
        }
    end

    function Workshop:getResponsibleProfileId(farmId, runtimeVehicle)
        local assetId = ""
        if runtimeVehicle ~= nil then
            for index, candidate in ipairs(self:getRuntimeVehicles()) do
                if candidate == runtimeVehicle then assetId = self:getVehicleId(candidate, index); break end
            end
        end
        return text(self:getAccidentDriverContext93(farmId, runtimeVehicle, assetId).profileId)
    end

    function Workshop:findAccident93(farmId, accidentId)
        if self.findAccident ~= nil then return self:findAccident(farmId, accidentId) end
        for _, accident in ipairs(self:getState(farmId, true).accidents or {}) do
            if tostring(accident.id or "") == tostring(accidentId or "") then return accident end
        end
        return nil
    end

    function Workshop:initializeAccidentAuthority93(farmId, accident)
        if type(accident) ~= "table" then return nil end
        accident.driverProfileId = text(accident.driverProfileId, accident.responsibleProfileId)
        accident.driverType = text(accident.driverType, "PLAYER")
        accident.declarationStatus = text(accident.declarationStatus, accident.statementStatus == "SUBMITTED" and "COMPLETED" or "PENDING_DRIVER")
        accident.declaredByProfileId = text(accident.declaredByProfileId)
        accident.declarationAutomatic = accident.declarationAutomatic == true
        accident.declaration = type(accident.declaration) == "table" and accident.declaration or {}
        accident.declaration.circumstanceCode = text(accident.declaration.circumstanceCode)
        accident.declaration.impactZone = text(accident.declaration.impactZone)
        accident.declaration.observationCode = text(accident.declaration.observationCode)
        accident.declaration.notes = text(accident.declaration.notes)
        accident.declaration.photoCount = math.max(0, math.floor(tonumber(accident.declaration.photoCount) or 0))
        accident.declaration.witnessCount = math.max(0, math.floor(tonumber(accident.declaration.witnessCount) or 0))
        accident.ownerNotified = accident.ownerNotified ~= false
        accident.ownerDecisionStatus = text(accident.ownerDecisionStatus, "PENDING")
        accident.preAccidentValue = math.max(0, tonumber(accident.preAccidentValue) or 0)
        accident.totalLossStatus = text(accident.totalLossStatus, "NONE")
        accident.totalLossOffer = type(accident.totalLossOffer) == "table" and accident.totalLossOffer or nil
        return accident
    end

    function Workshop:isOwnerActor93(farmId, profileId)
        local people = self:getPeopleService93()
        if people ~= nil and people.isFarmOwner ~= nil then return people:isFarmOwner(farmId, profileId) == true end
        return tostring(profileId or "") ~= "" and tostring(profileId) == tostring(self:getFarmOwnerProfileId93(farmId))
    end

    function Workshop:canDriverDeclare93(farmId, accident, actorProfileId, automatic)
        accident = self:initializeAccidentAuthority93(farmId, accident)
        actorProfileId = text(actorProfileId)
        if accident == nil or actorProfileId == "" then return false end
        if actorProfileId ~= text(accident.driverProfileId, accident.responsibleProfileId) then return false end
        if automatic == true then return accident.driverType == "AI_WORKER" end
        local people = self:getPeopleService93()
        return people == nil or people.hasPermission == nil or people:hasPermission(farmId, actorProfileId, "insurance.declareAccident") == true
    end

    function Workshop:submitAccidentDeclaration93(farmId, accidentId, actorProfileId, statement, automatic)
        local accident = self:findAccident93(farmId, accidentId)
        if accident == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_MISSING", "Accident not found") end
        accident = self:initializeAccidentAuthority93(farmId, accident)
        if accident.declarationStatus == "COMPLETED" then return AgriLife.Result.ok("WORKSHOP_ACCIDENT_DECLARATION_EXISTS", "Accident statement already recorded", {accident=accident}) end
        if not self:canDriverDeclare93(farmId, accident, actorProfileId, automatic) then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_DECLARATION_DENIED", "Only the involved driver can complete the accident statement") end
        statement = type(statement) == "table" and statement or {}
        accident.declaration = {
            circumstanceCode = text(statement.circumstanceCode, automatic and "AI_DETECTED" or "OTHER"),
            impactZone = text(statement.impactZone, automatic and "AUTO_DETECTED" or "UNKNOWN"),
            observationCode = text(statement.observationCode, automatic and "AI_TELEMETRY" or "NONE"),
            notes = text(statement.notes, automatic and "AI_WORKER_AUTOMATIC_STATEMENT" or ""),
            photoCount = math.max(0, math.floor(tonumber(statement.photoCount) or 0)),
            witnessCount = math.max(0, math.floor(tonumber(statement.witnessCount) or 0)),
            thirdPartyId = text(statement.thirdPartyId),
            thirdPartyPresent = statement.thirdPartyPresent == true,
            thirdPartyDamageAmount = math.max(0, tonumber(statement.thirdPartyDamageAmount) or 0)
        }
        accident.declaredByProfileId = text(actorProfileId)
        accident.declarationAutomatic = automatic == true
        accident.declarationStatus = "COMPLETED"
        accident.statementStatus = "READY_FOR_OWNER"
        accident.ownerNotified = true
        accident.ownerDecisionStatus = "PENDING"
        if self.addLifeEvent ~= nil then
            self:addLifeEvent(farmId, accident.assetId, automatic and "ACCIDENT_STATEMENT_AI" or "ACCIDENT_STATEMENT_PLAYER", tostring(accident.id))
        end
        self:recordEconomy(farmId, automatic and "ACCIDENT_STATEMENT_AI" or "ACCIDENT_STATEMENT_PLAYER", 0, tostring(accident.id))
        return AgriLife.Result.ok("WORKSHOP_ACCIDENT_DECLARATION_RECORDED", "Accident statement recorded and sent to the farm owner", {accident=accident, ownerDecisionRequired=true})
    end

    function Workshop:buildAutomaticAIStatement93(accident)
        return {
            circumstanceCode = "AI_JOB_ACCIDENT",
            impactZone = "AUTO_DETECTED",
            observationCode = "AI_TELEMETRY",
            notes = string.format("AI_WORKER_AUTOMATIC_STATEMENT:%s:%s", text(accident.cause, "collision"), text(accident.assetId)),
            photoCount = 0,
            witnessCount = 0
        }
    end

    function Workshop:transferAccidentDeclarationToClaim93(farmId, accident, claimId)
        local insurance = self:getInsuranceService93()
        if insurance == nil or insurance.submitAccidentStatement == nil then return nil end
        local declaration = type(accident.declaration) == "table" and accident.declaration or {}
        return insurance:submitAccidentStatement(farmId, claimId, {
            circumstanceCode = declaration.circumstanceCode,
            impactZone = declaration.impactZone,
            notes = declaration.notes,
            photoCount = declaration.photoCount,
            witnessCount = declaration.witnessCount,
            thirdPartyId = declaration.thirdPartyId,
            thirdPartyPresent = declaration.thirdPartyPresent,
            thirdPartyDamageAmount = declaration.thirdPartyDamageAmount
        })
    end

    function Workshop:getTotalLossThreshold93(farmId)
        local difficulty = self.getDifficultyId ~= nil and self:getDifficultyId(farmId) or "normal"
        if difficulty == "facile" then return 0.88 end
        if difficulty == "difficile" then return 0.72 end
        return 0.78
    end

    function Workshop:evaluateTotalLoss93(farmId, accident)
        accident = self:initializeAccidentAuthority93(farmId, accident)
        if accident == nil then return nil end
        local vehicle = self:findVehicle(farmId, accident.assetId)
        local preValue = math.max(1000, tonumber(accident.preAccidentValue) or 0)
        if preValue <= 1000 and vehicle ~= nil and self.estimateVehicleMarketValue ~= nil then preValue = math.max(1000, self:estimateVehicleMarketValue(farmId, vehicle)) end
        local repairEstimate = math.max(0, tonumber(accident.damageAmount) or 0)
        if vehicle ~= nil then
            local faults = self.getActiveFaults ~= nil and self:getActiveFaults(vehicle) or {}
            local severe = 0
            for _, fault in ipairs(faults) do if (tonumber(fault.stage) or 0) >= 3 then severe = severe + 1 end end
            repairEstimate = repairEstimate * (1 + math.min(0.35, severe * 0.06))
        end
        local ratio = repairEstimate / math.max(1, preValue)
        local threshold = self:getTotalLossThreshold93(farmId)
        if ratio < threshold then
            accident.totalLossStatus = "NOT_ECONOMIC_TOTAL_LOSS"
            accident.totalLossOffer = nil
            return {eligible=false, ratio=ratio, threshold=threshold, repairEstimate=round(repairEstimate), preAccidentValue=round(preValue)}
        end
        local insurance = self:getInsuranceService93()
        local policy = insurance ~= nil and insurance.findPolicyForAsset ~= nil and insurance:findPolicyForAsset(farmId, "vehicle", accident.assetId) or nil
        if policy == nil then
            accident.totalLossStatus = "UNINSURED_TOTAL_LOSS"
            accident.totalLossOffer = nil
            return {eligible=false, uninsured=true, ratio=ratio, threshold=threshold, repairEstimate=round(repairEstimate), preAccidentValue=round(preValue)}
        end
        local insuredBase = math.min(preValue, math.max(0, tonumber(policy.insuredValue) or preValue))
        local deductible = math.max(100, insuredBase * clamp(policy.deductible or 0, 0, 1))
        local gross = math.max(0, insuredBase * clamp(policy.coverage or 1, 0, 1) - deductible)
        accident.totalLossStatus = "OFFERED"
        accident.totalLossOffer = {
            preAccidentValue = round(preValue),
            repairEstimate = round(repairEstimate),
            repairRatio = round(ratio),
            threshold = threshold,
            policyId = text(policy.id),
            deductible = round(deductible),
            grossIndemnity = round(gross),
            ownerNetIndemnity = round(gross),
            status = "OFFERED"
        }
        return {eligible=true, offer=accident.totalLossOffer}
    end

    function Workshop:submitAccidentToInsurance93(farmId, accidentId, ownerProfileId)
        local accident = self:findAccident93(farmId, accidentId)
        if accident == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_MISSING", "Accident not found") end
        accident = self:initializeAccidentAuthority93(farmId, accident)
        if not self:isOwnerActor93(farmId, ownerProfileId) then return AgriLife.Result.fail("WORKSHOP_INSURANCE_OWNER_ONLY", "Only the farm owner can submit the accident to the insurer") end
        if accident.declarationStatus ~= "COMPLETED" then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_STATEMENT_REQUIRED", "The involved driver must complete the accident statement first") end
        if tostring(accident.claimId or "") ~= "" then return AgriLife.Result.ok("WORKSHOP_ACCIDENT_ALREADY_SUBMITTED", "Accident already submitted to insurer", {claimId=accident.claimId, accident=accident}) end
        local insurance = self:getInsuranceService93()
        if insurance == nil then return AgriLife.Result.fail("WORKSHOP_INSURANCE_UNAVAILABLE", "Insurance service unavailable") end
        local policy = insurance:findPolicyForAsset(farmId, "vehicle", accident.assetId)
        if policy == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_POLICY_MISSING", "No active vehicle policy for this accident") end
        local claimResult = insurance:fileClaim(farmId, policy.id, accident.damageAmount, accident.cause, accident.driverProfileId, accident.assetId)
        if claimResult == nil or claimResult.ok ~= true then return claimResult end
        accident.claimId = tostring(claimResult.details ~= nil and claimResult.details.claimId or "")
        accident.ownerDecisionStatus = "SUBMITTED"
        accident.statementStatus = "SUBMITTED"
        if insurance.linkAccident ~= nil then insurance:linkAccident(farmId, accident.claimId, accident) end
        self:transferAccidentDeclarationToClaim93(farmId, accident, accident.claimId)
        local totalLoss = self:evaluateTotalLoss93(farmId, accident)
        return AgriLife.Result.ok("WORKSHOP_ACCIDENT_SUBMITTED_BY_OWNER", "Accident submitted to insurer by farm owner", {claimId=accident.claimId, accident=accident, totalLoss=totalLoss})
    end

    function Workshop:getLeaseForAsset93(farmId, assetId)
        local assets = getModuleService(self.core, "assets")
        local state = assets ~= nil and assets.getState ~= nil and assets:getState(farmId, false) or nil
        if state == nil then return nil, assets end
        for _, lease in ipairs(state.leases or {}) do
            if tostring(lease.assetId or "") == tostring(assetId or "") and (lease.status == "active" or lease.status == "matured") then return lease, assets end
        end
        return nil, assets
    end

    function Workshop:markAssetWrittenOff93(farmId, assetId, accidentId, indemnity)
        local assets = getModuleService(self.core, "assets")
        local assetState = assets ~= nil and assets.getState ~= nil and assets:getState(farmId, false) or nil
        if assetState ~= nil then
            for _, purchase in ipairs(assetState.purchases or {}) do
                if tostring(purchase.assetId or "") == tostring(assetId or "") then
                    purchase.status = "written_off"
                    purchase.writtenOff = true
                    purchase.writtenOffPeriodKey = self:getPeriodKey()
                    purchase.writtenOffAccidentId = tostring(accidentId or "")
                    purchase.writtenOffIndemnity = round(indemnity)
                end
            end
            for _, lease in ipairs(assetState.leases or {}) do
                if tostring(lease.assetId or "") == tostring(assetId or "") and lease.status ~= "returned" then
                    lease.status = "written_off"
                    lease.closedPeriodKey = self:getPeriodKey()
                    lease.writtenOffAccidentId = tostring(accidentId or "")
                end
            end
        end
    end

    function Workshop:removeWrittenOffAsset93(farmId, assetId, accidentId, indemnity)
        local runtime = self:findRuntimeVehicle(farmId, assetId)
        if runtime ~= nil and runtime.delete ~= nil then
            local ok = pcall(runtime.delete, runtime)
            if not ok then return false, "runtime_delete_failed" end
        elseif runtime ~= nil then
            return false, "runtime_delete_unavailable"
        end
        self:markAssetWrittenOff93(farmId, assetId, accidentId, indemnity)
        local state = self:getState(farmId, true)
        state.vehicles[tostring(assetId)] = nil
        if state.workshopJobs ~= nil then
            for _, job in ipairs(state.workshopJobs) do
                if tostring(job.assetId or "") == tostring(assetId) and tostring(job.status or "") ~= "COMPLETED" then job.status = "CANCELLED_TOTAL_LOSS" end
            end
        end
        return true
    end

    function Workshop:acceptTotalLossOffer93(farmId, accidentId, ownerProfileId)
        local accident = self:findAccident93(farmId, accidentId)
        if accident == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_MISSING", "Accident not found") end
        accident = self:initializeAccidentAuthority93(farmId, accident)
        if not self:isOwnerActor93(farmId, ownerProfileId) then return AgriLife.Result.fail("WORKSHOP_INSURANCE_OWNER_ONLY", "Only the farm owner can accept a total-loss settlement") end
        if accident.totalLossStatus ~= "OFFERED" or type(accident.totalLossOffer) ~= "table" then return AgriLife.Result.fail("WORKSHOP_TOTAL_LOSS_OFFER_MISSING", "No total-loss settlement is available") end
        local insurance = self:getInsuranceService93()
        local claim = insurance ~= nil and insurance.getClaim ~= nil and insurance:getClaim(farmId, accident.claimId) or nil
        if claim ~= nil and claim.requiresLiability == true and tostring(claim.liabilityStatus or "UNKNOWN") == "UNKNOWN" then return AgriLife.Result.fail("WORKSHOP_TOTAL_LOSS_LIABILITY_PENDING", "Liability must be decided before total-loss settlement") end
        local offer = accident.totalLossOffer
        local gross = math.max(0, tonumber(offer.grossIndemnity) or 0)
        if claim ~= nil and claim.requiresLiability == true then
            local share = clamp(claim.liabilityShare or 0, 0, 1)
            gross = round(gross * (1 - share))
        end
        local lease, assets = self:getLeaseForAsset93(farmId, accident.assetId)
        local leaseSettlement = 0
        if lease ~= nil then
            local remaining = math.max(0, (tonumber(lease.termMonths) or 0) - (tonumber(lease.monthsPaid) or 0))
            leaseSettlement = math.min(gross, math.max(0, (tonumber(lease.residualValue) or 0) + (tonumber(lease.monthlyPayment) or 0) * remaining * 0.65 + (tonumber(lease.penalties) or 0)))
        end
        local net = round(math.max(0, gross - leaseSettlement))
        if net > 0 and (insurance == nil or insurance.addMoney == nil or not insurance:addMoney(farmId, net)) then return AgriLife.Result.fail("WORKSHOP_TOTAL_LOSS_PAYOUT_FAILED", "Total-loss settlement could not be credited") end
        local removed, reason = self:removeWrittenOffAsset93(farmId, accident.assetId, accident.id, gross)
        if not removed then
            if net > 0 and insurance ~= nil and insurance.addMoney ~= nil then insurance:addMoney(farmId, -net) end
            return AgriLife.Result.fail("WORKSHOP_TOTAL_LOSS_ASSET_REMOVE_FAILED", "Written-off asset could not be removed", {reason=reason})
        end
        accident.totalLossStatus = "ACCEPTED"
        offer.status = "ACCEPTED"
        offer.grossIndemnity = gross
        offer.leaseSettlement = round(leaseSettlement)
        offer.ownerNetIndemnity = net
        accident.ownerDecisionStatus = "TOTAL_LOSS_ACCEPTED"
        if claim ~= nil then
            claim.totalLoss = true
            claim.totalLossStatus = "ACCEPTED"
            claim.totalLossGrossPayout = gross
            claim.totalLossLeaseSettlement = round(leaseSettlement)
            claim.payout = net
            claim.status = "total_loss_paid"
            claim.settledPeriodKey = insurance:getPeriodKey()
        end
        if insurance ~= nil then
            local state = insurance:getState(farmId, true)
            state.totalPayouts = round((tonumber(state.totalPayouts) or 0) + gross)
            local policy = insurance.getPolicy ~= nil and insurance:getPolicy(farmId, offer.policyId) or nil
            if policy ~= nil then
                policy.status = "ended_total_loss"
                policy.endedPeriodKey = insurance:getPeriodKey()
                policy.endedReason = "TOTAL_LOSS"
            end
            insurance:recordEconomy(farmId, "INSURANCE_TOTAL_LOSS_PAYOUT", net, tostring(accident.id))
            if leaseSettlement > 0 then insurance:recordEconomy(farmId, "INSURANCE_TOTAL_LOSS_LESSOR_SETTLEMENT", 0, tostring(accident.id)..":"..tostring(leaseSettlement)) end
        end
        self:recordEconomy(farmId, "ASSET_WRITTEN_OFF", 0, tostring(accident.assetId))
        return AgriLife.Result.ok("WORKSHOP_TOTAL_LOSS_ACCEPTED", "Total-loss settlement accepted; asset written off and removed", {grossIndemnity=gross, leaseSettlement=round(leaseSettlement), ownerNetIndemnity=net, assetId=accident.assetId})
    end

    function Workshop:contestTotalLossOffer93(farmId, accidentId, ownerProfileId)
        local accident = self:findAccident93(farmId, accidentId)
        if accident == nil then return AgriLife.Result.fail("WORKSHOP_ACCIDENT_MISSING", "Accident not found") end
        accident = self:initializeAccidentAuthority93(farmId, accident)
        if not self:isOwnerActor93(farmId, ownerProfileId) then return AgriLife.Result.fail("WORKSHOP_INSURANCE_OWNER_ONLY", "Only the farm owner can contest a total-loss classification") end
        if accident.totalLossStatus ~= "OFFERED" then return AgriLife.Result.fail("WORKSHOP_TOTAL_LOSS_OFFER_MISSING", "No total-loss classification can be contested") end
        accident.totalLossStatus = "CONTESTED"
        accident.totalLossOffer.status = "CONTESTED"
        accident.ownerDecisionStatus = "TOTAL_LOSS_CONTESTED"
        local insurance = self:getInsuranceService93()
        if insurance ~= nil and insurance.appealClaim ~= nil and tostring(accident.claimId or "") ~= "" then pcall(insurance.appealClaim, insurance, farmId, accident.claimId) end
        return AgriLife.Result.ok("WORKSHOP_TOTAL_LOSS_CONTESTED", "Total-loss classification contested; counter-expertise requested", {accident=accident})
    end

    function Workshop:submitAccidentStatement(farmId, accidentId, statement, actorProfileId, automatic)
        actorProfileId = text(actorProfileId, type(statement) == "table" and statement.actorProfileId or "")
        return self:submitAccidentDeclaration93(farmId, accidentId, actorProfileId, statement, automatic == true)
    end

    local baseReportAccident93 = Workshop.reportAccident
    function Workshop:reportAccident(farmId, assetId, damageAmount, responsibleProfileId, cause)
        local result = baseReportAccident93(self, farmId, assetId, damageAmount, responsibleProfileId, cause)
        if result == nil or result.ok ~= true then return result end
        local accident = self:findAccident93(farmId, result.details ~= nil and result.details.accidentId or "")
        if accident == nil then return result end
        local runtime = self:findRuntimeVehicle(farmId, assetId)
        local driver = self:getAccidentDriverContext93(farmId, runtime, assetId)
        accident.driverProfileId = text(driver.profileId, responsibleProfileId)
        accident.responsibleProfileId = accident.driverProfileId
        accident.driverType = text(driver.driverType, "PLAYER")
        accident.driverOrderId = text(driver.orderId)
        accident.driverExecutor = text(driver.executor)
        accident.claimId = ""
        accident.declarationStatus = "PENDING_DRIVER"
        accident.statementStatus = "PENDING"
        accident.ownerDecisionStatus = "PENDING"
        accident.ownerNotified = true
        accident.totalLossStatus = "NONE"
        if accident.driverType == "AI_WORKER" and accident.driverProfileId ~= "" then
            self:submitAccidentDeclaration93(farmId, accident.id, accident.driverProfileId, self:buildAutomaticAIStatement93(accident), true)
            result.details.driverDeclarationAutomatic = true
        else
            result.details.driverDeclarationAutomatic = false
        end
        result.details.driverProfileId = accident.driverProfileId
        result.details.driverType = accident.driverType
        result.details.ownerDecisionRequired = true
        return result
    end

    local baseSnapshotAccident93 = Workshop.getSnapshot
    function Workshop:getSnapshot(farmId)
        local snapshot = baseSnapshotAccident93(self, farmId) or {}
        local pendingDriver, pendingOwner, totalLossOffers = 0, 0, 0
        for _, accident in ipairs(snapshot.accidents or {}) do
            self:initializeAccidentAuthority93(farmId, accident)
            if accident.declarationStatus ~= "COMPLETED" then pendingDriver = pendingDriver + 1 end
            if accident.declarationStatus == "COMPLETED" and accident.ownerDecisionStatus == "PENDING" then pendingOwner = pendingOwner + 1 end
            if accident.totalLossStatus == "OFFERED" then totalLossOffers = totalLossOffers + 1 end
        end
        snapshot.pendingDriverStatements = pendingDriver
        snapshot.pendingOwnerInsuranceDecisions = pendingOwner
        snapshot.totalLossOffers = totalLossOffers
        snapshot.accidentAuthorityVersion = Workshop.ACCIDENT_AUTHORITY_VERSION
        return snapshot
    end

    local baseSaveAccident93 = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, key, farmId)
        local result = baseSaveAccident93(self, xmlFile, key, farmId)
        if xmlFile == nil or key == nil then return result end
        local state = self:getState(farmId, true)
        for index, accident in ipairs(state.accidents or {}) do
            self:initializeAccidentAuthority93(farmId, accident)
            local k = string.format("%s.accidents.accident(%d)", key, index - 1)
            for _, field in ipairs({"driverType","driverOrderId","driverExecutor","declarationStatus","declaredByProfileId","ownerDecisionStatus","totalLossStatus"}) do xmlFile:setString(k.."#"..field, text(accident[field])) end
            xmlFile:setBool(k.."#declarationAutomatic", accident.declarationAutomatic == true)
            xmlFile:setBool(k.."#ownerNotified", accident.ownerNotified ~= false)
            xmlFile:setFloat(k.."#preAccidentValue", tonumber(accident.preAccidentValue) or 0)
            local d = accident.declaration or {}
            for _, field in ipairs({"circumstanceCode","impactZone","observationCode","notes","thirdPartyId"}) do xmlFile:setString(k..".declaration#"..field, text(d[field])) end
            xmlFile:setInt(k..".declaration#photoCount", math.floor(tonumber(d.photoCount) or 0))
            xmlFile:setInt(k..".declaration#witnessCount", math.floor(tonumber(d.witnessCount) or 0))
            xmlFile:setBool(k..".declaration#thirdPartyPresent", d.thirdPartyPresent == true)
            xmlFile:setFloat(k..".declaration#thirdPartyDamageAmount", tonumber(d.thirdPartyDamageAmount) or 0)
            local offer = accident.totalLossOffer
            if type(offer) == "table" then
                for _, field in ipairs({"preAccidentValue","repairEstimate","repairRatio","threshold","deductible","grossIndemnity","ownerNetIndemnity","leaseSettlement"}) do xmlFile:setFloat(k..".totalLoss#"..field, tonumber(offer[field]) or 0) end
                xmlFile:setString(k..".totalLoss#policyId", text(offer.policyId))
                xmlFile:setString(k..".totalLoss#status", text(offer.status))
            end
        end
        return result
    end

    local baseLoadAccident93 = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, key, farmId)
        local result = baseLoadAccident93(self, xmlFile, key, farmId)
        if xmlFile == nil or key == nil or xmlFile.iterate == nil then return result end
        local state = self:getState(farmId, true)
        local index = 0
        xmlFile:iterate(key..".accidents.accident", function(_, k)
            index = index + 1
            local accident = state.accidents[index]
            if accident ~= nil then
                for _, field in ipairs({"driverType","driverOrderId","driverExecutor","declarationStatus","declaredByProfileId","ownerDecisionStatus","totalLossStatus"}) do accident[field] = xmlFile:getString(k.."#"..field, text(accident[field])) end
                accident.declarationAutomatic = xmlFile:getBool(k.."#declarationAutomatic", false)
                accident.ownerNotified = xmlFile:getBool(k.."#ownerNotified", true)
                accident.preAccidentValue = xmlFile:getFloat(k.."#preAccidentValue", tonumber(accident.preAccidentValue) or 0)
                accident.declaration = {}
                for _, field in ipairs({"circumstanceCode","impactZone","observationCode","notes","thirdPartyId"}) do accident.declaration[field] = xmlFile:getString(k..".declaration#"..field, "") end
                accident.declaration.photoCount = xmlFile:getInt(k..".declaration#photoCount", 0)
                accident.declaration.witnessCount = xmlFile:getInt(k..".declaration#witnessCount", 0)
                accident.declaration.thirdPartyPresent = xmlFile:getBool(k..".declaration#thirdPartyPresent", false)
                accident.declaration.thirdPartyDamageAmount = xmlFile:getFloat(k..".declaration#thirdPartyDamageAmount", 0)
                local offerStatus = xmlFile:getString(k..".totalLoss#status", "")
                if offerStatus ~= "" then
                    accident.totalLossOffer = {status=offerStatus, policyId=xmlFile:getString(k..".totalLoss#policyId", "")}
                    for _, field in ipairs({"preAccidentValue","repairEstimate","repairRatio","threshold","deductible","grossIndemnity","ownerNetIndemnity","leaseSettlement"}) do accident.totalLossOffer[field] = xmlFile:getFloat(k..".totalLoss#"..field, 0) end
                end
                self:initializeAccidentAuthority93(farmId, accident)
            end
        end)
        return result
    end

    local baseChecklistAccident93 = Workshop.getRoadmap8Checklist
    function Workshop:getRoadmap8Checklist(farmId)
        local checklist = baseChecklistAccident93(self, farmId) or {}
        checklist.playerAccidentStatement = true
        checklist.aiWorkerAutomaticStatement = true
        checklist.ownerOnlyInsuranceDecision = true
        checklist.economicTotalLoss = true
        checklist.totalLossPermanentAssetRemoval = true
        checklist.accidentAuthorityVersion = Workshop.ACCIDENT_AUTHORITY_VERSION
        return checklist
    end
end

if AgriLife.WorkshopModule ~= nil then
    AgriLife.WorkshopModule.VERSION = "0.9.3.0"
    function AgriLife.WorkshopModule:submitAccidentDeclaration93(...) return self.service:submitAccidentDeclaration93(...) end
    function AgriLife.WorkshopModule:submitAccidentToInsurance93(...) return self.service:submitAccidentToInsurance93(...) end
    function AgriLife.WorkshopModule:acceptTotalLossOffer93(...) return self.service:acceptTotalLossOffer93(...) end
    function AgriLife.WorkshopModule:contestTotalLossOffer93(...) return self.service:contestTotalLossOffer93(...) end
end
