-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.CareerWorkTracker ~= nil then
    local Tracker = AgriLife.CareerWorkTracker
    local baseRecordAreaSqmInterFarm = Tracker.recordAreaSqm

    local function getFarmlandIdAt(x, z)
        if x == nil or z == nil or g_farmlandManager == nil or g_farmlandManager.getFarmlandIdAtWorldPosition == nil then return 0 end
        local ok, value = pcall(g_farmlandManager.getFarmlandIdAtWorldPosition, g_farmlandManager, x, z)
        return ok and tonumber(value) or 0
    end

    local function getFillSample(vehicle)
        if vehicle == nil or vehicle.getFillUnits == nil or vehicle.getFillUnitFillLevel == nil or vehicle.getFillUnitFillType == nil then return 0, 0 end
        local okUnits, units = pcall(vehicle.getFillUnits, vehicle)
        if not okUnits or type(units) ~= "table" then return 0, 0 end
        local total = 0
        local selectedType = 0
        local selectedLevel = 0
        for key, row in pairs(units) do
            local index = tonumber(row ~= nil and row.fillUnitIndex) or tonumber(key)
            if index ~= nil then
                local okLevel, level = pcall(vehicle.getFillUnitFillLevel, vehicle, index)
                local okType, fillTypeIndex = pcall(vehicle.getFillUnitFillType, vehicle, index)
                level = okLevel and math.max(0, tonumber(level) or 0) or 0
                fillTypeIndex = okType and tonumber(fillTypeIndex) or 0
                local fillType = g_fillTypeManager ~= nil and g_fillTypeManager.getFillTypeByIndex ~= nil and g_fillTypeManager:getFillTypeByIndex(fillTypeIndex) or nil
                local commercial = fillType ~= nil and fillType.showOnPriceTable ~= false and fillTypeIndex > 0
                if commercial then
                    total = total + level
                    if level > selectedLevel then selectedLevel = level; selectedType = fillTypeIndex end
                end
            end
        end
        return total, selectedType
    end

    function Tracker:recordAreaSqm(vehicle, specialtyId, areaSqm, source, workX, workZ, explicitProfileId, explicitFarmId)
        baseRecordAreaSqmInterFarm(self, vehicle, specialtyId, areaSqm, source, workX, workZ, explicitProfileId, explicitFarmId)
        local farmId = tonumber(explicitFarmId) or 0
        if farmId <= 0 and self.getOperatingProfile ~= nil then
            local _, resolvedFarmId = self:getOperatingProfile(vehicle)
            farmId = tonumber(resolvedFarmId) or 0
        end
        if farmId <= 0 then return end
        local registry = self.service ~= nil and self.service.core ~= nil and self.service.core.registry or nil
        local module = registry ~= nil and registry.instances ~= nil and registry.instances.commercialContracts or nil
        local contracts = module ~= nil and module.service or nil
        if contracts == nil or contracts.recordInterFarmVehicleWork == nil then return end
        local farmlandId = getFarmlandIdAt(workX, workZ)
        local hectares = math.max(0, tonumber(areaSqm) or 0) / 10000
        local now = tonumber(g_time) or 0
        self._interFarmWorkSamples = self._interFarmWorkSamples or setmetatable({}, {__mode = "k"})
        local sample = self._interFarmWorkSamples[vehicle]
        local hours = 0
        if sample ~= nil and now >= tonumber(sample.time or now) then hours = math.min(5 / 60, math.max(0, now - tonumber(sample.time or now)) / 3600000) end
        local fillLevel, fillTypeIndex = getFillSample(vehicle)
        local harvested = 0
        if tostring(specialtyId or "") == "harvesting" and sample ~= nil and fillLevel > tonumber(sample.fillLevel or 0) then harvested = fillLevel - tonumber(sample.fillLevel or 0) end
        self._interFarmWorkSamples[vehicle] = {time = now, fillLevel = fillLevel, fillTypeIndex = fillTypeIndex}
        contracts:recordInterFarmVehicleWork(farmId, farmlandId, hectares, hours, harvested, fillTypeIndex)
    end
end
