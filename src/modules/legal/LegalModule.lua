-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.LegalModule = {}
AgriLife.LegalModule.__index = AgriLife.LegalModule
AgriLife.LegalModule.ID = "legal"
AgriLife.LegalModule.VERSION = "0.7.8.0"
AgriLife.LegalModule.SCHEMA_VERSION = 2

function AgriLife.LegalModule.new(core)
    return setmetatable({core = core, service = AgriLife.Legal6Service.new(core), started = false}, AgriLife.LegalModule)
end

function AgriLife.LegalModule:create()
    return AgriLife.Result.ok("LEGAL_CREATED", "Fiscalité et contentieux créés")
end

function AgriLife.LegalModule:load(xmlFile, key, farmId)
    return self.service:loadFarm(xmlFile, key, farmId)
end

function AgriLife.LegalModule:start()
    if self.started then return AgriLife.Result.ok("LEGAL_ALREADY_STARTED", "Fiscalité déjà active") end
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer then
        if MessageType == nil or MessageType.PERIOD_CHANGED == nil then
            return AgriLife.Result.fail("LEGAL_PERIOD_EVENT_MISSING", "Événement mensuel indisponible")
        end
        local result = self.core.subscriptions:subscribe(AgriLife.LegalModule.ID, MessageType.PERIOD_CHANGED, self.service, self.service.onPeriodChanged)
        if not result.ok then return result end
    end
    self.started = true
    return AgriLife.Result.ok("LEGAL_STARTED", "Fiscalité et contentieux actifs")
end

function AgriLife.LegalModule:save(xmlFile, key, farmId)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer or (tonumber(farmId) or 0) <= 0 then
        return AgriLife.Result.ok("LEGAL_SAVE_SKIPPED", "Sauvegarde fiscale ignorée")
    end
    return self.service:saveFarm(xmlFile, key, farmId)
end

function AgriLife.LegalModule:stop()
    if self.core ~= nil and self.core.subscriptions ~= nil then self.core.subscriptions:unsubscribeOwner(AgriLife.LegalModule.ID) end
    self.started = false
    return AgriLife.Result.ok("LEGAL_STOPPED", "Fiscalité arrêtée")
end

function AgriLife.LegalModule:delete()
    self:stop()
    if self.service ~= nil then self.service:delete() end
    self.service = nil
    self.core = nil
    return AgriLife.Result.ok("LEGAL_DELETED", "Fiscalité supprimée")
end

function AgriLife.LegalModule:getSnapshot(farmId) return self.service:getSnapshot(farmId) end
function AgriLife.LegalModule:settleDebt(...) return self.service:settleDebt(...) end

function AgriLife.LegalModule.getDescriptor()
    return {
        id = AgriLife.LegalModule.ID,
        version = AgriLife.LegalModule.VERSION,
        schemaVersion = AgriLife.LegalModule.SCHEMA_VERSION,
        dependencies = {"economy", "bank", "payroll"},
        defaultEnabled = true,
        serverOnly = false,
        critical = false,
        factory = function(core) return AgriLife.LegalModule.new(core) end
    }
end

function AgriLife.LegalModule.register(registry)
    return registry:register(AgriLife.LegalModule.getDescriptor())
end
