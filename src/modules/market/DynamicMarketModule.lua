-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}
AgriLife.DynamicMarketModule = {}; AgriLife.DynamicMarketModule.__index = AgriLife.DynamicMarketModule
AgriLife.DynamicMarketModule.ID = "market"; AgriLife.DynamicMarketModule.VERSION = "0.7.0.0"; AgriLife.DynamicMarketModule.SCHEMA_VERSION = 1
function AgriLife.DynamicMarketModule.new(core) return setmetatable({core = core, service = AgriLife.DynamicMarket6Service.new(core), started = false}, AgriLife.DynamicMarketModule) end
function AgriLife.DynamicMarketModule:create() return AgriLife.Result.ok("MARKET_CREATED", "Dynamic market created") end
function AgriLife.DynamicMarketModule:load(xmlFile, key, farmId) return self.service:loadFarm(xmlFile, key, farmId) end
function AgriLife.DynamicMarketModule:start() if self.started then return AgriLife.Result.ok("MARKET_ALREADY_STARTED", "Dynamic market already started") end; self.service:discoverRuntimeContent(true); if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer and MessageType ~= nil and MessageType.PERIOD_CHANGED ~= nil then local result = self.core.subscriptions:subscribe(self.ID, MessageType.PERIOD_CHANGED, self.service, self.service.onPeriodChanged); if not result.ok then return result end end; self.started = true; return AgriLife.Result.ok("MARKET_STARTED", "Dynamic market started") end
function AgriLife.DynamicMarketModule:save(xmlFile, key, farmId) return self.service:saveFarm(xmlFile, key, farmId) end
function AgriLife.DynamicMarketModule:stop() if self.core ~= nil and self.core.subscriptions ~= nil then self.core.subscriptions:unsubscribeOwner(self.ID) end; self.started = false; return AgriLife.Result.ok("MARKET_STOPPED", "Dynamic market stopped") end
function AgriLife.DynamicMarketModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("MARKET_DELETED", "Dynamic market deleted") end
function AgriLife.DynamicMarketModule:getSnapshot(...) return self.service:getSnapshot(...) end
function AgriLife.DynamicMarketModule:getContractMultiplier(...) return self.service:getContractMultiplier(...) end
function AgriLife.DynamicMarketModule:getAssetMultiplier(...) return self.service:getAssetMultiplier(...) end
function AgriLife.DynamicMarketModule:getLandMultiplier(...) return self.service:getLandMultiplier(...) end
function AgriLife.DynamicMarketModule:getFuelMultiplier(...) return self.service:getFuelMultiplier(...) end
function AgriLife.DynamicMarketModule:getRentalMultiplier(...) return self.service:getRentalMultiplier(...) end
function AgriLife.DynamicMarketModule:getInputMultiplier(...) return self.service:getInputMultiplier(...) end
function AgriLife.DynamicMarketModule.getDescriptor() return {id = "market", version = "0.7.0.0", schemaVersion = 1, dependencies = {"economy", "commercialContracts", "journal"}, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.DynamicMarketModule.new(core) end} end
function AgriLife.DynamicMarketModule.register(registry) return registry:register(AgriLife.DynamicMarketModule.getDescriptor()) end
function AgriLife.DynamicMarketModule:getDemandMultiplier(...) return self.service:getDemandMultiplier(...) end
function AgriLife.DynamicMarketModule:getFillTypeMultiplier(...) return self.service:getFillTypeMultiplier(...) end
function AgriLife.DynamicMarketModule:getStoreMarketRows(...) return self.service:getStoreMarketRows(...) end
function AgriLife.DynamicMarketModule:getFarmlandMarketRows(...) return self.service:getFarmlandMarketRows(...) end
function AgriLife.DynamicMarketModule:getProductionMarketRows(...) return self.service:getProductionMarketRows(...) end
function AgriLife.DynamicMarketModule:getFillTypeQuote(...) return self.service:getFillTypeQuote(...) end
function AgriLife.DynamicMarketModule:getCostQuote(...) return self.service:getCostQuote(...) end
function AgriLife.DynamicMarketModule:getAgronomyAdjustment(...) return self.service:getAgronomyAdjustment(...) end

function AgriLife.DynamicMarketModule:quoteFarmlandRental(...) return self.service:quoteFarmlandRental(...) end
function AgriLife.DynamicMarketModule:createFarmlandRental(...) return self.service:createFarmlandRental(...) end
function AgriLife.DynamicMarketModule:quoteProductionRental(...) return self.service:quoteProductionRental(...) end
function AgriLife.DynamicMarketModule:createProductionRental(...) return self.service:createProductionRental(...) end
function AgriLife.DynamicMarketModule:terminateMarketRental(...) return self.service:terminateMarketRental(...) end
