-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04: recruitment fees must appear in the professional bank statement.
AgriLife = AgriLife or {}
AgriLife.F04RecruitmentBankStatement = AgriLife.F04RecruitmentBankStatement or {}

local Payroll = AgriLife.Payroll6Service
if Payroll ~= nil and Payroll.recruitVirtualEmployee ~= nil and Payroll._f04RecruitmentStatementWrapped ~= true then
    Payroll._f04RecruitmentStatementWrapped = true
    local baseRecruitVirtualEmployee = Payroll.recruitVirtualEmployee

    local function roundCurrency(value)
        return math.floor(((tonumber(value) or 0) * 100) + 0.5) / 100
    end

    local function recordProfessionalMovement(self, farmId, result)
        if result == nil or result.ok ~= true or result.details == nil then return end
        local fee = math.max(0, tonumber(result.details.fee) or tonumber(Payroll.RECRUITMENT_FEE) or 0)
        if fee <= 0 then return end

        local registry = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local bank = registry ~= nil and registry.bank or nil
        local service = bank ~= nil and (bank.service or bank) or nil
        if service == nil or service.getFarmState == nil or service.getFarm == nil then
            if AgriLife.Logger ~= nil then
                AgriLife.Logger.warning("Payroll", "Recruitment fee %.2f not added to professional statement: bank service unavailable", fee)
            end
            return
        end

        local state = service:getFarmState(farmId, true)
        local farm = service:getFarm(farmId)
        if state == nil or farm == nil then return end

        local environment = g_currentMission ~= nil and g_currentMission.environment or nil
        local nextId = math.max(1, math.floor(tonumber(state.nextBankMovementId) or 1))
        local movement = {
            id = string.format("BM6_%d_%06d", tonumber(farmId) or 0, nextId),
            periodKey = service.getCurrentPeriodKey ~= nil and service:getCurrentPeriodKey() or 0,
            day = environment ~= nil and (tonumber(environment.currentMonotonicDay) or tonumber(environment.currentDay) or 0) or 0,
            dayTime = environment ~= nil and (tonumber(environment.dayTime) or 0) or 0,
            kind = "PAYROLL_RECRUITMENT_FEE",
            amount = roundCurrency(-fee),
            balanceAfter = roundCurrency(tonumber(farm.money) or 0),
            note = tostring(result.details.displayName or ""),
            tags = "FRAIS RECRUTEMENT | " .. tostring(result.details.displayName or "")
        }

        state.nextBankMovementId = nextId + 1
        state.bankMovements = state.bankMovements or {}
        table.insert(state.bankMovements, movement)
        while #state.bankMovements > 160 do table.remove(state.bankMovements, 1) end
    end

    function Payroll:recruitVirtualEmployee(farmId, ...)
        local result = baseRecruitVirtualEmployee(self, farmId, ...)
        recordProfessionalMovement(self, farmId, result)
        return result
    end
end
