-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.CareerModule = {}
AgriLife.CareerModule.__index = AgriLife.CareerModule
AgriLife.CareerModule.ID = "career"
AgriLife.CareerModule.VERSION = "0.7.7.0"
AgriLife.CareerModule.SCHEMA_VERSION = 5

function AgriLife.CareerModule.new(core)
    local service=AgriLife.Career6Service.new(core)
    return setmetatable({ core=core, service=service, workTracker=nil, transportTracker=nil, hud=AgriLife.Career6Hud.new(core,service), updateable=nil, refreshAccumulator=0, networkAccumulator=0, started=false }, AgriLife.CareerModule)
end
function AgriLife.CareerModule:create()
    if self.service==nil then return AgriLife.Result.fail("CAREER_SERVICE_MISSING","Career service unavailable") end
    if AgriLife.CareerWorkTracker==nil then return AgriLife.Result.fail("CAREER_WORK_TRACKER_MISSING","Career work tracker unavailable") end
    if AgriLife.CareerTransportTracker==nil then return AgriLife.Result.fail("CAREER_TRANSPORT_TRACKER_MISSING","Career transport tracker unavailable") end
    if AgriLife.Career6Hud==nil or self.hud==nil then return AgriLife.Result.fail("CAREER_HUD_MISSING","Career XP HUD unavailable") end
    self.workTracker=AgriLife.CareerWorkTracker.new(self.service); self.transportTracker=AgriLife.CareerTransportTracker.new(self.service)
    return AgriLife.Result.ok("CAREER_CREATED","Career module created")
end
function AgriLife.CareerModule:load(xmlFile,moduleKey,farmId) return self.service:loadFarm(xmlFile,moduleKey,farmId) end
function AgriLife.CareerModule:start()
    if self.started then return AgriLife.Result.ok("CAREER_ALREADY_STARTED","Career module already started") end
    if self.core==nil or self.core.context==nil then return AgriLife.Result.fail("CAREER_CONTEXT_MISSING","Career mission context unavailable") end
    if self.workTracker==nil then return AgriLife.Result.fail("CAREER_WORK_TRACKER_MISSING","Career work tracker unavailable") end
    local trackerResult=self.workTracker:install(); if trackerResult~=nil and trackerResult.ok==false then return trackerResult end
    if not self.core.context.isDedicatedServer then
        local hudResult=self.hud:install(); if hudResult~=nil and hudResult.ok==false then self.workTracker:uninstall(); return hudResult end
    end
    if self.core.context.isServer then
        local people=self.service:getPeopleService(); if people~=nil and people.syncConnectedPlayers~=nil then people:syncConnectedPlayers() end
        if self.core.subscriptions~=nil and MessageType~=nil then
            local livestockHooks={{"HUSBANDRY_ANIMALS_CHANGED",self.service.onHusbandryAnimalsChanged},{"HUSBANDRY_FOOD_CHANGED",self.service.onHusbandryFoodChanged},{"ANIMAL_HUSBANDRY_UPDATED",self.service.onAnimalHusbandryUpdated}}
            for _,hook in ipairs(livestockHooks) do local messageType=MessageType[hook[1]];if messageType~=nil then local subscription=self.core.subscriptions:subscribe(AgriLife.CareerModule.ID,messageType,self.service,hook[2]);if subscription~=nil and not subscription.ok then AgriLife.Logger.warning("Career","Livestock hook %s unavailable: %s",hook[1],tostring(subscription.code)) end end end
        end
    elseif AgriLife.Career6SnapshotRequestEvent~=nil then AgriLife.Career6SnapshotRequestEvent.send(self.core.context:getFarmId() or 0) end
    if g_currentMission~=nil and g_currentMission.addUpdateable~=nil then
        self.updateable={update=function(_,dt)
            if self.core~=nil and self.core.context~=nil and self.core.context.isServer then
                -- Resolve exact specialised work first. The service can then
                -- prevent the same metres from also producing Driving XP.
                if self.workTracker~=nil then self.workTracker:update(dt) end; self.service:update(dt); if self.transportTracker~=nil then self.transportTracker:update(dt) end
                self.refreshAccumulator=self.refreshAccumulator+(tonumber(dt) or 0)
                if self.refreshAccumulator>=5000 then self.refreshAccumulator=0; if self.workTracker~=nil then self.workTracker:refreshVehicles() end end
            else
                self.networkAccumulator=self.networkAccumulator+(tonumber(dt) or 0)
                if self.networkAccumulator>=5000 then self.networkAccumulator=0; if AgriLife.Career6SnapshotRequestEvent~=nil then AgriLife.Career6SnapshotRequestEvent.send(self.core.context:getFarmId() or 0) end end
            end
        end}
        local ok,result=pcall(g_currentMission.addUpdateable,g_currentMission,self.updateable)
        if not ok or result==false then self.updateable=nil; if self.hud~=nil then self.hud:uninstall() end; if self.workTracker~=nil then self.workTracker:uninstall() end; return AgriLife.Result.fail("CAREER_UPDATE_INSTALL_FAILED",tostring(result)) end
    elseif not self.core.context.isDedicatedServer then if self.hud~=nil then self.hud:uninstall() end; if self.workTracker~=nil then self.workTracker:uninstall() end; return AgriLife.Result.fail("CAREER_UPDATE_RUNTIME_MISSING","Mission update API unavailable") end
    self.started=true; AgriLife.Logger.info("Career","Per-player Career module started")
    return AgriLife.Result.ok("CAREER_STARTED","Career module started")
end
function AgriLife.CareerModule:save(xmlFile,moduleKey,farmId)
    if self.core==nil or self.core.context==nil or not self.core.context.isServer then return AgriLife.Result.ok("CAREER_CLIENT_SAVE_SKIPPED","Client does not save career state") end
    if tonumber(farmId)==nil or tonumber(farmId)<=0 then return AgriLife.Result.ok("CAREER_NO_FARM_SAVE","No farm-specific career state to save") end
    return self.service:saveFarm(xmlFile,moduleKey,tonumber(farmId))
end
function AgriLife.CareerModule:stop()
    if g_currentMission~=nil and self.updateable~=nil and g_currentMission.removeUpdateable~=nil then pcall(g_currentMission.removeUpdateable,g_currentMission,self.updateable) end
    self.updateable=nil; self.refreshAccumulator=0; self.networkAccumulator=0
    if self.hud~=nil then self.hud:uninstall() end
    if self.workTracker~=nil then self.workTracker:uninstall() end; if self.transportTracker~=nil then self.transportTracker:reset() end
    if self.core~=nil and self.core.subscriptions~=nil then self.core.subscriptions:unsubscribeOwner(AgriLife.CareerModule.ID) end
    self.started=false; return AgriLife.Result.ok("CAREER_STOPPED","Career module stopped")
end
function AgriLife.CareerModule:delete()
    self:stop(); if self.workTracker~=nil then self.workTracker:delete() end; self.workTracker=nil; if self.transportTracker~=nil then self.transportTracker:delete() end; self.transportTracker=nil; if self.hud~=nil then self.hud:delete() end; self.hud=nil
    if self.service~=nil then self.service:delete() end; self.service=nil; self.core=nil; return AgriLife.Result.ok("CAREER_DELETED","Career module deleted")
end
function AgriLife.CareerModule:getLocalProfileId(farmId)
    local people=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.people or nil
    return people~=nil and people.getLocalProfileId~=nil and people:getLocalProfileId(farmId) or self.service:resolveProfileId(farmId,nil,nil)
end
function AgriLife.CareerModule:getSnapshot(farmId,profileId) return self.service~=nil and self.service:getSnapshot(farmId,profileId or self:getLocalProfileId(farmId)) or nil end
function AgriLife.CareerModule:getTeamSnapshots(farmId) return self.service~=nil and self.service:getTeamSnapshots(farmId) or {} end
function AgriLife.CareerModule:requestSnapshot(farmId) if AgriLife.Career6SnapshotRequestEvent==nil then return AgriLife.Result.fail("CAREER_NETWORK_UNAVAILABLE","Career snapshot event unavailable") end; return AgriLife.Career6SnapshotRequestEvent.send(farmId) end
function AgriLife.CareerModule:deleteProfile(farmId,profileId) return self.service~=nil and self.service:deleteProfile(farmId,profileId) or AgriLife.Result.ok("CAREER_PROFILE_ABSENT","Career service unavailable") end
function AgriLife.CareerModule:awardXP(farmId,specialtyId,amount,sourceToken,profileId) return self.service:awardXP(farmId,specialtyId,amount,sourceToken,profileId) end
function AgriLife.CareerModule:awardFieldWork(farmId,specialtyId,areaSqm,quality,sourceToken,profileId) return self.service:awardFieldWork(farmId,specialtyId,areaSqm,quality,sourceToken,profileId) end
function AgriLife.CareerModule:awardTransport(farmId,tonnes,kilometers,quality,sourceToken,profileId) return self.service:awardTransport(farmId,tonnes,kilometers,quality,sourceToken,profileId) end
function AgriLife.CareerModule:recordLivestockCare(farmId,units,action,sourceToken,profileId) return self.service:recordLivestockCare(farmId,units,action,sourceToken,profileId) end
function AgriLife.CareerModule:recordMaintenance(farmId,kind,difficulty,sourceToken,profileId) return self.service:recordMaintenance(farmId,kind,difficulty,sourceToken,profileId) end
function AgriLife.CareerModule:recordManagement(farmId,amount,sourceToken,profileId) return self.service:recordManagement(farmId,amount,sourceToken,profileId) end
function AgriLife.CareerModule:adjustReputation(farmId,amount,profileId) return self.service:adjustReputation(farmId,amount,profileId) end
function AgriLife.CareerModule:recordExamResult(farmId,passed,profileId) return self.service:recordExamResult(farmId,passed,profileId) end
function AgriLife.CareerModule:setExamLock(farmId,profileId,locked) return self.service:setExamLock(farmId,profileId,locked) end
function AgriLife.CareerModule.getDescriptor() return {id=AgriLife.CareerModule.ID,version=AgriLife.CareerModule.VERSION,schemaVersion=AgriLife.CareerModule.SCHEMA_VERSION,dependencies={"people"},defaultEnabled=true,serverOnly=false,critical=false,factory=function(core) return AgriLife.CareerModule.new(core) end} end
function AgriLife.CareerModule.register(registry) if registry==nil then return AgriLife.Result.fail("CAREER_REGISTRY_MISSING","Module registry unavailable") end; return registry:register(AgriLife.CareerModule.getDescriptor()) end
