-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 9 finalization, release readiness and future multiplayer scaffold.
AgriLife = AgriLife or {}

if AgriLife.Finalization6Service ~= nil then
    local Finalization = AgriLife.Finalization6Service
    Finalization.ROADMAP9_VERSION = "0.9.0.0"

    local baseNew = Finalization.new
    local baseDefault = Finalization.createDefaultState
    local baseSave = Finalization.saveFarm
    local baseLoad = Finalization.loadFarm
    local baseSnapshot = Finalization.getSnapshot
    local baseDelete = Finalization.delete

    local EXPECTED_PERSISTENT = {
        "economy", "bank", "company", "people", "enterprise", "payroll", "career", "exams",
        "qualifications", "administration", "insurance", "commercialContracts", "market", "workshop",
        "assets", "legal", "journal", "finalization"
    }

    function Finalization.new(core)
        local self = baseNew(core)
        self.networkRoadmap9 = AgriLife.NetworkRoadmap9 ~= nil and AgriLife.NetworkRoadmap9.new(core) or nil
        self.lastReleaseAudit = nil
        return self
    end

    function Finalization:createDefaultState(farmId)
        local state = baseDefault(self, farmId)
        state.lastRoadmap9AuditVersion = ""
        state.lastCompatibilityAuditOk = false
        state.lastPersistenceCoverageOk = false
        state.lastNetworkRevision = 0
        state.lastRecoverySource = ""
        state.recoveryCount = 0
        return state
    end

    function Finalization:getPersistenceCoverage(farmId)
        local registry = self.core ~= nil and self.core.registry or nil
        local rows, missing = {}, {}
        for _, moduleId in ipairs(EXPECTED_PERSISTENT) do
            local descriptor = registry ~= nil and registry.descriptors ~= nil and registry.descriptors[moduleId] or nil
            local instance = registry ~= nil and registry.instances ~= nil and registry.instances[moduleId] or nil
            local row = {
                moduleId = moduleId,
                registered = descriptor ~= nil,
                loaded = instance ~= nil,
                saveCapable = instance ~= nil and type(instance.save) == "function",
                loadCapable = instance ~= nil and type(instance.load) == "function"
            }
            row.ok = row.registered and row.loaded and row.saveCapable and row.loadCapable
            if not row.ok then table.insert(missing, moduleId) end
            table.insert(rows, row)
        end
        return {farmId = tonumber(farmId) or 0, ok = #missing == 0, rows = rows, missing = missing}
    end

    function Finalization:validateMultiFarmIsolation()
        local context = self.core ~= nil and self.core.context or nil
        local registry = self.core ~= nil and self.core.registry or nil
        local farmIds = context ~= nil and context.getFarmIds ~= nil and context:getFarmIds() or {}
        local collisions = {}
        if #farmIds > 1 and registry ~= nil and registry.instances ~= nil then
            for moduleId, instance in pairs(registry.instances) do
                local service = instance ~= nil and instance.service or nil
                if type(service) == "table" and type(service.farms) == "table" then
                    local seen = {}
                    for _, farmId in ipairs(farmIds) do
                        local state = service.farms[farmId]
                        if type(state) == "table" then
                            if seen[state] ~= nil then table.insert(collisions, moduleId .. ":" .. tostring(seen[state]) .. "=" .. tostring(farmId))
                            else seen[state] = farmId end
                        end
                    end
                end
            end
        end
        return {ok = #collisions == 0, farmCount = #farmIds, collisions = collisions, perFarmIsolation = true}
    end

    function Finalization:getRecoveryAudit()
        local persistence = self.core ~= nil and self.core.persistence or nil
        if persistence ~= nil and type(persistence.getRoadmap9RecoverySnapshot) == "function" then return persistence:getRoadmap9RecoverySnapshot() end
        return {backupRecoveryCount = 0, lastRecoverySource = "", lastLoadedPath = "", readOnly = persistence ~= nil and persistence.readOnly == true}
    end

    function Finalization:runRoadmap9Audit(farmId)
        local state = self:getState(farmId, true)
        local compatibility = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.compatibility or nil
        local compatibilityAudit = compatibility ~= nil and type(compatibility.runRoadmap9CompatibilityAudit) == "function" and compatibility:runRoadmap9CompatibilityAudit() or {ok = true, autonomousFallback = true}
        local persistence = self:getPersistenceCoverage(farmId)
        local isolation = self:validateMultiFarmIsolation()
        local runtime = self:auditRuntime()
        local network = self.networkRoadmap9 ~= nil and self.networkRoadmap9:getReadiness() or {authoritativeServer = true, perFarmIsolation = true, publicationEnabled = false, certified = false}
        local recovery = self:getRecoveryAudit()
        local migration = self.core ~= nil and self.core.migrations ~= nil and self.core.migrations.lastRun or nil
        local audit = {
            version = self.ROADMAP9_VERSION,
            farmId = tonumber(farmId) or 0,
            runtime = runtime,
            compatibility = compatibilityAudit,
            persistence = persistence,
            isolation = isolation,
            network = network,
            recovery = recovery,
            migration = migration,
            codeReady = runtime.compatible == true and compatibilityAudit.ok ~= false and persistence.ok and isolation.ok,
            certificationRequired = true,
            multiplayerPublicationEnabled = false
        }
        state.lastRoadmap9AuditVersion = self.ROADMAP9_VERSION
        state.lastCompatibilityAuditOk = compatibilityAudit.ok ~= false
        state.lastPersistenceCoverageOk = persistence.ok == true
        state.lastNetworkRevision = self.networkRoadmap9 ~= nil and self.networkRoadmap9:getFarmRevision(farmId) or 0
        state.lastRecoverySource = tostring(recovery.lastRecoverySource or "")
        state.recoveryCount = tonumber(recovery.backupRecoveryCount) or 0
        self.lastReleaseAudit = audit
        return audit
    end

    function Finalization:getReleaseReadiness(farmId)
        local audit = self:runRoadmap9Audit(farmId)
        return {
            version = audit.version,
            codeReady = audit.codeReady,
            staticGateRequired = true,
            inGameCertificationRequired = true,
            multiplayerCertificationRequired = true,
            publicReleaseAllowed = false,
            preOneVersion = true,
            reasons = audit.codeReady and {"Certification FS25 required before public release"} or {"Runtime or persistence audit is incomplete"}
        }
    end

    function Finalization:markFarmDirty(farmId, moduleId)
        if self.networkRoadmap9 == nil then return false end
        return self.networkRoadmap9:markDirty(farmId, moduleId)
    end

    function Finalization:buildNetworkEnvelope(farmId)
        if self.networkRoadmap9 == nil then return AgriLife.Result.fail("FINALIZATION9_NETWORK_UNAVAILABLE", "Network scaffold unavailable") end
        return self.networkRoadmap9:buildFarmEnvelope(farmId)
    end

    function Finalization:getRoadmap9NetworkReadiness()
        return self.networkRoadmap9 ~= nil and self.networkRoadmap9:getReadiness() or {publicationEnabled = false, certified = false}
    end

    function Finalization:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSave(self, xmlFile, moduleKey, farmId)
        if not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getState(farmId, true)
        xmlFile:setString(moduleKey .. ".roadmap9#lastAuditVersion", state.lastRoadmap9AuditVersion or "")
        xmlFile:setBool(moduleKey .. ".roadmap9#compatibilityOk", state.lastCompatibilityAuditOk == true)
        xmlFile:setBool(moduleKey .. ".roadmap9#persistenceCoverageOk", state.lastPersistenceCoverageOk == true)
        xmlFile:setInt(moduleKey .. ".roadmap9#networkRevision", tonumber(state.lastNetworkRevision) or 0)
        xmlFile:setString(moduleKey .. ".roadmap9#lastRecoverySource", state.lastRecoverySource or "")
        xmlFile:setInt(moduleKey .. ".roadmap9#recoveryCount", tonumber(state.recoveryCount) or 0)
        return result
    end

    function Finalization:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoad(self, xmlFile, moduleKey, farmId)
        local state = self:getState(farmId, true)
        if xmlFile ~= nil and moduleKey ~= nil then
            state.lastRoadmap9AuditVersion = xmlFile:getString(moduleKey .. ".roadmap9#lastAuditVersion", "")
            state.lastCompatibilityAuditOk = xmlFile:getBool(moduleKey .. ".roadmap9#compatibilityOk", false)
            state.lastPersistenceCoverageOk = xmlFile:getBool(moduleKey .. ".roadmap9#persistenceCoverageOk", false)
            state.lastNetworkRevision = xmlFile:getInt(moduleKey .. ".roadmap9#networkRevision", 0)
            state.lastRecoverySource = xmlFile:getString(moduleKey .. ".roadmap9#lastRecoverySource", "")
            state.recoveryCount = xmlFile:getInt(moduleKey .. ".roadmap9#recoveryCount", 0)
        end
        return result
    end

    function Finalization:getSnapshot(farmId)
        local snapshot = baseSnapshot(self, farmId)
        snapshot.roadmap9 = self:runRoadmap9Audit(farmId)
        snapshot.releaseReadiness = self:getReleaseReadiness(farmId)
        return snapshot
    end

    function Finalization:delete()
        if self.networkRoadmap9 ~= nil then self.networkRoadmap9:delete() end
        self.networkRoadmap9 = nil
        self.lastReleaseAudit = nil
        baseDelete(self)
    end
end

if AgriLife.FinalizationModule ~= nil then
    AgriLife.FinalizationModule.VERSION = "0.9.0.0"
    AgriLife.FinalizationModule.SCHEMA_VERSION = 2
    function AgriLife.FinalizationModule:runRoadmap9Audit(...) return self.service:runRoadmap9Audit(...) end
    function AgriLife.FinalizationModule:getReleaseReadiness(...) return self.service:getReleaseReadiness(...) end
    function AgriLife.FinalizationModule:buildNetworkEnvelope(...) return self.service:buildNetworkEnvelope(...) end
    function AgriLife.FinalizationModule:getRoadmap9NetworkReadiness(...) return self.service:getRoadmap9NetworkReadiness(...) end
    local baseDescriptor = AgriLife.FinalizationModule.getDescriptor
    function AgriLife.FinalizationModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.9.0.0"
        descriptor.schemaVersion = 2
        return descriptor
    end
end
