-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 7 optional agronomy adapters.
AgriLife = AgriLife or {}

if AgriLife.Compatibility6Service ~= nil then
    local Compatibility = AgriLife.Compatibility6Service
    Compatibility.ROADMAP7_VERSION = "0.7.9.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function callProvider(provider, farmlandId)
        if provider == nil then return nil, "provider_missing" end
        for _, methodName in ipairs({"getFarmlandData", "getFieldData", "getSoilData", "getFarmlandFieldInfo"}) do
            local method = provider[methodName]
            if type(method) == "function" then
                local ok, data = pcall(method, provider, farmlandId)
                if ok and data ~= nil then return data, methodName end
            end
        end
        return nil, "no_supported_reader"
    end

    local function normalizeData(data)
        if type(data) ~= "table" then return data end
        local normalized = {}
        for key, value in pairs(data) do normalized[key] = value end
        local quality = tonumber(data.quality or data.score or data.environmentalScore or data.environmentScore or data.yieldPotential)
        if quality ~= nil then
            if quality <= 1.5 then quality = quality * 100 end
            normalized.quality = clamp(quality, 0, 100)
        end
        local cost = tonumber(data.inputCostFactor or data.fertilizerCostFactor or data.inputFactor)
        if cost ~= nil then normalized.inputCostFactor = clamp(cost, 0.50, 1.75) end
        return normalized
    end

    local baseGetAgronomySnapshot = Compatibility.getAgronomySnapshot
    function Compatibility:getAgronomySnapshot(farmId, farmlandId)
        local snapshot = baseGetAgronomySnapshot(self, farmId, farmlandId) or {farmId = tonumber(farmId) or 0, farmlandId = tonumber(farmlandId) or 0}
        local detected = self:scan(false)
        if detected.precisionFarming ~= nil and detected.precisionFarming.providerAvailable == true then
            local provider = g_precisionFarming or g_precisionFarmingSoilMap
            local data, reader = callProvider(provider, farmlandId)
            snapshot.precisionFarming = snapshot.precisionFarming or {available = true, source = detected.precisionFarming.modName}
            snapshot.precisionFarming.available = true
            snapshot.precisionFarming.reader = reader
            if data ~= nil then snapshot.precisionFarming.data = normalizeData(data) end
        end
        if detected.soilFertilizer ~= nil and detected.soilFertilizer.providerAvailable == true then
            local provider = g_soilFertilizer or SoilFertilizer
            local data, reader = callProvider(provider, farmlandId)
            snapshot.soilFertilizer = snapshot.soilFertilizer or {available = true, source = detected.soilFertilizer.modName}
            snapshot.soilFertilizer.available = true
            snapshot.soilFertilizer.reader = reader
            if data ~= nil then snapshot.soilFertilizer.data = normalizeData(data) end
        end
        return snapshot
    end

    function Compatibility:getRoadmap7AgronomyCapabilities()
        local detected = self:scan(false)
        return {
            precisionFarmingLoaded = detected.precisionFarming ~= nil and detected.precisionFarming.loaded == true,
            precisionFarmingProvider = detected.precisionFarming ~= nil and detected.precisionFarming.providerAvailable == true,
            soilFertilizerLoaded = detected.soilFertilizer ~= nil and detected.soilFertilizer.loaded == true,
            soilFertilizerProvider = detected.soilFertilizer ~= nil and detected.soilFertilizer.providerAvailable == true,
            fallbackVanilla = true,
            hardDependency = false
        }
    end
end

if AgriLife.CompatibilityModule ~= nil then
    AgriLife.CompatibilityModule.VERSION = "0.7.9.0"
    function AgriLife.CompatibilityModule:getRoadmap7AgronomyCapabilities(...) return self.service:getRoadmap7AgronomyCapabilities(...) end
    local baseDescriptor = AgriLife.CompatibilityModule.getDescriptor
    function AgriLife.CompatibilityModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.7.9.0"
        return descriptor
    end
end
