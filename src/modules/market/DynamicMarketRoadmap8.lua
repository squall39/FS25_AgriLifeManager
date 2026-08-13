-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 8 workshop parts market bridge.
AgriLife = AgriLife or {}

if AgriLife.DynamicMarket6Service ~= nil then
    local Market = AgriLife.DynamicMarket6Service
    Market.ROADMAP8_VERSION = "0.8.0.0"

    local function clamp(value, minimum, maximum)
        return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
    end

    local function round(value)
        return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
    end

    local QUALITY = {
        OEM = {price = 1.25, availability = 0.90, warrantyMonths = 24, reliability = 1.00},
        AFTERMARKET = {price = 0.90, availability = 1.08, warrantyMonths = 12, reliability = 0.90},
        REMANUFACTURED = {price = 0.66, availability = 0.92, warrantyMonths = 6, reliability = 0.84},
        USED = {price = 0.43, availability = 0.78, warrantyMonths = 1, reliability = 0.68}
    }

    function Market:getWorkshopPartQuality(qualityId)
        qualityId = string.upper(tostring(qualityId or "OEM"))
        return QUALITY[qualityId] or QUALITY.OEM, QUALITY[qualityId] ~= nil and qualityId or "OEM"
    end

    function Market:getWorkshopPartsQuote(farmId, partFamily, basePrice, qualityId, urgency)
        local quality, normalizedQuality = self:getWorkshopPartQuality(qualityId)
        local inputFactor = self:getCategoryMultiplier(farmId, "inputs")
        local equipmentFactor = self:getCategoryMultiplier(farmId, "vehicles_new")
        local marketFactor = clamp(inputFactor * 0.62 + equipmentFactor * 0.38, 0.65, 1.55)
        local token = string.format("WORKSHOP_PART:%s:%s", tostring(partFamily or "generic"), normalizedQuality)
        local availability = self:getAvailabilitySnapshot(farmId, token, "inputs")
        local adjustedAvailability = clamp((tonumber(availability.availability) or 0.5) * quality.availability, 0.08, 1)
        local stockLevel = math.max(0, math.floor(adjustedAvailability * 12 + 0.5))
        local standardDays
        if stockLevel >= 8 then standardDays = 0
        elseif stockLevel >= 5 then standardDays = 1
        elseif stockLevel >= 3 then standardDays = 2
        elseif stockLevel >= 1 then standardDays = 4
        else standardDays = 6 + math.floor((1 - adjustedAvailability) * 5 + 0.5) end
        local urgent = tostring(urgency or "STANDARD"):upper()
        local deliveryDays = standardDays
        local deliveryFactor = 1
        if urgent == "PRIORITY" then deliveryDays = math.max(0, math.ceil(standardDays * 0.55)); deliveryFactor = 1.12
        elseif urgent == "EXPRESS" then deliveryDays = math.max(0, math.ceil(standardDays * 0.25)); deliveryFactor = 1.28 end
        local unitPrice = round(math.max(1, tonumber(basePrice) or 1) * marketFactor * quality.price * deliveryFactor)
        return {
            partFamily = tostring(partFamily or "generic"), qualityId = normalizedQuality,
            unitPrice = unitPrice, marketFactor = round(marketFactor), availableNow = stockLevel >= 8,
            stockLevel = stockLevel, availability = round(adjustedAvailability), deliveryDays = deliveryDays,
            standardDeliveryDays = standardDays, urgency = urgent, warrantyMonths = quality.warrantyMonths,
            reliability = quality.reliability, nextReviewPeriodKey = availability.nextReviewPeriodKey
        }
    end

    function Market:getWorkshopPartsMarketSnapshot(farmId, partFamilies)
        local rows = {}
        for _, family in ipairs(type(partFamilies) == "table" and partFamilies or {}) do
            local familyId = type(family) == "table" and family.id or tostring(family)
            local basePrice = type(family) == "table" and family.basePrice or 100
            for _, qualityId in ipairs({"OEM", "AFTERMARKET", "REMANUFACTURED", "USED"}) do
                table.insert(rows, self:getWorkshopPartsQuote(farmId, familyId, basePrice, qualityId, "STANDARD"))
            end
        end
        return rows
    end
end

if AgriLife.DynamicMarketModule ~= nil then
    AgriLife.DynamicMarketModule.VERSION = "0.8.0.0"
    function AgriLife.DynamicMarketModule:getWorkshopPartsQuote(...) return self.service:getWorkshopPartsQuote(...) end
    function AgriLife.DynamicMarketModule:getWorkshopPartsMarketSnapshot(...) return self.service:getWorkshopPartsMarketSnapshot(...) end
    local baseDescriptor = AgriLife.DynamicMarketModule.getDescriptor
    function AgriLife.DynamicMarketModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.8.0.0"
        return descriptor
    end
end
