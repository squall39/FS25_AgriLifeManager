-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.Career6Service ~= nil and AgriLife.InterFarmTransportHookInstalled ~= true then
    AgriLife.InterFarmTransportHookInstalled = true
    local Career = AgriLife.Career6Service
    local baseAwardTransportInterFarm = Career.awardTransport
    if baseAwardTransportInterFarm ~= nil then
        function Career:awardTransport(farmId, tonnes, kilometers, quality, sourceToken, profileId)
            local result = baseAwardTransportInterFarm(self, farmId, tonnes, kilometers, quality, sourceToken, profileId)
            local registry = self.core ~= nil and self.core.registry or nil
            local module = registry ~= nil and registry.instances ~= nil and registry.instances.commercialContracts or nil
            local contracts = module ~= nil and module.service or nil
            if contracts ~= nil and contracts.recordInterFarmTransportWork ~= nil and (result == nil or result.ok ~= false) then
                local hours = math.max(0, tonumber(kilometers) or 0) / 25
                contracts:recordInterFarmTransportWork(farmId, tonnes, hours)
            end
            return result
        end
    end
end
