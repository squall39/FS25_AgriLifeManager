-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}
AgriLife.AdministrationModule = {}; AgriLife.AdministrationModule.__index = AgriLife.AdministrationModule
AgriLife.AdministrationModule.ID = "administration"; AgriLife.AdministrationModule.VERSION = "0.7.8.0"; AgriLife.AdministrationModule.SCHEMA_VERSION = 2
function AgriLife.AdministrationModule.new(core) return setmetatable({core = core, service = AgriLife.Administration6Service.new(core), started = false}, AgriLife.AdministrationModule) end
function AgriLife.AdministrationModule:create() return AgriLife.Result.ok("ADMIN_CREATED", "Administration created") end
function AgriLife.AdministrationModule:load(xmlFile, key, farmId) return self.service:loadFarm(xmlFile, key, farmId) end
function AgriLife.AdministrationModule:start() if self.started then return AgriLife.Result.ok("ADMIN_ALREADY_STARTED", "Administration already started") end; if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer and MessageType ~= nil and MessageType.PERIOD_CHANGED ~= nil then local result = self.core.subscriptions:subscribe(self.ID, MessageType.PERIOD_CHANGED, self.service, self.service.onPeriodChanged); if not result.ok then return result end end; self.started = true; return AgriLife.Result.ok("ADMIN_STARTED", "Administration started") end
function AgriLife.AdministrationModule:save(xmlFile, key, farmId) return self.service:saveFarm(xmlFile, key, farmId) end
function AgriLife.AdministrationModule:stop() if self.core ~= nil and self.core.subscriptions ~= nil then self.core.subscriptions:unsubscribeOwner(self.ID) end; self.started = false; return AgriLife.Result.ok("ADMIN_STOPPED", "Administration stopped") end
function AgriLife.AdministrationModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("ADMIN_DELETED", "Administration deleted") end
function AgriLife.AdministrationModule:getSnapshot(...) return self.service:getSnapshot(...) end
function AgriLife.AdministrationModule:runControl(...) return self.service:runControl(...) end
function AgriLife.AdministrationModule:paySanction(...) return self.service:paySanction(...) end
function AgriLife.AdministrationModule:registerUnpaidPersonalSanction(...) return self.service:registerUnpaidPersonalSanction(...) end
function AgriLife.AdministrationModule:createManagementEvent(...) return self.service:createManagementEvent(...) end
function AgriLife.AdministrationModule:resolveEvent(...) return self.service:resolveEvent(...) end
function AgriLife.AdministrationModule.getDescriptor() return {id = "administration", version = AgriLife.AdministrationModule.VERSION, schemaVersion = AgriLife.AdministrationModule.SCHEMA_VERSION, dependencies = {"economy", "company", "legal", "insurance", "enterprise", "qualifications", "journal"}, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.AdministrationModule.new(core) end} end
function AgriLife.AdministrationModule.register(registry) return registry:register(AgriLife.AdministrationModule.getDescriptor()) end
