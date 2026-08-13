-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}
AgriLife.QualificationsModule = {}; AgriLife.QualificationsModule.__index = AgriLife.QualificationsModule
AgriLife.QualificationsModule.ID = "qualifications"; AgriLife.QualificationsModule.VERSION = "0.7.7.0"; AgriLife.QualificationsModule.SCHEMA_VERSION = 2
function AgriLife.QualificationsModule.new(core) return setmetatable({core = core, service = AgriLife.Qualifications6Service.new(core), started = false}, AgriLife.QualificationsModule) end
function AgriLife.QualificationsModule:create() return AgriLife.Result.ok("QUALIFICATIONS_CREATED", "Qualifications created") end
function AgriLife.QualificationsModule:load(xmlFile, key, farmId) return self.service:loadFarm(xmlFile, key, farmId) end
function AgriLife.QualificationsModule:start() self.started = true; return AgriLife.Result.ok("QUALIFICATIONS_STARTED", "Qualifications started") end
function AgriLife.QualificationsModule:save(xmlFile, key, farmId) return self.service:saveFarm(xmlFile, key, farmId) end
function AgriLife.QualificationsModule:stop() self.started = false; return AgriLife.Result.ok("QUALIFICATIONS_STOPPED", "Qualifications stopped") end
function AgriLife.QualificationsModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("QUALIFICATIONS_DELETED", "Qualifications deleted") end
function AgriLife.QualificationsModule:getSnapshot(...) return self.service:getSnapshot(...) end
function AgriLife.QualificationsModule:hasQualification(...) return self.service:hasQualification(...) end
function AgriLife.QualificationsModule:completeTraining(...) return self.service:completeTraining(...) end
function AgriLife.QualificationsModule.getDescriptor() return {id = "qualifications", version = AgriLife.QualificationsModule.VERSION, schemaVersion = AgriLife.QualificationsModule.SCHEMA_VERSION, dependencies = {"economy", "career", "exams", "journal"}, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.QualificationsModule.new(core) end} end
function AgriLife.QualificationsModule.register(registry) return registry:register(AgriLife.QualificationsModule.getDescriptor()) end
