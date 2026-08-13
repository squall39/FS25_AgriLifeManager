-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.ModuleContract = {}

AgriLife.ModuleContract.REQUIRED_DESCRIPTOR_FIELDS = {
    "id", "version", "schemaVersion", "dependencies", "defaultEnabled", "serverOnly", "critical", "factory"
}

AgriLife.ModuleContract.REQUIRED_METHODS = {
    "create", "load", "start", "save", "stop", "delete"
}

function AgriLife.ModuleContract.validateDescriptor(descriptor)
    if type(descriptor) ~= "table" then
        return AgriLife.Result.fail("MODULE_DESCRIPTOR_INVALID", "Descriptor must be a table")
    end

    for _, fieldName in ipairs(AgriLife.ModuleContract.REQUIRED_DESCRIPTOR_FIELDS) do
        if descriptor[fieldName] == nil then
            return AgriLife.Result.fail("MODULE_DESCRIPTOR_FIELD_MISSING", "Missing field: " .. fieldName)
        end
    end

    if type(descriptor.id) ~= "string" or descriptor.id == "" or string.match(descriptor.id, "^[%a][%w_%-]*$") == nil then
        return AgriLife.Result.fail("MODULE_ID_INVALID", "Module id must start with a letter and contain only letters, digits, underscores or hyphens")
    end
    if type(descriptor.version) ~= "string" or descriptor.version == "" then
        return AgriLife.Result.fail("MODULE_VERSION_INVALID", "Module version must be a non-empty string")
    end
    if type(descriptor.schemaVersion) ~= "number" or descriptor.schemaVersion < 1 or descriptor.schemaVersion % 1 ~= 0 then
        return AgriLife.Result.fail("MODULE_SCHEMA_INVALID", "Module schemaVersion must be a positive integer")
    end
    if type(descriptor.dependencies) ~= "table" then
        return AgriLife.Result.fail("MODULE_DEPENDENCIES_INVALID", "Dependencies must be a table")
    end
    if type(descriptor.defaultEnabled) ~= "boolean" or type(descriptor.serverOnly) ~= "boolean" or type(descriptor.critical) ~= "boolean" then
        return AgriLife.Result.fail("MODULE_FLAGS_INVALID", "Module flags must be booleans")
    end
    if type(descriptor.factory) ~= "function" then
        return AgriLife.Result.fail("MODULE_FACTORY_INVALID", "Module factory must be a function")
    end

    local seen = {}
    for _, dependencyId in ipairs(descriptor.dependencies) do
        if type(dependencyId) ~= "string" or dependencyId == "" then
            return AgriLife.Result.fail("MODULE_DEPENDENCY_ID_INVALID", "Dependency ids must be non-empty strings")
        end
        if dependencyId == descriptor.id then
            return AgriLife.Result.fail("MODULE_SELF_DEPENDENCY", "A module cannot depend on itself")
        end
        if seen[dependencyId] then
            return AgriLife.Result.fail("MODULE_DEPENDENCY_DUPLICATE", "Duplicate dependency: " .. dependencyId)
        end
        seen[dependencyId] = true
    end

    return AgriLife.Result.ok("MODULE_DESCRIPTOR_VALID", "Descriptor valid")
end

function AgriLife.ModuleContract.validateInstance(instance)
    if type(instance) ~= "table" then
        return AgriLife.Result.fail("MODULE_INSTANCE_INVALID", "Module instance must be a table")
    end
    for _, methodName in ipairs(AgriLife.ModuleContract.REQUIRED_METHODS) do
        if type(instance[methodName]) ~= "function" then
            return AgriLife.Result.fail("MODULE_METHOD_MISSING", "Missing method: " .. methodName)
        end
    end
    return AgriLife.Result.ok("MODULE_INSTANCE_VALID", "Module instance valid")
end
