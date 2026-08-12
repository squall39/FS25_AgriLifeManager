-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Workshop 8.1 completion: maintainable assets, hard immobilization and field repairs.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.ROADMAP81_VERSION = "0.9.2.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function tr(key)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(key or "")
    end

    local function lower(value)
        return string.lower(tostring(value or "")):gsub("\\", "/")
    end

    local NON_MAINTAINABLE_TOKENS = {
        "sparepartspallet", "fieldservicekit", "handtool", "bigbag", "pallet", "bale"
    }

    function Workshop:isMaintainableAsset(vehicle)
        if vehicle == nil or vehicle.rootNode == nil then return false end
        if vehicle.spec_fieldServiceKit6 ~= nil then return false end
        if vehicle.agriLifeDealerLoaner == true or string.find(tostring(vehicle.agriLifeAssetId or ""), "DEALER_LOANER_", 1, true) == 1 then return false end
        if vehicle.spec_pallet ~= nil or vehicle.spec_bigBag ~= nil or vehicle.spec_handTool ~= nil or vehicle.spec_bale ~= nil then return false end

        local filename = lower(vehicle.configFileName)
        local typeName = lower(vehicle.typeName)
        for _, token in ipairs(NON_MAINTAINABLE_TOKENS) do
            if string.find(filename, token, 1, true) ~= nil or string.find(typeName, token, 1, true) ~= nil then return false end
        end

        if vehicle.spec_motorized ~= nil then return true end
        if vehicle.spec_trailer ~= nil or vehicle.spec_attachable ~= nil then return true end
        if vehicle.spec_wheels ~= nil or vehicle.spec_wheelBased ~= nil then return true end
        if vehicle.spec_powerConsumer ~= nil or vehicle.spec_powerTakeOffs ~= nil or vehicle.spec_powerTakeOff ~= nil then return true end
        if vehicle.spec_workArea ~= nil or vehicle.spec_workAreas ~= nil then return true end
        if vehicle.spec_frontloader ~= nil or vehicle.spec_frontloaderTool ~= nil or vehicle.spec_shovel ~= nil then return true end
        if vehicle.spec_dynamicMountAttacher ~= nil or vehicle.spec_attacherJoints ~= nil then return true end
        return false
    end

    local baseGetAssetKind81 = Workshop.getAssetKind
    function Workshop:getAssetKind(vehicle)
        if vehicle == nil then return "unknown" end
        if vehicle.spec_motorized ~= nil then return baseGetAssetKind81(self, vehicle) end
        local filename = lower(vehicle.configFileName)
        local typeName = lower(vehicle.typeName)
        if string.find(filename, "weight", 1, true) ~= nil or string.find(typeName, "weight", 1, true) ~= nil then return "accessory" end
        if vehicle.spec_frontloaderTool ~= nil or vehicle.spec_shovel ~= nil then return "loader_accessory" end
        if vehicle.spec_trailer ~= nil then return "trailer" end
        if vehicle.spec_attachable ~= nil then return "implement" end
        return baseGetAssetKind81(self, vehicle)
    end

    local baseSyncVehicles81 = Workshop.syncVehicles
    function Workshop:syncVehicles(farmId)
        local state = self:getState(farmId, true)
        if state == nil then return 0 end
        local count = 0
        local runtimeIds = {}
        for index, vehicle in ipairs(self:getRuntimeVehicles()) do
            if self:getVehicleFarmId(vehicle) == tonumber(farmId) then
                local assetId = self:getVehicleId(vehicle, index)
                if self:isMaintainableAsset(vehicle) then
                    self:registerVehicle(farmId, assetId, self:getVehicleName(vehicle), self:getPrice(vehicle), self:getOperatingHours(vehicle))
                    runtimeIds[assetId] = true
                    count = count + 1
                elseif state.vehicles ~= nil and state.vehicles[assetId] ~= nil then
                    state.vehicles[assetId] = nil
                end
            end
        end
        if count <= 0 and baseSyncVehicles81 ~= nil and g_currentMission == nil then return baseSyncVehicles81(self, farmId) end
        return count
    end

    function Workshop:getInternalWorkshopInfrastructure(farmId)
        local level = 0
        local sources = {}
        local placeables = g_currentMission ~= nil and g_currentMission.placeableSystem ~= nil and g_currentMission.placeableSystem.placeables or {}
        for _, placeable in pairs(type(placeables) == "table" and placeables or {}) do
            local owner = tonumber(placeable.ownerFarmId) or 0
            if placeable.getOwnerFarmId ~= nil then
                local ok, value = pcall(placeable.getOwnerFarmId, placeable)
                if ok then owner = tonumber(value) or owner end
            end
            if owner == tonumber(farmId) then
                local typeName = lower(placeable.typeName or placeable.configFileName)
                local current = 0
                if placeable.spec_workshop ~= nil or placeable.spec_vehicleWorkshop ~= nil or string.find(typeName, "workshop", 1, true) ~= nil then
                    current = 3
                elseif placeable.spec_oilServicePoint6 ~= nil then
                    current = 2
                end
                if current > 0 then
                    level = math.max(level, current)
                    table.insert(sources, {kind="placeable", level=current, name=tostring(placeable.name or placeable.typeName or "workshop"), object=placeable})
                end
            end
        end
        for _, runtime in ipairs(self:getRuntimeVehicles()) do
            if self:getVehicleFarmId(runtime) == tonumber(farmId) and runtime.spec_fieldServiceKit6 ~= nil then
                level = math.max(level, 1)
                table.insert(sources, {kind="mobile_emergency", level=1, name=self:getVehicleName(runtime), object=runtime})
            end
        end
        return {level=level, available=level>0, sources=sources}
    end

    local baseIsMechanicAvailable81 = Workshop.isMechanicAvailable
    local baseGetMechanicCapability81 = Workshop.getMechanicCapability

    function Workshop:getPeopleService81()
        local people = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.people or nil
        return people ~= nil and (people.service or people) or nil
    end

    function Workshop:isOwnerMechanic81(farmId, profileId)
        profileId = tostring(profileId or "")
        if profileId == "" then return false end
        local people = self:getPeopleService81()
        return people ~= nil and people.isFarmOwner ~= nil and people:isFarmOwner(farmId, profileId) == true
    end

    function Workshop:getOwnerMaintenanceXp81(farmId, profileId)
        local career = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.career or nil
        local service = career ~= nil and (career.service or career) or nil
        if service == nil or service.getProfileState == nil then return 0 end
        local state = service:getProfileState(farmId, profileId, false)
        return math.max(0, tonumber(state ~= nil and state.specialties ~= nil and state.specialties.maintenance) or 0)
    end

    function Workshop:isMechanicAvailable(farmId, profileId)
        if self:isOwnerMechanic81(farmId, profileId) then
            local state = self:getState(farmId, true)
            if state.mechanicReservations[profileId] ~= nil then return false, "mechanic_reserved" end
            return true, ""
        end
        return baseIsMechanicAvailable81(self, farmId, profileId)
    end

    function Workshop:getMechanicCapability(farmId, profileId)
        if self:isOwnerMechanic81(farmId, profileId) then
            local xp = self:getOwnerMaintenanceXp81(farmId, profileId)
            local level = xp >= 7500 and 3 or (xp >= 1000 and 2 or 1)
            local skill = level == 3 and math.min(100, 72 + (xp-7500)/1200) or (level == 2 and math.min(71, 48 + (xp-1000)/270) or math.min(47, 35 + xp/77))
            return {level=level, skill=math.floor(skill+0.5), specialist=true, owner=true, maintenanceXP=xp}
        end
        return baseGetMechanicCapability81(self, farmId, profileId)
    end

    function Workshop:shouldRecordInternalPayroll(farmId, profileId)
        return not self:isOwnerMechanic81(farmId, profileId)
    end

    local baseApplyTechnicalEffects81 = Workshop.applyTechnicalEffects
    function Workshop:applyTechnicalEffects(farmId, assetId, runtimeVehicle, vehicle)
        baseApplyTechnicalEffects81(self, farmId, assetId, runtimeVehicle, vehicle)
        if runtimeVehicle == nil or vehicle == nil then return end
        local effects = runtimeVehicle.agriLifeTechnicalEffects or self:aggregateFaultEffects(vehicle)
        local administrativeLock = vehicle.technicalInspectionStatus == "CRITICAL" or vehicle.technicalInspectionStatus == "EXPIRED_CRITICAL"
        local hardLock = effects.lockStart == true or effects.stopEngine == true or effects.immobilize == true or administrativeLock
        runtimeVehicle.agriLifeStartLocked = hardLock
        runtimeVehicle.agriLifeStartLockReason = hardLock and (administrativeLock and "TECHNICAL_INSPECTION" or "MECHANICAL_FAULT") or ""
        vehicle.startLocked = hardLock
    end

    Workshop.FIELD_REPAIR_RULES = {
        BATTERY_FAILURE={maxStage=4, complete=true},
        FUEL_FILTER_CLOGGED={maxStage=3, complete=true},
        AIR_FILTER_CLOGGED={maxStage=3, complete=true},
        HYDRAULIC_HOSE_LEAK={maxStage=3, complete=false, targetStage=1},
        TYRE_PUNCTURE={maxStage=3, complete=true},
        LIGHTING_FAILURE={maxStage=3, complete=true},
        COOLANT_LEAK={maxStage=2, complete=false, targetStage=1},
        FUEL_LEAK={maxStage=2, complete=false, targetStage=1}
    }

    function Workshop:getAvailablePartQuality(farmId, partFamily)
        local state = self:getState(farmId, true)
        for _, qualityId in ipairs({"OEM", "AFTERMARKET", "REMANUFACTURED", "USED"}) do
            local key = self:getPartInventoryKey(partFamily, qualityId)
            if (tonumber(state.partsInventory ~= nil and state.partsInventory[key]) or 0) >= 1 then return qualityId end
        end
        return nil
    end

    function Workshop:getFieldRepairEligibility(farmId, assetId)
        local vehicle = self:findVehicle(farmId, assetId)
        if vehicle == nil then return {eligible=false, reason="asset_missing"} end
        local heavyFound = false
        for _, fault in ipairs(self:getActiveFaults(vehicle)) do
            local rule = Workshop.FIELD_REPAIR_RULES[tostring(fault.id or "")]
            if rule ~= nil and (tonumber(fault.stage) or 1) <= rule.maxStage then
                local qualityId = self:getAvailablePartQuality(farmId, fault.partFamily)
                if qualityId ~= nil then
                    return {eligible=true, fault=fault, rule=rule, partFamily=fault.partFamily, qualityId=qualityId}
                end
                return {eligible=false, reason="part_required", fault=fault, partFamily=fault.partFamily}
            end
            local effect = self:getFaultEffect(fault)
            if (tonumber(fault.stage) or 1) >= 3 or effect.immobilize == true or effect.stopEngine == true or effect.lockStart == true or effect.safetyCritical == true then heavyFound = true end
        end
        return {eligible=false, reason=heavyFound and "heavy_fault" or "no_eligible_fault"}
    end

    function Workshop:performFieldEmergencyRepair(farmId, assetId, profileId)
        local vehicle = self:findVehicle(farmId, assetId)
        if vehicle == nil then return AgriLife.Result.fail("WORKSHOP81_FIELD_ASSET_MISSING", tr("agrilife_workshop81_field_asset_missing")) end
        local eligibility = self:getFieldRepairEligibility(farmId, assetId)
        if not eligibility.eligible then
            local key = eligibility.reason == "part_required" and "agrilife_workshop81_field_part_required" or (eligibility.reason == "heavy_fault" and "agrilife_workshop81_field_heavy_fault" or "agrilife_workshop81_field_no_fault")
            return AgriLife.Result.fail("WORKSHOP81_FIELD_NOT_ELIGIBLE", tr(key), eligibility)
        end
        if not self:consumePart(farmId, eligibility.partFamily, eligibility.qualityId, 1) then
            return AgriLife.Result.fail("WORKSHOP81_FIELD_PART_REQUIRED", tr("agrilife_workshop81_field_part_required"), eligibility)
        end

        local fault = eligibility.fault
        local rule = eligibility.rule
        local system = vehicle.systems ~= nil and vehicle.systems[fault.systemId] or nil
        if rule.complete == true then
            fault.status = "repaired"
            fault.repairedPeriodKey = self:getPeriodKey()
            fault.repairJobId = "FIELD_" .. tostring(self:getGameMinuteStamp())
            if system ~= nil then
                system.condition = math.max(tonumber(system.condition) or 0, 0.74)
                system.stress = math.max(0, (tonumber(system.stress) or 0) * 0.55)
                system.installedPartQuality = eligibility.qualityId
            end
            self:addLifeEvent(farmId, assetId, "FIELD_REPAIR_COMPLETED", tostring(fault.id) .. ":" .. eligibility.qualityId)
            return AgriLife.Result.ok("WORKSHOP81_FIELD_REPAIR_COMPLETED", tr("agrilife_workshop81_field_repair_completed"), {faultId=fault.id, qualityId=eligibility.qualityId, permanent=true})
        end

        fault.stage = math.max(1, math.floor(tonumber(rule.targetStage) or 1))
        fault.detected = true
        fault.fieldStabilized = true
        fault.fieldStabilizedPeriodKey = self:getPeriodKey()
        if system ~= nil then
            system.condition = math.max(tonumber(system.condition) or 0, 0.48)
            system.stress = math.max(0, (tonumber(system.stress) or 0) * 0.72)
        end
        self:addLifeEvent(farmId, assetId, "FIELD_REPAIR_STABILIZED", tostring(fault.id) .. ":" .. eligibility.qualityId)
        return AgriLife.Result.ok("WORKSHOP81_FIELD_REPAIR_STABILIZED", tr("agrilife_workshop81_field_repair_stabilized"), {faultId=fault.id, qualityId=eligibility.qualityId, permanent=false})
    end

    function Workshop:installAgriLifeStartLockHook()
        if Workshop._agriLifeStartLockHookInstalled == true then return true end
        if Motorized == nil then return false end
        local installed = false
        if type(Motorized.startMotor) == "function" then
            local originalStartMotor = Motorized.startMotor
            Motorized.startMotor = function(vehicle, ...)
                if vehicle ~= nil and vehicle.agriLifeStartLocked == true then
                    if g_currentMission ~= nil and g_currentMission.addIngameNotification ~= nil and FSBaseMission ~= nil then
                        pcall(g_currentMission.addIngameNotification, g_currentMission, FSBaseMission.INGAME_NOTIFICATION_CRITICAL, tr("agrilife_workshop81_start_locked"))
                    end
                    return false
                end
                return originalStartMotor(vehicle, ...)
            end
            installed = true
        end
        if type(Motorized.getCanMotorRun) == "function" then
            local originalCanMotorRun = Motorized.getCanMotorRun
            Motorized.getCanMotorRun = function(vehicle, ...)
                if vehicle ~= nil and vehicle.agriLifeStartLocked == true then return false end
                return originalCanMotorRun(vehicle, ...)
            end
            installed = true
        end
        Workshop._agriLifeStartLockHookInstalled = installed
        return installed
    end

    Workshop:installAgriLifeStartLockHook()

    local baseUpdateRoadmap81 = Workshop.update
    function Workshop:update(dt)
        if Workshop._agriLifeStartLockHookInstalled ~= true then self:installAgriLifeStartLockHook() end
        return baseUpdateRoadmap81(self, dt)
    end

    local baseGetRoadmap8Checklist81 = Workshop.getRoadmap8Checklist
    function Workshop:getRoadmap8Checklist(farmId)
        local checklist = baseGetRoadmap8Checklist81(self, farmId) or {}
        checklist.roadmap81Version = Workshop.ROADMAP81_VERSION
        checklist.maintainableAssetFilter = true
        checklist.hardStartLock = Workshop._agriLifeStartLockHookInstalled == true
        checklist.fieldEmergencyRepair = true
        checklist.serviceTruckPlayerRemoved = true
        return checklist
    end
end

if AgriLife.WorkshopModule ~= nil then
    AgriLife.WorkshopModule.VERSION = "0.9.2.0"
    function AgriLife.WorkshopModule:isMaintainableAsset(...) return self.service:isMaintainableAsset(...) end
    function AgriLife.WorkshopModule:getFieldRepairEligibility(...) return self.service:getFieldRepairEligibility(...) end
    function AgriLife.WorkshopModule:performFieldEmergencyRepair(...) return self.service:performFieldEmergencyRepair(...) end
end
