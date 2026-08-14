-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Career6Service = {}
AgriLife.Career6Service.__index = AgriLife.Career6Service
AgriLife.Career6Service.SCHEMA_VERSION = 5
AgriLife.Career6Service.MAX_LEVEL = 100
AgriLife.Career6Service.MAX_STARS = 10
AgriLife.Career6Service.DRIVING_METERS_PER_XP = 100
AgriLife.Career6Service.MAX_STEP_DISTANCE = 120
AgriLife.Career6Service.ACTIVE_WORK_TTL_MS = 900
AgriLife.Career6Service.ACTIVE_DRIVING_TTL_MS = 650
AgriLife.Career6Service.HUD_WORK_HOLD_MS = 4500
AgriLife.Career6Service.HUD_DRIVING_HOLD_MS = 2200
AgriLife.Career6Service.FIELD_EXIT_CONFIRM_MS = 500

AgriLife.Career6Service.SPECIALTIES = {
    { id = "driving", labelKey = "agrilife_career6_specialty_driving" },
    { id = "tillage", labelKey = "agrilife_career6_specialty_tillage" },
    { id = "sowing", labelKey = "agrilife_career6_specialty_sowing" },
    { id = "cropCare", labelKey = "agrilife_career6_specialty_cropCare" },
    { id = "harvesting", labelKey = "agrilife_career6_specialty_harvesting" },
    { id = "livestock", labelKey = "agrilife_career6_specialty_livestock" },
    { id = "maintenance", labelKey = "agrilife_career6_specialty_maintenance" },
    { id = "management", labelKey = "agrilife_career6_specialty_management" }
}

AgriLife.Career6Service.STAR_THRESHOLDS = {
    1000, 2000, 3000, 4000, 5000,
    6000, 7000, 8000, 9000, 10000
}

AgriLife.Career6Service.FIELD_XP_PER_HA = {
    tillage = 80,
    sowing = 100,
    cropCare = 75,
    harvesting = 120
}

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function safeInteger(value, default)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
    return math.max(0, math.floor(value + 0.000001))
end

local function safeNumber(value, default)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
    return value
end

local function getRuntimeTime()
    if g_currentMission ~= nil and tonumber(g_currentMission.time) ~= nil then
        return tonumber(g_currentMission.time)
    end
    return tonumber(g_time) or 0
end

local function cleanProfileId(value)
    value = tostring(value or ""):gsub("[%c]", " "):gsub("%s+", " ")
    value = value:match("^%s*(.-)%s*$") or value
    if #value > 96 then value = value:sub(1, 96) end
    return value
end

local function getOwnerFarmId(vehicle)
    if vehicle == nil then return 0 end
    if vehicle.getOwnerFarmId ~= nil then
        local ok, farmId = pcall(vehicle.getOwnerFarmId, vehicle)
        if ok and tonumber(farmId) ~= nil then return tonumber(farmId) end
    end
    return tonumber(vehicle.ownerFarmId) or 0
end

local function getUniqueId(vehicle)
    if vehicle == nil then return nil end
    if vehicle.getUniqueId ~= nil then
        local ok, value = pcall(vehicle.getUniqueId, vehicle)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
    if vehicle.uniqueId ~= nil then return tostring(vehicle.uniqueId) end
    return tostring(vehicle)
end

local function getPosition(vehicle)
    if vehicle == nil or vehicle.rootNode == nil or vehicle.rootNode == 0 or getWorldTranslation == nil then return nil, nil end
    local ok, x, _, z = pcall(getWorldTranslation, vehicle.rootNode)
    if ok then return tonumber(x), tonumber(z) end
    return nil, nil
end

local function getIsOnField(vehicle, x, z)
    if x == nil or z == nil then return false end

    -- Use the same native density-map query as FS25's own field-aware
    -- specializations. Unlike a farmland ownership lookup, this distinguishes
    -- actual cultivable ground from a road or painted path crossing the same
    -- parcel.
    if FSDensityMapUtil ~= nil and FSDensityMapUtil.getFieldDataAtWorldPosition ~= nil then
        local ok, isOnField = pcall(FSDensityMapUtil.getFieldDataAtWorldPosition, x, 0, z)
        if ok and type(isOnField) == "boolean" then return isOnField end
    end

    -- Most drivable vehicles already expose the engine's field state. Keep it
    -- as a compatibility fallback for maps or scripts replacing the utility.
    if vehicle ~= nil and type(vehicle.isOnField) == "boolean" then return vehicle.isOnField end
    if vehicle ~= nil and vehicle.getPFStatisticInfo ~= nil then
        local ok, _, isOnField = pcall(vehicle.getPFStatisticInfo, vehicle)
        if ok and type(isOnField) == "boolean" then return isOnField end
    end
    return false
end

local function getSpeed(vehicle)
    if vehicle == nil then return 0 end
    if vehicle.getLastSpeed ~= nil then
        local ok, value = pcall(vehicle.getLastSpeed, vehicle)
        if ok and tonumber(value) ~= nil then return math.abs(tonumber(value)) end
    end
    return math.abs(tonumber(vehicle.lastSpeed) or 0)
end

local function getIsAIActive(vehicle)
    if vehicle == nil or vehicle.getIsAIActive == nil then return false end
    local ok, active = pcall(vehicle.getIsAIActive, vehicle)
    return ok and active == true
end

local function distance(x1, z1, x2, z2)
    if x1 == nil or z1 == nil or x2 == nil or z2 == nil then return 0 end
    local dx = x2 - x1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dz * dz)
end

function AgriLife.Career6Service.new(core)
    local self = setmetatable({}, AgriLife.Career6Service)
    self.core = core
    self.farms = {}
    self.runtimeByProfile = {}
    -- Transient activity is deliberately not persisted. It only drives the
    -- contextual XP HUD and prevents vehicle distance from also becoming
    -- Driving XP while a real specialised task is changing the world.
    self.activityByProfile = {}
    -- Server-side qualification lock. Exam6Service sets it synchronously when
    -- an exam starts, so Career XP is blocked before the next update tick. The
    -- direct Exam service state remains authoritative and reconciles this cache.
    self.examLocks = {}
    self.examProbeWarnings = {}
    self.recentTokens = {}
    self.nextTokenCleanupAt = 0
    return self
end

function AgriLife.Career6Service:getRuntimeKey(farmId, profileId)
    farmId = tonumber(farmId) or 0
    profileId = cleanProfileId(profileId)
    if farmId <= 0 or profileId == "" then return nil end
    return tostring(farmId) .. ":" .. profileId
end

function AgriLife.Career6Service:getSpecialtyDefinition(specialtyId)
    for _, specialty in ipairs(self.SPECIALTIES) do
        if specialty.id == specialtyId then return specialty end
    end
    return nil
end

function AgriLife.Career6Service:markActivity(farmId, profileId, specialtyId, activeDurationMs, visibleDurationMs)
    if not self:isSpecialtyValid(specialtyId) then return nil end
    profileId = self:resolveProfileId(farmId, profileId, nil)
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    if runtimeKey == nil then return nil end

    local now = getRuntimeTime()
    local current = self.activityByProfile[runtimeKey]
    -- A specialist job always owns the HUD and the XP category while it is
    -- active. Ordinary vehicle movement must never replace tillage, sowing,
    -- crop-care or harvesting with Driving.
    if specialtyId == "driving"
        and current ~= nil
        and current.specialtyId ~= "driving"
        and safeNumber(current.activeUntil, 0) > now then
        return current
    end

    activeDurationMs = math.max(0, safeInteger(activeDurationMs, 0))
    visibleDurationMs = math.max(activeDurationMs, safeInteger(visibleDurationMs, activeDurationMs))
    local activity = {
        farmId = tonumber(farmId) or 0,
        profileId = tostring(profileId),
        specialtyId = specialtyId,
        activeUntil = now + activeDurationMs,
        visibleUntil = now + visibleDurationMs
    }
    if current ~= nil and current.specialtyId == specialtyId then
        activity.activeUntil = math.max(activity.activeUntil, safeNumber(current.activeUntil, 0))
        activity.visibleUntil = math.max(activity.visibleUntil, safeNumber(current.visibleUntil, 0))
    end
    self.activityByProfile[runtimeKey] = activity
    return activity
end

function AgriLife.Career6Service:getActiveSpecialty(farmId, profileId)
    profileId = self:resolveProfileId(farmId, profileId, nil)
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    local activity = runtimeKey ~= nil and self.activityByProfile[runtimeKey] or nil
    if activity == nil or safeNumber(activity.activeUntil, 0) <= getRuntimeTime() then return nil end
    return activity.specialtyId
end

function AgriLife.Career6Service:updateFieldPresence(runtime, vehicle, x, z)
    local detectedOnField = getIsOnField(vehicle, x, z)
    local now = getRuntimeTime()

    -- Entering a field blocks Driving XP immediately. Leaving needs a short
    -- confirmation so the HUD does not flicker when the tractor straddles a
    -- field edge or a very narrow painted path.
    if detectedOnField then
        runtime.onField = true
        runtime.offFieldSince = nil
    elseif runtime.onField == true then
        if runtime.offFieldSince == nil then runtime.offFieldSince = now end
        if now - runtime.offFieldSince >= self.FIELD_EXIT_CONFIRM_MS then
            runtime.onField = false
            runtime.offFieldSince = nil
        end
    else
        runtime.onField = false
        runtime.offFieldSince = nil
    end
    return runtime.onField == true
end

function AgriLife.Career6Service:holdFieldActivity(farmId, profileId)
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    local activity = runtimeKey ~= nil and self.activityByProfile[runtimeKey] or nil
    if activity == nil then return nil end

    if activity.specialtyId == "driving" then
        self.activityByProfile[runtimeKey] = nil
        return nil
    end
    if self.FIELD_XP_PER_HA[activity.specialtyId] == nil then return nil end

    activity.visibleUntil = math.max(safeNumber(activity.visibleUntil, 0), getRuntimeTime() + self.HUD_WORK_HOLD_MS)
    return activity
end

function AgriLife.Career6Service:getSpecialtyProgress(xp)
    xp = safeInteger(xp, 0)
    local stars = self:getStars(xp)
    if stars >= self.MAX_STARS then
        return stars, self.STAR_THRESHOLDS[self.MAX_STARS], nil, 100
    end
    local floorXP = stars > 0 and self.STAR_THRESHOLDS[stars] or 0
    local nextXP = self.STAR_THRESHOLDS[stars + 1]
    local progress = math.floor(clamp(((xp - floorXP) / math.max(1, nextXP - floorXP)) * 100, 0, 100) + 0.5)
    return stars, floorXP, nextXP, progress
end

function AgriLife.Career6Service:getActivitySnapshot(farmId, profileId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, false)
    local runtimeKey = self:getRuntimeKey(farmId, resolvedProfileId)
    local activity = runtimeKey ~= nil and self.activityByProfile[runtimeKey] or nil
    local now = getRuntimeTime()
    if state == nil or activity == nil or safeNumber(activity.visibleUntil, 0) <= now then
        if runtimeKey ~= nil and activity ~= nil then self.activityByProfile[runtimeKey] = nil end
        return nil
    end

    local definition = self:getSpecialtyDefinition(activity.specialtyId)
    if definition == nil then return nil end
    local xp = safeInteger(state.specialties[activity.specialtyId], 0)
    local stars, floorXP, nextXP, progress = self:getSpecialtyProgress(xp)
    return {
        farmId = tonumber(farmId) or 0,
        profileId = tostring(resolvedProfileId or ""),
        specialtyId = activity.specialtyId,
        labelKey = definition.labelKey,
        xp = xp,
        stars = stars,
        floorXP = floorXP,
        nextXP = nextXP,
        progress = progress,
        active = safeNumber(activity.activeUntil, 0) > now,
        remainingMs = math.max(0, safeInteger(safeNumber(activity.visibleUntil, 0) - now, 0))
    }
end

function AgriLife.Career6Service:getPeopleModule()
    return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.people or nil
end

function AgriLife.Career6Service:getPeopleService()
    local module = self:getPeopleModule()
    return module ~= nil and module.service or nil
end

function AgriLife.Career6Service:setExamLock(farmId, profileId, locked)
    profileId = self:resolveProfileId(farmId, profileId, nil)
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    if runtimeKey == nil then return false end

    if locked == true then
        self.examLocks[runtimeKey] = true
        -- A permit task owns the mini-PDA. Remove any career activity left from
        -- the trip made before the fee was paid, without changing earned XP or
        -- the legitimate residual accumulated before the exam.
        self.activityByProfile[runtimeKey] = nil
    else
        self.examLocks[runtimeKey] = nil
        self.examProbeWarnings[runtimeKey] = nil
    end
    return true
end

function AgriLife.Career6Service:isExamRunning(farmId, profileId)
    profileId = self:resolveProfileId(farmId, profileId, nil)
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    if runtimeKey == nil then return false end

    local registry = self.core ~= nil and self.core.registry or nil
    local examModule = registry ~= nil and registry.instances ~= nil and (registry.instances.exams or registry.instances.exam) or nil
    local examService = examModule ~= nil and examModule.service or nil
    if examService ~= nil then
        -- Never use the full HUD/network snapshot as a gameplay lock. Snapshot
        -- construction also resolves navigation, equipment and UI data; a
        -- recoverable error there used to be silently interpreted as "no exam"
        -- and allowed Driving XP through. This lightweight query reads only the
        -- persisted exam flag.
        if examService.isExamRunning ~= nil then
            local ok, active = pcall(examService.isExamRunning, examService, farmId, profileId)
            if ok then
                if active == true then self.examLocks[runtimeKey] = true else self.examLocks[runtimeKey] = nil end
                self.examProbeWarnings[runtimeKey] = nil
                return active == true
            elseif not self.examProbeWarnings[runtimeKey] then
                self.examProbeWarnings[runtimeKey] = true
                AgriLife.Logger.warning("Career", "Direct exam lock probe failed for %s; keeping the fail-closed lock: %s", tostring(profileId), tostring(active))
            end
        elseif examService.getSnapshot ~= nil then
            local ok, snapshot = pcall(examService.getSnapshot, examService, farmId, profileId)
            if ok and snapshot ~= nil then
                local active = snapshot.examRunning == true
                if active then self.examLocks[runtimeKey] = true else self.examLocks[runtimeKey] = nil end
                return active
            end
        end
    end

    -- Fail closed only when Exam6Service has explicitly armed the lock. This
    -- protects the candidate if a later mod temporarily breaks the probe.
    return self.examLocks[runtimeKey] == true
end

function AgriLife.Career6Service:getExamSuspendedResult(farmId, profileId, specialtyId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    return AgriLife.Result.ok("CAREER_XP_SUSPENDED_EXAM", "Career XP is suspended during the agricultural licence exam", {
        profileId = resolvedProfileId,
        specialtyId = specialtyId,
        amount = 0,
        totalXP = state ~= nil and safeInteger(state.totalXP, 0) or 0,
        suspended = true
    })
end

function AgriLife.Career6Service:getLevelThreshold(level)
    level = math.max(1, math.min(self.MAX_LEVEL, safeInteger(level, 1)))
    if level <= 1 then return 0 end
    local n = level - 1
    return math.floor(350 * n * n)
end

function AgriLife.Career6Service:getLevel(totalXP)
    totalXP = safeInteger(totalXP, 0)
    local low, high = 1, self.MAX_LEVEL
    while low < high do
        local mid = math.ceil((low + high) / 2)
        if totalXP >= self:getLevelThreshold(mid) then low = mid else high = mid - 1 end
    end
    return low
end

function AgriLife.Career6Service:getLevelTitleKey(level)
    level = math.max(1, math.min(self.MAX_LEVEL, safeInteger(level, 1)))
    if level <= 10 then return "agrilife_career6_title_beginner" end
    if level <= 25 then return "agrilife_career6_title_worker" end
    if level <= 40 then return "agrilife_career6_title_operator" end
    if level <= 55 then return "agrilife_career6_title_professional" end
    if level <= 70 then return "agrilife_career6_title_manager" end
    if level <= 85 then return "agrilife_career6_title_expert" end
    if level <= 99 then return "agrilife_career6_title_master" end
    return "agrilife_career6_title_max"
end

function AgriLife.Career6Service:getStars(xp)
    xp = safeInteger(xp, 0)
    local stars = 0
    for index, threshold in ipairs(self.STAR_THRESHOLDS) do
        if xp >= threshold then stars = index else break end
    end
    return math.min(self.MAX_STARS, stars)
end

function AgriLife.Career6Service:getNextStarXP(xp)
    local stars = self:getStars(xp)
    if stars >= self.MAX_STARS then return nil end
    return self.STAR_THRESHOLDS[stars + 1]
end

function AgriLife.Career6Service:createDefaultState()
    local specialties = {}
    for _, specialty in ipairs(self.SPECIALTIES) do specialties[specialty.id] = 0 end
    return {
        totalXP = 0,
        reputation = 50,
        specialties = specialties,
        residualDrivingMeters = 0,
        residualTransportXP = 0,
        residualFieldXP = { tillage = 0, sowing = 0, cropCare = 0, harvesting = 0 },
        stats = {
            workMs = 0,
            distanceMeters = 0,
            areaSqm = 0,
            harvestedSqm = 0,
            transportedTonnesKm = 0,
            transportedTonnes = 0,
            livestockCareUnits = 0,
            diagnostics = 0,
            repairs = 0,
            examsPassed = 0,
            examsFailed = 0
        }
    }
end

function AgriLife.Career6Service:createDefaultFarmState()
    return { profiles = {} }
end

function AgriLife.Career6Service:getFarmState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local state = self.farms[farmId]
    if state == nil and create ~= false then
        state = self:createDefaultFarmState()
        self.farms[farmId] = state
    end
    return state
end

function AgriLife.Career6Service:resolveProfileId(farmId, requestedProfileId, vehicle)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local requested = cleanProfileId(requestedProfileId)
    if requested ~= "" then return requested end

    local people = self:getPeopleService()
    if people ~= nil then
        if vehicle ~= nil and people.getProfileIdForVehicle ~= nil then
            local profileId = people:getProfileIdForVehicle(farmId, vehicle)
            if profileId ~= nil and cleanProfileId(profileId) ~= "" then return cleanProfileId(profileId) end
        end
        local module = self:getPeopleModule()
        if module ~= nil and module.getLocalProfileId ~= nil then
            local profileId = module:getLocalProfileId(farmId)
            if profileId ~= nil and cleanProfileId(profileId) ~= "" then return cleanProfileId(profileId) end
        end
        -- People is authoritative in 6.0. If its local identity is not ready yet,
        -- do not create a permanent placeholder Career profile.
        return nil
    end
    return "SP_FARM_" .. tostring(farmId)
end

function AgriLife.Career6Service:getProfileState(farmId, profileId, create)
    local farmState = self:getFarmState(farmId, create)
    if farmState == nil then return nil, nil end
    profileId = self:resolveProfileId(farmId, profileId, nil)
    if profileId == nil or profileId == "" then return nil, nil end
    local state = farmState.profiles[profileId]
    if state == nil and create ~= false then
        state = self:createDefaultState()
        farmState.profiles[profileId] = state
    end
    return state, profileId
end

-- Compatibility helper for older callers. Career is no longer farm-global;
-- this returns the local player's state on that farm.
function AgriLife.Career6Service:getFarmStateLegacy(farmId, create)
    return self:getProfileState(farmId, nil, create)
end

function AgriLife.Career6Service:isSpecialtyValid(specialtyId)
    for _, specialty in ipairs(self.SPECIALTIES) do
        if specialty.id == specialtyId then return true end
    end
    return false
end

function AgriLife.Career6Service:acceptToken(token)
    if token == nil or token == "" then return true end
    token = tostring(token)
    local now = tonumber(g_time) or 0
    local previous = self.recentTokens[token]
    if previous ~= nil and now - previous < 15000 then return false end
    self.recentTokens[token] = now
    if now >= safeNumber(self.nextTokenCleanupAt, 0) then
        for key, timestamp in pairs(self.recentTokens) do
            if now - timestamp > 60000 then self.recentTokens[key] = nil end
        end
        self.nextTokenCleanupAt = now + 15000
    end
    return true
end

function AgriLife.Career6Service:awardXP(farmId, specialtyId, amount, sourceToken, profileId)
    if self.core ~= nil and self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then
        return AgriLife.Result.fail("CAREER_ONBOARDING_REQUIRED", "Bank selection and agricultural licence are required before earning career XP")
    end
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    amount = safeInteger(amount, 0)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    if not self:isSpecialtyValid(specialtyId) then return AgriLife.Result.fail("CAREER_SPECIALTY_INVALID", "Unknown specialty") end
    if amount <= 0 then return AgriLife.Result.fail("CAREER_XP_INVALID", "XP amount must be positive") end
    if self:isExamRunning(farmId, resolvedProfileId) then return self:getExamSuspendedResult(farmId, resolvedProfileId, specialtyId) end
    local scopedToken = sourceToken ~= nil and (tostring(farmId) .. ":" .. tostring(resolvedProfileId) .. ":" .. tostring(sourceToken)) or nil
    if not self:acceptToken(scopedToken) then return AgriLife.Result.fail("CAREER_XP_DUPLICATE", "Duplicate XP source ignored") end

    state.specialties[specialtyId] = safeInteger(state.specialties[specialtyId], 0) + amount
    state.totalXP = safeInteger(state.totalXP, 0) + amount
    local holdMs = specialtyId == "driving" and self.HUD_DRIVING_HOLD_MS or self.HUD_WORK_HOLD_MS
    self:markActivity(farmId, resolvedProfileId, specialtyId, 0, holdMs)
    AgriLife.Logger.info("Career", "XP +%d profile=%s farm=%d specialty=%s total=%d", amount, tostring(resolvedProfileId), tonumber(farmId) or 0, tostring(specialtyId), state.totalXP)
    return AgriLife.Result.ok("CAREER_XP_AWARDED", "Career XP awarded", {
        profileId = resolvedProfileId,
        specialtyId = specialtyId,
        amount = amount,
        totalXP = state.totalXP,
        level = self:getLevel(state.totalXP)
    })
end

function AgriLife.Career6Service:adjustReputation(farmId, amount, profileId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    state.reputation = math.floor(clamp((state.reputation or 50) + (tonumber(amount) or 0), 0, 100) + 0.5)
    return AgriLife.Result.ok("CAREER_REPUTATION_UPDATED", "Career reputation updated", { profileId = resolvedProfileId, reputation = state.reputation })
end

function AgriLife.Career6Service:awardFieldWork(farmId, specialtyId, areaSqm, quality, sourceToken, profileId)
    if self.core ~= nil and self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then
        return AgriLife.Result.fail("CAREER_ONBOARDING_REQUIRED", "Bank selection and agricultural licence are required before field XP")
    end
    local xpPerHa = self.FIELD_XP_PER_HA[specialtyId]
    if xpPerHa == nil then return AgriLife.Result.fail("CAREER_FIELD_SPECIALTY_INVALID", "Specialty is not eligible for field work XP") end
    areaSqm = math.max(0, safeNumber(areaSqm, 0))
    quality = clamp(quality or 1, 0.5, 1.10)
    if areaSqm <= 0 then return AgriLife.Result.fail("CAREER_FIELD_AREA_INVALID", "Worked area must be positive") end
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    if self:isExamRunning(farmId, resolvedProfileId) then return self:getExamSuspendedResult(farmId, resolvedProfileId, specialtyId) end
    self:markActivity(farmId, resolvedProfileId, specialtyId, self.ACTIVE_WORK_TTL_MS, self.HUD_WORK_HOLD_MS)

    local scopedToken = sourceToken ~= nil and (tostring(farmId) .. ":" .. tostring(resolvedProfileId) .. ":field:" .. tostring(sourceToken)) or nil
    if not self:acceptToken(scopedToken) then return AgriLife.Result.fail("CAREER_XP_DUPLICATE", "Duplicate field XP source ignored") end

    state.residualFieldXP = state.residualFieldXP or { tillage = 0, sowing = 0, cropCare = 0, harvesting = 0 }
    local exactXP = (areaSqm / 10000) * xpPerHa * quality + safeNumber(state.residualFieldXP[specialtyId], 0)
    local amount = math.floor(exactXP + 0.000001)
    state.residualFieldXP[specialtyId] = exactXP - amount
    state.stats.areaSqm = safeNumber(state.stats.areaSqm, 0) + areaSqm
    if specialtyId == "harvesting" then state.stats.harvestedSqm = safeNumber(state.stats.harvestedSqm, 0) + areaSqm end

    if amount <= 0 then
        if areaSqm >= 1 then AgriLife.Logger.debug("Career", "Field progress profile=%s farm=%d specialty=%s area=%.2fm2 residual=%.3f", tostring(resolvedProfileId), tonumber(farmId) or 0, tostring(specialtyId), areaSqm, state.residualFieldXP[specialtyId]) end
        return AgriLife.Result.ok("CAREER_FIELD_PROGRESS", "Field work progress recorded", {
            profileId = resolvedProfileId, specialtyId = specialtyId, amount = 0, areaSqm = areaSqm, residualXP = state.residualFieldXP[specialtyId]
        })
    end

    local result = self:awardXP(farmId, specialtyId, amount, nil, resolvedProfileId)
    if result.ok then
        result.details = result.details or {}
        result.details.areaSqm = areaSqm
        result.details.residualXP = state.residualFieldXP[specialtyId]
    end
    return result
end

function AgriLife.Career6Service:awardTransport(farmId, tonnes, kilometers, quality, sourceToken, profileId)
    if self.core ~= nil and self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then
        return AgriLife.Result.fail("CAREER_ONBOARDING_REQUIRED", "Bank selection and agricultural licence are required before transport XP")
    end
    tonnes = math.max(0, safeNumber(tonnes, 0))
    kilometers = math.max(0, safeNumber(kilometers, 0))
    quality = clamp(quality or 1, 0.5, 1.10)
    if tonnes <= 0 or kilometers <= 0 then return AgriLife.Result.fail("CAREER_TRANSPORT_INVALID", "Transport requires positive cargo and distance") end
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    if self:isExamRunning(farmId, resolvedProfileId) then return self:getExamSuspendedResult(farmId, resolvedProfileId, "driving") end
    self:markActivity(farmId, resolvedProfileId, "driving", self.ACTIVE_DRIVING_TTL_MS, self.HUD_DRIVING_HOLD_MS)

    local scopedToken = sourceToken ~= nil and (tostring(farmId) .. ":" .. tostring(resolvedProfileId) .. ":transport:" .. tostring(sourceToken)) or nil
    if not self:acceptToken(scopedToken) then return AgriLife.Result.fail("CAREER_XP_DUPLICATE", "Duplicate transport XP source ignored") end

    local exactXP = tonnes * kilometers * 0.25 * quality + safeNumber(state.residualTransportXP, 0)
    local amount = math.floor(exactXP + 0.000001)
    state.residualTransportXP = exactXP - amount
    state.stats.transportedTonnesKm = safeNumber(state.stats.transportedTonnesKm, 0) + tonnes * kilometers
    state.stats.transportedTonnes = safeNumber(state.stats.transportedTonnes, 0) + tonnes

    if amount <= 0 then
        return AgriLife.Result.ok("CAREER_TRANSPORT_PROGRESS", "Transport progress recorded", {
            profileId = resolvedProfileId, amount = 0, tonnes = tonnes, kilometers = kilometers, residualXP = state.residualTransportXP
        })
    end

    local result = self:awardXP(farmId, "driving", amount, nil, resolvedProfileId)
    if result.ok then
        result.details = result.details or {}
        result.details.tonnes = tonnes
        result.details.kilometers = kilometers
        result.details.residualXP = state.residualTransportXP
    end
    return result
end

function AgriLife.Career6Service:recordMaintenance(farmId, kind, difficulty, sourceToken, profileId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    difficulty = clamp(difficulty or 1, 0.25, 5)
    local isDiagnostic = tostring(kind) == "diagnostic"
    local base = isDiagnostic and 45 or 80
    local result = self:awardXP(farmId, "maintenance", math.max(1, math.floor(base * difficulty + 0.5)), sourceToken, resolvedProfileId)
    if result.ok and not (result.details ~= nil and result.details.suspended == true) then
        if isDiagnostic then state.stats.diagnostics = safeInteger(state.stats.diagnostics, 0) + 1
        else state.stats.repairs = safeInteger(state.stats.repairs, 0) + 1 end
    end
    return result
end

function AgriLife.Career6Service:recordLivestockCare(farmId, units, action, sourceToken, profileId)
    units=math.max(0,safeNumber(units,0))
    action=tostring(action or "care")
    if units<=0 then return AgriLife.Result.fail("CAREER_LIVESTOCK_INVALID","Livestock care requires a positive quantity") end
    local factors={care=1.0,feeding=1.0,welfare=1.5,breeding=2.0,veterinary=2.5}
    local factor=factors[action] or factors.care
    local amount=math.max(1,math.floor(units*factor+0.5))
    local result=self:awardXP(farmId,"livestock",amount,sourceToken,profileId)
    if result.ok and not (result.details~=nil and result.details.suspended==true) then
        local state=self:getProfileState(farmId,profileId,true)
        if state~=nil then state.stats.livestockCareUnits=safeNumber(state.stats.livestockCareUnits,0)+units end
        result.details=result.details or {}; result.details.units=units; result.details.action=action
    end
    return result
end

function AgriLife.Career6Service:handleHusbandryActivity(action,...)
    local farmId=0;local subject=nil;local units=1
    for index=1,select("#",...) do
        local value=select(index,...)
        if type(value)=="table" then
            subject=subject or value
            if value.getOwnerFarmId~=nil then local ok,id=pcall(value.getOwnerFarmId,value);if ok and tonumber(id)~=nil then farmId=tonumber(id) end end
            if farmId<=0 then farmId=tonumber(value.ownerFarmId) or tonumber(value.farmId) or 0 end
            local placeable=value.owningPlaceable or value.placeable
            if farmId<=0 and placeable~=nil then if placeable.getOwnerFarmId~=nil then local ok,id=pcall(placeable.getOwnerFarmId,placeable);if ok then farmId=tonumber(id) or 0 end end;if farmId<=0 then farmId=tonumber(placeable.ownerFarmId) or 0 end end
        elseif type(value)=="number" and value>0 and value<=10000 then units=math.max(units,math.min(50,value)) end
    end
    if farmId<=0 then return AgriLife.Result.fail("CAREER_LIVESTOCK_FARM_UNKNOWN","Husbandry farm could not be resolved") end
    local company=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.company or nil
    local snapshot=company~=nil and company.getSnapshot~=nil and company:getSnapshot(farmId) or nil
    local profileId=snapshot~=nil and snapshot.ownerProfileId or self:resolveProfileId(farmId,nil,nil)
    local bucket=math.floor(getRuntimeTime()/5000);local token=table.concat({"HUSBANDRY",tostring(action),tostring(subject or "farm"),tostring(bucket)},":")
    return self:recordLivestockCare(farmId,units,action,token,profileId)
end
function AgriLife.Career6Service:onHusbandryAnimalsChanged(...) return self:handleHusbandryActivity("welfare",...) end
function AgriLife.Career6Service:onHusbandryFoodChanged(...) return self:handleHusbandryActivity("feeding",...) end
function AgriLife.Career6Service:onAnimalHusbandryUpdated(...) return self:handleHusbandryActivity("care",...) end

function AgriLife.Career6Service:recordManagement(farmId, amount, sourceToken, profileId)
    return self:awardXP(farmId, "management", math.max(1, safeInteger(amount, 1)), sourceToken, profileId)
end

function AgriLife.Career6Service:recordExamResult(farmId, passed, profileId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    if state == nil then return AgriLife.Result.fail("CAREER_PROFILE_INVALID", "Career profile is invalid") end
    if passed == true then state.stats.examsPassed = safeInteger(state.stats.examsPassed, 0) + 1
    else state.stats.examsFailed = safeInteger(state.stats.examsFailed, 0) + 1 end
    return AgriLife.Result.ok("CAREER_EXAM_RECORDED", "Exam result recorded", { profileId = resolvedProfileId })
end

function AgriLife.Career6Service:getConnectedPlayerContexts()
    local people = self:getPeopleService()
    if people ~= nil and people.getConnectedPlayerContexts ~= nil then return people:getConnectedPlayerContexts() end
    local result = {}
    if self.core ~= nil and self.core.context ~= nil then
        local farmId = tonumber(self.core.context:getFarmId()) or 0
        if farmId > 0 then
            table.insert(result, { farmId = farmId, profileId = self:resolveProfileId(farmId, nil, nil), vehicle = g_currentMission ~= nil and g_currentMission.controlledVehicle or nil })
        end
    end
    return result
end

function AgriLife.Career6Service:update(dt)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return end
    local seen = {}
    for _, context in ipairs(self:getConnectedPlayerContexts()) do
        local farmId = tonumber(context.farmId) or 0
        local profileId = self:resolveProfileId(farmId, context.profileId, context.vehicle)
        if farmId > 0 and profileId ~= nil then
            local runtimeKey = self:getRuntimeKey(farmId, profileId)
            seen[runtimeKey] = true
            local state = self:getProfileState(farmId, profileId, true)
            local vehicle = context.vehicle
            if vehicle == nil or getOwnerFarmId(vehicle) ~= farmId or getIsAIActive(vehicle) then
                self.runtimeByProfile[runtimeKey] = nil
            else
                local vehicleId = getUniqueId(vehicle)
                local x, z = getPosition(vehicle)
                local runtime = self.runtimeByProfile[runtimeKey]
                if runtime == nil or runtime.vehicleId ~= vehicleId then
                    self.runtimeByProfile[runtimeKey] = { vehicleId = vehicleId, x = x, z = z, onField = getIsOnField(vehicle, x, z) }
                elseif self:isExamRunning(farmId, profileId) then
                    -- The licence is a qualification exercise, not career
                    -- work. Keep the position current so no exam distance can
                    -- become deferred Driving XP after the exam ends.
                    runtime.x, runtime.z = x, z
                    self:updateFieldPresence(runtime, vehicle, x, z)
                    self.activityByProfile[runtimeKey] = nil
                else
                    local step = distance(runtime.x, runtime.z, x, z)
                    runtime.x, runtime.z = x, z
                    if step > 0 and step <= self.MAX_STEP_DISTANCE then
                        state.stats.distanceMeters = safeNumber(state.stats.distanceMeters, 0) + step
                        if getSpeed(vehicle) > 0.15 then state.stats.workMs = safeInteger(state.stats.workMs, 0) + math.max(0, safeInteger(dt, 0)) end
                        local activeSpecialty = self:getActiveSpecialty(farmId, profileId)
                        local isOnField = self:updateFieldPresence(runtime, vehicle, x, z)
                        if isOnField then
                            -- Moving on cultivable ground with the implement
                            -- raised is field manoeuvring, not road transport.
                            -- Keep the last real field job visible, but award no
                            -- Driving XP until the vehicle reaches a path/road.
                            self:holdFieldActivity(farmId, profileId)
                        elseif activeSpecialty == nil or activeSpecialty == "driving" then
                            self:markActivity(farmId, profileId, "driving", self.ACTIVE_DRIVING_TTL_MS, self.HUD_DRIVING_HOLD_MS)
                            state.residualDrivingMeters = safeNumber(state.residualDrivingMeters, 0) + step
                            local xp = math.floor(state.residualDrivingMeters / self.DRIVING_METERS_PER_XP)
                            if xp > 0 then
                                state.residualDrivingMeters = state.residualDrivingMeters - xp * self.DRIVING_METERS_PER_XP
                                local xpResult=self:awardXP(farmId, "driving", xp, nil, profileId)
                                if xpResult~=nil and not xpResult.ok then AgriLife.Logger.warning("Career", "Driving XP rejected for %s: %s", tostring(profileId), tostring(xpResult.code)) end
                            end
                        end
                    end
                end
            end
        end
    end
    for key, _ in pairs(self.runtimeByProfile) do if not seen[key] then self.runtimeByProfile[key] = nil end end
end

function AgriLife.Career6Service:buildSnapshot(farmId, profileId, state)
    if state == nil then return nil end
    local level = self:getLevel(state.totalXP)
    local floorXP = self:getLevelThreshold(level)
    local nextXP = level < self.MAX_LEVEL and self:getLevelThreshold(level + 1) or nil
    local progress = 100
    if nextXP ~= nil then progress = math.floor(clamp(((state.totalXP - floorXP) / math.max(1, nextXP - floorXP)) * 100, 0, 100) + 0.5) end

    local specialties = {}
    for index, definition in ipairs(self.SPECIALTIES) do
        local xp = safeInteger(state.specialties[definition.id], 0)
        specialties[index] = { id = definition.id, labelKey = definition.labelKey, xp = xp, stars = self:getStars(xp), nextStarXP = self:getNextStarXP(xp) }
    end
    local people = self:getPeopleService()
    local profile = people ~= nil and people.getProfile ~= nil and people:getProfile(farmId, profileId) or nil
    local activity = self:getActivitySnapshot(farmId, profileId)
    return {
        farmId = tonumber(farmId) or 0,
        profileId = tostring(profileId or ""),
        displayName = profile ~= nil and profile.displayName or "Joueur",
        role = profile ~= nil and profile.role or "employee",
        connected = profile ~= nil and profile.connected == true or false,
        totalXP = safeInteger(state.totalXP, 0),
        level = level,
        levelTitleKey = self:getLevelTitleKey(level),
        levelProgress = progress,
        currentLevelXP = floorXP,
        nextLevelXP = nextXP,
        reputation = safeInteger(state.reputation, 50),
        activeSpecialtyId = activity ~= nil and activity.specialtyId or "",
        activityRemainingMs = activity ~= nil and activity.remainingMs or 0,
        specialties = specialties,
        stats = {
            workHours = safeNumber(state.stats.workMs, 0) / 3600000,
            distanceKm = safeNumber(state.stats.distanceMeters, 0) / 1000,
            areaHa = safeNumber(state.stats.areaSqm, 0) / 10000,
            harvestedHa = safeNumber(state.stats.harvestedSqm, 0) / 10000,
            transportedTonnesKm = safeNumber(state.stats.transportedTonnesKm, 0),
            transportedTonnes = safeNumber(state.stats.transportedTonnes, 0),
            livestockCareUnits = safeNumber(state.stats.livestockCareUnits, 0),
            diagnostics = safeInteger(state.stats.diagnostics, 0),
            repairs = safeInteger(state.stats.repairs, 0),
            examsPassed = safeInteger(state.stats.examsPassed, 0),
            examsFailed = safeInteger(state.stats.examsFailed, 0)
        }
    }
end

function AgriLife.Career6Service:getSnapshot(farmId, profileId)
    local state, resolvedProfileId = self:getProfileState(farmId, profileId, true)
    return self:buildSnapshot(farmId, resolvedProfileId, state)
end

function AgriLife.Career6Service:getTeamSnapshots(farmId)
    local farmState = self:getFarmState(farmId, true)
    if farmState == nil then return {} end
    local people = self:getPeopleService()
    if people ~= nil and people.getFarmState ~= nil then
        local peopleState = people:getFarmState(farmId, false)
        if peopleState ~= nil then
            for profileId, _ in pairs(peopleState.profiles or {}) do self:getProfileState(farmId, profileId, true) end
        end
    end
    local result = {}
    for profileId, state in pairs(farmState.profiles) do table.insert(result, self:buildSnapshot(farmId, profileId, state)) end
    table.sort(result, function(a, b)
        if a.connected ~= b.connected then return a.connected == true end
        return tostring(a.displayName) < tostring(b.displayName)
    end)
    return result
end

function AgriLife.Career6Service:applyClientTeamSnapshot(farmId, viewerProfileId, snapshots)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.fail("CAREER_FARM_INVALID", "Farm is invalid") end
    local farmState = self:createDefaultFarmState()
    for _, snapshot in ipairs(snapshots or {}) do
        local profileId = cleanProfileId(snapshot.profileId)
        if profileId ~= "" then
            local state = self:createDefaultState()
            state.totalXP = safeInteger(snapshot.totalXP, 0)
            state.reputation = safeInteger(snapshot.reputation, 50)
            for _, specialty in ipairs(snapshot.specialties or {}) do
                if self:isSpecialtyValid(specialty.id) then state.specialties[specialty.id] = safeInteger(specialty.xp, 0) end
            end
            local stats = snapshot.stats or {}
            state.stats.workMs = math.floor(math.max(0, safeNumber(stats.workHours, 0)) * 3600000 + 0.5)
            state.stats.distanceMeters = math.max(0, safeNumber(stats.distanceKm, 0)) * 1000
            state.stats.areaSqm = math.max(0, safeNumber(stats.areaHa, 0)) * 10000
            state.stats.harvestedSqm = math.max(0, safeNumber(stats.harvestedHa, 0)) * 10000
            state.stats.transportedTonnesKm = math.max(0, safeNumber(stats.transportedTonnesKm, 0))
            state.stats.transportedTonnes = math.max(0, safeNumber(stats.transportedTonnes, 0))
            state.stats.livestockCareUnits = math.max(0, safeNumber(stats.livestockCareUnits, 0))
            state.stats.diagnostics = safeInteger(stats.diagnostics, 0)
            state.stats.repairs = safeInteger(stats.repairs, 0)
            state.stats.examsPassed = safeInteger(stats.examsPassed, 0)
            state.stats.examsFailed = safeInteger(stats.examsFailed, 0)
            farmState.profiles[profileId] = state
            local activityId = tostring(snapshot.activeSpecialtyId or "")
            local remainingMs = math.max(0, safeInteger(snapshot.activityRemainingMs, 0))
            local runtimeKey = self:getRuntimeKey(farmId, profileId)
            if runtimeKey ~= nil then
                if self:isSpecialtyValid(activityId) and remainingMs > 0 then
                    local now = getRuntimeTime()
                    self.activityByProfile[runtimeKey] = {
                        farmId = farmId,
                        profileId = profileId,
                        specialtyId = activityId,
                        activeUntil = now + math.min(remainingMs, self.ACTIVE_WORK_TTL_MS),
                        visibleUntil = now + remainingMs
                    }
                else
                    self.activityByProfile[runtimeKey] = nil
                end
            end
        end
    end
    farmState.viewerProfileId = cleanProfileId(viewerProfileId)
    self.farms[farmId] = farmState
    return AgriLife.Result.ok("CAREER_CLIENT_SNAPSHOT_APPLIED", "Career team snapshot applied", { profileCount = #(snapshots or {}) })
end

function AgriLife.Career6Service:writeProfileState(xmlFile, baseKey, state)
    xmlFile:setInt(baseKey .. ".state#totalXP", safeInteger(state.totalXP, 0))
    xmlFile:setInt(baseKey .. ".state#reputation", safeInteger(state.reputation, 50))
    xmlFile:setFloat(baseKey .. ".state#residualDrivingMeters", safeNumber(state.residualDrivingMeters, 0))
    xmlFile:setFloat(baseKey .. ".state#residualTransportXP", safeNumber(state.residualTransportXP, 0))
    state.residualFieldXP = state.residualFieldXP or {}
    for specialtyId, _ in pairs(self.FIELD_XP_PER_HA) do xmlFile:setFloat(baseKey .. ".fieldResidual#" .. specialtyId, safeNumber(state.residualFieldXP[specialtyId], 0)) end
    for _, definition in ipairs(self.SPECIALTIES) do xmlFile:setInt(baseKey .. ".specialties#" .. definition.id, safeInteger(state.specialties[definition.id], 0)) end
    local stats = state.stats or {}
    xmlFile:setInt(baseKey .. ".stats#workMs", safeInteger(stats.workMs, 0))
    xmlFile:setFloat(baseKey .. ".stats#distanceMeters", safeNumber(stats.distanceMeters, 0))
    xmlFile:setFloat(baseKey .. ".stats#areaSqm", safeNumber(stats.areaSqm, 0))
    xmlFile:setFloat(baseKey .. ".stats#harvestedSqm", safeNumber(stats.harvestedSqm, 0))
    xmlFile:setFloat(baseKey .. ".stats#transportedTonnesKm", safeNumber(stats.transportedTonnesKm, 0))
    xmlFile:setFloat(baseKey .. ".stats#transportedTonnes", safeNumber(stats.transportedTonnes, 0))
    xmlFile:setFloat(baseKey .. ".stats#livestockCareUnits", safeNumber(stats.livestockCareUnits, 0))
    xmlFile:setInt(baseKey .. ".stats#diagnostics", safeInteger(stats.diagnostics, 0))
    xmlFile:setInt(baseKey .. ".stats#repairs", safeInteger(stats.repairs, 0))
    xmlFile:setInt(baseKey .. ".stats#examsPassed", safeInteger(stats.examsPassed, 0))
    xmlFile:setInt(baseKey .. ".stats#examsFailed", safeInteger(stats.examsFailed, 0))
end

function AgriLife.Career6Service:readProfileState(xmlFile, baseKey)
    local state = self:createDefaultState()
    state.totalXP = safeInteger(xmlFile:getInt(baseKey .. ".state#totalXP", 0), 0)
    state.reputation = math.floor(clamp(xmlFile:getInt(baseKey .. ".state#reputation", 50), 0, 100) + 0.5)
    state.residualDrivingMeters = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".state#residualDrivingMeters", 0), 0))
    state.residualTransportXP = clamp(safeNumber(xmlFile:getFloat(baseKey .. ".state#residualTransportXP", 0), 0), 0, 0.999999)
    for specialtyId, _ in pairs(self.FIELD_XP_PER_HA) do state.residualFieldXP[specialtyId] = clamp(safeNumber(xmlFile:getFloat(baseKey .. ".fieldResidual#" .. specialtyId, 0), 0), 0, 0.999999) end
    for _, definition in ipairs(self.SPECIALTIES) do state.specialties[definition.id] = safeInteger(xmlFile:getInt(baseKey .. ".specialties#" .. definition.id, 0), 0) end
    state.stats.workMs = safeInteger(xmlFile:getInt(baseKey .. ".stats#workMs", 0), 0)
    state.stats.distanceMeters = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#distanceMeters", 0), 0))
    state.stats.areaSqm = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#areaSqm", 0), 0))
    state.stats.harvestedSqm = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#harvestedSqm", 0), 0))
    state.stats.transportedTonnesKm = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#transportedTonnesKm", 0), 0))
    state.stats.transportedTonnes = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#transportedTonnes", 0), 0))
    state.stats.livestockCareUnits = math.max(0, safeNumber(xmlFile:getFloat(baseKey .. ".stats#livestockCareUnits", 0), 0))
    state.stats.diagnostics = safeInteger(xmlFile:getInt(baseKey .. ".stats#diagnostics", 0), 0)
    state.stats.repairs = safeInteger(xmlFile:getInt(baseKey .. ".stats#repairs", 0), 0)
    state.stats.examsPassed = safeInteger(xmlFile:getInt(baseKey .. ".stats#examsPassed", 0), 0)
    state.stats.examsFailed = safeInteger(xmlFile:getInt(baseKey .. ".stats#examsFailed", 0), 0)
    return state
end

function AgriLife.Career6Service:saveFarm(xmlFile, moduleKey, farmId)
    local farmState = self:getFarmState(farmId, true)
    if farmState == nil then return AgriLife.Result.fail("CAREER_FARM_INVALID", "Farm is invalid") end
    local profileIds = {}
    for profileId, _ in pairs(farmState.profiles) do table.insert(profileIds, profileId) end
    table.sort(profileIds)
    for index, profileId in ipairs(profileIds) do
        local baseKey = string.format("%s.profiles.profile(%d)", moduleKey, index - 1)
        xmlFile:setString(baseKey .. "#profileId", profileId)
        self:writeProfileState(xmlFile, baseKey, farmState.profiles[profileId])
    end
    return AgriLife.Result.ok("CAREER_FARM_SAVED", "Career profiles saved", { profileCount = #profileIds })
end

function AgriLife.Career6Service:findLegacyProfileId(farmId)
    local people = self:getPeopleService()
    if people ~= nil and people.getFarmState ~= nil then
        local peopleState = people:getFarmState(farmId, false)
        if peopleState ~= nil then
            for profileId, profile in pairs(peopleState.profiles or {}) do if profile.role == "owner" then return profileId end end
            for profileId, _ in pairs(peopleState.profiles or {}) do return profileId end
        end
    end
    return self:resolveProfileId(farmId, nil, nil)
end

function AgriLife.Career6Service:loadFarm(xmlFile, moduleKey, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("CAREER_CLIENT_LOAD_SKIPPED", "No farm-specific career state on this runtime") end
    local farmState = self:createDefaultFarmState()
    local loadedCount = 0
    if xmlFile ~= nil and moduleKey ~= nil and xmlFile.iterate ~= nil then
        xmlFile:iterate(moduleKey .. ".profiles.profile", function(_, key)
            local profileId = cleanProfileId(xmlFile:getString(key .. "#profileId", ""))
            if profileId ~= "" and farmState.profiles[profileId] == nil then
                farmState.profiles[profileId] = self:readProfileState(xmlFile, key)
                loadedCount = loadedCount + 1
            end
        end)
    end

    -- Schema 2 stored one farm-wide career. Migrate it once to the owner/local
    -- profile rather than silently discarding a player's existing progression.
    if loadedCount == 0 and xmlFile ~= nil and moduleKey ~= nil then
        local legacyXP = safeInteger(xmlFile:getInt(moduleKey .. ".state#totalXP", 0), 0)
        local legacyDistance = math.max(0, safeNumber(xmlFile:getFloat(moduleKey .. ".stats#distanceMeters", 0), 0))
        local legacyExams = safeInteger(xmlFile:getInt(moduleKey .. ".stats#examsPassed", 0), 0) + safeInteger(xmlFile:getInt(moduleKey .. ".stats#examsFailed", 0), 0)
        if legacyXP > 0 or legacyDistance > 0 or legacyExams > 0 then
            local profileId = self:findLegacyProfileId(farmId)
            if profileId ~= nil and profileId ~= "" then
                farmState.profiles[profileId] = self:readProfileState(xmlFile, moduleKey)
                loadedCount = 1
                AgriLife.Logger.info("Career", "Migrated farm-global Career state to profile %s on farm %d", tostring(profileId), farmId)
            end
        end
    end

    self.farms[farmId] = farmState
    return AgriLife.Result.ok("CAREER_FARM_LOADED", "Career profiles loaded", { profileCount = loadedCount })
end

function AgriLife.Career6Service:deleteProfile(farmId, profileId)
    local farmState = self:getFarmState(farmId, false)
    profileId = cleanProfileId(profileId)
    if farmState == nil or profileId == "" or farmState.profiles[profileId] == nil then
        return AgriLife.Result.ok("CAREER_PROFILE_ABSENT", "Career profile already absent")
    end
    farmState.profiles[profileId] = nil
    local runtimeKey = self:getRuntimeKey(farmId, profileId)
    if runtimeKey ~= nil then
        self.runtimeByProfile[runtimeKey] = nil
        self.activityByProfile[runtimeKey] = nil
        self.examLocks[runtimeKey] = nil
        self.examProbeWarnings[runtimeKey] = nil
    end
    for token, _ in pairs(self.recentTokens) do
        if tostring(token):find(tostring(farmId) .. ":" .. profileId .. ":", 1, true) == 1 then self.recentTokens[token] = nil end
    end
    return AgriLife.Result.ok("CAREER_PROFILE_DELETED", "Career profile deleted", { profileId = profileId })
end

function AgriLife.Career6Service:delete()
    self.farms = {}
    self.recentTokens = {}
    self.nextTokenCleanupAt = 0
    self.runtimeByProfile = {}
    self.activityByProfile = {}
    self.examLocks = {}
    self.examProbeWarnings = {}
    self.core = nil
end

-- Roadmap career record extension. The base XP system remains authoritative.
do
    local baseNew = AgriLife.Career6Service.new
    local baseAwardFieldWork = AgriLife.Career6Service.awardFieldWork
    local baseAwardTransport = AgriLife.Career6Service.awardTransport
    local baseRecordMaintenance = AgriLife.Career6Service.recordMaintenance
    local baseRecordLivestockCare = AgriLife.Career6Service.recordLivestockCare
    local baseRecordExamResult = AgriLife.Career6Service.recordExamResult
    local baseGetSnapshot = AgriLife.Career6Service.getSnapshot
    local baseSaveFarm = AgriLife.Career6Service.saveFarm
    local baseLoadFarm = AgriLife.Career6Service.loadFarm
    local baseDelete = AgriLife.Career6Service.delete

    local function careerRound(value)
        return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
    end

    function AgriLife.Career6Service.new(core)
        local self = baseNew(core)
        self.roadmapRecords = {}
        return self
    end

    function AgriLife.Career6Service:getRoadmapRecord(farmId, profileId, create)
        farmId = tonumber(farmId) or 0
        if farmId <= 0 then return nil, nil end
        local _, resolvedProfileId = self:getProfileState(farmId, profileId, create ~= false)
        resolvedProfileId = tostring(resolvedProfileId or profileId or "")
        if resolvedProfileId == "" then return nil, nil end
        self.roadmapRecords = self.roadmapRecords or {}
        self.roadmapRecords[farmId] = self.roadmapRecords[farmId] or {}
        local record = self.roadmapRecords[farmId][resolvedProfileId]
        if record == nil and create ~= false then
            record = {
                totalFieldSqm = 0,
                harvestedSqm = 0,
                transportTonnesKm = 0,
                maintenanceActions = 0,
                livestockCareUnits = 0,
                contractsCompleted = 0,
                incidents = 0,
                qualificationsEarned = 0,
                milestones = {},
                workHistory = {}
            }
            self.roadmapRecords[farmId][resolvedProfileId] = record
        end
        return record, resolvedProfileId
    end

    function AgriLife.Career6Service:recordRoadmapWork(farmId, profileId, kind, amount, referenceId)
        local record, resolvedProfileId = self:getRoadmapRecord(farmId, profileId, true)
        if record == nil then return end
        local item = {
            periodKey = 0,
            kind = tostring(kind or "activity"),
            amount = careerRound(amount or 0),
            referenceId = tostring(referenceId or "")
        }
        local environment = g_currentMission ~= nil and g_currentMission.environment or nil
        if environment ~= nil then
            item.periodKey = math.max(0, math.floor(tonumber(environment.currentYear) or 1)) * 12 + math.max(1, math.min(12, math.floor(tonumber(environment.currentPeriod) or 1)))
        end
        table.insert(record.workHistory, item)
        while #record.workHistory > 80 do table.remove(record.workHistory, 1) end
        return resolvedProfileId
    end

    function AgriLife.Career6Service:recordMilestone(farmId, profileId, kind, referenceId)
        local record = self:getRoadmapRecord(farmId, profileId, true)
        if record == nil then return AgriLife.Result.fail("CAREER_RECORD_INVALID", "Career record unavailable") end
        local periodKey = 0
        local environment = g_currentMission ~= nil and g_currentMission.environment or nil
        if environment ~= nil then periodKey = math.max(0, math.floor(tonumber(environment.currentYear) or 1)) * 12 + math.max(1, math.min(12, math.floor(tonumber(environment.currentPeriod) or 1))) end
        table.insert(record.milestones, {periodKey = periodKey, kind = tostring(kind or "milestone"), referenceId = tostring(referenceId or "")})
        while #record.milestones > 64 do table.remove(record.milestones, 1) end
        return AgriLife.Result.ok("CAREER_MILESTONE_RECORDED", "Career milestone recorded")
    end

    function AgriLife.Career6Service:recordContractCompletion(farmId, profileId, contractId)
        local record = self:getRoadmapRecord(farmId, profileId, true)
        if record ~= nil then record.contractsCompleted = math.max(0, math.floor(tonumber(record.contractsCompleted) or 0)) + 1 end
        self:recordRoadmapWork(farmId, profileId, "contract", 1, contractId)
    end

    function AgriLife.Career6Service:recordIncident(farmId, profileId, incidentId)
        local record = self:getRoadmapRecord(farmId, profileId, true)
        if record ~= nil then record.incidents = math.max(0, math.floor(tonumber(record.incidents) or 0)) + 1 end
        self:recordRoadmapWork(farmId, profileId, "incident", 1, incidentId)
    end

    function AgriLife.Career6Service:recordQualification(farmId, profileId, qualificationId)
        local record = self:getRoadmapRecord(farmId, profileId, true)
        if record ~= nil then record.qualificationsEarned = math.max(0, math.floor(tonumber(record.qualificationsEarned) or 0)) + 1 end
        self:recordMilestone(farmId, profileId, "qualification:" .. tostring(qualificationId or ""), qualificationId)
    end

    function AgriLife.Career6Service:awardFieldWork(farmId, specialtyId, areaSqm, quality, sourceToken, profileId)
        local result = baseAwardFieldWork(self, farmId, specialtyId, areaSqm, quality, sourceToken, profileId)
        if result ~= nil and result.ok then
            local resolvedProfileId = result.details ~= nil and result.details.profileId or profileId
            local record = self:getRoadmapRecord(farmId, resolvedProfileId, true)
            if record ~= nil then
                record.totalFieldSqm = careerRound((record.totalFieldSqm or 0) + math.max(0, tonumber(areaSqm) or 0))
                if tostring(specialtyId or "") == "harvesting" then record.harvestedSqm = careerRound((record.harvestedSqm or 0) + math.max(0, tonumber(areaSqm) or 0)) end
            end
            self:recordRoadmapWork(farmId, resolvedProfileId, "field:" .. tostring(specialtyId or "work"), math.max(0, tonumber(areaSqm) or 0), sourceToken)
        end
        return result
    end

    function AgriLife.Career6Service:awardTransport(farmId, tonnes, kilometers, quality, sourceToken, profileId)
        local result = baseAwardTransport(self, farmId, tonnes, kilometers, quality, sourceToken, profileId)
        if result ~= nil and result.ok then
            local resolvedProfileId = result.details ~= nil and result.details.profileId or profileId
            local record = self:getRoadmapRecord(farmId, resolvedProfileId, true)
            local tonnesKm = math.max(0, tonumber(tonnes) or 0) * math.max(0, tonumber(kilometers) or 0)
            if record ~= nil then record.transportTonnesKm = careerRound((record.transportTonnesKm or 0) + tonnesKm) end
            self:recordRoadmapWork(farmId, resolvedProfileId, "transport", tonnesKm, sourceToken)
        end
        return result
    end

    function AgriLife.Career6Service:recordMaintenance(farmId, kind, difficulty, sourceToken, profileId)
        local result = baseRecordMaintenance(self, farmId, kind, difficulty, sourceToken, profileId)
        if result ~= nil and result.ok then
            local record = self:getRoadmapRecord(farmId, profileId, true)
            if record ~= nil then record.maintenanceActions = math.max(0, math.floor(tonumber(record.maintenanceActions) or 0)) + 1 end
            self:recordRoadmapWork(farmId, profileId, "maintenance:" .. tostring(kind or "service"), 1, sourceToken)
        end
        return result
    end

    function AgriLife.Career6Service:recordLivestockCare(farmId, units, action, sourceToken, profileId)
        local result = baseRecordLivestockCare(self, farmId, units, action, sourceToken, profileId)
        if result ~= nil and result.ok then
            local record = self:getRoadmapRecord(farmId, profileId, true)
            if record ~= nil then record.livestockCareUnits = careerRound((record.livestockCareUnits or 0) + math.max(0, tonumber(units) or 0)) end
            self:recordRoadmapWork(farmId, profileId, "livestock:" .. tostring(action or "care"), units, sourceToken)
        end
        return result
    end

    function AgriLife.Career6Service:recordExamResult(farmId, passed, profileId)
        local result = baseRecordExamResult(self, farmId, passed, profileId)
        if result ~= nil and result.ok and passed == true then self:recordMilestone(farmId, profileId, "general_licence", "") end
        return result
    end

    function AgriLife.Career6Service:getSnapshot(farmId, profileId)
        local snapshot = baseGetSnapshot(self, farmId, profileId)
        if snapshot == nil then return nil end
        local record = self:getRoadmapRecord(farmId, snapshot.profileId or profileId, true)
        snapshot.careerRecord = record
        return snapshot
    end

    function AgriLife.Career6Service:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local records = self.roadmapRecords ~= nil and self.roadmapRecords[tonumber(farmId) or 0] or nil
        local profileIds = {}
        for profileId in pairs(records or {}) do table.insert(profileIds, profileId) end
        table.sort(profileIds)
        for index, profileId in ipairs(profileIds) do
            local record = records[profileId]
            local key = string.format("%s.roadmapRecords.profile(%d)", moduleKey, index - 1)
            xmlFile:setString(key .. "#profileId", profileId)
            xmlFile:setFloat(key .. "#totalFieldSqm", record.totalFieldSqm or 0); xmlFile:setFloat(key .. "#harvestedSqm", record.harvestedSqm or 0); xmlFile:setFloat(key .. "#transportTonnesKm", record.transportTonnesKm or 0); xmlFile:setInt(key .. "#maintenanceActions", record.maintenanceActions or 0); xmlFile:setFloat(key .. "#livestockCareUnits", record.livestockCareUnits or 0); xmlFile:setInt(key .. "#contractsCompleted", record.contractsCompleted or 0); xmlFile:setInt(key .. "#incidents", record.incidents or 0); xmlFile:setInt(key .. "#qualificationsEarned", record.qualificationsEarned or 0)
            for milestoneIndex, item in ipairs(record.milestones or {}) do local itemKey = string.format("%s.milestones.item(%d)", key, milestoneIndex - 1); xmlFile:setInt(itemKey .. "#periodKey", item.periodKey or 0); xmlFile:setString(itemKey .. "#kind", tostring(item.kind or "")); xmlFile:setString(itemKey .. "#referenceId", tostring(item.referenceId or "")) end
            for workIndex, item in ipairs(record.workHistory or {}) do local itemKey = string.format("%s.workHistory.item(%d)", key, workIndex - 1); xmlFile:setInt(itemKey .. "#periodKey", item.periodKey or 0); xmlFile:setString(itemKey .. "#kind", tostring(item.kind or "")); xmlFile:setFloat(itemKey .. "#amount", item.amount or 0); xmlFile:setString(itemKey .. "#referenceId", tostring(item.referenceId or "")) end
        end
        return result
    end

    function AgriLife.Career6Service:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok then return result end
        farmId = tonumber(farmId) or 0
        self.roadmapRecords = self.roadmapRecords or {}; self.roadmapRecords[farmId] = {}
        if xmlFile ~= nil and moduleKey ~= nil and xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".roadmapRecords.profile", function(_, key)
                local profileId = xmlFile:getString(key .. "#profileId", "")
                if profileId ~= "" then
                    local record = {totalFieldSqm = xmlFile:getFloat(key .. "#totalFieldSqm", 0), harvestedSqm = xmlFile:getFloat(key .. "#harvestedSqm", 0), transportTonnesKm = xmlFile:getFloat(key .. "#transportTonnesKm", 0), maintenanceActions = xmlFile:getInt(key .. "#maintenanceActions", 0), livestockCareUnits = xmlFile:getFloat(key .. "#livestockCareUnits", 0), contractsCompleted = xmlFile:getInt(key .. "#contractsCompleted", 0), incidents = xmlFile:getInt(key .. "#incidents", 0), qualificationsEarned = xmlFile:getInt(key .. "#qualificationsEarned", 0), milestones = {}, workHistory = {}}
                    xmlFile:iterate(key .. ".milestones.item", function(_, itemKey) table.insert(record.milestones, {periodKey = xmlFile:getInt(itemKey .. "#periodKey", 0), kind = xmlFile:getString(itemKey .. "#kind", ""), referenceId = xmlFile:getString(itemKey .. "#referenceId", "")}) end)
                    xmlFile:iterate(key .. ".workHistory.item", function(_, itemKey) table.insert(record.workHistory, {periodKey = xmlFile:getInt(itemKey .. "#periodKey", 0), kind = xmlFile:getString(itemKey .. "#kind", ""), amount = xmlFile:getFloat(itemKey .. "#amount", 0), referenceId = xmlFile:getString(itemKey .. "#referenceId", "")}) end)
                    self.roadmapRecords[farmId][profileId] = record
                end
            end)
        end
        return result
    end

    function AgriLife.Career6Service:delete()
        self.roadmapRecords = {}
        return baseDelete(self)
    end
end
