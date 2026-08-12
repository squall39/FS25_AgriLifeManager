-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 9 future multiplayer authority and per-farm replication scaffold.
AgriLife = AgriLife or {}

AgriLife.NetworkRoadmap9 = {}
AgriLife.NetworkRoadmap9.__index = AgriLife.NetworkRoadmap9
AgriLife.NetworkRoadmap9.VERSION = "0.9.0.0"
AgriLife.NetworkRoadmap9.PUBLICATION_ENABLED = false

local MODULE_IDS = {
    "economy", "bank", "company", "people", "enterprise", "payroll",
    "career", "exams", "qualifications", "administration", "insurance",
    "commercialContracts", "market", "workshop", "assets", "legal", "journal"
}

local function copySerializable(value, depth, seen)
    depth = tonumber(depth) or 0
    if depth > 7 then return nil end
    local kind = type(value)
    if kind == "nil" or kind == "boolean" or kind == "number" or kind == "string" then return value end
    if kind ~= "table" then return nil end
    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true
    local result = {}
    for key, item in pairs(value) do
        local keyType = type(key)
        if keyType == "string" or keyType == "number" then
            local copied = copySerializable(item, depth + 1, seen)
            if copied ~= nil then result[key] = copied end
        end
    end
    seen[value] = nil
    return result
end

local function positiveFarmId(value)
    value = tonumber(value) or 0
    if value <= 0 or value % 1 ~= 0 then return nil end
    return value
end

function AgriLife.NetworkRoadmap9.new(core)
    return setmetatable({
        core = core,
        farmRevisions = {},
        moduleRevisions = {},
        clientMirrors = {},
        lastEnvelopeByFarm = {},
        publicationEnabled = false
    }, AgriLife.NetworkRoadmap9)
end

function AgriLife.NetworkRoadmap9:isServer()
    return self.core ~= nil and self.core.context ~= nil and self.core.context.isServer == true
end

function AgriLife.NetworkRoadmap9:isMultiplayerSession()
    return self.core ~= nil and self.core.context ~= nil and self.core.context.isMultiplayer == true
end

function AgriLife.NetworkRoadmap9:isPublicationEnabled()
    return self.publicationEnabled == true and self.PUBLICATION_ENABLED == true
end

function AgriLife.NetworkRoadmap9:setPublicationEnabled(enabled)
    self.publicationEnabled = enabled == true and self.PUBLICATION_ENABLED == true
    return self.publicationEnabled
end

function AgriLife.NetworkRoadmap9:markDirty(farmId, moduleId)
    farmId = positiveFarmId(farmId)
    if farmId == nil then return false end
    moduleId = tostring(moduleId or "core")
    self.farmRevisions[farmId] = (tonumber(self.farmRevisions[farmId]) or 0) + 1
    self.moduleRevisions[farmId] = self.moduleRevisions[farmId] or {}
    self.moduleRevisions[farmId][moduleId] = (tonumber(self.moduleRevisions[farmId][moduleId]) or 0) + 1
    return true
end

function AgriLife.NetworkRoadmap9:getFarmRevision(farmId)
    return tonumber(self.farmRevisions[positiveFarmId(farmId) or 0]) or 0
end

function AgriLife.NetworkRoadmap9:getModuleSnapshot(moduleId, farmId)
    local registry = self.core ~= nil and self.core.registry or nil
    local instance = registry ~= nil and registry.instances ~= nil and registry.instances[moduleId] or nil
    if instance == nil or type(instance.getSnapshot) ~= "function" then return nil end
    local ok, snapshot = pcall(instance.getSnapshot, instance, farmId)
    if not ok then return nil end
    return copySerializable(snapshot, 0, {})
end

function AgriLife.NetworkRoadmap9:buildFarmEnvelope(farmId)
    farmId = positiveFarmId(farmId)
    if farmId == nil then return AgriLife.Result.fail("NETWORK9_FARM_INVALID", "Farm id is invalid") end
    if not self:isServer() then return AgriLife.Result.fail("NETWORK9_SERVER_REQUIRED", "Only the server may build authoritative farm envelopes") end

    local modules = {}
    for _, moduleId in ipairs(MODULE_IDS) do
        local snapshot = self:getModuleSnapshot(moduleId, farmId)
        if snapshot ~= nil then modules[moduleId] = snapshot end
    end
    local revision = self:getFarmRevision(farmId)
    local envelope = {
        protocol = 1,
        version = self.VERSION,
        farmId = farmId,
        revision = revision,
        serverAuthoritative = true,
        modules = modules
    }
    self.lastEnvelopeByFarm[farmId] = envelope
    return AgriLife.Result.ok("NETWORK9_ENVELOPE_READY", "Authoritative per-farm envelope built", envelope)
end

function AgriLife.NetworkRoadmap9:applyFarmEnvelope(envelope, localFarmId)
    if self:isServer() then return AgriLife.Result.fail("NETWORK9_CLIENT_ONLY", "Authoritative server does not consume client mirrors") end
    if type(envelope) ~= "table" then return AgriLife.Result.fail("NETWORK9_ENVELOPE_INVALID", "Envelope is invalid") end
    local farmId = positiveFarmId(envelope.farmId)
    local expectedFarmId = positiveFarmId(localFarmId)
    if farmId == nil or expectedFarmId == nil or farmId ~= expectedFarmId then
        return AgriLife.Result.fail("NETWORK9_FARM_ISOLATION", "A client may only receive its own farm envelope")
    end
    local current = self.clientMirrors[farmId]
    if current ~= nil and (tonumber(envelope.revision) or 0) < (tonumber(current.revision) or 0) then
        return AgriLife.Result.fail("NETWORK9_STALE_ENVELOPE", "Stale farm envelope rejected")
    end
    self.clientMirrors[farmId] = copySerializable(envelope, 0, {})
    return AgriLife.Result.ok("NETWORK9_MIRROR_UPDATED", "Client farm mirror updated", {farmId = farmId, revision = tonumber(envelope.revision) or 0})
end

function AgriLife.NetworkRoadmap9:getClientMirror(farmId)
    return self.clientMirrors[positiveFarmId(farmId) or 0]
end

function AgriLife.NetworkRoadmap9:getReadiness()
    return {
        protocol = 1,
        version = self.VERSION,
        authoritativeServer = true,
        perFarmIsolation = true,
        clientMirrorOnly = true,
        publicationEnabled = self:isPublicationEnabled(),
        runtimeMultiplayer = self:isMultiplayerSession(),
        certified = false
    }
end

function AgriLife.NetworkRoadmap9:delete()
    self.farmRevisions = {}
    self.moduleRevisions = {}
    self.clientMirrors = {}
    self.lastEnvelopeByFarm = {}
    self.core = nil
end
