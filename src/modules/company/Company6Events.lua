-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

local function getCompanyModule()
    if g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil then
        return g_agriLifeCore.registry.instances.company
    end
    return nil
end

local function getPeopleModule()
    if g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil then
        return g_agriLifeCore.registry.instances.people
    end
    return nil
end

local function authorize(connection, farmId, permission)
    local people = getPeopleModule()
    if people == nil or people.service == nil then return false, "COMPANY_PEOPLE_UNAVAILABLE", nil end
    if connection == nil then return people.service:authorizeLocal(farmId, permission) end
    return people.service:authorizeConnection(connection, farmId, permission)
end

AgriLife.Company6SnapshotEvent = {}
local Company6SnapshotEvent_mt = Class(AgriLife.Company6SnapshotEvent, Event)
InitEventClass(AgriLife.Company6SnapshotEvent, "AgriLifeCompany6SnapshotEvent")

function AgriLife.Company6SnapshotEvent.emptyNew() return Event.new(Company6SnapshotEvent_mt) end
function AgriLife.Company6SnapshotEvent.new(snapshot)
    local self = AgriLife.Company6SnapshotEvent.emptyNew()
    snapshot = snapshot or {}
    self.farmId = tonumber(snapshot.farmId) or 0
    self.companyName = tostring(snapshot.companyName or "")
    self.legalFormId = tostring(snapshot.legalFormId or "EI")
    self.ownerProfileId = tostring(snapshot.ownerProfileId or "")
    return self
end
function AgriLife.Company6SnapshotEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
    streamWriteString(streamId, self.companyName)
    streamWriteString(streamId, self.legalFormId)
    streamWriteString(streamId, self.ownerProfileId)
end
function AgriLife.Company6SnapshotEvent:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self.companyName = streamReadString(streamId)
    self.legalFormId = streamReadString(streamId)
    self.ownerProfileId = streamReadString(streamId)
    self:run(connection)
end
function AgriLife.Company6SnapshotEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and not connection:getIsServer() then return end
    local module = getCompanyModule()
    if module ~= nil and module.applyClientSnapshot ~= nil then
        module:applyClientSnapshot({farmId=self.farmId, companyName=self.companyName, legalFormId=self.legalFormId, ownerProfileId=self.ownerProfileId})
    end
end

AgriLife.Company6SnapshotRequestEvent = {}
local Company6SnapshotRequestEvent_mt = Class(AgriLife.Company6SnapshotRequestEvent, Event)
InitEventClass(AgriLife.Company6SnapshotRequestEvent, "AgriLifeCompany6SnapshotRequestEvent")
function AgriLife.Company6SnapshotRequestEvent.emptyNew() return Event.new(Company6SnapshotRequestEvent_mt) end
function AgriLife.Company6SnapshotRequestEvent.new(farmId) local self=AgriLife.Company6SnapshotRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; return self end
function AgriLife.Company6SnapshotRequestEvent.send(farmId)
    if g_server ~= nil then return AgriLife.Result.ok("COMPANY_SNAPSHOT_LOCAL", "Server owns company state") end
    if g_client ~= nil and g_client.getServerConnection ~= nil then
        g_client:getServerConnection():sendEvent(AgriLife.Company6SnapshotRequestEvent.new(farmId))
        return AgriLife.Result.ok("COMPANY_SNAPSHOT_REQUESTED", "Company snapshot requested")
    end
    return AgriLife.Result.fail("COMPANY_NETWORK_UNAVAILABLE", "No server connection")
end
function AgriLife.Company6SnapshotRequestEvent:writeStream(streamId, connection) streamWriteInt32(streamId,self.farmId) end
function AgriLife.Company6SnapshotRequestEvent:readStream(streamId, connection) self.farmId=streamReadInt32(streamId); self:run(connection) end
function AgriLife.Company6SnapshotRequestEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return end
    if connection == nil then return end
    local ok = select(1, authorize(connection, self.farmId, "profile.viewSelf"))
    if not ok then return end
    local module = getCompanyModule()
    local snapshot = module ~= nil and module.service ~= nil and module.service:getSnapshot(self.farmId) or nil
    if snapshot ~= nil then connection:sendEvent(AgriLife.Company6SnapshotEvent.new(snapshot)) end
end

AgriLife.Company6IdentityResultEvent = {}
local Company6IdentityResultEvent_mt = Class(AgriLife.Company6IdentityResultEvent, Event)
InitEventClass(AgriLife.Company6IdentityResultEvent, "AgriLifeCompany6IdentityResultEvent")
function AgriLife.Company6IdentityResultEvent.emptyNew() return Event.new(Company6IdentityResultEvent_mt) end
function AgriLife.Company6IdentityResultEvent.new(requestId, result)
    local self=AgriLife.Company6IdentityResultEvent.emptyNew(); result=result or {}
    self.requestId=tostring(requestId or ""); self.success=result.ok==true; self.code=tostring(result.code or "COMPANY_UNKNOWN")
    return self
end
function AgriLife.Company6IdentityResultEvent:writeStream(streamId, connection) streamWriteString(streamId,self.requestId); streamWriteBool(streamId,self.success); streamWriteString(streamId,self.code) end
function AgriLife.Company6IdentityResultEvent:readStream(streamId, connection) self.requestId=streamReadString(streamId); self.success=streamReadBool(streamId); self.code=streamReadString(streamId); self:run(connection) end
function AgriLife.Company6IdentityResultEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and not connection:getIsServer() then return end
    local module=getCompanyModule(); if module~=nil and module.onIdentityResult~=nil then module:onIdentityResult({requestId=self.requestId,success=self.success,code=self.code}) end
end

AgriLife.Company6IdentityRequestEvent = {}
local Company6IdentityRequestEvent_mt = Class(AgriLife.Company6IdentityRequestEvent, Event)
InitEventClass(AgriLife.Company6IdentityRequestEvent, "AgriLifeCompany6IdentityRequestEvent")
function AgriLife.Company6IdentityRequestEvent.emptyNew() return Event.new(Company6IdentityRequestEvent_mt) end
function AgriLife.Company6IdentityRequestEvent.new(farmId, companyName, legalFormId, requestId)
    local self=AgriLife.Company6IdentityRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; self.companyName=tostring(companyName or ""); self.legalFormId=tostring(legalFormId or "EI"); self.requestId=tostring(requestId or ""); return self
end
function AgriLife.Company6IdentityRequestEvent.send(farmId, companyName, legalFormId, requestId)
    local module=getCompanyModule(); if module==nil or module.service==nil then return AgriLife.Result.fail("COMPANY_MODULE_UNAVAILABLE","Company module unavailable") end
    if g_server~=nil then
        local ok,code=authorize(nil,farmId,"company.manage")
        if not ok then return AgriLife.Result.fail(code or "COMPANY_UNAUTHORIZED","Insufficient permissions") end
        local current=module.service:getSnapshot(farmId)
        local result=module.service:setIdentity(farmId,companyName,legalFormId,current~=nil and current.ownerProfileId or "")
        if module.onIdentityResult~=nil then module:onIdentityResult({requestId=requestId,success=result.ok,code=result.code}) end
        return result
    end
    if g_client~=nil and g_client.getServerConnection~=nil then
        g_client:getServerConnection():sendEvent(AgriLife.Company6IdentityRequestEvent.new(farmId,companyName,legalFormId,requestId))
        return AgriLife.Result.ok("COMPANY_IDENTITY_REQUEST_SENT","Company identity request sent")
    end
    return AgriLife.Result.fail("COMPANY_NETWORK_UNAVAILABLE","No server connection")
end
function AgriLife.Company6IdentityRequestEvent:writeStream(streamId, connection) streamWriteInt32(streamId,self.farmId); streamWriteString(streamId,self.companyName); streamWriteString(streamId,self.legalFormId); streamWriteString(streamId,self.requestId) end
function AgriLife.Company6IdentityRequestEvent:readStream(streamId, connection) self.farmId=streamReadInt32(streamId); self.companyName=streamReadString(streamId); self.legalFormId=streamReadString(streamId); self.requestId=streamReadString(streamId); self:run(connection) end
function AgriLife.Company6IdentityRequestEvent:run(connection)
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return end
    local module=getCompanyModule(); if module==nil or module.service==nil then return end
    local ok,code=authorize(connection,self.farmId,"company.manage")
    local result
    if not ok then result=AgriLife.Result.fail(code or "COMPANY_UNAUTHORIZED","Insufficient permissions")
    else
        local current=module.service:getSnapshot(self.farmId)
        result=module.service:setIdentity(self.farmId,self.companyName,self.legalFormId,current~=nil and current.ownerProfileId or "")
    end
    if connection~=nil and connection.sendEvent~=nil then
        connection:sendEvent(AgriLife.Company6IdentityResultEvent.new(self.requestId,result))
        local snapshot=module.service:getSnapshot(self.farmId); if snapshot~=nil then connection:sendEvent(AgriLife.Company6SnapshotEvent.new(snapshot)) end
    end
end
