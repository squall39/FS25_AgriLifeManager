-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

local function getCareerModule()
    if g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil then return g_agriLifeCore.registry.instances.career end
    return nil
end

local function validateFarmMembership(connection, farmId)
    if connection == nil then return true end
    if connection.getIsServer ~= nil and connection:getIsServer() then return true end
    if g_currentMission == nil then return false end
    if g_currentMission.getPlayerByConnection ~= nil then
        local ok, player = pcall(g_currentMission.getPlayerByConnection, g_currentMission, connection)
        if ok and player ~= nil and tonumber(player.farmId) == tonumber(farmId) then return true end
    end
    if g_currentMission.userManager ~= nil and g_currentMission.userManager.getUserByConnection ~= nil then
        local ok, user = pcall(g_currentMission.userManager.getUserByConnection, g_currentMission.userManager, connection)
        if ok and user ~= nil and user.getFarmId ~= nil then
            local okFarm, userFarmId = pcall(user.getFarmId, user)
            if okFarm and tonumber(userFarmId) == tonumber(farmId) then return true end
        end
    end
    return false
end

local function writeSnapshot(streamId, snapshot)
    streamWriteString(streamId, tostring(snapshot.profileId or ""))
    streamWriteInt32(streamId, tonumber(snapshot.totalXP) or 0)
    streamWriteUInt8(streamId, math.max(0, math.min(100, tonumber(snapshot.reputation) or 50)))
    streamWriteString(streamId, tostring(snapshot.activeSpecialtyId or ""))
    streamWriteInt32(streamId, math.max(0, tonumber(snapshot.activityRemainingMs) or 0))
    local byId = {}
    for _, specialty in ipairs(snapshot.specialties or {}) do byId[specialty.id] = specialty end
    for _, definition in ipairs(AgriLife.Career6Service.SPECIALTIES or {}) do streamWriteInt32(streamId, tonumber(byId[definition.id] ~= nil and byId[definition.id].xp or 0) or 0) end
    local stats = snapshot.stats or {}
    streamWriteFloat32(streamId, tonumber(stats.workHours) or 0)
    streamWriteFloat32(streamId, tonumber(stats.distanceKm) or 0)
    streamWriteFloat32(streamId, tonumber(stats.areaHa) or 0)
    streamWriteFloat32(streamId, tonumber(stats.harvestedHa) or 0)
    streamWriteFloat32(streamId, tonumber(stats.transportedTonnesKm) or 0)
    streamWriteFloat32(streamId, tonumber(stats.transportedTonnes) or 0)
    streamWriteInt32(streamId, tonumber(stats.diagnostics) or 0)
    streamWriteInt32(streamId, tonumber(stats.repairs) or 0)
    streamWriteInt32(streamId, tonumber(stats.examsPassed) or 0)
    streamWriteInt32(streamId, tonumber(stats.examsFailed) or 0)
end

local function readSnapshot(streamId)
    local snapshot = { profileId = streamReadString(streamId), specialties = {}, stats = {} }
    snapshot.totalXP = streamReadInt32(streamId)
    snapshot.reputation = streamReadUInt8(streamId)
    snapshot.activeSpecialtyId = streamReadString(streamId)
    snapshot.activityRemainingMs = streamReadInt32(streamId)
    for index, definition in ipairs(AgriLife.Career6Service.SPECIALTIES or {}) do snapshot.specialties[index] = { id = definition.id, xp = streamReadInt32(streamId) } end
    snapshot.stats.workHours = streamReadFloat32(streamId)
    snapshot.stats.distanceKm = streamReadFloat32(streamId)
    snapshot.stats.areaHa = streamReadFloat32(streamId)
    snapshot.stats.harvestedHa = streamReadFloat32(streamId)
    snapshot.stats.transportedTonnesKm = streamReadFloat32(streamId)
    snapshot.stats.transportedTonnes = streamReadFloat32(streamId)
    snapshot.stats.diagnostics = streamReadInt32(streamId)
    snapshot.stats.repairs = streamReadInt32(streamId)
    snapshot.stats.examsPassed = streamReadInt32(streamId)
    snapshot.stats.examsFailed = streamReadInt32(streamId)
    return snapshot
end

AgriLife.Career6SnapshotEvent = {}
local Career6SnapshotEvent_mt = Class(AgriLife.Career6SnapshotEvent, Event)
InitEventClass(AgriLife.Career6SnapshotEvent, "AgriLifeCareer6SnapshotEvent")
function AgriLife.Career6SnapshotEvent.emptyNew() return Event.new(Career6SnapshotEvent_mt) end
function AgriLife.Career6SnapshotEvent.new(farmId, viewerProfileId, snapshots)
    local self = AgriLife.Career6SnapshotEvent.emptyNew(); self.farmId = tonumber(farmId) or 0; self.viewerProfileId = tostring(viewerProfileId or ""); self.snapshots = snapshots or {}; return self
end
function AgriLife.Career6SnapshotEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId); streamWriteString(streamId, self.viewerProfileId)
    local count = math.min(64, #self.snapshots); streamWriteUInt8(streamId, count)
    for index = 1, count do writeSnapshot(streamId, self.snapshots[index]) end
end
function AgriLife.Career6SnapshotEvent:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId); self.viewerProfileId = streamReadString(streamId); self.snapshots = {}
    local count = streamReadUInt8(streamId); for index = 1, count do self.snapshots[index] = readSnapshot(streamId) end; self:run(connection)
end
function AgriLife.Career6SnapshotEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and not connection:getIsServer() then return end
    local module = getCareerModule()
    if module ~= nil and module.service ~= nil then
        module.service:applyClientTeamSnapshot(self.farmId, self.viewerProfileId, self.snapshots)
        if module.core ~= nil and module.core.ui ~= nil and module.core.ui.frame ~= nil then module.core.ui.frame:refresh() end
    end
end

AgriLife.Career6SnapshotRequestEvent = {}
local Career6SnapshotRequestEvent_mt = Class(AgriLife.Career6SnapshotRequestEvent, Event)
InitEventClass(AgriLife.Career6SnapshotRequestEvent, "AgriLifeCareer6SnapshotRequestEvent")
function AgriLife.Career6SnapshotRequestEvent.emptyNew() return Event.new(Career6SnapshotRequestEvent_mt) end
function AgriLife.Career6SnapshotRequestEvent.new(farmId) local self = AgriLife.Career6SnapshotRequestEvent.emptyNew(); self.farmId = tonumber(farmId) or 0; return self end
function AgriLife.Career6SnapshotRequestEvent.send(farmId)
    if g_server ~= nil then return AgriLife.Result.ok("CAREER_SNAPSHOT_LOCAL", "Server already owns career state") end
    if g_client ~= nil and g_client.getServerConnection ~= nil then g_client:getServerConnection():sendEvent(AgriLife.Career6SnapshotRequestEvent.new(farmId)); return AgriLife.Result.ok("CAREER_SNAPSHOT_REQUESTED", "Career snapshot requested") end
    return AgriLife.Result.fail("CAREER_NETWORK_UNAVAILABLE", "No server connection")
end
function AgriLife.Career6SnapshotRequestEvent:writeStream(streamId, connection) streamWriteInt32(streamId, self.farmId) end
function AgriLife.Career6SnapshotRequestEvent:readStream(streamId, connection) self.farmId = streamReadInt32(streamId); self:run(connection) end
function AgriLife.Career6SnapshotRequestEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return end
    if connection == nil or not validateFarmMembership(connection, self.farmId) then return end
    local module = getCareerModule(); if module == nil or module.service == nil then return end
    local people = module.service:getPeopleService(); local viewerProfileId = nil
    if people ~= nil and people.getConnectionIdentity ~= nil then viewerProfileId = select(1, people:getConnectionIdentity(connection, self.farmId)) end
    connection:sendEvent(AgriLife.Career6SnapshotEvent.new(self.farmId, viewerProfileId, module.service:getTeamSnapshots(self.farmId)))
end
