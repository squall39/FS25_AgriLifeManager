-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Core = {}
AgriLife.Core.__index = AgriLife.Core

local function isFatalResult(result)
    return result ~= nil and result.details ~= nil and result.details.fatal == true
end

function AgriLife.Core.new(mission)
    local self = setmetatable({}, AgriLife.Core)
    self.lifecycle = AgriLife.Lifecycle.new()
    self.lifecycle:transition(AgriLife.Lifecycle.State.BOOTSTRAPPING, "Core creation")
    self.context = AgriLife.MissionContext.new(mission)
    self.settings = AgriLife.Settings.new()
    self.subscriptions = AgriLife.SubscriptionManager.new()
    self.migrations = AgriLife.MigrationManager.new()
    local legacyMigrationResult = self.migrations:register(0, 1, function()
        return AgriLife.Result.ok("MIGRATION_0_1_OK", "Legacy AgriLife save normalized to schema 1")
    end)
    if legacyMigrationResult ~= nil and not legacyMigrationResult.ok then
        AgriLife.Logger.error("Core", "Save migration 0>1 registration failed: %s", tostring(legacyMigrationResult.code))
    end
    -- Schema 2 adds the legal/fiscal module and physical asset metadata. All
    -- existing schema-1 values remain valid; the new modules initialize their
    -- own defaults when their farm node is absent.
    local migrationResult = self.migrations:register(1, 2, function()
        return AgriLife.Result.ok("MIGRATION_1_2_OK", "AgriLife 6.1 save prepared for the complete 6.2 modules")
    end)
    if migrationResult ~= nil and not migrationResult.ok then
        AgriLife.Logger.error("Core", "Save migration 1>2 registration failed: %s", tostring(migrationResult.code))
    end
    local roadmapMigrationResult = self.migrations:register(2, 3, function()
        return AgriLife.Result.ok("MIGRATION_2_3_OK", "AgriLife save prepared for roadmap modules")
    end)
    if roadmapMigrationResult ~= nil and not roadmapMigrationResult.ok then
        AgriLife.Logger.error("Core", "Save migration 2>3 registration failed: %s", tostring(roadmapMigrationResult.code))
    end
    local finalizationMigrationResult = self.migrations:register(3, 4, function(xmlFile)
        if xmlFile ~= nil then
            xmlFile:setString("agriLifeManager.storage#roadmapFinalizationVersion", "0.9.0.0")
        end
        return AgriLife.Result.ok("MIGRATION_3_4_OK", "AgriLife save prepared for finalization, recovery and per-farm synchronization metadata")
    end)
    if finalizationMigrationResult ~= nil and not finalizationMigrationResult.ok then
        AgriLife.Logger.error("Core", "Save migration 3>4 registration failed: %s", tostring(finalizationMigrationResult.code))
    end
    self.registry = AgriLife.ModuleRegistry.new(self)

    if AgriLife.CompanyModule ~= nil and AgriLife.CompanyModule.register ~= nil then
        local companyRegisterResult = AgriLife.CompanyModule.register(self.registry)
        if companyRegisterResult ~= nil and companyRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Company module registration failed: %s (%s)", tostring(companyRegisterResult.message), tostring(companyRegisterResult.code))
        end
    end

    if AgriLife.PeopleModule ~= nil and AgriLife.PeopleModule.register ~= nil then
        local peopleRegisterResult = AgriLife.PeopleModule.register(self.registry)
        if peopleRegisterResult ~= nil and peopleRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "People module registration failed: %s (%s)", tostring(peopleRegisterResult.message), tostring(peopleRegisterResult.code))
        end
    end

    if AgriLife.BankModule ~= nil and AgriLife.BankModule.register ~= nil then
        local bankRegisterResult = AgriLife.BankModule.register(self.registry)
        if bankRegisterResult ~= nil and bankRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Bank module registration failed: %s (%s)", tostring(bankRegisterResult.message), tostring(bankRegisterResult.code))
        end
    end

    if AgriLife.CareerModule ~= nil and AgriLife.CareerModule.register ~= nil then
        local careerRegisterResult = AgriLife.CareerModule.register(self.registry)
        if careerRegisterResult ~= nil and careerRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Career module registration failed: %s (%s)", tostring(careerRegisterResult.message), tostring(careerRegisterResult.code))
        end
    end

    if AgriLife.ExamModule ~= nil and AgriLife.ExamModule.register ~= nil then
        local examRegisterResult = AgriLife.ExamModule.register(self.registry)
        if examRegisterResult ~= nil and examRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Exam module registration failed: %s (%s)", tostring(examRegisterResult.message), tostring(examRegisterResult.code))
        end
    end

    if AgriLife.PayrollModule ~= nil and AgriLife.PayrollModule.register ~= nil then
        local payrollRegisterResult = AgriLife.PayrollModule.register(self.registry)
        if payrollRegisterResult ~= nil and payrollRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Payroll module registration failed: %s (%s)", tostring(payrollRegisterResult.message), tostring(payrollRegisterResult.code))
        end
    end

    if AgriLife.CommercialContractsModule ~= nil and AgriLife.CommercialContractsModule.register ~= nil then
        local contractsRegisterResult = AgriLife.CommercialContractsModule.register(self.registry)
        if contractsRegisterResult ~= nil and contractsRegisterResult.ok == false then
            AgriLife.Logger.error("Core", "Commercial contracts module registration failed: %s (%s)", tostring(contractsRegisterResult.message), tostring(contractsRegisterResult.code))
        end
    end

    if AgriLife.EconomyModule ~= nil and AgriLife.EconomyModule.register ~= nil then
        local result = AgriLife.EconomyModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Economy module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.IntegrityModule ~= nil and AgriLife.IntegrityModule.register ~= nil then
        local result = AgriLife.IntegrityModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Integrity module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.InsuranceModule ~= nil and AgriLife.InsuranceModule.register ~= nil then
        local result = AgriLife.InsuranceModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Insurance module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.WorkshopModule ~= nil and AgriLife.WorkshopModule.register ~= nil then
        local result = AgriLife.WorkshopModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Workshop module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.AssetLifecycleModule ~= nil and AgriLife.AssetLifecycleModule.register ~= nil then
        local result = AgriLife.AssetLifecycleModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Asset lifecycle module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.LegalModule ~= nil and AgriLife.LegalModule.register ~= nil then
        local result = AgriLife.LegalModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Legal module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.JournalModule ~= nil and AgriLife.JournalModule.register ~= nil then
        local result = AgriLife.JournalModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Journal module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.QualificationsModule ~= nil and AgriLife.QualificationsModule.register ~= nil then
        local result = AgriLife.QualificationsModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Qualifications module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.EnterpriseModule ~= nil and AgriLife.EnterpriseModule.register ~= nil then
        local result = AgriLife.EnterpriseModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Enterprise module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.AdministrationModule ~= nil and AgriLife.AdministrationModule.register ~= nil then
        local result = AgriLife.AdministrationModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Administration module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.DynamicMarketModule ~= nil and AgriLife.DynamicMarketModule.register ~= nil then
        local result = AgriLife.DynamicMarketModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Dynamic market module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.CompatibilityModule ~= nil and AgriLife.CompatibilityModule.register ~= nil then
        local result = AgriLife.CompatibilityModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Compatibility module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.DashboardModule ~= nil and AgriLife.DashboardModule.register ~= nil then
        local result = AgriLife.DashboardModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Dashboard module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    if AgriLife.FinalizationModule ~= nil and AgriLife.FinalizationModule.register ~= nil then
        local result = AgriLife.FinalizationModule.register(self.registry)
        if result ~= nil and result.ok == false then AgriLife.Logger.error("Core", "Finalization module registration failed: %s (%s)", tostring(result.message), tostring(result.code)) end
    end

    self.persistence = AgriLife.Persistence.new(self)
    self.ui = AgriLife.UIManager.new(self)
    self.waitElapsed = 0
    self.waitTimeout = 15000
    self.beginRequested = true
    self.errorCount = 0
    self.lastError = nil
    self.deleted = false
    AgriLife.Logger.info("Core", "Core created (version=%s session=%d)", AgriLife.Version.MOD, self.context.sessionId)
    return self
end

function AgriLife.Core:isRuntimeReady()
    if self.context == nil or not self.context:isValid() then
        return false
    end
    -- A brand-new FS25 career may not expose missionInfo.savegameDirectory
    -- until the first native save. That is now intentional: AgriLife starts
    -- with a fresh in-memory career state, then persists AgriLifeManager.xml
    -- into FS25's tempsavegame staging directory on the first save.
    if self.context.refreshRuntimeInfo ~= nil then
        self.context:refreshRuntimeInfo()
    end
    if self.context.isDedicatedServer then
        return true
    end
    return g_gui ~= nil and self.ui:getInGameMenu() ~= nil
end

function AgriLife.Core:isFarmActivated(farmId)
    local economy=self.registry~=nil and self.registry.instances~=nil and self.registry.instances.economy or nil
    if economy==nil or economy.isReady==nil then return true end
    return economy:isReady(tonumber(farmId) or 0)==true
end

function AgriLife.Core:failStartup(result)
    self.beginRequested = false
    if self.lifecycle ~= nil and self.lifecycle:canTransition(AgriLife.Lifecycle.State.FAILED) then
        self.lifecycle:transition(AgriLife.Lifecycle.State.FAILED, result ~= nil and result.code or "STARTUP_FAILED")
    end
    return result or AgriLife.Result.fail("STARTUP_FAILED", "Core startup failed", { fatal = true })
end

function AgriLife.Core:beginMission()
    if self.deleted then
        return AgriLife.Result.fail("CORE_DELETED", "Core already deleted", { fatal = true })
    end

    local state = self.lifecycle:getState()
    if state == AgriLife.Lifecycle.State.RUNNING or state == AgriLife.Lifecycle.State.DEGRADED then
        return AgriLife.Result.fail("CORE_ALREADY_RUNNING", "Core already running")
    end
    if state ~= AgriLife.Lifecycle.State.BOOTSTRAPPING and state ~= AgriLife.Lifecycle.State.WAITING_RUNTIME then
        self.beginRequested = false
        return AgriLife.Result.fail("CORE_START_STATE_INVALID", "Core cannot start from state " .. tostring(state), { fatal = true })
    end

    if not self:isRuntimeReady() then
        if self.lifecycle:canTransition(AgriLife.Lifecycle.State.WAITING_RUNTIME) then
            self.lifecycle:transition(AgriLife.Lifecycle.State.WAITING_RUNTIME, "Waiting for menu runtime")
        end
        return AgriLife.Result.fail("RUNTIME_NOT_READY", "Runtime not ready")
    end

    self.lifecycle:transition(AgriLife.Lifecycle.State.LOADING_SETTINGS, "Loading local settings")
    local settingsResult = self.settings:load()
    if not settingsResult.ok then
        self:recordError(settingsResult)
    end

    self.lifecycle:transition(AgriLife.Lifecycle.State.LOADING_SAVE, "Loading savegame data")
    local createResult = self.registry:createAll()
    if not createResult.ok then
        self:recordError(createResult)
        if isFatalResult(createResult) then
            return self:failStartup(createResult)
        end
    end

    local allowModuleStart = true
    local loadResult = self.persistence:load()
    if not loadResult.ok then
        self:recordError(loadResult)
        if isFatalResult(loadResult) then
            allowModuleStart = false
        end
    end

    -- Start the authoritative services before mounting the GUI. loadGui() calls
    -- HomeFrame:onGuiSetupFinished(), which immediately refreshes the screen.
    -- Mounting first therefore used to query People before the real FS25 player
    -- was synchronized and created a ghost SP_FARM_x / "Joueur" owner profile.
    if allowModuleStart then
        local startResult = self.registry:startAll()
        if not startResult.ok then
            self:recordError(startResult)
            if isFatalResult(startResult) then
                return self:failStartup(startResult)
            end
        end
    else
        AgriLife.Logger.warning("Core", "Gameplay modules were not started because persistence is unavailable")
    end

    self.lifecycle:transition(AgriLife.Lifecycle.State.MOUNTING_UI, "Mounting application")
    if not self.context.isDedicatedServer then
        local uiResult = self.ui:mount()
        if not uiResult.ok then
            self:recordError(uiResult)
            return self:failStartup(uiResult)
        end
    else
        AgriLife.Logger.info("UI", "Dedicated server detected; UI mount skipped")
    end

    if allowModuleStart and self.ui ~= nil and self.ui.frame ~= nil and self.ui.frame.refresh ~= nil then
        self.ui.frame:refresh()
    end

    self.beginRequested = false
    if self.errorCount > 0 or not allowModuleStart then
        self.lifecycle:transition(AgriLife.Lifecycle.State.DEGRADED, "Startup completed with controlled issues")
    else
        self.lifecycle:transition(AgriLife.Lifecycle.State.RUNNING, "Startup complete")
    end

    AgriLife.Logger.info("Core", "Mission started")
    return AgriLife.Result.ok("CORE_RUNNING", "Core running")
end

function AgriLife.Core:update(dt)
    if self.deleted then return end

    -- UI runtime duties (notably the deferred first-run tutorial prompt) must
    -- keep running after beginMission() clears beginRequested.
    if self.ui ~= nil and self.ui.update ~= nil then
        local okUi, uiError = pcall(self.ui.update, self.ui, dt)
        if not okUi then AgriLife.Logger.warning("Core", "UI update failed: %s", tostring(uiError)) end
    end
    if self.registry ~= nil and self.registry.updateAll ~= nil then
        self.registry:updateAll(dt)
    end

    if not self.beginRequested then return end

    if self:isRuntimeReady() then
        local result = self:beginMission()
        if result ~= nil and not result.ok and isFatalResult(result) then
            self.beginRequested = false
        end
        return
    end

    self.waitElapsed = self.waitElapsed + (dt or 0)
    if self.waitElapsed >= self.waitTimeout then
        -- UI availability is timing-dependent in FS25. A late ESC controller
        -- must never kill the whole AgriLife core: log once per interval and
        -- keep retrying until the mission exposes the menu.
        AgriLife.Logger.warning("Core", "In-game menu runtime still unavailable; continuing to retry")
        self.waitElapsed = 0
    elseif not self.lifecycle:is(AgriLife.Lifecycle.State.WAITING_RUNTIME) and self.lifecycle:canTransition(AgriLife.Lifecycle.State.WAITING_RUNTIME) then
        self.lifecycle:transition(AgriLife.Lifecycle.State.WAITING_RUNTIME, "Waiting for menu runtime")
    end
end

function AgriLife.Core:save(saveDirectory)
    local state = self.lifecycle:getState()
    if state ~= AgriLife.Lifecycle.State.RUNNING and state ~= AgriLife.Lifecycle.State.DEGRADED then
        return AgriLife.Result.fail("CORE_NOT_SAVEABLE", "Core is not in a saveable state")
    end

    local returnState = state
    local transition = self.lifecycle:transition(AgriLife.Lifecycle.State.SAVING, "Save requested")
    if not transition.ok then
        return transition
    end

    local result = self.persistence:save(saveDirectory)
    if not result.ok then
        self:recordError(result)
        self.lifecycle:transition(AgriLife.Lifecycle.State.DEGRADED, result.code)
    else
        self.lifecycle:transition(returnState, "Save completed")
    end

    if self.ui ~= nil and self.ui.frame ~= nil then
        self.ui.frame:refresh()
    end
    return result
end

function AgriLife.Core:recordError(result)
    if type(result) ~= "table" then
        result = AgriLife.Result.fail("UNKNOWN_ERROR", tostring(result))
    end
    local increment = 1
    if result.details ~= nil and tonumber(result.details.failedCount) ~= nil then
        increment = math.max(1, tonumber(result.details.failedCount))
    end
    self.errorCount = self.errorCount + increment
    self.lastError = result
    AgriLife.Logger.error("Core", "%s: %s", tostring(result.code), tostring(result.message))
end

function AgriLife.Core:stop()
    if self.deleted or self.lifecycle == nil or self.lifecycle:is(AgriLife.Lifecycle.State.STOPPED) then
        return AgriLife.Result.ok("CORE_ALREADY_STOPPED", "Core already stopped")
    end

    self.beginRequested = false
    if self.lifecycle:canTransition(AgriLife.Lifecycle.State.STOPPING) then
        self.lifecycle:transition(AgriLife.Lifecycle.State.STOPPING, "Mission closing")
    end

    if self.ui ~= nil then
        self.ui:unmount()
    end
    if self.registry ~= nil then
        self.registry:stopAll()
    end
    if self.subscriptions ~= nil then
        self.subscriptions:delete()
    end

    if self.lifecycle:canTransition(AgriLife.Lifecycle.State.STOPPED) then
        self.lifecycle:transition(AgriLife.Lifecycle.State.STOPPED, "Cleanup complete")
    end
    return AgriLife.Result.ok("CORE_STOPPED", "Core stopped")
end

function AgriLife.Core:delete()
    if self.deleted then
        return
    end

    local sessionId = self.context ~= nil and self.context.sessionId or 0
    self:stop()
    if self.registry ~= nil then self.registry:delete() end
    if self.persistence ~= nil then self.persistence:delete() end
    if self.migrations ~= nil then self.migrations:delete() end
    if self.settings ~= nil then self.settings:delete() end
    if self.ui ~= nil then self.ui:delete() end
    if self.context ~= nil then self.context:delete() end

    self.registry = nil
    self.persistence = nil
    self.migrations = nil
    self.settings = nil
    self.subscriptions = nil
    self.ui = nil
    self.context = nil
    self.lifecycle = nil
    self.lastError = nil
    self.deleted = true
    AgriLife.Logger.info("Core", "Core destroyed (session=%d)", sessionId)
end

function AgriLife.Core:getStatusSnapshot()
    local modules = self.registry ~= nil and self.registry:getSnapshot() or { registered = 0, active = 0, failed = 0, disabled = 0 }
    return {
        version = AgriLife.Version.MOD,
        state = self.lifecycle ~= nil and self.lifecycle:getState() or AgriLife.Lifecycle.State.STOPPED,
        sessionId = self.context ~= nil and self.context.sessionId or 0,
        isServer = self.context ~= nil and self.context.isServer or false,
        isMultiplayer = self.context ~= nil and self.context.isMultiplayer or false,
        farmId = self.context ~= nil and self.context:getFarmId() or 0,
        schemaVersion = AgriLife.Version.SAVE_SCHEMA,
        saveSequence = self.persistence ~= nil and self.persistence.saveSequence or 0,
        lastSaveOk = self.persistence ~= nil and self.persistence.lastSaveOk or nil,
        moduleCount = modules.registered,
        activeModuleCount = modules.active,
        disabledModuleCount = modules.disabled,
        errorCount = self.errorCount,
        lastError = self.lastError
    }
end
