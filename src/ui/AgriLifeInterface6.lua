-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - roadmap step 2: interface and user experience.
-- This layer is presentation-only. It never owns gameplay or save data.

AgriLife = AgriLife or {}

AgriLife.Interface6 = {}
AgriLife.Interface6.__index = AgriLife.Interface6

AgriLife.Interface6.CANONICAL = {
    DASHBOARD = "dashboard",
    BANK = "bank",
    ENTERPRISE = "enterprise",
    CAREER = "careerQualifications",
    ADMINISTRATION = "administration",
    CONTRACTS = "contractsMarkets",
    WORKSHOP = "workshop"
}

AgriLife.Interface6.PAGE_BY_CANONICAL = {
    dashboard = "dashboard",
    bank = "bank",
    enterprise = "payroll",
    careerQualifications = "exams",
    administration = "insurance",
    contractsMarkets = "contracts",
    workshop = "workshop"
}

AgriLife.Interface6.CANONICAL_BY_PAGE = {
    dashboard = "dashboard",
    bank = "bank",
    payroll = "enterprise",
    company = "enterprise",
    exams = "careerQualifications",
    xp = "careerQualifications",
    insurance = "administration",
    accidents = "administration",
    contracts = "contractsMarkets",
    leasing = "contractsMarkets",
    used = "contractsMarkets",
    workshop = "workshop"
}

AgriLife.Interface6.NAVIGATION_ORDER = {
    "bank",
    "enterprise",
    "careerQualifications",
    "administration",
    "contractsMarkets",
    "workshop"
}

local function setText(element, value)
    if element ~= nil and element.setText ~= nil then
        element:setText(tostring(value or ""))
    end
end

local function setVisible(element, visible)
    if element ~= nil and element.setVisible ~= nil then
        element:setVisible(visible == true)
    end
end

local function setDisabled(element, disabled)
    if element ~= nil and element.setDisabled ~= nil then
        element:setDisabled(disabled == true)
    end
end

local function setImageColor(element, r, g, b, a)
    if element ~= nil and element.setImageColor ~= nil then
        element:setImageColor(r, g, b, a or 1)
    end
end

local function setTextColor(element, r, g, b, a)
    if element ~= nil and element.setTextColor ~= nil then
        element:setTextColor(r, g, b, a or 1)
    end
end

local function tr(key)
    if g_i18n == nil or g_i18n.getText == nil then return "--" end
    local value = g_i18n:getText(key)
    if value == nil or value == "" or value == key then return "--" end
    return value
end

local function trf(key, ...)
    local pattern = tr(key)
    if pattern == "--" then return pattern end
    local ok, value = pcall(string.format, pattern, ...)
    return ok and value or pattern
end

local function formatMoney(value)
    value = tonumber(value) or 0
    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        local ok, textValue = pcall(g_i18n.formatMoney, g_i18n, value, 0, true, true)
        if ok and textValue ~= nil then return textValue end
    end
    return string.format("%.0f", value)
end

local function module(core, id)
    if core == nil or core.registry == nil or core.registry.instances == nil then return nil end
    return core.registry.instances[id]
end

local function safeSnapshot(instance, methodName, farmId)
    if instance == nil or instance[methodName] == nil then return nil end
    local ok, result = pcall(instance[methodName], instance, farmId)
    return ok and result or nil
end

function AgriLife.Interface6.new(frame)
    return setmetatable({frame = frame}, AgriLife.Interface6)
end

function AgriLife.Interface6:getCore()
    return self.frame ~= nil and self.frame.core or nil
end

function AgriLife.Interface6:getFarmId()
    local core = self:getCore()
    if core == nil or core.context == nil or core.context.getFarmId == nil then return 0 end
    return tonumber(core.context:getFarmId()) or 0
end

function AgriLife.Interface6:getStartupSnapshot()
    local economy = module(self:getCore(), "economy")
    return safeSnapshot(economy, "getStartupSnapshot", self:getFarmId())
end

function AgriLife.Interface6:getDashboardSnapshot()
    local facade = module(self:getCore(), "dashboardFacade")
    return safeSnapshot(facade, "getSnapshot", self:getFarmId())
end

function AgriLife.Interface6:canonicalize(pageId)
    pageId = tostring(pageId or "dashboard")
    if AgriLife.Interface6.PAGE_BY_CANONICAL[pageId] ~= nil then return pageId end
    return AgriLife.Interface6.CANONICAL_BY_PAGE[pageId] or "dashboard"
end

function AgriLife.Interface6:pageForCanonical(canonicalId)
    return AgriLife.Interface6.PAGE_BY_CANONICAL[canonicalId] or "dashboard"
end

function AgriLife.Interface6:getStartupMessage(step)
    local map = {
        migration = {state = "agrilife_onboarding_existing_state", message = "agrilife_onboarding_existing_msg", action = "agrilife_onboarding_existing_button"},
        tutorial = {state = "agrilife_onboarding_choice_required_state", message = "agrilife_onboarding_choice_required_msg", action = "agrilife_onboarding_choice_required_button"},
        difficulty = {state = "agrilife_onboarding_mode_first_state", message = "agrilife_onboarding_mode_first_msg", action = "agrilife_onboarding_mode_first_button"},
        bank = {state = "agrilife_onboarding_bank_state", message = "agrilife_onboarding_bank_msg", action = "agrilife_onboarding_bank_button"},
        advisor = {state = "agrilife_onboarding_advisor_state", message = "agrilife_onboarding_advisor_msg", action = "agrilife_onboarding_advisor_button"},
        exam = {state = "agrilife_onboarding_licence_state", message = "agrilife_onboarding_licence_msg", action = "agrilife_onboarding_licence_button"},
        ready = {state = "agrilife_onboarding_ready", message = "agrilife_onboarding_ready_message_simple", action = "agrilife_onboarding_validated"}
    }
    return map[tostring(step or "")] or map.tutorial
end

function AgriLife.Interface6:isCanonicalReachable(canonicalId, startup)
    if canonicalId == "dashboard" then return true end
    if startup == nil then return false end

    local step = tostring(startup.step or "tutorial")
    if step == "ready" then return true end
    if step == "bank" or step == "advisor" then return canonicalId == "bank" end
    if step == "exam" then return canonicalId == "bank" or canonicalId == "careerQualifications" end
    return false
end

function AgriLife.Interface6:getNavigationSnapshot(startup)
    startup = startup or self:getStartupSnapshot()
    local state = {dashboard = {enabled = true, page = "dashboard"}}
    for _, canonicalId in ipairs(AgriLife.Interface6.NAVIGATION_ORDER) do
        state[canonicalId] = {
            enabled = self:isCanonicalReachable(canonicalId, startup),
            page = self:pageForCanonical(canonicalId)
        }
    end
    return state
end

function AgriLife.Interface6:resolvePage(requestedPage, startup)
    startup = startup or self:getStartupSnapshot()
    local canonicalId = self:canonicalize(requestedPage)
    if self:isCanonicalReachable(canonicalId, startup) then
        if canonicalId == "careerQualifications" and (requestedPage == "xp" or requestedPage == "exams") then
            return requestedPage, nil
        end
        return self:pageForCanonical(canonicalId), nil
    end

    local step = tostring(startup ~= nil and startup.step or "tutorial")
    local target = "dashboard"
    if step == "bank" or step == "advisor" then
        target = "bank"
    elseif step == "exam" then
        target = "exams"
    end

    local message = self:getStartupMessage(step)
    return target, message.message
end

function AgriLife.Interface6:getNavElements(canonicalId)
    local frame = self.frame
    if frame == nil then return nil end
    local map = {
        dashboard = {button = frame.navDashboard, bg = frame.navDashboardBg, accent = frame.navDashboardAccent, icon = frame.navDashboardIcon, label = frame.navDashboardLabel},
        bank = {button = frame.navBank, bg = frame.navBankBg, accent = frame.navBankAccent, icon = frame.navBankIcon, label = frame.navBankLabel},
        enterprise = {button = frame.navPayroll, bg = frame.navPayrollBg, accent = frame.navPayrollAccent, icon = frame.navPayrollIcon, label = frame.navPayrollLabel},
        careerQualifications = {button = frame.navExams, bg = frame.navExamsBg, accent = frame.navExamsAccent, icon = frame.navExamsIcon, label = frame.navExamsLabel},
        administration = {button = frame.navInsurance, bg = frame.navInsuranceBg, accent = frame.navInsuranceAccent, icon = frame.navInsuranceIcon, label = frame.navInsuranceLabel},
        contractsMarkets = {button = frame.navContracts, bg = frame.navContractsBg, accent = frame.navContractsAccent, icon = frame.navContractsIcon, label = frame.navContractsLabel},
        workshop = {button = frame.navWorkshop, bg = frame.navWorkshopBg, accent = frame.navWorkshopAccent, icon = frame.navWorkshopIcon, label = frame.navWorkshopLabel}
    }
    return map[canonicalId]
end

function AgriLife.Interface6:applyNavigation(activePage, startup)
    startup = startup or self:getStartupSnapshot()
    local activeCanonical = self:canonicalize(activePage)
    local states = self:getNavigationSnapshot(startup)
    local ids = {"dashboard", "bank", "enterprise", "careerQualifications", "administration", "contractsMarkets", "workshop"}

    for _, canonicalId in ipairs(ids) do
        local elements = self:getNavElements(canonicalId)
        local enabled = states[canonicalId] ~= nil and states[canonicalId].enabled == true
        local active = canonicalId == activeCanonical
        if elements ~= nil then
            setDisabled(elements.button, not enabled)
            if not enabled then
                setImageColor(elements.bg, 0.032, 0.041, 0.045, 1)
                setImageColor(elements.accent, 0.20, 0.24, 0.22, 1)
                setImageColor(elements.icon, 0.34, 0.38, 0.37, 1)
                setTextColor(elements.label, 0.42, 0.46, 0.45, 1)
            elseif active then
                setImageColor(elements.bg, 0.31, 0.45, 0.10, 1)
                setImageColor(elements.accent, 0.63, 0.86, 0.08, 1)
                setImageColor(elements.icon, 0.98, 1.00, 0.94, 1)
                setTextColor(elements.label, 0.98, 1.00, 0.96, 1)
            else
                setImageColor(elements.bg, 0.045, 0.061, 0.066, 1)
                setImageColor(elements.accent, 0.34, 0.46, 0.12, 1)
                setImageColor(elements.icon, 0.82, 0.87, 0.85, 1)
                setTextColor(elements.label, 0.82, 0.87, 0.85, 1)
            end
        end
    end

    -- Legacy entries are deliberately hidden from the final six-module root.
    for _, element in ipairs({
        self.frame.navCompany, self.frame.navCompanyBg, self.frame.navCompanyAccent, self.frame.navCompanyIcon, self.frame.navCompanyLabel,
        self.frame.navXp, self.frame.navXpBg, self.frame.navXpAccent, self.frame.navXpIcon, self.frame.navXpLabel,
        self.frame.navAccidents, self.frame.navAccidentsBg, self.frame.navAccidentsAccent, self.frame.navAccidentsIcon, self.frame.navAccidentsLabel,
        self.frame.navLeasing, self.frame.navLeasingBg, self.frame.navLeasingAccent, self.frame.navLeasingIcon, self.frame.navLeasingLabel,
        self.frame.navUsed, self.frame.navUsedBg, self.frame.navUsedAccent, self.frame.navUsedIcon, self.frame.navUsedLabel
    }) do
        setVisible(element, false)
    end
end

function AgriLife.Interface6:bindStartupBar(startup)
    local frame = self.frame
    if frame == nil then return end
    startup = startup or self:getStartupSnapshot()
    if startup == nil then
        setText(frame.sidebarCoreStateMirror, tr("agrilife_onboarding_unavailable"))
        setText(frame.dashboardMessage, tr("agrilife_onboarding_unavailable"))
        setDisabled(frame.onboardingActivateButton, true)
        return
    end

    local step = tostring(startup.step or "tutorial")
    local textKeys = self:getStartupMessage(step)
    setText(frame.sidebarCoreStateMirror, tr(textKeys.state))

    if step == "ready" then
        local provisional = startup.provisionalLicence or {}
        if provisional.enabled == true and provisional.completed ~= true then
            if provisional.expired == true then
                setText(frame.sidebarCoreStateMirror, tr("agrilife_provisional_dashboard_expired_state"))
                setText(frame.dashboardMessage, trf("agrilife_provisional_dashboard_expired_msg", tonumber(provisional.fineAmount) or 500))
            else
                setText(frame.sidebarCoreStateMirror, trf("agrilife_provisional_dashboard_state", tonumber(provisional.remainingMonths) or 3))
                setText(frame.dashboardMessage, trf("agrilife_provisional_dashboard_msg", tonumber(provisional.remainingMonths) or 3, 500))
            end
        else
            local modeKey = "agrilife_mode_" .. tostring(startup.modeId or "facile")
            setText(frame.dashboardMessage, trf("agrilife_onboarding_ready_message_simple", tr(modeKey)))
        end
    else
        setText(frame.dashboardMessage, frame.lastOnboardingMessage or tr(textKeys.message))
    end

    setText(frame.onboardingActivateButton, tr(textKeys.action))
    setDisabled(frame.onboardingActivateButton, false)
    setVisible(frame.onboardingModeButton, step == "difficulty")
end

function AgriLife.Interface6:bindDashboard(startup, dashboard)
    local frame = self.frame
    if frame == nil then return end
    startup = startup or self:getStartupSnapshot()
    dashboard = dashboard or self:getDashboardSnapshot()

    local cards = dashboard ~= nil and dashboard.cards or {}
    local bank = cards.bank or {}
    setText(frame.headerCash, formatMoney(bank.cash or 0))
    setText(frame.dashBankCash, formatMoney(bank.cash or 0))
    setText(frame.dashBankDebt, formatMoney(bank.debt or 0))

    local relationship = bank.relationship or {}
    local relationshipText = tr("agrilife_bank_relationship_none")
    if relationship.status == "active" then
        relationshipText = trf("agrilife_bank_relationship_active_fmt", tonumber(relationship.remainingMonths) or 0)
    elseif relationship.status == "expired" then
        relationshipText = tr("agrilife_bank_relationship_expired")
    elseif tostring(bank.providerName or "") ~= "" then
        relationshipText = tostring(bank.providerName)
    end
    setText(frame.dashBankScore, trf("agrilife_dashboard_bank_score_relation_fmt", tonumber(bank.score) or 0, relationshipText))

    local enterprise = cards.enterprise or {}
    setText(frame.dashExamState, trf("agrilife_dashboard_enterprise_active_fmt", tonumber(enterprise.employees) or 0))
    setText(frame.dashExamProgress, trf("agrilife_dashboard_enterprise_availability_fmt", tonumber(enterprise.available) or 0, tonumber(enterprise.busy) or 0))
    setText(frame.dashExamCatalog, trf("agrilife_dashboard_enterprise_reputation_fmt", tonumber(enterprise.reputation) or 50, tonumber(enterprise.activeOrders) or 0))

    local career = cards.careerQualifications or {}
    setText(frame.dashCareerLevel, trf("agrilife_dashboard_career_level_fmt", tonumber(career.level) or 1, tonumber(career.totalXP) or 0))
    local licenceText = tr("agrilife_exam6_state_optional")
    local provisional = startup ~= nil and startup.provisionalLicence or {}
    if career.examRunning == true then
        licenceText = trf("agrilife_dashboard_exam_running_fmt", tonumber(career.examProgress) or 0)
    elseif tostring(career.generalLicence or "") == "obtained" or (startup ~= nil and startup.licenceObtained == true) then
        licenceText = trf("agrilife_dashboard_licence_obtained_fmt", tonumber(career.lastResultScore) or tonumber(career.bestScore) or 0)
    elseif provisional ~= nil and provisional.enabled == true and provisional.completed ~= true then
        if provisional.expired == true then
            licenceText = tr("agrilife_exam6_state_provisional_expired")
        elseif provisional.started == true then
            licenceText = trf("agrilife_exam6_dashboard_months_left", tonumber(provisional.remainingMonths) or 0)
        else
            licenceText = tr("agrilife_exam6_state_provisional_pending")
        end
    elseif startup ~= nil and startup.licenceRequired == true then
        licenceText = tr("agrilife_dashboard_exam_required")
    end
    setText(frame.dashCareerXp, licenceText)
    setText(frame.dashCareerReputation, trf("agrilife_dashboard_qualifications_count_fmt", tonumber(career.qualificationCount) or 0))

    local administration = cards.administration or {}
    setText(frame.dashInsuranceState, trf("agrilife_dashboard_administration_compliance_fmt", tonumber(administration.compliance) or 0, (administration.statusLabelKey ~= nil and tr(administration.statusLabelKey) or tostring(administration.businessStatus or "small_farm"))))
    setText(frame.dashInsuranceDetail, trf("agrilife_dashboard_administration_detail_fmt", tonumber(administration.openSanctions) or 0, formatMoney(administration.unpaidAmount or 0), administration.insuranceCompliant == false and tr("agrilife_core_no") or tr("agrilife_core_yes")))

    local contracts = cards.contractsMarkets or {}
    local commodities = tonumber(contracts.commoditiesIndex) or 1
    local directionKey = "agrilife_market_direction_stable"
    if commodities > 1.015 then directionKey = "agrilife_market_direction_up"
    elseif commodities < 0.985 then directionKey = "agrilife_market_direction_down" end
    setText(frame.statusValueCard, trf("agrilife_dashboard_market_index_fmt", tr(directionKey), commodities))
    setText(frame.valueVersion, tostring(tonumber(contracts.activeContracts) or 0))
    setText(frame.valueModules, tostring(tonumber(contracts.opportunityCount) or 0))
    setText(frame.valueErrors, trf("agrilife_dashboard_fuel_index_fmt", tonumber(contracts.fuelIndex) or 1))
    setText(frame.valueLastSave, trf("agrilife_dashboard_inputs_index_fmt", tonumber(contracts.inputIndex) or 1))

    local workshop = cards.workshop or {}
    setText(frame.dashWorkshopState, trf("agrilife_dashboard_workshop_state_fmt", tonumber(workshop.vehicleCount) or 0, tonumber(workshop.immobilized) or 0))
    setText(frame.dashWorkshopDetail, trf("agrilife_dashboard_workshop_detail_fmt", tonumber(workshop.serviceDue) or 0, tonumber(workshop.breakdowns) or 0, tonumber(workshop.activeLeases) or 0, formatMoney(workshop.fleetMarketValue or 0)))
end

function AgriLife.Interface6:refreshDashboard()
    local frame = self.frame
    local core = self:getCore()
    if frame == nil or core == nil then return end

    local farmId = self:getFarmId()
    local status = core.getStatusSnapshot ~= nil and core:getStatusSnapshot() or {}
    setText(frame.headerVersion, status.version or "--")
    setText(frame.headerFarm, string.format("%s %s", tr("agrilife_core_farm"), tostring(farmId)))

    local startup = self:getStartupSnapshot()
    self:bindStartupBar(startup)
    self:bindDashboard(startup, self:getDashboardSnapshot())
    self:applyNavigation(frame.activePage or "dashboard", startup)

    -- The guided tutorial still owns its overlay, but it no longer owns the
    -- startup gate. Startup order comes only from getStartupSnapshot().
    local economy = module(core, "economy")
    local legacyTutorialSnapshot = safeSnapshot(economy, "getSnapshot", farmId)
    if frame.refreshTutorialOverlay ~= nil then
        frame:refreshTutorialOverlay(farmId, legacyTutorialSnapshot)
    end
end

function AgriLife.Interface6:showPage(requestedPage)
    local frame = self.frame
    if frame == nil then return end

    local startup = self:getStartupSnapshot()
    local pageId, reasonKey = self:resolvePage(requestedPage, startup)
    if reasonKey ~= nil then frame.lastOnboardingMessage = tr(reasonKey) end
    frame.activePage = pageId

    setVisible(frame.dashboardPage, pageId == "dashboard")
    setVisible(frame.bankPage, pageId == "bank")
    setVisible(frame.payrollPage, pageId == "payroll")
    setVisible(frame.examPage, pageId == "exams")
    setVisible(frame.insurancePage, pageId == "insurance")
    setVisible(frame.contractsPage, pageId == "contracts")
    setVisible(frame.workshopPage, pageId == "workshop")

    -- These pages remain implementation details and are not root modules.
    setVisible(frame.companyPage, false)
    setVisible(frame.xpPage, pageId == "xp")
    setVisible(frame.accidentsPage, false)
    setVisible(frame.leasingPage, false)
    setVisible(frame.usedPage, false)

    if pageId == "exams" then
        local own = frame.examSubview ~= "team"
        setVisible(frame.examSelfSummaryPanel, own)
        setVisible(frame.examSelfTaskPanel, own)
        setVisible(frame.examSelfStatusPanel, own)
        setVisible(frame.examTeamPanel, not own)
        setDisabled(frame.examSelfTabButton, own)
        setDisabled(frame.examTeamTabButton, not own)
    elseif pageId == "xp" then
        local own = frame.careerSubview ~= "team"
        setVisible(frame.careerSelfSummaryPanel, own)
        setVisible(frame.careerSelfStatsPanel, own)
        setVisible(frame.careerSelfSpecialtiesPanel, own)
        setVisible(frame.xpStatusText, own)
        setVisible(frame.careerTeamPanel, not own)
        setDisabled(frame.careerSelfTabButton, own)
        setDisabled(frame.careerTeamTabButton, not own)
    elseif pageId == "payroll" then
        local own = frame.payrollSubview ~= "team"
        setVisible(frame.payrollSelfPanel, own)
        setVisible(frame.payrollTeamPanel, not own)
        setDisabled(frame.payrollSelfTabButton, own)
        local canManage = frame.canManage ~= nil and frame:canManage("payroll.manage") == true
        setDisabled(frame.payrollTeamTabButton, (not own) or not canManage)
    end

    self:applyNavigation(pageId, startup)
    if frame.refresh ~= nil then frame:refresh() end
end

function AgriLife.Interface6:onStartupAction()
    local frame = self.frame
    local core = self:getCore()
    if frame == nil or core == nil then return end
    local farmId = self:getFarmId()
    local economy = module(core, "economy")
    if economy == nil or economy.getStartupSnapshot == nil then return end

    local startup = economy:getStartupSnapshot(farmId)
    if startup == nil then return end
    local step = tostring(startup.step or "tutorial")
    local result = nil

    if step == "migration" and economy.acknowledgeExistingCareer ~= nil then
        result = economy:acknowledgeExistingCareer(farmId)
    elseif step == "tutorial" then
        if frame.promptTutorialChoice ~= nil then frame:promptTutorialChoice() end
        return
    elseif step == "difficulty" and economy.confirmMode ~= nil then
        result = economy:confirmMode(farmId)
    elseif step == "bank" or step == "advisor" then
        self:showPage("bank")
        return
    elseif step == "exam" then
        self:showPage("exams")
        return
    elseif step == "ready" then
        frame.lastOnboardingMessage = nil
        self:refreshDashboard()
        return
    end

    frame.lastOnboardingMessage = result ~= nil and result.message or nil
    if frame.refresh ~= nil then frame:refresh() end
end

function AgriLife.Interface6.install()
    if AgriLife.HomeFrame == nil or AgriLife.HomeFrame.__interface6Installed == true then return end
    AgriLife.HomeFrame.__interface6Installed = true

    local function presenter(self)
        if self.interface6 == nil then self.interface6 = AgriLife.Interface6.new(self) end
        return self.interface6
    end

    function AgriLife.HomeFrame:getInterface6()
        return presenter(self)
    end

    function AgriLife.HomeFrame:isPageAvailableForDifficulty(pageId, snapshot)
        local ui = presenter(self)
        local startup = ui:getStartupSnapshot()
        return ui:isCanonicalReachable(ui:canonicalize(pageId), startup)
    end

    function AgriLife.HomeFrame:updateNavigationStyle(pageId)
        presenter(self):applyNavigation(pageId, presenter(self):getStartupSnapshot())
    end

    function AgriLife.HomeFrame:refreshOnboarding(farmId)
        presenter(self):bindStartupBar(presenter(self):getStartupSnapshot())
    end

    function AgriLife.HomeFrame:refreshDashboard()
        presenter(self):refreshDashboard()
    end

    function AgriLife.HomeFrame:showPage(pageId)
        presenter(self):showPage(pageId)
    end

    function AgriLife.HomeFrame:onClickOnboardingActivate()
        presenter(self):onStartupAction()
    end

    -- Final module aliases. Old detail pages remain reachable internally, but
    -- the player-facing root always resolves to the six roadmap modules.
    function AgriLife.HomeFrame:onClickCompany() self:showPage("enterprise") end
    function AgriLife.HomeFrame:onClickPayroll() self:showPage("enterprise") end
    function AgriLife.HomeFrame:onClickXp() self:showPage("careerQualifications") end
    function AgriLife.HomeFrame:onClickExams() self:showPage("careerQualifications") end
    function AgriLife.HomeFrame:onClickAccidents() self:showPage("administration") end
    function AgriLife.HomeFrame:onClickInsurance() self:showPage("administration") end
    function AgriLife.HomeFrame:onClickLeasing() self:showPage("contractsMarkets") end
    function AgriLife.HomeFrame:onClickUsed() self:showPage("contractsMarkets") end
    function AgriLife.HomeFrame:onClickContracts() self:showPage("contractsMarkets") end
end

AgriLife.Interface6.install()
