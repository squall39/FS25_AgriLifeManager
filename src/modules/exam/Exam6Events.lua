-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

local function getExamModule()
    if g_agriLifeCore~=nil and g_agriLifeCore.registry~=nil and g_agriLifeCore.registry.instances~=nil then return g_agriLifeCore.registry.instances.exams end
    return nil
end
local function getPeopleModule()
    if g_agriLifeCore~=nil and g_agriLifeCore.registry~=nil and g_agriLifeCore.registry.instances~=nil then return g_agriLifeCore.registry.instances.people end
    return nil
end
local function validateFarmMembership(connection,farmId)
    local people=getPeopleModule()
    if people~=nil and people.service~=nil and people.service.authorizeConnection~=nil then local ok,_,profileId=people.service:authorizeConnection(connection,farmId,"profile.viewSelf"); return ok==true,profileId end
    return false,nil
end

local function writeProfile(streamId,s)
    streamWriteString(streamId,tostring(s.profileId or "")); streamWriteString(streamId,tostring(s.licenceStatus or "notObtained")); streamWriteString(streamId,tostring(s.licenceNumber or "")); streamWriteInt32(streamId,tonumber(s.attempts) or 0); streamWriteInt32(streamId,tonumber(s.passes) or 0); streamWriteInt32(streamId,tonumber(s.bestScore) or 0); streamWriteBool(streamId,s.examRunning==true); streamWriteUInt8(streamId,math.max(0,math.min(10,tonumber(s.currentIndex) or 0))); streamWriteUInt8(streamId,math.max(0,math.min(100,tonumber(s.score) or 100))); streamWriteUInt8(streamId,math.max(0,math.min(255,tonumber(s.errors) or 0))); streamWriteUInt8(streamId,math.max(0,math.min(100,tonumber(s.progress) or 0))); streamWriteInt32(streamId,tonumber(s.elapsedMs) or 0); streamWriteString(streamId,tostring(s.lastMessageCode or "")); streamWriteString(streamId,tostring(s.lastErrorCode or "")); streamWriteInt32(streamId,tonumber(s.messageUntil) or 0)
    local hasTarget=tonumber(s.targetX)~=nil and tonumber(s.targetZ)~=nil
    streamWriteBool(streamId,hasTarget)
    if hasTarget then streamWriteFloat32(streamId,tonumber(s.targetX)); streamWriteFloat32(streamId,tonumber(s.targetZ)); streamWriteFloat32(streamId,tonumber(s.targetRadius) or 10); streamWriteFloat32(streamId,tonumber(s.targetDistance) or 0); streamWriteString(streamId,tostring(s.targetKind or "")) end
    local count=math.min(10,#(s.taskIds or {})); streamWriteUInt8(streamId,count); for i=1,count do streamWriteString(streamId,tostring(s.taskIds[i] or "")) end
    local certifications={}; for _,cert in pairs(s.certifications or {}) do table.insert(certifications,cert) end; table.sort(certifications,function(a,b) return tostring(a.id)<tostring(b.id) end)
    local certCount=math.min(32,#certifications); streamWriteUInt8(streamId,certCount)
    for i=1,certCount do local cert=certifications[i]; streamWriteString(streamId,tostring(cert.id or "")); streamWriteString(streamId,tostring(cert.name or "")); streamWriteString(streamId,tostring(cert.number or "")); streamWriteInt32(streamId,tonumber(cert.issuedPeriodKey) or 0); streamWriteFloat32(streamId,tonumber(cert.fee) or 0) end
end
local function readProfile(streamId)
    local s={profileId=streamReadString(streamId),licenceStatus=streamReadString(streamId),licenceNumber=streamReadString(streamId),attempts=streamReadInt32(streamId),passes=streamReadInt32(streamId),bestScore=streamReadInt32(streamId),examRunning=streamReadBool(streamId),currentIndex=streamReadUInt8(streamId),score=streamReadUInt8(streamId),errors=streamReadUInt8(streamId),progress=streamReadUInt8(streamId),elapsedMs=streamReadInt32(streamId),lastMessageCode=streamReadString(streamId),lastErrorCode=streamReadString(streamId),messageUntil=streamReadInt32(streamId),taskIds={}}
    if streamReadBool(streamId) then s.targetX=streamReadFloat32(streamId); s.targetZ=streamReadFloat32(streamId); s.targetRadius=streamReadFloat32(streamId); s.targetDistance=streamReadFloat32(streamId); s.targetKind=streamReadString(streamId) end
    local count=streamReadUInt8(streamId); for i=1,count do s.taskIds[i]=streamReadString(streamId) end
    s.certifications={}; local certCount=streamReadUInt8(streamId); for i=1,certCount do table.insert(s.certifications,{id=streamReadString(streamId),name=streamReadString(streamId),number=streamReadString(streamId),issuedPeriodKey=streamReadInt32(streamId),fee=streamReadFloat32(streamId)}) end
    return s
end

AgriLife.Exam6SnapshotEvent={}
local Exam6SnapshotEvent_mt=Class(AgriLife.Exam6SnapshotEvent,Event)
InitEventClass(AgriLife.Exam6SnapshotEvent,"AgriLifeExam6SnapshotEvent")
function AgriLife.Exam6SnapshotEvent.emptyNew() return Event.new(Exam6SnapshotEvent_mt) end
function AgriLife.Exam6SnapshotEvent.new(farmId,viewerProfileId,snapshots) local self=AgriLife.Exam6SnapshotEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; self.viewerProfileId=tostring(viewerProfileId or ""); self.snapshots=snapshots or {}; return self end
function AgriLife.Exam6SnapshotEvent:writeStream(streamId,connection) streamWriteInt32(streamId,self.farmId); streamWriteString(streamId,self.viewerProfileId); local count=math.min(64,#self.snapshots); streamWriteUInt8(streamId,count); for i=1,count do writeProfile(streamId,self.snapshots[i]) end end
function AgriLife.Exam6SnapshotEvent:readStream(streamId,connection) self.farmId=streamReadInt32(streamId); self.viewerProfileId=streamReadString(streamId); self.snapshots={}; local count=streamReadUInt8(streamId); for i=1,count do self.snapshots[i]=readProfile(streamId) end; self:run(connection) end
function AgriLife.Exam6SnapshotEvent:run(connection)
    if connection~=nil and connection.getIsServer~=nil and not connection:getIsServer() then return end
    local module=getExamModule(); if module~=nil and module.service~=nil then module.service:applyClientTeamSnapshot(self.farmId,self.viewerProfileId,self.snapshots); if module.core~=nil and module.core.ui~=nil and module.core.ui.frame~=nil then module.core.ui.frame:refresh() end end
end

AgriLife.Exam6SnapshotRequestEvent={}
local Exam6SnapshotRequestEvent_mt=Class(AgriLife.Exam6SnapshotRequestEvent,Event)
InitEventClass(AgriLife.Exam6SnapshotRequestEvent,"AgriLifeExam6SnapshotRequestEvent")
function AgriLife.Exam6SnapshotRequestEvent.emptyNew() return Event.new(Exam6SnapshotRequestEvent_mt) end
function AgriLife.Exam6SnapshotRequestEvent.new(farmId) local self=AgriLife.Exam6SnapshotRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; return self end
function AgriLife.Exam6SnapshotRequestEvent.send(farmId) if g_server~=nil then return AgriLife.Result.ok("EXAM_SNAPSHOT_LOCAL","Server already owns exam state") end; if g_client~=nil and g_client.getServerConnection~=nil then g_client:getServerConnection():sendEvent(AgriLife.Exam6SnapshotRequestEvent.new(farmId)); return AgriLife.Result.ok("EXAM_SNAPSHOT_REQUESTED","Exam snapshot requested") end; return AgriLife.Result.fail("EXAM_NETWORK_UNAVAILABLE","No server connection") end
function AgriLife.Exam6SnapshotRequestEvent:writeStream(streamId,connection) streamWriteInt32(streamId,self.farmId) end
function AgriLife.Exam6SnapshotRequestEvent:readStream(streamId,connection) self.farmId=streamReadInt32(streamId); self:run(connection) end
function AgriLife.Exam6SnapshotRequestEvent:run(connection)
    if connection~=nil and connection.getIsServer~=nil and connection:getIsServer() then return end
    local ok,viewerProfileId=validateFarmMembership(connection,self.farmId); if not ok or connection==nil then return end
    local module=getExamModule(); if module~=nil and module.service~=nil then connection:sendEvent(AgriLife.Exam6SnapshotEvent.new(self.farmId,viewerProfileId,module.service:getTeamSnapshots(self.farmId))) end
end

AgriLife.Exam6ActionResultEvent={}
local Exam6ActionResultEvent_mt=Class(AgriLife.Exam6ActionResultEvent,Event)
InitEventClass(AgriLife.Exam6ActionResultEvent,"AgriLifeExam6ActionResultEvent")
function AgriLife.Exam6ActionResultEvent.emptyNew() return Event.new(Exam6ActionResultEvent_mt) end
function AgriLife.Exam6ActionResultEvent.new(requestId,success,code) local self=AgriLife.Exam6ActionResultEvent.emptyNew(); self.requestId=tostring(requestId or ""); self.success=success==true; self.code=tostring(code or "EXAM_UNKNOWN"); return self end
function AgriLife.Exam6ActionResultEvent:writeStream(streamId,connection) streamWriteString(streamId,self.requestId); streamWriteBool(streamId,self.success); streamWriteString(streamId,self.code) end
function AgriLife.Exam6ActionResultEvent:readStream(streamId,connection) self.requestId=streamReadString(streamId); self.success=streamReadBool(streamId); self.code=streamReadString(streamId); self:run(connection) end
function AgriLife.Exam6ActionResultEvent:run(connection) if connection~=nil and connection.getIsServer~=nil and not connection:getIsServer() then return end; local module=getExamModule(); if module~=nil then module.lastActionResult={requestId=self.requestId,success=self.success,code=self.code}; if module.core~=nil and module.core.ui~=nil and module.core.ui.frame~=nil then module.core.ui.frame:refresh() end end end

AgriLife.Exam6ActionRequestEvent={}
local Exam6ActionRequestEvent_mt=Class(AgriLife.Exam6ActionRequestEvent,Event)
InitEventClass(AgriLife.Exam6ActionRequestEvent,"AgriLifeExam6ActionRequestEvent")
function AgriLife.Exam6ActionRequestEvent.emptyNew() return Event.new(Exam6ActionRequestEvent_mt) end
function AgriLife.Exam6ActionRequestEvent.new(farmId,action,requestId) local self=AgriLife.Exam6ActionRequestEvent.emptyNew(); self.farmId=tonumber(farmId) or 0; self.action=tostring(action or ""); self.requestId=tostring(requestId or ""); return self end
function AgriLife.Exam6ActionRequestEvent.send(farmId,action,requestId)
    if g_client~=nil and g_client.getServerConnection~=nil then g_client:getServerConnection():sendEvent(AgriLife.Exam6ActionRequestEvent.new(farmId,action,requestId)); return AgriLife.Result.ok("EXAM_ACTION_SENT","Exam action sent") end
    return AgriLife.Result.fail("EXAM_NETWORK_UNAVAILABLE","No server connection")
end
function AgriLife.Exam6ActionRequestEvent:writeStream(streamId,connection) streamWriteInt32(streamId,self.farmId); streamWriteString(streamId,self.action); streamWriteString(streamId,self.requestId) end
function AgriLife.Exam6ActionRequestEvent:readStream(streamId,connection) self.farmId=streamReadInt32(streamId); self.action=streamReadString(streamId); self.requestId=streamReadString(streamId); self:run(connection) end
function AgriLife.Exam6ActionRequestEvent:run(connection)
    if connection~=nil and connection.getIsServer~=nil and connection:getIsServer() then return end
    local ok,profileId=validateFarmMembership(connection,self.farmId); local module=getExamModule(); if module==nil or module.service==nil then return end
    local result
    if not ok then result=AgriLife.Result.fail("EXAM_PERMISSION_DENIED","Player is not a member of this farm")
    elseif self.action=="START" then result=module.service:startExam(self.farmId,profileId,true)
    elseif self.action=="CANCEL" then result=module.service:cancelExam(self.farmId,profileId,"EXAM_CANCELLED_BY_USER")
    elseif self.action=="CERTIFICATION" then result=module.service:requestNextCertification(self.farmId,profileId)
    else result=AgriLife.Result.fail("EXAM_ACTION_INVALID","Unknown exam action") end
    if connection~=nil then connection:sendEvent(AgriLife.Exam6ActionResultEvent.new(self.requestId,result.ok,result.code)); connection:sendEvent(AgriLife.Exam6SnapshotEvent.new(self.farmId,profileId,module.service:getTeamSnapshots(self.farmId))) end
end
