-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.0 - behavioural propulsion energy consumption.
AgriLife = AgriLife or {}
AgriLife.VehicleEnergy93 = AgriLife.VehicleEnergy93 or {service=nil, installed=false, originalUpdateConsumers=nil}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.ENERGY_BEHAVIOR_VERSION = "0.9.3.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function upper(value) return string.upper(tostring(value or "")) end

    local function round(value, digits)
        local p = 10 ^ math.max(0, math.floor(tonumber(digits) or 2))
        return math.floor((tonumber(value) or 0) * p + 0.5) / p
    end

    local NON_PROPULSION = {AIR=true, DEF=true, ADBLUE=true, COMPRESSEDAIR=true}
    local LIQUID_FUELS = {DIESEL=true, HVO=true, BIODIESEL=true, GASOLINE=true, PETROL=true, E85=true}
    local ELECTRIC_NAMES = {ELECTRICCHARGE=true, ELECTRIC_CHARGE=true, ELECTRICITY=true, BATTERY=true, CHARGE=true}
    local GAS_FUELS = {METHANE=true, CNG=true, LNG=true, BIOGAS=true, HYDROGEN=true}

    function Workshop:getEnergyDifficultyPolicy(farmId)
        local mode = self:getDifficultyId(farmId)
        if mode == "facile" then return {consumption=0.88, behaviorPenalty=0.65, conditionPenalty=0.70, name="facile"} end
        if mode == "difficile" then return {consumption=1.12, behaviorPenalty=1.15, conditionPenalty=1.10, name="difficile"} end
        return {consumption=1.00, behaviorPenalty=1.00, conditionPenalty=1.00, name="normal"}
    end

    function Workshop:getEnergyFillType(consumer)
        if consumer == nil then return nil end
        local index = tonumber(consumer.fillType)
        if index == nil or g_fillTypeManager == nil or type(g_fillTypeManager.getFillTypeByIndex) ~= "function" then return nil end
        local ok, fillType = pcall(g_fillTypeManager.getFillTypeByIndex, g_fillTypeManager, index)
        return ok and fillType or nil
    end

    function Workshop:isPropulsionEnergyConsumer(runtimeVehicle, consumer)
        if runtimeVehicle == nil or consumer == nil or consumer.permanentConsumption ~= true or (tonumber(consumer.usage) or 0) <= 0 then return false end
        local fillType = self:getEnergyFillType(consumer)
        local name = upper(fillType ~= nil and fillType.name or "")
        if NON_PROPULSION[name] then return false end
        if LIQUID_FUELS[name] or ELECTRIC_NAMES[name] or GAS_FUELS[name] then return true end

        local market = self:getMarketService()
        if market ~= nil and type(market.classifyFillType) == "function" and fillType ~= nil then
            local ok, category = pcall(market.classifyFillType, market, fillType)
            if ok and (category == "fuel" or category == "energy") and not NON_PROPULSION[name] then return true end
        end

        return name ~= "" and not NON_PROPULSION[name]
    end

    function Workshop:getVehiclePowerKw(runtimeVehicle)
        local motorized = self:getRootMotorizedVehicle(runtimeVehicle)
        local motor = motorized ~= nil and motorized.spec_motorized ~= nil and motorized.spec_motorized.motor or nil
        if motor ~= nil then
            local power = tonumber(motor.peakMotorPower)
            if power ~= nil and power > 1 then return clamp(power, 8, 1500) end
            if type(motor.getPeakMotorPower) == "function" then
                local ok, value = pcall(motor.getPeakMotorPower, motor)
                if ok and tonumber(value) ~= nil and tonumber(value) > 1 then return clamp(value, 8, 1500) end
            end
        end
        local pricePower = tonumber(runtimeVehicle ~= nil and (runtimeVehicle.power or runtimeVehicle.maxPower or runtimeVehicle.motorPower))
        if pricePower ~= nil and pricePower > 1 then
            return clamp(pricePower * 0.73549875, 8, 1500)
        end
        return 110
    end

    function Workshop:getMechanicalEfficiencyPenalty(stateVehicle)
        if stateVehicle == nil or type(stateVehicle.systems) ~= "table" then return 1 end
        local ids = {"engine","lubrication","fuel","admission","cooling","transmission","drivetrain"}
        local condition, service, count = 0, 0, 0
        for _, id in ipairs(ids) do
            local system = stateVehicle.systems[id]
            if system ~= nil then
                condition = condition + clamp(system.condition or 1, 0, 1)
                service = service + clamp(system.service or 1, 0, 1)
                count = count + 1
            end
        end
        if count <= 0 then return 1 end
        condition = condition / count
        service = service / count
        return clamp(1 + (1-condition) * 0.12 + (1-service) * 0.07, 1, 1.18)
    end

    function Workshop:getBehaviorEnergyPenalty(stateVehicle, farmId)
        local behavior = self:ensureBehavioralWearState(stateVehicle)
        local policy = self:getEnergyDifficultyPolicy(farmId)
        local aggression = clamp(behavior ~= nil and behavior.aggression or 0, 0, 2.5)
        return clamp(1 + aggression * 0.075 * policy.behaviorPenalty, 1, 1.18)
    end

    function Workshop:getConsumerFullLoadUsageLph(farmId, runtimeVehicle, stateVehicle, consumer)
        local fillType = self:getEnergyFillType(consumer)
        local name = upper(fillType ~= nil and fillType.name or "")
        local xmlUsageLph = math.max(0.05, (tonumber(consumer.usage) or 0) * 60 * 60 * 1000)
        local powerKw = self:getVehiclePowerKw(runtimeVehicle)
        local policy = self:getEnergyDifficultyPolicy(farmId)

        local powerBased
        if LIQUID_FUELS[name] or name == "" then
            powerBased = powerKw * 0.215
        elseif ELECTRIC_NAMES[name] then
            powerBased = xmlUsageLph * clamp(math.pow(powerKw / 110, 0.10), 0.78, 1.28)
        elseif GAS_FUELS[name] then
            powerBased = xmlUsageLph * clamp(math.pow(powerKw / 110, 0.12), 0.76, 1.32)
        else
            powerBased = xmlUsageLph * clamp(math.pow(powerKw / 110, 0.10), 0.78, 1.28)
        end

        local blended = LIQUID_FUELS[name] and (powerBased * 0.72 + xmlUsageLph * 0.28) or (powerBased * 0.55 + xmlUsageLph * 0.45)
        blended = clamp(blended, xmlUsageLph * 0.55, xmlUsageLph * 1.85)
        local conditionPenalty = self:getMechanicalEfficiencyPenalty(stateVehicle)
        conditionPenalty = 1 + (conditionPenalty - 1) * policy.conditionPenalty
        local behaviorPenalty = self:getBehaviorEnergyPenalty(stateVehicle, farmId)
        return blended * policy.consumption * conditionPenalty * behaviorPenalty, {
            carrier=name ~= "" and name or "UNKNOWN",
            powerKw=powerKw,
            horsepower=powerKw * 1.3596216173,
            xmlUsageLph=xmlUsageLph,
            conditionPenalty=conditionPenalty,
            behaviorPenalty=behaviorPenalty,
            difficultyFactor=policy.consumption
        }
    end

    function Workshop:ensureEnergyTelemetry(stateVehicle)
        stateVehicle.energyTelemetry = type(stateVehicle.energyTelemetry) == "table" and stateVehicle.energyTelemetry or {}
        local telemetry = stateVehicle.energyTelemetry
        telemetry.totalConsumed = math.max(0, tonumber(telemetry.totalConsumed) or 0)
        telemetry.lastUsagePerHour = math.max(0, tonumber(telemetry.lastUsagePerHour) or 0)
        telemetry.powerKw = math.max(0, tonumber(telemetry.powerKw) or 0)
        telemetry.horsepower = math.max(0, tonumber(telemetry.horsepower) or 0)
        telemetry.carrier = tostring(telemetry.carrier or "")
        telemetry.conditionPenalty = clamp(telemetry.conditionPenalty or 1, 1, 1.5)
        telemetry.behaviorPenalty = clamp(telemetry.behaviorPenalty or 1, 1, 1.5)
        telemetry.difficultyFactor = clamp(telemetry.difficultyFactor or 1, 0.5, 1.5)
        telemetry.marketFactor = clamp(telemetry.marketFactor or 1, 0.4, 2)
        return telemetry
    end

    function Workshop:getEnergyMarketFactor(farmId, consumer)
        local market = self:getMarketService()
        local fillType = self:getEnergyFillType(consumer)
        if market == nil or fillType == nil then return 1 end
        if type(market.classifyFillType) == "function" and type(market.getCategoryMultiplier) == "function" then
            local okCategory, category = pcall(market.classifyFillType, market, fillType)
            if okCategory and (category == "fuel" or category == "energy") then
                local okFactor, factor = pcall(market.getCategoryMultiplier, market, farmId, category)
                if okFactor and tonumber(factor) ~= nil then return clamp(factor, 0.4, 2) end
            end
        end
        return 1
    end

    function Workshop:prepareEnergyConsumers(runtimeVehicle)
        local farmId = self:getVehicleFarmId(runtimeVehicle)
        if farmId <= 0 then return nil end
        if self.core ~= nil and self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then return nil end
        local runtimeIndex = 0
        for index, candidate in ipairs(self:getRuntimeVehicles()) do if candidate == runtimeVehicle then runtimeIndex = index; break end end
        local assetId = self:getVehicleId(runtimeVehicle, runtimeIndex)
        local stateVehicle = self:ensureStep8Vehicle(farmId, assetId, runtimeVehicle)
        if stateVehicle == nil then return nil end
        local spec = runtimeVehicle.spec_motorized
        if spec == nil or type(spec.consumers) ~= "table" then return nil end
        local backups, telemetryRows = {}, {}
        for _, consumer in pairs(spec.consumers) do
            if self:isPropulsionEnergyConsumer(runtimeVehicle, consumer) then
                local targetLph, details = self:getConsumerFullLoadUsageLph(farmId, runtimeVehicle, stateVehicle, consumer)
                table.insert(backups, {consumer=consumer, usage=consumer.usage})
                consumer.usage = targetLph / 1.5 / (60 * 60 * 1000)
                details.consumer = consumer
                details.targetFullLoadLph = targetLph
                details.marketFactor = self:getEnergyMarketFactor(farmId, consumer)
                table.insert(telemetryRows, details)
            end
        end
        if #backups == 0 then return nil end
        return {farmId=farmId, assetId=assetId, stateVehicle=stateVehicle, backups=backups, rows=telemetryRows}
    end

    function Workshop:finalizeEnergyConsumers(runtimeVehicle, context, dt)
        if context == nil then return end
        for _, backup in ipairs(context.backups or {}) do backup.consumer.usage = backup.usage end
        local spec = runtimeVehicle ~= nil and runtimeVehicle.spec_motorized or nil
        local telemetry = self:ensureEnergyTelemetry(context.stateVehicle)
        local lastUsage = math.max(0, tonumber(spec ~= nil and spec.lastFuelUsage) or 0)
        telemetry.lastUsagePerHour = lastUsage
        if lastUsage > 0 and tonumber(dt) ~= nil then telemetry.totalConsumed = telemetry.totalConsumed + lastUsage / (60 * 60 * 1000) * math.max(0, dt) end
        local first = context.rows ~= nil and context.rows[1] or nil
        if first ~= nil then
            telemetry.powerKw = first.powerKw or telemetry.powerKw
            telemetry.horsepower = first.horsepower or telemetry.horsepower
            telemetry.carrier = first.carrier or telemetry.carrier
            telemetry.conditionPenalty = first.conditionPenalty or 1
            telemetry.behaviorPenalty = first.behaviorPenalty or 1
            telemetry.difficultyFactor = first.difficultyFactor or 1
            telemetry.marketFactor = first.marketFactor or 1
            telemetry.targetFullLoadLph = first.targetFullLoadLph or 0
        end
        runtimeVehicle.agriLifeEnergyTelemetry = telemetry
    end

    function Workshop:installEnergyConsumptionHook93()
        if AgriLife.VehicleEnergy93.installed == true then AgriLife.VehicleEnergy93.service = self; return true end
        if Motorized == nil or type(Motorized.updateConsumers) ~= "function" then return false end
        local original = Motorized.updateConsumers
        AgriLife.VehicleEnergy93.originalUpdateConsumers = original
        Motorized.updateConsumers = function(runtimeVehicle, dt, accInput, ...)
            local service = AgriLife.VehicleEnergy93.service
            if service == nil or runtimeVehicle == nil or runtimeVehicle.spec_motorized == nil then return original(runtimeVehicle, dt, accInput, ...) end
            local context = service:prepareEnergyConsumers(runtimeVehicle)
            if context == nil then return original(runtimeVehicle, dt, accInput, ...) end

            local missionInfo = g_currentMission ~= nil and g_currentMission.missionInfo or nil
            local previousFuelSetting = missionInfo ~= nil and missionInfo.fuelUsage or nil
            local wearable = runtimeVehicle.spec_wearable
            local savedDamage = wearable ~= nil and wearable.damage or nil
            local savedDamageByCurve = wearable ~= nil and wearable.damageByCurve or nil
            if missionInfo ~= nil then missionInfo.fuelUsage = 2 end
            if wearable ~= nil then wearable.damage = 0; wearable.damageByCurve = 0 end

            local ok, errorMessage = pcall(original, runtimeVehicle, dt, accInput, ...)

            if wearable ~= nil then wearable.damage = savedDamage or 0; wearable.damageByCurve = savedDamageByCurve or 0 end
            if missionInfo ~= nil and previousFuelSetting ~= nil then missionInfo.fuelUsage = previousFuelSetting end
            service:finalizeEnergyConsumers(runtimeVehicle, context, dt)
            if not ok then error(errorMessage) end
        end
        AgriLife.VehicleEnergy93.service = self
        AgriLife.VehicleEnergy93.installed = true
        return true
    end

    local baseNewEnergy93 = Workshop.new
    function Workshop.new(core)
        local self = baseNewEnergy93(core)
        AgriLife.VehicleEnergy93.service = self
        self:installEnergyConsumptionHook93()
        return self
    end

    local baseUpdateEnergy93 = Workshop.update
    function Workshop:update(dt)
        AgriLife.VehicleEnergy93.service = self
        if AgriLife.VehicleEnergy93.installed ~= true then self:installEnergyConsumptionHook93() end
        return baseUpdateEnergy93(self, dt)
    end

    local baseSnapshotEnergy93 = Workshop.getSnapshot
    function Workshop:getSnapshot(farmId)
        local snapshot = baseSnapshotEnergy93(self, farmId)
        snapshot.behavioralEnergyConsumption = true
        snapshot.energyConsumptionVersion = Workshop.ENERGY_BEHAVIOR_VERSION
        snapshot.energyDifficultyPolicy = self:getEnergyDifficultyPolicy(farmId)
        for _, vehicle in ipairs(snapshot.vehicles or {}) do
            local telemetry = self:ensureEnergyTelemetry(vehicle)
            vehicle.energyCarrier = telemetry.carrier
            vehicle.energyPowerKw = round(telemetry.powerKw, 1)
            vehicle.energyHorsepower = round(telemetry.horsepower, 0)
            vehicle.energyUsagePerHour = round(telemetry.lastUsagePerHour, 2)
            vehicle.energyTotalConsumed = round(telemetry.totalConsumed, 2)
            vehicle.energyConditionPenalty = round(telemetry.conditionPenalty, 3)
            vehicle.energyBehaviorPenalty = round(telemetry.behaviorPenalty, 3)
            vehicle.energyDifficultyFactor = round(telemetry.difficultyFactor, 3)
            vehicle.energyMarketFactor = round(telemetry.marketFactor, 3)
            vehicle.energyTargetFullLoad = round(telemetry.targetFullLoadLph or 0, 2)
        end
        return snapshot
    end

    local baseSaveEnergy93 = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveEnergy93(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getState(farmId, true)
        local index = 0
        for assetId, vehicle in pairs(state.vehicles or {}) do
            local telemetry = self:ensureEnergyTelemetry(vehicle)
            local key = string.format("%s.roadmap93.energy.assets.asset(%d)", moduleKey, index); index = index + 1
            xmlFile:setString(key.."#assetId", tostring(assetId))
            xmlFile:setString(key.."#carrier", tostring(telemetry.carrier or ""))
            for _, field in ipairs({"totalConsumed","lastUsagePerHour","powerKw","horsepower","conditionPenalty","behaviorPenalty","difficultyFactor","marketFactor","targetFullLoadLph"}) do
                xmlFile:setFloat(key.."#"..field, tonumber(telemetry[field]) or 0)
            end
        end
        return result
    end

    local baseLoadEnergy93 = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadEnergy93(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false or xmlFile == nil or moduleKey == nil or xmlFile.iterate == nil then return result end
        local state = self:getState(farmId, true)
        xmlFile:iterate(moduleKey..".roadmap93.energy.assets.asset", function(_, key)
            local assetId = xmlFile:getString(key.."#assetId", "")
            local vehicle = state.vehicles[assetId]
            if vehicle ~= nil then
                local telemetry = self:ensureEnergyTelemetry(vehicle)
                telemetry.carrier = xmlFile:getString(key.."#carrier", "")
                for _, field in ipairs({"totalConsumed","lastUsagePerHour","powerKw","horsepower","conditionPenalty","behaviorPenalty","difficultyFactor","marketFactor","targetFullLoadLph"}) do
                    telemetry[field] = xmlFile:getFloat(key.."#"..field, telemetry[field] or 0)
                end
            end
        end)
        return result
    end

    local baseChecklistEnergy93 = Workshop.getRoadmap8Checklist
    function Workshop:getRoadmap8Checklist(farmId)
        local checklist = baseChecklistEnergy93(self, farmId) or {}
        checklist.behavioralEnergyConsumption = true
        checklist.powerLoadConsumption = true
        checklist.mechanicalEfficiencyConsumption = true
        checklist.dynamicEnergyMarketBridge = self:getMarketService() ~= nil
        checklist.energyDifficultyPolicy = true
        checklist.energyConsumptionVersion = Workshop.ENERGY_BEHAVIOR_VERSION
        return checklist
    end
end

if AgriLife.WorkshopModule ~= nil then
    AgriLife.WorkshopModule.VERSION = "0.9.3.0"
end
