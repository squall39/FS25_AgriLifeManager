-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.Enterprise6Service = {}
AgriLife.Enterprise6Service.__index = AgriLife.Enterprise6Service

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

local function round(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function cloneTable(source)
    local target = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            target[key] = cloneTable(value)
        else
            target[key] = value
        end
    end
    return target
end

local function normalizeId(value)
    value = tostring(value or "")
    return value ~= "" and value or nil
end

local function nowMinute()
    if g_currentMission ~= nil and g_currentMission.environment ~= nil then
        return math.floor((tonumber(g_currentMission.environment.dayTime) or 0) / 60000)
    end
    return 0
end

local function currentDay()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    if environment == nil then return 0 end
    return tonumber(environment.currentMonotonicDay) or tonumber(environment.currentDay) or 0
end

local WORK_TYPES = {
    {id="TRANSPORT", name="Transport", specialties={TRANSPORT=true, LOGISTICS=true}},
    {id="CULTIVATE", name="Travail du sol", specialties={SOIL=true, CULTIVATION=true}},
    {id="SOW", name="Semis", specialties={SOWING=true, FIELD=true}},
    {id="HARVEST", name="Récolte", specialties={HARVEST=true}},
    {id="MOW", name="Fauche", specialties={MOWING=true, GRASS=true}},
    {id="SPRAY", name="Pulvérisation", specialties={SPRAYING=true, FIELD=true}},
    {id="FERTILIZE", name="Fertilisation", specialties={FERTILIZING=true, FIELD=true}},
    {id="ROLL", name="Roulage", specialties={FIELD=true}},
    {id="PLOW", name="Labour", specialties={SOIL=true, PLOWING=true}},
    {id="BALE", name="Pressage", specialties={BALING=true, GRASS=true}}
}

local CANDIDATE_NAMES = {
    "Hugo Bernard", "Lou Martin", "Emma Petit", "Lucas Robert", "Chloé Richard", "Arthur Durand", "Léa Moreau", "Jules Simon", "Manon Laurent", "Noah Michel", "Camille Lefèvre", "Tom Leroy"
}

local SPECIALTIES = {"TRANSPORT", "SOIL", "SOWING", "HARVEST", "GRASS", "SPRAYING", "FERTILIZING", "BALING"}

function AgriLife.Enterprise6Service.new(core)
    local self = setmetatable({}, AgriLife.Enterprise6Service)
    self.core = core
    self.farms = {}
    self._candidateSeed = 1
    return self
end

function AgriLife.Enterprise6Service:createFarm(farmId)
    local farm = {
        farmId = farmId,
        reputation = 50,
        employees = {},
        workOrders = {},
        workQueue = {},
        nextEmployeeId = 1,
        nextOrderId = 1,
        nextQueueId = 1,
        candidateRefresh = 0,
        candidateMarket = {},
        reputationHistory = {},
        incidents = {},
        trainingHistory = {},
        lastPeriod = 0,
        policies = {overtimeAllowed=true, manualSalaryAllowed=true}
    }
    self.farms[farmId] = farm
    return farm
end

function AgriLife.Enterprise6Service:getFarm(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local farm = self.farms[farmId]
    if farm == nil and create ~= false then farm = self:createFarm(farmId) end
    return farm
end

function AgriLife.Enterprise6Service:getPayrollService()
    local registry = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local module = registry ~= nil and registry.payroll or nil
    return module ~= nil and (module.service or module) or nil
end

function AgriLife.Enterprise6Service:getPeopleService()
    local registry = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local module = registry ~= nil and registry.people or nil
    return module ~= nil and (module.service or module) or nil
end

function AgriLife.Enterprise6Service:getEconomyService()
    local registry = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local module = registry ~= nil and registry.economy or nil
    return module ~= nil and (module.service or module) or nil
end

function AgriLife.Enterprise6Service:recordReputation(farm, amount, reason)
    farm.reputation = clamp((tonumber(farm.reputation) or 50) + (tonumber(amount) or 0), 0, 100)
    table.insert(farm.reputationHistory, 1, {day=currentDay(), amount=tonumber(amount) or 0, reason=tostring(reason or ""), value=farm.reputation})
    while #farm.reputationHistory > 40 do table.remove(farm.reputationHistory) end
    return farm.reputation
end

function AgriLife.Enterprise6Service:changeReputation(farmId, amount, reason)
    local farm = self:getFarm(farmId, true)
    if farm == nil then return AgriLife.Result.fail("ENTERPRISE_FARM_INVALID", "Invalid farm") end
    local value = self:recordReputation(farm, amount, reason)
    return AgriLife.Result.ok("ENTERPRISE_REPUTATION_CHANGED", "Reputation updated", {reputation=value})
end

function AgriLife.Enterprise6Service:getReputationFactors(farmId)
    local farm = self:getFarm(farmId, true)
    local reputation = farm ~= nil and farm.reputation or 50
    return {
        reputation = reputation,
        recruitmentQuality = clamp(0.65 + reputation / 200, 0.65, 1.15),
        contractAccess = clamp(0.55 + reputation / 125, 0.55, 1.35),
        wagePressure = clamp(1.15 - reputation / 300, 0.80, 1.15)
    }
end

function AgriLife.Enterprise6Service:getRuntimeVehicleRows(farmId)
    local rows = {}
    local mission = g_currentMission
    if mission ~= nil and mission.vehicles ~= nil then
        for _, vehicle in ipairs(mission.vehicles) do
            local ownerFarmId = tonumber(vehicle.getOwnerFarmId ~= nil and vehicle:getOwnerFarmId() or vehicle.ownerFarmId) or 0
            if ownerFarmId == tonumber(farmId) then
                local title = vehicle.getFullName ~= nil and vehicle:getFullName() or vehicle.getName ~= nil and vehicle:getName() or tostring(vehicle.typeName or "Véhicule")
                table.insert(rows, {id=tostring(vehicle.id or vehicle.rootNode or #rows + 1), title=title, object=vehicle})
            end
        end
    end
    return rows
end

function AgriLife.Enterprise6Service:getWorkTypeRows()
    local rows = {}
    for _, item in ipairs(WORK_TYPES) do rows[#rows+1] = cloneTable(item) end
    return rows
end

function AgriLife.Enterprise6Service:generateCandidate(farm, index)
    local seed = (tonumber(farm.candidateRefresh) or 0) * 17 + index * 31 + (tonumber(farm.farmId) or 1) * 7
    local name = CANDIDATE_NAMES[(seed % #CANDIDATE_NAMES) + 1]
    local specialty = SPECIALTIES[((seed * 3) % #SPECIALTIES) + 1]
    local compatibility = clamp(58 + (seed % 38), 40, 96)
    local salary = round(1650 + (seed % 8) * 85 + compatibility * 2.4)
    local contractType = (seed % 4 == 0) and "SEASONAL" or "CDI"
    return {
        id = string.format("CAND_%d_%d_%d", farm.farmId, farm.candidateRefresh, index),
        displayName = name,
        specialty = specialty,
        compatibility = compatibility,
        requestedSalary = salary,
        contractType = contractType,
        availabilityDays = 7,
        experience = clamp((seed % 6) + 1, 1, 6)
    }
end

function AgriLife.Enterprise6Service:refreshRecruitmentMarket(farmId)
    local farm = self:getFarm(farmId, true)
    farm.candidateRefresh = (tonumber(farm.candidateRefresh) or 0) + 1
    farm.candidateMarket = {}
    local factors = self:getReputationFactors(farmId)
    local count = factors.reputation >= 70 and 5 or 4
    for index=1,count do farm.candidateMarket[#farm.candidateMarket+1] = self:generateCandidate(farm,index) end
    return farm.candidateMarket
end

function AgriLife.Enterprise6Service:getRecruitmentMarket(farmId)
    local farm = self:getFarm(farmId, true)
    if #farm.candidateMarket == 0 then self:refreshRecruitmentMarket(farmId) end
    local rows = {}
    for _, candidate in ipairs(farm.candidateMarket) do rows[#rows+1] = cloneTable(candidate) end
    return rows
end

function AgriLife.Enterprise6Service:hireCandidate(farmId, candidateId)
    return self:hireCandidateWithOffer(farmId, candidateId, nil, nil)
end

function AgriLife.Enterprise6Service:hireCandidateWithOffer(farmId, candidateId, salaryOffer, contractType)
    local farm = self:getFarm(farmId, true)
    if farm == nil then return AgriLife.Result.fail("ENTERPRISE_FARM_INVALID", "Invalid farm") end
    local candidate = nil
    local index = nil
    for i, item in ipairs(self:getRecruitmentMarket(farmId)) do
        if tostring(item.id) == tostring(candidateId) then candidate = item; index = i; break end
    end
    if candidate == nil then return AgriLife.Result.fail("ENTERPRISE_CANDIDATE_UNKNOWN", "Candidate not found") end
    local salary = round(tonumber(salaryOffer) or candidate.requestedSalary)
    local minAccept = candidate.requestedSalary * (0.90 + (100-candidate.compatibility)/1000)
    if salary < minAccept then return AgriLife.Result.fail("ENTERPRISE_OFFER_REJECTED", "Candidate rejected the offer", {minimum=round(minAccept)}) end
    local payroll = self:getPayrollService()
    if payroll ~= nil and payroll.recruitVirtualEmployee ~= nil then
        local result = payroll:recruitVirtualEmployee(farmId, candidate.displayName, salary, contractType or candidate.contractType, candidate.specialty)
        if result == nil or result.ok ~= true then return result or AgriLife.Result.fail("ENTERPRISE_PAYROLL_RECRUIT_FAILED", "Recruitment failed") end
        table.remove(farm.candidateMarket, index)
        self:recordReputation(farm, 0.2, "EMPLOYEE_HIRED")
        return AgriLife.Result.ok("ENTERPRISE_CANDIDATE_HIRED", "Candidate hired", {candidate=candidate, payroll=result.details})
    end
    local employee = {
        id = string.format("EMP_%d_%04d", farmId, farm.nextEmployeeId),
        displayName = candidate.displayName,
        salary = salary,
        contractType = contractType or candidate.contractType,
        specialty = candidate.specialty,
        compatibility = candidate.compatibility,
        active = true,
        hiredDay = currentDay(),
        level = 1,
        xp = 0,
        performance = 50,
        completedOrders = 0,
        failedOrders = 0,
        trainingCount = 0,
        incidents = 0,
        promotions = 0,
        status = "AVAILABLE"
    }
    farm.nextEmployeeId = farm.nextEmployeeId + 1
    farm.employees[#farm.employees+1] = employee
    table.remove(farm.candidateMarket, index)
    return AgriLife.Result.ok("ENTERPRISE_CANDIDATE_HIRED", "Candidate hired", {employee=cloneTable(employee)})
end

function AgriLife.Enterprise6Service:getPayrollProfiles(farmId)
    local payroll = self:getPayrollService()
    if payroll ~= nil and payroll.getSnapshot ~= nil then
        local snapshot = payroll:getSnapshot(farmId)
        return snapshot ~= nil and snapshot.profiles or {}
    end
    return self:getFarm(farmId,true).employees
end

function AgriLife.Enterprise6Service:getEmployeeDetails(farmId, profileId)
    local payroll = self:getPayrollService()
    if payroll ~= nil and payroll.getProfile ~= nil then
        local profile = payroll:getProfile(farmId, profileId)
        if profile ~= nil then
            local result = cloneTable(profile)
            result.profileId = tostring(profile.id or profile.profileId or profileId)
            return result
        end
    end
    local farm = self:getFarm(farmId,true)
    for _, employee in ipairs(farm.employees or {}) do if tostring(employee.id)==tostring(profileId) then return cloneTable(employee) end end
    return nil
end

function AgriLife.Enterprise6Service:getWorkforceStatus(farmId, profileId)
    local farm = self:getFarm(farmId,true)
    farm.workforce = farm.workforce or {}
    local row = farm.workforce[tostring(profileId)]
    if row == nil then
        row = {status="AVAILABLE", overtime=0, absences=0, leave=0, sickness=0, breakActive=false, schedule={start=480, finish=1020}}
        farm.workforce[tostring(profileId)] = row
    end
    return cloneTable(row)
end

function AgriLife.Enterprise6Service:setEmployeeWorkforceStatus(farmId, profileId, status)
    local farm = self:getFarm(farmId,true)
    farm.workforce = farm.workforce or {}
    local row = farm.workforce[tostring(profileId)] or {schedule={start=480,finish=1020}}
    row.status = tostring(status or "AVAILABLE")
    farm.workforce[tostring(profileId)] = row
    return AgriLife.Result.ok("ENTERPRISE_STATUS_UPDATED", "Employee status updated", {status=row.status})
end

function AgriLife.Enterprise6Service:updateEmploymentContract(farmId, profileId, salary, contractType)
    local payroll = self:getPayrollService()
    if payroll ~= nil and payroll.updateProfile ~= nil then return payroll:updateProfile(farmId, profileId, salary, contractType) end
    return AgriLife.Result.fail("ENTERPRISE_PAYROLL_UNAVAILABLE", "Payroll unavailable")
end

function AgriLife.Enterprise6Service:promoteEmployee(farmId, profileId)
    return self:promoteEmployeeCareer(farmId, nil, profileId)
end

function AgriLife.Enterprise6Service:terminateEmployee(farmId, profileId)
    local payroll = self:getPayrollService()
    if payroll ~= nil and payroll.terminateProfile ~= nil then return payroll:terminateProfile(farmId, profileId) end
    return AgriLife.Result.fail("ENTERPRISE_PAYROLL_UNAVAILABLE", "Payroll unavailable")
end

function AgriLife.Enterprise6Service:getEmployeeSchedule(farmId, profileId)
    local status = self:getWorkforceStatus(farmId, profileId)
    return status.schedule or {start=480,finish=1020}
end

function AgriLife.Enterprise6Service:setEmployeeSchedule(farmId, profileId, startMinute, finishMinute)
    local farm = self:getFarm(farmId,true)
    farm.workforce = farm.workforce or {}
    local row = farm.workforce[tostring(profileId)] or {}
    row.schedule = {start=clamp(startMinute,0,1439),finish=clamp(finishMinute,1,1440)}
    if row.schedule.finish <= row.schedule.start then return AgriLife.Result.fail("ENTERPRISE_SCHEDULE_INVALID", "Invalid schedule") end
    farm.workforce[tostring(profileId)] = row
    return AgriLife.Result.ok("ENTERPRISE_SCHEDULE_UPDATED", "Schedule updated", {schedule=cloneTable(row.schedule)})
end

function AgriLife.Enterprise6Service:getEmployeeDailyTime(farmId, profileId)
    local status = self:getWorkforceStatus(farmId, profileId)
    local schedule = status.schedule or {start=480,finish=1020}
    local planned = math.max(0,(schedule.finish or 1020)-(schedule.start or 480))
    return {plannedMinutes=planned, overtimeMinutes=tonumber(status.overtime) or 0, absenceDays=tonumber(status.absences) or 0, leaveDays=tonumber(status.leave) or 0, sicknessDays=tonumber(status.sickness) or 0}
end

function AgriLife.Enterprise6Service:scheduleEmployeeLeave(farmId, profileId, days)
    local farm = self:getFarm(farmId,true); farm.workforce=farm.workforce or {}; local row=farm.workforce[tostring(profileId)] or {schedule={start=480,finish=1020}}
    row.leave=(tonumber(row.leave) or 0)+math.max(1,math.floor(tonumber(days) or 1)); row.status="LEAVE"; farm.workforce[tostring(profileId)]=row
    return AgriLife.Result.ok("ENTERPRISE_LEAVE_SCHEDULED","Leave scheduled",{days=row.leave})
end

function AgriLife.Enterprise6Service:recordEmployeeSickness(farmId, profileId, days)
    local farm=self:getFarm(farmId,true); farm.workforce=farm.workforce or {}; local row=farm.workforce[tostring(profileId)] or {schedule={start=480,finish=1020}}
    row.sickness=(tonumber(row.sickness) or 0)+math.max(1,math.floor(tonumber(days) or 1)); row.status="SICK"; farm.workforce[tostring(profileId)]=row
    return AgriLife.Result.ok("ENTERPRISE_SICKNESS_RECORDED","Sickness recorded",{days=row.sickness})
end

function AgriLife.Enterprise6Service:recordEmployeeAbsence(farmId, profileId, days)
    local farm=self:getFarm(farmId,true); farm.workforce=farm.workforce or {}; local row=farm.workforce[tostring(profileId)] or {schedule={start=480,finish=1020}}
    row.absences=(tonumber(row.absences) or 0)+math.max(1,math.floor(tonumber(days) or 1)); row.status="ABSENT"; farm.workforce[tostring(profileId)]=row
    self:recordReputation(farm,-0.2,"EMPLOYEE_ABSENCE")
    return AgriLife.Result.ok("ENTERPRISE_ABSENCE_RECORDED","Absence recorded",{days=row.absences})
end

function AgriLife.Enterprise6Service:setEmployeeBreak(farmId, profileId, active)
    local farm=self:getFarm(farmId,true); farm.workforce=farm.workforce or {}; local row=farm.workforce[tostring(profileId)] or {schedule={start=480,finish=1020}}
    row.breakActive=active==true; row.status=row.breakActive and "BREAK" or "AVAILABLE"; farm.workforce[tostring(profileId)]=row
    return AgriLife.Result.ok("ENTERPRISE_BREAK_UPDATED","Break updated",{active=row.breakActive})
end

function AgriLife.Enterprise6Service:clearEmployeeAvailabilityStatus(farmId, profileId)
    return self:setEmployeeWorkforceStatus(farmId,profileId,"AVAILABLE")
end

function AgriLife.Enterprise6Service:renewEmploymentContract(farmId, profileId, months)
    local farm=self:getFarm(farmId,true); farm.contracts=farm.contracts or {}; farm.contracts[tostring(profileId)]={remainingMonths=math.max(1,math.floor(tonumber(months) or 12))}
    return AgriLife.Result.ok("ENTERPRISE_CONTRACT_RENEWED","Contract renewed",cloneTable(farm.contracts[tostring(profileId)]))
end

function AgriLife.Enterprise6Service:raiseEmployeeSalary(farmId, profileId, amount)
    local details=self:getEmployeeDetails(farmId,profileId); if details==nil then return AgriLife.Result.fail("ENTERPRISE_EMPLOYEE_UNKNOWN","Employee not found") end
    local current=tonumber(details.salary or details.monthlySalary) or 0
    return self:updateEmploymentContract(farmId,profileId,current+math.max(1,tonumber(amount) or 100),details.contractType)
end

function AgriLife.Enterprise6Service:getDismissalCost(farmId, profileId)
    local details=self:getEmployeeDetails(farmId,profileId); local salary=details~=nil and tonumber(details.salary or details.monthlySalary) or 0
    local status=self:getWorkforceStatus(farmId,profileId); local seniority=tonumber(status.seniorityMonths) or 0
    return round(salary*(0.5+math.min(2,seniority/24)))
end

function AgriLife.Enterprise6Service:dismissEmployee(farmId, profileId)
    local cost=self:getDismissalCost(farmId,profileId)
    local economy=self:getEconomyService()
    if cost>0 and economy~=nil and economy.addMoney~=nil then economy:addMoney(farmId,-cost,"DISMISSAL_COST") end
    local result=self:terminateEmployee(farmId,profileId)
    if result~=nil and result.ok==true then self:recordReputation(self:getFarm(farmId,true),-1,"EMPLOYEE_DISMISSED") end
    return result or AgriLife.Result.fail("ENTERPRISE_DISMISS_FAILED","Dismissal failed")
end

function AgriLife.Enterprise6Service:getVehicleWorkCapabilities(vehicle)
    if vehicle==nil then return {} end
    local capabilities={TRANSPORT=true}
    local specs=vehicle.spec_workArea and vehicle.spec_workArea.workAreas or {}
    if vehicle.spec_sowingMachine~=nil then capabilities.SOW=true end
    if vehicle.spec_cultivator~=nil then capabilities.CULTIVATE=true end
    if vehicle.spec_plow~=nil then capabilities.PLOW=true end
    if vehicle.spec_mower~=nil then capabilities.MOW=true end
    if vehicle.spec_baler~=nil then capabilities.BALE=true end
    if vehicle.spec_sprayer~=nil then capabilities.SPRAY=true; capabilities.FERTILIZE=true end
    if vehicle.spec_combine~=nil or vehicle.spec_cutter~=nil then capabilities.HARVEST=true end
    if vehicle.spec_roller~=nil then capabilities.ROLL=true end
    if #specs>0 then capabilities.FIELD=true end
    return capabilities
end

function AgriLife.Enterprise6Service:createWorkOrder(farmId, profileId, vehicleId, workType, fieldId)
    local farm=self:getFarm(farmId,true); if farm==nil then return AgriLife.Result.fail("ENTERPRISE_FARM_INVALID","Invalid farm") end
    local id=string.format("WO_%d_%06d",farmId,farm.nextOrderId); farm.nextOrderId=farm.nextOrderId+1
    local order={id=id,profileId=tostring(profileId or ""),vehicleId=tostring(vehicleId or ""),workType=tostring(workType or "TRANSPORT"),fieldId=tonumber(fieldId) or 0,status="planned",createdDay=currentDay(),createdMinute=nowMinute(),progress=0}
    farm.workOrders[#farm.workOrders+1]=order
    return AgriLife.Result.ok("ENTERPRISE_ORDER_CREATED","Work order created",{order=cloneTable(order)})
end

function AgriLife.Enterprise6Service:getOrder(farm, orderId)
    for _,order in ipairs(farm.workOrders or {}) do if tostring(order.id)==tostring(orderId) then return order end end
    return nil
end

function AgriLife.Enterprise6Service:startWorkOrder(farmId, orderId)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil then return AgriLife.Result.fail("ENTERPRISE_ORDER_UNKNOWN","Order not found") end
    if order.status~="planned" and order.status~="paused" then return AgriLife.Result.fail("ENTERPRISE_ORDER_STATE","Order cannot start") end
    order.status="active"; order.startedDay=currentDay(); order.startedMinute=nowMinute(); self:setEmployeeWorkforceStatus(farmId,order.profileId,"ASSIGNED")
    return AgriLife.Result.ok("ENTERPRISE_ORDER_STARTED","Work order started",{order=cloneTable(order)})
end

function AgriLife.Enterprise6Service:pauseWorkOrder(farmId, orderId)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil or order.status~="active" then return AgriLife.Result.fail("ENTERPRISE_ORDER_STATE","Order cannot pause") end
    order.status="paused"; self:setEmployeeWorkforceStatus(farmId,order.profileId,"PAUSED"); return AgriLife.Result.ok("ENTERPRISE_ORDER_PAUSED","Work order paused",{order=cloneTable(order)})
end

function AgriLife.Enterprise6Service:resumeWorkOrder(farmId, orderId) return self:startWorkOrder(farmId,orderId) end

function AgriLife.Enterprise6Service:cancelWorkOrder(farmId, orderId)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil then return AgriLife.Result.fail("ENTERPRISE_ORDER_UNKNOWN","Order not found") end
    if order.status=="completed" or order.status=="cancelled" then return AgriLife.Result.fail("ENTERPRISE_ORDER_FINAL","Order already final") end
    order.status="cancelled"; self:setEmployeeWorkforceStatus(farmId,order.profileId,"AVAILABLE"); self:recordReputation(farm,-0.1,"WORK_CANCELLED")
    return AgriLife.Result.ok("ENTERPRISE_ORDER_CANCELLED","Work order cancelled",{order=cloneTable(order)})
end

function AgriLife.Enterprise6Service:completeWorkOrder(farmId, orderId, success)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil then return AgriLife.Result.fail("ENTERPRISE_ORDER_UNKNOWN","Order not found") end
    order.status=success==false and "failed" or "completed"; order.progress=success==false and order.progress or 1; order.completedDay=currentDay(); self:setEmployeeWorkforceStatus(farmId,order.profileId,"AVAILABLE")
    self:recordReputation(farm,success==false and -0.8 or 0.5,success==false and "WORK_FAILED" or "WORK_COMPLETED")
    return AgriLife.Result.ok("ENTERPRISE_ORDER_COMPLETED","Work order closed",{order=cloneTable(order)})
end

function AgriLife.Enterprise6Service:getEmployeeTrainingCatalog(farmId, profileId)
    local rows={}
    for i,specialty in ipairs(SPECIALTIES) do rows[#rows+1]={id="TRAIN_"..specialty,specialty=specialty,cost=500+i*125,durationPeriods=1+(i%2)} end
    return rows
end

function AgriLife.Enterprise6Service:startEmployeeTraining(farmId, actorProfileId, profileId, trainingId)
    local farm=self:getFarm(farmId,true); farm.training=farm.training or {}; local key=tostring(profileId)
    if farm.training[key]~=nil then return AgriLife.Result.fail("ENTERPRISE_TRAINING_ACTIVE","Training already active") end
    local selected=nil; for _,row in ipairs(self:getEmployeeTrainingCatalog(farmId,profileId)) do if row.id==trainingId then selected=row break end end
    if selected==nil then return AgriLife.Result.fail("ENTERPRISE_TRAINING_UNKNOWN","Training not found") end
    farm.training[key]={id=selected.id,specialty=selected.specialty,remainingPeriods=selected.durationPeriods,cost=selected.cost,startedDay=currentDay()}
    return AgriLife.Result.ok("ENTERPRISE_TRAINING_STARTED","Training started",cloneTable(farm.training[key]))
end

function AgriLife.Enterprise6Service:getEmployeeTrainingStatus(farmId, profileId)
    local farm=self:getFarm(farmId,true); return cloneTable((farm.training or {})[tostring(profileId)] or {})
end

function AgriLife.Enterprise6Service:completeQualificationTraining(farmId, profileId)
    local farm=self:getFarm(farmId,true); farm.training=farm.training or {}; local key=tostring(profileId); local training=farm.training[key]
    if training==nil then return AgriLife.Result.fail("ENTERPRISE_TRAINING_NONE","No active training") end
    table.insert(farm.trainingHistory,1,{profileId=key,specialty=training.specialty,day=currentDay()}); farm.training[key]=nil
    return AgriLife.Result.ok("ENTERPRISE_TRAINING_COMPLETED","Training completed",{specialty=training.specialty})
end

function AgriLife.Enterprise6Service:getEmployeeCareerProfile(farmId, profileId)
    local farm=self:getFarm(farmId,true); farm.careers=farm.careers or {}; local key=tostring(profileId); local row=farm.careers[key]
    if row==nil then row={workforceLevel=1,totalXP=0,performanceScore=50,completedOrders=0,failedOrders=0,trainingCount=0,incidents=0,promotions=0,seniorityMonths=0}; farm.careers[key]=row end
    return cloneTable(row)
end

function AgriLife.Enterprise6Service:getPromotionEligibility(farmId, profileId)
    local career=self:getEmployeeCareerProfile(farmId,profileId); local required=career.workforceLevel*1000
    local eligible=(career.totalXP or 0)>=required and (career.performanceScore or 0)>=60
    return {eligible=eligible,requiredXP=required,currentXP=career.totalXP or 0,requiredPerformance=60,currentPerformance=career.performanceScore or 0,nextLevel=(career.workforceLevel or 1)+1}
end

function AgriLife.Enterprise6Service:promoteEmployeeCareer(farmId, actorProfileId, profileId)
    local eligibility=self:getPromotionEligibility(farmId,profileId); if not eligibility.eligible then return AgriLife.Result.fail("ENTERPRISE_PROMOTION_LOCKED","Promotion requirements not met",eligibility) end
    local farm=self:getFarm(farmId,true); local career=farm.careers[tostring(profileId)]; career.workforceLevel=(career.workforceLevel or 1)+1; career.promotions=(career.promotions or 0)+1; career.performanceScore=clamp((career.performanceScore or 50)+3,0,100)
    return AgriLife.Result.ok("ENTERPRISE_PROMOTED","Employee promoted",{career=cloneTable(career)})
end

function AgriLife.Enterprise6Service:enqueueWorkOrder(farmId, orderId, priority)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil then return AgriLife.Result.fail("ENTERPRISE_ORDER_UNKNOWN","Order not found") end
    local item={id=string.format("WQ_%d_%06d",farmId,farm.nextQueueId),orderId=tostring(orderId),priority=tonumber(priority) or 0,status="QUEUED",createdDay=currentDay()}; farm.nextQueueId=farm.nextQueueId+1; farm.workQueue[#farm.workQueue+1]=item
    return AgriLife.Result.ok("ENTERPRISE_ORDER_QUEUED","Order queued",{queue=cloneTable(item)})
end

function AgriLife.Enterprise6Service:getWorkQueue(farmId)
    local farm=self:getFarm(farmId,true); local rows={}; for _,row in ipairs(farm.workQueue or {}) do rows[#rows+1]=cloneTable(row) end; table.sort(rows,function(a,b) if a.priority==b.priority then return tostring(a.id)<tostring(b.id) end return (a.priority or 0)>(b.priority or 0) end); return rows
end

function AgriLife.Enterprise6Service:cancelQueuedWork(farmId, queueId)
    local farm=self:getFarm(farmId,true); for _,row in ipairs(farm.workQueue or {}) do if tostring(row.id)==tostring(queueId) and row.status=="QUEUED" then row.status="CANCELLED"; return AgriLife.Result.ok("ENTERPRISE_QUEUE_CANCELLED","Queued work cancelled") end end; return AgriLife.Result.fail("ENTERPRISE_QUEUE_UNKNOWN","Queue item not found")
end

function AgriLife.Enterprise6Service:dispatchQueuedWork(farmId, queueId)
    local farm=self:getFarm(farmId,true); for _,row in ipairs(farm.workQueue or {}) do if tostring(row.id)==tostring(queueId) and row.status=="QUEUED" then local result=self:startWorkOrder(farmId,row.orderId); if result~=nil and result.ok==true then row.status="DISPATCHED" end; return result end end; return AgriLife.Result.fail("ENTERPRISE_QUEUE_UNKNOWN","Queue item not found")
end

function AgriLife.Enterprise6Service:processWorkQueue(farmId)
    for _,row in ipairs(self:getWorkQueue(farmId)) do if row.status=="QUEUED" then return self:dispatchQueuedWork(farmId,row.id) end end
    return AgriLife.Result.ok("ENTERPRISE_QUEUE_IDLE","No queued work")
end

function AgriLife.Enterprise6Service:reportWorkIncident(farmId, profileId, orderId, severity, reason)
    local farm=self:getFarm(farmId,true); local incident={id=string.format("INC_%d_%06d",farmId,#farm.incidents+1),profileId=tostring(profileId),orderId=tostring(orderId or ""),severity=clamp(severity or 1,1,5),reason=tostring(reason or "WORK_INCIDENT"),day=currentDay()}; table.insert(farm.incidents,1,incident)
    local career=self:getEmployeeCareerProfile(farmId,profileId); farm.careers[tostring(profileId)].incidents=(career.incidents or 0)+1; farm.careers[tostring(profileId)].performanceScore=clamp((career.performanceScore or 50)-incident.severity*2,0,100); self:recordReputation(farm,-incident.severity*0.2,"WORK_INCIDENT")
    return AgriLife.Result.ok("ENTERPRISE_INCIDENT_RECORDED","Incident recorded",{incident=cloneTable(incident)})
end

function AgriLife.Enterprise6Service:getEmployeeIncidents(farmId, profileId)
    local farm=self:getFarm(farmId,true); local rows={}; for _,incident in ipairs(farm.incidents or {}) do if tostring(incident.profileId)==tostring(profileId) then rows[#rows+1]=cloneTable(incident) end end; return rows
end

function AgriLife.Enterprise6Service:getWorkforceForecast(farmId)
    local profiles=self:getPayrollProfiles(farmId); local available=0; local assigned=0; local unavailable=0; local capacity=0
    for _,profile in ipairs(profiles or {}) do local id=tostring(profile.id or profile.profileId or ""); if id~="" then local status=self:getWorkforceStatus(farmId,id); if status.status=="AVAILABLE" then available=available+1 elseif status.status=="ASSIGNED" or status.status=="PAUSED" then assigned=assigned+1 else unavailable=unavailable+1 end; local schedule=status.schedule or {start=480,finish=1020}; capacity=capacity+math.max(0,(schedule.finish or 1020)-(schedule.start or 480)) end end
    return {total=#profiles,available=available,assigned=assigned,unavailable=unavailable,capacityMinutes=capacity,pressure=capacity>0 and clamp((assigned*540)/capacity,0,2) or 0}
end

function AgriLife.Enterprise6Service:getWorkforcePlanningSnapshot(farmId, profileId)
    return {employee=self:getEmployeeDetails(farmId,profileId),status=self:getWorkforceStatus(farmId,profileId),time=self:getEmployeeDailyTime(farmId,profileId),career=self:getEmployeeCareerProfile(farmId,profileId),promotion=self:getPromotionEligibility(farmId,profileId),training=self:getEmployeeTrainingStatus(farmId,profileId),incidents=self:getEmployeeIncidents(farmId,profileId),forecast=self:getWorkforceForecast(farmId)}
end

function AgriLife.Enterprise6Service:getEmployeeFullSheet(farmId, profileId)
    local snapshot=self:getWorkforcePlanningSnapshot(farmId,profileId); snapshot.schedule=self:getEmployeeSchedule(farmId,profileId); snapshot.dismissalCost=self:getDismissalCost(farmId,profileId); return snapshot
end

function AgriLife.Enterprise6Service:getEmployeeMachineFamiliarity(farmId, profileId)
    local farm=self:getFarm(farmId,true); farm.familiarity=farm.familiarity or {}; local key=tostring(profileId); farm.familiarity[key]=farm.familiarity[key] or {}; return cloneTable(farm.familiarity[key])
end

function AgriLife.Enterprise6Service:getReputationOpportunityProfile(farmId)
    local factors=self:getReputationFactors(farmId); return {reputation=factors.reputation,recruitment=factors.recruitmentQuality,contracts=factors.contractAccess,wagePressure=factors.wagePressure,band=factors.reputation>=80 and "EXCELLENT" or factors.reputation>=60 and "GOOD" or factors.reputation>=40 and "AVERAGE" or "WEAK"}
end

function AgriLife.Enterprise6Service:recordBusinessReputationEvent(farmId, amount, reason) return self:changeReputation(farmId,amount,reason) end

function AgriLife.Enterprise6Service:getRoadmap4Checklist(farmId)
    local farm=self:getFarm(farmId,true); return {recruitment=#self:getRecruitmentMarket(farmId)>0,workforce=#self:getPayrollProfiles(farmId)>=0,planning=self:getWorkforceForecast(farmId)~=nil,career=true,training=true,incidents=true,reputation=farm~=nil}
end

function AgriLife.Enterprise6Service:configureWorkOrderExecution(farmId, orderId, options)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); if order==nil then return AgriLife.Result.fail("ENTERPRISE_ORDER_UNKNOWN","Order not found") end; order.execution=cloneTable(options or {}); return AgriLife.Result.ok("ENTERPRISE_ORDER_EXECUTION_CONFIGURED","Execution configured",{execution=cloneTable(order.execution)})
end

function AgriLife.Enterprise6Service:getWorkOrderExecutionOptions(farmId, orderId)
    local farm=self:getFarm(farmId,true); local order=self:getOrder(farm,orderId); return order~=nil and cloneTable(order.execution or {}) or {}
end

function AgriLife.Enterprise6Service:onAIJobStopped(job, success)
    for farmId,farm in pairs(self.farms) do
        for _,order in ipairs(farm.workOrders or {}) do
            if order.status=="active" and order.execution~=nil and order.execution.aiJobId~=nil and tostring(order.execution.aiJobId)==tostring(job and job.id or "") then self:completeWorkOrder(farmId,order.id,success~=false) end
        end
    end
end

function AgriLife.Enterprise6Service:onPeriodChanged()
    for farmId,farm in pairs(self.farms) do
        farm.lastPeriod=(tonumber(farm.lastPeriod) or 0)+1
        for _,career in pairs(farm.careers or {}) do career.seniorityMonths=(tonumber(career.seniorityMonths) or 0)+1 end
        for profileId,training in pairs(farm.training or {}) do training.remainingPeriods=(tonumber(training.remainingPeriods) or 1)-1; if training.remainingPeriods<=0 then self:completeQualificationTraining(farmId,profileId) end end
    end
end

function AgriLife.Enterprise6Service:update(dt)
end

function AgriLife.Enterprise6Service:saveFarm(xmlFile, key, farmId)
    local farm=self:getFarm(farmId,false); if farm==nil then return AgriLife.Result.ok("ENTERPRISE_SAVE_EMPTY","Nothing to save") end
    local base=string.format("%s.enterprise",key); setXMLInt(xmlFile,base.."#reputation",math.floor((farm.reputation or 50)*100)); setXMLInt(xmlFile,base.."#nextEmployeeId",farm.nextEmployeeId or 1); setXMLInt(xmlFile,base.."#nextOrderId",farm.nextOrderId or 1); setXMLInt(xmlFile,base.."#nextQueueId",farm.nextQueueId or 1); setXMLInt(xmlFile,base.."#candidateRefresh",farm.candidateRefresh or 0)
    local function saveRows(name,rows,writer) for i,row in ipairs(rows or {}) do writer(string.format("%s.%s(%d)",base,name,i-1),row) end end
    saveRows("workOrders",farm.workOrders,function(k,row) setXMLString(xmlFile,k.."#id",row.id or ""); setXMLString(xmlFile,k.."#profileId",row.profileId or ""); setXMLString(xmlFile,k.."#vehicleId",row.vehicleId or ""); setXMLString(xmlFile,k.."#workType",row.workType or ""); setXMLInt(xmlFile,k.."#fieldId",row.fieldId or 0); setXMLString(xmlFile,k.."#status",row.status or "planned"); setXMLFloat(xmlFile,k.."#progress",row.progress or 0) end)
    saveRows("incidents",farm.incidents,function(k,row) setXMLString(xmlFile,k.."#id",row.id or ""); setXMLString(xmlFile,k.."#profileId",row.profileId or ""); setXMLString(xmlFile,k.."#orderId",row.orderId or ""); setXMLInt(xmlFile,k.."#severity",row.severity or 1); setXMLString(xmlFile,k.."#reason",row.reason or ""); setXMLInt(xmlFile,k.."#day",row.day or 0) end)
    local cIndex=0; for profileId,row in pairs(farm.careers or {}) do local k=string.format("%s.careers(%d)",base,cIndex); cIndex=cIndex+1; setXMLString(xmlFile,k.."#profileId",profileId); setXMLInt(xmlFile,k.."#level",row.workforceLevel or 1); setXMLInt(xmlFile,k.."#xp",row.totalXP or 0); setXMLFloat(xmlFile,k.."#performance",row.performanceScore or 50); setXMLInt(xmlFile,k.."#completed",row.completedOrders or 0); setXMLInt(xmlFile,k.."#failed",row.failedOrders or 0); setXMLInt(xmlFile,k.."#training",row.trainingCount or 0); setXMLInt(xmlFile,k.."#incidents",row.incidents or 0); setXMLInt(xmlFile,k.."#promotions",row.promotions or 0); setXMLInt(xmlFile,k.."#seniority",row.seniorityMonths or 0) end
    return AgriLife.Result.ok("ENTERPRISE_SAVED","Enterprise saved")
end

function AgriLife.Enterprise6Service:loadFarm(xmlFile, key, farmId)
    local farm=self:getFarm(farmId,true); local base=string.format("%s.enterprise",key); farm.reputation=(getXMLInt(xmlFile,base.."#reputation") or 5000)/100; farm.nextEmployeeId=getXMLInt(xmlFile,base.."#nextEmployeeId") or 1; farm.nextOrderId=getXMLInt(xmlFile,base.."#nextOrderId") or 1; farm.nextQueueId=getXMLInt(xmlFile,base.."#nextQueueId") or 1; farm.candidateRefresh=getXMLInt(xmlFile,base.."#candidateRefresh") or 0
    farm.workOrders={}; local i=0; while true do local k=string.format("%s.workOrders(%d)",base,i); local id=getXMLString(xmlFile,k.."#id"); if id==nil then break end; farm.workOrders[#farm.workOrders+1]={id=id,profileId=getXMLString(xmlFile,k.."#profileId") or "",vehicleId=getXMLString(xmlFile,k.."#vehicleId") or "",workType=getXMLString(xmlFile,k.."#workType") or "TRANSPORT",fieldId=getXMLInt(xmlFile,k.."#fieldId") or 0,status=getXMLString(xmlFile,k.."#status") or "planned",progress=getXMLFloat(xmlFile,k.."#progress") or 0}; i=i+1 end
    farm.incidents={}; i=0; while true do local k=string.format("%s.incidents(%d)",base,i); local id=getXMLString(xmlFile,k.."#id"); if id==nil then break end; farm.incidents[#farm.incidents+1]={id=id,profileId=getXMLString(xmlFile,k.."#profileId") or "",orderId=getXMLString(xmlFile,k.."#orderId") or "",severity=getXMLInt(xmlFile,k.."#severity") or 1,reason=getXMLString(xmlFile,k.."#reason") or "",day=getXMLInt(xmlFile,k.."#day") or 0}; i=i+1 end
    farm.careers={}; i=0; while true do local k=string.format("%s.careers(%d)",base,i); local profileId=getXMLString(xmlFile,k.."#profileId"); if profileId==nil then break end; farm.careers[profileId]={workforceLevel=getXMLInt(xmlFile,k.."#level") or 1,totalXP=getXMLInt(xmlFile,k.."#xp") or 0,performanceScore=getXMLFloat(xmlFile,k.."#performance") or 50,completedOrders=getXMLInt(xmlFile,k.."#completed") or 0,failedOrders=getXMLInt(xmlFile,k.."#failed") or 0,trainingCount=getXMLInt(xmlFile,k.."#training") or 0,incidents=getXMLInt(xmlFile,k.."#incidents") or 0,promotions=getXMLInt(xmlFile,k.."#promotions") or 0,seniorityMonths=getXMLInt(xmlFile,k.."#seniority") or 0}; i=i+1 end
    return AgriLife.Result.ok("ENTERPRISE_LOADED","Enterprise loaded")
end

function AgriLife.Enterprise6Service:delete()
    self.farms={}; self.core=nil
end

function AgriLife.Enterprise6Service:getSnapshot(farmId)
    local farm=self:getFarm(farmId,true)
    return {farmId=farmId,reputation=farm.reputation,reputationFactors=self:getReputationFactors(farmId),candidates=self:getRecruitmentMarket(farmId),workOrders=cloneTable(farm.workOrders),queue=self:getWorkQueue(farmId),forecast=self:getWorkforceForecast(farmId),employees=self:getPayrollProfiles(farmId)}
end