-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.0 - behavioural mechanical wear authority.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.BEHAVIORAL_WEAR_VERSION = "0.9.3.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function round(value, digits)
        local p = 10 ^ math.max(0, math.floor(tonumber(digits) or 2))
        return math.floor((tonumber(value) or 0) * p + 0.5) / p
    end

    local function angleDelta(a, b)
        local d = (tonumber(a) or 0) - (tonumber(b) or 0)
        while d > math.pi do d = d - math.pi * 2 end
        while d < -math.pi do d = d + math.pi * 2 end
        return d
    end

    local function callNumber(object, methodName, default)
        if object ~= nil and type(object[methodName]) == "function" then
            local ok, value = pcall(object[methodName], object)
            if ok and tonumber(value) ~= nil then return tonumber(value) end
        end
        return tonumber(default) or 0
    end

    local function callBool(object, methodName)
        if object ~= nil and type(object[methodName]) == "function" then
            local ok, value = pcall(object[methodName], object)
            if ok then return value == true end
        end
        return false
    end

    function Workshop:getBehavioralWearPolicy(farmId)
        local mode = self:getDifficultyId(farmId)
        if mode == "facile" then
            return {wear=0.62, stress=0.72, impact=0.68, tolerance=1.18, fault=0.72, name="facile"}
        elseif mode == "difficile" then
            return {wear=1.18, stress=1.14, impact=1.12, tolerance=0.90, fault=1.14, name="difficile"}
        end
        return {wear=1.00, stress=1.00, impact=1.00, tolerance=1.00, fault=1.00, name="normal"}
    end

    function Workshop:ensureBehavioralWearState(vehicle)
        if vehicle == nil then return nil end
        vehicle.behavioralWear = type(vehicle.behavioralWear) == "table" and vehicle.behavioralWear or {}
        local state = vehicle.behavioralWear
        state.score = clamp(state.score or 100, 0, 100)
        state.aggression = clamp(state.aggression or 0, 0, 2.5)
        state.usageHours = math.max(0, tonumber(state.usageHours) or 0)
        state.harshAccelerationEvents = math.max(0, math.floor(tonumber(state.harshAccelerationEvents) or 0))
        state.harshBrakingEvents = math.max(0, math.floor(tonumber(state.harshBrakingEvents) or 0))
        state.highSpeedCornerEvents = math.max(0, math.floor(tonumber(state.highSpeedCornerEvents) or 0))
        state.overloadEvents = math.max(0, math.floor(tonumber(state.overloadEvents) or 0))
        state.impactEvents = math.max(0, math.floor(tonumber(state.impactEvents) or 0))
        state.majorImpactEvents = math.max(0, math.floor(tonumber(state.majorImpactEvents) or 0))
        state.lastImpactSeverity = clamp(state.lastImpactSeverity or 0, 0, 1)
        state.totalBehaviorWear = math.max(0, tonumber(state.totalBehaviorWear) or 0)
        state.systemStress = type(state.systemStress) == "table" and state.systemStress or {}
        return state
    end

    function Workshop:getRootMotorizedVehicle(runtimeVehicle)
        if runtimeVehicle == nil then return nil end
        if runtimeVehicle.spec_motorized ~= nil then return runtimeVehicle end
        if type(runtimeVehicle.getRootVehicle) == "function" then
            local ok, root = pcall(runtimeVehicle.getRootVehicle, runtimeVehicle)
            if ok and root ~= nil and root.spec_motorized ~= nil then return root end
        end
        local root = runtimeVehicle.rootVehicle
        if root ~= nil and root.spec_motorized ~= nil then return root end
        return nil
    end

    function Workshop:getRuntimeHeading(runtimeVehicle)
        if runtimeVehicle == nil or runtimeVehicle.rootNode == nil or runtimeVehicle.rootNode == 0 or getWorldRotation == nil then return nil end
        local ok, _, ry, _ = pcall(getWorldRotation, runtimeVehicle.rootNode)
        return ok and tonumber(ry) or nil
    end

    function Workshop:getRuntimeLoad(runtimeVehicle)
        local motorized = self:getRootMotorizedVehicle(runtimeVehicle)
        if motorized == nil then return 0 end
        local spec = motorized.spec_motorized
        local load = tonumber(spec ~= nil and (spec.smoothedLoadPercentage or spec.actualLoadPercentage)) or 0
        if load > 1.5 then load = load / 100 end
        if load <= 0 then
            for _, methodName in ipairs({"getMotorLoadPercentage", "getMotorLoad"}) do
                if type(motorized[methodName]) == "function" then
                    local ok, value = pcall(motorized[methodName], motorized)
                    if ok and tonumber(value) ~= nil then load = tonumber(value); break end
                end
            end
            if load > 1.5 then load = load / 100 end
        end
        return clamp(load, 0, 1.5)
    end

    function Workshop:getRuntimeRpmPercentage(runtimeVehicle)
        local motorized = self:getRootMotorizedVehicle(runtimeVehicle)
        if motorized == nil then return 0 end
        if type(motorized.getMotorRpmPercentage) == "function" then
            local ok, value = pcall(motorized.getMotorRpmPercentage, motorized)
            if ok and tonumber(value) ~= nil then return clamp(value, 0, 1.25) end
        end
        local motor = motorized.spec_motorized ~= nil and motorized.spec_motorized.motor or nil
        if motor ~= nil then
            local minRpm = callNumber(motor, "getMinRpm", motor.minRpm or 800)
            local maxRpm = math.max(minRpm + 1, callNumber(motor, "getMaxRpm", motor.maxRpm or 2200))
            local rpm = callNumber(motor, "getLastMotorRpm", motor.lastMotorRpm or minRpm)
            return clamp((rpm - minRpm) / (maxRpm - minRpm), 0, 1.25)
        end
        return 0
    end

    function Workshop:getRuntimeWheelSlip(runtimeVehicle)
        local mechanical = self:getMechanicalSnapshot(runtimeVehicle)
        local slip = mechanical ~= nil and mechanical.mudSystem ~= nil and tonumber(mechanical.mudSystem.wheelSlip) or nil
        if slip ~= nil then return clamp(slip, 0, 2) end
        local motorized = self:getRootMotorizedVehicle(runtimeVehicle)
        local wheels = motorized ~= nil and motorized.spec_wheels or runtimeVehicle ~= nil and runtimeVehicle.spec_wheels or nil
        if wheels ~= nil then
            for _, field in ipairs({"wheelSlip", "lastWheelSlip", "maxWheelSlip"}) do
                if tonumber(wheels[field]) ~= nil then return clamp(wheels[field], 0, 2) end
            end
        end
        return 0
    end

    function Workshop:getRuntimeWorkActive(runtimeVehicle)
        if runtimeVehicle == nil then return false end
        for _, methodName in ipairs({"getIsTurnedOn", "getIsLowered", "getIsOperating", "getIsWorkAreaActive"}) do
            if callBool(runtimeVehicle, methodName) then return true end
        end
        local root = self:getRootMotorizedVehicle(runtimeVehicle)
        if root ~= nil and root ~= runtimeVehicle and callBool(root, "getIsTurnedOn") then return true end
        return false
    end

    function Workshop:computeBehavioralStress(runtimeVehicle, stateVehicle, elapsedSeconds)
        elapsedSeconds = clamp(elapsedSeconds, 0.05, 3)
        local behavior = self:ensureBehavioralWearState(stateVehicle)
        if behavior == nil or runtimeVehicle == nil then return {} end

        local speedKph = math.abs(tonumber(runtimeVehicle.lastSpeedReal or runtimeVehicle.lastSpeed) or 0) * 3.6
        local speedMps = speedKph / 3.6
        local previousSpeed = tonumber(behavior.lastSpeedMps)
        local acceleration = previousSpeed ~= nil and (speedMps - previousSpeed) / elapsedSeconds or 0
        behavior.lastSpeedMps = speedMps

        local heading = self:getRuntimeHeading(runtimeVehicle)
        local previousHeading = tonumber(behavior.lastHeading)
        local yawRate = heading ~= nil and previousHeading ~= nil and math.abs(angleDelta(heading, previousHeading)) / elapsedSeconds or 0
        behavior.lastHeading = heading
        local lateralIndex = yawRate * math.max(0, speedMps) / 4.5

        local load = self:getRuntimeLoad(runtimeVehicle)
        local rpm = self:getRuntimeRpmPercentage(runtimeVehicle)
        local slip = self:getRuntimeWheelSlip(runtimeVehicle)
        local working = self:getRuntimeWorkActive(runtimeVehicle)

        local accelStress = clamp((acceleration - 1.6) / 2.8, 0, 1.5)
        local brakeStress = clamp((-acceleration - 2.2) / 3.8, 0, 1.5)
        local cornerStress = clamp((lateralIndex - 0.34) / 1.20, 0, 1.6)
        local speedStress = clamp((speedKph - 42) / 55, 0, 1.2)
        local loadStress = clamp((load - 0.78) / 0.40, 0, 1.5)
        local rpmStress = clamp((rpm - 0.86) / 0.28, 0, 1.2)
        local slipStress = clamp((slip - 0.24) / 0.70, 0, 1.5)
        local workStress = working and clamp((load - 0.72) / 0.45, 0, 1.4) or 0

        local eventCooldown = math.max(0, tonumber(behavior.eventCooldown) or 0) - elapsedSeconds
        behavior.eventCooldown = eventCooldown
        if eventCooldown <= 0 then
            if accelStress > 0.45 then behavior.harshAccelerationEvents = behavior.harshAccelerationEvents + 1; behavior.eventCooldown = 1.5
            elseif brakeStress > 0.45 then behavior.harshBrakingEvents = behavior.harshBrakingEvents + 1; behavior.eventCooldown = 1.5
            elseif cornerStress > 0.50 then behavior.highSpeedCornerEvents = behavior.highSpeedCornerEvents + 1; behavior.eventCooldown = 1.5
            elseif loadStress > 0.85 and working then behavior.overloadEvents = behavior.overloadEvents + 1; behavior.eventCooldown = 2.0 end
        end

        local instantAggression = clamp(
            accelStress * 0.18 + brakeStress * 0.20 + cornerStress * 0.24 + speedStress * 0.08 +
            loadStress * 0.14 + rpmStress * 0.07 + slipStress * 0.09,
            0, 2.5)
        local smoothing = clamp(elapsedSeconds / 20, 0.02, 0.20)
        behavior.aggression = clamp((behavior.aggression or 0) * (1 - smoothing) + instantAggression * smoothing, 0, 2.5)
        behavior.score = clamp(100 - behavior.aggression * 38, 0, 100)
        if speedKph > 0.5 or load > 0.08 or working then behavior.usageHours = behavior.usageHours + elapsedSeconds / 3600 end

        local stress = {
            engine = loadStress * 0.72 + rpmStress * 0.36 + accelStress * 0.12,
            lubrication = loadStress * 0.34 + rpmStress * 0.30,
            fuel = loadStress * 0.14 + rpmStress * 0.10,
            admission = loadStress * 0.20,
            cooling = loadStress * 0.34 + rpmStress * 0.18,
            transmission = accelStress * 0.48 + loadStress * 0.38 + slipStress * 0.46,
            drivetrain = accelStress * 0.34 + loadStress * 0.28 + slipStress * 0.50,
            hydraulics = workStress * 0.26,
            brakes = brakeStress * 0.78 + speedStress * 0.16,
            steering = cornerStress * 0.56 + speedStress * 0.10,
            suspension = cornerStress * 0.42 + brakeStress * 0.24 + speedStress * 0.18,
            chassis = cornerStress * 0.12 + speedStress * 0.18,
            tyres = cornerStress * 0.62 + brakeStress * 0.34 + accelStress * 0.18 + slipStress * 0.58 + speedStress * 0.22,
            bearings = cornerStress * 0.34 + speedStress * 0.20 + slipStress * 0.20,
            axles = cornerStress * 0.30 + brakeStress * 0.22 + loadStress * 0.18,
            pto = workStress * 0.42 + rpmStress * (working and 0.18 or 0),
            workSystem = workStress * 0.55 + speedStress * (working and 0.12 or 0),
            dosing = workStress * 0.18,
            electronics = 0,
            hitch = workStress * 0.20 + cornerStress * 0.10
        }
        behavior.systemStress = stress
        runtimeVehicle.agriLifeBehavioralStress = stress
        runtimeVehicle.agriLifeBehaviorScore = behavior.score
        runtimeVehicle.agriLifeBehaviorAggression = behavior.aggression
        return stress
    end

    function Workshop:neutralizeVanillaWear(runtimeVehicle)
        if runtimeVehicle == nil or runtimeVehicle.spec_wearable == nil then return false end
        local spec = runtimeVehicle.spec_wearable
        if type(runtimeVehicle.setDamageAmount) == "function" then pcall(runtimeVehicle.setDamageAmount, runtimeVehicle, 0, true) else spec.damage = 0 end
        spec.damage = 0
        spec.damageByCurve = 0
        if type(spec.wearableNodes) == "table" and type(runtimeVehicle.setNodeWearAmount) == "function" then
            for _, nodeData in ipairs(spec.wearableNodes) do pcall(runtimeVehicle.setNodeWearAmount, runtimeVehicle, nodeData, 0, true) end
        elseif type(spec.wearableNodes) == "table" then
            for _, nodeData in ipairs(spec.wearableNodes) do nodeData.wearAmount = 0; nodeData.wearAmountSent = 0 end
            spec.totalAmount = 0
        end
        runtimeVehicle.agriLifeVanillaWearNeutralized = true
        return true
    end

    function Workshop:applyBehavioralImpact(farmId, assetId, runtimeVehicle, stateVehicle, nativeDamage)
        nativeDamage = clamp(nativeDamage, 0, 1)
        local behavior = self:ensureBehavioralWearState(stateVehicle)
        if behavior.nativeDamageBaselineCleared ~= true then
            behavior.nativeDamageBaselineCleared = true
            return nil
        end
        if nativeDamage < 0.0015 then return nil end
        local policy = self:getBehavioralWearPolicy(farmId)
        local previousSpeed = tonumber(behavior.lastSpeedMps) or 0
        local currentSpeed = math.abs(tonumber(runtimeVehicle.lastSpeedReal or runtimeVehicle.lastSpeed) or 0)
        local abruptStop = clamp((previousSpeed - currentSpeed - 1.8) / 8, 0, 1)
        if nativeDamage < 0.006 and abruptStop < 0.16 then return nil end
        local severity = clamp(nativeDamage * 5.5 + abruptStop * 0.30, 0, 1)
        local loss = (0.0012 + math.pow(severity, 1.65) * 0.060) * policy.impact
        if severity < 0.12 then loss = loss * 0.45 end

        local hasWheels = runtimeVehicle.spec_wheels ~= nil or runtimeVehicle.spec_wheelBased ~= nil or runtimeVehicle.spec_trailer ~= nil
        local weights = {chassis=0.40, hitch=0.18}
        if hasWheels then
            weights.tyres=0.58; weights.bearings=0.34; weights.axles=0.30; weights.suspension=0.28; weights.steering=0.22
        end
        if severity >= 0.45 and runtimeVehicle.spec_motorized ~= nil then
            weights.cooling=0.22; weights.drivetrain=0.16; weights.engine=severity >= 0.78 and 0.12 or 0
        end
        for systemId, weight in pairs(weights) do
            local system = stateVehicle.systems ~= nil and stateVehicle.systems[systemId] or nil
            if system ~= nil and weight > 0 then
                local componentLoss = loss * weight
                system.condition = clamp((tonumber(system.condition) or 1) - componentLoss, 0.03, 1)
                system.stress = clamp((tonumber(system.stress) or 0) + severity * weight * 0.8, 0, 3)
                system.faultExposure = math.max(0, tonumber(system.faultExposure) or 0) + severity * weight * 0.025 * policy.fault
            end
        end

        behavior.impactEvents = behavior.impactEvents + 1
        behavior.lastImpactSeverity = severity
        if severity >= 0.50 then behavior.majorImpactEvents = behavior.majorImpactEvents + 1 end
        self:addLifeEvent(farmId, assetId, "BEHAVIOR_IMPACT", string.format("severity=%.3f;native=%.4f", severity, nativeDamage))

        if severity >= 0.42 and (tonumber(behavior.accidentCooldownUntil) or 0) <= self:getGameMinuteStamp() then
            behavior.accidentCooldownUntil = self:getGameMinuteStamp() + 0.5
            local amount = math.max(250, (tonumber(stateVehicle.value) or 50000) * math.min(1.10, (0.025 + math.pow(severity, 2.20) * 0.98) * policy.impact))
            local result = self:reportAccident(farmId, assetId, amount, self:getResponsibleProfileId(farmId, runtimeVehicle), "behavioral_collision")
            if result ~= nil and result.ok then stateVehicle.lastBehaviorAccidentId = tostring(result.details ~= nil and result.details.accidentId or "") end
        end
        return severity
    end

    local baseGetRuntimeStress93 = Workshop.getRuntimeStress
    function Workshop:getRuntimeStress(runtimeVehicle)
        local stress = baseGetRuntimeStress93(self, runtimeVehicle) or {}
        local behavior = runtimeVehicle ~= nil and runtimeVehicle.agriLifeBehavioralStress or nil
        if type(behavior) == "table" then
            for systemId, value in pairs(behavior) do stress[systemId] = math.max(0, tonumber(stress[systemId]) or 0) + math.max(0, tonumber(value) or 0) end
        end
        return stress
    end

    local baseMechanicalSnapshot93 = Workshop.getMechanicalSnapshot
    function Workshop:getMechanicalSnapshot(runtimeVehicle)
        local snapshot = baseMechanicalSnapshot93(self, runtimeVehicle) or {}
        if snapshot.authority ~= nil and tostring(snapshot.authority) ~= "AGRILIFE" then snapshot.observedAuthority = snapshot.authority end
        snapshot.authority = "AGRILIFE"
        snapshot.fallbackAgriLife = true
        if snapshot.advancedDamageSystem ~= nil then
            snapshot.advancedDamageSystem.observer = snapshot.advancedDamageSystem.loaded == true
            snapshot.advancedDamageSystem.provider = false
        end
        return snapshot
    end

    local baseUpdateMechanical93 = Workshop.updateInternalMechanicalState
    function Workshop:updateInternalMechanicalState(farmId, assetId, runtimeVehicle, stateVehicle)
        local previousHours = tonumber(stateVehicle.lastTechnicalHours) or tonumber(stateVehicle.hours) or 0
        local previousKm = tonumber(stateVehicle.lastTechnicalKm) or tonumber(stateVehicle.kilometers) or 0
        local result = baseUpdateMechanical93(self, farmId, assetId, runtimeVehicle, stateVehicle)
        local currentHours = tonumber(stateVehicle.lastTechnicalHours) or previousHours
        local currentKm = tonumber(stateVehicle.lastTechnicalKm) or previousKm
        local deltaHours = math.max(0, currentHours - previousHours)
        local deltaKm = math.max(0, currentKm - previousKm)
        if deltaHours <= 0 and deltaKm <= 0 then return result end

        local policy = self:getBehavioralWearPolicy(farmId)
        local stress = runtimeVehicle ~= nil and runtimeVehicle.agriLifeBehavioralStress or {}
        local equivalentHours = deltaHours + deltaKm / 45 * 0.08
        local behavior = self:ensureBehavioralWearState(stateVehicle)
        for systemId, system in pairs(stateVehicle.systems or {}) do
            local definition = Workshop.SYSTEM_DEFINITIONS ~= nil and Workshop.SYSTEM_DEFINITIONS[systemId] or nil
            local instantaneous = math.max(0, tonumber(stress[systemId]) or 0)
            if definition ~= nil and instantaneous > 0.05 and equivalentHours > 0 then
                local excess = math.max(0, instantaneous - 0.05 * policy.tolerance)
                local extraWear = definition.wear * equivalentHours * excess * 0.52 * policy.wear
                if extraWear > 0 then
                    system.condition = clamp((tonumber(system.condition) or 1) - extraWear, 0.03, 1)
                    behavior.totalBehaviorWear = behavior.totalBehaviorWear + extraWear
                end
            end
        end
        local avg, count = 0, 0
        for _, system in pairs(stateVehicle.systems or {}) do avg = avg + (tonumber(system.condition) or 1); count = count + 1 end
        if count > 0 then stateVehicle.condition = clamp(avg / count, 0.03, 1) end
        return result
    end

    local baseApplyRuntimeCondition93 = Workshop.applyRuntimeCondition
    function Workshop:applyRuntimeCondition(farmId, assetId, condition)
        local runtimeVehicle = self:findRuntimeVehicle(farmId, assetId)
        if runtimeVehicle ~= nil and self:isMaintainableAsset(runtimeVehicle) then
            self:neutralizeVanillaWear(runtimeVehicle)
            return true
        end
        return baseApplyRuntimeCondition93(self, farmId, assetId, condition)
    end

    local baseUpdateBehavior93 = Workshop.update
    function Workshop:update(dt)
        local result = baseUpdateBehavior93(self, dt)
        if self.core == nil or self.core.context == nil or not self.core.context.isServer then return result end
        self.behaviorWearAccumulator = (tonumber(self.behaviorWearAccumulator) or 0) + math.max(0, tonumber(dt) or 0)
        if self.behaviorWearAccumulator < 350 then return result end
        local elapsedSeconds = clamp(self.behaviorWearAccumulator / 1000, 0.10, 2.0)
        self.behaviorWearAccumulator = 0

        for index, runtimeVehicle in ipairs(self:getRuntimeVehicles()) do
            local farmId = self:getVehicleFarmId(runtimeVehicle)
            if farmId > 0 and self:isMaintainableAsset(runtimeVehicle) then
                local assetId = self:getVehicleId(runtimeVehicle, index)
                local stateVehicle = self:ensureStep8Vehicle(farmId, assetId, runtimeVehicle)
                if stateVehicle ~= nil then
                    local nativeDamage = self:getVehicleDamage(runtimeVehicle)
                    self:applyBehavioralImpact(farmId, assetId, runtimeVehicle, stateVehicle, nativeDamage)
                    self:computeBehavioralStress(runtimeVehicle, stateVehicle, elapsedSeconds)
                    self:neutralizeVanillaWear(runtimeVehicle)
                end
            end
        end
        return result
    end

    local baseSnapshotBehavior93 = Workshop.getSnapshot
    function Workshop:getSnapshot(farmId)
        local snapshot = baseSnapshotBehavior93(self, farmId)
        snapshot.behavioralWearAuthority = true
        snapshot.vanillaMechanicalWearNeutralized = true
        snapshot.behavioralWearVersion = Workshop.BEHAVIORAL_WEAR_VERSION
        for _, vehicle in ipairs(snapshot.vehicles or {}) do
            local state = self:ensureBehavioralWearState(vehicle)
            vehicle.behaviorScore = round(state.score, 1)
            vehicle.behaviorAggression = round(state.aggression, 3)
            vehicle.behaviorUsageHours = round(state.usageHours, 2)
            vehicle.behaviorImpactEvents = state.impactEvents
            vehicle.behaviorMajorImpactEvents = state.majorImpactEvents
            vehicle.behaviorWearTotal = round(state.totalBehaviorWear, 5)
        end
        return snapshot
    end

    local baseSaveBehavior93 = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveBehavior93(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getState(farmId, true)
        local index = 0
        for assetId, vehicle in pairs(state.vehicles or {}) do
            local behavior = self:ensureBehavioralWearState(vehicle)
            local key = string.format("%s.roadmap93.behavior.assets.asset(%d)", moduleKey, index); index = index + 1
            xmlFile:setString(key.."#assetId", tostring(assetId))
            xmlFile:setFloat(key.."#score", behavior.score or 100)
            xmlFile:setFloat(key.."#aggression", behavior.aggression or 0)
            xmlFile:setFloat(key.."#usageHours", behavior.usageHours or 0)
            xmlFile:setFloat(key.."#totalBehaviorWear", behavior.totalBehaviorWear or 0)
            xmlFile:setFloat(key.."#lastImpactSeverity", behavior.lastImpactSeverity or 0)
            xmlFile:setInt(key.."#harshAccelerationEvents", behavior.harshAccelerationEvents or 0)
            xmlFile:setInt(key.."#harshBrakingEvents", behavior.harshBrakingEvents or 0)
            xmlFile:setInt(key.."#highSpeedCornerEvents", behavior.highSpeedCornerEvents or 0)
            xmlFile:setInt(key.."#overloadEvents", behavior.overloadEvents or 0)
            xmlFile:setInt(key.."#impactEvents", behavior.impactEvents or 0)
            xmlFile:setInt(key.."#majorImpactEvents", behavior.majorImpactEvents or 0)
        end
        return result
    end

    local baseLoadBehavior93 = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadBehavior93(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false or xmlFile == nil or moduleKey == nil or xmlFile.iterate == nil then return result end
        local state = self:getState(farmId, true)
        xmlFile:iterate(moduleKey..".roadmap93.behavior.assets.asset", function(_, key)
            local assetId = xmlFile:getString(key.."#assetId", "")
            local vehicle = state.vehicles[assetId]
            if vehicle ~= nil then
                local behavior = self:ensureBehavioralWearState(vehicle)
                behavior.score = xmlFile:getFloat(key.."#score", 100)
                behavior.aggression = xmlFile:getFloat(key.."#aggression", 0)
                behavior.usageHours = xmlFile:getFloat(key.."#usageHours", 0)
                behavior.totalBehaviorWear = xmlFile:getFloat(key.."#totalBehaviorWear", 0)
                behavior.lastImpactSeverity = xmlFile:getFloat(key.."#lastImpactSeverity", 0)
                behavior.harshAccelerationEvents = xmlFile:getInt(key.."#harshAccelerationEvents", 0)
                behavior.harshBrakingEvents = xmlFile:getInt(key.."#harshBrakingEvents", 0)
                behavior.highSpeedCornerEvents = xmlFile:getInt(key.."#highSpeedCornerEvents", 0)
                behavior.overloadEvents = xmlFile:getInt(key.."#overloadEvents", 0)
                behavior.impactEvents = xmlFile:getInt(key.."#impactEvents", 0)
                behavior.majorImpactEvents = xmlFile:getInt(key.."#majorImpactEvents", 0)
            end
        end)
        return result
    end

    local baseChecklistBehavior93 = Workshop.getRoadmap8Checklist
    function Workshop:getRoadmap8Checklist(farmId)
        local checklist = baseChecklistBehavior93(self, farmId) or {}
        checklist.behavioralWearAuthority = true
        checklist.vanillaWearNeutralized = true
        checklist.behavioralImpactDamage = true
        checklist.difficultyBehaviorPolicy = true
        checklist.behavioralWearVersion = Workshop.BEHAVIORAL_WEAR_VERSION
        return checklist
    end
end

if AgriLife.WorkshopModule ~= nil then
    AgriLife.WorkshopModule.VERSION = "0.9.3.0"
end
