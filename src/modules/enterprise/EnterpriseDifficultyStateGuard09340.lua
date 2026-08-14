-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- 0.9.3.40: keep Enterprise difficulty lookup independent from decorated Economy snapshots.
AgriLife = AgriLife or {}
AgriLife.EnterpriseDifficultyStateGuard09340 = AgriLife.EnterpriseDifficultyStateGuard09340 or {VERSION = "0.9.3.40"}

local Enterprise = AgriLife.Enterprise6Service
if Enterprise ~= nil and Enterprise._difficultyStateGuard09340Installed ~= true then
    Enterprise._difficultyStateGuard09340Installed = true

    function Enterprise:getDifficulty(farmId)
        farmId = tonumber(farmId) or 0
        if farmId <= 0 then return "normal" end
        local economyModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local economy = economyModule ~= nil and (economyModule.service or economyModule) or nil
        local state = economy ~= nil and economy.getFarmState ~= nil and economy:getFarmState(farmId, false) or nil
        return tostring(state ~= nil and state.modeId or "normal")
    end
end
