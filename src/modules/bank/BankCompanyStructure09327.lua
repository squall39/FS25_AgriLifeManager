-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.Bank6Service ~= nil then
    local Bank = AgriLife.Bank6Service
    Bank.COMPANY_STRUCTURE_VERSION = "0.9.3.27"

    local function num(value, default)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
        return value
    end
    local function clamp(value, minimum, maximum) return math.max(minimum, math.min(maximum, num(value, minimum))) end
    local function round(value) return math.floor(num(value, 0) * 100 + 0.5) / 100 end

    function Bank:getCompanyStructureSnapshot(farmId)
        local company = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.company or nil
        return company ~= nil and company.getSnapshot ~= nil and company:getSnapshot(farmId) or nil
    end

    -- A more structured legal form can modestly improve lender confidence,
    -- but the recurring administration cost means there is no universally
    -- best legal form. Unpaid structural fees have the opposite effect.
    local baseCalculateCapacity = Bank.calculateCapacity
    function Bank:calculateCapacity(farmId)
        local capacity = baseCalculateCapacity(self, farmId)
        local company = self:getCompanyStructureSnapshot(farmId)
        if company == nil then return capacity end
        local confidence = clamp(company.bankConfidenceBonus, 0, 4)
        local factor = 1 + confidence * 0.015
        if num(company.structureFeeArrears, 0) > 0 then factor = factor * 0.90 end
        return round(clamp(capacity * factor, 0, Bank.MAX_CASH_LOAN))
    end

    local baseCalculateAnnualRate = Bank.calculateAnnualRate
    function Bank:calculateAnnualRate(farmId, amount, termMonths)
        local rate = baseCalculateAnnualRate(self, farmId, amount, termMonths)
        local company = self:getCompanyStructureSnapshot(farmId)
        if company == nil then return rate end
        local separation = clamp(company.personalSeparation, 0, 1)
        local confidence = clamp(company.bankConfidenceBonus, 0, 4)
        rate = rate - confidence * 0.00020 - math.max(0, separation - 0.50) * 0.00050
        if num(company.structureFeeArrears, 0) > 0 then rate = rate + 0.0050 end
        return clamp(rate, 0.018, 0.22)
    end
end
