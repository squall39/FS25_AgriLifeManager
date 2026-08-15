-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.EnterpriseWorkerExecution09359 = {}
AgriLife.EnterpriseWorkerExecution09359.__index = AgriLife.EnterpriseWorkerExecution09359
AgriLife.EnterpriseWorkerExecution09359.VERSION = "0.9.3.59"

local WorkerExecution = AgriLife.EnterpriseWorkerExecution09359

WorkerExecution.STATE = {
    IDLE = "IDLE",
    FETCH_EQUIPMENT = "FETCH_EQUIPMENT",
    TRANSIT_TO_FIELD = "TRANSIT_TO_FIELD",
    FIELDWORK = "FIELDWORK",
    RETURN_EQUIPMENT = "RETURN_EQUIPMENT",
    RETURN_VEHICLE = "RETURN_VEHICLE",
    COMPLETE = "COMPLETE",
    FAILED = "FAILED",
    CANCELLED = "CANCELLED"
}

WorkerExecution.FIELD_TRANSIT_DISTANCE = 150
WorkerExecution.FIELD_DIRECT_START_DISTANCE = 50
WorkerExecution.RETURN_SKIP_DISTANCE = 4

local function safeCall(target, methodName, ...)
    if target == nil then return false, nil end
    local fn = target[methodName]
    if type(fn) ~= "function" then return false, nil end
    return pcall(fn, target, ...)
end

local function log(level, formatText, ...)
    local text = string.format(tostring(formatText or ""), ...)
    if AgriLife.Logger ~= nil then
        local fn = AgriLife.Logger[string.lower(tostring(level or "info"))]
        if type(fn) == "function" then
            local ok = pcall(fn, "EnterpriseWorker", "%s", text)
            if ok then return end
        end
    end
    if Logging ~= nil then
        local fn = Logging[string.lower(tostring(level or "info"))]
        if type(fn) == "function" then pcall(fn, "[AgriLife][EnterpriseWorker] %s", text) end
    end
end

local function getObjectRootNode(object)
    if object == nil then return nil end
    return object.rootNode or object.nodeId
end

local function objectKey(object)
    if object == nil then return nil end
    return tostring(object.id or object.rootNode or object.nodeId or object)
end

local function capturePose(object)
    local rootNode = getObjectRootNode(object)
    if rootNode == nil or getWorldTranslation == nil then return nil end

    local x, y, z = getWorldTranslation(rootNode)
    local angle = 0
    if localDirectionToWorld ~= nil and MathUtil ~= nil and MathUtil.getYRotationFromDirection ~= nil then
        local dx, _, dz = localDirectionToWorld(rootNode, 0, 0, 1)
        angle = MathUtil.getYRotationFromDirection(dx, dz)
    end

    return {x = x, y = y, z = z, angle = angle}
end

local function distance2DFromPose(object, pose)
    if object == nil or pose == nil then return math.huge end
    local rootNode = getObjectRootNode(object)
    if rootNode == nil or getWorldTranslation == nil then return math.huge end
    local x, _, z = getWorldTranslation(rootNode)
    local dx = x - (tonumber(pose.x) or 0)
    local dz = z - (tonumber(pose.z) or 0)
    return math.sqrt(dx * dx + dz * dz)
end

local function getFieldTarget(fieldId)
    if g_fieldManager == nil or g_fieldManager.getFieldById == nil then return nil, "FIELD_MANAGER_UNAVAILABLE" end
    local field = g_fieldManager:getFieldById(tonumber(fieldId) or 0)
    if field == nil then return nil, "FIELD_NOT_FOUND" end

    if field.getCenterOfFieldWorldPosition ~= nil then
        local x, z = field:getCenterOfFieldWorldPosition()
        if x ~= nil and z ~= nil then return {x = x, z = z, field = field}, nil end
    end

    return nil, "FIELD_CENTER_UNAVAILABLE"
end

local function isObjectAttachedTo(vehicle, object)
    if vehicle == nil or object == nil or vehicle.getAttachedImplements == nil then return false end
    local ok, implements = pcall(vehicle.getAttachedImplements, vehicle)
    if not ok or type(implements) ~= "table" then return false end

    for _, implement in ipairs(implements) do
        local attachedObject = implement ~= nil and implement.object or nil
        if attachedObject == object then return true end
        if attachedObject ~= nil and isObjectAttachedTo(attachedObject, object) then return true end
    end
    return false
end

local function getJobId(job)
    if type(job) == "number" or type(job) == "string" then return tostring(job) end
    if type(job) ~= "table" then return nil end
    return job.jobId ~= nil and tostring(job.jobId) or job.id ~= nil and tostring(job.id) or nil
end

function WorkerExecution.new(core, callbacks)
    local self = setmetatable({}, WorkerExecution)
    self.core = core
    self.callbacks = callbacks or {}
    self.assignments = {}
    self.assignmentsByJobId = {}
    self.vehicleReservations = {}
    return self
end

function WorkerExecution:setCallbacks(callbacks)
    self.callbacks = callbacks or {}
end

function WorkerExecution:setState(assignment, state, reason)
    if assignment == nil then return end
    local previous = assignment.state or WorkerExecution.STATE.IDLE
    assignment.state = state
    assignment.stateReason = reason
    log("info", "Order %s: %s -> %s%s", tostring(assignment.orderId), tostring(previous), tostring(state), reason ~= nil and (" (" .. tostring(reason) .. ")") or "")
end

function WorkerExecution:prepareVehicle(vehicle)
    if vehicle == nil then return end

    if vehicle.getIsMotorStarted ~= nil and vehicle.startMotor ~= nil then
        local ok, started = pcall(vehicle.getIsMotorStarted, vehicle)
        if ok and started ~= true then pcall(vehicle.startMotor, vehicle) end
    elseif vehicle.startMotor ~= nil then
        pcall(vehicle.startMotor, vehicle)
    end

    if vehicle.setBrakePedalInput ~= nil then pcall(vehicle.setBrakePedalInput, vehicle, 0) end
    if vehicle.setCruiseControlState ~= nil and Drivable ~= nil and Drivable.CRUISECONTROL_STATE_OFF ~= nil then
        pcall(vehicle.setCruiseControlState, vehicle, Drivable.CRUISECONTROL_STATE_OFF)
    end
end

function WorkerExecution:bindJob(assignment, aiJob)
    local jobId = getJobId(aiJob)
    if jobId == nil then return end
    if assignment.aiJobId ~= nil then self.assignmentsByJobId[tostring(assignment.aiJobId)] = nil end
    assignment.aiJobId = jobId
    self.assignmentsByJobId[jobId] = assignment
end

function WorkerExecution:clearJob(assignment)
    if assignment == nil then return end
    if assignment.aiJobId ~= nil then self.assignmentsByJobId[tostring(assignment.aiJobId)] = nil end
    assignment.aiJobId = nil
end

function WorkerExecution:isAIStopSuccessful(aiMessage)
    if type(self.callbacks.isAIStopSuccessful) == "function" then
        local ok, value = pcall(self.callbacks.isAIStopSuccessful, aiMessage)
        if ok then return value == true end
    end

    if aiMessage == nil then return true end

    if type(aiMessage) == "table" then
        if aiMessage.isError == true or aiMessage.error == true or aiMessage.failed == true then return false end
        if aiMessage.success == true or aiMessage.completed == true or aiMessage.finished == true then return true end
        if aiMessage.getIsError ~= nil then
            local ok, value = pcall(aiMessage.getIsError, aiMessage)
            if ok then return value ~= true end
        end
    end

    return true
end

function WorkerExecution:startGoto(assignment, targetPose, state)
    if assignment == nil or assignment.vehicle == nil then return false, "VEHICLE_UNAVAILABLE" end
    if targetPose == nil then return false, "TARGET_UNAVAILABLE" end
    if g_currentMission == nil or g_currentMission.aiJobTypeManager == nil or g_currentMission.aiSystem == nil then
        return false, "AI_SYSTEM_UNAVAILABLE"
    end
    if AIJobType == nil or AIJobType.GOTO == nil then return false, "AI_GOTO_UNAVAILABLE" end

    self:prepareVehicle(assignment.vehicle)

    local aiJob = g_currentMission.aiJobTypeManager:createJob(AIJobType.GOTO)
    if aiJob == nil then return false, "AI_GOTO_CREATE_FAILED" end

    local okApply = pcall(aiJob.applyCurrentState, aiJob, assignment.vehicle, g_currentMission, assignment.farmId, false)
    if not okApply then return false, "AI_GOTO_STATE_FAILED" end

    if aiJob.positionAngleParameter == nil then return false, "AI_GOTO_PARAMETER_MISSING" end
    aiJob.positionAngleParameter:setPosition(targetPose.x, targetPose.z)
    aiJob.positionAngleParameter:setAngle(tonumber(targetPose.angle) or 0)
    if aiJob.setValues ~= nil then aiJob:setValues() end

    local valid, errorMessage = aiJob:validate(assignment.farmId)
    if valid ~= true then return false, "AI_GOTO_VALIDATE_FAILED:" .. tostring(errorMessage) end

    self:setState(assignment, state)
    g_currentMission.aiSystem:startJob(aiJob, assignment.farmId)
    self:bindJob(assignment, aiJob)

    local aiActive = nil
    if assignment.vehicle.getIsAIActive ~= nil then
        local ok, value = pcall(assignment.vehicle.getIsAIActive, assignment.vehicle)
        if ok then aiActive = value end
    end
    log("info", "Order %s: GOTO started, jobId=%s, aiActive=%s", tostring(assignment.orderId), tostring(assignment.aiJobId), tostring(aiActive))
    return true, nil
end

function WorkerExecution:startFieldWork(assignment)
    if assignment == nil or assignment.vehicle == nil then return false, "VEHICLE_UNAVAILABLE" end
    if g_currentMission == nil or g_currentMission.aiJobTypeManager == nil or g_currentMission.aiSystem == nil then
        return false, "AI_SYSTEM_UNAVAILABLE"
    end
    if AIJobType == nil or AIJobType.FIELDWORK == nil then return false, "AI_FIELDWORK_UNAVAILABLE" end

    local target, reason = getFieldTarget(assignment.fieldId)
    if target == nil then return false, reason end

    self:prepareVehicle(assignment.vehicle)

    local aiJob = g_currentMission.aiJobTypeManager:createJob(AIJobType.FIELDWORK)
    if aiJob == nil then return false, "AI_FIELDWORK_CREATE_FAILED" end

    local vehiclePose = capturePose(assignment.vehicle)
    if vehiclePose == nil then return false, "VEHICLE_POSE_UNAVAILABLE" end
    local dx = vehiclePose.x - target.x
    local dz = vehiclePose.z - target.z
    local distance = math.sqrt(dx * dx + dz * dz)
    local directStart = distance < WorkerExecution.FIELD_DIRECT_START_DISTANCE

    local okApply = pcall(aiJob.applyCurrentState, aiJob, assignment.vehicle, g_currentMission, assignment.farmId, directStart)
    if not okApply then return false, "AI_FIELDWORK_STATE_FAILED" end

    if aiJob.positionAngleParameter ~= nil then
        if directStart then
            aiJob.positionAngleParameter:setAngle(vehiclePose.angle or 0)
        else
            aiJob.positionAngleParameter:setPosition(target.x, target.z)
        end
    end
    if aiJob.setValues ~= nil then aiJob:setValues() end

    local valid, errorMessage = aiJob:validate(assignment.farmId)
    if valid ~= true then return false, "AI_FIELDWORK_VALIDATE_FAILED:" .. tostring(errorMessage) end

    self:setState(assignment, WorkerExecution.STATE.FIELDWORK)
    g_currentMission.aiSystem:startJob(aiJob, assignment.farmId)
    self:bindJob(assignment, aiJob)

    local aiActive = nil
    if assignment.vehicle.getIsAIActive ~= nil then
        local ok, value = pcall(assignment.vehicle.getIsAIActive, assignment.vehicle)
        if ok then aiActive = value end
    end
    log("info", "Order %s: FIELDWORK started, direct=%s, distance=%.1f, jobId=%s, aiActive=%s", tostring(assignment.orderId), tostring(directStart), distance, tostring(assignment.aiJobId), tostring(aiActive))
    return true, nil
end

function WorkerExecution:startTransitOrFieldWork(assignment)
    local target, reason = getFieldTarget(assignment.fieldId)
    if target == nil then return self:failAssignment(assignment, reason) end

    local vehiclePose = capturePose(assignment.vehicle)
    if vehiclePose == nil then return self:failAssignment(assignment, "VEHICLE_POSE_UNAVAILABLE") end

    local dx = vehiclePose.x - target.x
    local dz = vehiclePose.z - target.z
    local distance = math.sqrt(dx * dx + dz * dz)

    if distance > WorkerExecution.FIELD_TRANSIT_DISTANCE then
        local tx = target.x
        local tz = target.z
        local angle = vehiclePose.angle or 0
        if MathUtil ~= nil and MathUtil.getYRotationFromDirection ~= nil then
            angle = MathUtil.getYRotationFromDirection(tx - vehiclePose.x, tz - vehiclePose.z)
        end
        local ok, errorReason = self:startGoto(assignment, {x = tx, z = tz, angle = angle}, WorkerExecution.STATE.TRANSIT_TO_FIELD)
        if not ok then return self:failAssignment(assignment, errorReason) end
        return true
    end

    local ok, errorReason = self:startFieldWork(assignment)
    if not ok then return self:failAssignment(assignment, errorReason) end
    return true
end

function WorkerExecution:startEquipmentFetch(assignment)
    local required = {}
    for _, row in ipairs(assignment.equipment or {}) do
        if row.wasAttached ~= true then required[#required + 1] = row end
    end

    if #required == 0 then return self:startTransitOrFieldWork(assignment) end

    self:setState(assignment, WorkerExecution.STATE.FETCH_EQUIPMENT)
    if type(self.callbacks.fetchEquipment) ~= "function" then
        return self:failAssignment(assignment, "NO_EQUIPMENT_FETCH_HANDLER")
    end

    local completed = false
    local function done(success, reason)
        if completed then return end
        completed = true
        self:continueAfterEquipmentFetch(assignment.orderId, success, reason)
    end

    local ok, result = pcall(self.callbacks.fetchEquipment, assignment, required, done)
    if not ok then return self:failAssignment(assignment, "EQUIPMENT_FETCH_HANDLER_ERROR:" .. tostring(result)) end
    if result == false and not completed then return self:failAssignment(assignment, "EQUIPMENT_FETCH_REJECTED") end
    return true
end

function WorkerExecution:continueAfterEquipmentFetch(orderId, success, reason)
    local assignment = self.assignments[tostring(orderId)]
    if assignment == nil or assignment.state ~= WorkerExecution.STATE.FETCH_EQUIPMENT then return false end
    if success ~= true then return self:failAssignment(assignment, reason or "EQUIPMENT_FETCH_FAILED") end
    return self:startTransitOrFieldWork(assignment)
end

function WorkerExecution:startEquipmentReturn(assignment)
    local borrowed = {}
    for _, row in ipairs(assignment.equipment or {}) do
        if row.wasAttached ~= true then borrowed[#borrowed + 1] = row end
    end

    if #borrowed == 0 then return self:startVehicleReturn(assignment) end

    self:setState(assignment, WorkerExecution.STATE.RETURN_EQUIPMENT)
    if type(self.callbacks.returnEquipment) ~= "function" then
        return self:failAssignment(assignment, "NO_EQUIPMENT_RETURN_HANDLER")
    end

    local completed = false
    local function done(success, reason)
        if completed then return end
        completed = true
        self:continueAfterEquipmentReturn(assignment.orderId, success, reason)
    end

    local ok, result = pcall(self.callbacks.returnEquipment, assignment, borrowed, done)
    if not ok then return self:failAssignment(assignment, "EQUIPMENT_RETURN_HANDLER_ERROR:" .. tostring(result)) end
    if result == false and not completed then return self:failAssignment(assignment, "EQUIPMENT_RETURN_REJECTED") end
    return true
end

function WorkerExecution:continueAfterEquipmentReturn(orderId, success, reason)
    local assignment = self.assignments[tostring(orderId)]
    if assignment == nil or assignment.state ~= WorkerExecution.STATE.RETURN_EQUIPMENT then return false end
    if success ~= true then return self:failAssignment(assignment, reason or "EQUIPMENT_RETURN_FAILED") end
    return self:startVehicleReturn(assignment)
end

function WorkerExecution:startVehicleReturn(assignment)
    if assignment.vehiclePose == nil then return self:failAssignment(assignment, "VEHICLE_RETURN_POSE_MISSING") end

    local distance = distance2DFromPose(assignment.vehicle, assignment.vehiclePose)
    if distance <= WorkerExecution.RETURN_SKIP_DISTANCE then
        self:setState(assignment, WorkerExecution.STATE.RETURN_VEHICLE, "already_at_origin")
        return self:completeAssignment(assignment)
    end

    local ok, reason = self:startGoto(assignment, assignment.vehiclePose, WorkerExecution.STATE.RETURN_VEHICLE)
    if not ok then return self:failAssignment(assignment, reason) end
    return true
end

function WorkerExecution:beginAssignment(order, vehicle, equipmentObjects)
    if type(order) ~= "table" then return false, "ORDER_INVALID" end
    local orderId = tostring(order.id or "")
    local farmId = tonumber(order.farmId) or tonumber(order.ownerFarmId) or 0
    local fieldId = tonumber(order.fieldId) or 0
    if orderId == "" then return false, "ORDER_ID_MISSING" end
    if farmId <= 0 then return false, "FARM_ID_INVALID" end
    if fieldId <= 0 then return false, "FIELD_ID_INVALID" end
    if vehicle == nil then return false, "VEHICLE_MISSING" end
    if self.assignments[orderId] ~= nil then return false, "ORDER_ALREADY_TRACKED" end

    local vehicleKey = objectKey(vehicle)
    if vehicleKey == nil then return false, "VEHICLE_ID_MISSING" end
    if self.vehicleReservations[vehicleKey] ~= nil then return false, "VEHICLE_ALREADY_RESERVED" end

    local vehiclePose = capturePose(vehicle)
    if vehiclePose == nil then return false, "VEHICLE_POSE_UNAVAILABLE" end

    local assignment = {
        orderId = orderId,
        order = order,
        farmId = farmId,
        profileId = tostring(order.profileId or ""),
        workType = tostring(order.workType or ""),
        fieldId = fieldId,
        vehicle = vehicle,
        vehicleKey = vehicleKey,
        vehiclePose = vehiclePose,
        equipment = {},
        state = WorkerExecution.STATE.IDLE,
        aiJobId = nil,
        startedAt = g_currentMission ~= nil and g_currentMission.time or 0
    }

    for _, object in ipairs(equipmentObjects or {}) do
        if object ~= nil then
            assignment.equipment[#assignment.equipment + 1] = {
                object = object,
                key = objectKey(object),
                pose = capturePose(object),
                wasAttached = isObjectAttachedTo(vehicle, object)
            }
        end
    end

    self.assignments[orderId] = assignment
    self.vehicleReservations[vehicleKey] = orderId

    log("info", "Order %s: assignment captured, vehicle=%s, equipment=%d, field=%d", orderId, vehicleKey, #assignment.equipment, fieldId)
    return self:startEquipmentFetch(assignment)
end

function WorkerExecution:onAIJobStopped(aiJob, aiMessage)
    local jobId = getJobId(aiJob)
    if jobId == nil then return false end
    local assignment = self.assignmentsByJobId[jobId]
    if assignment == nil then return false end

    self:clearJob(assignment)
    local successful = self:isAIStopSuccessful(aiMessage)
    log("info", "Order %s: AI job %s stopped in state %s, success=%s", tostring(assignment.orderId), jobId, tostring(assignment.state), tostring(successful))

    if successful ~= true then
        return self:failAssignment(assignment, "AI_JOB_FAILED:" .. tostring(assignment.state))
    end

    if assignment.state == WorkerExecution.STATE.TRANSIT_TO_FIELD then
        local ok, reason = self:startFieldWork(assignment)
        if not ok then return self:failAssignment(assignment, reason) end
        return true
    end

    if assignment.state == WorkerExecution.STATE.FIELDWORK then
        return self:startEquipmentReturn(assignment)
    end

    if assignment.state == WorkerExecution.STATE.RETURN_VEHICLE then
        return self:completeAssignment(assignment)
    end

    return false
end

function WorkerExecution:completeAssignment(assignment)
    if assignment == nil then return false end
    self:clearJob(assignment)
    self:setState(assignment, WorkerExecution.STATE.COMPLETE)
    if assignment.vehicleKey ~= nil then self.vehicleReservations[assignment.vehicleKey] = nil end

    if type(self.callbacks.onComplete) == "function" then
        local ok, err = pcall(self.callbacks.onComplete, assignment)
        if not ok then log("warning", "Order %s: completion callback failed: %s", tostring(assignment.orderId), tostring(err)) end
    end
    return true
end

function WorkerExecution:failAssignment(assignment, reason)
    if assignment == nil then return false end
    self:clearJob(assignment)
    assignment.failureReason = tostring(reason or "UNKNOWN")
    self:setState(assignment, WorkerExecution.STATE.FAILED, assignment.failureReason)
    if assignment.vehicleKey ~= nil then self.vehicleReservations[assignment.vehicleKey] = nil end

    if type(self.callbacks.onFailed) == "function" then
        local ok, err = pcall(self.callbacks.onFailed, assignment, assignment.failureReason)
        if not ok then log("warning", "Order %s: failure callback failed: %s", tostring(assignment.orderId), tostring(err)) end
    end
    return false
end

function WorkerExecution:cancelAssignment(orderId, reason)
    local assignment = self.assignments[tostring(orderId)]
    if assignment == nil then return false, "ORDER_NOT_TRACKED" end

    if assignment.aiJobId ~= nil and g_currentMission ~= nil and g_currentMission.aiSystem ~= nil and g_currentMission.aiSystem.stopJobById ~= nil then
        local jobId = tonumber(assignment.aiJobId) or assignment.aiJobId
        pcall(g_currentMission.aiSystem.stopJobById, g_currentMission.aiSystem, jobId, AIMessageErrorUnknown ~= nil and AIMessageErrorUnknown.new ~= nil and AIMessageErrorUnknown.new() or nil)
    end

    self:clearJob(assignment)
    self:setState(assignment, WorkerExecution.STATE.CANCELLED, reason or "cancelled")
    if assignment.vehicleKey ~= nil then self.vehicleReservations[assignment.vehicleKey] = nil end

    if type(self.callbacks.onCancelled) == "function" then pcall(self.callbacks.onCancelled, assignment, reason) end
    return true, nil
end

function WorkerExecution:getAssignment(orderId)
    return self.assignments[tostring(orderId)]
end

function WorkerExecution:isVehicleReserved(vehicle)
    local key = objectKey(vehicle)
    return key ~= nil and self.vehicleReservations[key] ~= nil, key ~= nil and self.vehicleReservations[key] or nil
end

function WorkerExecution:deleteAssignment(orderId)
    local key = tostring(orderId)
    local assignment = self.assignments[key]
    if assignment == nil then return false end
    self:clearJob(assignment)
    if assignment.vehicleKey ~= nil then self.vehicleReservations[assignment.vehicleKey] = nil end
    self.assignments[key] = nil
    return true
end
