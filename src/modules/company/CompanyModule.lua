-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.CompanyModule = {}
AgriLife.CompanyModule.__index = AgriLife.CompanyModule
AgriLife.CompanyModule.ID = "company"
AgriLife.CompanyModule.VERSION = "0.7.8.0"
AgriLife.CompanyModule.SCHEMA_VERSION = 2

function AgriLife.CompanyModule.new(core)
    return setmetatable({ core=core, service=AgriLife.Company6Service.new(core), started=false, clientSnapshot=nil, requestSequence=0, lastIdentityResult=nil, lastSnapshotRequestTime=-100000 }, AgriLife.CompanyModule)
end
function AgriLife.CompanyModule:create() return AgriLife.Result.ok("COMPANY_CREATED", "Company module created") end
function AgriLife.CompanyModule:load(xmlFile,moduleKey,farmId) return self.service:loadFarm(xmlFile,moduleKey,farmId) end
function AgriLife.CompanyModule:start()
    self.started=true
    if self.core~=nil and self.core.context~=nil and not self.core.context.isServer and AgriLife.Company6SnapshotRequestEvent~=nil then self:requestSnapshot(self.core.context:getFarmId() or 0,true) end
    return AgriLife.Result.ok("COMPANY_STARTED","Company module started")
end
function AgriLife.CompanyModule:save(xmlFile,moduleKey,farmId)
    if self.core==nil or self.core.context==nil or not self.core.context.isServer then return AgriLife.Result.ok("COMPANY_CLIENT_SAVE_SKIPPED","Client does not save company state") end
    if tonumber(farmId)==nil or tonumber(farmId)<=0 then return AgriLife.Result.ok("COMPANY_NO_FARM_SAVE","No farm company state") end
    return self.service:saveFarm(xmlFile,moduleKey,tonumber(farmId))
end
function AgriLife.CompanyModule:stop() self.started=false return AgriLife.Result.ok("COMPANY_STOPPED","Company module stopped") end
function AgriLife.CompanyModule:delete() self:stop(); if self.service~=nil then self.service:delete() end; self.service=nil; self.core=nil; self.clientSnapshot=nil; return AgriLife.Result.ok("COMPANY_DELETED","Company module deleted") end
function AgriLife.CompanyModule:getSnapshot(farmId)
    if self.core~=nil and self.core.context~=nil and not self.core.context.isServer then self:requestSnapshot(farmId,false); return self.clientSnapshot end
    return self.service~=nil and self.service:getSnapshot(farmId) or nil
end
function AgriLife.CompanyModule:applyClientSnapshot(snapshot)
    if snapshot==nil then return end
    local form=self.service~=nil and self.service:getLegalForm(snapshot.legalFormId) or nil
    snapshot.legalFormId=form~=nil and form.id or tostring(snapshot.legalFormId or "EI")
    snapshot.legalFormLabelKey=form~=nil and form.labelKey or "agrilife_company6_form_EI"
    snapshot.minMembers=form~=nil and form.minMembers or 1; snapshot.maxMembers=form~=nil and form.maxMembers or 1
    self.clientSnapshot=snapshot
    if self.core~=nil and self.core.ui~=nil and self.core.ui.frame~=nil then self.core.ui.frame:refresh() end
end
function AgriLife.CompanyModule:requestSnapshot(farmId,force)
    if self.core==nil or self.core.context==nil or self.core.context.isServer or AgriLife.Company6SnapshotRequestEvent==nil then return AgriLife.Result.ok("COMPANY_SNAPSHOT_NOT_NEEDED","Company snapshot not needed") end
    local now=tonumber(g_time) or 0; if not force and now-self.lastSnapshotRequestTime<3000 then return AgriLife.Result.ok("COMPANY_SNAPSHOT_THROTTLED","Company snapshot throttled") end
    self.lastSnapshotRequestTime=now; return AgriLife.Company6SnapshotRequestEvent.send(farmId)
end
function AgriLife.CompanyModule:canManage(farmId)
    local people=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.people or nil
    return people~=nil and people.canLocal~=nil and people:canLocal(farmId,"company.manage")==true
end
function AgriLife.CompanyModule:setIdentity(farmId,companyName,legalFormId)
    if not self:canManage(farmId) then return AgriLife.Result.fail("COMPANY_UNAUTHORIZED","Only the owner or a manager can change company settings") end
    self.requestSequence=self.requestSequence+1; local requestId=string.format("CI-%d-%d",tonumber(farmId) or 0,self.requestSequence); self.lastIdentityResult=nil
    if AgriLife.Company6IdentityRequestEvent==nil then return AgriLife.Result.fail("COMPANY_NETWORK_UNAVAILABLE","Company identity event unavailable") end
    return AgriLife.Company6IdentityRequestEvent.send(farmId,companyName,legalFormId,requestId)
end
function AgriLife.CompanyModule:onIdentityResult(result)
    self.lastIdentityResult=result
    if self.core~=nil and self.core.ui~=nil and self.core.ui.frame~=nil and self.core.ui.frame.onCompanyIdentityResult~=nil then self.core.ui.frame:onCompanyIdentityResult(result) end
end
function AgriLife.CompanyModule:getLegalForms() return AgriLife.Company6Service.LEGAL_FORMS end
function AgriLife.CompanyModule.getDescriptor() return {id=AgriLife.CompanyModule.ID,version=AgriLife.CompanyModule.VERSION,schemaVersion=AgriLife.CompanyModule.SCHEMA_VERSION,dependencies={},defaultEnabled=true,serverOnly=false,critical=false,factory=function(core) return AgriLife.CompanyModule.new(core) end} end
function AgriLife.CompanyModule.register(registry) if registry==nil then return AgriLife.Result.fail("COMPANY_REGISTRY_MISSING","Module registry unavailable") end; return registry:register(AgriLife.CompanyModule.getDescriptor()) end
