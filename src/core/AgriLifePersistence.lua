-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Persistence = {}
AgriLife.Persistence.__index = AgriLife.Persistence

local function fileExistsSafe(path)
    return path ~= nil and fileExists ~= nil and fileExists(path) == true
end

local function sortedKeys(map)
    local keys = {}
    for key in pairs(map) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    return keys
end

function AgriLife.Persistence.new(core)
    return setmetatable({
        core = core,
        saveSequence = 0,
        lastSaveOk = nil,
        lastError = nil,
        isSaving = false,
        readOnly = false,
        loadedFarmIds = {},
        existingCareerWithoutAgriLife = false,
        careerIdentity = "",
        lastLoadedPath = "",
        lastRecoverySource = "",
        backupRecoveryCount = 0
    }, AgriLife.Persistence)
end

local function sanitizePathPart(value)
    value = tostring(value or ""):gsub("[\\/:*?\"<>|]", "_"):gsub("%s+", "_")
    value = value:gsub("[^%w%._%-]", "_")
    if value == "" then value = "savegame" end
    return value
end

-- FIX4G: gameplay state belongs to the career save itself, not modSettings.
-- During FSCareerMissionInfo:saveToXMLFile FS25 points savegameDirectory at
-- the tempsavegame staging directory. Writing AgriLifeManager.xml there lets
-- the native SavegameController copy it atomically with the rest of the save.
function AgriLife.Persistence:getSaveKey()
    local missionInfo = self.core ~= nil and self.core.context ~= nil and self.core.context.missionInfo or nil
    local index = missionInfo ~= nil and tonumber(missionInfo.savegameIndex) or nil
    if index ~= nil then return "savegame" .. tostring(math.floor(index)) end

    local directory = self:getActiveSavegameDirectory()
    if directory ~= nil and directory ~= "" then
        local normalized = tostring(directory):gsub("\\", "/"):gsub("/+$", "")
        local leaf = normalized:match("([^/]+)$")
        if leaf ~= nil and leaf ~= "" then return sanitizePathPart(leaf) end
    end
    return "savegame_unsaved"
end

function AgriLife.Persistence:ensureCareerIdentity()
    if tostring(self.careerIdentity or "") ~= "" then return self.careerIdentity end
    local context = self.core ~= nil and self.core.context or nil
    local sessionId = context ~= nil and tonumber(context.sessionId) or 0
    local clock = tonumber(g_time) or 0
    local saveKey = self:getSaveKey()
    self.careerIdentity = string.format("ALM_%s_%d_%d", sanitizePathPart(saveKey), math.max(0, math.floor(sessionId)), math.max(0, math.floor(clock)))
    return self.careerIdentity
end

function AgriLife.Persistence:getRoadmap9RecoverySnapshot()
    return {
        careerIdentity = tostring(self.careerIdentity or ""),
        lastLoadedPath = tostring(self.lastLoadedPath or ""),
        lastRecoverySource = tostring(self.lastRecoverySource or ""),
        backupRecoveryCount = tonumber(self.backupRecoveryCount) or 0,
        readOnly = self.readOnly == true,
        saveSequence = tonumber(self.saveSequence) or 0
    }
end

function AgriLife.Persistence:getActiveSavegameDirectory()
    local context = self.core ~= nil and self.core.context or nil
    if context == nil then return nil end
    if context.refreshRuntimeInfo ~= nil then
        context:refreshRuntimeInfo()
    end
    local missionInfo = context.missionInfo
    local directory = missionInfo ~= nil and missionInfo.savegameDirectory or nil
    if directory == nil or directory == "" then
        directory = context.savegameDirectory
    end
    if directory == nil or directory == "" then
        return nil
    end
    return tostring(directory):gsub("[\\/]+$", "")
end

function AgriLife.Persistence:getPath(saveDirectory)
    local directory = saveDirectory
    if directory == nil or directory == "" then
        directory = self:getActiveSavegameDirectory()
    end
    if directory == nil or directory == "" then return nil end
    directory = tostring(directory):gsub("[\\/]+$", "")
    return directory .. "/" .. AgriLife.Version.SAVE_FILE
end

function AgriLife.Persistence:getBackupPath(path)
    path = tostring(path or "")
    if path == "" then return nil end
    local base, count = path:gsub("%.xml$", "_backup.xml")
    return count > 0 and base or (path .. "_backup.xml")
end

function AgriLife.Persistence:loadModuleSettings(xmlFile)
    if xmlFile == nil or xmlFile.iterate == nil then
        return
    end

    xmlFile:iterate("agriLifeManager.saveSettings.modules.module", function(_, moduleKey)
        local moduleId = xmlFile:getString(moduleKey .. "#id")
        local hasEnabled = xmlFile.hasProperty == nil or xmlFile:hasProperty(moduleKey .. "#enabled")
        if moduleId ~= nil and moduleId ~= "" and hasEnabled then
            local enabled = xmlFile:getBool(moduleKey .. "#enabled", false)
            self.core.registry:setEnabled(moduleId, enabled)
        end
    end)
end

function AgriLife.Persistence:getFarmRoots(xmlFile)
    local roots = {}
    if xmlFile ~= nil and xmlFile.iterate ~= nil then
        xmlFile:iterate("agriLifeManager.farms.farm", function(_, farmKey)
            local farmId = xmlFile:getInt(farmKey .. "#id", 0)
            if farmId > 0 and roots[farmId] == nil then
                roots[farmId] = farmKey
                self.loadedFarmIds[farmId] = true
                self.core.registry.loadedFarmIds[farmId] = true
            end
        end)
    end
    return roots
end

function AgriLife.Persistence:getAllFarmIds(extraRoots)
    local ids = {}
    for farmId in pairs(self.loadedFarmIds) do
        ids[farmId] = true
    end
    for farmId in pairs(self.core.registry.loadedFarmIds or {}) do
        ids[farmId] = true
    end
    if extraRoots ~= nil then
        for farmId in pairs(extraRoots) do
            ids[farmId] = true
        end
    end
    if self.core.context ~= nil and self.core.context.getFarmIds ~= nil then
        for _, farmId in ipairs(self.core.context:getFarmIds()) do
            ids[farmId] = true
        end
    end

    local sorted = {}
    for farmId in pairs(ids) do
        farmId = tonumber(farmId)
        if farmId ~= nil and farmId > 0 then
            table.insert(sorted, farmId)
        end
    end
    table.sort(sorted)
    return sorted
end

function AgriLife.Persistence:loadModulesForFarms(xmlFile, farmRoots)
    local farmIds = self:getAllFarmIds(farmRoots)
    if #farmIds == 0 then
        return self.core.registry:loadAll(nil, nil, nil)
    end

    for _, farmId in ipairs(farmIds) do
        local moduleResult = self.core.registry:loadAll(xmlFile, farmRoots[farmId], farmId)
        if not moduleResult.ok then
            return moduleResult
        end
    end
    return AgriLife.Result.ok("MODULE_FARMS_LOADED", "Module data loaded for farms", { farmCount = #farmIds })
end


function AgriLife.Persistence:isNativeCareerAlreadySaved(path)
    path=tostring(path or "")
    if path=="" then return false end
    local directory=path:gsub("[\\/][^\\/]+$", "")
    if directory=="" then return false end
    return fileExistsSafe(directory.."/careerSavegame.xml") or fileExistsSafe(directory.."/farms.xml") or fileExistsSafe(directory.."/vehicles.xml")
end

function AgriLife.Persistence:markExistingCareerMigration()
    self.existingCareerWithoutAgriLife=true
    local economy=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.economy or nil
    if economy==nil or economy.markExistingCareer==nil then return end
    for _,farmId in ipairs(self:getAllFarmIds({})) do economy:markExistingCareer(farmId) end
    AgriLife.Logger.info("Persistence","Existing FS25 career detected without AgriLife save; migration mode enabled and current money will be preserved")
end

function AgriLife.Persistence:load()
    self.readOnly = false
    self.lastError = nil

    if self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer then
        self.saveSequence = 0
        self.lastSaveOk = nil
        local moduleResult = self.core.registry:loadAll(nil, nil, nil)
        if not moduleResult.ok then
            return moduleResult
        end
        AgriLife.Logger.info("Persistence", "Client load skipped; server owns save data")
        return AgriLife.Result.ok("CLIENT_LOAD_SKIPPED", "Client does not read the server save file")
    end

    if XMLFile == nil or XMLFile.loadIfExists == nil then
        return AgriLife.Result.fail("XML_API_UNAVAILABLE", "XML API unavailable", { fatal = true })
    end

    local path = self:getPath()
    if path == nil then
        -- This is the normal state of a brand-new FS25 career before its first
        -- native save. Do NOT fall back to a slot-numbered modSettings file:
        -- doing so is what made a fresh career inherit a previous exam/XP state.
        self.saveSequence = 0
        self.lastSaveOk = nil
        local moduleResult = self:loadModulesForFarms(nil, {})
        if not moduleResult.ok then return moduleResult end
        AgriLife.Logger.info("Persistence", "No savegame directory yet; initializing a brand-new AgriLife career state")
        return AgriLife.Result.ok("SAVE_NOT_FOUND", "New unsaved AgriLife career initialized")
    end

    local primaryExists = fileExistsSafe(path)
    local openOk, xmlFile = pcall(XMLFile.loadIfExists, "AgriLifeManagerSave", path)
    local loadedPath = path
    if not openOk or (xmlFile == nil and primaryExists) then
        local backupPath = self:getBackupPath(path)
        local backupOk, backupFile = pcall(XMLFile.loadIfExists, "AgriLifeManagerBackup", backupPath)
        if backupOk and backupFile ~= nil then
            xmlFile = backupFile
            openOk = true
            loadedPath = backupPath
            self.lastRecoverySource = "backup"
            self.backupRecoveryCount = (tonumber(self.backupRecoveryCount) or 0) + 1
            AgriLife.Logger.warning("Persistence", "Primary AgriLife save unavailable; native backup loaded (%s)", tostring(backupPath))
        else
            self.readOnly = true
            self.lastError = not openOk and "SAVE_OPEN_FAILED" or "SAVE_XML_INVALID"
            return AgriLife.Result.fail(self.lastError, not openOk and tostring(xmlFile) or "Existing AgriLife save could not be parsed", { fatal = true, readOnly = true, path = path, backupPath = backupPath })
        end
    elseif xmlFile == nil then
        local backupPath = self:getBackupPath(path)
        local backupOk, backupFile = pcall(XMLFile.loadIfExists, "AgriLifeManagerBackup", backupPath)
        if backupOk and backupFile ~= nil then
            xmlFile = backupFile
            loadedPath = backupPath
            self.lastRecoverySource = "backup"
            self.backupRecoveryCount = (tonumber(self.backupRecoveryCount) or 0) + 1
            AgriLife.Logger.warning("Persistence", "Primary AgriLife save missing; native backup loaded (%s)", tostring(backupPath))
        end
    end

    if xmlFile == nil then
        self.saveSequence = 0
        self.lastSaveOk = nil
        local moduleResult = self:loadModulesForFarms(nil, {})
        if not moduleResult.ok then return moduleResult end
        if self:isNativeCareerAlreadySaved(path) then
            self:markExistingCareerMigration()
            return AgriLife.Result.ok("EXISTING_CAREER_MIGRATION", "Existing FS25 career detected; AgriLife will preserve the current career and initialize only its own systems")
        end
        AgriLife.Logger.info("Persistence", "No %s found in this career save (%s); initializing a new AgriLife state", tostring(AgriLife.Version.SAVE_FILE), tostring(path))
        return AgriLife.Result.ok("SAVE_NOT_FOUND", "New AgriLife save will be created inside this career")
    end

    local schemaVersion = xmlFile:getInt("agriLifeManager#schemaVersion", 0)
    local fileVersion = xmlFile:getString("agriLifeManager#version", "unknown")
    self.saveSequence = xmlFile:getInt("agriLifeManager#saveSequence", 0)
    self.careerIdentity = xmlFile:getString("agriLifeManager.storage#careerIdentity", "")
    if self.careerIdentity == "" then self:ensureCareerIdentity() end
    self.lastLoadedPath = tostring(loadedPath or "")
    if self.lastRecoverySource == "" then self.lastRecoverySource = loadedPath == path and "primary" or "backup" end

    if schemaVersion > AgriLife.Version.SAVE_SCHEMA then
        self.readOnly = true
        xmlFile:delete()
        self.lastError = "SAVE_SCHEMA_NEWER"
        return AgriLife.Result.fail("SAVE_SCHEMA_NEWER", string.format("Save schema %d is newer than supported schema %d", schemaVersion, AgriLife.Version.SAVE_SCHEMA), {
            fileVersion = fileVersion,
            fatal = true,
            readOnly = true,
            path = path
        })
    end

    if schemaVersion < AgriLife.Version.SAVE_SCHEMA then
        local migration = self.core.migrations:migrate(xmlFile, schemaVersion, AgriLife.Version.SAVE_SCHEMA)
        if not migration.ok then
            xmlFile:delete()
            self.readOnly = true
            self.lastError = migration.code
            migration.details = migration.details or {}
            migration.details.fatal = true
            migration.details.readOnly = true
            migration.details.path = path
            return migration
        end
        schemaVersion = AgriLife.Version.SAVE_SCHEMA
    end

    self:loadModuleSettings(xmlFile)
    local farmRoots = self:getFarmRoots(xmlFile)
    local moduleResult = self:loadModulesForFarms(xmlFile, farmRoots)
    xmlFile:delete()

    if not moduleResult.ok then
        self.lastError = moduleResult.code
        self.readOnly = true
        moduleResult.details = moduleResult.details or {}
        moduleResult.details.readOnly = true
        moduleResult.details.path = path
        return moduleResult
    end

    AgriLife.Logger.info("Persistence", "Save loaded from career (version=%s schema=%d sequence=%d farms=%d path=%s)", fileVersion, schemaVersion, self.saveSequence, #self:getAllFarmIds(farmRoots), tostring(loadedPath))
    return AgriLife.Result.ok("SAVE_LOADED", "AgriLife save loaded from career")
end

function AgriLife.Persistence:writeModuleSettings(xmlFile)
    local settings = self.core.registry:getEnabledSettings()
    local index = 0
    for _, moduleId in ipairs(sortedKeys(settings)) do
        local moduleKey = string.format("agriLifeManager.saveSettings.modules.module(%d)", index)
        xmlFile:setString(moduleKey .. "#id", moduleId)
        xmlFile:setBool(moduleKey .. "#enabled", settings[moduleId] == true)
        index = index + 1
    end
end

function AgriLife.Persistence:validateFile(path, expectedSequence, expectedSchema)
    if not fileExistsSafe(path) then
        return AgriLife.Result.fail("SAVE_FILE_MISSING", "Expected save file is missing")
    end
    if XMLFile == nil or XMLFile.loadIfExists == nil then
        return AgriLife.Result.fail("XML_API_UNAVAILABLE", "XML API unavailable")
    end

    local ok, xmlFile = pcall(XMLFile.loadIfExists, "AgriLifeManagerSaveValidation", path)
    if not ok or xmlFile == nil then
        return AgriLife.Result.fail("SAVE_FILE_INVALID", tostring(xmlFile or "XML could not be opened"))
    end

    local schema = xmlFile:getInt("agriLifeManager#schemaVersion", -1)
    local sequence = xmlFile:getInt("agriLifeManager#saveSequence", -1)
    xmlFile:delete()

    if expectedSchema ~= nil and schema ~= expectedSchema then
        return AgriLife.Result.fail("SAVE_SCHEMA_MISMATCH", string.format("Expected schema %d, got %d", expectedSchema, schema))
    end
    if expectedSequence ~= nil and sequence ~= expectedSequence then
        return AgriLife.Result.fail("SAVE_SEQUENCE_MISMATCH", string.format("Expected sequence %d, got %d", expectedSequence, sequence))
    end
    return AgriLife.Result.ok("SAVE_FILE_VALID", "Save file metadata valid")
end

function AgriLife.Persistence:writeSaveFile(path, nextSequence)
    local xmlFile = nil
    local ok, result = xpcall(function()
        xmlFile = XMLFile.create("AgriLifeManagerSave", path, "agriLifeManager")
        if xmlFile == nil then
            return AgriLife.Result.fail("SAVE_CREATE_FAILED", "Could not create AgriLifeManager.xml in the FS25 save staging directory")
        end

        xmlFile:setString("agriLifeManager#version", AgriLife.Version.MOD)
        xmlFile:setInt("agriLifeManager#schemaVersion", AgriLife.Version.SAVE_SCHEMA)
        xmlFile:setInt("agriLifeManager#saveSequence", nextSequence)
        xmlFile:setInt("agriLifeManager.core#sessionId", self.core.context.sessionId)
        xmlFile:setInt("agriLifeManager.core#lastFarmId", self.core.context:getFarmId())
        xmlFile:setString("agriLifeManager.storage#saveKey", self:getSaveKey())
        xmlFile:setString("agriLifeManager.storage#backend", "savegame")
        xmlFile:setString("agriLifeManager.storage#careerIdentity", self:ensureCareerIdentity())
        xmlFile:setString("agriLifeManager.storage#roadmapFinalizationVersion", "0.9.0.0")
        self:writeModuleSettings(xmlFile)

        local farmIds = self:getAllFarmIds()
        for farmIndex, farmId in ipairs(farmIds) do
            local farmRoot = string.format("agriLifeManager.farms.farm(%d)", farmIndex - 1)
            xmlFile:setInt(farmRoot .. "#id", farmId)
            local moduleResult = self.core.registry:saveAll(xmlFile, farmRoot, farmId)
            if not moduleResult.ok then
                return moduleResult
            end
        end

        xmlFile:save()
        xmlFile:delete()
        xmlFile = nil
        return AgriLife.Result.ok("SAVE_FILE_WRITTEN", "AgriLife save file written into FS25 staging", { farmCount = #farmIds })
    end, function(errorValue)
        return tostring(errorValue)
    end)

    if xmlFile ~= nil then pcall(xmlFile.delete, xmlFile) end
    if not ok then
        return AgriLife.Result.fail("SAVE_WRITE_FAILED", tostring(result))
    end
    return result
end

function AgriLife.Persistence:save(saveDirectory)
    if self.isSaving then
        return AgriLife.Result.fail("SAVE_ALREADY_RUNNING", "An AgriLife save is already running")
    end
    if self.readOnly then
        return AgriLife.Result.fail("SAVE_READ_ONLY", "Save opened in read-only mode")
    end

    local serverCheck = self.core.context:requireServer("AgriLife save")
    if not serverCheck.ok then return serverCheck end
    if XMLFile == nil or XMLFile.create == nil then
        return AgriLife.Result.fail("XML_API_UNAVAILABLE", "XML API unavailable")
    end

    -- saveDirectory is deliberately supplied by the FSCareerMissionInfo hook.
    -- On FS25 1.21 this is the native tempsavegame staging directory. We never
    -- derive a writable slot path in modSettings and never copy state between slots.
    local path = self:getPath(saveDirectory)
    if path == nil then
        return AgriLife.Result.fail("SAVE_DIRECTORY_UNAVAILABLE", "FS25 save staging directory unavailable")
    end

    self.isSaving = true
    local nextSequence = self.saveSequence + 1
    local ok, result = xpcall(function()
        local writeResult = self:writeSaveFile(path, nextSequence)
        if not writeResult.ok then return writeResult end
        local validation = self:validateFile(path, nextSequence, AgriLife.Version.SAVE_SCHEMA)
        if not validation.ok then
            return AgriLife.Result.fail("SAVE_VALIDATION_FAILED", validation.message)
        end
        local backupPath = self:getBackupPath(path)
        local backupResult = self:writeSaveFile(backupPath, nextSequence)
        local backupValidation = backupResult.ok and self:validateFile(backupPath, nextSequence, AgriLife.Version.SAVE_SCHEMA) or backupResult
        if backupValidation == nil or not backupValidation.ok then
            AgriLife.Logger.warning("Persistence", "Native backup staging failed: %s", tostring(backupValidation ~= nil and backupValidation.code or "unknown"))
        end
        return AgriLife.Result.ok("SAVE_STAGED", "AgriLife save and backup staged with FS25", { path = path, backupPath = backupPath, backupOk = backupValidation ~= nil and backupValidation.ok == true })
    end, function(errorValue)
        return tostring(errorValue)
    end)
    self.isSaving = false

    if not ok then
        self.lastSaveOk = false
        self.lastError = "SAVE_UNHANDLED_ERROR"
        return AgriLife.Result.fail("SAVE_UNHANDLED_ERROR", tostring(result))
    end
    if not result.ok then
        self.lastSaveOk = false
        self.lastError = result.code
        return result
    end

    self.saveSequence = nextSequence
    self.lastSaveOk = true
    self.lastError = nil
    AgriLife.Logger.info("Persistence", "Save staged in native FS25 career save (sequence=%d farms=%d path=%s)", self.saveSequence, #self:getAllFarmIds(), tostring(path))
    return AgriLife.Result.ok("SAVE_OK", "AgriLife save staged in native FS25 savegame", { saveSequence = self.saveSequence, path = path })
end

function AgriLife.Persistence:delete()
    self.core = nil
    self.isSaving = false
    self.loadedFarmIds = {}
    self.careerIdentity = ""
    self.lastLoadedPath = ""
    self.lastRecoverySource = ""
    self.backupRecoveryCount = 0
end
