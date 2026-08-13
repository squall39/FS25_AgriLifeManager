-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.IntegrityModule = {}
AgriLife.IntegrityModule.__index = AgriLife.IntegrityModule
AgriLife.IntegrityModule.ID = "integrity"
AgriLife.IntegrityModule.VERSION = "0.7.0.0"
AgriLife.IntegrityModule.SCHEMA_VERSION = 1

function AgriLife.IntegrityModule.new(core)
    return setmetatable({core = core, service = AgriLife.Integrity6Service.new(core), started = false, updateable = nil}, AgriLife.IntegrityModule)
end

function AgriLife.IntegrityModule:create()
    return AgriLife.Result.ok("INTEGRITY_CREATED", "Financial integrity module created")
end

function AgriLife.IntegrityModule:load(xmlFile, key, farmId)
    return self.service:loadFarm(xmlFile, key, farmId)
end

function AgriLife.IntegrityModule:start()
    if self.started then return AgriLife.Result.ok("INTEGRITY_ALREADY_STARTED", "Integrity already started") end
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer then
        local hookInstalled = self.service:installMoneyHook()
        if not hookInstalled then AgriLife.Logger.warning("Integrity", "FS25 money hook unavailable; direct-balance reconciliation remains active") end
        if g_currentMission ~= nil and g_currentMission.addUpdateable ~= nil then
            self.updateable = {update = function(_, dt) if self.service ~= nil then self.service:update(dt) end end}
            local ok, result = pcall(g_currentMission.addUpdateable, g_currentMission, self.updateable)
            if not ok or result == false then
                self.updateable = nil
                return AgriLife.Result.fail("INTEGRITY_UPDATEABLE_FAILED", "Financial integrity monitor could not start")
            end
        end
        for _, farmId in ipairs(self.core.context:getFarmIds()) do self.service:setBaseline(farmId) end
    end
    self.started = true
    return AgriLife.Result.ok("INTEGRITY_STARTED", "Financial integrity monitor started")
end

function AgriLife.IntegrityModule:save(xmlFile, key, farmId)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer or tonumber(farmId) == nil or tonumber(farmId) <= 0 then
        return AgriLife.Result.ok("INTEGRITY_SAVE_SKIPPED", "Integrity save skipped")
    end
    return self.service:saveFarm(xmlFile, key, tonumber(farmId))
end

function AgriLife.IntegrityModule:stop()
    if g_currentMission~=nil and self.updateable~=nil and g_currentMission.removeUpdateable~=nil then pcall(g_currentMission.removeUpdateable,g_currentMission,self.updateable) end
    self.updateable=nil
    if AgriLife.Integrity6Runtime~=nil and self.service~=nil and AgriLife.Integrity6Runtime.activeService==self.service then AgriLife.Integrity6Runtime.activeService=nil end
    self.started = false
    return AgriLife.Result.ok("INTEGRITY_STOPPED", "Financial integrity monitor stopped")
end

function AgriLife.IntegrityModule:delete()
    self:stop()
    if self.service ~= nil then self.service:delete() end
    self.updateable = nil
    self.service = nil
    self.core = nil
    return AgriLife.Result.ok("INTEGRITY_DELETED", "Financial integrity module deleted")
end

function AgriLife.IntegrityModule:getSnapshot(farmId) return self.service:getSnapshot(farmId) end
function AgriLife.IntegrityModule:reconcile(...) return self.service:reconcile(...) end
function AgriLife.IntegrityModule:canPerformFinancialAction(farmId) return self.service:canPerformFinancialAction(farmId) end

function AgriLife.IntegrityModule:getDescriptor()
    return {
        id = AgriLife.IntegrityModule.ID,
        version = AgriLife.IntegrityModule.VERSION,
        schemaVersion = AgriLife.IntegrityModule.SCHEMA_VERSION,
        dependencies = {"economy", "people"},
        defaultEnabled = true,
        serverOnly = false,
        critical = false,
        factory = function(core) return AgriLife.IntegrityModule.new(core) end
    }
end

function AgriLife.IntegrityModule.register(registry)
    return registry:register(AgriLife.IntegrityModule:getDescriptor())
end
