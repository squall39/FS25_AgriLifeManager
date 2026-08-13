-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Bootstrap = {
    core = nil,
    saveInProgress = false,
    saveHookInstalled = false
}

function AgriLife.Bootstrap:loadMap(mapName)
    if self.core ~= nil or g_agriLifeCore ~= nil then
        AgriLife.Logger.warning("Bootstrap", "Duplicate loadMap ignored")
        return
    end

    local ok, coreOrError = pcall(AgriLife.Core.new, g_currentMission)
    if not ok or coreOrError == nil then
        AgriLife.Logger.error("Bootstrap", "Core creation failed: %s", tostring(coreOrError))
        self.core = nil
        g_agriLifeCore = nil
        return
    end

    self.core = coreOrError
    g_agriLifeCore = self.core
    AgriLife.Logger.info("Bootstrap", "Mission listener attached")
end

function AgriLife.Bootstrap:update(dt)
    -- Install on the first update rather than in loadMap. By this point all
    -- mods have had their loadMap callbacks, so a later loadMap-time overwrite
    -- cannot silently remove the AgriLife save hook.
    if not self.saveHookInstalled then
        self:installSaveHook()
    end
    if self.core ~= nil then
        local ok, errorValue = pcall(self.core.update, self.core, dt)
        if not ok then
            AgriLife.Logger.error("Bootstrap", "Unhandled update error: %s", tostring(errorValue))
            self.core.beginRequested = false
        end
    end
end

function AgriLife.Bootstrap:requestSave(source, missionInfo)
    if self.core == nil or self.saveInProgress then return end

    local saveDirectory = missionInfo ~= nil and missionInfo.savegameDirectory or nil
    if saveDirectory == nil or saveDirectory == "" then
        AgriLife.Logger.error("Bootstrap", "AgriLife native save skipped: FSCareerMissionInfo staging directory unavailable (%s)", tostring(source or "unknown"))
        return
    end

    self.saveInProgress = true
    AgriLife.Logger.info("Bootstrap", "AgriLife native save requested (%s staging=%s)", tostring(source or "unknown"), tostring(saveDirectory))
    local ok, result = pcall(self.core.save, self.core, saveDirectory)
    self.saveInProgress = false

    if not ok then
        AgriLife.Logger.error("Bootstrap", "Unhandled save error: %s", tostring(result))
    elseif result ~= nil and not result.ok then
        AgriLife.Logger.error("Bootstrap", "Save failed: %s", tostring(result.code))
    end
end

function AgriLife.Bootstrap:saveToXMLFile(xmlFile, key, usedModNames)
    -- FIX4G: intentionally no gameplay-state write here. Plain ModEventListener
    -- save callbacks do not guarantee that missionInfo.savegameDirectory already
    -- points at FS25's tempsavegame. The explicit FSCareerMissionInfo hook below
    -- is the single authoritative save path.
end

function AgriLife.Bootstrap:installSaveHook()
    if self.saveHookInstalled then return true end
    if FSCareerMissionInfo == nil or FSCareerMissionInfo.saveToXMLFile == nil or Utils == nil or Utils.appendedFunction == nil then
        return false
    end

    local bootstrap = self
    FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(
        FSCareerMissionInfo.saveToXMLFile,
        function(missionInfo, ...)
            bootstrap:requestSave("FSCareerMissionInfo.saveToXMLFile", missionInfo)
        end
    )
    self.saveHookInstalled = true
    AgriLife.Logger.info("Bootstrap", "FS25 native career save hook installed (tempsavegame backend)")
    return true
end

function AgriLife.Bootstrap:deleteMap()
    local core = self.core
    self.core = nil
    g_agriLifeCore = nil
    self.saveInProgress = false

    if core ~= nil then
        local ok, errorValue = pcall(core.delete, core)
        if not ok then
            AgriLife.Logger.error("Bootstrap", "Core deletion failed: %s", tostring(errorValue))
        end
    end
    AgriLife.Logger.info("Bootstrap", "Mission listener detached")
end

function AgriLife.Bootstrap:draw()
end

function AgriLife.Bootstrap:keyEvent(unicode, sym, modifier, isDown)
end

function AgriLife.Bootstrap:mouseEvent(posX, posY, isDown, isUp, button)
end

addModEventListener(AgriLife.Bootstrap)
