-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Workshop 8.1 turnaround times and dealer replacement equipment.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.TURNAROUND_LOANER_VERSION = "0.9.2.0"

    local function round(value)
        return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
    end

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function upper(value)
        return string.upper(tostring(value or ""))
    end

    local function runtimeUniqueId(vehicle)
        if vehicle == nil then return "" end
        if vehicle.getUniqueId ~= nil then
            local ok, value = pcall(vehicle.getUniqueId, vehicle)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(vehicle.uniqueId or vehicle.savegameId or vehicle.id or "")
    end

    local function tr(key)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(key or "")
    end

    local TIMED_JOB_KINDS = {
        REPAIR=true,
        ANNUAL_REVIEW=true,
        TYRE_REPLACEMENT=true,
        RECALL=true,
        DIAGNOSTIC_FULL=true
    }

    local baseCreateDefaultStateTurnaround = Workshop.createDefaultState
    function Workshop:createDefaultState()
        local state = baseCreateDefaultStateTurnaround(self)
        state.nextDealerLoanerId = 1
        state.dealerLoaners = {}
        return state
    end

    local baseSanitizeTurnaround = Workshop.sanitize
    function Workshop:sanitize(state)
        state = baseSanitizeTurnaround(self, state)
        state.nextDealerLoanerId = math.max(1, math.floor(tonumber(state.nextDealerLoanerId) or 1))
        state.dealerLoaners = type(state.dealerLoaners) == "table" and state.dealerLoaners or {}
        return state
    end

    function Workshop:getWorkshopModeId81(farmId)
        local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local service = economy ~= nil and (economy.service or economy) or nil
        local snapshot = service ~= nil and service.getSnapshot ~= nil and service:getSnapshot(farmId) or nil
        return tostring(snapshot ~= nil and snapshot.modeId or "normal")
    end

    function Workshop:getDealerTurnaroundFactor81(urgency)
        urgency = upper(urgency or "STANDARD")
        if urgency == "EXPRESS" then return 0.48 end
        if urgency == "PRIORITY" then return 0.58 end
        return 0.68
    end

    function Workshop:getInternalTurnaroundRatio81(farmId, profileId, vehicle, kind)
        local infrastructure = self:getInternalWorkshopInfrastructure(farmId) or {level=0}
        local mechanic = self:getMechanicCapability(farmId, profileId) or {level=1, skill=35}
        local toolingLevel = clamp(infrastructure.level or 0, 0, 3)
        local mechanicLevel = clamp(mechanic.level or 1, 1, 3)
        local ratio = 3.0
        ratio = ratio - math.max(0, toolingLevel - 1) * 0.22
        ratio = ratio - math.max(0, mechanicLevel - 1) * 0.23
        if mechanic.owner == true then ratio = ratio + 0.08 end
        if upper(kind) == "DIAGNOSTIC_FULL" then ratio = ratio - 0.10 end
        return round(clamp(ratio, 2.0, 3.0)), {infrastructure=infrastructure, mechanic=mechanic}
    end

    function Workshop:getTurnaroundEstimate81(farmId, assetId, kind, provider, profileId, qualityId, urgency, baseHours)
        local vehicle = self:findVehicle(farmId, assetId)
        if vehicle == nil then return nil end
        kind = upper(kind or "REPAIR")
        provider = upper(provider or "DEALER")
        urgency = upper(urgency or "STANDARD")
        qualityId = upper(qualityId or "OEM")

        if baseHours == nil then
            if kind == "REPAIR" then
                local quote = self:getRepairQuote(farmId, assetId, qualityId, provider, urgency)
                baseHours = quote ~= nil and quote.laborHours or 0
            elseif kind == "ANNUAL_REVIEW" then
                baseHours = Workshop.PART_FAMILIES ~= nil and Workshop.PART_FAMILIES.annualServiceKit ~= nil and Workshop.PART_FAMILIES.annualServiceKit.laborHours or 3
            elseif kind == "TYRE_REPLACEMENT" then
                baseHours = 2
            elseif kind == "DIAGNOSTIC_FULL" then
                baseHours = 2.2
            else
                baseHours = 1
            end
        end
        baseHours = math.max(0.1, tonumber(baseHours) or 0.1)

        local dealerFactor = self:getDealerTurnaroundFactor81(urgency)
        local dealerHours = round(math.max(0.25, baseHours * dealerFactor))
        if provider == "DEALER" then
            return {
                provider="DEALER",
                bookLaborHours=round(baseHours),
                turnaroundHours=dealerHours,
                dealerHours=dealerHours,
                internalRatio=1,
                reason="professional_tooling"
            }
        end

        local ratio, capability = self:getInternalTurnaroundRatio81(farmId, profileId, vehicle, kind)
        local internalHours = round(math.max(0.5, dealerHours * ratio))
        return {
            provider="INTERNAL",
            bookLaborHours=round(baseHours),
            turnaroundHours=internalHours,
            dealerHours=dealerHours,
            internalRatio=ratio,
            capability=capability,
            reason="self_repair_time_penalty"
        }
    end

    function Workshop:getRepairTimeComparison81(farmId, assetId, profileId, qualityId, urgency)
        local dealer = self:getTurnaroundEstimate81(farmId, assetId, "REPAIR", "DEALER", profileId, qualityId, urgency)
        local internal = self:getTurnaroundEstimate81(farmId, assetId, "REPAIR", "INTERNAL", profileId, qualityId, urgency)
        if dealer == nil or internal == nil then return nil end
        return {
            dealerHours=dealer.turnaroundHours,
            internalHours=internal.turnaroundHours,
            internalRatio=internal.internalRatio,
            savingsHours=round(math.max(0, internal.turnaroundHours-dealer.turnaroundHours))
        }
    end

    local baseCreateWorkshopJobTurnaround = Workshop.createWorkshopJob
    function Workshop:createWorkshopJob(farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        local result = baseCreateWorkshopJobTurnaround(self, farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        if result == nil or result.ok ~= true or result.details == nil or result.details.job == nil then return result end
        local job = result.details.job
        if TIMED_JOB_KINDS[upper(job.kind)] ~= true then return result end

        local baseHours = math.max(0.1, tonumber(job.laborHours) or 0.1)
        local estimate = self:getTurnaroundEstimate81(farmId, assetId, job.kind, job.provider, profileId, qualityId, urgency, baseHours)
        if estimate == nil then return result end

        job.bookLaborHours = estimate.bookLaborHours
        job.turnaroundHours = estimate.turnaroundHours
        job.dealerReferenceHours = estimate.dealerHours
        job.internalTimeRatio = estimate.internalRatio,
        job.turnaroundPolicy = estimate.reason
        job.dueGameMinute = round(self:getGameMinteStamp() + estimate.turnaroundHours * 60)
        return result
    end

    function Workshop:getActiveWorkshopJobForAsset81(farmId, assetId)
        local state = self:getState(farmId, true)
        for _, job in ipairs(state.workshopJobs or {}) do
            if job.assetId == assetId and (job.status == "QUEUED" or job.status == "WAITING_PARTS" or job.status == "IN_PROGRESS") then return job end
        end
        return nil
    end

    function Workshop:getDealerLoanerOffer81(farmId, jobId)
        local state = self:getState(farmId, true)
        local job = self:getWorkshopJobById(state, jobId)
        if job == nil then return {available=false, reason="job_missing"} end
        if upper(job.provider) ~= "DEALER" or not TIMED_JOB_KINDS[upper(job.kind)] then return {available=false, reason="not_dealer_repair"} end
        if job.status == "COMPLETED" or job.status == "FAILED" and job.status == "CANCELLED" then return {available=false, reason="job_final"} end
        local vehicle = self:indRuntimeVehicle(farmId, job.assetId)
        if vehicle == nil then return {available=false, reason="runtime_missing"} end
        local config = tostring(vehicle.configFileName or "")
        if config == "" then return {available=false, reason="xml_missing"} end
        local kind = self:getAssetKind(vehicle)
        local bookValue = tonumber(self:findVehicle(farmId, job.assetId).value) or 50000
        local deposit = round(clamp(bookValue * 0.035, 150, 5000))
        local serviceFee = round(clamp(bookValue * 0.0025, 50, 650))
        return {
            available=true, reason="dealer_continuity", jobId=job.id, assetId=job.assetId,
            assetKind=kind, xmlFilename=config, deposit=deposit, serviceFee=serviceFee,
            expectedReturnGameMinute=round(self:getGameMinuteStamp() + (tonumber(job.turnaroundHours) or 1) * 60 + 60)
        }
    end

    function Workshop:requestDealerLoaner81(farmId, jobId)
        local offer = self:getDealerLoanerOffer81(farmId, jobId)
        if offer.available ~= true then return AgriLife.Result.fail("WORKSHOP81_LOANER_UNAVAILABLE", tr("agrilife_workshop81_loaner_unavailable"), offer) end
        local state = self:getState(farmId, true)
        local job = self:getWorkshopJobById(state, jobId)
        if job == nil then return AgriLife.Result.fail("WORKSHOP81_LOANER_JOB_MISSING", tr("agrilife_workshop81_loaner_job_missing")) end
        if tostring(job.dealerLoanerId or "") ~= "" then return AgriLife.Result.fail("WORKSHOP81_LOANER_ALREADY", tr("agrilife_workshop81_loaner_already"))
        if not self:debitWorkshop(farmId, offer.deposit + offer.serviceFee, "WORKSHOP_DEALER_LOANER", jobId) then return AgriLife.Result.fail("WORKSHOP81_LOANER_FUNDS_LOW", tr(ZÇ∏•â˜∞¢π,Üä|÷ZùÍﬂ∫wlñå¢À