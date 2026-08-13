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

    function Contracts:getInterFarmRentalState(offer)
        if offer == nil then return nil end
        offer.rental = offer.rental or {
            originalOwnerFarmId = tonumber(offer.sourceFarmId) or 0,
            currentHolderFarmId = tonumber(offer.sourceFarmId) or 0,
            checkoutPeriodKey = 0,
            returnPeriodKey = tonumber(offer.duePeriodKey) or 0,
            checkoutDamage = 0,
            returnDamage = 0,
            damageCharge = 0,
            lateCharge = 0,
            transferred = false,
            returned = false
        }
        return offer.rental
    end

    function Contracts:getVehicleDamageMetric(vehicle)
        if vehicle == nil then return 0 end
        local values = {}
        for _, methodName in ipairs({"getDamageAmount", "getDamage", "getWearTotalAmount"}) do
            local method = vehicle[methodName]
            if method ~= nil then
                local ok, value = pcall(method, vehicle)
                if ok and tonumber(value) ~= nil then table.insert(values, tonumber(value)) end
            end
        end
        if vehicle.spec_wearable ~= nil then table.insert(values, tonumber(vehicle.spec_wearable.damage) or 0) end
        local result = 0
        for _, value in ipairs(values) do result = math.max(result, value) end
        return clamp(result, 0, 1)
    end

    function Contracts:activateEquipmentRental(offer)
        if offer == nil or offer.contractType ~= "equipment_rental" then return true end
        local rental = self:getInterFarmRentalState(offer)
        if rental.transferred == true then return true end
        local vehicle = self:findRuntimeVehicleForInterFarm(offer.sourceFarmId, offer.assetId)
        if vehicle == nil then return false, "rental vehicle not found" end
        rental.checkoutDamage = self:getVehicleDamageMetric(vehicle)
        rental.checkoutPeriodKey = self:getPeriodKey()
        local ok, reason = self:transferInterFarmVehicle(offer.assetId, offer.sourceFarmId, offer.contractorFarmId)
        if not ok then return false, reason end
        rental.currentHolderFarmId = offer.contractorFarmId
        rental.transferred = true
        return true
    end

    function Contracts:finishEquipmentRental(offer, forced)
        if offer == nil or offer.contractType ~= "equipment_rental" then return true, 0 end
        local rental = self:getInterFarmRentalState(offer)
        if rental.returned == true then return true, rental.damageCharge + rental.lateCharge end
        local vehicle = self:findRuntimeVehicleForInterFarm(offer.contractorFarmId, offer.assetId)
        if vehicle == nil then return false, 0, "rental vehicle not found at return" end
        rental.returnDamage = self:getVehicleDamageMetric(vehicle)
        local damageDelta = math.max(0, rental.returnDamage - num(rental.checkoutDamage, 0))
        local baseValue = 25000
        local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local workshop = instances ~= nil and instances.workshop ~= nil and instances.workshop.service or nil
        if workshop ~= nil and workshop.getState ~= nil then
            local ws = workshop:getState(offer.contractorFarmId, false)
            local row = ws ~= nil and ws.vehicles ~= nil and ws.vehicles[tostring(offer.assetId or "")] or nil
            baseValue = math.max(baseValue, tonumber(row ~= nil and row.value) or 0)
        end
        rental.damageCharge = round(damageDelta * baseValue * 0.35)
        local lateness = math.max(0, self:getPeriodKey() - integer(offer.duePeriodKey, self:getPeriodKey()))
        rental.lateCharge = round((tonumber(offer.rewardValue) or 0) * math.min(1, lateness * 0.15))
        local charge = round(rental.damageCharge + rental.lateCharge)
        if charge > 0 then
            local _, paid = self:transferFarmMoney(offer.contractorFarmId, offer.sourceFarmId, charge, offer.id .. ":rental_return")
            charge = paid
        end
        local ok, reason = self:transferInterFarmVehicle(offer.assetId, offer.contractorFarmId, offer.sourceFarmId)
        if not ok then return false, charge, reason end
        rental.currentHolderFarmId = offer.sourceFarmId
        rental.returned = true
        rental.forcedReturn = forced == true
        return true, charge
    end

    function Contracts:getInterFarmProductPaymentDirection(offer)
        if offer ~= nil and self:isInterFarmSellerContract(offer) and tostring(offer.rewardMode or "") == "product_quantity" then
            return integer(offer.contractorFarmId, 0), integer(offer.sourceFarmId, 0)
        end
        return integer(offer ~= nil and offer.sourceFarmId, 0), integer(offer ~= nil and offer.contractorFarmId, 0)
    end

    function Contracts:settleInterFarmProductEntitlement(offer)
        if offer == nil then return true, 0 end
        local product = round(math.max(0, num(offer.productEntitlementLiters, 0) - num(offer.productTransferredLiters, 0)))
        if product <= 0 then return true, 0 end
        if integer(offer.fillTypeIndex, 0) <= 0 then return false, 0, "fill type missing" end
        local fromFarmId, toFarmId = self:getInterFarmProductPaymentDirection(offer)
        if fromFarmId <= 0 or toFarmId <= 0 then return false, 0, "product payment farms unavailable" end
        local ok, transferred, reason = self:transferInterFarmProduct(fromFarmId, toFarmId, offer.fillTypeIndex, product, offer.id .. ":reward")
        offer.productTransferredLiters = round(num(offer.productTransferredLiters, 0) + transferred)
        return ok and offer.productTransferredLiters + 0.01 >= offer.productEntitlementLiters, transferred, reason
    end

    function Contracts:completeInterFarmPhysicalSettlement(offer)
        if offer == nil then return false, "offer unavailable" end
        if offer.contractType == "asset_sale" then
            if offer.assetTransferred == true then return true end
            local ok, reason = self:transferInterFarmVehicle(offer.assetId, offer.sourceFarmId, offer.contractorFarmId)
            if ok then offer.assetTransferred = true end
            return ok, reason
        end
        if offer.contractType == "equipment_rental" then
            local ok, _, reason = self:finishEquipmentRental(offer, false)
            return ok, reason
        end
        if offer.contractType == "bale_sale" then
            if num(offer.quantity, 0) <= num(offer.balesTransferred, 0) then return true end
            local target = math.max(1, integer(num(offer.quantity, 0) - num(offer.balesTransferred, 0), 1))
            local ok, count, reason = self:transferInterFarmBales(offer.sourceFarmId, offer.contractorFarmId, target)
            offer.balesTransferred = integer(num(offer.balesTransferred, 0) + count, 0)
            return ok and offer.balesTransferred >= integer(offer.quantity, 0), reason
        end
        if offer.contractType == "crop_sale" then
            local target = round(math.max(0, num(offer.quantity, 0)))
            local already = round(math.max(0, num(offer.saleProductTransferredLiters, 0)))
            local remaining = round(math.max(0, target - already))
            if remaining <= 0 then return true end
            if integer(offer.fillTypeIndex, 0) <= 0 then return false, "fill type missing" end
            local ok, transferred, reason = self:transferInterFarmProduct(offer.sourceFarmId, offer.contractorFarmId, offer.fillTypeIndex, remaining, offer.id .. ":sale")
            offer.saleProductTransferredLiters = round(already + transferred)
            return ok and offer.saleProductTransferredLiters + 0.01 >= target, reason
        end
        if num(offer.productEntitlementLiters, 0) > 0 then
            local ok, _, reason = self:settleInterFarmProductEntitlement(offer)
            return ok, reason
        end
        return true
    end

end
