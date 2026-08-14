-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04.2 salary rebalance by AgriLife difficulty.
AgriLife = AgriLife or {}
AgriLife.PayrollDifficultySalary09339 = AgriLife.PayrollDifficultySalary09339 or {VERSION = "0.9.3.39"}

local Payroll = AgriLife.Payroll6Service
if Payroll ~= nil and Payroll._salaryDifficulty09339Installed ~= true then
    Payroll._salaryDifficulty09339Installed = true

    local baseGetRecommendedSalary = Payroll.getRecommendedSalary

    local function getFarmId(self, employee)
        local farmId = tonumber(employee ~= nil and employee.farmId) or 0
        if farmId > 0 then return farmId end
        local profileId = tostring(employee ~= nil and employee.profileId or "")
        for id, state in pairs(self.farms or {}) do
            if state ~= nil and state.employees ~= nil and state.employees[profileId] == employee then
                return tonumber(id) or 0
            end
        end
        return 0
    end

    local function getDifficulty(self, farmId)
        if farmId <= 0 then return "normal" end
        -- Never request Economy:getSnapshot from salary calculation.
        -- Economy snapshots can include payroll data, which itself asks for
        -- recommended salaries. Reading the persisted farm state keeps this
        -- dependency one-way and prevents recursive snapshot construction.
        local economyModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local economy = economyModule ~= nil and (economyModule.service or economyModule) or nil
        local state = economy ~= nil and economy.getFarmState ~= nil and economy:getFarmState(farmId, false) or nil
        return tostring(state ~= nil and state.modeId or "normal")
    end

    local function salaryFactor(difficulty)
        difficulty = tostring(difficulty or "normal")
        if difficulty == "facile" then return 0.85 end
        if difficulty == "difficile" then return 1.05 end
        return 0.95
    end

    function Payroll:getSalaryDifficultyFactor(farmId)
        return salaryFactor(getDifficulty(self, tonumber(farmId) or 0))
    end

    function Payroll:getRecommendedSalary(employee)
        local base = tonumber(baseGetRecommendedSalary(self, employee)) or 0
        if employee == nil or base <= 0 then return math.max(0, base) end
        local factor = salaryFactor(getDifficulty(self, getFarmId(self, employee)))
        return math.floor((base * factor) / 10 + 0.5) * 10
    end
end
