-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.HomeFrame = {}
AgriLife.HomeFrame_mt = Class(AgriLife.HomeFrame, TabbedMenuFrameElement)

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
        element:setImageColor(nil, r, g, b, a)
    end
end

local function setTextColor(element, r, g, b, a)
    if element ~= nil and element.setTextColor ~= nil then
        element:setTextColor(r, g, b, a)
    end
end


local function setResolvedImageFilename(element, relativePath)
    if element == nil or element.setImageFilename == nil or relativePath == nil then return end
    local baseDir = AgriLife ~= nil and AgriLife.Version ~= nil and AgriLife.Version.MOD_DIR or g_currentModDirectory or ""
    local filename = relativePath
    if Utils ~= nil and Utils.getFilename ~= nil then
        filename = Utils.getFilename(relativePath, baseDir)
    elseif baseDir ~= "" then
        filename = tostring(baseDir) .. tostring(relativePath)
    end
    element:setImageFilename(filename)
end

local function upperDisplay(value)
    local text = string.upper(tostring(value or ""))
    local accents = {
        ["é"]="É", ["è"]="È", ["ê"]="Ê", ["ë"]="Ë", ["à"]="À", ["â"]="Â", ["ä"]="Ä",
        ["î"]="Î", ["ï"]="Ï", ["ô"]="Ô", ["ö"]="Ö", ["ù"]="Ù", ["û"]="Û", ["ü"]="Ü",
        ["ç"]="Ç", ["œ"]="Œ", ["æ"]="Æ"
    }
    for from, to in pairs(accents) do text = text:gsub(from, to) end
    return text
end


local function setStarRow(owner, prefix, stars)
    stars = math.max(0, math.min(5, math.floor(tonumber(stars) or 0)))
    for i=1,5 do
        local element = owner ~= nil and owner[prefix .. tostring(i)] or nil
        if element ~= nil then
            setResolvedImageFilename(element, i <= stars and "gui/icons/star_filled.dds" or "gui/icons/star_empty.dds")
            if element.setImageColor ~= nil then
                if i <= stars then pcall(element.setImageColor, element, 0.84, 0.92, 0.22, 1) else pcall(element.setImageColor, element, 0.38, 0.46, 0.44, 1) end
            end
        end
    end
end

local function workerStars(employee)
    if employee == nil then return 0 end
    local level = math.max(1, math.min(100, tonumber(employee.careerLevel) or 1))
    local reputation = math.max(0, math.min(100, tonumber(employee.reputation) or 50))
    local normalized = (((level - 1) / 99) * 0.65) + ((reputation / 100) * 0.35)
    return math.max(1, math.min(5, math.floor(1 + normalized * 4 + 0.5)))
end

local function formatMoney(value)
    value = tonumber(value) or 0
    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        return g_i18n:formatMoney(value, 2, true, true)
    end
    return string.format("%.2f", value)
end

local function formatPersonalMoney(value)
    value = tonumber(value) or 0
    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        return g_i18n:formatMoney(value, 2, true, true)
    end
    return string.format("%.2f", value)
end

local function formatPercent(value)
    return string.format("%.2f%%", (tonumber(value) or 0) * 100)
end

local function formatNumber(value, decimals)
    value = tonumber(value) or 0
    decimals = math.max(0, math.floor(tonumber(decimals) or 0))
    if decimals == 0 then
        return string.format("%.0f", value)
    end
    return string.format("%." .. tostring(decimals) .. "f", value)
end

local function formatStars(stars)
    stars = math.max(0, math.min(10, math.floor(tonumber(stars) or 0)))
    return string.format("%d/10", stars)
end

local BANK_MOVEMENT_KEYS = {
    BANK_LOAN="agrilife_bank_movement_loan",
    BANK_LOAN_SETUP_FEE="agrilife_bank_movement_setup_fee",
    BANK_PAYMENT="agrilife_bank_movement_payment",
    BANK_ACCOUNT_FEE="agrilife_bank_movement_account_fee",
    BANK_INCIDENT_FEE="agrilife_bank_movement_incident_fee",
    BANK_EARLY_REPAYMENT="agrilife_bank_movement_early_repay",
    BANK_EARLY_REPAY_FEE="agrilife_bank_movement_early_repay_fee",
    BANK_RESTRUCTURE_FEE="agrilife_bank_movement_restructure_fee"
}

local function getBankMovementLabel(kind)
    local key = BANK_MOVEMENT_KEYS[tostring(kind or "")] or "agrilife_bank_movement_other"
    return g_i18n ~= nil and g_i18n:getText(key) or tostring(kind or "--")
end

local function formatBankMovementDate(movement)
    if movement == nil then return "--" end
    local day = math.floor(tonumber(movement.day) or 0)
    local dayTime = math.max(0, tonumber(movement.dayTime) or 0)
    local totalMinutes = math.floor(dayTime / 60000)
    local hour = math.floor(totalMinutes / 60) % 24
    local minute = totalMinutes % 60
    if day > 0 then return string.format("J%d %02d:%02d", day, hour, minute) end
    return string.format("P%d", math.floor(tonumber(movement.periodKey) or 0))
end

local function formatSignedMoney(value)
    value = tonumber(value) or 0
    local prefix = value > 0.005 and "+" or ""
    return prefix .. formatMoney(value)
end

function AgriLife.HomeFrame.new(core)
    local self = AgriLife.HomeFrame:superClass().new(nil, AgriLife.HomeFrame_mt)
    self.core = core
    self.name = "agriLifeHomeFrame"
    self.activePage = "dashboard"
    self.bankAmountIndex = 2
    self.bankTermIndex = 3
    self.bankAmounts = { 25000, 50000, 100000, 250000, "MAX" }
    self.bankTerms = { 12, 24, 36, 48, 60 }
    self.bankPurposeIndex = 1
    self.bankPurposes = { "cash", "land", "equipment", "building", "production", "refinancing" }
    self.bankRequestPending = false
    self.bankProviderIndex = 1
    self.bankAdvisorIndex = 1
    self.bankProviderBrowsing = false
    self.bankAdvisorBrowsing = false
    self.bankAccountView = "finance"
    self.legalFormIndex = 1
    self.contractOfferIndex = 1
    self.contractOffers = {}
    self.lastBankMessage = nil
    self.lastExamMessage = nil
    self.lastPayrollMessage = nil
    self.lastContractsMessage = nil
    self.examSubview = "self"
    self.careerSubview = "self"
    self.examTeamPage = 1
    self.careerTeamPage = 1
    self.examTeamRows = {}
    self.careerTeamRows = {}
    self.examSelectedProfileId = nil
    self.careerSelectedProfileId = nil
    self.payrollSubview = "self"
    self.payrollTeamPage = 1
    self.payrollTeamRows = {}
    self.payrollSelectedProfileId = nil
    self.onboardingProfileIndex = 1
    self.onboardingModeIndex = 3
    self.insuranceCategoryIndex = 1
    self.insuranceTierIndex = 2
    self.insuranceValueIndex = 2
    self.insurancePolicyIndex = 1
    self.insuranceClaimIndex = 1
    self.insuranceCategories = { "vehicle", "building", "crop", "livestock", "liability", "transport" }
    self.insuranceValues = { 50000, 100000, 250000, 500000, 1000000 }
    self.workshopVehicleIndex = 1
    self.usedOfferIndex = 1
    self.accidentIndex = 1
    self.leaseIndex = 1
    self.companyLedgerIndex = 1
    self.companyAssociateIndex = 1
    self.companyHousingIndex = 1
    self.companyHousingOptions = { {id="farmhouse",label="Maison de ferme",cost=450}, {id="village",label="Logement au village",cost=750}, {id="town",label="Appartement en ville",cost=1050} }
    self.companyPersonalBanks = { {id="credit_agricole_particulier",label="Crédit Agricole Particuliers"}, {id="banque_postale",label="La Banque Postale"}, {id="credit_mutuel",label="Crédit Mutuel"}, {id="caisse_epargne",label="Caisse d'Épargne"} }
    self.companyPrivateVehicleValues = {0, 10000, 25000, 50000}
    self.leaseTermIndex = 4
    self.leaseTerms = {12,24,36,48,60,72,84}
    self.leaseDepositIndex = 2
    self.leaseDeposits = {0.05,0.10,0.15,0.20,0.30,0.40}
    self.lastOnboardingMessage = nil
    self.lastInsuranceMessage = nil
    self.lastWorkshopMessage = nil
    self.enterpriseCandidateIndex = 1
    self.enterpriseVehicleIndex = 1
    self.enterpriseWorkIndex = 1
    self.enterpriseFieldIndex = 1
    self.qualificationIndex = 1
    self.marketViewIndex = 1
    self.marketRowIndex = 1
    self.marketRentalTermIndex = 3
    self.marketRentalTerms = {3, 6, 12, 24, 36}
    self.bankRelationshipTermIndex = 2
    self.bankRelationshipTerms = {12, 36, 60}
    self.lastAdministrationMessage = nil
    self.lastEnterpriseMessage = nil
    self.lastMarketMessage = nil
    self.tutorialPromptShown = false
    self.textTutorialRunning = false
    self.textTutorialPage = 0
    self.textTutorialReview = false
    self.textTutorialMigrationMode = false
    self.textTutorialPendingPage = nil
    self.textTutorialPendingFinish = false
    self.textTutorialPendingDelayMs = 0

    self.btnBack = {
        text = g_i18n:getText("agrilife_core_close"),
        inputAction = InputAction.MENU_BACK
    }
    -- The frame refreshes itself after every AgriLife action.  Keep only the
    -- native Back/Close action in the footer so the bottom bar stays clean.
    self:setMenuButtonInfo({ self.btnBack })
    return self
end


function AgriLife.HomeFrame:resolveModImageAssets()
    local assets = {
        { element = self.navDashboardIcon, path = "gui/ui6icons/dashboard.dds" },
        { element = self.navBankIcon, path = "gui/ui6icons/bank.dds" },
        { element = self.navPayrollIcon, path = "gui/ui6icons/payroll.dds" },
        { element = self.navContractsIcon, path = "gui/ui6icons/contracts.dds" },
        { element = self.navExamsIcon, path = "gui/ui6icons/exam.dds" },
        { element = self.navXpIcon, path = "gui/ui6icons/career.dds" },
        { element = self.navInsuranceIcon, path = "gui/ui6icons/insurance.dds" },
        { element = self.navWorkshopIcon, path = "gui/ui6icons/workshop.dds" },
        { element = self.resolvedModImage01, path = "resources/ui/logo_mark.dds" },
        { element = self.resolvedModImage02, path = "gui/ui6icons/bank.dds" },
        { element = self.resolvedModImage03, path = "gui/ui6icons/exam.dds" },
        { element = self.resolvedModImage04, path = "gui/ui6icons/career.dds" },
        { element = self.resolvedModImage05, path = "gui/ui6icons/insurance.dds" },
        { element = self.resolvedModImage06, path = "resources/ui/logo_mark.dds" },
        { element = self.resolvedModImage07, path = "gui/ui6icons/workshop.dds" },
        { element = self.resolvedModImage08, path = "gui/ui6icons/bank.dds" },
        { element = self.bankProviderSelectorIcon, path = "gui/bankicons/finance.dds", bankPictogram = true },
        { element = self.bankAdvisorSelectorIcon, path = "gui/bankicons/agent.dds", bankPictogram = true },
        { element = self.bankSummaryCashIcon, path = "gui/bankicons/cash.dds", bankPictogram = true },
        { element = self.bankSummaryVanillaDebtIcon, path = "gui/bankicons/loan.dds", bankPictogram = true },
        { element = self.bankSummaryDebtIcon, path = "gui/bankicons/loan_doc.dds", bankPictogram = true },
        { element = self.bankSummaryMonthlyIcon, path = "gui/bankicons/calendar.dds", bankPictogram = true },
        { element = self.bankSummaryScoreIcon, path = "gui/bankicons/credit_score.dds", bankPictogram = true },
        { element = self.bankSummaryCapacityIcon, path = "gui/bankicons/trend_up.dds", bankPictogram = true },
        { element = self.bankSummaryLoansIcon, path = "gui/bankicons/finances.dds", bankPictogram = true },
        { element = self.bankRequestAmountIcon, path = "gui/bankicons/cash.dds", bankPictogram = true },
        { element = self.bankRequestTermIcon, path = "gui/bankicons/calendar.dds", bankPictogram = true },
        { element = self.bankRequestRateIcon, path = "gui/bankicons/percentage.dds", bankPictogram = true },
        { element = self.bankRequestMonthlyIcon, path = "gui/bankicons/finances.dds", bankPictogram = true },
        { element = self.bankRequestInterestIcon, path = "gui/bankicons/percentage.dds", bankPictogram = true },
        { element = self.bankRequestTotalCostIcon, path = "gui/bankicons/cash.dds", bankPictogram = true },
        { element = self.bankRequestFeesIcon, path = "gui/bankicons/finances.dds", bankPictogram = true },
        { element = self.bankRequestAccountFeeIcon, path = "gui/bankicons/finance.dds", bankPictogram = true },
        { element = self.bankRequestPurposeIcon, path = "gui/bankicons/loan_doc.dds", bankPictogram = true },
        { element = self.bankRequestHintIcon, path = "gui/bankicons/timer.dds", bankPictogram = true },
        { element = self.bankStatementTitleIcon, path = "gui/bankicons/finances.dds", bankPictogram = true },
        { element = self.bankAccountTitleIcon, path = "gui/bankicons/finance.dds", bankPictogram = true },
        { element = self.bankAmountPrevIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.bankAmountNextIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.bankTermPrevIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.bankTermNextIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.resolvedModImage09, path = "gui/ui6icons/exam.dds" },
        { element = self.examTeamPrevButtonIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.examTeamNextButtonIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.resolvedModImage10, path = "gui/ui6icons/career.dds" },
        { element = self.careerTeamPrevButtonIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.careerTeamNextButtonIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.resolvedModImage11, path = "gui/ui6icons/payroll.dds" },
        { element = self.payrollSelfPersonIcon, path = "gui/ui6icons/person.dds" },
        { element = self.legalFormPrevButtonIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.legalFormNextButtonIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.payrollTeamPrevButtonIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.payrollTeamNextButtonIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.resolvedModImage12, path = "gui/ui6icons/contracts.dds" },
        { element = self.contractsPrevButtonIcon, path = "gui/icons/arrow_left.dds" },
        { element = self.contractsNextButtonIcon, path = "gui/icons/arrow_right.dds" },
        { element = self.resolvedModImage13, path = "gui/icons/insurance.dds" },
        { element = self.resolvedModImage14, path = "gui/icons/insurance.dds" },
        { element = self.resolvedModImage15, path = "gui/icons/fsk_repair.dds" },
        { element = self.resolvedModImage16, path = "gui/icons/fsk_repair.dds" },
    }
    local resolved = 0
    local bankResolved = 0
    local bankExpected = 0
    for _, asset in ipairs(assets) do
        if asset.bankPictogram == true then
            bankExpected = bankExpected + 1
        end
        if asset.element ~= nil then
            setResolvedImageFilename(asset.element, asset.path)
            resolved = resolved + 1
            if asset.bankPictogram == true then
                bankResolved = bankResolved + 1
            end
        end
    end
    if not self.modImagesResolved then
        self.modImagesResolved = true
        AgriLife.Logger.info("UI", "Resolved %d/%d AgriLife GUI image assets with absolute mod paths", resolved, #assets)
        AgriLife.Logger.info("UI", "Bank pictograms resolved %d/%d with absolute paths", bankResolved, bankExpected)
        if bankResolved ~= bankExpected then
            AgriLife.Logger.warning("UI", "Bank pictogram binding incomplete: %d/%d", bankResolved, bankExpected)
        end
    end
end

function AgriLife.HomeFrame:onGuiSetupFinished()
    AgriLife.HomeFrame:superClass().onGuiSetupFinished(self)
    self:resolveModImageAssets()
    self:showPage(self.activePage)
    self:refresh()
end

function AgriLife.HomeFrame:onFrameOpen()
    AgriLife.HomeFrame:superClass().onFrameOpen(self)
    self:resolveModImageAssets()
    self:showPage(self.activePage)
    self:refresh()
    self:promptTutorialChoice()
end

function AgriLife.HomeFrame:getBankModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.bank
end

function AgriLife.HomeFrame:getCompanyModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.company
end

function AgriLife.HomeFrame:getPeopleModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.people
end

function AgriLife.HomeFrame:canManage(permission)
    local people = self:getPeopleModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    return people ~= nil and people.canLocal ~= nil and people:canLocal(farmId, permission) == true
end

function AgriLife.HomeFrame:refreshAccessMode()
    local people = self:getPeopleModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local canManage = self:canManage("company.manage")
    local accessText = g_i18n:getText(canManage and "agrilife_people6_access_management" or "agrilife_people6_access_readonly")
    local economy = self:getEconomyModule()
    local difficulty = economy ~= nil and economy.getSnapshot ~= nil and economy:getSnapshot(farmId) or nil
    local modeText = "--"
    if difficulty ~= nil and difficulty.modeChosen == true then
        modeText = self:getLocalizedModeName(difficulty.modeId, difficulty.modeName)
    end
    local modePrefix = g_i18n:getText("agrilife_onboarding_mode_prefix") or "MODE : "
    setText(self.headerAccessMode, tostring(modePrefix) .. upperDisplay(modeText) .. "  |  " .. upperDisplay(accessText))
    if self.headerAccessMode ~= nil then
        if canManage then setTextColor(self.headerAccessMode, 0.67, 0.91, 0.45, 1) else setTextColor(self.headerAccessMode, 0.68, 0.77, 0.80, 1) end
    end
    if people ~= nil and people.requestSnapshot ~= nil and self.core ~= nil and self.core.context ~= nil and not self.core.context.isServer and farmId > 0 then
        local now = tonumber(g_time) or 0
        if self.lastPeopleSnapshotRequest == nil or now - self.lastPeopleSnapshotRequest > 5000 then
            self.lastPeopleSnapshotRequest = now
            people:requestSnapshot(farmId)
        end
    end
end

function AgriLife.HomeFrame:getPayrollModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.payroll
end

function AgriLife.HomeFrame:getContractsModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.commercialContracts
end

function AgriLife.HomeFrame:getExamModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.exams
end

function AgriLife.HomeFrame:getCareerModule()
    if self.core == nil or self.core.registry == nil or self.core.registry.instances == nil then return nil end
    return self.core.registry.instances.career
end

function AgriLife.HomeFrame:getEconomyModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.economy or nil
end

function AgriLife.HomeFrame:getIntegrityModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.integrity or nil
end

function AgriLife.HomeFrame:getInsuranceModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.insurance or nil
end

function AgriLife.HomeFrame:getWorkshopModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.workshop or nil
end

function AgriLife.HomeFrame:getAssetsModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.assets or nil
end

function AgriLife.HomeFrame:getLegalModule()
    return self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.legal or nil
end

function AgriLife.HomeFrame:isPageAvailableForDifficulty(pageId,snapshot)
    if pageId=="dashboard" then return true end
    local policy=snapshot~=nil and snapshot.modePolicy or nil
    local access=policy~=nil and policy.moduleAccess or nil
    if type(access)~="table" then return true end
    return access[pageId]==true
end

function AgriLife.HomeFrame:updateNavigationStyle(pageId)
    -- UI 0.6.4.8: navigation sobre et cohérente.
    -- Une seule identité visuelle AgriLife : vert pour l'état actif / accent,
    -- pictogrammes neutres pour les entrées inactives.
    local agriGreen = {0.63, 0.86, 0.08}
    local items = {
        { id = "dashboard", bg = self.navDashboardBg, accent = self.navDashboardAccent, icon = self.navDashboardIcon, label = self.navDashboardLabel },
        { id = "company", bg = self.navCompanyBg, accent = self.navCompanyAccent, icon = self.navCompanyIcon, label = self.navCompanyLabel },
        { id = "bank", bg = self.navBankBg, accent = self.navBankAccent, icon = self.navBankIcon, label = self.navBankLabel },
        { id = "payroll", bg = self.navPayrollBg, accent = self.navPayrollAccent, icon = self.navPayrollIcon, label = self.navPayrollLabel },
        { id = "contracts", bg = self.navContractsBg, accent = self.navContractsAccent, icon = self.navContractsIcon, label = self.navContractsLabel },
        { id = "exams", bg = self.navExamsBg, accent = self.navExamsAccent, icon = self.navExamsIcon, label = self.navExamsLabel },
        { id = "xp", bg = self.navXpBg, accent = self.navXpAccent, icon = self.navXpIcon, label = self.navXpLabel },
        { id = "insurance", bg = self.navInsuranceBg, accent = self.navInsuranceAccent, icon = self.navInsuranceIcon, label = self.navInsuranceLabel },
        { id = "workshop", bg = self.navWorkshopBg, accent = self.navWorkshopAccent, icon = self.navWorkshopIcon, label = self.navWorkshopLabel },
        { id = "accidents", bg = self.navAccidentsBg, accent = self.navAccidentsAccent, icon = self.navAccidentsIcon, label = self.navAccidentsLabel },
        { id = "leasing", bg = self.navLeasingBg, accent = self.navLeasingAccent, icon = self.navLeasingIcon, label = self.navLeasingLabel },
        { id = "used", bg = self.navUsedBg, accent = self.navUsedAccent, icon = self.navUsedIcon, label = self.navUsedLabel }
    }

    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    local economy=self:getEconomyModule();local difficultySnapshot=economy~=nil and economy:getSnapshot(farmId) or nil
    for _, item in ipairs(items) do
        local active = item.id == pageId
        local available=self:isPageAvailableForDifficulty(item.id,difficultySnapshot)
        local reachable=true
        if difficultySnapshot~=nil and item.id~="dashboard" then
            local policy=difficultySnapshot.modePolicy or {}
            local access=policy.moduleAccess or {}
            local foundationReady=difficultySnapshot.modeChosen==true
            local companyPending=difficultySnapshot.setupCompleted~=true or (policy.companyRequired==true and difficultySnapshot.statutesAccepted~=true)
            if item.id=="company" then reachable=foundationReady and access.company==true
            elseif item.id=="bank" then reachable=foundationReady and access.bank==true
            elseif item.id=="exams" then reachable=foundationReady and not companyPending and access.exams==true
            else reachable=difficultySnapshot.ready==true and access[item.id]==true end
        end
        if not available or not reachable then
            setImageColor(item.bg,0.032,0.041,0.045,1)
            setImageColor(item.accent,0.20,0.24,0.22,1)
            setImageColor(item.icon,0.34,0.38,0.37,1)
            setTextColor(item.label,0.42,0.46,0.45,1)
        elseif active then
            setImageColor(item.bg, 0.31, 0.45, 0.10, 1)
            setImageColor(item.accent, agriGreen[1], agriGreen[2], agriGreen[3], 1)
            setImageColor(item.icon, 0.98, 1.00, 0.94, 1)
            setTextColor(item.label, 0.98, 1.00, 0.96, 1)
        else
            setImageColor(item.bg, 0.045, 0.061, 0.066, 1)
            setImageColor(item.accent, 0.34, 0.46, 0.12, 1)
            setImageColor(item.icon, 0.82, 0.87, 0.85, 1)
            setTextColor(item.label, 0.82, 0.87, 0.85, 1)
        end
    end
end

function AgriLife.HomeFrame:showPage(pageId)
    local allowed = { dashboard = true, company = true, bank = true, payroll = true, contracts = true, exams = true, xp = true, insurance = true, workshop = true, accidents = true, leasing = true, used = true }
    if not allowed[pageId] then pageId = "dashboard" end
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    local economy=self:getEconomyModule()
    local onboarding=economy~=nil and economy:getSnapshot(farmId) or nil
    if onboarding~=nil and onboarding.modeChosen==true and not self:isPageAvailableForDifficulty(pageId,onboarding) then
        self.lastOnboardingMessage=string.format(g_i18n:getText("agrilife_difficulty_module_locked"),self:getLocalizedModeName(onboarding.modeId,onboarding.modeName))
        pageId="dashboard"
    end
    if onboarding~=nil then
        local policy=onboarding.modePolicy or {}
        local companyPending=onboarding.setupCompleted~=true or (policy.companyRequired==true and onboarding.statutesAccepted~=true)
        if onboarding.modeChosen~=true and pageId~="dashboard" then
            pageId="dashboard"
            self.lastOnboardingMessage=g_i18n:getText("agrilife_onboarding_mode_first_msg")
        elseif onboarding.tutorialChoiceMade~=true and pageId~="dashboard" then
            pageId="dashboard"
            self.lastOnboardingMessage=g_i18n:getText("agrilife_onboarding_choice_required_msg")
        elseif policy.bankRequired==true and onboarding.bankSelected~=true and pageId~="dashboard" and pageId~="bank" then
            pageId="bank"
            self.lastOnboardingMessage=g_i18n:getText("agrilife_onboarding_bank_required")
        elseif companyPending and pageId~="dashboard" and pageId~="bank" and pageId~="company" then
            pageId="dashboard"
            self.lastOnboardingMessage=policy.companyRequired==true and g_i18n:getText("agrilife_onboarding_company_required") or g_i18n:getText("agrilife_onboarding_setup_required")
        elseif policy.licenceRequired==true and onboarding.licenceObtained~=true and pageId~="dashboard" and pageId~="bank" and pageId~="company" and pageId~="exams" then
            pageId="exams"
            self.lastOnboardingMessage=g_i18n:getText("agrilife_onboarding_licence_required")
        end
    end
    self.activePage = pageId
    setVisible(self.dashboardPage, pageId == "dashboard")
    setVisible(self.companyPage, pageId == "company")
    setVisible(self.bankPage, pageId == "bank")
    setVisible(self.payrollPage, pageId == "payroll")
    setVisible(self.contractsPage, pageId == "contracts")
    setVisible(self.examPage, pageId == "exams")
    setVisible(self.xpPage, pageId == "xp")
    setVisible(self.insurancePage, pageId == "insurance")
    setVisible(self.workshopPage, pageId == "workshop")
    setVisible(self.accidentsPage, pageId == "accidents")
    setVisible(self.leasingPage, pageId == "leasing")
    setVisible(self.usedPage, pageId == "used")
    self:updateNavigationStyle(pageId)
    if pageId == "exams" then
        local own = self.examSubview ~= "team"
        setVisible(self.examSelfSummaryPanel, own); setVisible(self.examSelfTaskPanel, own); setVisible(self.examSelfStatusPanel, own); setVisible(self.examTeamPanel, not own)
        setDisabled(self.examSelfTabButton, own); setDisabled(self.examTeamTabButton, not own)
    elseif pageId == "xp" then
        local own = self.careerSubview ~= "team"
        setVisible(self.careerSelfSummaryPanel, own); setVisible(self.careerSelfStatsPanel, own); setVisible(self.careerSelfSpecialtiesPanel, own); setVisible(self.xpStatusText, own); setVisible(self.careerTeamPanel, not own)
        setDisabled(self.careerSelfTabButton, own); setDisabled(self.careerTeamTabButton, not own)
    elseif pageId == "payroll" then
        local own = self.payrollSubview ~= "team"
        setVisible(self.payrollSelfPanel, own); setVisible(self.payrollTeamPanel, not own)
        setDisabled(self.payrollSelfTabButton, own); setDisabled(self.payrollTeamTabButton, (not own) or not self:canManage("payroll.manage"))
    end
    self:refresh()
end

function AgriLife.HomeFrame:onClickDashboard()
    self:showPage("dashboard")
end

function AgriLife.HomeFrame:onClickCompany()
    self:showPage("company")
end

function AgriLife.HomeFrame:onClickBank()
    local hours = AgriLife.OperationalHours93
    if hours ~= nil and not hours:isOpen("BANK") then hours:showClosedInfo("BANK"); return end
    self:showPage("bank")
end

function AgriLife.HomeFrame:onClickPayroll()
    self:showPage("payroll")
end

function AgriLife.HomeFrame:onClickContracts()
    self:showPage("contracts")
end

function AgriLife.HomeFrame:onClickExams()
    self:showPage("exams")
end

function AgriLife.HomeFrame:onClickXp()
    self:showPage("xp")
end

function AgriLife.HomeFrame:onClickCareerQualificationsCareer()
    self:showPage("xp")
end

function AgriLife.HomeFrame:onClickCareerQualificationsExam()
    self:showPage("exams")
end

function AgriLife.HomeFrame:onClickInsurance()
    self:showPage("insurance")
end

function AgriLife.HomeFrame:onClickWorkshop()
    self:showPage("workshop")
end

function AgriLife.HomeFrame:onClickAccidents() self:showPage("accidents") end
function AgriLife.HomeFrame:onClickLeasing()
    local hours=AgriLife.OperationalHours93;if hours~=nil and not hours:isOpen("DEALER") then hours:showClosedInfo("DEALER");return end
    self:showPage("leasing")
end
function AgriLife.HomeFrame:onClickUsed()
    local hours=AgriLife.OperationalHours93;if hours~=nil and not hours:isOpen("DEALER") then hours:showClosedInfo("DEALER");return end
    self:showPage("used")
end

function AgriLife.HomeFrame:getBankProviderSelection()
    local bank = self:getBankModule()
    if bank == nil or bank.getProviders == nil then return nil, nil end
    local order, providers = bank:getProviders()
    if type(order) ~= "table" or #order == 0 then return nil, nil end
    self.bankProviderIndex = math.max(1, math.min(#order, tonumber(self.bankProviderIndex) or 1))
    local id = order[self.bankProviderIndex]
    return id, providers ~= nil and providers[id] or nil
end

function AgriLife.HomeFrame:syncBankProviderIndex(snapshot)
    local bank = self:getBankModule()
    if bank == nil or bank.getProviders == nil or snapshot == nil then return end
    local order = bank:getProviders()
    for i, id in ipairs(order or {}) do if id == snapshot.providerId then self.bankProviderIndex = i; return end end
end

function AgriLife.HomeFrame:syncBankAdvisorIndex(snapshot)
    local bank=self:getBankModule();if bank==nil or bank.getAdvisors==nil or snapshot==nil then return end
    local order=bank:getAdvisors()
    if snapshot.advisorSelected==true then
        for index,id in ipairs(order or{})do if id==snapshot.advisorId then self.bankAdvisorIndex=index;return end end
    end
    -- Before the first appointment, always point at the first advisor the current
    -- bank/farm can actually use. This avoids presenting a locked advisor as the
    -- default confirmation target.
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    for index,id in ipairs(order or{})do
        local access=bank.getAdvisorAccess~=nil and bank:getAdvisorAccess(farmId,id)or nil
        if access==nil or access.unlocked==true then self.bankAdvisorIndex=index;return end
    end
    self.bankAdvisorIndex=1
end

function AgriLife.HomeFrame:cycleBankProvider(direction)
    local bank=self:getBankModule()
    if bank==nil or bank.getProviders==nil then return end
    local order=bank:getProviders(); if type(order)~="table" or #order==0 then return end
    self.bankProviderIndex=((tonumber(self.bankProviderIndex)or 1)-1+(tonumber(direction)or 1))%#order+1
    self.bankProviderBrowsing=true
    self.lastBankMessage=g_i18n:getText("agrilife_bank6_click_to_confirm_provider")
    self:refreshBank()
end
function AgriLife.HomeFrame:onClickBankProviderPrev() self:cycleBankProvider(-1) end
function AgriLife.HomeFrame:onClickBankProviderNext() self:cycleBankProvider(1) end
function AgriLife.HomeFrame:onClickBankProviderCurrent()
    local bank=self:getBankModule(); if bank==nil or not self:canManage("bank.manage") then return end
    local order=bank:getProviders(); if type(order)~="table" or #order==0 then return end
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    local id=order[math.max(1,math.min(#order,tonumber(self.bankProviderIndex)or 1))]
    local result=bank:setProvider(farmId,id)
    self.lastBankMessage=result~=nil and (result.ok and g_i18n:getText("agrilife_bank6_provider_changed") or self:getBankResultText(result.code,result.details)) or g_i18n:getText("agrilife_bank6_provider_change_failed")
    self.bankProviderBrowsing=false; self.bankAdvisorBrowsing=false
    self:refresh()
end
function AgriLife.HomeFrame:onBankProviderResult(result)
    self.lastBankMessage=result~=nil and result.success and g_i18n:getText("agrilife_bank6_click_to_confirm_advisor") or self:getBankResultText(result~=nil and result.code or "BANK_PROVIDER_CHANGE_FAILED",result~=nil and result.details or nil)
    self.bankProviderBrowsing=false; self.bankAdvisorBrowsing=false; self:refreshBank()
end

function AgriLife.HomeFrame:cycleBankAdvisor(direction)
    local bank=self:getBankModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    if bank==nil then return end
    local snapshot=bank:getSnapshot(farmId); if snapshot==nil or snapshot.providerSelected~=true then self.lastBankMessage=g_i18n:getText("agrilife_bank_choose_provider_first"); self:refreshBank(); return end
    local order=bank:getAdvisors(); if type(order)~="table" or #order==0 then return end
    self.bankAdvisorIndex=((tonumber(self.bankAdvisorIndex)or 1)-1+(tonumber(direction)or 1))%#order+1
    self.bankAdvisorBrowsing=true
    self.lastBankMessage=g_i18n:getText("agrilife_bank6_click_to_confirm_advisor")
    self:refreshBank()
end
function AgriLife.HomeFrame:onClickBankAdvisorPrev() self:cycleBankAdvisor(-1) end
function AgriLife.HomeFrame:onClickBankAdvisorNext() self:cycleBankAdvisor(1) end
function AgriLife.HomeFrame:onClickBankAdvisor()
    local bank=self:getBankModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    if bank==nil or not self:canManage("bank.manage")then return end
    local snapshot=bank:getSnapshot(farmId);if snapshot==nil or snapshot.providerSelected~=true then self.lastBankMessage=g_i18n:getText("agrilife_bank_choose_provider_first");self:refreshBank();return end
    local order=bank:getAdvisors();if type(order)~="table"or#order==0 then return end
    local id=order[math.max(1,math.min(#order,tonumber(self.bankAdvisorIndex)or 1))]
    local result=bank:setAdvisor(farmId,id)
    self.lastBankMessage=result~=nil and (result.ok and g_i18n:getText("agrilife_bank6_advisor_changed") or self:getBankResultText(result.code,result.details)) or g_i18n:getText("agrilife_bank6_advisor_unavailable")
    self.bankAdvisorBrowsing=false; self:refresh()
end

function AgriLife.HomeFrame:onClickBankProAccount() self.bankAccountView="finance"; self:refreshBank() end
function AgriLife.HomeFrame:onClickBankPersonalAccount() self.bankAccountView="statement"; self:refreshBank() end

function AgriLife.HomeFrame:getSelectedBankAmount(snapshot)
    local selected = self.bankAmounts[self.bankAmountIndex] or 50000
    if selected == "MAX" then
        return math.floor(math.max(0, tonumber(snapshot ~= nil and snapshot.capacity) or 0) / 1000) * 1000
    end
    return selected
end

function AgriLife.HomeFrame:getSelectedBankTerm()
    return self.bankTerms[self.bankTermIndex] or 36
end

function AgriLife.HomeFrame:getSelectedBankPurpose()
    return self.bankPurposes[self.bankPurposeIndex] or "cash"
end

function AgriLife.HomeFrame:onClickBankPurpose()
    self.bankPurposeIndex=(self.bankPurposeIndex%#self.bankPurposes)+1;self.lastBankMessage=nil;self:refreshBank()
end

function AgriLife.HomeFrame:cycleBankAmount(direction)
    local count = #self.bankAmounts
    self.bankAmountIndex = ((self.bankAmountIndex - 1 + direction) % count) + 1
    self.lastBankMessage = nil
    self:refreshBank()
end

function AgriLife.HomeFrame:cycleBankTerm(direction)
    local count = #self.bankTerms
    self.bankTermIndex = ((self.bankTermIndex - 1 + direction) % count) + 1
    self.lastBankMessage = nil
    self:refreshBank()
end

function AgriLife.HomeFrame:onClickBankAmountPrev() self:cycleBankAmount(-1) end
function AgriLife.HomeFrame:onClickBankAmountNext() self:cycleBankAmount(1) end
function AgriLife.HomeFrame:onClickBankTermPrev() self:cycleBankTerm(-1) end
function AgriLife.HomeFrame:onClickBankTermNext() self:cycleBankTerm(1) end

function AgriLife.HomeFrame:onClickBankRequest()
    if self.bankRequestPending then return end
    local bank = self:getBankModule()
    if not self:canManage("bank.manage") then
        self.lastBankMessage = g_i18n:getText("agrilife_people6_readonly_bank")
        self:refreshBank()
        return
    end
    if bank == nil then
        self.lastBankMessage = g_i18n:getText("agrilife_bank6_unavailable")
        self:refreshBank()
        return
    end

    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local snapshot = bank:getSnapshot(farmId)
    local amount = self:getSelectedBankAmount(snapshot)
    local termMonths = self:getSelectedBankTerm()
    local purpose=self:getSelectedBankPurpose()
    local preview = bank:previewLoan(farmId, amount, termMonths, purpose)
    if preview ~= nil and preview.ok and preview.details ~= nil then
        setText(self.bankSetupFeeValue, formatMoney(preview.details.setupFee or 0))
        setText(self.bankMonthlyFeePreviewValue, formatMoney(preview.details.monthlyAccountFee or snapshot.monthlyAccountFee or 0))
    else
        setText(self.bankSetupFeeValue, "--")
        setText(self.bankMonthlyFeePreviewValue, snapshot.providerSelected==true and formatMoney(snapshot.monthlyAccountFee or 0) or "--")
    end
    if preview == nil or not preview.ok then
        self.lastBankMessage = self:getBankResultText(preview ~= nil and preview.code or "BANK_UNKNOWN")
        self:refreshBank()
        return
    end

    self.bankRequestPending = true
    self.lastBankMessage = g_i18n:getText("agrilife_bank6_request_pending")
    setDisabled(self.bankRequestButton, true)
    local result = bank:requestLoan(farmId, amount, termMonths, purpose)
    if result ~= nil and not result.ok then
        self.bankRequestPending = false
        self.lastBankMessage = self:getBankResultText(result.code)
    end
    self:refreshBank()
end

function AgriLife.HomeFrame:getBankResultText(code, details)
    details=details or {}
    if code=="BANK_MODE_REQUIRED" then return g_i18n:getText("agrilife_onboarding_mode_first_msg") end
    if code=="BANK_PROVIDER_REQUIRED" then return g_i18n:getText("agrilife_bank6_need_provider") end
    if code=="BANK_ADVISOR_REQUIRED" then return g_i18n:getText("agrilife_bank6_need_advisor") end
    if code=="BANK_ONBOARDING_REQUIRED" then return g_i18n:getText("agrilife_onboarding_licence_required") end
    if code=="BANK_PROVIDER_REPUTATION_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_reputation"),tonumber(details.requiredReputation)or 0,tonumber(details.reputation)or 0) end
    if code=="BANK_PROVIDER_SCORE_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_score"),tonumber(details.requiredScore or details.minimumScore)or 0,tonumber(details.score)or 0) end
    if code=="BANK_PROVIDER_RELATIONSHIP_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_relationship"),tonumber(details.requiredRelationship)or 0,tonumber(details.relationship)or 0) end
    if code=="BANK_ADVISOR_PROVIDER_TIER_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_provider_tier"),tonumber(details.requiredProviderTier)or 1) end
    if code=="BANK_ADVISOR_REPUTATION_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_advisor_reputation"),tonumber(details.requiredReputation)or 0,tonumber(details.reputation)or 0) end
    if code=="BANK_ADVISOR_SCORE_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_advisor_score"),tonumber(details.requiredScore)or 0,tonumber(details.score)or 0) end
    if code=="BANK_ADVISOR_RELATIONSHIP_TOO_LOW" then return string.format(g_i18n:getText("agrilife_bank6_lock_advisor_relationship"),tonumber(details.requiredRelationship)or 0,tonumber(details.relationship)or 0) end
    if code=="BANK_TERM_DIFFICULTY_LIMIT" then return string.format(g_i18n:getText("agrilife_bank6_term_difficulty_limit"),tonumber(details.maximumTerm)or 0) end
    if code=="BANK_GUARANTEE_INSUFFICIENT" then return string.format(g_i18n:getText("agrilife_bank6_guarantee_insufficient"),formatMoney(details.requiredContribution or 0),formatMoney(details.availableCash or 0)) end
    if code=="BANK_PROVIDER_ACTIVE_RELATION_LOCK" then return g_i18n:getText("agrilife_bank6_provider_active_relation_lock") end
    local keys = {
        BANK_LOAN_APPROVED = "agrilife_bank6_result_approved",
        BANK_APPLICATION_SUBMITTED = "agrilife_bank6_application_submitted",
        BANK_APPLICATION_ALREADY_PENDING = "agrilife_bank6_application_pending",
        BANK_APPLICATION_PENDING_LOCK = "agrilife_bank6_application_pending_lock",
        BANK_APPLICATION_REJECTED = "agrilife_bank6_application_rejected",
        BANK_CAPACITY_EXCEEDED = "agrilife_bank6_result_capacity",
        BANK_AMOUNT_INVALID = "agrilife_bank6_result_amount",
        BANK_TERM_INVALID = "agrilife_bank6_result_term",
        BANK_UNAUTHORIZED = "agrilife_bank6_result_unauthorized",
        BANK_DUPLICATE_REQUEST = "agrilife_bank6_result_duplicate",
        BANK_CREDIT_FAILED = "agrilife_bank6_result_creditFailed",
        BANK_SERVER_REQUIRED = "agrilife_bank6_result_server",
        BANK_NETWORK_UNAVAILABLE = "agrilife_bank6_result_network"
    }
    return g_i18n:getText(keys[code] or "agrilife_bank6_result_failed")
end


function AgriLife.HomeFrame:getBankDecisionReasonText(reasonCode)
    local keys={
        legal="agrilife_bank6_decision_reason_legal",
        capacity="agrilife_bank6_decision_reason_capacity",
        score="agrilife_bank6_decision_reason_score",
        reputation="agrilife_bank6_decision_reason_reputation",
        relationship="agrilife_bank6_decision_reason_relationship",
        purpose="agrilife_bank6_decision_reason_purpose",
        strong="agrilife_bank6_decision_reason_strong",
        balanced="agrilife_bank6_decision_reason_balanced",
        overall="agrilife_bank6_decision_reason_overall"
    }
    return g_i18n:getText(keys[tostring(reasonCode or "")] or "agrilife_bank6_decision_reason_overall")
end

function AgriLife.HomeFrame:getTextTutorialPages()
    local pages = {}
    if self.textTutorialMigrationMode == true then
        for i=1,4 do
            pages[i] = g_i18n:getText(string.format("agrilife_migration_page_%d", i))
        end
        return pages
    end
    for i=1,8 do
        pages[i] = g_i18n:getText(string.format("agrilife_tutorial_page_%d", i))
    end
    return pages
end
function AgriLife.HomeFrame:showTextTutorialPage()
    if self.textTutorialRunning ~= true then return end
    local pages = self:getTextTutorialPages()
    local pageIndex = math.max(1, math.min(#pages, tonumber(self.textTutorialPage) or 1))
    local text = pages[pageIndex]
    AgriLife.Logger.info("Tutorial", "Showing text guide page %d/%d", pageIndex, #pages)

    if self.textTutorialUsingPagedDialog ~= true and self.core ~= nil and self.core.ui ~= nil and self.core.ui.showTutorialDialog ~= nil then
        local pagedCallback = function()
            if self == nil then return end
            self.textTutorialUsingPagedDialog = false
            self.textTutorialRunning = false
            self.textTutorialPage = 0
            self.textTutorialPendingPage = nil
            self.textTutorialPendingFinish = false
            self.textTutorialPendingDelayMs = 0
            AgriLife.Logger.info("Tutorial", "Paged text guide closed; opening final tutorial choice")
            self:finishTextTutorial()
        end
        local ok, shown = pcall(self.core.ui.showTutorialDialog, self.core.ui, pages, pagedCallback)
        if ok and shown == true then
            self.textTutorialUsingPagedDialog = true
            return
        end
        self.textTutorialUsingPagedDialog = false
        AgriLife.Logger.warning("Tutorial", "Paged tutorial unavailable; falling back to InfoDialog sequence")
    end

    local callback = function()
        if self == nil then return end

        -- FS25 reuses one singleton InfoDialog. Reopening that same dialog
        -- directly from its close callback works once, then the engine's
        -- cleanup of the previous dialog can wipe the new callback. That is
        -- exactly why 0.6.4.2 reached page 2/8 and stopped. Queue the next
        -- page and open it from the following UI updates after the previous
        -- dialog has fully closed.
        if pageIndex < #pages then
            self.textTutorialPendingPage = pageIndex + 1
            self.textTutorialPendingFinish = false
        else
            self.textTutorialPendingPage = nil
            self.textTutorialPendingFinish = true
        end
        self.textTutorialPendingDelayMs = 250
        AgriLife.Logger.info("Tutorial", "Text guide page %d acknowledged; next step queued", pageIndex)
    end

    if InfoDialog ~= nil and InfoDialog.show ~= nil then
        InfoDialog.show(text, callback, nil)
        return
    end
    if g_gui ~= nil and g_gui.showInfoDialog ~= nil then
        g_gui:showInfoDialog({text=text, callback=callback, target=nil, okText=pageIndex < #pages and g_i18n:getText("agrilife_tutorial_next") or g_i18n:getText("agrilife_tutorial_finish")})
        return
    end

    self.textTutorialRunning = false
    self.textTutorialPage = 0
    AgriLife.Logger.warning("Tutorial", "FS25 InfoDialog API unavailable; text guide could not be displayed")
    if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(g_i18n:getText("agrilife_tutorial_reopen_warning"), 8000)
    end
end

function AgriLife.HomeFrame:updateTextTutorial(dt)
    if self.textTutorialRunning ~= true then return end
    if self.textTutorialPendingPage == nil and self.textTutorialPendingFinish ~= true then return end

    self.textTutorialPendingDelayMs = math.max(0, (tonumber(self.textTutorialPendingDelayMs) or 0) - (tonumber(dt) or 0))
    if self.textTutorialPendingDelayMs > 0 then return end

    if self.textTutorialPendingPage ~= nil then
        local nextPage = tonumber(self.textTutorialPendingPage) or 1
        self.textTutorialPendingPage = nil
        self.textTutorialPage = nextPage
        AgriLife.Logger.info("Tutorial", "Opening queued text guide page %d", nextPage)
        self:showTextTutorialPage()
        return
    end

    if self.textTutorialPendingFinish == true then
        self.textTutorialPendingFinish = false
        self.textTutorialRunning = false
        self.textTutorialPage = 0
        AgriLife.Logger.info("Tutorial", "All text guide pages acknowledged; opening final tutorial choice")
        self:finishTextTutorial()
    end
end

function AgriLife.HomeFrame:startTextTutorial(forceReview)
    if self.textTutorialRunning == true then return end
    local economy = self:getEconomyModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    if tonumber(farmId) == nil or tonumber(farmId) <= 0 then return end
    local snapshot = economy ~= nil and economy:getSnapshot(farmId) or nil
    if snapshot == nil then return end

    if forceReview ~= true and snapshot.tutorialChoiceMade == true then
        self.tutorialPromptShown = true
        return
    end

    self.tutorialPromptShown = true
    self.textTutorialRunning = true
    self.textTutorialPage = 1
    self.textTutorialPendingPage = nil
    self.textTutorialPendingFinish = false
    self.textTutorialPendingDelayMs = 0
    self.textTutorialReview = forceReview == true or snapshot.tutorialChoiceMade == true
    self.textTutorialMigrationMode = forceReview ~= true and snapshot.existingCareerDetected == true and snapshot.existingCareerAcknowledged ~= true
    AgriLife.Logger.info("Tutorial", "Text guide started (farm=%s review=%s migration=%s)", tostring(farmId), tostring(self.textTutorialReview), tostring(self.textTutorialMigrationMode))
    self:showTextTutorialPage()
end

function AgriLife.HomeFrame:finishTextTutorial()
    local economy = self:getEconomyModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local snapshot = economy ~= nil and economy:getSnapshot(farmId) or nil

    if self.textTutorialReview == true or (snapshot ~= nil and snapshot.tutorialChoiceMade == true) then
        self.textTutorialReview = false
        self.textTutorialMigrationMode = false
        self.lastOnboardingMessage = g_i18n:getText("agrilife_tutorial_review_done")
        AgriLife.Logger.info("Tutorial", "Text guide review completed")
        self:refreshDashboard()
        return
    end

    self.textTutorialReview = false
    self.textTutorialMigrationMode = false
    local question = g_i18n:getText("agrilife_tutorial_final_question")
    local callback = function(confirmed)
        self:onTutorialChoice(confirmed == true)
    end

    if YesNoDialog ~= nil and YesNoDialog.show ~= nil then
        YesNoDialog.show(callback, nil, question)
    elseif g_gui ~= nil and g_gui.showYesNoDialog ~= nil then
        g_gui:showYesNoDialog({text=question, title="AGRILIFE MANAGER", callback=callback, target=nil, yesText=g_i18n:getText("agrilife_core_yes"), noText=g_i18n:getText("agrilife_core_no")})
    else
        -- Never leave a new career blocked just because a dialog class is not
        -- exposed by a future FS25 build. Default to the guided path.
        AgriLife.Logger.warning("Tutorial", "YesNoDialog API unavailable; guided onboarding enabled by fallback")
        self:onTutorialChoice(true)
    end
end

function AgriLife.HomeFrame:onTutorialChoice(enabled)
    local economy=self:getEconomyModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    local result=economy~=nil and economy:setTutorialPreference(farmId,enabled==true)or nil
    self.lastOnboardingMessage=enabled==true and g_i18n:getText("agrilife_tutorial_enabled_msg") or g_i18n:getText("agrilife_tutorial_disabled_msg")
    self.tutorialPromptShown=true
    self.textTutorialRunning=false
    self.textTutorialPage=0
    self.textTutorialPendingPage=nil
    self.textTutorialPendingFinish=false
    self.textTutorialPendingDelayMs=0
    self.textTutorialUsingPagedDialog=false
    if result~=nil and result.ok and enabled==true then self.activePage="dashboard" end
    AgriLife.Logger.info("Tutorial", "Guided onboarding preference saved (enabled=%s)", tostring(enabled==true))
    self:showPage("dashboard")
end

function AgriLife.HomeFrame:promptTutorialChoice()
    if self.tutorialPromptShown then return end
    if self.core~=nil and self.core.ui~=nil and self.core.ui.isGameplayReadyForTutorialPrompt~=nil and not self.core.ui:isGameplayReadyForTutorialPrompt() then return end
    local economy=self:getEconomyModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0
    if tonumber(farmId)==nil or tonumber(farmId)<=0 then return end
    local snapshot=economy~=nil and economy:getSnapshot(farmId)or nil
    if snapshot==nil then return end
    if snapshot.tutorialChoiceMade==true then self.tutorialPromptShown=true;return end
    self:startTextTutorial(false)
end

function AgriLife.HomeFrame:onClickTutorialGuide()
    self:startTextTutorial(true)
end

function AgriLife.HomeFrame:onClickTutorialStop()
    self:onTutorialChoice(false)
end

function AgriLife.HomeFrame:onClickTutorialAction()
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local snapshot=economy~=nil and economy:getSnapshot(farmId)or nil;local step=snapshot~=nil and snapshot.tutorialStep or"inactive"
    if step=="mode" then
        local result=economy~=nil and economy:confirmMode(farmId) or nil;self.lastOnboardingMessage=result~=nil and result.message or nil;self:refreshDashboard()
    elseif step=="migration" then
        local result=economy~=nil and economy:acknowledgeExistingCareer(farmId) or nil;self.lastOnboardingMessage=result~=nil and result.message or nil;self:refreshDashboard()
    elseif step=="bank"or step=="advisor"then self:showPage("bank")
    elseif step=="company"then self:onClickOnboardingActivate()
    elseif step=="exam"then self:showPage("exams")
    elseif step=="finish"then local result=economy:completeTutorial(farmId);self.lastOnboardingMessage=result~=nil and result.message or nil;self:refreshDashboard()
    end
end

function AgriLife.HomeFrame:refreshTutorialOverlay(farmId,snapshot)
    snapshot=snapshot or(self:getEconomyModule()~=nil and self:getEconomyModule():getSnapshot(farmId)or nil)
    local active=snapshot~=nil and snapshot.tutorialEnabled==true and snapshot.tutorialCompleted~=true
    local step=tostring(snapshot~=nil and snapshot.tutorialStep or "bank")

    -- The guided visit owns the dashboard content area.  Hiding the normal
    -- cards avoids text/button bleed-through on 1080p, 1440p and scaled UIs.
    setVisible(self.dashboardCardsGroup,not active)
    setVisible(self.tutorialOverlay,active)
    -- During the guided start, expose exactly one foundational choice at a time.
    local foundationStep=step=="mode"
    -- During mode selection the selector lives inside the guide card; this also removes the native button artefact seen behind MODE.
    setVisible(self.dashboardSetupBar,not active)
    if active then
        setVisible(self.onboardingModeButton,step=="mode")
        setVisible(self.onboardingActivateButton,false)
    else
        setVisible(self.onboardingModeButton,true)
        setVisible(self.onboardingActivateButton,true)
    end

    if not active then return end
    local content={}
    for _,id in ipairs({"migration","mode","bank","advisor","company","exam","finish"}) do
        content[id]={
            progress=g_i18n:getText("agrilife_tutorial_step_"..id.."_progress"),
            title=g_i18n:getText("agrilife_tutorial_step_"..id.."_title"),
            body=g_i18n:getText("agrilife_tutorial_step_"..id.."_body"),
            check=g_i18n:getText("agrilife_tutorial_step_"..id.."_check"),
            action=g_i18n:getText("agrilife_tutorial_step_"..id.."_action")
        }
    end
    local item=content[step]or content.mode
    local bodyText=item.body
    local checklistText=item.check
    if step=="company" and snapshot~=nil and snapshot.modePolicy~=nil and snapshot.modePolicy.companyRequired~=true then
        item={
            progress=item.progress,
            title=g_i18n:getText("agrilife_onboarding_free_state"),
            body=g_i18n:getText("agrilife_onboarding_free_msg_short"),
            check=g_i18n:getText("agrilife_onboarding_setup_required"),
            action=g_i18n:getText("agrilife_onboarding_validate_start")
        }
        bodyText=item.body
        checklistText=item.check
    end
    if step=="mode" then
        local modeId=tostring(snapshot.modeId or "facile")
        local bodyKey="agrilife_tutorial_mode_detail_"..modeId
        local checkKey="agrilife_tutorial_mode_check_"..modeId
        local localizedBody=g_i18n:getText(bodyKey)
        local localizedCheck=g_i18n:getText(checkKey)
        if localizedBody~=nil and localizedBody~=bodyKey then bodyText=localizedBody end
        if localizedCheck~=nil and localizedCheck~=checkKey then checklistText=localizedCheck end
        setVisible(self.tutorialModeCycleButton,true)
        if self.tutorialModeCycleButton~=nil and self.tutorialModeCycleButton.setText~=nil then
            self.tutorialModeCycleButton:setText(g_i18n:getText("agrilife_onboarding_mode_prefix")..self:getLocalizedModeName(modeId,modeId).."  >")
        end
    else
        setVisible(self.tutorialModeCycleButton,false)
    end
    setText(self.tutorialProgressText,item.progress);setText(self.tutorialTitleText,item.title);setText(self.tutorialBodyText,bodyText);setText(self.tutorialChecklistText,checklistText)
    if self.tutorialActionButton~=nil and self.tutorialActionButton.setText~=nil then self.tutorialActionButton:setText(item.action)end
end

function AgriLife.HomeFrame:onBankLoanResult(result)
    self.bankRequestPending = false
    self.lastBankMessage = self:getBankResultText(result ~= nil and result.code or "BANK_UNKNOWN")
    self:refreshBank()
end

function AgriLife.HomeFrame:syncOnboardingSelection(snapshot)
    if snapshot==nil or AgriLife.Economy6Service==nil then return end
    for i,id in ipairs(AgriLife.Economy6Service.MODE_ORDER or {}) do if id==snapshot.modeId then self.onboardingModeIndex=i break end end
end

function AgriLife.HomeFrame:onClickOnboardingProfile()
    self.lastOnboardingMessage=g_i18n:getText("agrilife_profile_removed_message")
    self:refreshDashboard()
end

function AgriLife.HomeFrame:onClickOnboardingMode()
    local economy=self:getEconomyModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if economy==nil or AgriLife.Economy6Service==nil then return end
    local snapshot=economy:getSnapshot(farmId);if snapshot~=nil and snapshot.modeChosen==true then return end
    local order=AgriLife.Economy6Service.MODE_ORDER; self.onboardingModeIndex=(self.onboardingModeIndex % #order)+1
    local result=economy:selectMode(farmId,order[self.onboardingModeIndex]); self.lastOnboardingMessage=result~=nil and result.message or nil; self:refreshDashboard()
end

function AgriLife.HomeFrame:onClickOnboardingActivate()
    local economy=self:getEconomyModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if economy==nil then return end
    local snapshot=economy:getSnapshot(farmId); if snapshot==nil then return end
    local policy=snapshot.modePolicy or {}
    local result=nil

    if snapshot.existingCareerDetected==true and snapshot.existingCareerAcknowledged~=true then
        result=economy:acknowledgeExistingCareer(farmId)
    elseif snapshot.modeChosen~=true then
        result=economy:confirmMode(farmId)
    elseif policy.bankRequired==true and snapshot.bankProviderSelected~=true then
        -- The dashboard action is a real progression assistant: when the next
        -- obligation is the bank, take the player to the bank instead of
        -- calling finalizeSetup and showing an unrelated company action.
        self.lastOnboardingMessage=nil
        self:showPage("bank")
        return
    elseif policy.bankRequired==true and snapshot.bankAdvisorSelected~=true then
        self.lastOnboardingMessage=nil
        self:showPage("bank")
        return
    elseif snapshot.setupCompleted~=true or (policy.companyRequired==true and snapshot.statutesAccepted~=true) then
        result=economy:finalizeSetup(farmId)
    elseif policy.licenceRequired==true and snapshot.licenceObtained~=true then
        self.lastOnboardingMessage=nil
        self:showPage("exams")
        return
    else
        result=AgriLife.Result.ok("ECONOMY_ONBOARDING_ALREADY_READY","AgriLife onboarding already complete")
    end

    self.lastOnboardingMessage=result~=nil and result.message or g_i18n:getText("agrilife_onboarding_config_unavailable")
    self:refresh()
end

function AgriLife.HomeFrame:getLocalizedModeName(modeId, fallback)
    local key = "agrilife_mode_" .. tostring(modeId or "")
    local value = g_i18n:getText(key)
    if value == nil or value == key then return tostring(fallback or modeId or "--") end
    return value
end

function AgriLife.HomeFrame:getLocalizedProfileName(profileId, fallback)
    local key = "agrilife_profile_" .. tostring(profileId or "")
    local value = g_i18n:getText(key)
    if value == nil or value == key then return tostring(fallback or profileId or "--") end
    return value
end

function AgriLife.HomeFrame:getAutomaticCareerStatus(farmId)
    local career=self:getCareerModule()
    local snapshot=career~=nil and career:getSnapshot(farmId) or nil
    local level=snapshot~=nil and tonumber(snapshot.level) or 1
    local key="agrilife_career_status_new"
    if level>=80 then key="agrilife_career_status_reference"
    elseif level>=50 then key="agrilife_career_status_recognized"
    elseif level>=25 then key="agrilife_career_status_confirmed"
    elseif level>=10 then key="agrilife_career_status_established" end
    local value=g_i18n:getText(key)
    return value~=nil and value~=key and value or tostring(snapshot~=nil and snapshot.levelTitleKey or "--")
end

function AgriLife.HomeFrame:getLocalizedManagementDepth(value)
    local key = "agrilife_company_management_" .. tostring(value or "standard")
    local text = g_i18n:getText(key)
    if text == nil or text == key then return tostring(value or "standard") end
    return text
end

function AgriLife.HomeFrame:refreshOnboarding(farmId)
    local economy=self:getEconomyModule(); local snapshot=economy~=nil and economy:getSnapshot(farmId) or nil
    if snapshot==nil then setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_unavailable")); return end
    self:syncOnboardingSelection(snapshot)
    local mode=AgriLife.Economy6Service.MODES[snapshot.modeId]
    local policy=snapshot.modePolicy or {}
    local companyPending=snapshot.setupCompleted~=true or (policy.companyRequired==true and snapshot.statutesAccepted~=true)
    local bankProviderPending=policy.bankRequired==true and snapshot.bankProviderSelected~=true
    local bankAdvisorPending=policy.bankRequired==true and snapshot.bankProviderSelected==true and snapshot.bankAdvisorSelected~=true
    local licencePending=policy.licenceRequired==true and companyPending~=true and snapshot.licenceObtained~=true
    setText(self.onboardingModeButton,g_i18n:getText("agrilife_onboarding_mode_prefix")..self:getLocalizedModeName(snapshot.modeId, mode~=nil and mode.name or "--"))
    setDisabled(self.onboardingModeButton,not self:canManage("company.manage") or snapshot.modeChosen==true)

    -- Keep the bottom action useful at every mandatory step. Bank/advisor and
    -- exam steps are navigation actions; company/migration/mode remain
    -- administrative actions. This removes the confusing disabled
    -- "VALIDER LA SOCIÉTÉ" state while the player is still choosing a bank.
    local canSetupAction=false
    if snapshot.tutorialChoiceMade==true then
        if bankProviderPending or bankAdvisorPending then
            canSetupAction=self:canManage("bank.manage")
        elseif licencePending then
            canSetupAction=true
        elseif snapshot.existingCareerDetected==true and snapshot.existingCareerAcknowledged~=true or snapshot.modeChosen~=true or companyPending then
            canSetupAction=self:canManage("company.manage")
        end
    end
    setDisabled(self.onboardingActivateButton,not canSetupAction)

    local foundationReady=snapshot.modeChosen==true
    local access=policy.moduleAccess or {}
    setDisabled(self.navCompany,not foundationReady or access.company~=true)
    setDisabled(self.navBank,not foundationReady or access.bank~=true)
    setDisabled(self.navExams,not foundationReady or companyPending or access.exams~=true)
    setDisabled(self.navPayroll,snapshot.ready~=true or access.payroll~=true)
    setDisabled(self.navContracts,snapshot.ready~=true or access.contracts~=true)
    setDisabled(self.navXp,snapshot.ready~=true or access.xp~=true)
    setDisabled(self.navInsurance,snapshot.ready~=true or access.insurance~=true)
    setDisabled(self.navWorkshop,snapshot.ready~=true or access.workshop~=true)
    if self.navAccidents~=nil then setDisabled(self.navAccidents,snapshot.ready~=true or access.accidents~=true) end
    if self.navLeasing~=nil then setDisabled(self.navLeasing,snapshot.ready~=true or access.leasing~=true) end
    if self.navUsed~=nil then setDisabled(self.navUsed,snapshot.ready~=true or access.used~=true) end

    if snapshot.tutorialChoiceMade~=true then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_choice_required_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_choice_required_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_choice_required_button"))
    elseif snapshot.existingCareerDetected==true and snapshot.existingCareerAcknowledged~=true then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_existing_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_existing_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_existing_button"))
    elseif snapshot.modeChosen~=true then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_mode_first_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_mode_first_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_mode_first_button"))
    elseif policy.bankRequired==true and not snapshot.bankProviderSelected then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_bank_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_bank_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_bank_button"))
    elseif policy.bankRequired==true and not snapshot.bankAdvisorSelected then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_advisor_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_advisor_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_advisor_button"))
    elseif companyPending then
        if policy.companyRequired==true then
            setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_company_state"))
            setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_company_msg"))
            setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_company_button"))
        else
            setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_free_state"))
            setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_free_msg_short"))
            setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_validate_start"))
        end
    elseif policy.licenceRequired==true and not snapshot.licenceObtained then
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_licence_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_licence_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_licence_button"))
    elseif snapshot.ready then
        local provisional=snapshot.provisionalLicence or {}
        if provisional.enabled==true and provisional.completed~=true then
            if provisional.expired==true then
                setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_provisional_dashboard_expired_state"))
                setText(self.dashboardMessage,string.format(g_i18n:getText("agrilife_provisional_dashboard_expired_msg"),tonumber(provisional.fineAmount)or 500))
            else
                setText(self.sidebarCoreStateMirror,string.format(g_i18n:getText("agrilife_provisional_dashboard_state"),tonumber(provisional.remainingMonths)or 3))
                setText(self.dashboardMessage,string.format(g_i18n:getText("agrilife_provisional_dashboard_msg"),tonumber(provisional.remainingMonths)or 3,tonumber(policy.provisionalFine)or 500))
            end
        elseif policy.bankRequired==true then
            setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_active_required"))
            setText(self.dashboardMessage,string.format(g_i18n:getText("agrilife_onboarding_ready_message_simple"),self:getLocalizedModeName(snapshot.modeId, snapshot.modeName)))
        else
            setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_active_optional"))
            setText(self.dashboardMessage,string.format(g_i18n:getText("agrilife_onboarding_ready_message_simple"),self:getLocalizedModeName(snapshot.modeId, snapshot.modeName)))
        end
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_validated"))
    else
        setText(self.sidebarCoreStateMirror,g_i18n:getText("agrilife_onboarding_incomplete_state"))
        setText(self.dashboardMessage,self.lastOnboardingMessage or g_i18n:getText("agrilife_onboarding_incomplete_msg"))
        setText(self.onboardingActivateButton,g_i18n:getText("agrilife_onboarding_check_steps"))
    end
    self:updateNavigationStyle(self.activePage or "dashboard")
end

function AgriLife.HomeFrame:refreshDashboard()
    if self.core == nil then return end
    local status = self.core:getStatusSnapshot()
    local farmId = status.farmId or (self.core.context ~= nil and self.core.context:getFarmId()) or 0
    self:refreshOnboarding(farmId)
    local economy=self:getEconomyModule();local economySnapshot=economy~=nil and economy:getSnapshot(farmId)or nil;self:refreshTutorialOverlay(farmId,economySnapshot)

    setText(self.headerVersion, status.version)
    setText(self.headerFarm, string.format("%s %s", g_i18n:getText("agrilife_core_farm"), tostring(farmId)))
    setText(self.valueVersion, status.version)
    setText(self.valueState, status.state)
    setText(self.valueSession, status.sessionId)
    setText(self.valueFarm, farmId)
    setText(self.valueRole, status.isServer and g_i18n:getText("agrilife_core_server") or g_i18n:getText("agrilife_core_client"))
    setText(self.valueMultiplayer, status.isMultiplayer and g_i18n:getText("agrilife_core_yes") or g_i18n:getText("agrilife_core_no"))
    setText(self.valueSchema, status.schemaVersion)

    local saveText = g_i18n:getText("agrilife_core_never")
    if status.lastSaveOk == true then
        saveText = g_i18n:getText("agrilife_core_success")
    elseif status.lastSaveOk == false then
        saveText = g_i18n:getText("agrilife_core_failure")
    end
    setText(self.valueLastSave, saveText)
    setText(self.valueModules, string.format("%d / %d", status.activeModuleCount, status.moduleCount))
    setText(self.valueErrors, string.format("%s: %d", g_i18n:getText("agrilife_core_errors"), status.errorCount))

    local statusText = g_i18n:getText("agrilife_core_ready")
    if status.state == AgriLife.Lifecycle.State.DEGRADED or status.errorCount > 0 then
        statusText = g_i18n:getText("agrilife_core_degraded")
    end
    setText(self.statusValueCard, statusText)
    setText(self.sidebarCoreState, statusText)

    local bank = self:getBankModule()
    local bankSnapshot = bank ~= nil and farmId > 0 and bank:getSnapshot(farmId) or nil
    if bankSnapshot ~= nil then
        setText(self.headerCash, formatMoney(bankSnapshot.cash))
        setText(self.dashBankCash, formatMoney(bankSnapshot.cash))
        setText(self.dashBankDebt, formatMoney(bankSnapshot.agriLifeDebt))
        setText(self.dashBankScore, string.format("%d - %s", bankSnapshot.score or 0, g_i18n:getText("agrilife_bank6_rating_" .. tostring(bankSnapshot.rating or "standard"))))
    else
        setText(self.headerCash, "--")
        setText(self.dashBankCash, "--")
        setText(self.dashBankDebt, "--")
        setText(self.dashBankScore, g_i18n:getText("agrilife_ui6_module_not_connected"))
    end

    local exam = self:getExamModule()
    local examSnapshot = exam ~= nil and farmId > 0 and exam:getSnapshot(farmId) or nil
    if examSnapshot ~= nil then
        local modePolicy=economySnapshot~=nil and economySnapshot.modePolicy or {}
        local provisional=economySnapshot~=nil and economySnapshot.provisionalLicence or {}
        local licenceObtained=examSnapshot.licenceStatus=="obtained"

        setText(self.dashExamCatalogLabel,g_i18n:getText("agrilife_exam6_dashboard_attempts_label"))
        setText(self.dashExamCatalog,string.format(g_i18n:getText("agrilife_exam6_dashboard_attempts_value"),tonumber(examSnapshot.attempts)or 0,tonumber(examSnapshot.passes)or 0))

        if licenceObtained then
            setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_licensed"))
            setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_dashboard_result_label"))
            setText(self.dashExamProgress,string.format(g_i18n:getText("agrilife_exam6_dashboard_score_value"),tonumber(examSnapshot.bestScore)or tonumber(examSnapshot.score)or 0))
        elseif examSnapshot.examRunning then
            setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_running"))
            setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_progress"))
            setText(self.dashExamProgress,string.format("%d/10 - %d%%",examSnapshot.currentIndex or 1,examSnapshot.progress or 0))
        elseif provisional.enabled==true and provisional.completed~=true then
            setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_dashboard_deadline_label"))
            if provisional.expired==true then
                setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_provisional_expired"))
                setText(self.dashExamProgress,g_i18n:getText("agrilife_exam6_dashboard_deadline_expired"))
            elseif provisional.started==true then
                setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_provisional"))
                setText(self.dashExamProgress,string.format(g_i18n:getText("agrilife_exam6_dashboard_months_left"),tonumber(provisional.remainingMonths)or tonumber(modePolicy.provisionalMonths)or 3))
            else
                setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_provisional_pending"))
                setText(self.dashExamProgress,g_i18n:getText("agrilife_exam6_dashboard_after_bank"))
            end
        elseif modePolicy.licenceRequired==true then
            setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_required"))
            setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_progress"))
            setText(self.dashExamProgress,g_i18n:getText("agrilife_exam6_dashboard_not_started"))
        else
            setText(self.dashExamState,g_i18n:getText("agrilife_exam6_state_optional"))
            setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_progress"))
            setText(self.dashExamProgress,g_i18n:getText("agrilife_exam6_dashboard_not_started"))
        end
    else
        setText(self.dashExamState, g_i18n:getText("agrilife_ui6_module_not_connected"))
        setText(self.dashExamProgressLabel,g_i18n:getText("agrilife_exam6_progress"))
        setText(self.dashExamCatalogLabel,g_i18n:getText("agrilife_exam6_dashboard_attempts_label"))
        setText(self.dashExamProgress, "--")
        setText(self.dashExamCatalog, "--")
    end

    local career = self:getCareerModule()
    local careerSnapshot = career ~= nil and farmId > 0 and career:getSnapshot(farmId) or nil
    if careerSnapshot ~= nil then
        setText(self.dashCareerLevel, string.format("%d - %s", careerSnapshot.level or 1, g_i18n:getText(careerSnapshot.levelTitleKey or "agrilife_career6_title_beginner")))
        setText(self.dashCareerXp, formatNumber(careerSnapshot.totalXP, 0) .. " XP")
        setText(self.dashCareerReputation, string.format("%d/100", careerSnapshot.reputation or 0))
    else
        setText(self.dashCareerLevel, g_i18n:getText("agrilife_ui6_module_not_connected"))
        setText(self.dashCareerXp, "--")
        setText(self.dashCareerReputation, "--")
    end

    local statuses = self.core.registry ~= nil and self.core.registry.statuses or {}
    local insurance=self:getInsuranceModule(); local insuranceSnapshot=insurance~=nil and insurance:getSnapshot(farmId) or nil
    if insuranceSnapshot~=nil then setText(self.dashInsuranceState,string.format("%d contrat(s)",insuranceSnapshot.activePolicies or 0)); setText(self.dashInsuranceDetail,string.format("%s/mois  |  %d sinistre(s)",formatMoney(insuranceSnapshot.monthlyPremium or 0),insuranceSnapshot.openClaims or 0)) else setText(self.dashInsuranceState,g_i18n:getText("agrilife_ui6_module_not_connected")); setText(self.dashInsuranceDetail,"--") end
    local workshop=self:getWorkshopModule(); local workshopSnapshot=workshop~=nil and workshop:getSnapshot(farmId) or nil
    if workshopSnapshot~=nil then setText(self.dashWorkshopState,string.format("%d matériel(s)",workshopSnapshot.vehicleCount or 0)); setText(self.dashWorkshopDetail,string.format("%d révision(s)  |  %d panne(s)",workshopSnapshot.serviceDue or 0,workshopSnapshot.breakdowns or 0)) else setText(self.dashWorkshopState,g_i18n:getText("agrilife_ui6_module_not_connected")); setText(self.dashWorkshopDetail,"--") end

    local bankStatus = statuses ~= nil and statuses.bank or "--"
    setText(self.dashboardBankState, bank ~= nil and tostring(bankStatus) or g_i18n:getText("agrilife_ui6_module_not_connected"))
end

function AgriLife.HomeFrame:refreshBank()
    local bank = self:getBankModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    if bank == nil or farmId <= 0 then
        setText(self.bankStatusText, g_i18n:getText("agrilife_bank6_unavailable"))
        setDisabled(self.bankRequestButton, true)
        return
    end

    local snapshot = bank:getSnapshot(farmId)
    if snapshot == nil then
        setText(self.bankStatusText, g_i18n:getText("agrilife_bank6_unavailable"))
        setDisabled(self.bankRequestButton, true)
        return
    end

    if self.bankProviderBrowsing~=true then self:syncBankProviderIndex(snapshot) end
    if self.bankAdvisorBrowsing~=true then self:syncBankAdvisorIndex(snapshot) end
    local canManageBank = self:canManage("bank.manage")
    local providerOrder,providerDefs=bank:getProviders()
    local candidateProviderId=type(providerOrder)=="table" and providerOrder[math.max(1,math.min(#providerOrder,tonumber(self.bankProviderIndex)or 1))] or nil
    local candidateProvider=providerDefs~=nil and providerDefs[candidateProviderId] or nil
    local applicationPending=(tonumber(snapshot.pendingApplicationCount) or 0)>0
    setDisabled(self.bankProviderPrevButton, not canManageBank or applicationPending)
    setDisabled(self.bankProviderNextButton, not canManageBank or applicationPending)
    if self.bankProviderButton~=nil then
        if self.bankProviderButton.setText~=nil then self.bankProviderButton:setText(upperDisplay(candidateProvider~=nil and candidateProvider.name or snapshot.providerName or "--")) end
        if self.bankProviderButton.setSelected~=nil then pcall(self.bankProviderButton.setSelected,self.bankProviderButton,snapshot.providerSelected==true and candidateProviderId==snapshot.providerId and self.bankProviderBrowsing~=true) end
    end
    setDisabled(self.bankProviderButton,not canManageBank or applicationPending)
    setStarRow(self,"bankProviderStar",candidateProvider~=nil and (candidateProvider.reputationStars or candidateProvider.stars or candidateProvider.tier) or snapshot.providerReputationStars or snapshot.providerStars or 1)
    setStarRow(self,"bankProviderSkillStar",candidateProvider~=nil and (candidateProvider.competenceStars or candidateProvider.stars or candidateProvider.tier) or snapshot.providerCompetenceStars or snapshot.providerStars or 1)
    local advisorOrder,advisorDefs=bank:getAdvisors()
    local candidateAdvisorId=type(advisorOrder)=="table" and advisorOrder[math.max(1,math.min(#advisorOrder,tonumber(self.bankAdvisorIndex)or 1))] or nil
    local candidateAdvisor=advisorDefs~=nil and advisorDefs[candidateAdvisorId] or nil
    local advisorEnabled=canManageBank and snapshot.providerSelected==true and not applicationPending
    setDisabled(self.bankAdvisorPrevButton,not advisorEnabled)
    setDisabled(self.bankAdvisorNextButton,not advisorEnabled)
    if self.bankAdvisorButton~=nil then
        if self.bankAdvisorButton.setText~=nil then self.bankAdvisorButton:setText(upperDisplay(candidateAdvisor~=nil and candidateAdvisor.name or "--"))end
        if self.bankAdvisorButton.setSelected~=nil then pcall(self.bankAdvisorButton.setSelected,self.bankAdvisorButton,snapshot.advisorSelected==true and candidateAdvisorId==snapshot.advisorId and self.bankAdvisorBrowsing~=true) end
    end
    setDisabled(self.bankAdvisorButton,not advisorEnabled)
    setStarRow(self,"bankAdvisorStar",candidateAdvisor~=nil and (candidateAdvisor.reputationStars or candidateAdvisor.stars or candidateAdvisor.tier) or snapshot.advisorReputationStars or snapshot.advisorStars or 1)
    setStarRow(self,"bankAdvisorSkillStar",candidateAdvisor~=nil and (candidateAdvisor.competenceStars or candidateAdvisor.stars or candidateAdvisor.tier) or snapshot.advisorCompetenceStars or snapshot.advisorStars or 1)
    setText(self.bankCashValue, formatMoney(snapshot.cash))
    setText(self.bankVanillaDebtValue, formatMoney(snapshot.vanillaDebt))
    setText(self.bankDebtValue, formatMoney(snapshot.agriLifeDebt))
    setText(self.bankMonthlyValue, formatMoney(snapshot.monthly))
    setText(self.bankScoreValue, string.format("%d - %s", snapshot.score, g_i18n:getText("agrilife_bank6_rating_" .. snapshot.rating)))
    setText(self.bankCapacityValue, formatMoney(snapshot.capacity))
    setText(self.bankLoansValue, snapshot.activeLoans)
    setStarRow(self,"bankOwnerStar",snapshot.ownerReputationStars or 3)
    setStarRow(self,"bankCompanyStar",snapshot.companyReputationStars or 3)
    local nextBank=snapshot.nextBankProgression
    local progressText=string.format(g_i18n:getText("agrilife_bank6_progress_line_stars"),tonumber(snapshot.bankRelationship)or 0,tonumber(snapshot.advisorTrust)or 0,tonumber(snapshot.bankingTenureMonths)or 0,tostring(snapshot.providerTierName or"--"),tostring(snapshot.advisorTierName or"--"))
    if nextBank~=nil then progressText=progressText.."  |  "..string.format(g_i18n:getText("agrilife_bank6_next_unlock"),tostring(nextBank.providerName or"--"),tonumber(nextBank.requiredReputation)or 0,tonumber(nextBank.requiredScore)or 0,tonumber(nextBank.requiredRelationship)or 0) end
    local modeLabel=g_i18n:getText("agrilife_mode_"..tostring(snapshot.bankModeId or "normal"))
    progressText=progressText.."  |  "..string.format(
        g_i18n:getText("agrilife_bank6_difficulty_policy_short"),
        tostring(modeLabel),
        (tonumber(snapshot.difficultyCapacityFactor)or 1)*100,
        (tonumber(snapshot.difficultyRateAdjustment)or 0)*100,
        (tonumber(snapshot.difficultyContributionRate)or 0)*100)
    setText(self.bankProgressValue,progressText)

    local amount = self:getSelectedBankAmount(snapshot)
    local termMonths = self:getSelectedBankTerm()
    setText(self.bankAmountValue, formatMoney(amount))
    setText(self.bankTermValue, string.format(g_i18n:getText("agrilife_bank6_months_format"), termMonths))

    local purpose=self:getSelectedBankPurpose();local purposeDefinition=AgriLife.Bank6Service~=nil and AgriLife.Bank6Service.PURPOSES[purpose] or nil
    if self.bankPurposeButton~=nil and self.bankPurposeButton.setText~=nil then self.bankPurposeButton:setText(upperDisplay(tostring(purposeDefinition~=nil and purposeDefinition.name or purpose))) end
    local preview = bank:previewLoan(farmId, amount, termMonths, purpose)
    if snapshot.providerSelected~=true then
        setText(self.bankRateValue, "--");setText(self.bankPaymentValue, "--");setText(self.bankTotalValue, "--");setText(self.bankInterestValue, "--")
        setText(self.bankSetupFeeValue, "--"); setText(self.bankMonthlyFeePreviewValue, "--")
        setText(self.bankStatusText,self.lastBankMessage or g_i18n:getText("agrilife_bank6_click_to_confirm_provider"))
        setDisabled(self.bankRequestButton,true)
    elseif snapshot.advisorSelected~=true then
        setText(self.bankRateValue, "--");setText(self.bankPaymentValue, "--");setText(self.bankTotalValue, "--");setText(self.bankInterestValue, "--")
        setText(self.bankSetupFeeValue, "--"); setText(self.bankMonthlyFeePreviewValue, formatMoney(snapshot.monthlyAccountFee or 0))
        setText(self.bankStatusText,self.lastBankMessage or g_i18n:getText("agrilife_bank6_click_to_confirm_advisor"))
        setDisabled(self.bankRequestButton,true)
    elseif preview ~= nil and preview.ok then
        local d = preview.details
        setText(self.bankRateValue, formatPercent(d.annualRate))
        setText(self.bankPaymentValue, formatMoney(d.monthlyPayment))
        setText(self.bankTotalValue, formatMoney(d.totalCost))
        setText(self.bankInterestValue, formatMoney(d.totalInterest))
        -- Keep professional banking costs visible before the player submits the file.
        setText(self.bankSetupFeeValue, formatMoney(d.setupFee or 0))
        setText(self.bankMonthlyFeePreviewValue, formatMoney(d.monthlyAccountFee or snapshot.monthlyAccountFee or 0))
        if applicationPending then
            local hours=math.max(0,(tonumber(snapshot.applicationRemainingMs)or 0)/3600000)
            setText(self.bankStatusText,string.format(g_i18n:getText("agrilife_bank6_application_reviewing"),hours))
        elseif tostring(snapshot.applicationStatus or"none")=="rejected" then
            local reason=self:getBankDecisionReasonText(snapshot.applicationDecisionReasonCode)
            setText(self.bankStatusText,string.format(g_i18n:getText("agrilife_bank6_application_last_rejected_reason"),tonumber(snapshot.applicationDecisionScore)or 0,tonumber(snapshot.applicationDecisionThreshold)or 0,reason))
        elseif tostring(snapshot.applicationStatus or"none")=="approved" then
            local reason=self:getBankDecisionReasonText(snapshot.applicationDecisionReasonCode)
            setText(self.bankStatusText,string.format(g_i18n:getText("agrilife_bank6_application_last_approved_reason"),reason))
        elseif self.lastBankMessage == nil then
            local economy=self:getEconomyModule();local onboarding=economy~=nil and economy:getSnapshot(farmId)or nil
            if onboarding~=nil and onboarding.tutorialEnabled==true and onboarding.tutorialCompleted~=true then setText(self.bankStatusText,string.format(g_i18n:getText("agrilife_bank6_advisor_status"),tostring(snapshot.advisorName or"--"),tostring(snapshot.advisorTierName or"--"),tostring(snapshot.advisorDescription or"")))else setText(self.bankStatusText, g_i18n:getText(canManageBank and "agrilife_bank6_ready" or "agrilife_people6_readonly_bank"))end
        else
            setText(self.bankStatusText, self.lastBankMessage)
        end
        setDisabled(self.bankRequestButton, self.bankRequestPending or applicationPending or not canManageBank)
    else
        setText(self.bankRateValue, "--")
        setText(self.bankPaymentValue, "--")
        setText(self.bankTotalValue, "--")
        setText(self.bankInterestValue, "--")
        setText(self.bankSetupFeeValue, "--"); setText(self.bankMonthlyFeePreviewValue, snapshot.providerSelected==true and formatMoney(snapshot.monthlyAccountFee or 0) or "--")
        setText(self.bankStatusText, self.lastBankMessage or self:getBankResultText(preview ~= nil and preview.code or "BANK_UNKNOWN"))
        setDisabled(self.bankRequestButton, true)
    end
    local loan=self:getPrimaryLoan()
    setText(self.bankAdvancedLoanValue,loan~=nil and string.format("%s - restant %s - %d mois",tostring(loan.purpose or"Prêt"),formatMoney(loan.principalRemaining or 0),loan.remainingMonths or loan.termMonths or 0)or"Aucun prêt AgriLife actif")
    setText(self.bankOverdraftValue,string.format("Découvert %s | utilisé %s | frais en retard %s",formatMoney(snapshot.overdraftLimit or 0),formatMoney(snapshot.overdraftUsed or 0),formatMoney(snapshot.accountFeesArrears or 0)))
    setDisabled(self.bankEarlyRepayButton,loan==nil or not canManageBank);setDisabled(self.bankRestructureButton,loan==nil or not canManageBank);setDisabled(self.bankOverdraftButton,not canManageBank)
    -- Banque AgriLife = compte professionnel uniquement. Le compte personnel reste
    -- géré hors de cet écran (Personnel/Société) afin de ne pas mélanger les fonds.
    local statementView = self.bankAccountView == "statement"
    setVisible(self.bankFinancingPanel, not statementView)
    setVisible(self.bankStatementPanel, statementView)
    setDisabled(self.bankProAccountButton, not statementView)
    setDisabled(self.bankPersonalAccountButton, statementView)
    setText(self.bankAccountTitle,g_i18n:getText("agrilife_bank_account_professional"))
    setText(self.bankAccountSummary,string.format(g_i18n:getText("agrilife_bank_account_pro_summary_v2"),formatMoney(snapshot.cash or 0),formatMoney(snapshot.monthlyAccountFee or 0),formatMoney((snapshot.accountFeesPaid or 0)+(snapshot.incidentFeesPaid or 0)+(snapshot.loanFeesPaid or 0)+(snapshot.earlyRepayFeesPaid or 0)),formatMoney(snapshot.totalInterestPaid or 0)))

    setText(self.bankStatementFeeSummary,string.format(g_i18n:getText("agrilife_bank_statement_fee_summary"),formatMoney(snapshot.monthlyAccountFee or 0),formatMoney(snapshot.loanFeesPaid or 0),formatMoney(snapshot.incidentFeesPaid or 0),formatMoney(snapshot.totalInterestPaid or 0)))
    local movements = snapshot.recentBankMovements or {}
    for i=1,6 do
        local movement = movements[i]
        setText(self["bankStatementDate"..i], movement~=nil and formatBankMovementDate(movement) or "--")
        setText(self["bankStatementLabel"..i], movement~=nil and getBankMovementLabel(movement.kind) or g_i18n:getText("agrilife_bank_statement_empty"))
        setText(self["bankStatementTags"..i], movement~=nil and tostring(movement.tags or "") or "")
        setText(self["bankStatementAmount"..i], movement~=nil and formatSignedMoney(movement.amount) or "--")
        setText(self["bankStatementBalance"..i], movement~=nil and formatMoney(movement.balanceAfter) or "--")
    end
end


function AgriLife.HomeFrame:getLocalPayrollProfileId(farmId)
    local people=self:getPeopleModule()
    if people~=nil and people.getLocalProfileId~=nil then return people:getLocalProfileId(farmId) end
    return nil
end

function AgriLife.HomeFrame:getSelectedPayrollEmployee(snapshot)
    if snapshot==nil then return nil end
    local selectedId=tostring(self.payrollSelectedProfileId or "")
    for _,e in ipairs(snapshot.employees or {}) do if tostring(e.profileId or "")==selectedId then return e end end
    return nil
end


local function getPayrollEmploymentKey(employee)
    local status=tostring(employee~=nil and employee.employmentStatus or "")
    if status=="TERMINATED" then return "agrilife_payroll6_employment_terminated" end
    if employee~=nil and employee.active==true then return "agrilife_payroll6_employment_active" end
    return "agrilife_payroll6_employment_suspended"
end

local function getRecentPayrollLines(snapshot,profileId,limit)
    local lines={}
    local payments=snapshot~=nil and snapshot.recentPayments or {}
    for i=#payments,1,-1 do
        local p=payments[i]
        if tostring(p.profileId or "")==tostring(profileId or "") then
            local gross=tonumber(p.paid) or tonumber(p.gross) or 0
            local withholding=tonumber(p.withholding) or 0
            local net=tonumber(p.netPaid)
            if net==nil then net=math.max(0,gross-withholding) end
            table.insert(lines,string.format(g_i18n:getText("agrilife_payroll6_latest_detail"),formatPersonalMoney(gross),formatPersonalMoney(withholding),formatPersonalMoney(net)))
            if #lines>=math.max(1,tonumber(limit) or 1) then break end
        end
    end
    if #lines==0 then return g_i18n:getText("agrilife_payroll6_history_empty") end
    return table.concat(lines,"\n")
end

local function getLatestPayrollCompact(snapshot,profileId)
    local payments=snapshot~=nil and snapshot.recentPayments or {}
    for i=#payments,1,-1 do
        local p=payments[i]
        if tostring(p.profileId or "")==tostring(profileId or "") then
            local status=tostring(p.status or "PAID")
            local key=status=="PAID" and "agrilife_payroll6_history_paid" or (status=="SETTLED" and "agrilife_payroll6_history_settled" or (status=="PARTIAL" and "agrilife_payroll6_history_partial" or "agrilife_payroll6_history_unpaid"))
            return string.format(g_i18n:getText("agrilife_payroll6_latest_compact"),p.periodKey or 0,formatMoney(p.paid or 0),g_i18n:getText(key))
        end
    end
    return g_i18n:getText("agrilife_payroll6_history_empty")
end

local function getPersonalMovementLabel(kind)
    local movementKeys={
        SALARY="agrilife_payroll6_movement_salary",
        FINAL_SETTLEMENT="agrilife_payroll6_movement_settlement",
        PURCHASE="agrilife_payroll6_movement_purchase",
        STARTING_CAPITAL="agrilife_payroll6_movement_starting_capital",
        EXAM_FEE="agrilife_payroll6_movement_exam_fee",
        EXAM_REFUND="agrilife_payroll6_movement_exam_refund",
        HOUSING="agrilife_payroll6_movement_housing",
        PERSONAL_BANK_FEE="agrilife_payroll6_movement_bank_fee",
        PRIVATE_VEHICLE="agrilife_payroll6_movement_private_vehicle",
        PRIVATE_VEHICLE_SALE="agrilife_payroll6_movement_private_vehicle_sale",
        PRIVATE_VEHICLE_RUNNING_COST="agrilife_payroll6_movement_private_vehicle_cost",
        PERSONAL_TAX="agrilife_payroll6_movement_personal_tax",
        BENEFIT="agrilife_payroll6_movement_benefit",
        PROVISIONAL_LICENCE_FINE="agrilife_payroll6_movement_licence_fine",
        PERSONAL_EXPENSE="agrilife_payroll6_movement_personal_expense",
        PERSONAL_INCOME="agrilife_payroll6_movement_personal_income"
    }
    return g_i18n:getText(movementKeys[tostring(kind or "UNKNOWN")] or "agrilife_payroll6_movement_other")
end

local function getRecentPersonalMovements(snapshot,profileId,limit)
    local txs=snapshot~=nil and snapshot.recentTransactions or {}
    local lines={}
    for i=#txs,1,-1 do
        local tx=txs[i]
        if tostring(tx.profileId or "")==tostring(profileId or "") then
            local amount=tonumber(tx.amount) or 0
            local signed=(amount>=0 and "+" or "-")..formatPersonalMoney(math.abs(amount))
            table.insert(lines,string.format(g_i18n:getText("agrilife_payroll6_movement_row"),tx.periodKey or 0,getPersonalMovementLabel(tx.kind),signed,formatPersonalMoney(tx.balanceAfter or 0)))
            if #lines>=math.max(1,tonumber(limit) or 4) then break end
        end
    end
    if #lines==0 then return g_i18n:getText("agrilife_payroll6_movement_empty") end
    return table.concat(lines,"\n")
end

function AgriLife.HomeFrame:refreshPayroll()
    local company=self:getCompanyModule(); local payroll=self:getPayrollModule(); local people=self:getPeopleModule()
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if company==nil or payroll==nil or farmId<=0 then setText(self.payrollStatusText,g_i18n:getText("agrilife_payroll6_unavailable")); return end
    local cs=company:getSnapshot(farmId); local ps=payroll:getSnapshot(farmId)
    if cs==nil or ps==nil then setText(self.payrollStatusText,g_i18n:getText("agrilife_payroll6_unavailable")); return end
    local economy=self:getEconomyModule();local ready=economy~=nil and economy:isReady(farmId);local canManagePayroll=self:canManage("payroll.manage")and ready
    if not canManagePayroll and self.payrollSubview=="team" then self.payrollSubview="self" end
    local own=self.payrollSubview~="team"
    setVisible(self.payrollSelfPanel,own); setVisible(self.payrollTeamPanel,not own)
    setDisabled(self.payrollSelfTabButton,own); setDisabled(self.payrollTeamTabButton,(not own) or not canManagePayroll)

    setText(self.payrollCompanyValue,cs.companyName or "--")
    setText(self.payrollLegalFormValue,g_i18n:getText(cs.legalFormLabelKey or "agrilife_company6_form_EI"))
    setText(self.payrollTotalValue,formatMoney(ps.totalMonthlyPayroll or 0))
    setText(self.payrollCountValue,tostring(ps.employeeCount or 0))
    local canRecruit=canManagePayroll and self:canManage("profiles.manage")
    setDisabled(self.payrollRecruitCdiButton,not canRecruit); setDisabled(self.payrollRecruitCddButton,not canRecruit); setDisabled(self.payrollRecruitApprenticeButton,not canRecruit)
    setDisabled(self.legalFormPrevButton,not canManagePayroll); setDisabled(self.legalFormNextButton,not canManagePayroll)
    local forms=company:getLegalForms() or {}; for i,form in ipairs(forms) do if form.id==cs.legalFormId then self.legalFormIndex=i; break end end

    local localProfileId=self:getLocalPayrollProfileId(farmId)
    local ownEmployee=nil
    for _,e in ipairs(ps.employees or {}) do if tostring(e.profileId or "")==tostring(localProfileId or "") then ownEmployee=e; break end end
    if ownEmployee==nil and #((ps.employees) or {})==1 and not canManagePayroll then ownEmployee=ps.employees[1] end
    if ownEmployee~=nil then
        setText(self.payrollSelfNameValue,ownEmployee.displayName or "Joueur")
        local ownEmploymentKey=getPayrollEmploymentKey(ownEmployee)
        setText(self.payrollSelfRoleValue,g_i18n:getText(ownEmployee.roleLabelKey or "agrilife_payroll6_role_employee").."  |  "..g_i18n:getText(ownEmploymentKey))
        setText(self.payrollSelfSalaryValue,formatMoney(ownEmployee.monthlySalary or 0))
        setText(self.payrollSelfRecommendedValue,formatMoney(ownEmployee.recommendedSalary or 0))
        setText(self.payrollSelfBalanceValue,formatPersonalMoney(ownEmployee.personalBalance or 0))
        setText(self.payrollSelfArrearsValue,formatPersonalMoney(ownEmployee.salaryArrears or 0))
        setText(self.payrollSelfCareerValue,string.format("%d  |  %d/100",ownEmployee.careerLevel or 1,ownEmployee.reputation or 50))
        setText(self.payrollSelfModeValue,g_i18n:getText(ownEmployee.salaryMode=="MANUAL" and "agrilife_payroll6_salary_manual" or "agrilife_payroll6_salary_auto"))
        local totalGross=tonumber(ownEmployee.totalPaid) or tonumber(ownEmployee.totalGrossPaid) or 0
        local totalWithholding=tonumber(ownEmployee.withholdingPaid) or 0
        local totalNet=math.max(0,totalGross-totalWithholding)
        setText(self.payrollSelfHistoryValue,string.format(g_i18n:getText("agrilife_payroll6_history_detail_format"),ownEmployee.paymentCount or 0,formatPersonalMoney(totalGross),formatPersonalMoney(totalWithholding),formatPersonalMoney(totalNet)).."\n"..getRecentPayrollLines(ps,ownEmployee.profileId,1))
        setText(self.payrollSelfPrivateHint,getRecentPersonalMovements(ps,ownEmployee.profileId,5))
    else
        setText(self.payrollSelfNameValue,g_i18n:getText("agrilife_payroll6_no_profile")); setText(self.payrollSelfRoleValue,"--"); setText(self.payrollSelfSalaryValue,"--"); setText(self.payrollSelfRecommendedValue,"--"); setText(self.payrollSelfBalanceValue,"--"); setText(self.payrollSelfArrearsValue,"--"); setText(self.payrollSelfCareerValue,"--"); setText(self.payrollSelfModeValue,"--"); setText(self.payrollSelfHistoryValue,"--"); setText(self.payrollSelfPrivateHint,g_i18n:getText("agrilife_payroll6_private_spending_hint"))
    end

    local employees=ps.employees or {}; local pageSize=5; local pageCount=math.max(1,math.ceil(#employees/pageSize)); self.payrollTeamPage=math.max(1,math.min(pageCount,self.payrollTeamPage or 1)); self.payrollTeamRows={}
    local first=(self.payrollTeamPage-1)*pageSize+1
    for i=1,pageSize do
        local e=employees[first+i-1]; self.payrollTeamRows[i]=e
        local row=self["payrollTeamRow"..tostring(i)]
        if e~=nil then
            local role=g_i18n:getText(e.roleLabelKey or "agrilife_payroll6_role_employee")
            local employment=g_i18n:getText(getPayrollEmploymentKey(e))
            setText(row,string.format("%s   |   %s   |   %s   |   Niv. %d   |   %s/mois",e.displayName or "Joueur",role,employment,e.careerLevel or 1,formatMoney(e.monthlySalary or 0))); setDisabled(row,false)
        else setText(row,"-"); setDisabled(row,true) end
    end
    setText(self.payrollTeamPageValue,string.format("%d / %d",self.payrollTeamPage,pageCount)); setDisabled(self.payrollTeamPrevButton,self.payrollTeamPage<=1); setDisabled(self.payrollTeamNextButton,self.payrollTeamPage>=pageCount)
    local selected=self:getSelectedPayrollEmployee(ps)
    if selected==nil then selected=employees[first]; self.payrollSelectedProfileId=selected~=nil and selected.profileId or nil end
    if selected~=nil then
        setText(self.payrollSelectedNameValue,selected.displayName or "Joueur")
        setText(self.payrollSelectedRoleValue,g_i18n:getText(selected.roleLabelKey or "agrilife_payroll6_role_employee"))
        local selectedStars=workerStars(selected)
        setStarRow(self,"payrollWorkerStar",selectedStars)
        setText(self.payrollWorkerStarsValue,string.format(g_i18n:getText("agrilife_payroll6_worker_stars"),selectedStars))
        setText(self.payrollSelectedSalaryValue,formatMoney(selected.monthlySalary or 0))
        setText(self.payrollSelectedRecommendedValue,formatMoney(selected.recommendedSalary or 0))
        setText(self.payrollSelectedRangeValue,string.format("%s - %s",formatMoney(selected.salaryMin or 0),formatMoney(selected.salaryMax or 0)))
        setText(self.payrollSelectedBalanceValue,selected.personalBalanceVisible==true and formatMoney(selected.personalBalance or 0) or g_i18n:getText("agrilife_payroll6_balance_private"))
        setText(self.payrollSelectedArrearsValue,formatMoney(selected.salaryArrears or 0))
        local selectedEmployment=g_i18n:getText(getPayrollEmploymentKey(selected))
        setText(self.payrollSelectedModeValue,selectedEmployment.."  |  "..g_i18n:getText(selected.salaryMode=="MANUAL" and "agrilife_payroll6_salary_manual" or "agrilife_payroll6_salary_auto").."  |  "..getLatestPayrollCompact(ps,selected.profileId))
    else
        for _,id in ipairs({"payrollSelectedNameValue","payrollSelectedRoleValue","payrollSelectedSalaryValue","payrollSelectedRecommendedValue","payrollSelectedRangeValue","payrollSelectedBalanceValue","payrollSelectedArrearsValue","payrollSelectedModeValue"}) do setText(self[id],"--") end
        setStarRow(self,"payrollWorkerStar",0); setText(self.payrollWorkerStarsValue,"--")
    end
    local localProfileId=self:getLocalPayrollProfileId(farmId)
    local localPeople=people~=nil and people.getSnapshot~=nil and people:getSnapshot(farmId) or nil
    local localRole="employee"
    if localPeople~=nil then for _,p in ipairs(localPeople.profiles or {}) do if tostring(p.profileId or "")==tostring(localProfileId or "") then localRole=p.role or localRole; break end end end
    local employmentStatus=selected~=nil and tostring(selected.employmentStatus or (selected.active and "ACTIVE" or "SUSPENDED")) or ""
    local editable=canManagePayroll and selected~=nil and employmentStatus~="TERMINATED" and (localRole=="owner" or ((selected.role=="employee" or selected.role=="apprentice") and tostring(selected.profileId or "")~=tostring(localProfileId or "")))
    local roleEditable=selected~=nil and employmentStatus~="TERMINATED" and selected.role~="owner" and self:canManage("roles.manage")
    local employmentEditable=false
    if selected~=nil and self:canManage("profiles.manage") and selected.role~="owner" then
        employmentEditable=localRole=="owner" or ((selected.role=="employee" or selected.role=="apprentice") and tostring(selected.profileId or "")~=tostring(localProfileId or ""))
    end
    local terminateEditable=employmentEditable and (employmentStatus~="TERMINATED" or (tonumber(selected.salaryArrears) or 0)>0.01)
    setDisabled(self.payrollRolePrevButton,not roleEditable); setDisabled(self.payrollRoleNextButton,not roleEditable); setDisabled(self.payrollSalaryAutoButton,not editable or selected.salaryMode=="AUTO"); setDisabled(self.payrollSalaryDownButton,not editable); setDisabled(self.payrollSalaryUpButton,not editable); setDisabled(self.payrollActiveButton,not employmentEditable); setDisabled(self.payrollTerminateButton,not terminateEditable)
    setDisabled(self.payrollOvertimeButton,not editable);setDisabled(self.payrollAbsenceButton,not editable);setDisabled(self.payrollSickButton,not editable);setDisabled(self.payrollLeaveButton,selected==nil or employmentStatus=="TERMINATED");setDisabled(self.payrollSettleButton,selected==nil or(tonumber(selected.salaryArrears)or 0)<=0.01)
    setText(self.payrollAttendanceValue,selected~=nil and string.format("%s | H sup. %.1f | Abs. %.1f j | Mal. %.1f j | Congés %.1f j",tostring(selected.contractType or"CDI"),tonumber(selected.overtimeHours)or 0,tonumber(selected.absenceDays)or 0,tonumber(selected.sickDays)or 0,tonumber(selected.leaveBalanceDays)or 0)or"--")
    local activeKey="agrilife_payroll6_resume_pay"
    if selected~=nil and employmentStatus=="TERMINATED" then activeKey="agrilife_payroll6_rehire" elseif selected~=nil and selected.active==true then activeKey="agrilife_payroll6_suspend_pay" end
    setText(self.payrollActiveButton,g_i18n:getText(activeKey))
    local terminateKey="agrilife_payroll6_terminate"
    if employmentStatus=="TERMINATED" then terminateKey=(tonumber(selected~=nil and selected.salaryArrears or 0) or 0)>0.01 and "agrilife_payroll6_settle_arrears" or "agrilife_payroll6_termination_recorded" end
    setText(self.payrollTerminateButton,g_i18n:getText(terminateKey))
    setText(self.payrollStatusText,self.lastPayrollMessage or(not ready and"Accès verrouillé : choisissez la banque et obtenez le permis agricole."or g_i18n:getText(canManagePayroll and "agrilife_payroll6_status" or "agrilife_people6_readonly_payroll")))
end

function AgriLife.HomeFrame:onClickPayrollSelfTab() self.payrollSubview="self"; self:refreshPayroll() end
function AgriLife.HomeFrame:onClickPayrollTeamTab() if self:canManage("payroll.manage") then self.payrollSubview="team" end; self:refreshPayroll() end
function AgriLife.HomeFrame:selectPayrollRow(index) local row=self.payrollTeamRows[index]; if row~=nil then self.payrollSelectedProfileId=row.profileId end; self:refreshPayroll() end
function AgriLife.HomeFrame:onClickPayrollTeamRow1() self:selectPayrollRow(1) end
function AgriLife.HomeFrame:onClickPayrollTeamRow2() self:selectPayrollRow(2) end
function AgriLife.HomeFrame:onClickPayrollTeamRow3() self:selectPayrollRow(3) end
function AgriLife.HomeFrame:onClickPayrollTeamRow4() self:selectPayrollRow(4) end
function AgriLife.HomeFrame:onClickPayrollTeamRow5() self:selectPayrollRow(5) end
function AgriLife.HomeFrame:onClickPayrollTeamPrev() self.payrollTeamPage=math.max(1,(self.payrollTeamPage or 1)-1); self.payrollSelectedProfileId=nil; self:refreshPayroll() end
function AgriLife.HomeFrame:onClickPayrollTeamNext() self.payrollTeamPage=(self.payrollTeamPage or 1)+1; self.payrollSelectedProfileId=nil; self:refreshPayroll() end

function AgriLife.HomeFrame:recruitVirtualEmployee(role,contractType)
    local payroll=self:getPayrollModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0;local actor=self:getLocalPayrollProfileId(farmId)
    local result=payroll~=nil and payroll:recruitVirtualEmployee(farmId,actor,role,contractType,nil)or nil
    self.lastPayrollMessage=result~=nil and result.message or"Recrutement indisponible"
    if result~=nil and result.ok and result.details~=nil then self.payrollSelectedProfileId=result.details.profileId;self.payrollSubview="team" end
    self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollRecruitCDI() self:recruitVirtualEmployee("employee","CDI") end
function AgriLife.HomeFrame:onClickPayrollRecruitCDD() self:recruitVirtualEmployee("employee","CDD") end
function AgriLife.HomeFrame:onClickPayrollRecruitApprentice() self:recruitVirtualEmployee("apprentice","APPRENTICESHIP") end

function AgriLife.HomeFrame:getPayrollSelectedForAction()
    local payroll=self:getPayrollModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; local ps=payroll~=nil and payroll:getSnapshot(farmId) or nil
    return payroll,farmId,self:getSelectedPayrollEmployee(ps)
end
function AgriLife.HomeFrame:onClickPayrollSalaryAuto()
    local payroll,farmId,e=self:getPayrollSelectedForAction(); if payroll==nil or e==nil or not self:canManage("payroll.manage") then return end
    local r=payroll:setSalaryAuto(farmId,e.profileId); self.lastPayrollMessage=g_i18n:getText(r~=nil and r.ok and (r.code=="PAYROLL_ADMIN_REQUEST_SENT" and "agrilife_payroll6_admin_pending" or "agrilife_payroll6_admin_updated") or "agrilife_payroll6_admin_failed"); self:refreshPayroll()
end
function AgriLife.HomeFrame:adjustPayrollSalary(delta)
    local payroll,farmId,e=self:getPayrollSelectedForAction(); if payroll==nil or e==nil or not self:canManage("payroll.manage") then return end
    local amount=math.max(e.salaryMin or 0,math.min(e.salaryMax or 0,(e.monthlySalary or e.recommendedSalary or 0)+(tonumber(delta) or 0)))
    local r=payroll:setSalaryManual(farmId,e.profileId,amount); self.lastPayrollMessage=g_i18n:getText(r~=nil and r.ok and (r.code=="PAYROLL_ADMIN_REQUEST_SENT" and "agrilife_payroll6_admin_pending" or "agrilife_payroll6_admin_updated") or "agrilife_payroll6_admin_failed"); self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollSalaryDown() self:adjustPayrollSalary(-100) end
function AgriLife.HomeFrame:onClickPayrollSalaryUp() self:adjustPayrollSalary(100) end
function AgriLife.HomeFrame:onClickPayrollActive()
    local people=self:getPeopleModule(); local _,farmId,e=self:getPayrollSelectedForAction(); if people==nil or e==nil or not self:canManage("profiles.manage") then return end
    local r=people:setActive(farmId,e.profileId,e.active~=true); self.lastPayrollMessage=g_i18n:getText(r~=nil and r.ok and (r.code=="PEOPLE_ADMIN_REQUEST_SENT" and "agrilife_payroll6_admin_pending" or "agrilife_payroll6_admin_updated") or "agrilife_payroll6_admin_failed"); self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollTerminate()
    local payroll,farmId,e=self:getPayrollSelectedForAction(); if payroll==nil or e==nil or not self:canManage("payroll.manage") or not self:canManage("profiles.manage") then return end
    local status=tostring(e.employmentStatus or (e.active and "ACTIVE" or "SUSPENDED"))
    local r
    if status=="TERMINATED" then
        if (tonumber(e.salaryArrears) or 0)<=0.01 then return end
        r=payroll:settleOutstanding(farmId,e.profileId)
    else
        r=payroll:terminateEmployment(farmId,e.profileId)
    end
    local key="agrilife_payroll6_admin_failed"
    if r~=nil and r.ok then
        if r.code=="PAYROLL_ADMIN_REQUEST_SENT" then key="agrilife_payroll6_admin_pending"
        elseif r.code=="PAYROLL_EMPLOYMENT_TERMINATED_ARREARS" or r.code=="PAYROLL_SETTLEMENT_PARTIAL" then key="agrilife_payroll6_termination_arrears"
        elseif r.code=="PAYROLL_SETTLEMENT_PAID" then key="agrilife_payroll6_settlement_paid"
        else key="agrilife_payroll6_termination_done" end
    end
    self.lastPayrollMessage=g_i18n:getText(key); self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollOvertime()
    local payroll,farmId,e=self:getPayrollSelectedForAction();local actor=self:getLocalPayrollProfileId(farmId);local r=payroll~=nil and e~=nil and payroll:recordAttendance(farmId,actor,e.profileId,(tonumber(e.overtimeHours)or 0)+1,tonumber(e.absenceDays)or 0)or nil;self.lastPayrollMessage=r~=nil and r.message or"Aucun salarié sélectionné";self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollAbsence()
    local payroll,farmId,e=self:getPayrollSelectedForAction();local actor=self:getLocalPayrollProfileId(farmId);local r=payroll~=nil and e~=nil and payroll:recordAttendance(farmId,actor,e.profileId,tonumber(e.overtimeHours)or 0,(tonumber(e.absenceDays)or 0)+0.5)or nil;self.lastPayrollMessage=r~=nil and r.message or"Aucun salarié sélectionné";self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollSick()
    local payroll,farmId,e=self:getPayrollSelectedForAction();local actor=self:getLocalPayrollProfileId(farmId);local r=payroll~=nil and e~=nil and payroll:recordSickLeave(farmId,actor,e.profileId,1)or nil;self.lastPayrollMessage=r~=nil and r.message or"Aucun salarié sélectionné";self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollLeave()
    local payroll,farmId,e=self:getPayrollSelectedForAction();local r=payroll~=nil and e~=nil and payroll:requestLeave(farmId,e.profileId,2)or nil;self.lastPayrollMessage=r~=nil and r.message or"Aucun salarié sélectionné";self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollSettle()
    local payroll,farmId,e=self:getPayrollSelectedForAction();local r=payroll~=nil and e~=nil and payroll:settleOutstanding(farmId,e.profileId)or nil;self.lastPayrollMessage=r~=nil and r.message or"Aucun arriéré sélectionné";self:refreshPayroll()
end

function AgriLife.HomeFrame:cyclePayrollRole(direction)
    local people=self:getPeopleModule(); local _,farmId,e=self:getPayrollSelectedForAction(); if people==nil or e==nil or e.role=="owner" or not self:canManage("roles.manage") then return end
    local roles={"apprentice","employee","partner","manager"}; local idx=2; for i,r in ipairs(roles) do if r==e.role then idx=i; break end end; idx=((idx-1+(tonumber(direction) or 1))%#roles)+1
    local r=people:setRole(farmId,e.profileId,roles[idx]); self.lastPayrollMessage=g_i18n:getText(r~=nil and r.ok and (r.code=="PEOPLE_ADMIN_REQUEST_SENT" and "agrilife_payroll6_admin_pending" or "agrilife_payroll6_admin_updated") or "agrilife_payroll6_admin_failed"); self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickPayrollRolePrev() self:cyclePayrollRole(-1) end
function AgriLife.HomeFrame:onClickPayrollRoleNext() self:cyclePayrollRole(1) end
function AgriLife.HomeFrame:onPayrollAdminResult(result)
    local key="agrilife_payroll6_admin_failed"
    if result~=nil and result.success then
        if result.code=="PAYROLL_EMPLOYMENT_TERMINATED_ARREARS" or result.code=="PAYROLL_SETTLEMENT_PARTIAL" then key="agrilife_payroll6_termination_arrears"
        elseif result.code=="PAYROLL_SETTLEMENT_PAID" then key="agrilife_payroll6_settlement_paid"
        elseif result.code=="PAYROLL_EMPLOYMENT_TERMINATED" or result.code=="PAYROLL_EMPLOYMENT_ALREADY_TERMINATED" then key="agrilife_payroll6_termination_done"
        else key="agrilife_payroll6_admin_updated" end
    elseif result~=nil and result.code=="PAYROLL_SALARY_OUT_OF_RANGE" then key="agrilife_payroll6_salary_out_of_range" end
    self.lastPayrollMessage=g_i18n:getText(key)
    local payroll=self:getPayrollModule(); local people=self:getPeopleModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if payroll~=nil and payroll.requestSnapshot~=nil then payroll:requestSnapshot(farmId) end
    if people~=nil and people.requestSnapshot~=nil then people:requestSnapshot(farmId) end
    self:refreshPayroll()
end

function AgriLife.HomeFrame:onPeopleAdminResult(result)
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    local people=self:getPeopleModule(); local payroll=self:getPayrollModule()
    if people~=nil and people.requestSnapshot~=nil then people:requestSnapshot(farmId) end
    if payroll~=nil and payroll.requestSnapshot~=nil then payroll:requestSnapshot(farmId) end
    if self.activePage=="payroll" then self.lastPayrollMessage=g_i18n:getText(result~=nil and result.success and "agrilife_payroll6_admin_updated" or "agrilife_payroll6_admin_failed") end
    self:refresh()
end

function AgriLife.HomeFrame:cycleLegalForm(direction)
    local company=self:getCompanyModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if company==nil or company.service==nil or farmId<=0 then return end
    if not self:canManage("company.manage") then
        self.lastPayrollMessage = g_i18n:getText("agrilife_people6_readonly_payroll")
        self:refreshPayroll()
        return
    end
    local forms=company:getLegalForms() or {}; if #forms==0 then return end
    self.legalFormIndex=((self.legalFormIndex-1+direction)%#forms)+1
    local current=company:getSnapshot(farmId); local form=forms[self.legalFormIndex]
    local result=company:setIdentity(farmId,current~=nil and current.companyName or "Exploitation agricole",form.id)
    if result~=nil and result.ok then
        self.lastPayrollMessage=g_i18n:getText(result.code=="COMPANY_IDENTITY_REQUEST_SENT" and "agrilife_company6_form_pending" or "agrilife_company6_form_changed")
    else
        self.lastPayrollMessage=g_i18n:getText("agrilife_company6_form_change_failed")
    end
    self:refreshPayroll()
end
function AgriLife.HomeFrame:onCompanyIdentityResult(result)
    local success=result~=nil and result.success
    self.lastPayrollMessage=g_i18n:getText(success and "agrilife_company6_form_changed" or "agrilife_company6_form_change_failed")
    self.lastCompanyMessage=success and "Forme juridique mise à jour" or ("Forme juridique incompatible avec le nombre de membres ("..tostring(result~=nil and result.code or "erreur")..")")
    self:refreshPayroll()
end
function AgriLife.HomeFrame:onClickLegalFormPrev() self:cycleLegalForm(-1) end
function AgriLife.HomeFrame:onClickLegalFormNext() self:cycleLegalForm(1) end

function AgriLife.HomeFrame:refreshContracts()
    local module=self:getContractsModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    if module==nil or farmId<=0 then setText(self.contractsStatusText,g_i18n:getText("agrilife_contracts6_unavailable")); setDisabled(self.contractsAcceptButton,true); return end
    local snapshot=module:getSnapshot(farmId)
    local canManageContracts=self:canManage("contracts.manage")
    setText(self.contractsStationCount,tostring(snapshot~=nil and snapshot.stationCount or 0)); setText(self.contractsOfferCount,tostring(snapshot~=nil and snapshot.opportunityCount or 0)); setText(self.contractsActiveCount,tostring(snapshot~=nil and snapshot.activeContracts or 0)); setText(self.contractsCompletedCount,tostring(snapshot~=nil and snapshot.completedContracts or 0))
    local r=module:buildOpportunities(farmId); self.contractOffers=(r~=nil and r.ok and r.details~=nil and r.details.offers) or {}
    if #self.contractOffers==0 then self.contractOfferIndex=1; setText(self.contractsOfferIndex,"0 / 0"); setText(self.contractsOfferStation,"--"); setText(self.contractsOfferGoods,"--"); setText(self.contractsOfferTerms,"--"); setText(self.contractsOfferPrice,"--"); setDisabled(self.contractsAcceptButton,true); setText(self.contractsStatusText,self.lastContractsMessage or g_i18n:getText("agrilife_contracts6_no_offer")); return end
    self.contractOfferIndex=math.max(1,math.min(#self.contractOffers,self.contractOfferIndex)); local o=self.contractOffers[self.contractOfferIndex]
    setText(self.contractsOfferIndex,string.format("%d / %d",self.contractOfferIndex,#self.contractOffers)); setText(self.contractsOfferStation,o.stationName or "--"); setText(self.contractsOfferGoods,o.fillTypeTitle or o.fillTypeName or "--")
    setText(self.contractsOfferTerms,string.format(g_i18n:getText("agrilife_contracts6_terms_format"),formatNumber((o.volumeLiters or 0)/1000,1),o.durationMonths or 0)); setText(self.contractsOfferPrice,string.format(g_i18n:getText("agrilife_contracts6_price_format"),formatMoney((o.contractPrice or 0)*1000),formatPercent(o.premium or 0)))
    setDisabled(self.contractsAcceptButton,not canManageContracts)
    local defaultStatus=g_i18n:getText(canManageContracts and "agrilife_contracts6_status" or "agrilife_people6_readonly_contracts")
    if snapshot~=nil and (snapshot.penaltyDue or 0)>0.01 then defaultStatus=string.format(g_i18n:getText("agrilife_contracts6_penalty_due"),formatMoney(snapshot.penaltyDue),snapshot.failedContracts or 0) end
    setText(self.contractsStatusText,self.lastContractsMessage or defaultStatus)
end
function AgriLife.HomeFrame:cycleContractOffer(direction) if #self.contractOffers==0 then return end; self.contractOfferIndex=((self.contractOfferIndex-1+direction)%#self.contractOffers)+1; self.lastContractsMessage=nil; self:refreshContracts() end
function AgriLife.HomeFrame:onClickContractPrev() self:cycleContractOffer(-1) end
function AgriLife.HomeFrame:onClickContractNext() self:cycleContractOffer(1) end
function AgriLife.HomeFrame:onClickContractAccept()
    local module=self:getContractsModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; local offer=self.contractOffers[self.contractOfferIndex]
    if not self:canManage("contracts.manage") then
        self.lastContractsMessage = g_i18n:getText("agrilife_people6_readonly_contracts")
        self:refreshContracts()
        return
    end
    if module==nil or offer==nil then return end
    local result=module:acceptOffer(farmId,offer)
    if result~=nil and result.ok then self.lastContractsMessage=g_i18n:getText(result.code=="CONTRACTS_ACCEPT_REQUEST_SENT" and "agrilife_contracts6_pending" or "agrilife_contracts6_accepted") else self.lastContractsMessage=g_i18n:getText("agrilife_contracts6_failed") end
    self:refreshContracts()
end
function AgriLife.HomeFrame:onContractsActionResult(result)
    self.lastContractsMessage=g_i18n:getText(result~=nil and result.success and "agrilife_contracts6_accepted" or "agrilife_contracts6_failed")
    self:refreshContracts()
end

function AgriLife.HomeFrame:getExamResultText(code)
    local keys = {
        EXAM_STARTED = "agrilife_exam6_result_started",
        EXAM_CANCELLED = "agrilife_exam6_result_cancelled",
        EXAM_ALREADY_RUNNING = "agrilife_exam6_result_alreadyRunning",
        EXAM_LICENCE_ALREADY_OBTAINED = "agrilife_exam6_result_alreadyLicensed",
        EXAM_HUD_UNAVAILABLE = "agrilife_exam6_result_hud",
        EXAM_HUD_CONTENT_FAILED = "agrilife_exam6_result_hud",
        EXAM_NO_FEASIBLE_SCENARIO = "agrilife_exam6_result_equipment",
        EXAM_FUNDS_INSUFFICIENT = "agrilife_exam6_result_funds",
        PAYROLL_PERSONAL_FUNDS_INSUFFICIENT = "agrilife_exam6_result_funds",
        EXAM_PERSONAL_ACCOUNT_UNAVAILABLE = "agrilife_exam6_result_personalAccount",
        EXAM_CATALOG_TOO_SMALL = "agrilife_exam6_result_catalog",
        EXAM_MODULE_NOT_READY = "agrilife_exam6_result_unavailable"
    }
    return g_i18n:getText(keys[code] or "agrilife_exam6_result_failed")
end

function AgriLife.HomeFrame:formatExamTaskText(task, key)
    if task == nil then return "--" end
    local template = g_i18n:getText(key)
    local scenario = g_i18n:getText(task.scenarioLabelKey)
    local ok, value = pcall(string.format, template, scenario)
    return ok and value or (tostring(template) .. " - " .. tostring(scenario))
end

function AgriLife.HomeFrame:onClickExamAction()
    local exam = self:getExamModule()
    if exam == nil then
        self.lastExamMessage = g_i18n:getText("agrilife_exam6_result_unavailable")
        self:refreshExam()
        return
    end
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local snapshot = exam:getSnapshot(farmId)
    local result
    if snapshot ~= nil and snapshot.examRunning then
        result = exam:cancelExam(farmId)
    elseif snapshot ~= nil and snapshot.licenceStatus == "obtained" then
        self.lastExamMessage = g_i18n:getText("agrilife_exam6_result_alreadyLicensed")
        self:refreshExam()
        return
    else
        result = exam:startExam(farmId)
    end
    self.lastExamMessage = self:getExamResultText(result ~= nil and result.code or "EXAM_UNKNOWN")
    self:refreshExam()
end

function AgriLife.HomeFrame:onClickExamCertification()
    local exam=self:getExamModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0
    local result=exam~=nil and exam.requestNextCertification~=nil and exam:requestNextCertification(farmId) or nil
    self.lastExamMessage=result~=nil and result.message or "Certification indisponible"; self:refreshExam()
end

function AgriLife.HomeFrame:setExamSubview(view)
    self.examSubview = view == "team" and "team" or "self"
    local own = self.examSubview == "self"
    setVisible(self.examSelfSummaryPanel, own)
    setVisible(self.examSelfTaskPanel, own)
    setVisible(self.examSelfStatusPanel, own)
    setVisible(self.examTeamPanel, not own)
    setDisabled(self.examSelfTabButton, own)
    setDisabled(self.examTeamTabButton, not own)
    self:refreshExam()
end

function AgriLife.HomeFrame:setCareerSubview(view)
    self.careerSubview = view == "team" and "team" or "self"
    local own = self.careerSubview == "self"
    setVisible(self.careerSelfSummaryPanel, own)
    setVisible(self.careerSelfStatsPanel, own)
    setVisible(self.careerSelfSpecialtiesPanel, own)
    setVisible(self.xpStatusText, own)
    setVisible(self.careerTeamPanel, not own)
    setDisabled(self.careerSelfTabButton, own)
    setDisabled(self.careerTeamTabButton, not own)
    self:refreshCareer()
end

function AgriLife.HomeFrame:onClickExamSelfTab() self:setExamSubview("self") end
function AgriLife.HomeFrame:onClickExamTeamTab() self:setExamSubview("team") end
function AgriLife.HomeFrame:onClickExamHudVisible()local exam=self:getExamModule();local result=exam~=nil and exam:toggleHudVisible()or nil;self.lastExamMessage=result~=nil and result.message or"Réglage HUD indisponible";self:refreshExam()end
function AgriLife.HomeFrame:onClickExamHudLock()local exam=self:getExamModule();local result=exam~=nil and exam:toggleHudLocked()or nil;self.lastExamMessage=result~=nil and result.message or"Réglage HUD indisponible";self:refreshExam()end
function AgriLife.HomeFrame:onClickExamHudPosition()local exam=self:getExamModule();local result=exam~=nil and exam:cycleHudPosition()or nil;self.lastExamMessage=result~=nil and result.message or"Réglage HUD indisponible";self:refreshExam()end
function AgriLife.HomeFrame:onClickCareerSelfTab() self:setCareerSubview("self") end
function AgriLife.HomeFrame:onClickCareerTeamTab() self:setCareerSubview("team") end

function AgriLife.HomeFrame:getPeopleProfiles(farmId)
    local people = self:getPeopleModule()
    local snapshot = people ~= nil and people.getSnapshot ~= nil and people:getSnapshot(farmId) or nil
    return snapshot ~= nil and snapshot.profiles or {}
end

function AgriLife.HomeFrame:getSnapshotMap(list)
    local result = {}
    for _, snapshot in ipairs(list or {}) do
        if snapshot.profileId ~= nil then result[tostring(snapshot.profileId)] = snapshot end
    end
    return result
end

function AgriLife.HomeFrame:formatPeoplePresence(profile)
    if profile ~= nil and profile.connected == true then return g_i18n:getText("agrilife_people6_connected") end
    local day = profile ~= nil and tonumber(profile.lastSeenDay) or 0
    if day ~= nil and day > 0 then return string.format(g_i18n:getText("agrilife_people6_last_seen_day"), day) end
    return g_i18n:getText("agrilife_people6_offline")
end

function AgriLife.HomeFrame:refreshCareerTeam()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local career = self:getCareerModule()
    local profiles = self:getPeopleProfiles(farmId)
    local careerMap = self:getSnapshotMap(career ~= nil and career.getTeamSnapshots ~= nil and career:getTeamSnapshots(farmId) or {})
    local pages = math.max(1, math.ceil(#profiles / 5))
    self.careerTeamPage = math.max(1, math.min(pages, tonumber(self.careerTeamPage) or 1))
    self.careerTeamRows = {}
    local first = (self.careerTeamPage - 1) * 5 + 1
    for row = 1, 5 do
        local profile = profiles[first + row - 1]
        local button = self["careerTeamRow" .. tostring(row)]
        if profile == nil then
            setText(button, "--")
            setDisabled(button, true)
        else
            local snapshot = careerMap[tostring(profile.profileId)]
            local role = g_i18n:getText(profile.roleLabelKey or ("agrilife_people6_role_" .. tostring(profile.role or "employee")))
            local presence = self:formatPeoplePresence(profile)
            local line
            if snapshot ~= nil then
                line = string.format("%s   |   %s   |   Niv. %d   |   %s XP   |   Rép. %d/100   |   %s", tostring(profile.displayName or "Joueur"), role, snapshot.level or 1, formatNumber(snapshot.totalXP, 0), snapshot.reputation or 50, presence)
            else
                line = string.format("%s   |   %s   |   --   |   %s", tostring(profile.displayName or "Joueur"), role, presence)
            end
            setText(button, line)
            setDisabled(button, false)
            self.careerTeamRows[row] = profile
        end
    end
    setText(self.careerTeamPageValue, string.format("%d / %d", self.careerTeamPage, pages))
    setDisabled(self.careerTeamPrevButton, self.careerTeamPage <= 1)
    setDisabled(self.careerTeamNextButton, self.careerTeamPage >= pages)
    local selected = nil
    for _, p in ipairs(profiles) do if tostring(p.profileId) == tostring(self.careerSelectedProfileId) then selected = p; break end end
    setText(self.careerTeamSelectionText, selected ~= nil and string.format(g_i18n:getText("agrilife_people6_selected_profile"), selected.displayName or "Joueur") or g_i18n:getText("agrilife_people6_select_profile"))
    setDisabled(self.careerTeamDeleteButton, selected == nil or selected.canDelete ~= true or not self:canManage("profiles.manage"))
end

function AgriLife.HomeFrame:refreshExamTeam()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    local exam = self:getExamModule()
    local profiles = self:getPeopleProfiles(farmId)
    local examMap = self:getSnapshotMap(exam ~= nil and exam.getTeamSnapshots ~= nil and exam:getTeamSnapshots(farmId) or {})
    local pages = math.max(1, math.ceil(#profiles / 5))
    self.examTeamPage = math.max(1, math.min(pages, tonumber(self.examTeamPage) or 1))
    self.examTeamRows = {}
    local first = (self.examTeamPage - 1) * 5 + 1
    for row = 1, 5 do
        local profile = profiles[first + row - 1]
        local button = self["examTeamRow" .. tostring(row)]
        if profile == nil then
            setText(button, "--")
            setDisabled(button, true)
        else
            local snapshot = examMap[tostring(profile.profileId)]
            local role = g_i18n:getText(profile.roleLabelKey or ("agrilife_people6_role_" .. tostring(profile.role or "employee")))
            local presence = self:formatPeoplePresence(profile)
            local line
            if snapshot ~= nil then
                local licence = g_i18n:getText("agrilife_licence_status_" .. tostring(snapshot.licenceStatus or "notObtained"))
                line = string.format("%s   |   %s   |   %s   |   %d réussites   |   %d/100   |   %s", tostring(profile.displayName or "Joueur"), role, licence, snapshot.passes or 0, snapshot.bestScore or 0, presence)
            else
                line = string.format("%s   |   %s   |   --   |   %s", tostring(profile.displayName or "Joueur"), role, presence)
            end
            setText(button, line)
            setDisabled(button, false)
            self.examTeamRows[row] = profile
        end
    end
    setText(self.examTeamPageValue, string.format("%d / %d", self.examTeamPage, pages))
    setDisabled(self.examTeamPrevButton, self.examTeamPage <= 1)
    setDisabled(self.examTeamNextButton, self.examTeamPage >= pages)
    local selected = nil
    for _, p in ipairs(profiles) do if tostring(p.profileId) == tostring(self.examSelectedProfileId) then selected = p; break end end
    setText(self.examTeamSelectionText, selected ~= nil and string.format(g_i18n:getText("agrilife_people6_selected_profile"), selected.displayName or "Joueur") or g_i18n:getText("agrilife_people6_select_profile"))
    setDisabled(self.examTeamDeleteButton, selected == nil or selected.canDelete ~= true or not self:canManage("profiles.manage"))
end

function AgriLife.HomeFrame:selectCareerTeamRow(row)
    local profile = self.careerTeamRows ~= nil and self.careerTeamRows[row] or nil
    self.careerSelectedProfileId = profile ~= nil and profile.profileId or nil
    self:refreshCareerTeam()
end
function AgriLife.HomeFrame:selectExamTeamRow(row)
    local profile = self.examTeamRows ~= nil and self.examTeamRows[row] or nil
    self.examSelectedProfileId = profile ~= nil and profile.profileId or nil
    self:refreshExamTeam()
end
function AgriLife.HomeFrame:onClickCareerTeamRow1() self:selectCareerTeamRow(1) end
function AgriLife.HomeFrame:onClickCareerTeamRow2() self:selectCareerTeamRow(2) end
function AgriLife.HomeFrame:onClickCareerTeamRow3() self:selectCareerTeamRow(3) end
function AgriLife.HomeFrame:onClickCareerTeamRow4() self:selectCareerTeamRow(4) end
function AgriLife.HomeFrame:onClickCareerTeamRow5() self:selectCareerTeamRow(5) end
function AgriLife.HomeFrame:onClickExamTeamRow1() self:selectExamTeamRow(1) end
function AgriLife.HomeFrame:onClickExamTeamRow2() self:selectExamTeamRow(2) end
function AgriLife.HomeFrame:onClickExamTeamRow3() self:selectExamTeamRow(3) end
function AgriLife.HomeFrame:onClickExamTeamRow4() self:selectExamTeamRow(4) end
function AgriLife.HomeFrame:onClickExamTeamRow5() self:selectExamTeamRow(5) end
function AgriLife.HomeFrame:onClickCareerTeamPrev() self.careerTeamPage = math.max(1,(self.careerTeamPage or 1)-1); self:refreshCareerTeam() end
function AgriLife.HomeFrame:onClickCareerTeamNext() self.careerTeamPage = (self.careerTeamPage or 1)+1; self:refreshCareerTeam() end
function AgriLife.HomeFrame:onClickExamTeamPrev() self.examTeamPage = math.max(1,(self.examTeamPage or 1)-1); self:refreshExamTeam() end
function AgriLife.HomeFrame:onClickExamTeamNext() self.examTeamPage = (self.examTeamPage or 1)+1; self:refreshExamTeam() end

function AgriLife.HomeFrame:confirmProfileDeletion(profileId, source)
    local people = self:getPeopleModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    if people == nil or not self:canManage("profiles.manage") or profileId == nil then return end
    local target = nil
    for _, p in ipairs(self:getPeopleProfiles(farmId)) do if tostring(p.profileId) == tostring(profileId) then target = p; break end end
    if target == nil or target.canDelete ~= true then
        if source == "career" then setText(self.careerTeamSelectionText, g_i18n:getText("agrilife_people6_delete_denied")) else setText(self.examTeamSelectionText, g_i18n:getText("agrilife_people6_delete_denied")) end
        return
    end
    local function performDelete()
        local result = people:deleteProfile(farmId, profileId)
        local message = result ~= nil and result.ok and g_i18n:getText("agrilife_people6_delete_requested") or g_i18n:getText("agrilife_people6_delete_failed")
        if source == "career" then self.careerSelectedProfileId=nil; setText(self.careerTeamSelectionText,message) else self.examSelectedProfileId=nil; setText(self.examTeamSelectionText,message) end
        if people.requestSnapshot ~= nil then people:requestSnapshot(farmId) end
        local career=self:getCareerModule(); if career~=nil and career.requestSnapshot~=nil then career:requestSnapshot(farmId) end
        local exam=self:getExamModule(); if exam~=nil and exam.requestSnapshot~=nil then exam:requestSnapshot(farmId) end
    end
    local message = string.format(g_i18n:getText("agrilife_people6_delete_confirm"), target.displayName or "Joueur")
    if YesNoDialog ~= nil and YesNoDialog.show ~= nil then
        YesNoDialog.show(function(_, confirmed) if confirmed == true then performDelete() end end, self, message, g_i18n:getText("agrilife_people6_delete_title"))
    else
        if source == "career" then setText(self.careerTeamSelectionText,g_i18n:getText("agrilife_people6_confirmation_unavailable")) else setText(self.examTeamSelectionText,g_i18n:getText("agrilife_people6_confirmation_unavailable")) end
    end
end
function AgriLife.HomeFrame:onClickCareerTeamDelete() self:confirmProfileDeletion(self.careerSelectedProfileId,"career") end
function AgriLife.HomeFrame:onClickExamTeamDelete() self:confirmProfileDeletion(self.examSelectedProfileId,"exam") end

function AgriLife.HomeFrame:refreshExam()
    local exam = self:getExamModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    if self.examSubview == "team" then
        self:refreshExamTeam()
        return
    end
    if exam == nil or farmId <= 0 then
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_result_unavailable"))
        setDisabled(self.examActionButton, true)
        return
    end

    local snapshot = exam:getSnapshot(farmId)
    if snapshot == nil then
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_result_unavailable"))
        setDisabled(self.examActionButton, true)
        return
    end

    local settings=self.core~=nil and self.core.settings or nil;local hudVisible=settings==nil or settings.examHudVisible~=false;local hudLocked=settings==nil or settings.examHudLocked~=false
    if self.examHudVisibleButton~=nil and self.examHudVisibleButton.setText~=nil then self.examHudVisibleButton:setText(hudVisible and"HUD : AFFICHÉ"or"HUD : MASQUÉ")end
    if self.examHudLockButton~=nil and self.examHudLockButton.setText~=nil then self.examHudLockButton:setText(hudLocked and"HUD : VERROUILLÉ"or"HUD : LIBRE")end
    setDisabled(self.examHudPositionButton,hudLocked)

    local licenceObtained = snapshot.licenceStatus == "obtained"
    setText(self.examCertificationValue,string.format("%d / %d certificats",snapshot.certificationCount or 0,#(AgriLife.Exam6Service.CERTIFICATIONS or {})))
    local eligibility=exam.service~=nil and exam.service.getCertificationEligibility~=nil and exam.service:getCertificationEligibility(farmId,self:getLocalPayrollProfileId(farmId)) or {}
    setDisabled(self.examCertificationButton,not licenceObtained or #eligibility==0)
    setText(self.examLicenseValue, g_i18n:getText("agrilife_licence_status_" .. tostring(snapshot.licenceStatus or "notObtained")))
    setText(self.examStateValue, snapshot.examRunning and g_i18n:getText("agrilife_exam6_state_running") or g_i18n:getText(licenceObtained and "agrilife_exam6_state_licensed" or "agrilife_exam6_state_ready"))
    setText(self.examAttemptsValue, snapshot.attempts or 0)
    setText(self.examBestScoreValue, string.format("%d/100", snapshot.bestScore or 0))
    setText(self.examCatalogValue, string.format("%d / 100+", snapshot.catalogCount or 0))
    setText(self.examFeeValue, licenceObtained and "--" or formatMoney(snapshot.fee or 0))
    setVisible(self.examActionButton, not licenceObtained)

    if licenceObtained then
        setText(self.examTaskTitle, g_i18n:getText("agrilife_exam6_licence_title"))
        setText(self.examScenarioValue, string.format(g_i18n:getText("agrilife_exam6_licence_number_format"), tostring(snapshot.licenceNumber or "--")))
        local resultScore = tonumber(snapshot.lastResultScore) or tonumber(snapshot.bestScore) or tonumber(snapshot.score) or 0
        setText(self.examObjectiveValue, string.format(g_i18n:getText("agrilife_exam6_licence_score_format"), resultScore))
        local historyCount = tonumber(snapshot.attemptHistoryCount) or tonumber(snapshot.historyCount) or 0
        local attemptText = string.format(g_i18n:getText("agrilife_exam6_licence_attempts_format"), tonumber(snapshot.attempts) or 0, tonumber(snapshot.passes) or 0)
        setText(self.examCriterionValue, string.format("%s | %s", attemptText, string.format(g_i18n:getText("agrilife_career5_exam_history_fmt"), historyCount)))
        setText(self.examProgressValue, g_i18n:getText("agrilife_exam6_licence_progress"))
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_licence_status"))
        setDisabled(self.examActionButton, true)
        return
    end

    local task = snapshot.currentTask
    if snapshot.examRunning and task ~= nil then
        setText(self.examTaskTitle, string.format(g_i18n:getText("agrilife_exam6_task_format"), snapshot.currentIndex or 1, 10))
        setText(self.examScenarioValue, string.format("%s: %s", g_i18n:getText("agrilife_exam6_scenario"), g_i18n:getText(task.scenarioLabelKey)))
        setText(self.examObjectiveValue, self:formatExamTaskText(task, task.objectiveKey))
        setText(self.examCriterionValue, self:formatExamTaskText(task, task.criterionKey))
        setText(self.examProgressValue, string.format("%s: %d%%   |   %s: %d/100   |   %s: %d", g_i18n:getText("agrilife_exam6_progress"), snapshot.progress or 0, g_i18n:getText("agrilife_exam6_score"), snapshot.score or 100, g_i18n:getText("agrilife_exam6_errors"), snapshot.errors or 0))
        if self.examActionButton ~= nil and self.examActionButton.setText ~= nil then self.examActionButton:setText(g_i18n:getText("agrilife_exam6_cancel")) end
    else
        setText(self.examTaskTitle, g_i18n:getText("agrilife_exam6_ready_title"))
        setText(self.examScenarioValue, g_i18n:getText("agrilife_exam6_ready_scenario"))
        setText(self.examObjectiveValue, g_i18n:getText("agrilife_exam6_ready_objective"))
        setText(self.examCriterionValue, g_i18n:getText("agrilife_exam6_ready_criterion"))
        setText(self.examProgressValue, string.format(g_i18n:getText("agrilife_exam6_history_format"), snapshot.historyCount or 0))
        if self.examActionButton ~= nil and self.examActionButton.setText ~= nil then self.examActionButton:setText(g_i18n:getText("agrilife_exam6_start")) end
    end
    local hasFunds=true
    if not snapshot.examRunning then
        local payroll=self:getPayrollModule()
        local profileId=self:getLocalPayrollProfileId(farmId)
        local ps=payroll~=nil and payroll.getViewerSnapshot~=nil and payroll:getViewerSnapshot(farmId,profileId,false) or (payroll~=nil and payroll.getSnapshot~=nil and payroll:getSnapshot(farmId) or nil)
        local personalBalance=0
        if ps~=nil then
            for _,employee in ipairs(ps.employees or {}) do
                if tostring(employee.profileId or "")==tostring(profileId or "") then personalBalance=tonumber(employee.personalBalance) or 0; break end
            end
        end
        hasFunds=personalBalance+0.01 >= (tonumber(snapshot.fee) or 0)
    end
    if not hasFunds then
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_result_funds"))
    elseif snapshot.examRunning and snapshot.lastErrorCode=="EXAM_DAMAGE_PENALTY" then
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_damage_penalty"))
    elseif snapshot.examRunning and snapshot.lastErrorCode=="EXAM_WRONG_FIELD_PENALTY" then
        setText(self.examStatusText, g_i18n:getText("agrilife_exam6_wrong_field_penalty"))
    else
        setText(self.examStatusText, self.lastExamMessage or g_i18n:getText("agrilife_exam6_status_hint"))
    end
    setDisabled(self.examActionButton, (not snapshot.examRunning) and (not hasFunds))
end

function AgriLife.HomeFrame:refreshCareer()
    local career = self:getCareerModule()
    local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    if self.careerSubview == "team" then
        self:refreshCareerTeam()
        return
    end
    if career == nil or farmId <= 0 then
        setText(self.xpStatusText, g_i18n:getText("agrilife_career6_unavailable"))
        return
    end

    local snapshot = career:getSnapshot(farmId)
    if snapshot == nil then
        setText(self.xpStatusText, g_i18n:getText("agrilife_career6_unavailable"))
        return
    end

    setText(self.xpLevelValue, string.format("%d - %s", snapshot.level or 1, g_i18n:getText(snapshot.levelTitleKey or "agrilife_career6_title_beginner")))
    setText(self.xpTotalValue, formatNumber(snapshot.totalXP, 0) .. " XP")
    setText(self.xpProgressValue, string.format("%d%%", snapshot.levelProgress or 0))
    setText(self.xpReputationValue, string.format("%d/100", snapshot.reputation or 0))

    local stats = snapshot.stats or {}
    setText(self.xpHoursValue, string.format(g_i18n:getText("agrilife_career6_hours_format"), formatNumber(stats.workHours, 1)))
    setText(self.xpDistanceValue, string.format(g_i18n:getText("agrilife_career6_km_format"), formatNumber(stats.distanceKm, 1)))
    setText(self.xpAreaValue, string.format(g_i18n:getText("agrilife_career6_ha_format"), formatNumber(stats.areaHa, 1)))
    setText(self.xpHarvestValue, string.format(g_i18n:getText("agrilife_career6_ha_format"), formatNumber(stats.harvestedHa, 1)))
    setText(self.xpTransportValue, string.format(g_i18n:getText("agrilife_career6_tonnes_format"), formatNumber(stats.transportedTonnes, 1)))
    setText(self.xpMaintenanceValue, string.format("%d / %d", stats.diagnostics or 0, stats.repairs or 0))
    setText(self.xpExamsValue, string.format("%d / %d", stats.examsPassed or 0, stats.examsFailed or 0))

    for index, specialty in ipairs(snapshot.specialties or {}) do
        local label = self["xpSpec" .. tostring(index) .. "Label"]
        local value = self["xpSpec" .. tostring(index) .. "Value"]
        setText(label, g_i18n:getText(specialty.labelKey))
        local nextText = specialty.nextStarXP ~= nil and string.format(g_i18n:getText("agrilife_career6_specialty_progress"), specialty.xp or 0, specialty.nextStarXP) or g_i18n:getText("agrilife_career6_specialty_max")
        setText(value, string.format("%s   %s", formatStars(specialty.stars), nextText))
    end

    local record = snapshot.careerRecord or {}
    local milestones = #(record.milestones or {})
    local summary = string.format(g_i18n:getText("agrilife_career5_record_fmt"),
        tonumber(record.contractsCompleted) or 0, tonumber(record.contractsFailed) or 0,
        tonumber(record.incidents) or 0, tonumber(record.qualificationsEarned) or 0,
        milestones, tonumber(snapshot.xpMultiplier) or 1)
    setText(self.xpStatusText, summary)
end

local INSURANCE_CATEGORY_LABELS={vehicle="Matériel et véhicules",building="Bâtiments",crop="Cultures",livestock="Animaux",liability="Responsabilité civile",transport="Transport"}
local INSURANCE_LIABILITY_L10N={UNKNOWN="agrilife_insurance8_liability_unknown",NOT_RESPONSIBLE="agrilife_insurance8_liability_not_responsible",RESPONSIBLE="agrilife_insurance8_liability_responsible",SHARED="agrilife_insurance8_liability_shared"}

function AgriLife.HomeFrame:getInsuranceSelection()
    local category=self.insuranceCategories[self.insuranceCategoryIndex] or "vehicle"
    local tierId=AgriLife.Insurance6Service~=nil and AgriLife.Insurance6Service.TIER_ORDER[self.insuranceTierIndex] or "standard"
    local value=self.insuranceValues[self.insuranceValueIndex] or 100000
    return category,tierId,value
end

function AgriLife.HomeFrame:onClickInsuranceCategory() self.insuranceCategoryIndex=(self.insuranceCategoryIndex % #self.insuranceCategories)+1; self.lastInsuranceMessage=nil; self:refreshInsurance() end
function AgriLife.HomeFrame:onClickInsuranceTier() self.insuranceTierIndex=(self.insuranceTierIndex % #AgriLife.Insurance6Service.TIER_ORDER)+1; self.lastInsuranceMessage=nil; self:refreshInsurance() end
function AgriLife.HomeFrame:onClickInsuranceValue() self.insuranceValueIndex=(self.insuranceValueIndex % #self.insuranceValues)+1; self.lastInsuranceMessage=nil; self:refreshInsurance() end
function AgriLife.HomeFrame:onClickInsuranceBuy()
    local module=self:getInsuranceModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; if module==nil or not self:canManage("insurance.manage") then return end
    local category,tier,value=self:getInsuranceSelection(); local result=module:buyPolicy(farmId,category,category.."_portfolio",INSURANCE_CATEGORY_LABELS[category],value,tier,0.35)
    self.lastInsuranceMessage=result~=nil and result.message or "Souscription indisponible"; self:refreshInsurance()
end

function AgriLife.HomeFrame:getSelectedInsurancePolicy(snapshot)
    local policies=snapshot~=nil and snapshot.policies or{};if#policies==0 then return nil end;self.insurancePolicyIndex=((self.insurancePolicyIndex-1)%#policies)+1;return policies[self.insurancePolicyIndex]
end
function AgriLife.HomeFrame:getSelectedInsuranceClaim(snapshot)
    local claims=snapshot~=nil and snapshot.claims or{};if#claims==0 then return nil end;self.insuranceClaimIndex=((self.insuranceClaimIndex-1)%#claims)+1;return claims[self.insuranceClaimIndex]
end
function AgriLife.HomeFrame:onClickInsurancePolicyNext()local module=self:getInsuranceModule();local snapshot=module~=nil and module:getSnapshot(self.core.context:getFarmId())or nil;local n=snapshot~=nil and#(snapshot.policies or{})or 0;if n>0 then self.insurancePolicyIndex=self.insurancePolicyIndex%n+1 end;self:refreshInsurance()end
function AgriLife.HomeFrame:onClickInsuranceClaimNext()local module=self:getInsuranceModule();local snapshot=module~=nil and module:getSnapshot(self.core.context:getFarmId())or nil;local n=snapshot~=nil and#(snapshot.claims or{})or 0;if n>0 then self.insuranceClaimIndex=self.insuranceClaimIndex%n+1 end;self:refreshInsurance()end
function AgriLife.HomeFrame:onClickInsuranceCancel()
    if not self:canManage("insurance.manage")then return end;local module=self:getInsuranceModule();local farmId=self.core.context:getFarmId();local snapshot=module~=nil and module:getSnapshot(farmId)or nil;local policy=self:getSelectedInsurancePolicy(snapshot);local result=nil
    if policy~=nil and policy.status=="suspended" then result=module:reactivatePolicy(farmId,policy.id) elseif policy~=nil then result=module:cancelPolicy(farmId,policy.id) end
    self.lastInsuranceMessage=result~=nil and result.message or"Aucun contrat à gérer";self:refreshInsurance()
end
function AgriLife.HomeFrame:onClickInsuranceFileClaim()
    if not self:canManage("insurance.manage")then return end
    local module=self:getInsuranceModule();local farmId=self.core.context:getFarmId();local snapshot=module~=nil and module:getSnapshot(farmId)or nil;local policy=self:getSelectedInsurancePolicy(snapshot);local result=nil
    if policy~=nil and policy.status=="active" then
        local damage=math.max(1000,math.min(75000,(tonumber(policy.insuredValue)or 0)*0.08))
        local economy=self:getEconomyModule();local owner=economy~=nil and economy.service~=nil and economy.service:getOwnerProfileId(farmId)or""
        result=module:fileClaim(farmId,policy.id,damage,"déclaration "..tostring(policy.category or"dommage"),owner,policy.assetId)
    end
    self.lastInsuranceMessage=result~=nil and result.message or"Sélectionnez un contrat actif";self:refreshInsurance()
end
function AgriLife.HomeFrame:onClickInsuranceAssess()
    if not self:canManage("insurance.manage")then return end
    local module=self:getInsuranceModule();local farmId=self.core.context:getFarmId();local snapshot=module~=nil and module:getSnapshot(farmId)or nil;local claim=self:getSelectedInsuranceClaim(snapshot);local result=nil
    if claim~=nil and claim.requiresLiability==true and tostring(claim.liabilityStatus or"UNKNOWN")=="UNKNOWN" and module.requestLiabilityAssessment~=nil then result=module:requestLiabilityAssessment(farmId,claim.id) elseif claim~=nil then result=module:assessClaim(farmId,claim.id) end
    self.lastInsuranceMessage=result~=nil and result.message or"Aucun sinistre en attente d'expertise";self:refreshInsurance()
end
function AgriLife.HomeFrame:onClickInsuranceAppeal()
    if not self:canManage("insurance.manage")then return end;local module=self:getInsuranceModule();local farmId=self.core.context:getFarmId();local snapshot=module~=nil and module:getSnapshot(farmId)or nil;local claim=self:getSelectedInsuranceClaim(snapshot);local result=claim~=nil and module:appealClaim(farmId,claim.id)or nil;self.lastInsuranceMessage=result~=nil and result.message or"Aucun sinistre susceptible de recours";self:refreshInsurance()
end

function AgriLife.HomeFrame:refreshInsurance()
    local module=self:getInsuranceModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; local snapshot=module~=nil and module:getSnapshot(farmId) or nil
    if snapshot==nil then setText(self.insurancePlaceholderStatus,"Module Assurance indisponible"); return end
    setText(self.insuranceActiveValue,snapshot.activePolicies or 0); setText(self.insuranceMonthlyValue,formatMoney(snapshot.monthlyPremium or 0)); setText(self.insuranceClaimsValue,snapshot.openClaims or 0)
    local bm=snapshot.bonusMalusDetails;local bmText=string.format("%.2f",snapshot.bonusMalus or 1);if bm~=nil and g_i18n~=nil then local key=bm.status=="BONUS"and"agrilife_insurance8_bonus_fmt"or(bm.status=="MALUS"and"agrilife_insurance8_malus_fmt"or"agrilife_insurance8_neutral_fmt");bmText=string.format(g_i18n:getText(key),tonumber(bm.coefficient)or 1,tonumber(bm.ratePercent)or 0)end;setText(self.insuranceBonusValue,bmText)
    local covered={}; for _,id in ipairs(self.insuranceCategories) do if snapshot.coverage~=nil and snapshot.coverage[id] then table.insert(covered,INSURANCE_CATEGORY_LABELS[id]) end end
    local missing={};for _,id in ipairs(snapshot.missingRequiredCategories or{})do table.insert(missing,INSURANCE_CATEGORY_LABELS[id]or id)end
    local coverageText=#covered>0 and table.concat(covered,"\n") or "Aucune couverture";if #missing>0 then coverageText=coverageText.."\nManque : "..table.concat(missing,", ")end;setText(self.insuranceCoverageValue,coverageText)
    local category,tierId,value=self:getInsuranceSelection(); local tier=AgriLife.Insurance6Service.TIERS[tierId]
    if self.insuranceCategoryButton~=nil and self.insuranceCategoryButton.setText~=nil then self.insuranceCategoryButton:setText(INSURANCE_CATEGORY_LABELS[category]) end
    if self.insuranceTierButton~=nil and self.insuranceTierButton.setText~=nil then self.insuranceTierButton:setText(tier~=nil and tier.name or tierId) end
    if self.insuranceValueButton~=nil and self.insuranceValueButton.setText~=nil then self.insuranceValueButton:setText(formatMoney(value)) end
    local quote=module:quote(farmId,category,value,tierId,0.35); setText(self.insuranceQuoteValue,quote~=nil and quote.ok and (formatMoney(quote.details.monthlyPremium).." / mois") or "--")
    local economy=self:getEconomyModule(); local ready=economy~=nil and economy:isReady(farmId); local canManage=self:canManage("insurance.manage");setDisabled(self.insuranceCategoryButton,not canManage);setDisabled(self.insuranceTierButton,not canManage);setDisabled(self.insuranceValueButton,not canManage);setDisabled(self.insuranceBuyButton,not ready or not canManage or quote==nil or not quote.ok)
    local selectedPolicy=self:getSelectedInsurancePolicy(snapshot);local selectedClaim=self:getSelectedInsuranceClaim(snapshot);local policyText=selectedPolicy~=nil and string.format("Contrat %s - %s - %s%s",tostring(selectedPolicy.id),INSURANCE_CATEGORY_LABELS[selectedPolicy.category]or tostring(selectedPolicy.category),tostring(selectedPolicy.status),(tonumber(selectedPolicy.missedPremiums)or 0)>0 and(" - "..tostring(selectedPolicy.missedPremiums).." impayé(s)")or"")or"Aucun contrat";local claimText=selectedClaim~=nil and string.format("Sinistre %s - %s - %s%s",tostring(selectedClaim.id),formatMoney(selectedClaim.damageAmount or 0),tostring(selectedClaim.status),tostring(selectedClaim.assessmentReason or"")~=""and(" - "..tostring(selectedClaim.assessmentReason))or"")or"Aucun sinistre";if selectedClaim~=nil and selectedClaim.requiresLiability==true and g_i18n~=nil then local liabilityKey=INSURANCE_LIABILITY_L10N[tostring(selectedClaim.liabilityStatus or"UNKNOWN")]or INSURANCE_LIABILITY_L10N.UNKNOWN;claimText=claimText.."\n"..g_i18n:getText(liabilityKey).." | "..string.format(g_i18n:getText("agrilife_insurance8_settlement_fmt"),formatMoney(selectedClaim.insurerRepairShare or 0),formatMoney(selectedClaim.ownerRepairShare or selectedClaim.repairEstimate or selectedClaim.damageAmount or 0))end;setText(self.insuranceManageValue,policyText.."\n"..claimText);setDisabled(self.insurancePolicyNextButton,#(snapshot.policies or{})<2);setDisabled(self.insuranceClaimNextButton,#(snapshot.claims or{})<2);local policyManageable=selectedPolicy~=nil and(selectedPolicy.status=="active"or selectedPolicy.status=="suspended");setDisabled(self.insuranceCancelButton,not canManage or not policyManageable);setText(self.insuranceCancelButton,selectedPolicy~=nil and selectedPolicy.status=="suspended"and"RÉACTIVER"or"RÉSILIER");setDisabled(self.insuranceFileClaimButton,not canManage or selectedPolicy==nil or selectedPolicy.status~="active");local assessable=selectedClaim~=nil and(selectedClaim.status=="expertise"or selectedClaim.status=="appeal"or selectedClaim.status=="payment_pending");setDisabled(self.insuranceAssessButton,not canManage or not assessable);local appealable=selectedClaim~=nil and(selectedClaim.status=="rejected"or selectedClaim.status=="paid")and selectedClaim.appealed~=true;setDisabled(self.insuranceAppealButton,not canManage or not appealable)
    setText(self.insurancePlaceholderStatus,self.lastInsuranceMessage or (ready and "Sélectionnez une catégorie, une formule et un capital assuré." or "Accès verrouillé : banque et permis agricole obligatoires."))
end

function AgriLife.HomeFrame:getWorkshopSelection(snapshot)
    local list=snapshot~=nil and snapshot.vehicles or {}; if #list==0 then return nil end; self.workshopVehicleIndex=((self.workshopVehicleIndex-1)%#list)+1; return list[self.workshopVehicleIndex]
end
function AgriLife.HomeFrame:onClickWorkshopVehicle() local module=self:getWorkshopModule(); local farmId=self.core.context:getFarmId(); local s=module~=nil and module:getSnapshot(farmId) or nil; local n=s~=nil and #(s.vehicles or {}) or 0; if n>0 then self.workshopVehicleIndex=(self.workshopVehicleIndex%n)+1 end; self:refreshWorkshop() end
function AgriLife.HomeFrame:runWorkshopAction(action)
    if not self:canManage("workshop.manage") then self.lastWorkshopMessage="Accès atelier en lecture seule pour ce rôle.";self:refreshWorkshop();return end
    local module=self:getWorkshopModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; local snapshot=module~=nil and module:getSnapshot(farmId) or nil; local vehicle=self:getWorkshopSelection(snapshot); if vehicle==nil then self.lastWorkshopMessage="Aucun matériel détecté pour cette ferme."; self:refreshWorkshop(); return end
    local profileId=self:getLocalPayrollProfileId(farmId); local result=nil
    if action=="diagnose" then result=module:diagnose(farmId,vehicle.assetId,profileId) elseif action=="service" then result=module:serviceVehicle(farmId,vehicle.assetId,profileId) elseif action=="repair" then result=module:repair(farmId,vehicle.assetId,profileId) elseif action=="tyres" then result=module:replaceTyres(farmId,vehicle.assetId,profileId) end
    self.lastWorkshopMessage=result~=nil and result.message or "Action atelier indisponible"; self:refreshWorkshop()
end
function AgriLife.HomeFrame:onClickWorkshopDiagnose() self:runWorkshopAction("diagnose") end
function AgriLife.HomeFrame:onClickWorkshopService() self:runWorkshopAction("service") end
function AgriLife.HomeFrame:onClickWorkshopRepair() self:runWorkshopAction("repair") end
function AgriLife.HomeFrame:onClickWorkshopTyres() self:runWorkshopAction("tyres") end
function AgriLife.HomeFrame:getUsedOffer(snapshot) local offers=snapshot~=nil and snapshot.offers or {}; if #offers==0 then return nil end; self.usedOfferIndex=((self.usedOfferIndex-1)%#offers)+1; return offers[self.usedOfferIndex] end
function AgriLife.HomeFrame:onClickUsedOffer() local assets=self:getAssetsModule(); local farmId=self.core.context:getFarmId(); local s=assets~=nil and assets:getSnapshot(farmId) or nil; local n=s~=nil and #(s.offers or {}) or 0; if n>0 then self.usedOfferIndex=(self.usedOfferIndex%n)+1 end; self:refreshWorkshop() end
function AgriLife.HomeFrame:onClickUsedInspect() if not self:canManage("assets.manage")then return end;local assets=self:getAssetsModule(); local farmId=self.core.context:getFarmId(); local snap=assets~=nil and assets:getSnapshot(farmId) or nil; local o=self:getUsedOffer(snap); local r=o~=nil and assets:inspectOffer(farmId,o.id) or nil; self.lastWorkshopMessage=r~=nil and r.message or "Aucune offre à inspecter"; self:refreshWorkshop() end
function AgriLife.HomeFrame:onClickUsedBuy() if not self:canManage("assets.manage")then return end;local assets=self:getAssetsModule(); local farmId=self.core.context:getFarmId(); local snap=assets~=nil and assets:getSnapshot(farmId) or nil; local o=self:getUsedOffer(snap); local r=o~=nil and assets:purchaseUsed(farmId,o.id) or nil; self.lastWorkshopMessage=r~=nil and r.message or "Aucune offre à acheter"; self:refreshWorkshop() end
function AgriLife.HomeFrame:onClickLeaseCreate() if not self:canManage("assets.manage")then return end;local assets=self:getAssetsModule(); local farmId=self.core.context:getFarmId(); local snap=assets~=nil and assets:getSnapshot(farmId)or nil;local offer=self:getUsedOffer(snap);local r=offer~=nil and assets:createLease(farmId,offer.name,offer.newValue,48,0.10,0.25,offer.xmlFilename) or nil; self.lastWorkshopMessage=r~=nil and r.message or "Leasing indisponible"; self:refreshWorkshop() end
function AgriLife.HomeFrame:refreshWorkshop()
    local workshop=self:getWorkshopModule(); local assets=self:getAssetsModule(); local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0; local ws=workshop~=nil and workshop:getSnapshot(farmId) or nil; local as=assets~=nil and assets:getSnapshot(farmId) or nil
    if ws==nil or as==nil then setText(self.workshopPlaceholderStatus,"Atelier ou gestion d'actifs indisponible"); return end
    setText(self.workshopSummaryValue,string.format("%d matériel(s)  |  %d révision(s)  |  %d panne(s)  |  %d accident(s)",ws.vehicleCount or 0,ws.serviceDue or 0,ws.breakdowns or 0,ws.accidentCount or 0)); setText(self.assetsSummaryValue,string.format("Leasing : %d actif(s), %s/mois  |  Occasion : %d offre(s), %d achat(s)",as.activeLeases or 0,formatMoney(as.monthlyLeasing or 0),as.usedOfferCount or 0,as.usedPurchaseCount or 0))
    local v=self:getWorkshopSelection(ws); if v~=nil then if self.workshopVehicleButton~=nil and self.workshopVehicleButton.setText~=nil then self.workshopVehicleButton:setText(v.name) end; local behaviorText=string.format(g_i18n:getText("agrilife_workshop93_behavior_score_fmt"),math.floor((tonumber(v.behaviorScore)or 100)+0.5));local carrier=tostring(v.energyCarrier or "");local energyUsage=tonumber(v.energyUsagePerHour)or 0;local liquid=(carrier=="DIESEL" or carrier=="HVO" or carrier=="BIODIESEL" or carrier=="GASOLINE" or carrier=="PETROL" or carrier=="E85");local energyText=string.format(g_i18n:getText(liquid and "agrilife_workshop93_energy_liquid_fmt" or "agrilife_workshop93_energy_generic_fmt"),carrier~="" and carrier or "--",energyUsage);setText(self.workshopVehicleState,string.format("État %.0f%% | Huile %.0f%% | Filtres %.0f%% | Pneus %.0f%% | %.1f h | %.1f km%s | %s | %s",(v.condition or 0)*100,(v.oilLife or 0)*100,(v.filterLife or 0)*100,(v.tyreLife or 0)*100,v.hours or 0,v.kilometers or 0,(v.breakdown or(tonumber(v.downtimePeriods)or 0)>0)and" | IMMOBILISÉ"or"",behaviorText,energyText)) else if self.workshopVehicleButton~=nil and self.workshopVehicleButton.setText~=nil then self.workshopVehicleButton:setText("Aucun matériel détecté") end; setText(self.workshopVehicleState,"--") end
    local o=self:getUsedOffer(as); if o~=nil then if self.usedOfferButton~=nil and self.usedOfferButton.setText~=nil then self.usedOfferButton:setText(string.format("%s - %s",o.name,formatMoney(o.price))) end; setText(self.usedOfferState,string.format("%d an(s) | %.0f h | %.0f km | état %.0f%% | risque %.0f%% | %d accident(s)",o.ageYears or 0,o.hours or 0,o.kilometers or 0,(o.serviceScore or 0)*100,(o.risk or 0)*100,o.accidentCount or 0)) else if self.usedOfferButton~=nil and self.usedOfferButton.setText~=nil then self.usedOfferButton:setText("Aucune offre") end; setText(self.usedOfferState,"--") end
    local economy=self:getEconomyModule(); local ready=economy~=nil and economy:isReady(farmId);local canWorkshop=self:canManage("workshop.manage");local canAssets=self:canManage("assets.manage");for _,button in ipairs({self.workshopDiagnoseButton,self.workshopServiceButton,self.workshopRepairButton,self.workshopTyresButton})do setDisabled(button,not canWorkshop or v==nil)end;setDisabled(self.usedInspectButton,not canAssets or o==nil);setDisabled(self.usedBuyButton,not canAssets or o==nil);setDisabled(self.leaseCreateButton,not ready or not canAssets or o==nil); setText(self.workshopPlaceholderStatus,self.lastWorkshopMessage or (ready and "Les opérations sont enregistrées dans l'historique technique et le grand livre." or "Accès verrouillé : banque et permis agricole obligatoires."))
end

function AgriLife.HomeFrame:onClickCompanyLegalForm()
    if not self:canManage("company.manage") then return end
    local company=self:getCompanyModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0;local snapshot=company~=nil and company:getSnapshot(farmId)or nil;if snapshot==nil then return end
    local forms=company:getLegalForms()or{};local index=1;for i,form in ipairs(forms)do if form.id==snapshot.legalFormId then index=i break end end;index=index%math.max(1,#forms)+1
    local result=company:setIdentity(farmId,snapshot.companyName,forms[index].id);self.lastCompanyMessage=result~=nil and result.message or "Modification indisponible";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyHousing()
    if not self:canManage("company.manage") then return end
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local service=economy~=nil and economy.service or nil;if service==nil then return end
    local owner=service:getOwnerProfileId(farmId);local account=service:getPersonalAccount(farmId,owner,true);self.companyHousingIndex=self.companyHousingIndex%#self.companyHousingOptions+1;local choice=self.companyHousingOptions[self.companyHousingIndex];account.housing=choice.id;account.monthlyHousingCost=choice.cost;self.lastCompanyMessage="Logement personnel mis à jour";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyPersonalBank()
    if not self:canManage("company.manage") then return end
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local service=economy~=nil and economy.service or nil;if service==nil then return end
    local owner=service:getOwnerProfileId(farmId);local account=service:getPersonalAccount(farmId,owner,true);local index=0;for i,bank in ipairs(self.companyPersonalBanks)do if bank.id==account.bankProviderId then index=i break end end;index=index%#self.companyPersonalBanks+1;local choice=self.companyPersonalBanks[index];local result=economy:setPersonalBank(farmId,owner,choice.id);self.lastCompanyMessage=result~=nil and result.ok and("Banque personnelle sélectionnée : "..choice.label)or(result~=nil and result.message or"Banque personnelle indisponible");self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyPrivateVehicle()
    if not self:canManage("company.manage") then return end
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local service=economy~=nil and economy.service or nil;if service==nil then return end
    local account=service:getPersonalAccount(farmId,service:getOwnerProfileId(farmId),true);local current=tonumber(account.privateVehicleValue)or 0;local index=1;for i,value in ipairs(self.companyPrivateVehicleValues)do if value==current then index=i break end end;local target=self.companyPrivateVehicleValues[index%#self.companyPrivateVehicleValues+1]
    local result=economy:setPrivateVehicle(farmId,account.profileId,target);self.lastCompanyMessage=result~=nil and result.message or"Opération privée indisponible";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyExpense()
    if not self:canManage("company.manage") then return end
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local service=economy~=nil and economy.service or nil;if service==nil then return end;local result=service:addPersonalMoney(farmId,service:getOwnerProfileId(farmId),-500,"PERSONAL_EXPENSE","Dépense personnelle");self.lastCompanyMessage=result~=nil and result.message or "Dépense indisponible";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyCapitalContribution()
    if not self:canManage("company.manage") then return end
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local actor=self:getLocalPayrollProfileId(farmId);local result=economy~=nil and economy:contributeCapital(farmId,actor,5000)or nil
    self.lastCompanyMessage=result~=nil and result.message or"Apport indisponible";self:refreshCompany()
end
function AgriLife.HomeFrame:getAssociateCandidate(farmId,economySnapshot)
    local payroll=self:getPayrollModule();local payrollSnapshot=payroll~=nil and payroll:getSnapshot(farmId)or nil;local existing={}
    for _,associate in ipairs(economySnapshot~=nil and economySnapshot.associates or{})do existing[tostring(associate.profileId or"")]=true end
    local owner=self:getEconomyModule()~=nil and self:getEconomyModule().service:getOwnerProfileId(farmId)or""
    for _,employee in ipairs(payrollSnapshot~=nil and payrollSnapshot.employees or{})do
        if employee.employmentStatus~="TERMINATED" and tostring(employee.profileId or"")~=tostring(owner) and not existing[tostring(employee.profileId or"")] then return employee end
    end
    return nil
end
function AgriLife.HomeFrame:onClickCompanyAssociateAdd()
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local snapshot=economy~=nil and economy:getSnapshot(farmId)or nil;local candidate=self:getAssociateCandidate(farmId,snapshot);local actor=self:getLocalPayrollProfileId(farmId)
    local result=candidate~=nil and economy:addAssociateManaged(farmId,actor,candidate.profileId,10)or nil
    self.lastCompanyMessage=result~=nil and result.message or"Recrutez d'abord un salarié pouvant devenir associé";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyAssociateRemove()
    local economy=self:getEconomyModule();local farmId=self.core.context:getFarmId();local snapshot=economy~=nil and economy:getSnapshot(farmId)or nil;local associates=snapshot~=nil and snapshot.associates or{};local actor=self:getLocalPayrollProfileId(farmId)
    if #associates>0 then self.companyAssociateIndex=((self.companyAssociateIndex-1)%#associates)+1 end
    local target=associates[self.companyAssociateIndex];local result=target~=nil and economy:removeAssociate(farmId,actor,target.profileId)or nil
    self.lastCompanyMessage=result~=nil and result.message or"Aucun associé à retirer";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickCompanyReconcile()
    local integrity=self:getIntegrityModule();local farmId=self.core.context:getFarmId();local actor=self:getLocalPayrollProfileId(farmId);local result=integrity~=nil and integrity:reconcile(farmId,actor,"Rapprochement validé depuis le dossier société")or nil
    self.lastCompanyMessage=result~=nil and result.message or"Rapprochement indisponible";self:refreshCompany()
end
function AgriLife.HomeFrame:onClickLegalSettle()
    if not self:canManage("legal.manage") then return end
    local legal=self:getLegalModule();local farmId=self.core.context:getFarmId();local snapshot=legal~=nil and legal:getSnapshot(farmId)or nil;local result=legal~=nil and legal:settleDebt(farmId,snapshot~=nil and snapshot.debt or 0)or nil;self.lastCompanyMessage=result~=nil and result.message or "Aucune dette à régler";self:refreshCompany()
end
function AgriLife.HomeFrame:refreshCompany()
    local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId()or 0;local company=self:getCompanyModule();local economy=self:getEconomyModule();local legal=self:getLegalModule();local integrity=self:getIntegrityModule();local c=company~=nil and company:getSnapshot(farmId)or nil;local e=economy~=nil and economy:getSnapshot(farmId)or nil;local l=legal~=nil and legal:getSnapshot(farmId)or nil;local i=integrity~=nil and integrity:getSnapshot(farmId)or nil
    if c==nil or e==nil then setText(self.companyStatusText,"Dossier administratif indisponible");return end
    local bankLabel=tostring(e.personalBankProviderId or"--");for _,bank in ipairs(self.companyPersonalBanks)do if bank.id==e.personalBankProviderId then bankLabel=bank.label break end end
    setText(self.companyNameValue,c.companyName)
    setText(self.companyLegalValue,g_i18n:getText(c.legalFormLabelKey))
    setText(self.companyCapitalValue,formatMoney(e.socialCapital or 0))
    setText(self.companyProfileValue,self:getAutomaticCareerStatus(farmId))
    local policy=e.modePolicy or{}
    setText(self.companyModeValue,string.format(g_i18n:getText("agrilife_company_management_format"),self:getLocalizedModeName(e.modeId,e.modeName),self:getLocalizedManagementDepth(policy.managementDepth)))
    local payroll=self:getPayrollModule();local payrollSnapshot=payroll~=nil and payroll:getSnapshot(farmId)or nil;local names={}
    for _,associate in ipairs(e.associates or{})do
        local name=tostring(associate.profileId or"?")
        for _,employee in ipairs(payrollSnapshot~=nil and payrollSnapshot.employees or{})do if tostring(employee.profileId or"")==tostring(associate.profileId or"")then name=tostring(employee.displayName or name);break end end
        table.insert(names,string.format("%s %.0f%%",name,tonumber(associate.sharePercent)or 0))
    end
    setText(self.companyAssociateValue,#names>0 and table.concat(names,", ")or"Aucun associé")
    setText(self.companyPersonalBalanceValue,formatMoney(e.personalBalance or 0));setText(self.companyPersonalBankValue,string.format("%s | %s/mois | score %d",bankLabel,formatMoney(e.personalBankMonthlyFee or 0),e.personalCreditScore or 0));setText(self.companyHousingValue,string.format("%s - %s/mois",tostring(e.housing or"--"),formatMoney(e.monthlyHousingCost or 0)));setText(self.companyPrivateVehicleValue,(tonumber(e.privateVehicleValue)or 0)>0 and string.format("Véhicule : %s | %.0f km | %s/mois",formatMoney(e.privateVehicleValue),e.privateVehicleKilometers or 0,formatMoney(e.privateVehicleMonthlyCost or 0))or"Aucun véhicule privé")
    setText(self.companyTaxValue,l~=nil and formatMoney(l.currentTaxProvision or 0).."/mois"or"--");setText(self.companyLegalDebtValue,l~=nil and formatMoney(l.debt or 0)or"--");setText(self.companyLegalStageValue,l~=nil and tostring(l.stage or"current")or"--");local canCompany=self:canManage("company.manage");local actor=self:getLocalPayrollProfileId(farmId);local people=self:getPeopleModule();local isOwner=people~=nil and people.service~=nil and people.service.isFarmOwner~=nil and people.service:isFarmOwner(farmId,actor);setDisabled(self.companyLegalFormButton,not canCompany);setDisabled(self.companyPersonalBankValue,not canCompany);setDisabled(self.companyHousingButton,not canCompany);setDisabled(self.companyPrivateVehicleButton,not canCompany);setDisabled(self.companyExpenseButton,not canCompany);setDisabled(self.companyCapitalContributionButton,not canCompany);setDisabled(self.companyAssociateAddButton,not isOwner or self:getAssociateCandidate(farmId,e)==nil);setDisabled(self.companyAssociateRemoveButton,not isOwner or #(e.associates or{})==0);setDisabled(self.companyReconcileButton,not canCompany or i==nil or(math.abs(tonumber(i.unresolvedDifference)or 0)<0.01 and i.locked~=true));setDisabled(self.legalSettleButton,not self:canManage("legal.manage")or l==nil or(l.debt or 0)<=0)
    local lines={};for i=math.max(1,#(e.recentLedger or{})-3),#(e.recentLedger or{})do local entry=e.recentLedger[i];if entry~=nil then table.insert(lines,string.format("%s  %s  %s",tostring(entry.category or""),formatMoney(entry.amount or 0),tostring(entry.note or"")))end end;setText(self.companyLedgerValue,#lines>0 and table.concat(lines,"\n")or"Aucun mouvement enregistré")
    local integrityText=i~=nil and(i.locked and("ALERTE INTÉGRITÉ - rapprochement requis : "..formatMoney(i.unresolvedDifference or 0))or(math.abs(tonumber(i.unresolvedDifference)or 0)>=0.01 and("Écart à rapprocher : "..formatMoney(i.unresolvedDifference or 0))or"Registre financier rapproché"))or"Registre d'intégrité indisponible";setText(self.companyStatusText,self.lastCompanyMessage or integrityText)
end

function AgriLife.HomeFrame:getSelectedAccident(snapshot)
    local list=snapshot~=nil and snapshot.accidents or{};if #list==0 then return nil end;self.accidentIndex=((self.accidentIndex-1)%#list)+1;return list[self.accidentIndex]
end
function AgriLife.HomeFrame:onClickAccidentNext()local workshop=self:getWorkshopModule();local snapshot=workshop~=nil and workshop:getSnapshot(self.core.context:getFarmId())or nil;local n=snapshot~=nil and #(snapshot.accidents or{})or 0;if n>0 then self.accidentIndex=self.accidentIndex%n+1 end;self:refreshAccidents()end
function AgriLife.HomeFrame:onClickAccidentClaim()
    local farmId=self.core.context:getFarmId();local workshop=self:getWorkshopModule();local ws=workshop~=nil and workshop:getSnapshot(farmId)or nil;local accident=self:getSelectedAccident(ws)
    if accident==nil or workshop==nil then self.lastAccidentMessage=g_i18n:getText("agrilife_accident93_none_selected");self:refreshAccidents();return end
    local actor=self:getLocalPayrollProfileId(farmId)
    local driver=tostring(accident.driverProfileId or accident.responsibleProfileId or"")
    local declarationComplete=tostring(accident.declarationStatus or"") == "COMPLETED"
    if not declarationComplete then
        if tostring(actor or"")==driver and self:canManage("insurance.declareAccident") then
            if self.core~=nil and self.core.ui~=nil and self.core.ui.showAccidentStatementDialog~=nil then
                self.core.ui:showAccidentStatementDialog(workshop.service or workshop,farmId,ws.accidents or{},accident.id,actor,function(result) self.lastAccidentMessage=result~=nil and result.message or nil;self:refreshAccidents() end)
            end
        else
            self.lastAccidentMessage=g_i18n:getText("agrilife_accident93_wait_driver_statement")
        end
        self:refreshAccidents();return
    end
    if not self:canManage("insurance.manage") then self.lastAccidentMessage=g_i18n:getText("agrilife_accident93_owner_only_decision");self:refreshAccidents();return end
    local service=workshop.service or workshop
    local result
    if tostring(accident.totalLossStatus or"")=="OFFERED" then result=service:acceptTotalLossOffer93(farmId,accident.id,actor)
    elseif tostring(accident.claimId or"")=="" then result=service:submitAccidentToInsurance93(farmId,accident.id,actor)
    else result=AgriLife.Result.fail("WORKSHOP_ACCIDENT_ALREADY_SUBMITTED",g_i18n:getText("agrilife_accident93_already_submitted")) end
    self.lastAccidentMessage=result~=nil and result.message or g_i18n:getText("agrilife_accident93_action_failed");self:refreshAccidents()
end
function AgriLife.HomeFrame:onClickAccidentExpertise()
    if not self:canManage("insurance.manage") then return end
    local farmId=self.core.context:getFarmId();local workshop=self:getWorkshopModule();local service=workshop~=nil and(workshop.service or workshop)or nil;local accident=self:getSelectedAccident(workshop~=nil and workshop:getSnapshot(farmId)or nil);local result=nil
    if accident~=nil and service~=nil then
        if tostring(accident.totalLossStatus or"")=="OFFERED" and tostring(accident.liabilityStatus or"UNKNOWN")=="UNKNOWN" and service.assessAccidentLiability~=nil then result=service:assessAccidentLiability(farmId,accident.id)
        elseif tostring(accident.totalLossStatus or"")=="OFFERED" then result=service:contestTotalLossOffer93(farmId,accident.id,self:getLocalPayrollProfileId(farmId))
        elseif tostring(accident.claimId or"")~="" and service.assessAccidentLiability~=nil then result=service:assessAccidentLiability(farmId,accident.id)
        end
    end
    self.lastAccidentMessage=result~=nil and result.message or g_i18n:getText("agrilife_accident93_no_expertise");self:refreshAccidents()
end
function AgriLife.HomeFrame:refreshAccidents()
    local farmId=self.core.context:getFarmId();local workshop=self:getWorkshopModule();local insurance=self:getInsuranceModule();local ws=workshop~=nil and workshop:getSnapshot(farmId)or nil;local ins=insurance~=nil and insurance:getSnapshot(farmId)or nil;if ws==nil then return end;setText(self.accidentCountValue,ws.accidentCount or 0);setText(self.accidentClaimsValue,ins~=nil and ins.openClaims or 0);setText(self.accidentPayoutValue,ins~=nil and formatMoney(ins.totalPayouts or 0)or"--")
    local a=self:getSelectedAccident(ws);local canOwner=self:canManage("insurance.manage");local canDeclare=self:canManage("insurance.declareAccident");local actor=self:getLocalPayrollProfileId(farmId)
    if a~=nil then
        local driver=tostring(a.driverProfileId or a.responsibleProfileId or"--");local declarationComplete=tostring(a.declarationStatus or"")=="COMPLETED"
        setText(self.accidentVehicleValue,a.vehicleName);setText(self.accidentDamageValue,formatMoney(a.damageAmount or 0));setText(self.accidentCauseValue,tostring(a.cause or"--"));setText(self.accidentResponsibleValue,string.format("%s | %s | %s",driver,tostring(a.driverType or"PLAYER"),declarationComplete and g_i18n:getText("agrilife_accident93_statement_done") or g_i18n:getText("agrilife_accident93_statement_pending")));setText(self.accidentClaimValue,tostring(a.claimId or"")~=""and tostring(a.claimId)or g_i18n:getText("agrilife_accident93_claim_none"));setText(self.accidentDowntimeValue,string.format("%d période(s)",a.downtimePeriods or 0))
        local primaryEnabled=false;local secondaryEnabled=false
        if not declarationComplete then setText(self.accidentClaimButton,g_i18n:getText("agrilife_accident93_fill_statement"));primaryEnabled=canDeclare and tostring(actor or"")==driver
        elseif tostring(a.totalLossStatus or"")=="OFFERED" then
            local liabilityPending=tostring(a.liabilityStatus or"UNKNOWN")=="UNKNOWN"
            if liabilityPending then
                setText(self.accidentClaimButton,g_i18n:getText("agrilife_accident93_total_loss_wait_expertise"));setText(self.accidentExpertiseButton,g_i18n:getText("agrilife_accident93_expertise"));secondaryEnabled=canOwner
            else
                setText(self.accidentClaimButton,g_i18n:getText("agrilife_accident93_accept_total_loss"));setText(self.accidentExpertiseButton,g_i18n:getText("agrilife_accident93_contest_total_loss"));primaryEnabled=canOwner;secondaryEnabled=canOwner
            end
        elseif tostring(a.claimId or"")=="" then setText(self.accidentClaimButton,g_i18n:getText("agrilife_accident93_submit_insurer"));setText(self.accidentExpertiseButton,g_i18n:getText("agrilife_accident93_expertise"));primaryEnabled=canOwner
        else setText(self.accidentClaimButton,g_i18n:getText("agrilife_accident93_submitted"));setText(self.accidentExpertiseButton,g_i18n:getText("agrilife_accident93_expertise"));secondaryEnabled=canOwner end
        setDisabled(self.accidentClaimButton,not primaryEnabled);setDisabled(self.accidentExpertiseButton,not secondaryEnabled)
        local offer=a.totalLossOffer;local status
        if offer~=nil and tostring(a.totalLossStatus or"")=="OFFERED" then status=string.format(g_i18n:getText("agrilife_accident93_total_loss_offer_fmt"),formatMoney(offer.preAccidentValue or 0),formatMoney(offer.repairEstimate or 0),formatMoney(offer.ownerNetIndemnity or offer.grossIndemnity or 0))
        elseif not declarationComplete then status=tostring(a.driverType or"")=="AI_WORKER" and g_i18n:getText("agrilife_accident93_ai_statement_automatic") or g_i18n:getText("agrilife_accident93_driver_must_statement")
        elseif tostring(a.claimId or"")=="" then status=g_i18n:getText("agrilife_accident93_owner_review_required") else status=g_i18n:getText("agrilife_accident93_insurer_review") end
        setText(self.accidentStatusText,self.lastAccidentMessage or status)
    else
        setText(self.accidentVehicleValue,g_i18n:getText("agrilife_accident93_no_accident"));setDisabled(self.accidentClaimButton,true);setDisabled(self.accidentExpertiseButton,true);setText(self.accidentStatusText,self.lastAccidentMessage or g_i18n:getText("agrilife_accident93_no_accident"))
    end
end

function AgriLife.HomeFrame:getSelectedLease(snapshot)
    local active={};for _,lease in ipairs(snapshot~=nil and snapshot.leases or{})do if lease.status=="active"or lease.status=="matured"then table.insert(active,lease)end end;if #active==0 then return nil end;self.leaseIndex=((self.leaseIndex-1)%#active)+1;return active[self.leaseIndex]
end
function AgriLife.HomeFrame:onClickLeaseOffer()self:onClickUsedOffer();self:refreshLeasing()end
function AgriLife.HomeFrame:onClickLeaseTerm()self.leaseTermIndex=self.leaseTermIndex%#self.leaseTerms+1;self:refreshLeasing()end
function AgriLife.HomeFrame:onClickLeaseDeposit()self.leaseDepositIndex=self.leaseDepositIndex%#self.leaseDeposits+1;self:refreshLeasing()end
function AgriLife.HomeFrame:onClickLeaseCreateAdvanced()
    if not self:canManage("assets.manage") then return end
    local farmId=self.core.context:getFarmId();local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(farmId)or nil;local offer=self:getUsedOffer(snapshot);local result=offer~=nil and assets:createLease(farmId,offer.name,offer.newValue,self.leaseTerms[self.leaseTermIndex],self.leaseDeposits[self.leaseDepositIndex],0.25,offer.xmlFilename)or nil;self.lastLeaseMessage=result~=nil and result.message or"Aucun matériel disponible";self:refreshLeasing()
end
function AgriLife.HomeFrame:onClickLeaseNext()local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(self.core.context:getFarmId())or nil;local count=0;for _,lease in ipairs(snapshot~=nil and snapshot.leases or{})do if lease.status=="active"or lease.status=="matured"then count=count+1 end end;if count>0 then self.leaseIndex=self.leaseIndex%count+1 end;self:refreshLeasing()end
function AgriLife.HomeFrame:onClickLeaseBuyout()if not self:canManage("assets.manage")then return end;local farmId=self.core.context:getFarmId();local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(farmId)or nil;local lease=self:getSelectedLease(snapshot);local result=lease~=nil and assets:buyoutLease(farmId,lease.id)or nil;self.lastLeaseMessage=result~=nil and result.message or"Aucun leasing actif";self:refreshLeasing()end
function AgriLife.HomeFrame:onClickLeaseReturn()if not self:canManage("assets.manage")then return end;local farmId=self.core.context:getFarmId();local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(farmId)or nil;local lease=self:getSelectedLease(snapshot);local result=lease~=nil and assets:returnLease(farmId,lease.id)or nil;self.lastLeaseMessage=result~=nil and result.message or"Aucun leasing actif";self:refreshLeasing()end
function AgriLife.HomeFrame:refreshLeasing()
    local farmId=self.core.context:getFarmId();local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(farmId)or nil;if snapshot==nil then return end;local canManage=self:canManage("assets.manage");local offer=self:getUsedOffer(snapshot);setText(self.leaseOfferValue,offer~=nil and offer.name or"Aucune offre");setText(self.leaseAssetValue,offer~=nil and formatMoney(offer.newValue)or"--");setText(self.leaseTermValue,string.format("%d mois",self.leaseTerms[self.leaseTermIndex]));setText(self.leaseDepositValue,string.format("%.0f %%",self.leaseDeposits[self.leaseDepositIndex]*100));local preview=offer~=nil and assets:previewLease(farmId,offer.name,offer.newValue,self.leaseTerms[self.leaseTermIndex],self.leaseDeposits[self.leaseDepositIndex],0.25)or nil;setText(self.leasePreviewValue,preview~=nil and preview.ok and string.format("Apport %s | %s/mois | option %s",formatMoney(preview.details.deposit),formatMoney(preview.details.monthlyPayment),formatMoney(preview.details.residualValue))or(preview~=nil and preview.message or"--"));setDisabled(self.leaseOfferValue,not canManage);setDisabled(self.leaseTermValue,not canManage);setDisabled(self.leaseDepositValue,not canManage);setDisabled(self.leaseCreateAdvancedButton,not canManage or offer==nil or preview==nil or not preview.ok)
    local lease=self:getSelectedLease(snapshot);setText(self.leaseActiveCountValue,snapshot.activeLeases or 0);setText(self.leaseMonthlyValue,formatMoney(snapshot.monthlyLeasing or 0));if lease~=nil then setText(self.leaseCurrentValue,string.format("%s - %d/%d mois",lease.assetName,lease.monthsPaid or 0,lease.termMonths or 0));setText(self.leaseCurrentDetailValue,string.format("%s/mois | résiduel %s | pénalités %s",formatMoney(lease.monthlyPayment),formatMoney(lease.residualValue),formatMoney(lease.penalties or 0)));setDisabled(self.leaseBuyoutButton,not canManage);setDisabled(self.leaseReturnButton,not canManage)else setText(self.leaseCurrentValue,"Aucun leasing actif");setText(self.leaseCurrentDetailValue,"--");setDisabled(self.leaseBuyoutButton,true);setDisabled(self.leaseReturnButton,true)end;setText(self.leaseStatusText,self.lastLeaseMessage or"Leasing bancaire avec apport, mensualités, restitution, pénalités et option d'achat.")
end

function AgriLife.HomeFrame:refreshUsed()
    local farmId=self.core.context:getFarmId();local assets=self:getAssetsModule();local snapshot=assets~=nil and assets:getSnapshot(farmId)or nil;if snapshot==nil then return end;local canManage=self:canManage("assets.manage");local offer=self:getUsedOffer(snapshot);setText(self.usedCountValue,snapshot.usedOfferCount or 0);setText(self.usedPurchasedValue,snapshot.usedPurchaseCount or 0);setText(self.usedInspectionCountValue,snapshot.inspectionCount or 0);if offer~=nil then setText(self.usedNameValue,offer.name);setText(self.usedPriceValue,formatMoney(offer.price));setText(self.usedHistoryValue,string.format("%d an(s) | %.0f h | %.0f km | état %.0f%% | %d accident(s)",offer.ageYears or 0,offer.hours or 0,offer.kilometers or 0,(offer.serviceScore or 0)*100,offer.accidentCount or 0));setText(self.usedRiskValue,string.format("Risque %.0f%% - %s",(offer.risk or 0)*100,offer.inspected and tostring(offer.inspectionReport)or"historique incomplet"));setDisabled(self.usedNameValue,not canManage);setDisabled(self.usedInspectPageButton,not canManage or offer.inspected==true);setDisabled(self.usedBuyPageButton,not canManage)else setText(self.usedNameValue,"Aucune offre");setText(self.usedPriceValue,"--");setText(self.usedHistoryValue,"--");setText(self.usedRiskValue,"--");setDisabled(self.usedInspectPageButton,true);setDisabled(self.usedBuyPageButton,true)end;setText(self.usedStatusText,self.lastWorkshopMessage or"Les offres sont issues du catalogue réellement chargé par la carte et les mods.")
end
function AgriLife.HomeFrame:onClickUsedNextPage()self:onClickUsedOffer();self:refreshUsed()end
function AgriLife.HomeFrame:onClickUsedInspectPage()self:onClickUsedInspect();self:refreshUsed()end
function AgriLife.HomeFrame:onClickUsedBuyPage()self:onClickUsedBuy();self:refreshUsed()end

function AgriLife.HomeFrame:getPrimaryLoan()
    local bank=self:getBankModule();local farmId=self.core.context:getFarmId();local loans=bank~=nil and bank.service~=nil and bank.service:getActiveLoans(farmId)or{};return loans[1]
end
function AgriLife.HomeFrame:onClickBankEarlyRepay()local bank=self:getBankModule();local farmId=self.core.context:getFarmId();local loan=self:getPrimaryLoan();local result=loan~=nil and bank:repayEarly(farmId,loan.id,math.max(1000,(loan.principalRemaining or 0)*0.10))or nil;self.lastBankMessage=result~=nil and result.message or"Aucun prêt actif";self:refreshBank()end
function AgriLife.HomeFrame:onClickBankRestructure()local bank=self:getBankModule();local farmId=self.core.context:getFarmId();local loan=self:getPrimaryLoan();local result=loan~=nil and bank:restructureLoan(farmId,loan.id,math.min(120,(loan.remainingMonths or loan.termMonths or 36)+12))or nil;self.lastBankMessage=result~=nil and result.message or"Aucun prêt actif";self:refreshBank()end
function AgriLife.HomeFrame:onClickBankOverdraft()local bank=self:getBankModule();local farmId=self.core.context:getFarmId();local snapshot=bank~=nil and bank:getSnapshot(farmId)or nil;local values={0,5000,10000,25000,50000};local current=snapshot~=nil and snapshot.overdraftLimit or 0;local index=1;for i,v in ipairs(values)do if v==current then index=i break end end;index=index%#values+1;local result=bank~=nil and bank:setOverdraftLimit(farmId,values[index])or nil;self.lastBankMessage=result~=nil and result.message or"Découvert indisponible";self:refreshBank()end

function AgriLife.HomeFrame:refresh()
    self:refreshAccessMode()
    self:refreshDashboard()
    if self.activePage == "company" then
        self:refreshCompany()
    elseif self.activePage == "bank" then
        self:refreshBank()
    elseif self.activePage == "payroll" then
        self:refreshPayroll()
    elseif self.activePage == "contracts" then
        self:refreshContracts()
    elseif self.activePage == "exams" then
        self:refreshExam()
    elseif self.activePage == "xp" then
        self:refreshCareer()
    elseif self.activePage == "insurance" then
        self:refreshInsurance()
    elseif self.activePage == "workshop" then
        self:refreshWorkshop()
    elseif self.activePage == "accidents" then
        self:refreshAccidents()
    elseif self.activePage == "leasing" then
        self:refreshLeasing()
    elseif self.activePage == "used" then
        self:refreshUsed()
    end
end

function AgriLife.HomeFrame:delete()
    self.core = nil
    self.bankAmounts = nil
    self.bankTerms = nil
    self.lastBankMessage = nil
    self.lastExamMessage = nil
    AgriLife.HomeFrame:superClass().delete(self)
end

-- Roadmap 0.7 facade. The existing detailed pages are preserved, while the
-- root navigation and dashboard expose exactly the six final player modules.
do
    local baseRefreshDashboardRoadmap = AgriLife.HomeFrame.refreshDashboard
    local baseRefreshPayrollRoadmap = AgriLife.HomeFrame.refreshPayroll
    local baseRefreshContractsRoadmap = AgriLife.HomeFrame.refreshContracts
    local baseRefreshInsuranceRoadmap = AgriLife.HomeFrame.refreshInsurance
    local baseRefreshBankRoadmap = AgriLife.HomeFrame.refreshBank

    function AgriLife.HomeFrame:getEnterpriseModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.enterprise or nil end
    function AgriLife.HomeFrame:getQualificationsModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.qualifications or nil end
    function AgriLife.HomeFrame:getAdministrationModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.administration or nil end
    function AgriLife.HomeFrame:getMarketModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.market or nil end
    function AgriLife.HomeFrame:getDashboardFacadeModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.dashboardFacade or nil end
    function AgriLife.HomeFrame:getJournalModule() return self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.journal or nil end

    function AgriLife.HomeFrame:isPageAvailableForDifficulty(pageId, snapshot)
        if pageId == "dashboard" then return true end
        local finalPages = {bank = true, payroll = true, exams = true, insurance = true, contracts = true, workshop = true}
        if finalPages[pageId] then return snapshot == nil or snapshot.modeChosen == true end
        return true
    end

    function AgriLife.HomeFrame:refreshDashboard()
        baseRefreshDashboardRoadmap(self)
        if self.core == nil or self.core.context == nil then return end
        local farmId = self.core.context:getFarmId()
        local facade = self:getDashboardFacadeModule()
        local snapshot = facade ~= nil and facade.getSnapshot ~= nil and facade:getSnapshot(farmId) or nil
        local cards = snapshot ~= nil and snapshot.cards or nil
        if cards == nil then return end

        local bank = cards.bank or {}
        local relationship = bank.relationship or {}
        local relationText = tostring(relationship.status or "none")
        if relationship.status == "active" then relationText = string.format("%s, %d mois", tostring(bank.providerName or ""), tonumber(relationship.remainingMonths) or 0)
        elseif tostring(bank.providerName or "") ~= "" then relationText = tostring(bank.providerName) end
        setText(self.dashBankScore, string.format(g_i18n:getText("agrilife_dashboard_bank_score_relation_fmt"), tonumber(bank.score) or 0, relationText))

        local enterprise = cards.enterprise or {}
        setText(self.dashExamState, string.format(g_i18n:getText("agrilife_dashboard_enterprise_active_fmt"), tonumber(enterprise.employees) or 0))
        setText(self.dashExamProgress, string.format(g_i18n:getText("agrilife_dashboard_enterprise_availability_fmt"), tonumber(enterprise.available) or 0, tonumber(enterprise.busy) or 0))
        setText(self.dashExamCatalog, string.format(g_i18n:getText("agrilife_dashboard_enterprise_reputation_fmt"), tonumber(enterprise.reputation) or 50, tonumber(enterprise.activeOrders) or 0))

        local career = cards.careerQualifications or {}
        setText(self.dashCareerLevel, string.format(g_i18n:getText("agrilife_dashboard_career_level_fmt"), tonumber(career.level) or 1, tonumber(career.totalXP) or 0))
        local licence = tostring(career.generalLicence or "unknown")
        if career.examRunning == true then licence = string.format(g_i18n:getText("agrilife_dashboard_exam_running_fmt"), tonumber(career.examProgress) or 0)
        elseif licence == "obtained" then licence = string.format(g_i18n:getText("agrilife_dashboard_licence_obtained_fmt"), tonumber(career.bestScore) or 0)
        elseif licence == "required" then licence = g_i18n:getText("agrilife_dashboard_exam_required") end
        setText(self.dashCareerXp, licence)
        setText(self.dashCareerReputation, string.format(g_i18n:getText("agrilife_dashboard_qualifications_count_fmt"), tonumber(career.qualificationCount) or 0))

        local administration = cards.administration or {}
        setText(self.dashInsuranceState, string.format(g_i18n:getText("agrilife_dashboard_administration_compliance_fmt"), tonumber(administration.compliance) or 0, (administration.statusLabelKey ~= nil and g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText(administration.statusLabelKey) or tostring(administration.businessStatus or "small_farm"))))
        setText(self.dashInsuranceDetail, string.format(g_i18n:getText("agrilife_dashboard_administration_detail_fmt"), tonumber(administration.openSanctions) or 0, formatMoney(administration.unpaidAmount or 0), administration.insuranceCompliant == false and g_i18n:getText("agrilife_core_no") or g_i18n:getText("agrilife_core_yes")))

        local contracts = cards.contractsMarkets or {}
        local commodities = tonumber(contracts.commoditiesIndex) or 1
        local direction = commodities > 1.015 and g_i18n:getText("agrilife_market_direction_up") or (commodities < 0.985 and g_i18n:getText("agrilife_market_direction_down") or g_i18n:getText("agrilife_market_direction_stable"))
        setText(self.statusValueCard, string.format(g_i18n:getText("agrilife_dashboard_market_index_fmt"), direction, commodities))
        setText(self.valueVersion, tostring(tonumber(contracts.activeContracts) or 0))
        setText(self.valueModules, tostring(tonumber(contracts.opportunityCount) or 0))
        setText(self.valueErrors, string.format(g_i18n:getText("agrilife_dashboard_fuel_index_fmt"), tonumber(contracts.fuelIndex) or 1))
        setText(self.valueLastSave, string.format(g_i18n:getText("agrilife_dashboard_inputs_index_fmt"), tonumber(contracts.inputIndex) or 1))

        local workshop = cards.workshop or {}
        setText(self.dashWorkshopState, string.format(g_i18n:getText("agrilife_dashboard_workshop_state_fmt"), tonumber(workshop.vehicleCount) or 0, tonumber(workshop.immobilized) or 0))
        setText(self.dashWorkshopDetail, string.format(g_i18n:getText("agrilife_dashboard_workshop_detail_fmt"), tonumber(workshop.serviceDue) or 0, tonumber(workshop.breakdowns) or 0, tonumber(workshop.activeLeases) or 0, formatMoney(workshop.fleetMarketValue or 0)))
    end

    function AgriLife.HomeFrame:refreshPayroll()
        baseRefreshPayrollRoadmap(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local enterprise = self:getEnterpriseModule()
        local snapshot = enterprise ~= nil and enterprise.getSnapshot ~= nil and enterprise:getSnapshot(farmId) or nil
        if snapshot ~= nil and self.payrollStatusText ~= nil then
            setText(self.payrollStatusText, string.format(g_i18n:getText("agrilife_enterprise_summary_fmt"), tonumber(snapshot.reputation) or 50, tonumber(snapshot.candidateCount) or 0, tonumber(snapshot.activeOrders) or 0))
        end
    end

    function AgriLife.HomeFrame:refreshContracts()
        baseRefreshContractsRoadmap(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local market = self:getMarketModule()
        local snapshot = market ~= nil and market.getSnapshot ~= nil and market:getSnapshot(farmId) or nil
        if snapshot ~= nil and self.contractsStatusText ~= nil then
            local categories = snapshot.categories or {}
            setText(self.contractsStatusText, string.format(g_i18n:getText("agrilife_market_summary_fmt"), categories.commodities ~= nil and categories.commodities.index or 1, snapshot.fuelMultiplier or 1, snapshot.inputMultiplier or 1, snapshot.rentalMultiplier or 1))
        end
    end

    function AgriLife.HomeFrame:refreshInsurance()
        baseRefreshInsuranceRoadmap(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration.getSnapshot ~= nil and administration:getSnapshot(farmId) or nil
        if snapshot ~= nil and self.insuranceStatusText ~= nil then
            setText(self.insuranceStatusText, string.format("Administration | conformité %.0f%% | %d sanction(s) | %d événement(s)", tonumber(snapshot.complianceScore) or 0, tonumber(snapshot.openSanctionCount) or 0, tonumber(snapshot.openEventCount) or 0))
        end
    end

    function AgriLife.HomeFrame:refreshBank()
        baseRefreshBankRoadmap(self)
        local bank = self:getBankModule()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local relation = bank ~= nil and bank.getRelationshipSnapshot ~= nil and bank:getRelationshipSnapshot(farmId) or nil
        if relation ~= nil and self.bankStatusText ~= nil then
            local label = tostring(relation.status or "none")
            if relation.status == "active" then label = string.format("Contrat bancaire actif | %d mois restant(s)", tonumber(relation.remainingMonths) or 0) end
            setText(self.bankStatusText, label)
        end
    end
end

-- Roadmap 0.7 interactive controls for the six final modules.
do
    local baseRefreshPayrollInteractive = AgriLife.HomeFrame.refreshPayroll
    local baseRefreshContractsInteractive = AgriLife.HomeFrame.refreshContracts
    local baseRefreshInsuranceInteractive = AgriLife.HomeFrame.refreshInsurance
    local baseRefreshBankInteractive = AgriLife.HomeFrame.refreshBank
    local baseRefreshExamInteractive = AgriLife.HomeFrame.refreshExam

    local function resultMessage(result, fallback)
        if result ~= nil and result.message ~= nil and tostring(result.message) ~= "" then return tostring(result.message) end
        return tostring(fallback or "")
    end

    local function getFarmId(self)
        return self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    end

    local function getActorProfileId(self, farmId)
        local profileId = self:getLocalPayrollProfileId(farmId)
        if profileId ~= nil and tostring(profileId) ~= "" then return tostring(profileId) end
        local people = self:getPeopleModule()
        if people ~= nil and people.getOwnerProfileId ~= nil then
            local ok, value = pcall(people.getOwnerProfileId, people, farmId)
            if ok and value ~= nil then return tostring(value) end
        end
        return ""
    end

    local function normalizeIndex(index, count)
        count = math.max(1, math.floor(tonumber(count) or 1))
        index = math.floor(tonumber(index) or 1)
        return ((index - 1) % count) + 1
    end

    function AgriLife.HomeFrame:getEnterpriseFieldRows()
        local rows = {}
        local fields = g_fieldManager ~= nil and g_fieldManager.fields or nil
        if type(fields) == "table" then
            for key, field in pairs(fields) do
                local id = field ~= nil and (field.fieldId or field.id) or key
                if id ~= nil then
                    local numericId = tonumber(id)
                    table.insert(rows, {id = tostring(id), label = string.format("%s %s", g_i18n:getText("agrilife_enterprise_field"), tostring(numericId or id))})
                end
            end
        end
        table.sort(rows, function(a, b)
            local ai, bi = tonumber(a.id), tonumber(b.id)
            if ai ~= nil and bi ~= nil then return ai < bi end
            return tostring(a.id) < tostring(b.id)
        end)
        return rows
    end

    function AgriLife.HomeFrame:getSelectedEnterpriseOrder(snapshot)
        if snapshot == nil then return nil end
        local profileId = tostring(self.payrollSelectedProfileId or "")
        for index = #(snapshot.orders or {}), 1, -1 do
            local order = snapshot.orders[index]
            if profileId ~= "" and tostring(order.profileId or "") == profileId and order.status ~= "completed" and order.status ~= "cancelled" and order.status ~= "failed" then return order end
        end
        return nil
    end

    function AgriLife.HomeFrame:onClickEnterpriseCandidate()
        local enterprise = self:getEnterpriseModule()
        local snapshot = enterprise ~= nil and enterprise:getSnapshot(getFarmId(self)) or nil
        local count = snapshot ~= nil and #(snapshot.recruitmentMarket or snapshot.candidates or {}) or 0
        if count > 0 then self.enterpriseCandidateIndex = normalizeIndex((self.enterpriseCandidateIndex or 1) + 1, count) end
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseHire()
        local farmId = getFarmId(self)
        local enterprise = self:getEnterpriseModule()
        local snapshot = enterprise ~= nil and enterprise:getSnapshot(farmId) or nil
        local candidates = snapshot ~= nil and (snapshot.recruitmentMarket or snapshot.candidates) or {}
        if #candidates <= 0 then self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_no_candidate"); self:refreshPayroll(); return end
        self.enterpriseCandidateIndex = normalizeIndex(self.enterpriseCandidateIndex, #candidates)
        local candidate = candidates[self.enterpriseCandidateIndex]
        local result = enterprise.hireCandidateWithOffer ~= nil and enterprise:hireCandidateWithOffer(farmId, getActorProfileId(self, farmId), candidate.id, candidate.requestedContract, candidate.requestedSalary) or enterprise:hireCandidate(farmId, getActorProfileId(self, farmId), candidate.id, candidate.requestedContract)
        self.lastEnterpriseMessage = resultMessage(result, g_i18n:getText("agrilife_enterprise_hire_failed"))
        self.enterpriseCandidateIndex = 1
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseRefresh()
        local farmId = getFarmId(self)
        local enterprise = self:getEnterpriseModule()
        if enterprise ~= nil and enterprise.service ~= nil and enterprise.service.refreshCandidateMarket ~= nil then
            local canWrite = self.core == nil or self.core.context == nil or self.core.context.isServer == true
            if canWrite then enterprise.service:refreshCandidateMarket(farmId, true); self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_candidates_refreshed")
            else self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_server_required") end
        end
        self.enterpriseCandidateIndex = 1
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseVehicle()
        local enterprise = self:getEnterpriseModule()
        local rows = enterprise ~= nil and enterprise:getRuntimeVehicleRows(getFarmId(self)) or {}
        if #rows > 0 then self.enterpriseVehicleIndex = normalizeIndex((self.enterpriseVehicleIndex or 1) + 1, #rows) end
        self.enterpriseWorkIndex = 1
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseWorkType()
        local farmId = getFarmId(self)
        local enterprise = self:getEnterpriseModule()
        local vehicles = enterprise ~= nil and enterprise:getRuntimeVehicleRows(farmId) or {}
        local vehicle = #vehicles > 0 and vehicles[normalizeIndex(self.enterpriseVehicleIndex, #vehicles)] or nil
        local rows = enterprise ~= nil and enterprise:getWorkTypeRows(farmId, vehicle ~= nil and vehicle.id or nil) or {}
        if #rows > 0 then self.enterpriseWorkIndex = normalizeIndex((self.enterpriseWorkIndex or 1) + 1, #rows) end
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseField()
        local rows = self:getEnterpriseFieldRows()
        if #rows > 0 then self.enterpriseFieldIndex = normalizeIndex((self.enterpriseFieldIndex or 1) + 1, #rows) end
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseOrderAction()
        local farmId = getFarmId(self)
        local actorProfileId = getActorProfileId(self, farmId)
        local enterprise = self:getEnterpriseModule()
        if enterprise == nil then return end
        local snapshot = enterprise:getSnapshot(farmId)
        local order = self:getSelectedEnterpriseOrder(snapshot)
        local result
        if order ~= nil then
            if order.status == "planned" then result = enterprise:startWorkOrder(farmId, actorProfileId, order.id)
            elseif order.status == "active" then result = enterprise:pauseWorkOrder(farmId, actorProfileId, order.id)
            elseif order.status == "paused" then result = enterprise:resumeWorkOrder(farmId, actorProfileId, order.id) end
        else
            local profileId = tostring(self.payrollSelectedProfileId or "")
            if profileId == "" then self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_select_employee"); self:refreshPayroll(); return end
            local vehicles = enterprise:getRuntimeVehicleRows(farmId)
            local fields = self:getEnterpriseFieldRows()
            if #vehicles <= 0 then self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_no_vehicle"); self:refreshPayroll(); return end
            self.enterpriseVehicleIndex = normalizeIndex(self.enterpriseVehicleIndex, #vehicles)
            local vehicle = vehicles[self.enterpriseVehicleIndex]
            local workTypes = enterprise:getWorkTypeRows(farmId, vehicle.id)
            if #workTypes <= 0 then self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_no_work"); self:refreshPayroll(); return end
            self.enterpriseWorkIndex = normalizeIndex(self.enterpriseWorkIndex, #workTypes)
            if #fields > 0 then self.enterpriseFieldIndex = normalizeIndex(self.enterpriseFieldIndex, #fields) end
            local work = workTypes[self.enterpriseWorkIndex]
            local field = #fields > 0 and fields[self.enterpriseFieldIndex] or nil
            result = enterprise:createWorkOrder(farmId, actorProfileId, profileId, vehicle.id, "", work.id, field ~= nil and field.id or "", "")
            if result ~= nil and result.ok and result.details ~= nil and result.details.order ~= nil then result = enterprise:startWorkOrder(farmId, actorProfileId, result.details.order.id) end
        end
        self.lastEnterpriseMessage = resultMessage(result, g_i18n:getText("agrilife_enterprise_order_failed"))
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseCancelOrder()
        local farmId = getFarmId(self)
        local enterprise = self:getEnterpriseModule()
        local snapshot = enterprise ~= nil and enterprise:getSnapshot(farmId) or nil
        local order = self:getSelectedEnterpriseOrder(snapshot)
        if order == nil then self.lastEnterpriseMessage = g_i18n:getText("agrilife_enterprise_no_order"); self:refreshPayroll(); return end
        local result = enterprise:cancelWorkOrder(farmId, getActorProfileId(self, farmId), order.id)
        self.lastEnterpriseMessage = resultMessage(result, g_i18n:getText("agrilife_enterprise_order_failed"))
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickQualificationSelect()
        local farmId = getFarmId(self)
        local profileId = getActorProfileId(self, farmId)
        local qualifications = self:getQualificationsModule()
        local snapshot = qualifications ~= nil and qualifications:getSnapshot(farmId, profileId) or nil
        local count = snapshot ~= nil and #(snapshot.available or {}) or 0
        if count > 0 then self.qualificationIndex = normalizeIndex((self.qualificationIndex or 1) + 1, count) end
        self:refreshExam()
    end

    function AgriLife.HomeFrame:onClickQualificationTrain()
        local farmId = getFarmId(self)
        local profileId = getActorProfileId(self, farmId)
        local qualifications = self:getQualificationsModule()
        local snapshot = qualifications ~= nil and qualifications:getSnapshot(farmId, profileId) or nil
        local rows = snapshot ~= nil and snapshot.available or {}
        if #rows <= 0 then self.lastExamMessage = g_i18n:getText("agrilife_qualification_none"); self:refreshExam(); return end
        self.qualificationIndex = normalizeIndex(self.qualificationIndex, #rows)
        local row = rows[self.qualificationIndex]
        local result = qualifications:completeTraining(farmId, profileId, row.id, 100)
        self.lastExamMessage = resultMessage(result, g_i18n:getText("agrilife_qualification_failed"))
        self:refreshExam()
    end

    function AgriLife.HomeFrame:onClickAdministrationControl()
        local farmId = getFarmId(self)
        local administration = self:getAdministrationModule()
        local result = administration ~= nil and administration:runControl(farmId, "manual") or nil
        self.lastAdministrationMessage = resultMessage(result, g_i18n:getText("agrilife_admin_action_failed"))
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:onClickAdministrationPaySanction()
        local farmId = getFarmId(self)
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration:getSnapshot(farmId) or nil
        local sanction = nil
        for _, item in ipairs(snapshot ~= nil and snapshot.sanctions or {}) do if item.status ~= "paid" and item.status ~= "cancelled" then sanction = item; break end end
        if sanction == nil then self.lastAdministrationMessage = g_i18n:getText("agrilife_admin_no_sanction"); self:refreshInsurance(); return end
        local result = administration:paySanction(farmId, sanction.id, getActorProfileId(self, farmId))
        self.lastAdministrationMessage = resultMessage(result, g_i18n:getText("agrilife_admin_action_failed"))
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:onClickAdministrationResolveEvent()
        local farmId = getFarmId(self)
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration:getSnapshot(farmId) or nil
        local event = nil
        for _, item in ipairs(snapshot ~= nil and snapshot.events or {}) do if item.status == "open" then event = item; break end end
        if event == nil then self.lastAdministrationMessage = g_i18n:getText("agrilife_admin_no_event"); self:refreshInsurance(); return end
        local result = administration:resolveEvent(farmId, event.id, "pay")
        self.lastAdministrationMessage = resultMessage(result, g_i18n:getText("agrilife_admin_action_failed"))
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:getMarketViewId()
        local views = {"commodities", "farmland", "productions", "rentals"}
        self.marketViewIndex = normalizeIndex(self.marketViewIndex, #views)
        return views[self.marketViewIndex]
    end

    function AgriLife.HomeFrame:onClickMarketView()
        self.marketViewIndex = normalizeIndex((self.marketViewIndex or 1) + 1, 4)
        self.marketRowIndex = 1
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickMarketRent()
        local farmId = getFarmId(self)
        local market = self:getMarketModule()
        if market == nil then return end
        local view = self:getMarketViewId()
        local term = self.marketRentalTerms[normalizeIndex(self.marketRentalTermIndex, #self.marketRentalTerms)]
        local result
        if view == "farmland" then
            local rows = market:getFarmlandMarketRows(farmId)
            if #rows > 0 then self.marketRowIndex = normalizeIndex(self.marketRowIndex, #rows); result = market:createFarmlandRental(farmId, rows[self.marketRowIndex].id, term) end
        elseif view == "productions" then
            local rows = market:getProductionMarketRows(farmId)
            if #rows > 0 then self.marketRowIndex = normalizeIndex(self.marketRowIndex, #rows); result = market:createProductionRental(farmId, rows[self.marketRowIndex].id, term) end
        end
        if result == nil then self.lastMarketMessage = g_i18n:getText("agrilife_market_select_rentable") else self.lastMarketMessage = resultMessage(result, g_i18n:getText("agrilife_market_action_failed")) end
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickMarketTerminate()
        local farmId = getFarmId(self)
        local market = self:getMarketModule()
        local snapshot = market ~= nil and market:getSnapshot(farmId) or nil
        local contract = nil
        for _, item in ipairs(snapshot ~= nil and snapshot.assetRentals or {}) do
            if item.status == "active" or item.status == "matured" or item.status == "defaulted" or item.status == "restore_pending" then contract = item; break end
        end
        if contract == nil then self.lastMarketMessage = g_i18n:getText("agrilife_market_no_rental"); self:refreshContracts(); return end
        local result = market:terminateMarketRental(farmId, contract.id)
        self.lastMarketMessage = resultMessage(result, g_i18n:getText("agrilife_market_action_failed"))
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickBankRelationshipTerm()
        self.bankRelationshipTermIndex = normalizeIndex((self.bankRelationshipTermIndex or 1) + 1, #self.bankRelationshipTerms)
        self:refreshBank()
    end

    function AgriLife.HomeFrame:onClickBankRelationshipAction()
        local farmId = getFarmId(self)
        local bank = self:getBankModule()
        if bank == nil then return end
        local relation = bank:getRelationshipSnapshot(farmId)
        local term = self.bankRelationshipTerms[normalizeIndex(self.bankRelationshipTermIndex, #self.bankRelationshipTerms)]
        local result
        if relation.status == "expired" or (relation.status == "active" and (tonumber(relation.remainingMonths) or 0) <= 1) then result = bank:renewRelationshipContract(farmId, term)
        elseif relation.status ~= "active" then result = bank:signRelationshipContract(farmId, term)
        else result = AgriLife.Result.fail("BANK_RELATION_ALREADY_ACTIVE", g_i18n:getText("agrilife_bank_relationship_already_active")) end
        self.lastBankMessage = resultMessage(result, g_i18n:getText("agrilife_bank_relationship_action_failed"))
        self:refreshBank()
    end

    function AgriLife.HomeFrame:onClickBankRelationshipTerminate()
        local farmId = getFarmId(self)
        local bank = self:getBankModule()
        local result = bank ~= nil and bank:terminateRelationshipContract(farmId, getActorProfileId(self, farmId)) or nil
        self.lastBankMessage = resultMessage(result, g_i18n:getText("agrilife_bank_relationship_action_failed"))
        self:refreshBank()
    end

    function AgriLife.HomeFrame:onClickBankRefinance()
        local farmId = getFarmId(self)
        local bank = self:getBankModule()
        local loan = self:getPrimaryLoan()
        if bank == nil or loan == nil then self.lastBankMessage = g_i18n:getText("agrilife_bank_refinance_no_loan"); self:refreshBank(); return end
        local term = self:getSelectedBankTerm()
        local requestId = string.format("UI_REFI_%d_%s_%d", farmId, tostring(loan.id or "loan"), math.floor(tonumber(g_time) or 0))
        local result = bank:requestRefinance(farmId, loan.id, term, requestId)
        self.lastBankMessage = resultMessage(result, g_i18n:getText("agrilife_bank_refinance_failed"))
        self:refreshBank()
    end

    function AgriLife.HomeFrame:refreshPayroll()
        baseRefreshPayrollInteractive(self)
        local farmId = getFarmId(self)
        local enterprise = self:getEnterpriseModule()
        local snapshot = enterprise ~= nil and enterprise:getSnapshot(farmId) or nil
        if snapshot == nil then return end
        local candidates = snapshot.candidates or {}
        if #candidates > 0 then
            self.enterpriseCandidateIndex = normalizeIndex(self.enterpriseCandidateIndex, #candidates)
            local candidate = candidates[self.enterpriseCandidateIndex]
            setText(self.enterpriseCandidateButton, string.format("%s | %s | %s | %d%%", tostring(candidate.name or "--"), tostring(candidate.requestedContract or "--"), formatMoney(candidate.requestedSalary or 0), math.floor((tonumber(candidate.fitScore) or 0) + 0.5)))
            setDisabled(self.enterpriseHireButton, false)
        else
            setText(self.enterpriseCandidateButton, g_i18n:getText("agrilife_enterprise_no_candidate")); setDisabled(self.enterpriseHireButton, true)
        end
        local vehicles = enterprise:getRuntimeVehicleRows(farmId)
        local selectedVehicle = nil
        if #vehicles > 0 then self.enterpriseVehicleIndex = normalizeIndex(self.enterpriseVehicleIndex, #vehicles); selectedVehicle = vehicles[self.enterpriseVehicleIndex]; setText(self.enterpriseVehicleButton, selectedVehicle.name) else setText(self.enterpriseVehicleButton, g_i18n:getText("agrilife_enterprise_no_vehicle")) end
        local works = enterprise:getWorkTypeRows(farmId, selectedVehicle ~= nil and selectedVehicle.id or nil)
        local fields = self:getEnterpriseFieldRows()
        if #works > 0 then self.enterpriseWorkIndex = normalizeIndex(self.enterpriseWorkIndex, #works); setText(self.enterpriseWorkButton, string.upper(tostring(works[self.enterpriseWorkIndex].id or "--"))) else setText(self.enterpriseWorkButton, g_i18n:getText("agrilife_enterprise_no_work")) end
        if #fields > 0 then self.enterpriseFieldIndex = normalizeIndex(self.enterpriseFieldIndex, #fields); setText(self.enterpriseFieldButton, fields[self.enterpriseFieldIndex].label) else setText(self.enterpriseFieldButton, g_i18n:getText("agrilife_enterprise_field_none")) end
        local order = self:getSelectedEnterpriseOrder(snapshot)
        if order ~= nil then
            setText(self.enterpriseOrderStateText, string.format(g_i18n:getText("agrilife_enterprise_order_state_fmt"), tostring(order.status or "--"), tostring(order.executor or "--"), math.floor((tonumber(order.progress) or 0) * 100 + 0.5)))
            local key = order.status == "active" and "agrilife_enterprise_order_pause" or (order.status == "paused" and "agrilife_enterprise_order_resume" or "agrilife_enterprise_order_start")
            setText(self.enterpriseOrderButton, g_i18n:getText(key)); setDisabled(self.enterpriseCancelOrderButton, false)
        else
            setText(self.enterpriseOrderStateText, self.lastEnterpriseMessage or g_i18n:getText("agrilife_enterprise_no_order")); setText(self.enterpriseOrderButton, g_i18n:getText("agrilife_enterprise_order_create")); setDisabled(self.enterpriseCancelOrderButton, true)
        end
        local selectedProfileId = tostring(self.payrollSelectedProfileId or "")
        if selectedProfileId ~= "" and enterprise.getEmployeeDetails ~= nil then
            local details = enterprise:getEmployeeDetails(farmId, selectedProfileId)
            if details ~= nil then
                local statusKey = "agrilife_enterprise_status_" .. string.lower(tostring(details.workforceStatus or "AVAILABLE"))
                local statusText = g_i18n:getText(statusKey)
                setText(self.payrollAttendanceValue, string.format("%s | %s | H sup. %.1f | Abs. %.1f j | Mal. %.1f j | Congés %.1f j", tostring(details.contractType or "CDI"), tostring(statusText or details.workforceStatus or "--"), tonumber(details.overtimeHours) or 0, tonumber(details.absenceDays) or 0, tonumber(details.sickDays) or 0, tonumber(details.leaveBalanceDays) or 0))
            end
        end
        if self.lastEnterpriseMessage ~= nil and tostring(self.lastEnterpriseMessage) ~= "" then setText(self.payrollStatusText, tostring(self.lastEnterpriseMessage)) end
    end

    function AgriLife.HomeFrame:refreshExam()
        baseRefreshExamInteractive(self)
        local farmId = getFarmId(self)
        local profileId = getActorProfileId(self, farmId)
        local qualifications = self:getQualificationsModule()
        local snapshot = qualifications ~= nil and qualifications:getSnapshot(farmId, profileId) or nil
        local rows = snapshot ~= nil and snapshot.available or {}
        if #rows > 0 then
            self.qualificationIndex = normalizeIndex(self.qualificationIndex, #rows)
            local row = rows[self.qualificationIndex]
            local title = g_i18n:getText(row.titleKey)
            local eligibility = row.eligibility or {}
            local suffix
            if row.obtained then suffix = g_i18n:getText("agrilife_qualification_obtained")
            elseif eligibility.eligible then suffix = string.format(g_i18n:getText("agrilife_qualification_cost_fmt"), formatMoney(eligibility.cost or 0))
            else suffix = g_i18n:getText("agrilife_qualification_locked") end
            setText(self.qualificationSelectButton, string.format("%s | %s", title, suffix))
            setDisabled(self.examCertificationButton, row.obtained == true or eligibility.eligible ~= true)
            setText(self.examCertificationButton, g_i18n:getText("agrilife_qualification_train"))
        else
            setText(self.qualificationSelectButton, g_i18n:getText("agrilife_qualification_none")); setDisabled(self.examCertificationButton, true)
        end
    end

    function AgriLife.HomeFrame:refreshInsurance()
        baseRefreshInsuranceInteractive(self)
        local farmId = getFarmId(self)
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration:getSnapshot(farmId) or nil
        if snapshot == nil then return end
        setText(self.administrationStatusText, string.format(g_i18n:getText("agrilife_admin_summary_fmt"), tonumber(snapshot.complianceScore) or 0, tostring(snapshot.statusId or "small_farm"), tonumber(snapshot.openSanctionCount) or 0, formatMoney(snapshot.unpaidSanctionAmount or 0), tonumber(snapshot.openEventCount) or 0))
        setDisabled(self.administrationSanctionButton, (tonumber(snapshot.openSanctionCount) or 0) <= 0)
        setDisabled(self.administrationEventButton, (tonumber(snapshot.openEventCount) or 0) <= 0)
        if self.lastAdministrationMessage ~= nil then setText(self.insuranceStatusText, tostring(self.lastAdministrationMessage)) end
    end

    function AgriLife.HomeFrame:refreshContracts()
        baseRefreshContractsInteractive(self)
        local farmId = getFarmId(self)
        local market = self:getMarketModule()
        local snapshot = market ~= nil and market:getSnapshot(farmId) or nil
        if snapshot == nil then return end
        local view = self:getMarketViewId()
        local summary = ""
        local rentable = false
        if view == "farmland" then
            local rows = snapshot.farmlandMarket or {}; if #rows > 0 then self.marketRowIndex = normalizeIndex(self.marketRowIndex, #rows); local row = rows[self.marketRowIndex]; summary = string.format(g_i18n:getText("agrilife_market_farmland_fmt"), tostring(row.id), tonumber(row.areaInHa) or 0, formatMoney(row.marketPrice or 0), formatMoney(row.monthlyLeaseEstimate or 0)); rentable = true else summary = g_i18n:getText("agrilife_market_empty") end
        elseif view == "productions" then
            local rows = snapshot.productionMarket or {}; if #rows > 0 then self.marketRowIndex = normalizeIndex(self.marketRowIndex, #rows); local row = rows[self.marketRowIndex]; summary = string.format(g_i18n:getText("agrilife_market_production_fmt"), tostring(row.name or row.id), formatMoney(row.marketValue or 0), tonumber(row.rentalMultiplier) or 1); rentable = true else summary = g_i18n:getText("agrilife_market_empty") end
        elseif view == "rentals" then
            summary = string.format(g_i18n:getText("agrilife_market_rentals_fmt"), tonumber(snapshot.activeAssetRentals) or 0, formatMoney(snapshot.monthlyAssetRental or 0), formatMoney(snapshot.assetRentalExposure or 0))
        else
            local categories = snapshot.categories or {}; local commodity = categories.commodities or {}
            summary = string.format(g_i18n:getText("agrilife_market_indices_fmt"), tonumber(commodity.index) or 1, tonumber(snapshot.fuelMultiplier) or 1, tonumber(snapshot.inputMultiplier) or 1, tonumber(snapshot.rentalMultiplier) or 1)
        end
        setText(self.marketSummaryText, summary)
        setText(self.marketViewButton, g_i18n:getText("agrilife_market_view_" .. view))
        setDisabled(self.marketRentButton, not rentable)
        setDisabled(self.marketTerminateButton, (tonumber(snapshot.activeAssetRentals) or 0) <= 0)
        if self.lastMarketMessage ~= nil then setText(self.contractsStatusText, tostring(self.lastMarketMessage)) end
    end

    function AgriLife.HomeFrame:refreshBank()
        baseRefreshBankInteractive(self)
        local farmId = getFarmId(self)
        local bank = self:getBankModule()
        if bank == nil then return end
        local relation = bank:getRelationshipSnapshot(farmId)
        local term = self.bankRelationshipTerms[normalizeIndex(self.bankRelationshipTermIndex, #self.bankRelationshipTerms)]
        setText(self.bankRelationshipTermButton, string.format(g_i18n:getText("agrilife_bank_relationship_term_fmt"), term))
        local status = tostring(relation.status or "none")
        if status == "active" then
            setText(self.bankRelationshipActionButton, (tonumber(relation.remainingMonths) or 0) <= 1 and g_i18n:getText("agrilife_bank_relationship_renew") or g_i18n:getText("agrilife_bank_relationship_active"))
            setDisabled(self.bankRelationshipActionButton, (tonumber(relation.remainingMonths) or 0) > 1)
            setDisabled(self.bankRelationshipTerminateButton, false)
        elseif status == "expired" then
            setText(self.bankRelationshipActionButton, g_i18n:getText("agrilife_bank_relationship_renew")); setDisabled(self.bankRelationshipActionButton, false); setDisabled(self.bankRelationshipTerminateButton, true)
        else
            setText(self.bankRelationshipActionButton, g_i18n:getText("agrilife_bank_relationship_sign")); setDisabled(self.bankRelationshipActionButton, false); setDisabled(self.bankRelationshipTerminateButton, true)
        end
        local loan = self:getPrimaryLoan()
        setDisabled(self.bankRefinanceButton, loan == nil or status ~= "active")
        if self.bankAccountSummary ~= nil then
            local base = tostring(self.bankAccountSummary.text or "")
            local relationText = status == "active" and string.format(g_i18n:getText("agrilife_bank_relationship_active_fmt"), tonumber(relation.remainingMonths) or 0) or g_i18n:getText("agrilife_bank_relationship_" .. (status == "expired" and "expired" or "none"))
            if base ~= "" then setText(self.bankAccountSummary, base .. " | " .. relationText) end
        end
    end
end


-- Roadmap 0.7 journal dialog. Journal remains transversal and does not add a seventh dashboard card.
do
    function AgriLife.HomeFrame:onClickJournal()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local journal = self:getJournalModule()
        local snapshot = journal ~= nil and journal.getSnapshot ~= nil and journal:getSnapshot(farmId, 12) or {count = 0, entries = {}}
        if self.core ~= nil and self.core.ui ~= nil and self.core.ui.showJournalDialog ~= nil then
            self.core.ui:showJournalDialog(snapshot)
        end
    end
end

-- Roadmap 0.7 banking accounting controls.
do
    local baseRefreshBankAccounting = AgriLife.HomeFrame.refreshBank

    function AgriLife.HomeFrame:onClickBankTaxPay()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local bank = self:getBankModule()
        local accounting = bank ~= nil and bank.getAccountingSnapshot ~= nil and bank:getAccountingSnapshot(farmId) or nil
        local liability = nil
        for _, item in ipairs(accounting ~= nil and accounting.taxLiabilities or {}) do
            if item.status == "open" or item.status == "overdue" then liability = item; break end
        end
        if liability == nil then
            self.lastBankMessage = g_i18n:getText("agrilife_bank_tax_none")
        else
            local result = bank:payTax(farmId, liability.id, nil)
            self.lastBankMessage = result ~= nil and result.ok and g_i18n:getText("agrilife_bank_tax_payment_ok") or g_i18n:getText("agrilife_bank_tax_payment_failed")
        end
        self:refreshBank()
    end

    function AgriLife.HomeFrame:refreshBank()
        baseRefreshBankAccounting(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local bank = self:getBankModule()
        local accounting = bank ~= nil and bank.getAccountingSnapshot ~= nil and bank:getAccountingSnapshot(farmId) or nil
        if accounting == nil then return end
        local current = accounting.current or {}
        local cashflow = accounting.cashflow or {}
        if self.bankStatementFeeSummary ~= nil then
            setText(self.bankStatementFeeSummary, string.format(
                g_i18n:getText("agrilife_bank_accounting_summary_fmt"),
                formatMoney(current.profit or 0),
                formatMoney(accounting.outstandingTax or 0),
                formatMoney(cashflow.projectedNet or 0)
            ))
        end
        setDisabled(self.bankTaxPayButton, (tonumber(accounting.outstandingTax) or 0) <= 0)
    end
end

-- Roadmap step 4 workforce planning, training, career and incident views.
do
    local baseRefreshPayrollWorkforceViews = AgriLife.HomeFrame.refreshPayroll
    local DETAIL_VIEWS = {"OVERVIEW", "EMPLOYEE", "PLANNING", "TRAINING", "CAREER", "INCIDENTS"}

    local function normalizeDetailIndex(value, count)
        count = math.max(1, tonumber(count) or 1)
        value = tonumber(value) or 1
        while value < 1 do value = value + count end
        while value > count do value = value - count end
        return value
    end

    local function getEnterpriseFarmId(self)
        return self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    end

    local function getEnterpriseActor(self, farmId)
        if self.getLocalPayrollProfileId ~= nil then return tostring(self:getLocalPayrollProfileId(farmId) or "") end
        return ""
    end

    local function trEnterprise(key, fallback)
        if g_i18n == nil or g_i18n.getText == nil then return fallback or key end
        local value = g_i18n:getText(key)
        if value == nil or value == "" or value == key then return fallback or key end
        return value
    end

    local function workLabel(workType)
        local id = string.lower(tostring(workType or ""))
        return trEnterprise("agrilife_enterprise_work_" .. id, string.upper(id))
    end

    local function specialtyLabel(specialty)
        local id = string.lower(tostring(specialty or ""))
        return trEnterprise("agrilife_enterprise_specialty_" .. id, string.upper(id))
    end

    local function pressureLabel(pressure)
        return trEnterprise("agrilife_enterprise_pressure_" .. string.lower(tostring(pressure or "LOW")), tostring(pressure or "LOW"))
    end

    local function resultText(result, fallbackKey)
        if result ~= nil and result.message ~= nil and tostring(result.message) ~= "" then return tostring(result.message) end
        return trEnterprise(fallbackKey, "--")
    end

    function AgriLife.HomeFrame:getEnterpriseDetailView()
        self.enterpriseDetailViewIndex = normalizeDetailIndex(self.enterpriseDetailViewIndex or 1, #DETAIL_VIEWS)
        return DETAIL_VIEWS[self.enterpriseDetailViewIndex]
    end

    function AgriLife.HomeFrame:onClickEnterpriseView()
        self.enterpriseDetailViewIndex = normalizeDetailIndex((self.enterpriseDetailViewIndex or 1) + 1, #DETAIL_VIEWS)
        self.enterpriseDetailRowIndex = 1
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseDetailPrev()
        self.enterpriseDetailRowIndex = math.max(1, (tonumber(self.enterpriseDetailRowIndex) or 1) - 1)
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseDetailNext()
        self.enterpriseDetailRowIndex = (tonumber(self.enterpriseDetailRowIndex) or 1) + 1
        self:refreshPayroll()
    end

    function AgriLife.HomeFrame:onClickEnterpriseDetailAction()
        local enterprise = self:getEnterpriseModule()
        local farmId = getEnterpriseFarmId(self)
        if enterprise == nil or farmId <= 0 then return end
        local actor = getEnterpriseActor(self, farmId)
        local profileId = tostring(self.payrollSelectedProfileId or "")
        local view = self:getEnterpriseDetailView()
        local result = nil

        if view == "PLANNING" then
            local rows = enterprise:getWorkQueue(farmId, false) or {}
            if #rows > 0 then
                self.enterpriseDetailRowIndex = normalizeDetailIndex(self.enterpriseDetailRowIndex or 1, #rows)
                local row = rows[self.enterpriseDetailRowIndex]
                if row.status == "QUEUED" or row.status == "BLOCKED" then
                    result = enterprise:dispatchQueuedWork(farmId, actor, row.id)
                elseif row.status == "PLANNED" or row.status == "STARTED" then
                    result = enterprise:cancelQueuedWork(farmId, actor, row.id)
                end
            end
        elseif view == "TRAINING" and profileId ~= "" then
            local rows = {}
            for _, row in ipairs(enterprise:getEmployeeTrainingCatalog(farmId, profileId) or {}) do
                if row.type == "SKILL" then table.insert(rows, row) end
            end
            if #rows > 0 and enterprise:getEmployeeTrainingStatus(farmId, profileId) == nil then
                self.enterpriseDetailRowIndex = normalizeDetailIndex(self.enterpriseDetailRowIndex or 1, #rows)
                result = enterprise:startEmployeeTraining(farmId, actor, profileId, rows[self.enterpriseDetailRowIndex].id)
            end
        elseif view == "CAREER" and profileId ~= "" then
            result = enterprise:promoteEmployeeCareer(farmId, actor, profileId)
        end

        if result ~= nil then
            self.lastEnterpriseMessage = resultText(result, result.ok and "agrilife_enterprise_action_ok" or "agrilife_enterprise_action_failed")
        end
        self:refreshPayroll()
    end

    local function renderForecast(forecast)
        forecast = forecast or {}
        return string.format(
            trEnterprise("agrilife_enterprise_forecast_fmt", "%d j | charge %d min | capacité %d min | pression %s | saisonniers %d | priorité %s"),
            tonumber(forecast.horizonDays) or 7,
            tonumber(forecast.demandMinutes) or 0,
            tonumber(forecast.capacityMinutes) or 0,
            pressureLabel(forecast.pressure),
            tonumber(forecast.recommendedSeasonals) or 0,
            specialtyLabel(forecast.primarySpecialty ~= "" and forecast.primarySpecialty or "none")
        )
    end

    function AgriLife.HomeFrame:refreshPayroll()
        baseRefreshPayrollWorkforceViews(self)
        local enterprise = self:getEnterpriseModule()
        local farmId = getEnterpriseFarmId(self)
        if enterprise == nil or farmId <= 0 then return end

        local profileId = tostring(self.payrollSelectedProfileId or "")
        local planning = enterprise:getWorkforcePlanningSnapshot(farmId, profileId)
        local forecast = planning ~= nil and planning.forecast or enterprise:getWorkforceForecast(farmId, 7)
        local forecastText = renderForecast(forecast)
        local message = tostring(self.lastEnterpriseMessage or "")
        setText(self.payrollStatusText, message ~= "" and (message .. "\n" .. forecastText) or forecastText)

        local view = self:getEnterpriseDetailView()
        setText(self.enterpriseViewButton, trEnterprise("agrilife_enterprise_view_" .. string.lower(view), view))
        setVisible(self.enterpriseDetailOverlay, view ~= "OVERVIEW")
        if view == "OVERVIEW" then return end

        local rows = {}
        local title = "--"
        local body = "--"
        local actionText = trEnterprise("agrilife_enterprise_action_none", "--")
        local actionDisabled = true
        local navigationDisabled = true

        if view == "EMPLOYEE" then
            title = trEnterprise("agrilife_enterprise_employee_sheet_title", "Dossier salarié")
            local sheet = profileId ~= "" and enterprise:getEmployeeFullSheet(farmId, profileId) or nil
            if sheet == nil then
                body = trEnterprise("agrilife_enterprise_detail_select_employee", "Sélectionnez un salarié.")
            else
                local specialty = sheet.specialty or {}
                local career = sheet.career or {}
                local work = sheet.workSummary or {}
                local activeOrder = sheet.activeOrder
                local orderText = activeOrder ~= nil and string.format("%s / %s / %d%%", workLabel(activeOrder.workType), tostring(activeOrder.status or "--"), math.floor((tonumber(activeOrder.progress) or 0) * 100 + 0.5)) or trEnterprise("agrilife_enterprise_no_order", "Aucun ordre actif")
                body = string.format(
                    trEnterprise("agrilife_enterprise_employee_sheet_fmt", "%s | %s | %s | ancienneté %d mois\nStatut %s | salaire %s | brut %s | coût employeur %s\nSpécialité %s %d/100 | XP %d | performance %.0f/100\nHeures %.1f | sup. %.1f | congés %.1f j | maladie %.1f j | absences %.1f j\nOrdre : %s"),
                    tostring(sheet.displayName or "--"), tostring(sheet.role or "--"), tostring(sheet.contractType or "--"), tonumber(sheet.seniorityMonths) or 0,
                    tostring(sheet.status or "--"), formatMoney(sheet.monthlySalary or 0), formatMoney(sheet.monthlyGross or 0), formatMoney(sheet.employerCost or 0),
                    specialtyLabel(specialty.primary or "none"), tonumber(specialty.specialtySkill) or 0, tonumber(career.totalXP or (sheet.xp ~= nil and sheet.xp.total) or 0) or 0, tonumber(career.performanceScore) or 50,
                    (tonumber(work.workedMinutes) or 0) / 60, tonumber(sheet.overtimeHours) or 0, tonumber(sheet.leaveBalanceDays) or 0, tonumber(sheet.sickDays) or 0, tonumber(sheet.absenceDays) or 0, orderText
                )
            end
        elseif view == "PLANNING" then
            title = trEnterprise("agrilife_enterprise_planning_title", "Planning")
            rows = planning ~= nil and planning.queue or {}
            navigationDisabled = #rows <= 1
            if #rows > 0 then
                self.enterpriseDetailRowIndex = normalizeDetailIndex(self.enterpriseDetailRowIndex or 1, #rows)
                local row = rows[self.enterpriseDetailRowIndex]
                body = string.format(
                    trEnterprise("agrilife_enterprise_planning_item_fmt", "%d/%d | %s | %s | priorité %d | %d min\nSalarié %s | véhicule %s\n%s"),
                    self.enterpriseDetailRowIndex,
                    #rows,
                    workLabel(row.workType),
                    trEnterprise("agrilife_enterprise_queue_status_" .. string.lower(tostring(row.status or "queued")), tostring(row.status or "--")),
                    tonumber(row.priority) or 0,
                    tonumber(row.estimatedMinutes) > 0 and tonumber(row.estimatedMinutes) or 0,
                    tostring(row.profileId or "--"),
                    tostring(row.vehicleId or "--"),
                    tostring(row.blockedReason or "")
                ) .. "\n\n" .. forecastText
                if row.status == "QUEUED" or row.status == "BLOCKED" then
                    actionText = trEnterprise("agrilife_enterprise_planning_dispatch", "Démarrer")
                    actionDisabled = false
                elseif row.status == "PLANNED" or row.status == "STARTED" then
                    actionText = trEnterprise("agrilife_enterprise_planning_cancel", "Annuler")
                    actionDisabled = false
                end
            else
                body = trEnterprise("agrilife_enterprise_planning_empty", "Aucun travail planifié.") .. "\n\n" .. forecastText
            end
        elseif view == "TRAINING" then
            title = trEnterprise("agrilife_enterprise_training_title", "Formation")
            if profileId == "" then
                body = trEnterprise("agrilife_enterprise_detail_select_employee", "Sélectionnez un salarié.")
            else
                local active = enterprise:getEmployeeTrainingStatus(farmId, profileId)
                if active ~= nil then
                    body = string.format(trEnterprise("agrilife_enterprise_training_active_fmt", "%s | %s | %d période(s) restante(s) | %s"), tostring(active.id or "--"), specialtyLabel(active.specialty), tonumber(active.remainingPeriods) or 0, formatMoney(active.cost or 0))
                    actionText = trEnterprise("agrilife_enterprise_training_active", "Formation en cours")
                else
                    for _, row in ipairs(enterprise:getEmployeeTrainingCatalog(farmId, profileId) or {}) do if row.type == "SKILL" then table.insert(rows, row) end end
                    navigationDisabled = #rows <= 1
                    if #rows > 0 then
                        self.enterpriseDetailRowIndex = normalizeDetailIndex(self.enterpriseDetailRowIndex or 1, #rows)
                        local row = rows[self.enterpriseDetailRowIndex]
                        body = string.format(trEnterprise("agrilife_enterprise_training_item_fmt", "%d/%d | %s\nCoût %s | durée %d période(s)"), self.enterpriseDetailRowIndex, #rows, specialtyLabel(row.specialty), formatMoney(row.cost or 0), tonumber(row.durationPeriods) or 1)
                        actionText = trEnterprise("agrilife_enterprise_training_start", "Démarrer la formation")
                        actionDisabled = false
                    else
                        body = trEnterprise("agrilife_enterprise_training_empty", "Aucune formation disponible.")
                    end
                end
            end
        elseif view == "CAREER" then
            title = trEnterprise("agrilife_enterprise_career_title", "Carrière salarié")
            local career = planning ~= nil and planning.career or nil
            local promotion = planning ~= nil and planning.promotion or nil
            if career == nil then
                body = trEnterprise("agrilife_enterprise_detail_select_employee", "Sélectionnez un salarié.")
            else
                local eligibility = promotion ~= nil and promotion.eligible == true and trEnterprise("agrilife_enterprise_promotion_ready", "Promotion possible") or trEnterprise("agrilife_enterprise_promotion_locked", "Promotion non disponible")
                body = string.format(
                    trEnterprise("agrilife_enterprise_career_fmt", "Niveau %d | XP %d | ancienneté %d mois\nPerformance %.0f/100 | réussites %d | échecs %d\nFormations %d | incidents %d | promotions %d\n%s"),
                    tonumber(career.workforceLevel) or 1,
                    tonumber(career.totalXP) or 0,
                    tonumber(career.seniorityMonths) or 0,
                    tonumber(career.performanceScore) or 50,
                    tonumber(career.completedOrders) or 0,
                    tonumber(career.failedOrders) or 0,
                    tonumber(career.trainingCount) or 0,
                    tonumber(career.incidents) or 0,
                    tonumber(career.promotions) or 0,
                    eligibility
                )
                actionText = trEnterprise("agrilife_enterprise_promotion_action", "Promouvoir")
                actionDisabled = promotion == nil or promotion.eligible ~= true
            end
        elseif view == "INCIDENTS" then
            title = trEnterprise("agrilife_enterprise_incidents_title", "Incidents")
            rows = planning ~= nil and planning.incidents or {}
            navigationDisabled = #rows <= 1
            if #rows > 0 then
                self.enterpriseDetailRowIndex = normalizeDetailIndex(self.enterpriseDetailRowIndex or 1, #rows)
                local incident = rows[self.enterpriseDetailRowIndex]
                body = string.format(
                    trEnterprise("agrilife_enterprise_incident_fmt", "%d/%d | %s | %s\nDégâts estimés %s | période %d\n%s"),
                    self.enterpriseDetailRowIndex,
                    #rows,
                    trEnterprise("agrilife_enterprise_incident_severity_" .. string.lower(tostring(incident.severity or "minor")), tostring(incident.severity or "--")),
                    tostring(incident.category or "--"),
                    formatMoney(incident.estimatedDamage or 0),
                    tonumber(incident.periodKey) or 0,
                    tostring(incident.description or "")
                )
            else
                body = trEnterprise("agrilife_enterprise_incidents_empty", "Aucun incident enregistré pour ce salarié.")
            end
        end

        setText(self.enterpriseDetailTitle, title)
        setText(self.enterpriseDetailText, body)
        setText(self.enterpriseDetailActionButton, actionText)
        setDisabled(self.enterpriseDetailActionButton, actionDisabled)
        setDisabled(self.enterpriseDetailPrevButton, navigationDisabled or (tonumber(self.enterpriseDetailRowIndex) or 1) <= 1)
        setDisabled(self.enterpriseDetailNextButton, navigationDisabled or #rows == 0 or (tonumber(self.enterpriseDetailRowIndex) or 1) >= #rows)
    end
end

-- Roadmap step 6 - Administration unified player view.
do
    local baseRefreshAdministrationRoadmap6 = AgriLife.HomeFrame.refreshInsurance

    local function adminTr(key, fallback)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local value = g_i18n:getText(key)
            if value ~= nil and value ~= "" and value ~= key then return value end
        end
        return fallback or key
    end

    local function joinRows(rows)
        if rows == nil or #rows == 0 then return adminTr("agrilife_admin_none", "Aucun") end
        return table.concat(rows, ", ")
    end

    local function firstRegularizable(snapshot)
        local allowed = {registration = true, accounts = true, risk_register = true}
        for _, raw in ipairs(snapshot ~= nil and snapshot.missingRequirements or {}) do
            local id = tostring(raw or ""):match("^[^:]+") or ""
            if allowed[id] then return id end
        end
        return nil
    end

    function AgriLife.HomeFrame:onClickAdministrationUpgradeStatus()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local administration = self:getAdministrationModule()
        local result = administration ~= nil and administration.requestStatusUpgrade ~= nil and administration:requestStatusUpgrade(farmId) or nil
        self.lastAdministrationMessage = result ~= nil and result.message or adminTr("agrilife_admin_action_failed", "Action administrative impossible")
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:onClickAdministrationRegularize()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration.getSnapshot ~= nil and administration:getSnapshot(farmId) or nil
        local requirementId = firstRegularizable(snapshot)
        local result = requirementId ~= nil and administration ~= nil and administration.regularizeRequirement ~= nil and administration:regularizeRequirement(farmId, requirementId) or nil
        self.lastAdministrationMessage = result ~= nil and result.message or adminTr("agrilife_admin_no_regularization", "Aucune formalité régularisable depuis cet écran")
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:onClickAdministrationPaymentPlan()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local legal = self:getLegalModule()
        local result = legal ~= nil and legal.requestPaymentPlan ~= nil and legal:requestPaymentPlan(farmId, 12) or nil
        self.lastAdministrationMessage = result ~= nil and result.message or adminTr("agrilife_admin_no_legal_case", "Aucun contentieux éligible")
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:onClickAdministrationContestCase()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local legal = self:getLegalModule()
        local result = legal ~= nil and legal.contestCase ~= nil and legal:contestCase(farmId) or nil
        self.lastAdministrationMessage = result ~= nil and result.message or adminTr("agrilife_admin_no_legal_case", "Aucun contentieux éligible")
        self:refreshInsurance()
    end

    function AgriLife.HomeFrame:refreshInsurance()
        baseRefreshAdministrationRoadmap6(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local administration = self:getAdministrationModule()
        local snapshot = administration ~= nil and administration.getSnapshot ~= nil and administration:getSnapshot(farmId) or nil
        if snapshot == nil then return end

        local health = snapshot.health or {}
        local restrictions = snapshot.restrictions or {}
        local nextStatus = snapshot.nextStatus
        local statusLabel = adminTr(snapshot.statusLabelKey or "agrilife_admin_status_small_farm", tostring(snapshot.businessStatus or "small_farm"))
        local summary = string.format(
            adminTr("agrilife_admin_roadmap6_summary_fmt", "%s | conformité %.0f%% | santé %.0f/100 | %d sanction(s)"),
            statusLabel,
            tonumber(snapshot.complianceScore) or 0,
            tonumber(health.score) or 0,
            tonumber(snapshot.openSanctionCount or snapshot.openSanctions) or 0
        )
        if tostring(self.lastAdministrationMessage or "") ~= "" then summary = tostring(self.lastAdministrationMessage) .. "\n" .. summary end
        setText(self.administrationStatusText, summary)

        local detail
        if nextStatus == nil then
            detail = adminTr("agrilife_admin_status_max", "Statut maximal atteint")
        elseif nextStatus.eligible == true then
            detail = adminTr("agrilife_admin_status_upgrade_ready", "Évolution de statut disponible")
        else
            detail = string.format(adminTr("agrilife_admin_status_missing_fmt", "Prochain statut : exigences manquantes : %s"), joinRows(nextStatus.missing or {}))
        end
        setText(self.administrationDetailText, detail)

        local restrictionText
        if restrictions.businessSuspended == true then
            restrictionText = string.format(adminTr("agrilife_admin_restriction_suspended_fmt", "ACTIVITÉ SUSPENDUE : %s"), tostring(restrictions.reason or "--"))
        elseif restrictions.financingBlocked or restrictions.newContractsBlocked or restrictions.automatedWorkBlocked then
            restrictionText = string.format(adminTr("agrilife_admin_restriction_active_fmt", "Restriction active : %s"), tostring(restrictions.reason or "--"))
        else
            local legal = snapshot.legal or {}
            restrictionText = string.format(adminTr("agrilife_admin_legal_fmt", "Contentieux : %s | dette %s"), tostring(legal.stage or "current"), formatMoney(legal.debt or 0))
        end
        setText(self.administrationRestrictionText, restrictionText)

        setDisabled(self.administrationUpgradeButton, nextStatus == nil or nextStatus.eligible ~= true)
        setDisabled(self.administrationRegularizeButton, firstRegularizable(snapshot) == nil)
        local legalSnapshot = snapshot.legal or {}
        setDisabled(self.administrationPaymentPlanButton, (tonumber(legalSnapshot.debt) or 0) <= 0 or legalSnapshot.paymentPlan ~= nil)
        setDisabled(self.administrationContestButton, (tonumber(legalSnapshot.debt) or 0) <= 0 or legalSnapshot.contested == true)
    end
end
