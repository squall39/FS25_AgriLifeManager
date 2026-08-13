-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.CommercialContracts6Service ~= nil then
    local Contracts = AgriLife.CommercialContracts6Service

    local function num(value, fallback)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return fallback or 0 end
        return value
    end

    local function integer(value, fallback)
        return math.floor(num(value, fallback or 0))
    end

    local function clamp(value, minimum, maximum)
        value = num(value, minimum)
        if value < minimum then return minimum end
        if value > maximum then return maximum end
        return value
    end

    local function round(value)
        return math.floor(num(value, 0) * 100 + 0.5) / 100
    end

    function Contracts:findBestActiveInterFarmOffer(actorFarmId, predicate)
        local matches = {}
        for _, state in pairs(self.farms or {}) do
            for _, offer in ipairs(state.interFarmOffers or {}) do
                if offer.status == "active" and integer(offer.contractorFarmId, 0) == integer(actorFarmId, 0) and (predicate == nil or predicate(offer)) then
                    table.insert(matches, offer)
                end
            end
        end
        table.sort(matches, function(a, b)
            if integer(a.duePeriodKey, 0) == integer(b.duePeriodKey, 0) then return tostring(a.id) < tostring(b.id) end
            return integer(a.duePeriodKey, 0) < integer(b.duePeriodKey, 0)
        end)
        return matches[1]
    end

    function Contracts:recordInterFarmVehicleWork(actorFarmId, fieldId, hectares, hours, harvestedLiters, fillTypeIndex)
        actorFarmId = integer(actorFarmId, 0)
        fieldId = integer(fieldId, 0)
        if actorFarmId <= 0 then return 0 end
        local offer = self:findBestActiveInterFarmOffer(actorFarmId, function(row)
            local fieldMatches = integer(row.fieldId, 0) <= 0 or integer(row.fieldId, 0) == fieldId
            local fillMatches = integer(row.fillTypeIndex, 0) <= 0 or integer(fillTypeIndex, 0) <= 0 or integer(row.fillTypeIndex, 0) == integer(fillTypeIndex, 0)
            local kind = tostring(row.contractType or "")
            return fieldMatches and fillMatches and (kind == "field_work" or kind == "harvest_help" or kind == "service")
        end)
        if offer == nil then return 0 end
        self:recordInterFarmProgress(offer.id, {hectares = hectares, hours = hours, harvestedLiters = harvestedLiters}, actorFarmId)
        return 1
    end

    function Contracts:recordInterFarmTransportWork(actorFarmId, deliveredQuantity, hours)
        actorFarmId = integer(actorFarmId, 0)
        if actorFarmId <= 0 then return 0 end
        local offer = self:findBestActiveInterFarmOffer(actorFarmId, function(row) return tostring(row.contractType or "") == "transport" end)
        if offer == nil then return 0 end
        self:recordInterFarmProgress(offer.id, {quantity = math.max(0, num(deliveredQuantity, 0)), hours = math.max(0, num(hours, 0))}, actorFarmId)
        return 1
    end

    function Contracts:processInterFarmRuntime(periodKey)
        periodKey = integer(periodKey, self:getPeriodKey())
        for _, state in pairs(self.farms or {}) do
            for _, offer in ipairs(state.interFarmOffers or {}) do
                if offer.status == "active" then
                    if offer.contractType == "equipment_rental" then
                        local rental = self:getInterFarmRentalState(offer)
                        if rental.transferred ~= true then self:activateEquipmentRental(offer) end
                        if periodKey > integer(offer.duePeriodKey, periodKey) and rental.returned ~= true then self:finishEquipmentRental(offer, true) end
                    end
                    if offer.physicalSettlementPending == true then
                        local ok = self:completeInterFarmPhysicalSettlement(offer)
                        if ok and num(offer.productEntitlementLiters, 0) > num(offer.productTransferredLiters, 0) then ok = select(1, self:settleInterFarmProductEntitlement(offer)) end
                        if ok then offer.physicalSettlementPending = false; offer.physicalSettlementError = "" end
                    end
                elseif (offer.status == "completed" or offer.status == "failed") and offer.physicalSettlementPending == true then
                    local ok = self:completeInterFarmPhysicalSettlement(offer)
                    if ok and offer.status == "completed" and num(offer.productEntitlementLiters, 0) > num(offer.productTransferredLiters, 0) then ok = select(1, self:settleInterFarmProductEntitlement(offer)) end
                    if ok then offer.physicalSettlementPending = false; offer.physicalSettlementError = "" end
                end
            end
        end
    end

    local baseAccept = Contracts.acceptInterFarmOffer
    function Contracts:acceptInterFarmOffer(contractorFarmId, actorProfileId, contractId)
        local result = baseAccept(self, contractorFarmId, actorProfileId, contractId)
        if result ~= nil and result.ok and result.details ~= nil and result.details.offer ~= nil and result.details.offer.contractType == "equipment_rental" then
            local ok, reason = self:activateEquipmentRental(result.details.offer)
            if not ok then
                result.details.offer.status = "open"
                result.details.offer.contractorFarmId = 0
                result.details.offer.contractorFarmName = ""
                result.details.offer.contractorProfileId = ""
                result.details.offer.accessGranted = false
                return AgriLife.Result.fail("INTERFARM_RENTAL_ACTIVATION_FAILED", "Location impossible", {reason = reason, contractId = contractId})
            end
        end
        return result
    end

    function Contracts:captureInterFarmPhysicalState(offer)
        return {
            assetTransferred = offer ~= nil and offer.assetTransferred == true,
            balesTransferred = integer(offer ~= nil and offer.balesTransferred, 0),
            saleProductTransferredLiters = round(num(offer ~= nil and offer.saleProductTransferredLiters, 0)),
            productTransferredLiters = round(num(offer ~= nil and offer.productTransferredLiters, 0)),
            settlementPaid = round(num(offer ~= nil and offer.settlementPaid, 0))
        }
    end

    function Contracts:rollbackInterFarmPhysicalSettlement(offer, before)
        if offer == nil or before == nil then return true end
        if tostring(offer.contractType or "") == "asset_sale" and offer.assetTransferred == true and before.assetTransferred ~= true then
            local ok = self:transferInterFarmVehicle(offer.assetId, offer.contractorFarmId, offer.sourceFarmId)
            if not ok then return false end
            offer.assetTransferred = false
        elseif tostring(offer.contractType or "") == "bale_sale" then
            local delta = math.max(0, integer(offer.balesTransferred, 0) - integer(before.balesTransferred, 0))
            if delta > 0 then
                local ok, count = self:transferInterFarmBales(offer.contractorFarmId, offer.sourceFarmId, delta)
                if not ok or count < delta then return false end
                offer.balesTransferred = integer(before.balesTransferred, 0)
            end
        elseif tostring(offer.contractType or "") == "crop_sale" then
            local delta = round(math.max(0, num(offer.saleProductTransferredLiters, 0) - num(before.saleProductTransferredLiters, 0)))
            if delta > 0 then
                local ok, transferred = self:transferInterFarmProduct(offer.contractorFarmId, offer.sourceFarmId, offer.fillTypeIndex, delta, offer.id .. ":rollback")
                if not ok or transferred + 0.01 < delta then return false end
                offer.saleProductTransferredLiters = round(num(before.saleProductTransferredLiters, 0))
            end
        end
        return true
    end

    local baseComplete = Contracts.completeInterFarmContract
    function Contracts:completeInterFarmContract(contractId, actorFarmId)
        local offer = self:findInterFarmOffer(contractId)
        if offer == nil then return baseComplete(self, contractId, actorFarmId) end
        local sellerPhysical = self:isInterFarmSellerContract(offer) and tostring(offer.contractType or "") ~= "equipment_rental"
        local before = self:captureInterFarmPhysicalState(offer)

        if sellerPhysical then
            local ok, reason = self:completeInterFarmPhysicalSettlement(offer)
            if not ok then
                offer.physicalSettlementPending = true
                offer.physicalSettlementError = tostring(reason or "physical settlement pending")
                return AgriLife.Result.fail("INTERFARM_PHYSICAL_SETTLEMENT_PENDING", "Transfert physique inter-fermes indisponible", {contractId = offer.id, reason = offer.physicalSettlementError})
            end
        elseif tostring(offer.contractType or "") == "equipment_rental" then
            local ok, _, reason = self:finishEquipmentRental(offer, false)
            if not ok then
                return AgriLife.Result.fail("INTERFARM_RENTAL_RETURN_PENDING", "Retour de location indisponible", {contractId = offer.id, reason = tostring(reason or "return unavailable")})
            end
        end

        local result = baseComplete(self, contractId, actorFarmId)
        if result == nil or result.ok ~= true then
            if sellerPhysical then self:rollbackInterFarmPhysicalSettlement(offer, before) end
            local extraPaid = round(math.max(0, num(offer.settlementPaid, 0) - num(before.settlementPaid, 0)))
            if extraPaid > 0 then
                local payerFarmId, payeeFarmId = self:getInterFarmPaymentDirection(offer)
                local refunded = self:transferFarmMoney(payeeFarmId, payerFarmId, extraPaid, offer.id .. ":payment_rollback")
                if refunded then offer.settlementPaid = before.settlementPaid end
            end
            return result
        end

        offer.physicalSettlementPending = false
        offer.physicalSettlementError = ""
        if tostring(offer.contractType or "") ~= "equipment_rental" and num(offer.productEntitlementLiters, 0) > num(offer.productTransferredLiters, 0) then
            local ok, _, reason = self:settleInterFarmProductEntitlement(offer)
            if not ok then
                offer.physicalSettlementPending = true
                offer.physicalSettlementError = tostring(reason or "product settlement pending")
                result.details = result.details or {}
                result.details.physicalSettlementPending = true
                result.details.physicalSettlementError = offer.physicalSettlementError
            end
        end
        return result
    end

    local baseFail = Contracts.failInterFarmContract
    function Contracts:failInterFarmContract(contractId, reason, currentPeriodKey, actorFarmId)
        local offer = self:findInterFarmOffer(contractId)
        if offer ~= nil and offer.contractType == "equipment_rental" then
            local returned, _, returnReason = self:finishEquipmentRental(offer, true)
            if not returned then
                offer.physicalSettlementPending = true
                offer.physicalSettlementError = tostring(returnReason or "rental return pending")
            end
        end
        return baseFail(self, contractId, reason, currentPeriodKey, actorFarmId)
    end

    local baseProcess = Contracts.processInterFarmContracts
    function Contracts:processInterFarmContracts(periodKey)
        baseProcess(self, periodKey)
        self:processInterFarmRuntime(periodKey)
    end

    local baseSave = Contracts.saveFarm
    function Contracts:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSave(self, xmlFile, moduleKey, farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        local state = self:ensureInterFarmState(farmId)
        for index, offer in ipairs(state.interFarmOffers or {}) do
            local key = string.format("%s.interFarm.offers.offer(%d)", moduleKey, index - 1)
            xmlFile:setFloat(key .. "#productTransferredLiters", num(offer.productTransferredLiters, 0))
            xmlFile:setFloat(key .. "#saleProductTransferredLiters", num(offer.saleProductTransferredLiters, 0))
            xmlFile:setInt(key .. "#balesTransferred", integer(offer.balesTransferred, 0))
            xmlFile:setBool(key .. "#assetTransferred", offer.assetTransferred == true)
            xmlFile:setBool(key .. "#physicalSettlementPending", offer.physicalSettlementPending == true)
            xmlFile:setString(key .. "#physicalSettlementError", tostring(offer.physicalSettlementError or ""))
            local rental = offer.rental
            if rental ~= nil then
                local r = key .. ".rental"
                xmlFile:setInt(r .. "#originalOwnerFarmId", integer(rental.originalOwnerFarmId, 0))
                xmlFile:setInt(r .. "#currentHolderFarmId", integer(rental.currentHolderFarmId, 0))
                xmlFile:setInt(r .. "#checkoutPeriodKey", integer(rental.checkoutPeriodKey, 0))
                xmlFile:setInt(r .. "#returnPeriodKey", integer(rental.returnPeriodKey, 0))
                xmlFile:setFloat(r .. "#checkoutDamage", num(rental.checkoutDamage, 0))
                xmlFile:setFloat(r .. "#returnDamage", num(rental.returnDamage, 0))
                xmlFile:setFloat(r .. "#damageCharge", num(rental.damageCharge, 0))
                xmlFile:setFloat(r .. "#lateCharge", num(rental.lateCharge, 0))
                xmlFile:setBool(r .. "#transferred", rental.transferred == true)
                xmlFile:setBool(r .. "#returned", rental.returned == true)
                xmlFile:setBool(r .. "#forcedReturn", rental.forcedReturn == true)
            end
        end
        return result
    end

    local baseLoad = Contracts.loadFarm
    function Contracts:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoad(self, xmlFile, moduleKey, farmId)
        local state = self:ensureInterFarmState(farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        for index, offer in ipairs(state.interFarmOffers or {}) do
            local key = string.format("%s.interFarm.offers.offer(%d)", moduleKey, index - 1)
            offer.productTransferredLiters = xmlFile:getFloat(key .. "#productTransferredLiters", 0)
            offer.saleProductTransferredLiters = xmlFile:getFloat(key .. "#saleProductTransferredLiters", 0)
            offer.balesTransferred = xmlFile:getInt(key .. "#balesTransferred", 0)
            offer.assetTransferred = xmlFile:getBool(key .. "#assetTransferred", false)
            offer.physicalSettlementPending = xmlFile:getBool(key .. "#physicalSettlementPending", false)
            offer.physicalSettlementError = xmlFile:getString(key .. "#physicalSettlementError", "")
            if offer.contractType == "equipment_rental" then
                local r = key .. ".rental"
                offer.rental = {
                    originalOwnerFarmId = xmlFile:getInt(r .. "#originalOwnerFarmId", offer.sourceFarmId),
                    currentHolderFarmId = xmlFile:getInt(r .. "#currentHolderFarmId", offer.sourceFarmId),
                    checkoutPeriodKey = xmlFile:getInt(r .. "#checkoutPeriodKey", 0),
                    returnPeriodKey = xmlFile:getInt(r .. "#returnPeriodKey", offer.duePeriodKey),
                    checkoutDamage = xmlFile:getFloat(r .. "#checkoutDamage", 0),
                    returnDamage = xmlFile:getFloat(r .. "#returnDamage", 0),
                    damageCharge = xmlFile:getFloat(r .. "#damageCharge", 0),
                    lateCharge = xmlFile:getFloat(r .. "#lateCharge", 0),
                    transferred = xmlFile:getBool(r .. "#transferred", false),
                    returned = xmlFile:getBool(r .. "#returned", false),
                    forcedReturn = xmlFile:getBool(r .. "#forcedReturn", false)
                }
            end
        end
        return result
    end
end

if AgriLife.CommercialContractsModule ~= nil then
    function AgriLife.CommercialContractsModule:recordInterFarmVehicleWork(...) return self.service:recordInterFarmVehicleWork(...) end
    function AgriLife.CommercialContractsModule:recordInterFarmTransportWork(...) return self.service:recordInterFarmTransportWork(...) end
    function AgriLife.CommercialContractsModule:transferInterFarmProduct(...) return self.service:transferInterFarmProduct(...) end
    function AgriLife.CommercialContractsModule:transferInterFarmVehicle(...) return self.service:transferInterFarmVehicle(...) end
end
