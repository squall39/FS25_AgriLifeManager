-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.JournalModule = {}
AgriLife.JournalModule.__index = AgriLife.JournalModule
AgriLife.JournalModule.ID = "journal"
AgriLife.JournalModule.VERSION = "0.7.0.0"
AgriLife.JournalModule.SCHEMA_VERSION = 1

function AgriLife.JournalModule.new(core)
    return setmetatable({core = core, service = AgriLife.Journal6Service.new(core), started = false}, AgriLife.JournalModule)
end
function AgriLife.JournalModule:create() return AgriLife.Result.ok("JOURNAL_CREATED", "Journal created") end
function AgriLife.JournalModule:load(xmlFile, key, farmId) return self.service:loadFarm(xmlFile, key, farmId) end
function AgriLife.JournalModule:start() self.started = true; return AgriLife.Result.ok("JOURNAL_STARTED", "Journal started") end
function AgriLife.JournalModule:save(xmlFile, key, farmId) return self.service:saveFarm(xmlFile, key, farmId) end
function AgriLife.JournalModule:stop() self.started = false; return AgriLife.Result.ok("JOURNAL_STOPPED", "Journal stopped") end
function AgriLife.JournalModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("JOURNAL_DELETED", "Journal deleted") end
function AgriLife.JournalModule:record(...) return self.service:record(...) end
function AgriLife.JournalModule:getSnapshot(...) return self.service:getSnapshot(...) end
function AgriLife.JournalModule.getDescriptor()
    return {id = AgriLife.JournalModule.ID, version = AgriLife.JournalModule.VERSION, schemaVersion = 1, dependencies = {"economy"}, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.JournalModule.new(core) end}
end
function AgriLife.JournalModule.register(registry) return registry:register(AgriLife.JournalModule.getDescriptor()) end
