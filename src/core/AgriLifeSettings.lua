-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Settings = {}
AgriLife.Settings.__index = AgriLife.Settings

function AgriLife.Settings.new()
    return setmetatable({
        schemaVersion = AgriLife.Version.SETTINGS_SCHEMA,
        loggingLevel = "INFO",
        showStartupMessage = true,
        examHudVisible = true,
        examHudLocked = true,
        examHudOffsetX = 0,
        examHudOffsetY = 0,
        loaded = false,
        readOnly = false,
        filePath = nil
    }, AgriLife.Settings)
end

function AgriLife.Settings:getDirectory()
    if getUserProfileAppPath == nil then
        return nil
    end
    local modName = tostring(AgriLife.Version.SETTINGS_NAMESPACE or "FS25_AgriLifeManager")
    return getUserProfileAppPath() .. "modSettings/" .. modName
end

function AgriLife.Settings:getFilePath()
    local directory = self:getDirectory()
    if directory == nil then
        return nil
    end
    return directory .. "/settings.xml"
end

function AgriLife.Settings:ensureDirectory()
    local directory = self:getDirectory()
    if directory == nil then
        return AgriLife.Result.fail("SETTINGS_DIRECTORY_UNAVAILABLE", "Settings directory unavailable")
    end
    if createFolder ~= nil then
        local ok, value = pcall(createFolder, directory)
        if not ok then
            return AgriLife.Result.fail("SETTINGS_DIRECTORY_CREATE_FAILED", tostring(value))
        end
    end
    return AgriLife.Result.ok("SETTINGS_DIRECTORY_READY", "Settings directory ready")
end

function AgriLife.Settings:load()
    self.filePath = self:getFilePath()
    if self.filePath == nil then
        AgriLife.Logger.warning("Settings", "User profile path is unavailable; defaults retained")
        self.loaded = true
        self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
        return AgriLife.Result.ok("SETTINGS_DEFAULTS", "Defaults retained")
    end

    local directoryResult = self:ensureDirectory()
    if not directoryResult.ok then
        AgriLife.Logger.warning("Settings", "%s", directoryResult.message)
        self.loaded = true
        self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
        return AgriLife.Result.ok("SETTINGS_DEFAULTS", "Defaults retained", { warning = directoryResult.code })
    end

    local loadOk, xmlFile = pcall(function()
        if XMLFile == nil or XMLFile.loadIfExists == nil then
            return nil
        end
        return XMLFile.loadIfExists("AgriLifeUserSettings", self.filePath)
    end)

    if not loadOk then
        AgriLife.Logger.warning("Settings", "Could not read local settings: %s", tostring(xmlFile))
        self.loaded = true
        self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
        return AgriLife.Result.ok("SETTINGS_DEFAULTS", "Defaults retained", { warning = "SETTINGS_READ_FAILED" })
    end

    if xmlFile == nil and fileExists ~= nil and fileExists(self.filePath) then
        self.readOnly = true
        self.loaded = true
        self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
        AgriLife.Logger.warning("Settings", "Existing local settings are unreadable; defaults retained without overwriting the file")
        return AgriLife.Result.ok("SETTINGS_INVALID_READ_ONLY", "Unreadable local settings preserved")
    end

    if xmlFile ~= nil then
        local schemaVersion = xmlFile:getInt("agriLifeSettings#schemaVersion", 0)
        if schemaVersion > AgriLife.Version.SETTINGS_SCHEMA then
            self.readOnly = true
            xmlFile:delete()
            self.loaded = true
            self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
            AgriLife.Logger.warning("Settings", "Settings schema %d is newer than supported schema %d; defaults retained", schemaVersion, AgriLife.Version.SETTINGS_SCHEMA)
            return AgriLife.Result.ok("SETTINGS_SCHEMA_NEWER", "Newer local settings ignored", { schemaVersion = schemaVersion })
        end

        if schemaVersion >= 1 and schemaVersion <= AgriLife.Version.SETTINGS_SCHEMA then
            self.schemaVersion = schemaVersion
            self.loggingLevel = AgriLife.Logger.normalizeLevel(xmlFile:getString("agriLifeSettings.logging#level", "INFO"))
            self.showStartupMessage = xmlFile:getBool("agriLifeSettings.interface#showStartupMessage", true)
            self.examHudVisible = xmlFile:getBool("agriLifeSettings.interface.examHud#visible", true)
            self.examHudLocked = xmlFile:getBool("agriLifeSettings.interface.examHud#locked", true)
            self.examHudOffsetX = math.max(-0.70, math.min(0.70, xmlFile:getFloat("agriLifeSettings.interface.examHud#offsetX", 0)))
            self.examHudOffsetY = math.max(-0.70, math.min(0.70, xmlFile:getFloat("agriLifeSettings.interface.examHud#offsetY", 0)))
            self.schemaVersion = AgriLife.Version.SETTINGS_SCHEMA
            xmlFile:delete()
            if schemaVersion < AgriLife.Version.SETTINGS_SCHEMA then self:save() end
            AgriLife.Logger.info("Settings", "Local settings loaded")
        else
            xmlFile:delete()
            AgriLife.Logger.warning("Settings", "Unsupported settings schema %d; defaults restored", schemaVersion)
            local saveResult = self:save()
            if not saveResult.ok then
                AgriLife.Logger.warning("Settings", "Defaults could not be persisted: %s", saveResult.code)
            end
        end
    else
        local saveResult = self:save()
        if not saveResult.ok then
            self.loaded = true
            self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
            return AgriLife.Result.ok("SETTINGS_DEFAULTS", "Defaults retained", { warning = saveResult.code })
        end
        AgriLife.Logger.info("Settings", "Local settings created from defaults")
    end

    self.loaded = true
    self.loggingLevel = AgriLife.Logger.setLevel(self.loggingLevel)
    return AgriLife.Result.ok("SETTINGS_LOADED", "Settings loaded")
end

function AgriLife.Settings:save()
    if self.readOnly then
        return AgriLife.Result.fail("SETTINGS_READ_ONLY", "Local settings are read-only")
    end
    if self.filePath == nil then
        self.filePath = self:getFilePath()
    end
    if self.filePath == nil or XMLFile == nil or XMLFile.create == nil then
        return AgriLife.Result.fail("SETTINGS_PATH_UNAVAILABLE", "Settings path unavailable")
    end

    local directoryResult = self:ensureDirectory()
    if not directoryResult.ok then
        return directoryResult
    end

    self.loggingLevel = AgriLife.Logger.normalizeLevel(self.loggingLevel)
    local ok, result = pcall(function()
        local xmlFile = XMLFile.create("AgriLifeUserSettings", self.filePath, "agriLifeSettings")
        if xmlFile == nil then
            return AgriLife.Result.fail("SETTINGS_CREATE_FAILED", "Could not create local settings file")
        end

        xmlFile:setInt("agriLifeSettings#schemaVersion", AgriLife.Version.SETTINGS_SCHEMA)
        xmlFile:setString("agriLifeSettings.logging#level", self.loggingLevel)
        xmlFile:setBool("agriLifeSettings.interface#showStartupMessage", self.showStartupMessage)
        xmlFile:setBool("agriLifeSettings.interface.examHud#visible", self.examHudVisible==true)
        xmlFile:setBool("agriLifeSettings.interface.examHud#locked", self.examHudLocked==true)
        xmlFile:setFloat("agriLifeSettings.interface.examHud#offsetX", tonumber(self.examHudOffsetX) or 0)
        xmlFile:setFloat("agriLifeSettings.interface.examHud#offsetY", tonumber(self.examHudOffsetY) or 0)
        xmlFile:save()
        xmlFile:delete()
        return AgriLife.Result.ok("SETTINGS_SAVED", "Settings saved")
    end)

    if not ok then
        return AgriLife.Result.fail("SETTINGS_SAVE_FAILED", tostring(result))
    end
    return result
end

function AgriLife.Settings:delete()
    self.loaded = false
    self.filePath = nil
end
