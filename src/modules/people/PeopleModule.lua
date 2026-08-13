-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.PeopleModule = {}
AgriLife.PeopleModule.__index = AgriLife.PeopleModule
AgriLife.PeopleModule.ID = "people"
AgriLife.PeopleModule.VERSION = "0.7.0.0"
AgriLife.PeopleModule.SCHEMA_VERSION = 1

function AgriLife.PeopleModule.new(core)
    return setmetatable({ core = core, service = AgriLife.People6Service.new(core), updateable = nil, started = false }, AgriLife.PeopleModule)
end
function AgriLife.PeopleModule:create() return AgriLife.Result.ok("PEOPLE_CREATED", "People module created") end
function AgriLife.PeopleModule:load(xmlFile, moduleKey, farmId) return self.service:loadFarm(xmlFile, moduleKey, farmId) end
function AgriLife.PeopleModule:start()
    if self.started then return AgriLife.Result.ok("PEOPLE_ALREADY_STARTED", "People module already started") end
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer then
        self.service:syncConnectedPlayers()
    elseif self.core ~= nil and self.core.context ~= nil and AgriLife.People6SnapshotRequestEvent ~= nil then
        AgriLife.People6SnapshotRequestEvent.send(self.core.context:getFarmId() or 0)
    end
    if g_currentMission ~= nil and g_currentMission.addUpdateable ~= nil then
        self.updateable = { update = function(_, dt) self.service:update(dt) end }
        local ok, result = pcall(g_currentMission.addUpdateable, g_currentMission, self.updateable)
        if not ok or result == false then self.updateable = nil; return AgriLife.Result.fail("PEOPLE_UPDATE_INSTALL_FAILED", tostring(result)) end
    end
    self.started = true
    return AgriLife.Result.ok("PEOPLE_STARTED", "People module started")
end
function AgriLife.PeopleModule:save(xmlFile, moduleKey, farmId)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return AgriLife.Result.ok("PEOPLE_CLIENT_SAVE_SKIPPED", "Client does not save people") end
    if tonumber(farmId) == nil or tonumber(farmId) <= 0 then return AgriLife.Result.ok("PEOPLE_NO_FARM_SAVE", "No farm people state") end
    return self.service:saveFarm(xmlFile, moduleKey, tonumber(farmId))
end
function AgriLife.PeopleModule:stop()
    if g_currentMission ~= nil and self.updateable ~= nil and g_currentMission.removeUpdateable ~= nil then pcall(g_currentMission.removeUpdateable, g_currentMission, self.updateable) end
    self.updateable = nil; self.started = false
    return AgriLife.Result.ok("PEOPLE_STOPPED", "People module stopped")
end
function AgriLife.PeopleModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("PEOPLE_DELETED", "People module deleted") end
function AgriLife.PeopleModule:getLocalProfileId(farmId)
    if self.service == nil then return nil end
    if self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer then
        local state=self.service:getFarmState(farmId,false)
        if state~=nil and state.viewerProfileId~=nil and state.viewerProfileId~="" then return state.viewerProfileId end
    end

    local id, _, player = self.service:getConnectionIdentity(nil, farmId)
    if player ~= nil and id ~= nil and tostring(id) ~= "" then
        return id
    end

    -- During the few frames where the local Player object is unavailable, reuse
    -- an already authoritative owner instead of returning SP_FARM_x and thereby
    -- creating a second persistent identity.
    local ownerId = self.service:getCompanyOwnerProfileId(farmId)
    if ownerId ~= nil and tostring(ownerId) ~= "" then return ownerId end
    local state=self.service:getFarmState(farmId,false)
    if state~=nil then
        for profileId, profile in pairs(state.profiles or {}) do
            if profile.role=="owner" then return profileId end
        end
    end
    return nil
end
function AgriLife.PeopleModule:getSnapshot(farmId)
    if self.service == nil then return nil end
    local profileId = self:getLocalProfileId(farmId)
    return self.service:getSnapshot(farmId, profileId)
end
function AgriLife.PeopleModule:canLocal(farmId, permission)
    if self.service == nil then return false end
    if self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer then
        local profileId=self:getLocalProfileId(farmId)
        return profileId~=nil and self.service:hasPermission(farmId,profileId,permission)
    end
    local ok = self.service:authorizeLocal(farmId, permission)
    return ok == true
end
function AgriLife.PeopleModule:requestSnapshot(farmId)
    if AgriLife.People6SnapshotRequestEvent==nil then return AgriLife.Result.fail("PEOPLE_NETWORK_UNAVAILABLE","People snapshot event unavailable") end
    return AgriLife.People6SnapshotRequestEvent.send(farmId)
end
function AgriLife.PeopleModule:deleteProfile(farmId, profileId)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.People6AdminRequestEvent.send(farmId,"DELETE",profileId,"",string.format("PD-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PeopleModule:setRole(farmId, profileId, role)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.People6AdminRequestEvent.send(farmId,"ROLE",profileId,role,string.format("PR-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PeopleModule:setActive(farmId, profileId, active)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.People6AdminRequestEvent.send(farmId,"ACTIVE",profileId,active==true and "1" or "0",string.format("PA-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PeopleModule.getDescriptor()
    return { id = AgriLife.PeopleModule.ID, version = AgriLife.PeopleModule.VERSION, schemaVersion = AgriLife.PeopleModule.SCHEMA_VERSION, dependencies = { "company" }, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.PeopleModule.new(core) end }
end
function AgriLife.PeopleModule.register(registry)
    if registry == nil then return AgriLife.Result.fail("PEOPLE_REGISTRY_MISSING", "Module registry unavailable") end
    return registry:register(AgriLife.PeopleModule.getDescriptor())
end
