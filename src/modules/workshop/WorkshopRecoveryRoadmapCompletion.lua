-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Workshop 8.1 recovery and towing completion.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.RECOVERY_VERSION = "0.9.2.0"

    local function round(value) return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100 end
    local function lower(value) return string.lower(tostring(value or "")):gsub("\\", "/") end
    local function tr(key)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(key or "")
    end

    function Workshop:getRuntimePosition(runtime)
        if runtime ~= nil and runtime.rootNode ~= nil and getWorldTranslation ~= nil then
            local ok, x, y, z = pcall(getWorldTranslation, runtime.rootNode)
            if ok then return x, y, z end
        end
        return nil, nil, nil
    end

    function Workshop:getOwnedWorkshopPlaceable(farmId)
        local placeables = g_currentMission ~= nil and g_currentMission.placeableSystem ~= nil and g_currentMission.placeableSystem.placeables or {}
        local best = nil
        local bestLevel = 0
        for _, placeable in pairs(type(placeables) == "table" and placeables or {}) do
            local owner = tonumber(placeable.ownerFarmId) or 0
            if placeable.getOwnerFarmId ~= nil then local ok, value = pcall(placeable.getOwnerFarmId, placeable); if ok then owner = tonumber(value) or owner end end
            if owner == tonumber(farmId) then
                local typeName = lower(placeable.typeName or placeable.configFileName)
                local level = 0
                if placeable.spec_workshop ~= nil or placeable.spec_vehicleWorkshop ~= nil or string.find(typeName, "workshop", 1, true) ~= nil then level = 3
                elseif placeable.spec_oilServicePoint6 ~= nil then level = 2 end
                if level > bestLevel and placeable.rootNode ~= nil then best = placeable; bestLevel = level end
            end
        end
        return best, bestLevel
    end

    function Workshop:getDealerRecoveryPosition()
        local mission = g_currentMission
        if mission == nil then return nil, nil, nil end
        local collections = {
            mission.storeSpawnPlaces,
            mission.vehicleSpawnPlaces,
            mission.shopController ~= nil and mission.shopController.spawnPlaces or nil,
            mission.vehicleShopBase ~= nil and mission.vehicleShopBase.spawnPlaces or nil
        }
        for _, collection in ipairs(collections) do
            if type(collection) == "table" then
                for _, place in pairs(collection) do
                    local node = type(place) == "table" and (place.startNode or place.node or place.rootNode or place.start) or place
                    if node ~= nil and getWorldTranslation ~= nil then
                        local ok, x, y, z = pcall(getWorldTranslation, node)
                        if ok then return x, y, z end
                    end
                    if type(place) == "table" and tonumber(place.x) ~= nil and tonumber(place.z) ~= nil then return tonumber(place.x), tonumber(place.y) or 0, tonumber(place.z) end
                end
            end
        end
        return nil, nil, nil
    end

    function Workshop:getRecoveryDestinationPosition(farmId, destination)
        destination = string.upper(tostring(destination or "DEALER"))
        if destination == "INTERNAL" then
            local placeable = self:getOwnedWorkshopPlaceable(farmId)
            if placeable ~= nil and placeable.rootNode ~= nil and getWorldTranslation ~= nil then
                local ok, x, y, z = pcall(getWorldTranslation, placeable.rootNode)
                if ok then return x + 4, y + 1, z + 4, placeable end
            end
            return nil, nil, nil, nil
        end
        local x, y, z = self:getDealerRecoveryPosition()
        return x, y, z, nil
    end

    function Workshop:getRecoveryQuote(farmId, assetId, destination, urgency)
        local vehicle = self:findVehicle(farmId, assetId)
        local runtime = self:findRuntimeVehicle(farmId, assetId)
        if vehicle == nil then return nil end
        destination = string.upper(tostring(destination or "DEALER"))
        urgency = string.upper(tostring(urgency or "STANDARD"))
        local sx, _, sz = self:getRuntimePosition(runtime)
        local dx, _, dz = self:getRecoveryDestinationPosition(farmId, destination)
        local distanceKm = destination == "INTERNAL" and 2.0 or 5.0
        if sx ~= nil and dx ~= nil then distanceKm = math.max(0.25, math.sqrt((sx-dx)^2 + (sz-dz)^2) / 1000) end
        local urgencyFactor = urgency == "EXPRESS" and 1.45 or (urgency == "PRIORITY" and 1.20 or 1)
        local base = 145 + distanceKm * 24 + math.max(0, tonumber(vehicle.value) or 0) * 0.0007
        local cost = round(base * self:getDifficultyPolicy(farmId).labor * urgencyFactor)
        local travelHours = math.max(0.35, distanceKm / (urgency == "EXPRESS" and 42 or urgency == "PRIORITY" and 34 or 26))
        local delayHours = round(travelHours + (urgency == "EXPRESS" and 0.25 or urgency == "PRIORITY" and 0.55 or 1.1))
        return {assetId=assetId, destination=destination, urgency=urgency, distanceKm=round(distanceKm), cost=cost, delayHours=delayHours}
    end

    function Workshop:requestRecovery(farmId, assetId, urgency, profileId, destination)
        local state = self:getState(farmId, true)
        local vehicle = self:findVehicle(farmId, assetId)
        if vehicle == nil then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_ASSET_MISSING", tr("agrilife_workshop81_recovery_asset_missing")) end
        if tostring(vehicle.currentWorkshopJobId or "") ~= "" then return AgriLife.Result.fail("WORKSHOP8_JOB_ACTIVE", tr("agrilife_workshop81_job_active")) end
        local effects = self:aggregateFaultEffects(vehicle)
        local requiresRecovery = vehicle.immobilized == true or effects.immobilize == true or effects.lockStart == true or effects.stopEngine == true or vehicle.technicalInspectionStatus == "CRITICAL" or vehicle.technicalInspectionStatus == "EXPIRED_CRITICAL"
        if not requiresRecovery then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_NOT_REQUIRED", tr("agrilife_workshop81_recovery_not_required")) end

        destination = string.upper(tostring(destination or "DEALER"))
        if destination ~= "DEALER" and destination ~= "INTERNAL" then destination = "DEALER" end
        if destination == "INTERNAL" then
            local infrastructure = self:getInternalWorkshopInfrastructure(farmId)
            if infrastructure == nil or infrastructure.available ~= true or (tonumber(infrastructure.level) or 0) < 2 then
                return AgriLife.Result.fail("WORKSHOP81_RECOVERY_INTERNAL_UNAVAILABLE", tr("agrilife_workshop81_recovery_internal_unavailable"), {infrastructure=infrastructure})
            end
        end

        local quote = self:getRecoveryQuote(farmId, assetId, destination, urgency)
        if quote == nil then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_QUOTE_FAILED", tr("agrilife_workshop81_recovery_quote_failed")) end
        if not self:debitWorkshop(farmId, quote.cost, "WORKSHOP_RECOVERY", tostring(assetId)) then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_FUNDS_LOW", tr("agrilife_workshop81_recovery_funds_low"), {cost=quote.cost}) end

        local id = string.format("RECOVERY_%d_%06d", farmId, state.nextWorkshopJobId)
        state.nextWorkshopJobId = state.nextWorkshopJobId + 1
        local now = self:getGameMinuteStamp()
        local job = {
            id=id, assetId=assetId, kind="RECOVERY", provider="RECOVERY_SERVICE", mechanicProfileId="", qualityId="OEM",
            urgency=quote.urgency, status="IN_PROGRESS", createdGameMinute=round(now), startedGameMinute=round(now),
            dueGameMinute=round(now + quote.delayHours * 60), completedGameMinute=0, laborHours=quote.delayHours,
            laborCost=quote.cost, partsCost=0, deliveryCost=0, totalCost=quote.cost, parts={}, partOrderIds={}, partsConsumed=true,
            recoveryDestination=destination, recoveryDistanceKm=quote.distanceKm, assistancePaid=0,
            options={recoveryDestination=destination, requestedByProfileId=tostring(profileId or "")}
        }
        table.insert(state.workshopJobs, job)
        vehicle.currentWorkshopJobId = id
        vehicle.downtimePeriods = math.max(1, tonumber(vehicle.downtimePeriods) or 0)
        vehicle.recoveryDestination = destination
        self:addLifeEvent(farmId, assetId, "RECOVERY_REQUESTED", id .. ":" .. destination .. ":" .. tostring(quote.distanceKm))
        return AgriLife.Result.ok("WORKSHOP81_RECOVERY_CREATED", tr("agrilife_workshop81_recovery_created"), {job=job, quote=quote})
    end

    function Workshop:moveRuntimeAssetToRecoveryDestination(farmId, assetId, destination)
        local runtime = self:findRuntimeVehicle(farmId, assetId)
        if runtime == nil or runtime.rootNode == nil or setWorldTranslation == nil then return false, "runtime_missing" end
        local x, y, z = self:getRecoveryDestinationPosition(farmId, destination)
        if x == nil then return false, "destination_missing" end
        if getTerrainHeightAtWorldPos ~= nil and g_terrainNode ~= nil then
            local ok, height = pcall(getTerrainHeightAtWorldPos, g_terrainNode, x, 0, z)
            if ok and tonumber(height) ~= nil then y = math.max(tonumber(y) or 0, tonumber(height) + 0.5) end
        end
        local ok = pcall(setWorldTranslation, runtime.rootNode, x, y or 0, z)
        if ok and runtime.raiseActive ~= nil then pcall(runtime.raiseActive, runtime) end
        return ok, ok and "" or "transfer_failed"
    end

    local basePerformJobCompletionRecovery = Workshop.performJobCompletion
    function Workshop:performJobCompletion(farmId, job)
        if job ~= nil and tostring(job.kind or "") == "RECOVERY" then
            local vehicle = self:findVehicle(farmId, job.assetId)
            if vehicle == nil then job.status = "FAILED"; return end
            local moved, reason = self:moveRuntimeAssetToRecoveryDestination(farmId, job.assetId, job.recoveryDestination or (job.options ~= nil and job.options.recoveryDestination) or "DEALER")
            if not moved then
                job.status = "WAITING_DESTINATION"
                job.recoveryTransferPending = true
                job.dueGameMinute = round(self:getGameMinuteStamp() + 5)
                job.recoveryLastError = tostring(reason or "destination_missing")
                return
            end
            local destination = string.upper(tostring(job.recoveryDestination or "DEALER"))
            vehicle.recoveredToWorkshop = true
            vehicle.recoveryLocation = destination
            vehicle.lastRecoveryPeriodKey = self:getPeriodKey()
            vehicle.currentWorkshopJobId = ""
            vehicle.downtimePeriods = 0
            job.status = "COMPLETED"
            job.recoveryTransferPending = false
            job.completedGameMinute = round(self:getGameMinuteStamp())
            self:addLifeEvent(farmId, job.assetId, "RECOVERY_COMPLETED", job.id .. ":" .. destination)

            local insurance = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.insurance or nil
            local service = insurance ~= nil and (insurance.service or insurance) or nil
            if service ~= nil and service.settleWorkshopAssistance ~= nil then
                local ok, result = pcall(service.settleWorkshopAssistance, service, farmId, job.assetId, job.totalCost, job.id)
                if ok and type(result) == "table" and result.ok == true then
                    job.assistancePaid = tonumber(result.details ~= nil and result.details.payout) or 0
                    job.assistancePolicyId = tostring(result.details ~= nil and result.details.policyId or "")
                end
            end
            return
        end
        return basePerformJobCompletionRecovery(self, farmId, job)
    end

    local baseUpdateWorkshopJobsRecovery = Workshop.updateWorkshopJobs
    function Workshop:updateWorkshopJobs(farmId, now)
        local state = self:getState(farmId, true)
        for _, job in ipairs(state.workshopJobs or {}) do
            if job.kind == "RECOVERY" and job.status == "WAITING_DESTINATION" and now >= (tonumber(job.dueGameMinute) or 0) then
                job.status = "IN_PROGRESS"
            end
        end
        return baseUpdateWorkshopJobsRecovery(self, farmId, now)
    end

    local baseGetContinuityOptionsRecovery = Workshop.getContinuityOptions
    function Workshop:getContinuityOptions(farmId, assetId)
        local result = baseGetContinuityOptionsRecovery(self, farmId, assetId) or {}
        if result.canRequestRecovery == true then
            result.recoveryQuotes = {
                dealer=self:getRecoveryQuote(farmId, assetId, "DEALER", "STANDARD"),
                internal=self:getRecoveryQuote(farmId, assetId, "INTERNAL", "STANDARD")
            }
            local infrastructure = self:getInternalWorkshopInfrastructure(farmId)
            result.internalRecoveryAvailable = infrastructure ~= nil and infrastructure.available == true and (tonumber(infrastructure.level) or 0) >= 2
        end
        return result
    end

    local baseSaveFarmRecovery = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveFarmRecovery(self, xmlFile, moduleKey, farmId)
        local state = self:getState(farmId, true)
        for index, job in ipairs(state.workshopJobs or {}) do
            local key = string.format("%s.roadmap8.jobs.job(%d)", moduleKey, index - 1)
            xmlFile:setString(key .. "#recoveryDestination", tostring(job.recoveryDestination or ""))
            xmlFile:setFloat(key .. "#recoveryDistanceKm", tonumber(job.recoveryDistanceKm) or 0)
            xmlFile:setFloat(key .. "#assistancePaid", tonumber(job.assistancePaid) or 0)
            xmlFile:setString(key .. "#assistancePolicyId", tostring(job.assistancePolicyId or ""))
            xmlFile:setBool(key .. "#recoveryTransferPending", job.recoveryTransferPending == true)
            xmlFile:setString(key .. "#recoveryLastError", tostring(job.recoveryLastError or ""))
        end
        for assetId, vehicle in pairs(state.vehicles or {}) do
            local vehicleIndex = 0
            for id in pairs(state.vehicles or {}) do
                if tostring(id) == tostring(assetId) then break end
                vehicleIndex = vehicleIndex + 1
            end
            vehicle.recoveryLocation = tostring(vehicle.recoveryLocation or "")
        end
        return result
    end

    local baseLoadFarmRecovery = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadFarmRecovery(self, xmlFile, moduleKey, farmId)
        local state = self:getState(farmId, true)
        if xmlFile ~= nil and xmlFile.iterate ~= nil then
            local index = 0
            xmlFile:iterate(moduleKey .. ".roadmap8.jobs.job", function(_, key)
                index = index + 1
                local job = state.workshopJobs[index]
                if job ~= nil then
                    job.recoveryDestination = xmlFile:getString(key .. "#recoveryDestination", tostring(job.options ~= nil and job.options.recoveryDestination or ""))
                    job.recoveryDistanceKm = xmlFile:getFloat(key .. "#recoveryDistanceKm", 0)
                    job.assistancePaid = xmlFile:getFloat(key .. "#assistancePaid", 0)
                    job.assistancePolicyId = xmlFile:getString(key .. "#assistancePolicyId", "")
                    job.recoveryTransferPending = xmlFile:getBool(key .. "#recoveryTransferPending", false)
                    job.recoveryLastError = xmlFile:getString(key .. "#recoveryLastError", "")
                    if job.options == nil then job.options = {} end
                    if job.recoveryDestination ~= "" then job.options.recoveryDestination = job.recoveryDestination end
                end
            end)
        end
        return result
    end
end

if AgriLife.WorkshopModule ~= nil then
    function AgriLife.WorkshopModule:getRecoveryQuote(...) return self.service:getRecoveryQuote(...) end
    function AgriLife.WorkshopModule:requestRecovery(...) return self.service:requestRecovery(...) end
end
