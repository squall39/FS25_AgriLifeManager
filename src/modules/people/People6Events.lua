-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

local function getPeopleModule()
    if g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil then
        return g_agriLifeCore.registry.instances.people
    end
    return nil
end

local function validateFarmMembership(connection, farmId)
    if connection == nil then return true end
    if connection.getIsServer ~= nil and connection:getIsServer() then return true end
    if g_currentMission == nil then return false end
    if g_currentMission.getPlayerByConnection ~= nil then
        local player = g_currentMission:getPlayerByConnection(connection)
        if player ~= nil and tonumber(player.farmId) == tonumber(farmId) then return true end
    end
    if g_currentMission.userManager ~= nil and g_currentMission.userManager.getUserByConnection ~= nil then
        local user = g_currentMission.userManager:getUserByConnection(connection)
        if user ~= nil and user.getFarmId ~= nil and tonumber(user:getFarmId()) == tonumber(farmId) then return true end
    end
    return false
end

AgriLife.People6SnapshotEvent = {}
local People6SnapshotEvent_mt = Class(AgriLife.People6SnapshotEvent, Event)
InitEventClass(AgriLife.People6SnapshotEvent, "AgriLifePeople6SnapshotEvent")

function AgriLife.People6SnapshotEvent.emptyNew() return Event.new(People6SnapshotEvent_mt) end
function AgriLife.People6SnapshotEvent.new(farmId, viewerProfileId, profiles)
    local self = AgriLife.People6SnapshotEvent.emptyNew()
    self.farmId = tonumber(farmId) or 0
    self.viewerProfileId = tostring(viewerProfileId or "")
    self.profiles = profiles or {}
    return self
end
function AgriLife.People6SnapshotEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
    streamWriteString(streamId, self.viewerProfileId)
    local count = math.min(64, #self.profiles)
    streamWriteUInt8(streamId, count)
    for i = 1, count do
        local p = self.profiles[i]
        streamWriteString(streamId, tostring(p.profileId or ""))
        streamWriteString(streamId, tostring(p.displayName or "Joueur"))
        streamWriteString(streamId, tostring(p.role or "employee"))
        streamWriteBool(streamId, p.active == true)
        streamWriteBool(streamId, p.connected == true)
        streamWriteInt32(streamId, tonumber(p.joinedPeriodKey) or 0)
        streamWriteInt32(streamId, tonumber(p.lastSeenPeriodKey) or 0)
        streamWriteInt32(streamId, tonumber(p.lastSeenDay) or 0)
        streamWriteInt32(streamId, tonumber(p.lastSeenTime) or 0)
    end
end
function AgriLife.People6SnapshotEvent:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self.viewerProfileId = streamReadString(streamId)
    self.profiles = {}
    local count = streamReadUInt8(streamId)
    for i = 1, count do
        self.profiles[i] = {
            profileId = streamReadString(streamId),
            displayName = streamReadString(streamId),
            role = streamReadString(streamId),
            active = streamReadBool(streamId),
            connected = streamReadBool(streamId),
            joinedPeriodKey = streamReadInt32(streamId),
            lastSeenPeriodKey = streamReadInt32(streamId),
            lastSeenDay = streamReadInt32(streamId),
            lastSeenTime = streamReadInt32(streamId)
        }
    end
    self:run(connection)
end
function AgriLife.People6SnapshotEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and not connection:getIsServer() then return end
    local module = getPeopleModule()
    if module ~= nil and module.service ~= nil and module.service.applyClientSnapshot ~= nil then
        module.service:applyClientSnapshot(self.farmId, self.viewerProfileId, self.profiles)
        if module.core ~= nil and module.core.ui ~= nil and module.core.ui.frame ~= nil then module.core.ui.frame:refresh() end
    end
end

AgriLife.People6SnapshotRequestEvent = {}
local People6SnapshotRequestEvent_mt = Class(AgriLife.People6SnapshotRequestEvent, Event)
InitEventClass(AgriLife.People6SnapshotRequestEvent, "AgriLifePeople6SnapshotRequestEvent")
function AgriLife.People6SnapshotRequestEvent.emptyNew() return Event.new(People6SnapshotRequestEvent_mt) end
function AgriLife.People6SnapshotRequestEvent.new(farmId) local self=AgriLife.People6SnapshotRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; return self end
function AgriLife.People6SnapshotRequestEvent.send(farmId)
    if g_server ~= nil then return AgriLife.Result.ok("PEOPLE_SNAPSHOT_LOCAL", "Server already owns people state") end
    if g_client ~= nil and g_client.getServerConnection ~= nil then g_client:getServerConnection():sendEvent(AgriLife.People6SnapshotRequestEvent.new(farmId)); return AgriLife.Result.ok("PEOPLE_SNAPSHOT_REQUESTED", "People snapshot requested") end
    return AgriLife.Result.fail("PEOPLE_NETWORK_UNAVAILABLE", "No server connection")
end
function AgriLife.People6SnapshotRequestEvent:writeStream(streamId, connection) streamWriteInt32(streamId, self.farmId) end
function AgriLife.People6SnapshotRequestEvent:readStream(streamId, connection) self.farmId=streamReadInt32(streamId); self:run(connection) end
function AgriLife.People6SnapshotRequestEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return end
    local module=getPeopleModule(); if module==nil or module.service==nil or connection==nil then return end
    if not validateFarmMembership(connection,self.farmId) then return end
    module.service:syncConnectedPlayers()
    local profileId=select(1,module.service:getConnectionIdentity(connection,self.farmId))
    local snapshot=module.service:getSnapshot(self.farmId,profileId)
    if snapshot~=nil then connection:sendEvent(AgriLife.People6SnapshotEvent.new(self.farmId,profileId,snapshot.profiles)) end
end

AgriLife.People6AdminResultEvent = {}
local People6AdminResultEvent_mt = Class(AgriLife.People6AdminResultEvent, Event)
InitEventClass(AgriLife.People6AdminResultEvent, "AgriLifePeople6AdminResultEvent")
function AgriLife.People6AdminResultEvent.emptyNew() return Event.new(People6AdminResultEvent_mt) end
function AgriLife.People6AdminResultEvent.new(requestId, success, code) local self=AgriLife.People6AdminResultEvent.emptyNew(); self.requestId=tostring(requestId or ""); self.success=success==true; self.code=tostring(code or "PEOPLE_UNKNOWN"); return self end
function AgriLife.People6AdminResultEvent:writeStream(streamId, connection) streamWriteString(streamId,self.requestId); streamWriteBool(streamId,self.success); streamWriteString(streamId,self.code) end
function AgriLife.People6AdminResultEvent:readStream(streamId, connection) self.requestId=streamReadString(streamId); self.success=streamReadBool(streamId); self.code=streamReadString(streamId); self:run(connection) end
function AgriLife.People6AdminResultEvent:run(connection)
    if connection~=nil and connection.getIsServer~=nil and not connection:getIsServer() then return end
    local module=getPeopleModule()
    if module~=nil then
        module.lastAdminResult={requestId=self.requestId,success=self.success,code=self.code}
        if module.core~=nil and module.core.ui~=nil and module.core.ui.frame~=nil and module.core.ui.frame.onPeopleAdminResult~=nil then module.core.ui.frame:onPeopleAdminResult(module.lastAdminResult) end
    end
end

AgriLife.People6AdminRequestEvent = {}
local People6AdminRequestEvent_mt = Class(AgriLife.People6AdminRequestEvent, Event)
InitEventClass(AgriLife.People6AdminRequestEvent, "AgriLifePeople6AdminRequestEvent")
function AgriLife.People6AdminRequestEvent.emptyNew() return Event.new(People6AdminRequestEvent_mt) end
function AgriLife.People6AdminRequestEvent.new(farmId,action,targetProfileId,value,requestId)
    local self=AgriLife.People6AdminRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; self.action=tostring(action or ""); self.targetProfileId=tostring(targetProfileId or ""); self.value=tostring(value or ""); self.requestId=tostring(requestId or ""); return self
end
function AgriLife.People6AdminRequestEvent.send(farmId,action,targetProfileId,value,requestId)
    local module=getPeopleModule(); if module==nil or module.service==nil then return AgriLife.Result.fail("PEOPLE_MODULE_UNAVAILABLE","People module unavailable") end
    if g_server~=nil then
        local permission=action=="ROLE" and "roles.manage" or "profiles.manage"
        local ok,code,actor=module.service:authorizeLocal(farmId,permission)
        if not ok then return AgriLife.Result.fail(code or "PEOPLE_PERMISSION_DENIED","Insufficient permissions") end
        if action=="DELETE" then return module.service:deleteProfile(farmId,actor,targetProfileId) end
        if action=="ROLE" then return module.service:setRole(farmId,actor,targetProfileId,value) end
        if action=="ACTIVE" then return module.service:setActive(farmId,actor,targetProfileId,value=="1") end
        return AgriLife.Result.fail("PEOPLE_ACTION_INVALID","Unknown admin action")
    end
    if g_client~=nil and g_client.getServerConnection~=nil then g_client:getServerConnection():sendEvent(AgriLife.People6AdminRequestEvent.new(farmId,action,targetProfileId,value,requestId)); return AgriLife.Result.ok("PEOPLE_ADMIN_REQUEST_SENT","People admin request sent") end
    return AgriLife.Result.fail("PEOPLE_NETWORK_UNAVAILABLE","No server connection")
end
function AgriLife.People6AdminRequestEvent:writeStream(streamId, connection) streamWriteInt32(streamId,self.farmId); streamWriteString(streamId,self.action); streamWriteString(streamId,self.targetProfileId); streamWriteString(streamId,self.value); streamWriteString(streamId,self.requestId) end
function AgriLife.People6AdminRequestEvent:readStream(streamId, connection) self.farmId=streamReadInt32(streamId); self.action=streamReadString(streamId); self.targetProfileId=streamReadString(streamId); self.value=streamReadString(streamId); self.requestId=streamReadString(streamId); self:run(connection) end
function AgriLife.People6AdminRequestEvent:run(connection)
    if connection~=nil and connection.getIsServer~=nil and connection:getIsServer() then return end
    local module=getPeopleModule(); if module==nil or module.service==nil then return end
    local permission=self.action=="ROLE" and "roles.manage" or "profiles.manage"
    local ok,code,actor=module.service:authorizeConnection(connection,self.farmId,permission)
    local result
    if not ok then result=AgriLife.Result.fail(code or "PEOPLE_PERMISSION_DENIED","Insufficient permissions")
    elseif self.action=="DELETE" then result=module.service:deleteProfile(self.farmId,actor,self.targetProfileId)
    elseif self.action=="ROLE" then result=module.service:setRole(self.farmId,actor,self.targetProfileId,self.value)
    elseif self.action=="ACTIVE" then result=module.service:setActive(self.farmId,actor,self.targetProfileId,self.value=="1")
    else result=AgriLife.Result.fail("PEOPLE_ACTION_INVALID","Unknown admin action") end
    if connection~=nil then
        connection:sendEvent(AgriLife.People6AdminResultEvent.new(self.requestId,result.ok,result.code))
        local snapshot=module.service:getSnapshot(self.farmId,actor)
        if snapshot~=nil then connection:sendEvent(AgriLife.People6SnapshotEvent.new(self.farmId,actor,snapshot.profiles)) end
    end
end
