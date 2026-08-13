-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}
AgriLife.EnterpriseModule = {}; AgriLife.EnterpriseModule.__index = AgriLife.EnterpriseModule
AgriLife.EnterpriseModule.ID = "enterprise"; AgriLife.EnterpriseModule.VERSION = "0.7.6.0"; AgriLife.EnterpriseModule.SCHEMA_VERSION = 5
function AgriLife.EnterpriseModule.new(core) return setmetatable({core = core, service = AgriLife.Enterprise6Service.new(core), started = false}, AgriLife.EnterpriseModule) end
function AgriLife.EnterpriseModule:create() return AgriLife.Result.ok("ENTERPRISE_CREATED", "Enterprise created") end
function AgriLife.EnterpriseModule:load(xmlFile, key, farmId) return self.service:loadFarm(xmlFile, key, farmId) end
function AgriLife.EnterpriseModule:start()
    if self.started then return AgriLife.Result.ok("ENTERPRISE_ALREADY_STARTED", "Enterprise already started") end
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer and self.core.subscriptions ~= nil and MessageType ~= nil then
        if MessageType.PERIOD_CHANGED ~= nil then
            local result = self.core.subscriptions:subscribe(self.ID, MessageType.PERIOD_CHANGED, self.service, self.service.onPeriodChanged)
            if result ~= nil and result.ok == false then return result end
        end
        if MessageType.AI_JOB_STOPPED ~= nil and self.service.onAIJobStopped ~= nil then
            local result = self.core.subscriptions:subscribe(self.ID, MessageType.AI_JOB_STOPPED, self.service, self.service.onAIJobStopped)
            if result ~= nil and result.ok == false then AgriLife.Logger.warning("Enterprise", "AI job stop hook unavailable: %s", tostring(result.code)) end
        end
    end
    self.started = true
    return AgriLife.Result.ok("ENTERPRISE_STARTED", "Enterprise started")
end
function AgriLife.EnterpriseModule:update(dt) if self.service ~= nil then self.service:update(dt) end end
function AgriLife.EnterpriseModule:save(xmlFile, key, farmId) return self.service:saveFarm(xmlFile, key, farmId) end
function AgriLife.EnterpriseModule:stop() if self.core ~= nil and self.core.subscriptions ~= nil then self.core.subscriptions:unsubscribeOwner(self.ID) end; self.started = false; return AgriLife.Result.ok("ENTERPRISE_STOPPED", "Enterprise stopped") end
function AgriLife.EnterpriseModule:delete() self:stop(); if self.service ~= nil then self.service:delete() end; self.service = nil; self.core = nil; return AgriLife.Result.ok("ENTERPRISE_DELETED", "Enterprise deleted") end
function AgriLife.EnterpriseModule:getSnapshot(...) return self.service:getSnapshot(...) end
function AgriLife.EnterpriseModule:hireCandidate(...) return self.service:hireCandidate(...) end
function AgriLife.EnterpriseModule:createWorkOrder(...) return self.service:createWorkOrder(...) end
function AgriLife.EnterpriseModule:startWorkOrder(...) return self.service:startWorkOrder(...) end
function AgriLife.EnterpriseModule:pauseWorkOrder(...) return self.service:pauseWorkOrder(...) end
function AgriLife.EnterpriseModule:resumeWorkOrder(...) return self.service:resumeWorkOrder(...) end
function AgriLife.EnterpriseModule:cancelWorkOrder(...) return self.service:cancelWorkOrder(...) end
function AgriLife.EnterpriseModule:completeWorkOrder(...) return self.service:completeWorkOrder(...) end
function AgriLife.EnterpriseModule:changeReputation(...) return self.service:changeReputation(...) end
function AgriLife.EnterpriseModule:getRuntimeVehicleRows(...) return self.service:getRuntimeVehicleRows(...) end
function AgriLife.EnterpriseModule:getWorkTypeRows(...) return self.service:getWorkTypeRows(...) end
function AgriLife.EnterpriseModule:getEmployeeDetails(...) return self.service:getEmployeeDetails(...) end
function AgriLife.EnterpriseModule:getWorkforceStatus(...) return self.service:getWorkforceStatus(...) end
function AgriLife.EnterpriseModule:setEmployeeWorkforceStatus(...) return self.service:setEmployeeWorkforceStatus(...) end
function AgriLife.EnterpriseModule:updateEmploymentContract(...) return self.service:updateEmploymentContract(...) end
function AgriLife.EnterpriseModule:promoteEmployee(...) return self.service:promoteEmployee(...) end
function AgriLife.EnterpriseModule:terminateEmployee(...) return self.service:terminateEmployee(...) end
function AgriLife.EnterpriseModule:getReputationFactors(...) return self.service:getReputationFactors(...) end
function AgriLife.EnterpriseModule:getEmployeeSchedule(...) return self.service:getEmployeeSchedule(...) end
function AgriLife.EnterpriseModule:setEmployeeSchedule(...) return self.service:setEmployeeSchedule(...) end
function AgriLife.EnterpriseModule:getEmployeeDailyTime(...) return self.service:getEmployeeDailyTime(...) end
function AgriLife.EnterpriseModule:scheduleEmployeeLeave(...) return self.service:scheduleEmployeeLeave(...) end
function AgriLife.EnterpriseModule:recordEmployeeSickness(...) return self.service:recordEmployeeSickness(...) end
function AgriLife.EnterpriseModule:recordEmployeeAbsence(...) return self.service:recordEmployeeAbsence(...) end
function AgriLife.EnterpriseModule:setEmployeeBreak(...) return self.service:setEmployeeBreak(...) end
function AgriLife.EnterpriseModule:clearEmployeeAvailabilityStatus(...) return self.service:clearEmployeeAvailabilityStatus(...) end
function AgriLife.EnterpriseModule:renewEmploymentContract(...) return self.service:renewEmploymentContract(...) end
function AgriLife.EnterpriseModule:raiseEmployeeSalary(...) return self.service:raiseEmployeeSalary(...) end
function AgriLife.EnterpriseModule:getDismissalCost(...) return self.service:getDismissalCost(...) end
function AgriLife.EnterpriseModule:dismissEmployee(...) return self.service:dismissEmployee(...) end
function AgriLife.EnterpriseModule:getVehicleWorkCapabilities(...) return self.service:getVehicleWorkCapabilities(...) end
function AgriLife.EnterpriseModule:configureWorkOrderExecution(...) return self.service:configureWorkOrderExecution(...) end
function AgriLife.EnterpriseModule:getWorkOrderExecutionOptions(...) return self.service:getWorkOrderExecutionOptions(...) end
function AgriLife.EnterpriseModule:getRecruitmentMarket(...) return self.service:getRecruitmentMarket(...) end
function AgriLife.EnterpriseModule:hireCandidateWithOffer(...) return self.service:hireCandidateWithOffer(...) end
function AgriLife.EnterpriseModule:getEmployeeTrainingCatalog(...) return self.service:getEmployeeTrainingCatalog(...) end
function AgriLife.EnterpriseModule:startEmployeeTraining(...) return self.service:startEmployeeTraining(...) end
function AgriLife.EnterpriseModule:completeQualificationTraining(...) return self.service:completeQualificationTraining(...) end
function AgriLife.EnterpriseModule:getEmployeeCareerProfile(...) return self.service:getEmployeeCareerProfile(...) end
function AgriLife.EnterpriseModule:getPromotionEligibility(...) return self.service:getPromotionEligibility(...) end
function AgriLife.EnterpriseModule:enqueueWorkOrder(...) return self.service:enqueueWorkOrder(...) end
function AgriLife.EnterpriseModule:getWorkQueue(...) return self.service:getWorkQueue(...) end
function AgriLife.EnterpriseModule:cancelQueuedWork(...) return self.service:cancelQueuedWork(...) end
function AgriLife.EnterpriseModule:dispatchQueuedWork(...) return self.service:dispatchQueuedWork(...) end
function AgriLife.EnterpriseModule:processWorkQueue(...) return self.service:processWorkQueue(...) end
function AgriLife.EnterpriseModule:reportWorkIncident(...) return self.service:reportWorkIncident(...) end
function AgriLife.EnterpriseModule:getEmployeeTrainingStatus(...) return self.service:getEmployeeTrainingStatus(...) end
function AgriLife.EnterpriseModule:getEmployeeIncidents(...) return self.service:getEmployeeIncidents(...) end
function AgriLife.EnterpriseModule:getWorkforceForecast(...) return self.service:getWorkforceForecast(...) end
function AgriLife.EnterpriseModule:getWorkforcePlanningSnapshot(...) return self.service:getWorkforcePlanningSnapshot(...) end
function AgriLife.EnterpriseModule:promoteEmployeeCareer(...) return self.service:promoteEmployeeCareer(...) end

function AgriLife.EnterpriseModule:getEmployeeFullSheet(...) return self.service:getEmployeeFullSheet(...) end
function AgriLife.EnterpriseModule:getEmployeeMachineFamiliarity(...) return self.service:getEmployeeMachineFamiliarity(...) end
function AgriLife.EnterpriseModule:getReputationOpportunityProfile(...) return self.service:getReputationOpportunityProfile(...) end
function AgriLife.EnterpriseModule:recordBusinessReputationEvent(...) return self.service:recordBusinessReputationEvent(...) end
function AgriLife.EnterpriseModule:getRoadmap4Checklist(...) return self.service:getRoadmap4Checklist(...) end
function AgriLife.EnterpriseModule.getDescriptor() return {id = "enterprise", version = "0.7.6.0", schemaVersion = 5, dependencies = {"economy", "company", "people", "payroll", "career", "journal", "compatibility"}, defaultEnabled = true, serverOnly = false, critical = false, factory = function(core) return AgriLife.EnterpriseModule.new(core) end} end
function AgriLife.EnterpriseModule.register(registry) return registry:register(AgriLife.EnterpriseModule.getDescriptor()) end
