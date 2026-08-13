-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.CommercialContracts6Service ~= nil then
    local Contracts = AgriLife.CommercialContracts6Service

    function Contracts:canInterFarmWorkField(farmId, farmlandId)
        local access = self:getInterFarmFieldAccess(farmId, farmlandId)
        return access ~= nil and access.allowed == true, access
    end
end

if AgriLife.CommercialContractsModule ~= nil then
    function AgriLife.CommercialContractsModule:canInterFarmWorkField(...)
        return self.service:canInterFarmWorkField(...)
    end
end
