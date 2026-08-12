-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 9 optional compatibility and universal-content audit.
AgriLife = AgriLife or {}

if AgriLife.Compatibility6Service ~= nil then
    local Compatibility = AgriLife.Compatibility6Service
    Compatibility.ROADMAP9_VERSION = "0.9.0.0"

    local function safeCount(value)
        if type(value) ~= "table" then return 0 end
        local count = 0
        for _ in pairs(value) do count = count + 1 end
        return count
    end

    local function statusRow(id, row, fallback)
        row = type(row) == "table" and row or {}
        return {
            id = id,
            loaded = row.loaded == true,
            providerAvailable = row.providerAvailable == true,
            modName = tostring(row.modName or ""),
            hardDependency = false,
            fallback = fallback ~= false
        }
    end

    function Compatibility:getRoadmap9IntegrationMatrix()
        local detected = self:scan(true) or {}
        return {
            courseplay = statusRow("courseplay", detected.courseplay, true),
            autoDrive = statusRow("autoDrive", detected.autoDrive, true),
            precisionFarming = statusRow("precisionFarming", detected.precisionFarming, true),
            soilFertilizer = statusRow("soilFertilizer", detected.soilFertilizer, true),
            mudSystem = statusRow("mudSystem", detected.mudSystem, true),
            advancedDamageSystem = statusRow("advancedDamageSystem", detected.advancedDamageSystem, true),
            hardDependencies = 0,
            autonomousFallback = true
        }
    end

    function Compatibility:auditRuntimeContent()
        local registry = self.core ~= nil and self.core.registry or nil
        local market = registry ~= nil and registry.instances ~= nil and registry.instances.market or nil
        local service = market ~= nil and (market.service or market) or nil
        local content = nil
        if service ~= nil and type(service.discoverRuntimeContent) == "function" then
            local ok, value = pcall(service.discoverRuntimeContent, service, true)
            if ok then content = value end
        end
        content = type(content) == "table" and content or {}
        local missionInfo = g_currentMission ~= nil and g_currentMission.missionInfo or nil
        local mapId = missionInfo ~= nil and (missionInfo.mapId or missionInfo.mapXMLFilename or missionInfo.mapTitle) or ""
        local fillTypes = safeCount(content.fillTypes)
        local storeItems = safeCount(content.storeItems)
        local farmlands = safeCount(content.farmlands)
        local productions = safeCount(content.productions)
        return {
            mapId = tostring(mapId or ""),
            dynamicDiscovery = service ~= nil and type(service.discoverRuntimeContent) == "function",
            fillTypes = fillTypes,
            storeItems = storeItems,
            farmlands = farmlands,
            productions = productions,
            multifruitReady = fillTypes > 0 or g_fillTypeManager == nil,
            mapAgnostic = true,
            fixedMapList = false,
            fixedFruitList = false
        }
    end

    function Compatibility:runRoadmap9CompatibilityAudit()
        local matrix = self:getRoadmap9IntegrationMatrix()
        local content = self:auditRuntimeContent()
        local degraded = {}
        for id, row in pairs(matrix) do
            if type(row) == "table" and row.loaded and not row.providerAvailable then table.insert(degraded, id) end
        end
        table.sort(degraded)
        return {
            version = self.ROADMAP9_VERSION,
            integrations = matrix,
            runtimeContent = content,
            degradedProviders = degraded,
            autonomousFallback = true,
            hardDependencyFailure = false,
            ok = true
        }
    end
end

if AgriLife.CompatibilityModule ~= nil then
    AgriLife.CompatibilityModule.VERSION = "0.9.0.0"
    function AgriLife.CompatibilityModule:getRoadmap9IntegrationMatrix(...) return self.service:getRoadmap9IntegrationMatrix(...) end
    function AgriLife.CompatibilityModule:auditRuntimeContent(...) return self.service:auditRuntimeContent(...) end
    function AgriLife.CompatibilityModule:runRoadmap9CompatibilityAudit(...) return self.service:runRoadmap9CompatibilityAudit(...) end
    local baseDescriptor = AgriLife.CompatibilityModule.getDescriptor
    function AgriLife.CompatibilityModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.9.0.0"
        return descriptor
    end
end
