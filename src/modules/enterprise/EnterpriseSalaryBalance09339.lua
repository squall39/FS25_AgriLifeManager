-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04.2 candidate salary rebalance and owner promotion guard.
AgriLife = AgriLife or {}
AgriLife.EnterpriseSalaryBalance09339 = AgriLife.EnterpriseSalaryBalance09339 or {VERSION = "0.9.3.39"}

local Enterprise = AgriLife.Enterprise6Service
if Enterprise ~= nil and Enterprise._salaryBalance09339Installed ~= true then
    Enterprise._salaryBalance09339Installed = true

    local baseRefreshCandidateMarket = Enterprise.refreshCandidateMarket
    local baseGetPromotionEligibility = Enterprise.getPromotionEligibility

    local function round10(value)
        return math.floor((math.max(0, tonumber(value) or 0)) / 10 + 0.5) * 10
    end

    local function candidateFactor(difficulty)
        difficulty = tostring(difficulty or "normal")
        if difficulty == "facile" then return 0.92 end
        if difficulty == "difficile" then return 1.10 end
        return 1.00
    end

    local function getDifficultyDirect(self, farmId)
        local economyModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local economy = economyModule ~= nil and (economyModule.service or economyModule) or nil
        local state = economy ~= nil and economy.getFarmState ~= nil and economy:getFarmState(farmId, false) or nil
        return tostring(state ~= nil and state.modeId or "normal")
    end

    function Enterprise:refreshCandidateMarket(farmId, force)
        local rows = baseRefreshCandidateMarket(self, farmId, force) or {}
        local difficulty = getDifficultyDirect(self, farmId)
        local factor = candidateFactor(difficulty)
        for _, candidate in ipairs(rows) do
            local skill = math.max(0, tonumber(candidate.generalSkill) or 0)
            local experience = math.max(0, tonumber(candidate.experienceMonths) or 0)
            local balancedBase = 1300 + skill * 7.5 + experience * 0.8
            candidate.requestedSalary = round10(balancedBase * factor)
        end
        return rows
    end

    function Enterprise:getPromotionEligibility(farmId, profileId)
        local details = self.getEmployeeDetails ~= nil and self:getEmployeeDetails(farmId, profileId) or nil
        if details ~= nil and tostring(details.role or "") == "owner" then
            return {eligible=false, reason="owner_role"}
        end
        return baseGetPromotionEligibility(self, farmId, profileId)
    end
end
