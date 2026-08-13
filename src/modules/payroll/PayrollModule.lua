-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}
AgriLife.PayrollModule={}; AgriLife.PayrollModule.__index=AgriLife.PayrollModule
AgriLife.PayrollModule.ID="payroll"; AgriLife.PayrollModule.VERSION="0.7.3.0"; AgriLife.PayrollModule.SCHEMA_VERSION=6
function AgriLife.PayrollModule.new(core) return setmetatable({core=core,service=AgriLife.Payroll6Service.new(core),updateable=nil,started=false,clientSnapshot=nil,snapshotAccumulator=0},AgriLife.PayrollModule) end
function AgriLife.PayrollModule:create() return AgriLife.Result.ok("PAYROLL_CREATED","Payroll module created") end
function AgriLife.PayrollModule:load(xmlFile,moduleKey,farmId) return self.service:loadFarm(xmlFile,moduleKey,farmId) end
function AgriLife.PayrollModule:start()
    if self.started then return AgriLife.Result.ok("PAYROLL_ALREADY_STARTED","Payroll already started") end
    if self.core==nil or self.core.context==nil then return AgriLife.Result.fail("PAYROLL_CONTEXT_MISSING","Payroll mission context unavailable") end
    if self.core.context.isServer then
        self.service:syncConnectedPlayers()
        if MessageType==nil or MessageType.PERIOD_CHANGED==nil then return AgriLife.Result.fail("PAYROLL_PERIOD_EVENT_MISSING","PERIOD_CHANGED message is unavailable") end
        if self.core.subscriptions==nil then return AgriLife.Result.fail("PAYROLL_SUBSCRIPTIONS_MISSING","Subscription manager unavailable") end
        local sub=self.core.subscriptions:subscribe(AgriLife.PayrollModule.ID,MessageType.PERIOD_CHANGED,self.service,self.service.onPeriodChanged)
        if sub==nil or not sub.ok then return sub or AgriLife.Result.fail("PAYROLL_PERIOD_SUBSCRIBE_FAILED","Unable to subscribe payroll period event") end
    elseif AgriLife.Payroll6SnapshotRequestEvent~=nil then
        AgriLife.Payroll6SnapshotRequestEvent.send(self.core.context:getFarmId() or 0)
    end
    if g_currentMission~=nil and g_currentMission.addUpdateable~=nil then
        self.updateable={update=function(_,dt)
            if self.core~=nil and self.core.context~=nil and self.core.context.isServer then self.service:update(dt)
            else self.snapshotAccumulator=self.snapshotAccumulator+math.max(0,tonumber(dt) or 0); if self.snapshotAccumulator>=5000 then self.snapshotAccumulator=0; local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; if farmId>0 and AgriLife.Payroll6SnapshotRequestEvent~=nil then AgriLife.Payroll6SnapshotRequestEvent.send(farmId) end end end
        end}
        local ok,res=pcall(g_currentMission.addUpdateable,g_currentMission,self.updateable); if not ok or res==false then self.updateable=nil; return AgriLife.Result.fail("PAYROLL_UPDATE_INSTALL_FAILED",tostring(res)) end
    end
    self.started=true; return AgriLife.Result.ok("PAYROLL_STARTED","Payroll module started")
end
function AgriLife.PayrollModule:save(xmlFile,moduleKey,farmId) if self.core==nil or self.core.context==nil or not self.core.context.isServer then return AgriLife.Result.ok("PAYROLL_CLIENT_SAVE_SKIPPED","Client does not save payroll") end; if tonumber(farmId)==nil or tonumber(farmId)<=0 then return AgriLife.Result.ok("PAYROLL_NO_FARM_SAVE","No farm payroll") end; return self.service:saveFarm(xmlFile,moduleKey,tonumber(farmId)) end
function AgriLife.PayrollModule:stop() if g_currentMission~=nil and self.updateable~=nil and g_currentMission.removeUpdateable~=nil then pcall(g_currentMission.removeUpdateable,g_currentMission,self.updateable) end; self.updateable=nil; self.started=false; return AgriLife.Result.ok("PAYROLL_STOPPED","Payroll stopped") end
function AgriLife.PayrollModule:delete() self:stop(); if self.service~=nil then self.service:delete() end; self.service=nil; self.core=nil; self.clientSnapshot=nil; return AgriLife.Result.ok("PAYROLL_DELETED","Payroll deleted") end
function AgriLife.PayrollModule:getSnapshot(farmId)
    if self.core~=nil and self.core.context~=nil and not self.core.context.isServer then return self.clientSnapshot end
    if self.service==nil then return nil end
    local people=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.people or nil
    local viewerProfileId=people~=nil and people.getLocalProfileId~=nil and people:getLocalProfileId(farmId) or nil
    local canManage=viewerProfileId~=nil and people~=nil and people.service~=nil and people.service:hasPermission(farmId,viewerProfileId,"payroll.manage") or false
    if self.service.getViewerSnapshot~=nil and viewerProfileId~=nil then return self.service:getViewerSnapshot(farmId,viewerProfileId,canManage) end
    return self.service:getSnapshot(farmId)
end
function AgriLife.PayrollModule:applyClientSnapshot(snapshot) self.clientSnapshot=snapshot; if self.core~=nil and self.core.ui~=nil and self.core.ui.frame~=nil then self.core.ui.frame:refresh() end end
function AgriLife.PayrollModule:requestSnapshot(farmId) if AgriLife.Payroll6SnapshotRequestEvent==nil then return AgriLife.Result.fail("PAYROLL_NETWORK_UNAVAILABLE","Payroll snapshot event unavailable") end; return AgriLife.Payroll6SnapshotRequestEvent.send(farmId) end

function AgriLife.PayrollModule:setSalaryAuto(farmId,profileId)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.Payroll6AdminRequestEvent.send(farmId,profileId,"AUTO",0,string.format("PA-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PayrollModule:setSalaryManual(farmId,profileId,amount)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.Payroll6AdminRequestEvent.send(farmId,profileId,"MANUAL",amount,string.format("PM-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PayrollModule:terminateEmployment(farmId,profileId)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.Payroll6AdminRequestEvent.send(farmId,profileId,"TERMINATE",0,string.format("PT-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PayrollModule:settleOutstanding(farmId,profileId)
    self.requestSequence=(self.requestSequence or 0)+1
    return AgriLife.Payroll6AdminRequestEvent.send(farmId,profileId,"SETTLE",0,string.format("PS-%d-%d",farmId,self.requestSequence))
end
function AgriLife.PayrollModule:recordAttendance(farmId,actorProfileId,targetProfileId,overtimeHours,absenceDays) return self.service:recordAttendance(farmId,actorProfileId,targetProfileId,overtimeHours,absenceDays) end
function AgriLife.PayrollModule:requestLeave(farmId,profileId,days) return self.service:requestLeave(farmId,profileId,days) end
function AgriLife.PayrollModule:recordSickLeave(farmId,actorProfileId,targetProfileId,days) return self.service:recordSickLeave(farmId,actorProfileId,targetProfileId,days) end
function AgriLife.PayrollModule:recruitVirtualEmployee(farmId,actorProfileId,role,contractType,displayName) return self.service:recruitVirtualEmployee(farmId,actorProfileId,role,contractType,displayName) end
function AgriLife.PayrollModule:resign(farmId,profileId) return self.service:resign(farmId,profileId) end
function AgriLife.PayrollModule:onAdminResult(result)
    self.lastAdminResult=result
    if self.core~=nil and self.core.ui~=nil and self.core.ui.frame~=nil and self.core.ui.frame.onPayrollAdminResult~=nil then self.core.ui.frame:onPayrollAdminResult(result) end
end

function AgriLife.PayrollModule:deleteProfile(farmId,profileId) return self.service~=nil and self.service:deleteProfile(farmId,profileId) or AgriLife.Result.ok("PAYROLL_PROFILE_ABSENT","Payroll unavailable") end
function AgriLife.PayrollModule:getEnterpriseWorkSummary(...) return self.service:getEnterpriseWorkSummary(...) end
function AgriLife.PayrollModule:onPeriodChanged() if self.service~=nil then self.service:onPeriodChanged() end end
function AgriLife.PayrollModule.getDescriptor() return {id=AgriLife.PayrollModule.ID,version=AgriLife.PayrollModule.VERSION,schemaVersion=AgriLife.PayrollModule.SCHEMA_VERSION,dependencies={"company","people","career"},defaultEnabled=true,serverOnly=false,critical=false,factory=function(core) return AgriLife.PayrollModule.new(core) end} end
function AgriLife.PayrollModule.register(registry) if registry==nil then return AgriLife.Result.fail("PAYROLL_REGISTRY_MISSING","Module registry unavailable") end; return registry:register(AgriLife.PayrollModule.getDescriptor()) end
