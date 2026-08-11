-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 7: dynamic new/used equipment and rental market.
AgriLife = AgriLife or {}

if AgriLife.AssetLifecycle6Service ~= nil then
    local Assets = AgriLife.AssetLifecycle6Service
    Assets.ROADMAP7_VERSION = "0.7.9.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function round(value)
        return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
    end

    local function hashText(value)
        local text = tostring(value or "")
        local hash = 0
        for index = 1, #text do hash = (hash * 33 + string.byte(text, index) * index) % 2147483647 end
        return hash
    end

    local baseCreateDefaultState = Assets.createDefaultState
    function Assets:createDefaultState()
        local state = baseCreateDefaultState(self)
        state.newEquipmentOrders = {}
        return state
    end

    local baseSanitize = Assets.sanitize
    function Assets:sanitize(state)
        state = baseSanitize(self, state)
        state.newEquipmentOrders = state.newEquipmentOrders or {}
        return state
    end

    function Assets:getNewEquipmentAvailability(farmId, xmlFilename)
        local periodKey = self:getPeriodKey()
        local market = self:getDynamicMarket()
        local multiplier = market ~= nil and market.getAssetMultiplier ~= nil and market:getAssetMultiplier(farmId, false) or 1
        local seed = hashText(xmlFilename) + periodKey * 977 + (tonumber(farmId) or 0) * 131
        local pressure = clamp((multiplier - 0.70) / 0.75, 0, 1)
        local roll = (seed % 1000) / 1000
        local available = roll > (0.05 + pressure * 0.12)
        local delay = available and (1 + ((math.floor(seed / 17) + math.floor(pressure * 10)) % 3)) or (3 + (seed % 3))
        local stock = available and (1 + (math.floor(seed / 41) % 4)) or 0
        return {available = available, deliveryDelayMonths = delay, stock = stock, pressure = round(pressure), nextReviewPeriodKey = periodKey + 1}
    end

    local baseGetNewOffers = Assets.getNewOffers
    function Assets:getNewOffers(farmId, limit)
        local rows = baseGetNewOffers(self, farmId, limit)
        for _, row in ipairs(rows or {}) do
            local availability = self:getNewEquipmentAvailability(farmId, row.xmlFilename)
            row.available = availability.available
            row.deliveryDelayMonths = availability.deliveryDelayMonths
            row.stock = availability.stock
            row.marketPressure = availability.pressure
            row.nextReviewPeriodKey = availability.nextReviewPeriodKey
        end
        table.sort(rows, function(a, b)
            if a.available ~= b.available then return a.available == true end
            if (a.deliveryDelayMonths or 99) ~= (b.deliveryDelayMonths or 99) then return (a.deliveryDelayMonths or 99) < (b.deliveryDelayMonths or 99) end
            return (a.marketPrice or 0) < (b.marketPrice or 0)
        end)
        return rows
    end

    local function getPendingOrder(state, orderId)
        for _, order in ipairs(state.newEquipmentOrders or {}) do
            if tostring(order.id) == tostring(orderId) then return order end
        end
        return nil
    end

    function Assets:deliverNewEquipmentOrder(farmId, order)
        if order == nil or order.status ~= "pending" then return false end
        local spawned, spawnError = self:spawnAsset(farmId, order.xmlFilename, order.assetId, 1, 0)
        if not spawned then
            order.deliveryAttempts = (order.deliveryAttempts or 0) + 1
            order.lastDeliveryError = tostring(spawnError or "unknown")
            order.duePeriodKey = self:getPeriodKey() + 1
            return false
        end
        order.status = "delivered"
        order.deliveredPeriodKey = self:getPeriodKey()
        local state = self:getState(farmId, true)
        local purchase = {
            id = order.id, offerId = "", sourceType = "new", assetId = order.assetId,
            name = order.name, xmlFilename = order.xmlFilename, price = order.price,
            newValue = order.referenceValue, ageYears = 0, hours = 0, kilometers = 0,
            serviceScore = 1, accidentCount = 0, risk = 0, marketMultiplier = order.marketMultiplier,
            purchasedPeriodKey = order.createdPeriodKey, deliveredPeriodKey = order.deliveredPeriodKey
        }
        table.insert(state.purchases, purchase)
        self:registerWorkshopAsset(farmId, purchase.assetId, purchase.name, purchase.price, 0, 1, 0)
        return true
    end

    -- Step 7 owns the new-equipment purchase pathway so availability and delivery delay
    -- are real gameplay constraints rather than decorative market data.
    function Assets:purchaseNew(farmId, xmlFilename)
        if self.core == nil or self.core.context == nil or not self.core.context.isServer then return AgriLife.Result.fail("ASSET_SERVER_REQUIRED", "Server authority required") end
        if self.core.isFarmActivated ~= nil and not self.core:isFarmActivated(farmId) then return AgriLife.Result.fail("ASSET_ONBOARDING_REQUIRED", "AgriLife activation is required before purchasing equipment") end
        local economy = self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local insurance = economy ~= nil and economy.requireInsurance ~= nil and economy:requireInsurance(farmId, "vehicle") or nil
        if insurance ~= nil and not insurance.ok then return insurance end
        local item = self:findStoreCandidate(xmlFilename)
        if item == nil then return AgriLife.Result.fail("ASSET_NEW_ITEM_NOT_FOUND", "Store item not found") end
        local availability = self:getNewEquipmentAvailability(farmId, xmlFilename)
        if not availability.available then return AgriLife.Result.fail("ASSET_NEW_TEMPORARILY_UNAVAILABLE", "Equipment is temporarily unavailable", availability) end
        local market = self:getDynamicMarket()
        local multiplier = market ~= nil and market.getAssetMultiplier ~= nil and market:getAssetMultiplier(farmId, false) or 1
        local price = round(math.max(0, tonumber(item.base) or 0) * multiplier)
        local farm = self:getFarm(farmId)
        if farm == nil or (tonumber(farm.money) or 0) + 0.01 < price then return AgriLife.Result.fail("ASSET_NEW_FUNDS_LOW", "Insufficient funds for new equipment", {price = price}) end
        if not self:addMoney(farmId, -price) then return AgriLife.Result.fail("ASSET_NEW_DEBIT_FAILED", "Equipment payment failed") end
        local state = self:getState(farmId, true)
        local purchaseId = string.format("NEW_%d_%05d", farmId, state.nextPurchaseId)
        state.nextPurchaseId = state.nextPurchaseId + 1
        local order = {
            id = purchaseId, assetId = "ALM_" .. purchaseId,
            name = (tostring(item.brand or "") .. " " .. tostring(item.model or "")):gsub("^%s+", ""),
            xmlFilename = item.xmlFilename, price = price, referenceValue = tonumber(item.base) or price,
            marketMultiplier = multiplier, status = "pending", createdPeriodKey = self:getPeriodKey(),
            duePeriodKey = self:getPeriodKey() + math.max(1, availability.deliveryDelayMonths or 1),
            deliveryDelayMonths = math.max(1, availability.deliveryDelayMonths or 1), deliveryAttempts = 0
        }
        table.insert(state.newEquipmentOrders, order)
        state.totalNewSpent = round((state.totalNewSpent or 0) + price)
        self:recordEconomy(farmId, "NEW_PURCHASE_ORDER", -price, order.id)
        return AgriLife.Result.ok("ASSET_NEW_ORDERED", "New equipment ordered", order)
    end

    local baseProcessPeriod = Assets.processPeriod
    function Assets:processPeriod(farmId, periodKey)
        baseProcessPeriod(self, farmId, periodKey)
        local state = self:getState(farmId, true)
        for _, order in ipairs(state.newEquipmentOrders or {}) do
            if order.status == "pending" and periodKey >= (tonumber(order.duePeriodKey) or periodKey) then self:deliverNewEquipmentOrder(farmId, order) end
        end
    end

    function Assets:getRentalMarketPolicy(farmId)
        local market = self:getDynamicMarket()
        local multiplier = market ~= nil and market.getRentalMultiplier ~= nil and market:getRentalMultiplier(farmId) or 1
        local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local snapshot = economy ~= nil and economy.getSnapshot ~= nil and economy:getSnapshot(farmId) or nil
        local modeId = snapshot ~= nil and snapshot.modeId or "normal"
        return {
            modeId = modeId,
            marketMultiplier = multiplier,
            maxTermMonths = modeId == "facile" and 12 or (modeId == "difficile" and 6 or 9),
            damagePenaltyFactor = modeId == "facile" and 0.08 or (modeId == "difficile" and 0.18 or 0.12),
            latePenaltyRate = modeId == "facile" and 0.03 or (modeId == "difficile" and 0.09 or 0.05)
        }
    end

    local baseQuoteRental = Assets.quoteRental
    function Assets:quoteRental(farmId, xmlFilename, termMonths)
        local policy = self:getRentalMarketPolicy(farmId)
        termMonths = math.floor(tonumber(termMonths) or 1)
        if termMonths > policy.maxTermMonths then return AgriLife.Result.fail("ASSET_RENTAL_TERM_POLICY", "Rental term exceeds difficulty policy", {maxTermMonths = policy.maxTermMonths}) end
        local result = baseQuoteRental(self, farmId, xmlFilename, termMonths)
        if result ~= nil and result.ok and result.details ~= nil then
            result.details.maxTermMonths = policy.maxTermMonths
            result.details.damagePenaltyFactor = policy.damagePenaltyFactor
            result.details.latePenaltyRate = policy.latePenaltyRate
        end
        return result
    end

    local baseGetSnapshot = Assets.getSnapshot
    function Assets:getSnapshot(farmId)
        local snapshot = baseGetSnapshot(self, farmId)
        local state = self:getState(farmId, true)
        local pending, delivered, failedAttempts = 0, 0, 0
        for _, order in ipairs(state.newEquipmentOrders or {}) do
            if order.status == "pending" then pending = pending + 1 elseif order.status == "delivered" then delivered = delivered + 1 end
            failedAttempts = failedAttempts + (tonumber(order.deliveryAttempts) or 0)
        end
        snapshot.newEquipmentOrders = state.newEquipmentOrders
        snapshot.pendingNewDeliveries = pending
        snapshot.deliveredNewOrders = delivered
        snapshot.failedDeliveryAttempts = failedAttempts
        snapshot.newOffers = self:getNewOffers(farmId, 24)
        snapshot.rentalMarketPolicy = self:getRentalMarketPolicy(farmId)
        return snapshot
    end

    local baseSaveFarm = Assets.saveFarm
    function Assets:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getState(farmId, true)
        for index, order in ipairs(state.newEquipmentOrders or {}) do
            local key = string.format("%s.roadmap7.newOrders.order(%d)", moduleKey, index - 1)
            for _, name in ipairs({"id", "assetId", "name", "xmlFilename", "status", "lastDeliveryError"}) do xmlFile:setString(key .. "#" .. name, tostring(order[name] or "")) end
            for _, name in ipairs({"price", "referenceValue", "marketMultiplier"}) do xmlFile:setFloat(key .. "#" .. name, tonumber(order[name]) or 0) end
            for _, name in ipairs({"createdPeriodKey", "duePeriodKey", "deliveredPeriodKey", "deliveryDelayMonths", "deliveryAttempts"}) do xmlFile:setInt(key .. "#" .. name, math.floor(tonumber(order[name]) or 0)) end
        end
        return result
    end

    local baseLoadFarm = Assets.loadFarm
    function Assets:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadFarm(self, xmlFile, moduleKey, farmId)
        if result == nil or not result.ok or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getState(farmId, true)
        state.newEquipmentOrders = {}
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".roadmap7.newOrders.order", function(_, key)
                local order = {}
                for _, name in ipairs({"id", "assetId", "name", "xmlFilename", "status", "lastDeliveryError"}) do order[name] = xmlFile:getString(key .. "#" .. name, "") end
                for _, name in ipairs({"price", "referenceValue", "marketMultiplier"}) do order[name] = xmlFile:getFloat(key .. "#" .. name, 0) end
                for _, name in ipairs({"createdPeriodKey", "duePeriodKey", "deliveredPeriodKey", "deliveryDelayMonths", "deliveryAttempts"}) do order[name] = xmlFile:getInt(key .. "#" .. name, 0) end
                if order.id ~= "" then table.insert(state.newEquipmentOrders, order) end
            end)
        end
        return result
    end

    function Assets:getRoadmap7Checklist(farmId)
        return {
            dynamicNewMarket = type(self.getNewEquipmentAvailability) == "function",
            realAvailability = type(self.getNewOffers) == "function",
            deliveryDelay = type(self.deliverNewEquipmentOrder) == "function",
            usedMarket = type(self.purchaseUsed) == "function" and type(self.inspectOffer) == "function",
            shortRental = type(self.createRental) == "function" and type(self.returnRental) == "function",
            rentalConsequences = type(self.getRentalMarketPolicy) == "function",
            persistence = type(self.saveFarm) == "function" and type(self.loadFarm) == "function",
            inGameCertification = false
        }
    end
end

if AgriLife.AssetLifecycleModule ~= nil then
    AgriLife.AssetLifecycleModule.VERSION = "0.7.9.0"
    AgriLife.AssetLifecycleModule.SCHEMA_VERSION = 2
    function AgriLife.AssetLifecycleModule:getRoadmap7Checklist(...) return self.service:getRoadmap7Checklist(...) end
    local baseDescriptor = AgriLife.AssetLifecycleModule.getDescriptor
    function AgriLife.AssetLifecycleModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.7.9.0"
        descriptor.schemaVersion = 2
        return descriptor
    end
end
