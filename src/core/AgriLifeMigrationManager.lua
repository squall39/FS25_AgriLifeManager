-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.MigrationManager = {}
AgriLife.MigrationManager.__index = AgriLife.MigrationManager

function AgriLife.MigrationManager.new()
    return setmetatable({ migrations = {}, history = {}, lastRun = nil }, AgriLife.MigrationManager)
end

function AgriLife.MigrationManager:register(fromSchema, toSchema, callback)
    if type(fromSchema) ~= "number" or type(toSchema) ~= "number" or fromSchema % 1 ~= 0 or toSchema % 1 ~= 0 then
        return AgriLife.Result.fail("MIGRATION_SCHEMA_INVALID", "Migration schemas must be integers")
    end
    if fromSchema < 0 or toSchema ~= fromSchema + 1 then
        return AgriLife.Result.fail("MIGRATION_RANGE_INVALID", "Migrations must advance exactly one schema")
    end
    if type(callback) ~= "function" then
        return AgriLife.Result.fail("MIGRATION_CALLBACK_INVALID", "Migration callback must be a function")
    end

    local key = tostring(fromSchema) .. ">" .. tostring(toSchema)
    if self.migrations[key] ~= nil then
        return AgriLife.Result.fail("MIGRATION_DUPLICATE", "Migration already registered")
    end
    self.migrations[key] = callback
    return AgriLife.Result.ok("MIGRATION_REGISTERED", "Migration registered")
end

function AgriLife.MigrationManager:migrate(xmlFile, fromSchema, targetSchema)
    if xmlFile == nil then
        return AgriLife.Result.fail("MIGRATION_XML_MISSING", "Migration requires an XML file")
    end
    if fromSchema > targetSchema then
        return AgriLife.Result.fail("SAVE_SCHEMA_NEWER", "Save schema is newer than this mod", { fatal = true, readOnly = true })
    end

    local current = fromSchema
    while current < targetSchema do
        local key = tostring(current) .. ">" .. tostring(current + 1)
        local callback = self.migrations[key]
        if callback == nil then
            return AgriLife.Result.fail("MIGRATION_MISSING", "Missing migration " .. key, { fatal = true, migration = key })
        end

        local callOk, value = pcall(callback, xmlFile, current, current + 1)
        local result = callOk and AgriLife.Result.normalize(value, "MIGRATION_STEP_OK", "MIGRATION_STEP_FAILED") or AgriLife.Result.fail("MIGRATION_STEP_FAILED", tostring(value))
        if not result.ok then
            return AgriLife.Result.fail("MIGRATION_FAILED", result.message, { fatal = true, migration = key })
        end

        current = current + 1
        xmlFile:setInt("agriLifeManager#schemaVersion", current)
        local row = {fromSchema = current - 1, toSchema = current, key = key}
        table.insert(self.history, row)
        while #self.history > 32 do table.remove(self.history, 1) end
    end

    self.lastRun = {fromSchema = fromSchema, targetSchema = targetSchema, schemaVersion = current, steps = targetSchema - fromSchema}
    return AgriLife.Result.ok("MIGRATION_COMPLETE", "Migration complete", { schemaVersion = current, steps = targetSchema - fromSchema })
end

function AgriLife.MigrationManager:delete()
    self.migrations = {}
    self.history = {}
    self.lastRun = nil
end
