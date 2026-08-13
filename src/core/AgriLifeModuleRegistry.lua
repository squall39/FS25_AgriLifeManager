-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.ModuleRegistry = {}
AgriLife.ModuleRegistry.__index = AgriLife.ModuleRegistry

AgriLife.ModuleRegistry.Status = {
    REGISTERED = "REGISTERED",
    CREATED = "CREATED",
    LOADED = "LOADED",
    STARTED = "STARTED",
    DISABLED = "DISABLED",
    FAILED = "FAILED",
    STOPPED = "STOPPED",
    DELETED = "DELETED"
}

local function normalizeModuleCall(ok, value, successCode, failureCode)
    if not ok then
        return AgriLife.Result.fail(failureCode, tostring(value))
    end
    return AgriLife.Result.normalize(value, successCode, failureCode)
end

function AgriLife.ModuleRegistry.new(core)
    return setmetatable({
        core = core,
        descriptors = {},
        instances = {},
        statuses = {},
        order = {},
        resolvedOrder = nil,
        errors = {},
        enabledOverrides = {},
        loadedFarmIds = {},
        stoppedModules = {},
        deletedModules = {},
        stopped = false,
        deleted = false
    }, AgriLife.ModuleRegistry)
end

function AgriLife.ModuleRegistry:register(descriptor)
    if self.deleted or next(self.instances) ~= nil then
        return AgriLife.Result.fail("MODULE_REGISTRATION_CLOSED", "Modules must be registered before creation")
    end

    local validation = AgriLife.ModuleContract.validateDescriptor(descriptor)
    if not validation.ok then
        return validation
    end
    if self.descriptors[descriptor.id] ~= nil then
        return AgriLife.Result.fail("MODULE_DUPLICATE", "Duplicate module id: " .. descriptor.id)
    end

    self.descriptors[descriptor.id] = descriptor
    self.statuses[descriptor.id] = AgriLife.ModuleRegistry.Status.REGISTERED
    table.insert(self.order, descriptor.id)
    self.resolvedOrder = nil
    return AgriLife.Result.ok("MODULE_REGISTERED", "Module registered", { moduleId = descriptor.id })
end

function AgriLife.ModuleRegistry:resolveDependencies()
    if self.resolvedOrder ~= nil then
        return AgriLife.Result.ok("MODULE_DEPENDENCIES_VALID", "Dependencies valid", { order = self.resolvedOrder })
    end

    for moduleId, descriptor in pairs(self.descriptors) do
        for _, dependencyId in ipairs(descriptor.dependencies) do
            if self.descriptors[dependencyId] == nil then
                return AgriLife.Result.fail("MODULE_DEPENDENCY_MISSING", string.format("%s requires %s", moduleId, dependencyId), { fatal = true })
            end
        end
    end

    local state = {}
    local resolved = {}
    local stack = {}

    local function visit(moduleId)
        if state[moduleId] == 2 then
            return nil
        end
        if state[moduleId] == 1 then
            local cycle = table.concat(stack, " -> ") .. " -> " .. moduleId
            return AgriLife.Result.fail("MODULE_DEPENDENCY_CYCLE", cycle, { fatal = true })
        end

        state[moduleId] = 1
        table.insert(stack, moduleId)
        for _, dependencyId in ipairs(self.descriptors[moduleId].dependencies) do
            local errorResult = visit(dependencyId)
            if errorResult ~= nil then
                return errorResult
            end
        end
        table.remove(stack)
        state[moduleId] = 2
        table.insert(resolved, moduleId)
        return nil
    end

    for _, moduleId in ipairs(self.order) do
        local errorResult = visit(moduleId)
        if errorResult ~= nil then
            return errorResult
        end
    end

    self.resolvedOrder = resolved
    return AgriLife.Result.ok("MODULE_DEPENDENCIES_VALID", "Dependencies valid", { order = resolved })
end

function AgriLife.ModuleRegistry:setEnabled(moduleId, enabled)
    if type(moduleId) ~= "string" or moduleId == "" or type(enabled) ~= "boolean" then
        return AgriLife.Result.fail("MODULE_SETTING_INVALID", "Invalid module enabled setting")
    end
    self.enabledOverrides[moduleId] = enabled
    return AgriLife.Result.ok("MODULE_SETTING_UPDATED", "Module enabled setting updated", { moduleId = moduleId, enabled = enabled })
end

function AgriLife.ModuleRegistry:isRuntimeEligible(descriptor)
    return not descriptor.serverOnly or (self.core ~= nil and self.core.context ~= nil and self.core.context.isServer)
end

function AgriLife.ModuleRegistry:isEnabled(descriptor)
    local override = self.enabledOverrides[descriptor.id]
    if override ~= nil then
        return override == true
    end
    return descriptor.defaultEnabled == true
end

function AgriLife.ModuleRegistry:updateAll(dt)
    if self.deleted or self.stopped then return end
    local order = self.resolvedOrder or self.order or {}
    for _, moduleId in ipairs(order) do
        local instance = self.instances[moduleId]
        if instance ~= nil and self.statuses[moduleId] == AgriLife.ModuleRegistry.Status.STARTED and type(instance.update) == "function" then
            local ok, err = pcall(instance.update, instance, dt)
            if not ok then AgriLife.Logger.warning("ModuleRegistry", "%s update failed: %s", tostring(moduleId), tostring(err)) end
        end
    end
end

function AgriLife.ModuleRegistry:getEnabledSettings()
    local settings = {}
    for moduleId, descriptor in pairs(self.descriptors) do
        settings[moduleId] = self:isEnabled(descriptor)
    end
    for moduleId, enabled in pairs(self.enabledOverrides) do
        if settings[moduleId] == nil then
            settings[moduleId] = enabled
        end
    end
    return settings
end

function AgriLife.ModuleRegistry:recordFailure(moduleId, result)
    self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.FAILED
    self.errors[moduleId] = result
    AgriLife.Logger.error("ModuleRegistry", "%s failed: %s (%s)", moduleId, tostring(result.message), tostring(result.code))
end

function AgriLife.ModuleRegistry:buildPartialResult(code, message, failures)
    if #failures == 0 then
        return AgriLife.Result.ok(code, message)
    end
    return AgriLife.Result.fail(code .. "_PARTIAL", message, {
        fatal = false,
        failed = failures,
        failedCount = #failures
    })
end

function AgriLife.ModuleRegistry:createAll()
    local dependencyResult = self:resolveDependencies()
    if not dependencyResult.ok then
        return dependencyResult
    end

    self.stopped = false
    local failures = {}
    for _, moduleId in ipairs(self.resolvedOrder) do
        local descriptor = self.descriptors[moduleId]
        if not self:isRuntimeEligible(descriptor) then
            self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.DISABLED
        else
            local factoryOk, instance = pcall(descriptor.factory, self.core)
            if not factoryOk then
                local factoryResult = AgriLife.Result.fail("MODULE_FACTORY_FAILED", tostring(instance))
                self:recordFailure(moduleId, factoryResult)
                table.insert(failures, moduleId)
                if descriptor.critical then
                    factoryResult.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                    return factoryResult
                end
            else
                local validation = AgriLife.ModuleContract.validateInstance(instance)
                if not validation.ok then
                    self:recordFailure(moduleId, validation)
                    table.insert(failures, moduleId)
                    if descriptor.critical then
                        validation.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                        return validation
                    end
                else
                    self.instances[moduleId] = instance
                    local createOk, createValue = pcall(instance.create, instance)
                    local createResult = normalizeModuleCall(createOk, createValue, "MODULE_CREATE_OK", "MODULE_CREATE_FAILED")
                    if not createResult.ok then
                        self:recordFailure(moduleId, createResult)
                        table.insert(failures, moduleId)
                        if descriptor.critical then
                            createResult.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                            return createResult
                        end
                    else
                        self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.CREATED
                    end
                end
            end
        end
    end

    return self:buildPartialResult("MODULES_CREATED", "Registered modules created", failures)
end

function AgriLife.ModuleRegistry:getModuleKeys(xmlFile, farmRoot)
    local moduleKeys = {}
    if xmlFile == nil or farmRoot == nil or xmlFile.iterate == nil then
        return moduleKeys
    end

    xmlFile:iterate(farmRoot .. ".modules.module", function(_, moduleKey)
        local moduleId = xmlFile:getString(moduleKey .. "#id")
        if moduleId ~= nil and moduleId ~= "" and moduleKeys[moduleId] == nil then
            moduleKeys[moduleId] = moduleKey
        end
    end)
    return moduleKeys
end

function AgriLife.ModuleRegistry:dependenciesAvailableForLoad(descriptor)
    for _, dependencyId in ipairs(descriptor.dependencies) do
        if self.statuses[dependencyId] == AgriLife.ModuleRegistry.Status.FAILED then
            return false, dependencyId
        end
    end
    return true, nil
end

function AgriLife.ModuleRegistry:loadAll(xmlFile, farmRoot, farmId)
    local dependencyResult = self:resolveDependencies()
    if not dependencyResult.ok then
        return dependencyResult
    end

    local moduleKeys = self:getModuleKeys(xmlFile, farmRoot)
    local failures = {}
    for _, moduleId in ipairs(self.resolvedOrder) do
        local descriptor = self.descriptors[moduleId]
        local instance = self.instances[moduleId]
        local status = self.statuses[moduleId]
        if instance ~= nil and status ~= AgriLife.ModuleRegistry.Status.FAILED then
            local dependenciesOk, failedDependency = self:dependenciesAvailableForLoad(descriptor)
            if not dependenciesOk then
                local result = AgriLife.Result.fail("MODULE_DEPENDENCY_FAILED", moduleId .. " depends on failed module " .. failedDependency)
                self:recordFailure(moduleId, result)
                table.insert(failures, moduleId)
                if descriptor.critical then
                    result.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                    return result
                end
            else
                local moduleKey = moduleKeys[moduleId]
                local loadOk, loadValue = pcall(instance.load, instance, xmlFile, moduleKey, farmId)
                local loadResult = normalizeModuleCall(loadOk, loadValue, "MODULE_LOAD_OK", "MODULE_LOAD_FAILED")
                if not loadResult.ok then
                    self:recordFailure(moduleId, loadResult)
                    table.insert(failures, moduleId)
                    if descriptor.critical then
                        loadResult.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                        return loadResult
                    end
                else
                    self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.LOADED
                end
            end
        end
    end

    if farmId ~= nil and tonumber(farmId) ~= nil and tonumber(farmId) > 0 then
        self.loadedFarmIds[tonumber(farmId)] = true
    end
    return self:buildPartialResult("MODULES_LOADED", "Module load pass complete", failures)
end

function AgriLife.ModuleRegistry:startAll()
    local dependencyResult = self:resolveDependencies()
    if not dependencyResult.ok then
        return dependencyResult
    end

    local failures = {}
    for _, moduleId in ipairs(self.resolvedOrder) do
        local descriptor = self.descriptors[moduleId]
        local instance = self.instances[moduleId]
        if instance ~= nil and self.statuses[moduleId] ~= AgriLife.ModuleRegistry.Status.FAILED then
            if not self:isEnabled(descriptor) then
                self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.DISABLED
            else
                local dependencyFailed = nil
                for _, dependencyId in ipairs(descriptor.dependencies) do
                    if self.statuses[dependencyId] ~= AgriLife.ModuleRegistry.Status.STARTED then
                        dependencyFailed = dependencyId
                        break
                    end
                end

                if dependencyFailed ~= nil then
                    local result = AgriLife.Result.fail("MODULE_DEPENDENCY_NOT_STARTED", moduleId .. " requires started module " .. dependencyFailed)
                    self:recordFailure(moduleId, result)
                    table.insert(failures, moduleId)
                    if descriptor.critical then
                        result.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                        return result
                    end
                elseif self.statuses[moduleId] ~= AgriLife.ModuleRegistry.Status.LOADED then
                    local result = AgriLife.Result.fail("MODULE_NOT_LOADED", moduleId .. " cannot start before load")
                    self:recordFailure(moduleId, result)
                    table.insert(failures, moduleId)
                    if descriptor.critical then
                        result.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                        return result
                    end
                else
                    local startOk, startValue = pcall(instance.start, instance)
                    local startResult = normalizeModuleCall(startOk, startValue, "MODULE_START_OK", "MODULE_START_FAILED")
                    if not startResult.ok then
                        self:recordFailure(moduleId, startResult)
                        table.insert(failures, moduleId)
                        if descriptor.critical then
                            startResult.details = { moduleId = moduleId, fatal = true, failedCount = 1 }
                            return startResult
                        end
                    else
                        self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.STARTED
                    end
                end
            end
        end
    end

    return self:buildPartialResult("MODULES_STARTED", "Module start pass complete", failures)
end

function AgriLife.ModuleRegistry:saveAll(xmlFile, farmRoot, farmId)
    local dependencyResult = self:resolveDependencies()
    if not dependencyResult.ok then
        return dependencyResult
    end

    local moduleIndex = 0
    for _, moduleId in ipairs(self.resolvedOrder) do
        local descriptor = self.descriptors[moduleId]
        local instance = self.instances[moduleId]
        if instance ~= nil and self.statuses[moduleId] ~= AgriLife.ModuleRegistry.Status.FAILED then
            local moduleKey = string.format("%s.modules.module(%d)", farmRoot, moduleIndex)
            xmlFile:setString(moduleKey .. "#id", moduleId)
            xmlFile:setString(moduleKey .. "#version", descriptor.version)
            xmlFile:setInt(moduleKey .. "#schemaVersion", descriptor.schemaVersion)

            local saveOk, saveValue = pcall(instance.save, instance, xmlFile, moduleKey, farmId)
            local saveResult = normalizeModuleCall(saveOk, saveValue, "MODULE_SAVE_OK", "MODULE_SAVE_FAILED")
            if not saveResult.ok then
                return AgriLife.Result.fail("MODULE_SAVE_FAILED", saveResult.message, {
                    moduleId = moduleId,
                    farmId = farmId,
                    fatal = true,
                    failedCount = 1
                })
            end
            moduleIndex = moduleIndex + 1
        end
    end
    return AgriLife.Result.ok("MODULES_SAVED", "Modules saved", { count = moduleIndex })
end

function AgriLife.ModuleRegistry:stopAll()
    if self.stopped then
        return AgriLife.Result.ok("MODULES_ALREADY_STOPPED", "Modules already stopped")
    end

    local order = self.resolvedOrder or self.order
    for index = #order, 1, -1 do
        local moduleId = order[index]
        local instance = self.instances[moduleId]
        if instance ~= nil and not self.stoppedModules[moduleId] then
            local ok, value = pcall(instance.stop, instance)
            if not ok or value == false or (type(value) == "table" and value.ok == false) then
                AgriLife.Logger.warning("ModuleRegistry", "Module %s stop failed: %s", moduleId, tostring(value))
            end
            if self.core ~= nil and self.core.subscriptions ~= nil then
                self.core.subscriptions:unsubscribeOwner(moduleId)
            end
            self.stoppedModules[moduleId] = true
            if self.statuses[moduleId] ~= AgriLife.ModuleRegistry.Status.FAILED then
                self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.STOPPED
            end
        end
    end
    self.stopped = true
    return AgriLife.Result.ok("MODULES_STOPPED", "Modules stopped")
end

function AgriLife.ModuleRegistry:delete()
    if self.deleted then
        return
    end
    self:stopAll()

    local order = self.resolvedOrder or self.order
    for index = #order, 1, -1 do
        local moduleId = order[index]
        local instance = self.instances[moduleId]
        if instance ~= nil and not self.deletedModules[moduleId] then
            local ok, value = pcall(instance.delete, instance)
            if not ok or value == false or (type(value) == "table" and value.ok == false) then
                AgriLife.Logger.warning("ModuleRegistry", "Module %s delete failed: %s", moduleId, tostring(value))
            end
            self.deletedModules[moduleId] = true
        end
        self.statuses[moduleId] = AgriLife.ModuleRegistry.Status.DELETED
    end

    self.instances = {}
    self.descriptors = {}
    self.statuses = {}
    self.order = {}
    self.resolvedOrder = nil
    self.errors = {}
    self.enabledOverrides = {}
    self.loadedFarmIds = {}
    self.core = nil
    self.deleted = true
end

function AgriLife.ModuleRegistry:getSnapshot()
    local registered = 0
    local active = 0
    local failed = 0
    local disabled = 0
    for moduleId in pairs(self.descriptors) do
        registered = registered + 1
        if self.statuses[moduleId] == AgriLife.ModuleRegistry.Status.STARTED then
            active = active + 1
        elseif self.statuses[moduleId] == AgriLife.ModuleRegistry.Status.FAILED then
            failed = failed + 1
        elseif self.statuses[moduleId] == AgriLife.ModuleRegistry.Status.DISABLED then
            disabled = disabled + 1
        end
    end
    return { registered = registered, active = active, failed = failed, disabled = disabled }
end
