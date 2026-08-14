-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.Payroll6Service == nil then return end
local Payroll=AgriLife.Payroll6Service
Payroll.OWNER_REMUNERATION_VERSION="0.9.3.28"

local function tr(key,fallback)
    if g_i18n~=nil and g_i18n.getText~=nil then local ok,value=pcall(g_i18n.getText,g_i18n,key);if ok and value~=nil and tostring(value)~=tostring(key)then return tostring(value)end end
    return tostring(fallback or key or "")
end

local function num(value, fallback)
    value=tonumber(value);if value==nil or value~=value or value==math.huge or value==-math.huge then return fallback or 0 end;return value
end

function Payroll:getOwnerProfileIdForFarm(farmId)
    local people=self:getPeopleService()
    if people~=nil and people.getOwnerProfileId~=nil then local value=people:getOwnerProfileId(farmId);if value~=nil and tostring(value)~=""then return tostring(value)end end
    local economy=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.economy or nil
    local service=economy~=nil and (economy.service or economy)or nil
    if service~=nil and service.getOwnerProfileId~=nil then return tostring(service:getOwnerProfileId(farmId)or"")end
    return ""
end

function Payroll:previewOwnerRemuneration(farmId,amount)
    local profileId=self:getOwnerProfileIdForFarm(farmId);local state=self:getFarmState(farmId,false);local employee=state~=nil and state.employees~=nil and state.employees[profileId]or nil
    if employee==nil then return AgriLife.Result.fail("OWNER_REMUNERATION_PROFILE_MISSING",tr("agrilife_owner_pay_profile_missing","Owner payroll profile is unavailable."))end
    self:syncCareerForEmployee(farmId,employee)
    local minimum,maximum=self:getSalaryBounds(employee);local recommended=self:getRecommendedSalary(employee);amount=tonumber(amount)or self:getMonthlySalary(employee)
    if amount<minimum or amount>maximum then return AgriLife.Result.fail("OWNER_REMUNERATION_OUT_OF_RANGE",tr("agrilife_owner_pay_out_of_range","Owner remuneration is outside the allowed range."),{minimum=minimum,maximum=maximum,recommended=recommended,current=self:getMonthlySalary(employee)})end
    local enterprise=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.enterprise or nil
    local advice=enterprise~=nil and enterprise.getManagementAdvice~=nil and enterprise:getManagementAdvice(farmId,"OWNER_PAY",{monthlyEmployerCost=amount},false)or nil
    return AgriLife.Result.ok("OWNER_REMUNERATION_PREVIEW",tr("agrilife_owner_pay_preview_ready","Owner remuneration preview ready."),{profileId=profileId,amount=amount,minimum=minimum,maximum=maximum,recommended=recommended,current=self:getMonthlySalary(employee),advice=advice})
end

function Payroll:setOwnerRemuneration(farmId,actorProfileId,amount)
    local preview=self:previewOwnerRemuneration(farmId,amount);if preview==nil or preview.ok~=true then return preview end
    local economy=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.economy or nil
    local service=economy~=nil and (economy.service or economy)or nil
    local health=service~=nil and service.getBusinessHealth~=nil and service:getBusinessHealth(farmId)or nil
    if health~=nil and (health.status=="INSOLVENT"or health.status=="BANKRUPT") and num(amount,0)>num(preview.details.current,0) then
        return AgriLife.Result.fail("OWNER_REMUNERATION_INCREASE_RESTRICTED",tr("agrilife_owner_pay_increase_restricted","Owner remuneration cannot be increased while the farm is insolvent. Reducing it remains possible."),health)
    end
    local profileId=preview.details.profileId;return self:setSalaryPolicy(farmId,actorProfileId,profileId,"MANUAL",amount)
end

function Payroll:restoreOwnerRemunerationAuto(farmId,actorProfileId)
    local profileId=self:getOwnerProfileIdForFarm(farmId);if profileId==""then return AgriLife.Result.fail("OWNER_REMUNERATION_PROFILE_MISSING",tr("agrilife_owner_pay_profile_missing","Owner payroll profile is unavailable."))end
    return self:setSalaryPolicy(farmId,actorProfileId,profileId,"AUTO",0)
end

if AgriLife.PayrollModule~=nil then
    function AgriLife.PayrollModule:previewOwnerRemuneration(...)return self.service:previewOwnerRemuneration(...)end
    function AgriLife.PayrollModule:setOwnerRemuneration(...)return self.service:setOwnerRemuneration(...)end
    function AgriLife.PayrollModule:restoreOwnerRemunerationAuto(...)return self.service:restoreOwnerRemunerationAuto(...)end
end
