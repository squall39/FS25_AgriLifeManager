-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}
AgriLife.EconomyModule={}; AgriLife.EconomyModule.__index=AgriLife.EconomyModule
AgriLife.EconomyModule.ID="economy"; AgriLife.EconomyModule.VERSION="0.7.0.0"; AgriLife.EconomyModule.SCHEMA_VERSION=5
function AgriLife.EconomyModule.new(core) return setmetatable({core=core,service=AgriLife.Economy6Service.new(core),started=false,updateable=nil},AgriLife.EconomyModule) end
function AgriLife.EconomyModule:create() return AgriLife.Result.ok("ECONOMY_CREATED","Official economy module created") end
function AgriLife.EconomyModule:load(xmlFile,key,farmId) return self.service:loadFarm(xmlFile,key,farmId) end
function AgriLife.EconomyModule:start()
    if self.started then return AgriLife.Result.ok("ECONOMY_ALREADY_STARTED","Economy already started") end
    if self.core~=nil and self.core.context~=nil and self.core.context.isServer then
        if MessageType==nil or MessageType.PERIOD_CHANGED==nil then return AgriLife.Result.fail("ECONOMY_PERIOD_EVENT_MISSING","PERIOD_CHANGED unavailable") end
        local r=self.core.subscriptions:subscribe(AgriLife.EconomyModule.ID,MessageType.PERIOD_CHANGED,self.service,self.service.onPeriodChanged); if not r.ok then return r end
    end
    if self.service~=nil and self.service.installDifficultyVehicleEntryGuard~=nil then self.service:installDifficultyVehicleEntryGuard() end
    if self.core~=nil and self.core.context~=nil and g_currentMission~=nil and g_currentMission.addUpdateable~=nil then
        self.updateable={update=function(_,dt) if self.service~=nil then self.service:update(dt) end end}
        local ok,result=pcall(g_currentMission.addUpdateable,g_currentMission,self.updateable)
        if not ok or result==false then self.updateable=nil; AgriLife.Logger.warning("Economy","Economy runtime guard updateable could not be installed: %s",tostring(result)) end
    end
    self.started=true; return AgriLife.Result.ok("ECONOMY_STARTED","Official economy started")
end
function AgriLife.EconomyModule:save(xmlFile,key,farmId) if self.core==nil or self.core.context==nil or not self.core.context.isServer or tonumber(farmId)==nil or tonumber(farmId)<=0 then return AgriLife.Result.ok("ECONOMY_SAVE_SKIPPED","Economy save skipped") end; return self.service:saveFarm(xmlFile,key,tonumber(farmId)) end
function AgriLife.EconomyModule:stop() if self.core~=nil and self.core.subscriptions~=nil then self.core.subscriptions:unsubscribeOwner(AgriLife.EconomyModule.ID) end; if self.updateable~=nil and g_currentMission~=nil and g_currentMission.removeUpdateable~=nil then pcall(g_currentMission.removeUpdateable,g_currentMission,self.updateable) end; self.updateable=nil; self.started=false; return AgriLife.Result.ok("ECONOMY_STOPPED","Economy stopped") end
function AgriLife.EconomyModule:delete() self:stop(); if self.service~=nil then self.service:delete() end; self.service=nil; self.core=nil; return AgriLife.Result.ok("ECONOMY_DELETED","Economy deleted") end
function AgriLife.EconomyModule:getSnapshot(farmId) return self.service~=nil and self.service:getSnapshot(farmId) or nil end
function AgriLife.EconomyModule:isReady(farmId) return self.service~=nil and self.service:isReady(farmId)==true end
function AgriLife.EconomyModule:requireInsurance(farmId,category) return self.service:requireInsurance(farmId,category) end
function AgriLife.EconomyModule:selectMode(farmId,id) return self.service:selectMode(farmId,id) end
function AgriLife.EconomyModule:confirmMode(farmId) return self.service:confirmMode(farmId) end
function AgriLife.EconomyModule:changeMode(farmId,id) return self.service:changeMode(farmId,id) end
function AgriLife.EconomyModule:getModePolicy(farmId) return self.service:getModePolicy(farmId) end
function AgriLife.EconomyModule:getStartupStep(farmId) return self.service~=nil and self.service:getStartupStep(farmId) or nil end
function AgriLife.EconomyModule:getStartupSnapshot(farmId) return self.service~=nil and self.service:getStartupSnapshot(farmId) or nil end
function AgriLife.EconomyModule:validateStartupState(farmId) return self.service~=nil and self.service:validateStartupState(farmId) or AgriLife.Result.fail("ECONOMY_UNAVAILABLE","Economy unavailable") end
function AgriLife.EconomyModule:isModuleAvailable(farmId,moduleId) return self.service~=nil and self.service:isModuleAvailable(farmId,moduleId)==true end
function AgriLife.EconomyModule:selectStartingProfile(farmId,id) return self.service:selectStartingProfile(farmId,id) end
function AgriLife.EconomyModule:confirmStartingProfile(farmId) return self.service:confirmStartingProfile(farmId) end
function AgriLife.EconomyModule:finalizeSetup(farmId) return self.service:finalizeSetup(farmId) end
function AgriLife.EconomyModule:markExistingCareer(farmId) return self.service~=nil and self.service:markExistingCareer(farmId) or nil end
function AgriLife.EconomyModule:acknowledgeExistingCareer(farmId) return self.service~=nil and self.service:acknowledgeExistingCareer(farmId) or AgriLife.Result.fail("ECONOMY_UNAVAILABLE","Economy unavailable") end
function AgriLife.EconomyModule:setTutorialPreference(farmId,enabled) return self.service:setTutorialPreference(farmId,enabled) end
function AgriLife.EconomyModule:completeTutorial(farmId) return self.service:completeTutorial(farmId) end
function AgriLife.EconomyModule:setPersonalBank(...) return self.service:setPersonalBank(...) end
function AgriLife.EconomyModule:setPrivateVehicle(...) return self.service:setPrivateVehicle(...) end
function AgriLife.EconomyModule:contributeCapital(...) return self.service:contributeCapital(...) end
function AgriLife.EconomyModule:addAssociateManaged(...) return self.service:addAssociateManaged(...) end
function AgriLife.EconomyModule:removeAssociate(...) return self.service:removeAssociate(...) end
function AgriLife.EconomyModule:getDescriptor() return {id=AgriLife.EconomyModule.ID,version=AgriLife.EconomyModule.VERSION,schemaVersion=AgriLife.EconomyModule.SCHEMA_VERSION,dependencies={"company","people","bank","career","payroll","exams"},defaultEnabled=true,serverOnly=false,critical=false,factory=function(core) return AgriLife.EconomyModule.new(core) end} end
function AgriLife.EconomyModule.register(registry) return registry:register(AgriLife.EconomyModule.getDescriptor()) end
