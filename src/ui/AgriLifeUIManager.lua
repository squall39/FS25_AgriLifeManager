-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.UIManager = {}
AgriLife.UIManager.__index = AgriLife.UIManager

function AgriLife.UIManager.new(core)
    local sessionId = core ~= nil and core.context ~= nil and core.context.sessionId or 0
    return setmetatable({
        core = core,
        frame = nil,
        inGameMenu = nil,
        pageName = "pageAgriLifeManager6",
        guiName = string.format("AgriLifeHomeFrame_%d", sessionId),
        tutorialGuiName = string.format("AgriLifeTutorialDialog_%d", sessionId),
        tutorialDialog = nil,
        tutorialDialogLoaded = false,
        journalGuiName = string.format("AgriLifeJournalDialog_%d", sessionId),
        journalDialog = nil,
        journalDialogLoaded = false,
        accidentStatementGuiName = string.format("AgriLifeAccidentStatementDialog_%d", sessionId),
        accidentStatementDialog = nil,
        accidentStatementDialogLoaded = false,
        mounted = false,
        guiLoaded = false,
        tutorialPromptPollMs = 0,
        tutorialGameplayReadyMs = 0,
        tutorialLastBlockReason = nil
    }, AgriLife.UIManager)
end


function AgriLife.UIManager:loadTutorialDialog()
    if self.tutorialDialogLoaded and self.tutorialDialog ~= nil then return true end
    if g_gui == nil or g_gui.loadGui == nil or AgriLife.TutorialDialog == nil then return false end
    local dialog = AgriLife.TutorialDialog.new()
    local xmlPath = Utils.getFilename("gui/AgriLifeTutorialDialog.xml", AgriLife.Version.MOD_DIR)
    local ok, value = pcall(g_gui.loadGui, g_gui, xmlPath, self.tutorialGuiName, dialog, false)
    if not ok or value == false then
        if dialog ~= nil and dialog.delete ~= nil then pcall(dialog.delete, dialog) end
        AgriLife.Logger.warning("UI", "Paged tutorial dialog could not be loaded: %s", tostring(value))
        return false
    end
    self.tutorialDialog = dialog
    self.tutorialDialogLoaded = true
    return true
end

function AgriLife.UIManager:showTutorialDialog(pages, callback)
    if not self:loadTutorialDialog() then return false end
    self.tutorialDialog:setData(pages, callback, nil, nil)
    local ok, dialog = pcall(g_gui.showDialog, g_gui, self.tutorialGuiName, true)
    return ok and dialog ~= nil
end

function AgriLife.UIManager:unloadTutorialDialog()
    if self.tutorialDialog ~= nil then
        if g_gui ~= nil and g_gui.closeDialogByName ~= nil then pcall(g_gui.closeDialogByName, g_gui, self.tutorialGuiName) end
        self:clearGuiRegistration(self.tutorialDialog)
        if self.tutorialDialog.delete ~= nil then pcall(self.tutorialDialog.delete, self.tutorialDialog) end
    end
    self.tutorialDialog = nil
    self.tutorialDialogLoaded = false
end

function AgriLife.UIManager:loadJournalDialog()
    if self.journalDialogLoaded and self.journalDialog ~= nil then return true end
    if g_gui == nil or g_gui.loadGui == nil or AgriLife.JournalDialog == nil then return false end
    local dialog = AgriLife.JournalDialog.new()
    local xmlPath = Utils.getFilename("gui/AgriLifeJournalDialog.xml", AgriLife.Version.MOD_DIR)
    local ok, value = pcall(g_gui.loadGui, g_gui, xmlPath, self.journalGuiName, dialog, false)
    if not ok or value == false then
        if dialog ~= nil and dialog.delete ~= nil then pcall(dialog.delete, dialog) end
        AgriLife.Logger.warning("UI", "Journal dialog could not be loaded: %s", tostring(value))
        return false
    end
    self.journalDialog = dialog
    self.journalDialogLoaded = true
    return true
end

function AgriLife.UIManager:showJournalDialog(snapshot)
    if not self:loadJournalDialog() then return false end
    self.journalDialog:setData(snapshot)
    local ok, dialog = pcall(g_gui.showDialog, g_gui, self.journalGuiName, true)
    return ok and dialog ~= nil
end

function AgriLife.UIManager:unloadJournalDialog()
    if self.journalDialog ~= nil then
        if g_gui ~= nil and g_gui.closeDialogByName ~= nil then pcall(g_gui.closeDialogByName, g_gui, self.journalGuiName) end
        self:clearGuiRegistration(self.journalDialog)
        if self.journalDialog.delete ~= nil then pcall(self.journalDialog.delete, self.journalDialog) end
    end
    self.journalDialog = nil
    self.journalDialogLoaded = false
end

function AgriLife.UIManager:loadAccidentStatementDialog()
    if self.accidentStatementDialogLoaded and self.accidentStatementDialog ~= nil then return true end
    if g_gui == nil or g_gui.loadGui == nil or AgriLife.AccidentStatementDialog == nil then return false end
    local dialog = AgriLife.AccidentStatementDialog.new()
    local xmlPath = Utils.getFilename("gui/RoadAccidentDialog.xml", AgriLife.Version.MOD_DIR)
    local ok, value = pcall(g_gui.loadGui, g_gui, xmlPath, self.accidentStatementGuiName, dialog, false)
    if not ok or value == false then
        if dialog ~= nil and dialog.delete ~= nil then pcall(dialog.delete, dialog) end
        AgriLife.Logger.warning("UI", "Accident statement dialog could not be loaded: %s", tostring(value))
        return false
    end
    self.accidentStatementDialog = dialog
    self.accidentStatementDialogLoaded = true
    return true
end

function AgriLife.UIManager:showAccidentStatementDialog(workshop, farmId, accidents, selectedAccidentId, actorProfileId, callback)
    if not self:loadAccidentStatementDialog() then return false end
    self.accidentStatementDialog:setData(workshop, farmId, accidents, selectedAccidentId, actorProfileId, callback)
    local ok, dialog = pcall(g_gui.showDialog, g_gui, self.accidentStatementGuiName, true)
    return ok and dialog ~= nil
end

function AgriLife.UIManager:unloadAccidentStatementDialog()
    if self.accidentStatementDialog ~= nil then
        if g_gui ~= nil and g_gui.closeDialogByName ~= nil then pcall(g_gui.closeDialogByName, g_gui, self.accidentStatementGuiName) end
        self:clearGuiRegistration(self.accidentStatementDialog)
        if self.accidentStatementDialog.delete ~= nil then pcall(self.accidentStatementDialog.delete, self.accidentStatementDialog) end
    end
    self.accidentStatementDialog = nil
    self.accidentStatementDialogLoaded = false
end

function AgriLife.UIManager:getInGameMenu()
    -- FS25 does not expose the in-game menu through exactly the same global
    -- path at every point of mission startup. Prefer the mission/global
    -- references, then the GUI controller table, and finally scan the
    -- registered controllers for an object that has the InGameMenu API.
    if g_currentMission ~= nil and g_currentMission.inGameMenu ~= nil then
        return g_currentMission.inGameMenu
    end

    if g_inGameMenu ~= nil then
        return g_inGameMenu
    end

    -- On current FS25 builds the loaded GUI entry can already own the menu
    -- target even when screenControllers has not exposed it under InGameMenu.
    if g_gui ~= nil and g_gui.guis ~= nil then
        local guiEntry = g_gui.guis["InGameMenu"]
        if type(guiEntry) == "table" then
            local candidates = { guiEntry.target, guiEntry.controller, guiEntry.screen, guiEntry.gui }
            for _, candidate in ipairs(candidates) do
                if type(candidate) == "table"
                    and candidate.pagingElement ~= nil
                    and candidate.registerPage ~= nil
                    and candidate.addPageTab ~= nil then
                    return candidate
                end
            end
        end
    end

    if g_gui ~= nil and g_gui.screenControllers ~= nil then
        if InGameMenu ~= nil and g_gui.screenControllers[InGameMenu] ~= nil then
            return g_gui.screenControllers[InGameMenu]
        end

        if g_gui.screenControllers["InGameMenu"] ~= nil then
            return g_gui.screenControllers["InGameMenu"]
        end

        for _, controller in pairs(g_gui.screenControllers) do
            if type(controller) == "table"
                and controller.pagingElement ~= nil
                and controller.registerPage ~= nil
                and controller.addPageTab ~= nil
                and controller.rebuildTabList ~= nil
                and (controller.pageMapOverview ~= nil
                    or controller.pagePrices ~= nil
                    or controller.pageFinances ~= nil
                    or controller.pageCalendar ~= nil) then
                return controller
            end
        end
    end

    return nil
end


function AgriLife.UIManager:getCurrentGuiName()
    if g_gui == nil then return nil end

    -- currentListener is the most reliable FS25 indicator for full-screen
    -- controllers such as WardrobeScreen. The previous implementation only
    -- looked at currentGui; on 1.21 this can remain a non-nil internal entry
    -- even after returning to gameplay and kept the tutorial blocked forever.
    local listener = g_gui.currentListener
    if type(listener) == "table" then
        local value = listener.name or listener.guiName or listener.id
        if value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end

    if type(g_gui.currentGuiName) == "string" and g_gui.currentGuiName ~= "" then
        return g_gui.currentGuiName
    end
    if g_gui.getCurrentGuiName ~= nil then
        local ok, value = pcall(g_gui.getCurrentGuiName, g_gui)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
    local current = g_gui.currentGui
    if type(current) == "table" then
        local target = current.target or current.controller or current.screen or current.gui or current
        if type(target) == "table" then
            local value = target.name or target.guiName or target.id
            if value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
    end
    return nil
end

function AgriLife.UIManager:getTutorialBlockReason()
    if not self.mounted or self.frame == nil or self.core == nil or self.core.context == nil then return "ui-not-mounted" end
    local mission = g_currentMission or self.core.context.mission
    if mission == nil then return "mission-not-ready" end
    -- FS25 exposes the local avatar primarily through g_localPlayer. Some
    -- mission implementations also keep mission.player, so accept either.
    if g_localPlayer == nil and mission.player == nil then return "player-not-ready" end
    local farmId = tonumber(self.core.context:getFarmId()) or 0
    if farmId <= 0 then return "farm-not-ready" end

    if g_gui ~= nil and g_gui.getIsDialogVisible ~= nil then
        local okDialog, dialogVisible = pcall(g_gui.getIsDialogVisible, g_gui)
        if okDialog and dialogVisible == true then return "dialog-open" end
    end

    local guiName = self:getCurrentGuiName()
    if guiName ~= nil then
        local normalized = string.lower(tostring(guiName)):gsub("[^%w]", "")
        -- FS25 character creation uses WardrobeScreen. Keep a few aliases for
        -- maps/mods that wrap that screen in their own character controller.
        if normalized:find("wardrobe", 1, true) ~= nil
            or normalized:find("character", 1, true) ~= nil
            or normalized:find("playercustom", 1, true) ~= nil
            or normalized:find("playerselection", 1, true) ~= nil then
            return "character-screen:" .. tostring(guiName)
        end

        -- currentListener represents an actually active FS25 screen. Blocking
        -- here prevents the guide from appearing over ESC/shop/other screens.
        -- Unlike currentGui, this is not the stale entry that caused 0.6.4.1
        -- to wait forever after character creation.
        if g_gui ~= nil and g_gui.currentListener ~= nil then
            return "active-gui:" .. tostring(guiName)
        end
    end

    -- If FS25 says a GUI is visibly open but its controller name cannot be
    -- resolved, defer instead of drawing over an unknown startup screen. A
    -- stale currentGui object alone is no longer considered a blocker.
    if g_gui ~= nil and g_gui.getIsGuiVisible ~= nil and guiName == nil then
        local okVisible, guiVisible = pcall(g_gui.getIsGuiVisible, g_gui)
        if okVisible and guiVisible == true then return "unnamed-gui-open" end
    end

    return nil
end

function AgriLife.UIManager:isGameplayReadyForTutorialPrompt()
    return self:getTutorialBlockReason() == nil
end


local function normalizeVanillaFinanceText(value)
    local text=string.lower(tostring(value or ""))
    local replacements={{"é","e"},{"è","e"},{"ê","e"},{"ë","e"},{"à","a"},{"â","a"},{"ä","a"},{"î","i"},{"ï","i"},{"ô","o"},{"ö","o"},{"ù","u"},{"û","u"},{"ü","u"},{"ç","c"}}
    for _,pair in ipairs(replacements)do text=text:gsub(pair[1],pair[2])end
    return text
end

function AgriLife.UIManager:isVanillaLoanMenuButton(info)
    if type(info)~="table" then return false end
    local label=normalizeVanillaFinanceText(info.text or info.label or info.title or info.name or info.id or "")
    local tokens={"emprunt","rembours","borrow","repay","loan","kredit","tilg","prestito","rimbors","prestam","reembol","emprest","pozycz","splat","заем","погаш","借款","还款","借入","返済"}
    for _,token in ipairs(tokens)do if label:find(token,1,true)~=nil then return true end end
    return false
end

function AgriLife.UIManager:filterVanillaFinanceMenuButtons(info)
    if type(info)~="table" then return info end
    local filtered={}
    local numeric=false
    for k,v in pairs(info)do if type(k)=="number" then numeric=true;break end end
    if not numeric then return info end
    for _,entry in ipairs(info)do
        if not self:isVanillaLoanMenuButton(entry) then table.insert(filtered,entry) end
    end
    return filtered
end

function AgriLife.UIManager:enforceAgriLifeBankingUI()
    local menu=self:getInGameMenu(); local page=menu~=nil and menu.pageFinances or nil
    if page==nil then return end

    -- Intercept the parent TabbedMenu source as well. FS25 1.21 obtains the
    -- bottom bar through InGameMenu:getPageButtonInfo(page); filtering only the
    -- page object can leave the vanilla loan actions visible and active.
    if menu._agriLifeOriginalGetPageButtonInfo==nil and type(menu.getPageButtonInfo)=="function" then
        local manager=self
        menu._agriLifeOriginalGetPageButtonInfo=menu.getPageButtonInfo
        menu.getPageButtonInfo=function(menuSelf,pageArg,...)
            local ok,info=pcall(menuSelf._agriLifeOriginalGetPageButtonInfo,menuSelf,pageArg,...)
            if not ok then
                AgriLife.Logger.warning("UI","InGameMenu page button query failed while AgriLife banking lock was active: %s",tostring(info))
                return {}
            end
            if pageArg==menuSelf.pageFinances or pageArg==page then
                return manager:filterVanillaFinanceMenuButtons(info)
            end
            return info
        end
        AgriLife.Logger.info("UI","InGameMenu Finance button source intercepted before action registration")
    end

    -- FS25 1.21 renders the loan commands in the page's dynamic menu button
    -- list rather than exposing them as ordinary GUI controls. Filter that
    -- list at the source so keyboard/gamepad shortcuts disappear with them.
    if page._agriLifeOriginalGetMenuButtonInfo==nil and type(page.getMenuButtonInfo)=="function" then
        local manager=self
        page._agriLifeOriginalGetMenuButtonInfo=page.getMenuButtonInfo
        page.getMenuButtonInfo=function(pageSelf,...)
            local ok,info=pcall(pageSelf._agriLifeOriginalGetMenuButtonInfo,pageSelf,...)
            if not ok then
                AgriLife.Logger.warning("UI","Vanilla finance menu button query failed while AgriLife banking lock was active: %s",tostring(info))
                return {}
            end
            return manager:filterVanillaFinanceMenuButtons(info)
        end
        AgriLife.Logger.info("UI","Vanilla FS25 Finance borrow/repay menu actions intercepted")
    end

    for _,fieldName in ipairs({"menuButtonInfo","menuButtonInfos","buttonInfo","buttonInfos"})do
        local value=page[fieldName]
        if type(value)=="table" then
            local numeric=false
            for k,_ in pairs(value)do if type(k)=="number" then numeric=true;break end end
            if numeric then
                page[fieldName]=self:filterVanillaFinanceMenuButtons(value)
            else
                for key,list in pairs(value)do if type(list)=="table" then value[key]=self:filterVanillaFinanceMenuButtons(list)end end
            end
        end
    end

    local names={"borrowButton","repayButton","buttonBorrow","buttonRepay","loanBorrowButton","loanRepayButton","increaseLoanButton","decreaseLoanButton"}
    for _,name in ipairs(names) do
        local element=page[name]
        if element~=nil then
            if element.setDisabled~=nil then pcall(element.setDisabled,element,true) end
            if element.setVisible~=nil then pcall(element.setVisible,element,false) end
        end
    end

    -- Ask the parent menu to rebuild its bottom command bar when available.
    for _,methodName in ipairs({"updateMenuButtonInfo","setMenuButtonInfoDirty","updateButtonsPanel","updateButtons","rebuildMenuButtons"})do
        local method=menu~=nil and menu[methodName]or nil
        if type(method)=="function"then pcall(method,menu)end
    end
end

function AgriLife.UIManager:update(dt)
    if not self.mounted or self.frame == nil then return end
    self.vanillaBankUiPollMs=(tonumber(self.vanillaBankUiPollMs)or 0)+(tonumber(dt)or 0)
    if self.vanillaBankUiPollMs>=1000 then self.vanillaBankUiPollMs=0; self:enforceAgriLifeBankingUI() end

    -- The multi-page text guide has its own deferred dialog sequencer. It
    -- must keep ticking even after tutorialPromptShown becomes true.
    if self.frame.updateTextTutorial ~= nil then
        self.frame:updateTextTutorial(dt)
    end

    if self.frame.promptTutorialChoice == nil then return end
    if self.frame.tutorialPromptShown == true then return end

    self.tutorialPromptPollMs = (tonumber(self.tutorialPromptPollMs) or 0) + (tonumber(dt) or 0)
    if self.tutorialPromptPollMs < 500 then return end
    local elapsed = self.tutorialPromptPollMs
    self.tutorialPromptPollMs = 0

    local blockReason = self:getTutorialBlockReason()
    if blockReason ~= nil then
        self.tutorialGameplayReadyMs = 0
        if self.tutorialLastBlockReason ~= blockReason then
            self.tutorialLastBlockReason = blockReason
            AgriLife.Logger.info("Tutorial", "Waiting before text guide (%s)", tostring(blockReason))
        end
        return
    end

    if self.tutorialLastBlockReason ~= "ready" then
        self.tutorialLastBlockReason = "ready"
        AgriLife.Logger.info("Tutorial", "Gameplay detected; text guide will open after a short safety delay")
    end
    self.tutorialGameplayReadyMs = (tonumber(self.tutorialGameplayReadyMs) or 0) + elapsed
    if self.tutorialGameplayReadyMs >= 1800 then
        self.tutorialGameplayReadyMs = 0
        self.frame:promptTutorialChoice()
    end
end

function AgriLife.UIManager:removeFromArray(array, value)
    if array == nil then
        return
    end
    for index = #array, 1, -1 do
        local item = array[index]
        if item == value or (type(item) == "table" and item.element == value) then
            table.remove(array, index)
        end
    end
end

function AgriLife.UIManager:clearGuiRegistration(frame)
    if g_gui == nil or g_gui.guis == nil or frame == nil then
        return
    end
    for guiName, entry in pairs(g_gui.guis) do
        if entry == frame or (type(entry) == "table" and entry.target == frame) then
            g_gui.guis[guiName] = nil
        end
    end
end

function AgriLife.UIManager:detachFrame(menu, frame)
    if menu == nil or frame == nil then
        return
    end

    -- TabbedMenu:unregisterPage() expects the FrameElement class, not the
    -- instance. Keep the old array cleanup as a fallback for pre-FIX4E pages
    -- which were mounted manually instead of through TabbedMenu:addPage().
    local pageRoot = menu.pageRoots ~= nil and menu.pageRoots[frame] or nil
    local pageClass = nil
    if frame.class ~= nil then
        local okClass, resolvedClass = pcall(frame.class, frame)
        if okClass then pageClass = resolvedClass end
    end
    if pageClass ~= nil and menu.unregisterPage ~= nil then
        pcall(menu.unregisterPage, menu, pageClass)
    end

    if menu.pagingElement ~= nil then
        if pageRoot ~= nil and menu.pagingElement.removeElement ~= nil then
            pcall(menu.pagingElement.removeElement, menu.pagingElement, pageRoot)
        end
        self:removeFromArray(menu.pagingElement.elements, frame)
        self:removeFromArray(menu.pagingElement.pages, frame)
        if pageRoot ~= nil then
            self:removeFromArray(menu.pagingElement.elements, pageRoot)
            self:removeFromArray(menu.pagingElement.pages, pageRoot)
        end
    end
    self:removeFromArray(menu.pageFrames, frame)

    if menu[self.pageName] == frame then
        menu[self.pageName] = nil
    end
    if menu.controlIDs ~= nil then
        menu.controlIDs[self.pageName] = nil
    end

    if menu.rebuildTabList ~= nil then
        pcall(menu.rebuildTabList, menu)
    end
    if menu.setPageSelectorTitles ~= nil then
        pcall(menu.setPageSelectorTitles, menu)
    end
end

function AgriLife.UIManager:mount()
    if self.mounted then
        return AgriLife.Result.fail("UI_ALREADY_MOUNTED", "AgriLife UI already mounted")
    end
    if g_gui == nil or g_gui.loadGui == nil then
        return AgriLife.Result.fail("GUI_SYSTEM_UNAVAILABLE", "GUI system unavailable", { fatal = true })
    end

    self.inGameMenu = self:getInGameMenu()
    if self.inGameMenu == nil then
        return AgriLife.Result.fail("INGAME_MENU_UNAVAILABLE", "In-game menu controller unavailable", { fatal = false })
    end
    AgriLife.Logger.info("UI", "In-game menu controller resolved")

    local staleFrame = self.inGameMenu[self.pageName]
    if staleFrame ~= nil then
        AgriLife.Logger.warning("UI", "Stale AgriLife page found and removed before mounting")
        self:detachFrame(self.inGameMenu, staleFrame)
        self:clearGuiRegistration(staleFrame)
        if staleFrame.delete ~= nil then
            pcall(staleFrame.delete, staleFrame)
        end
    end

    self.frame = AgriLife.HomeFrame.new(self.core)
    local xmlPath = Utils.getFilename("gui/AgriLifeHomeFrame.xml", AgriLife.Version.MOD_DIR)
    local loadOk, loadValue = pcall(g_gui.loadGui, g_gui, xmlPath, self.guiName, self.frame, true)
    if not loadOk or loadValue == false then
        if self.frame ~= nil and self.frame.delete ~= nil then
            pcall(self.frame.delete, self.frame)
        end
        self.frame = nil
        return AgriLife.Result.fail("UI_XML_LOAD_FAILED", tostring(loadValue), { fatal = true })
    end
    self.guiLoaded = true

    local requiredControls = {
        "headerVersion", "headerFarm", "headerCash",
        "valueVersion", "statusValueCard", "dashboardPage", "bankPage", "examPage", "xpPage", "insurancePage", "workshopPage",
        "navDashboard", "navBank", "navExams", "navXp", "navInsurance", "navWorkshop",
        "navDashboardBg", "navBankBg", "navExamsBg", "navXpBg", "navInsuranceBg", "navWorkshopBg",
        "navDashboardIcon", "navBankIcon", "navExamsIcon", "navXpIcon", "navInsuranceIcon", "navWorkshopIcon",
        "navDashboardLabel", "navBankLabel", "navExamsLabel", "navXpLabel", "navInsuranceLabel", "navWorkshopLabel",
        "dashBankCash", "dashExamState", "dashExamProgressLabel", "dashExamCatalogLabel", "dashCareerLevel", "dashInsuranceState", "dashWorkshopState",
        "bankRequestButton", "bankPurposeButton", "examActionButton", "examLicenseValue", "examStateValue",
        "examTaskTitle", "examObjectiveValue", "examCriterionValue", "examProgressValue", "examStatusText",
        "xpLevelValue", "xpTotalValue", "xpProgressValue", "xpReputationValue", "xpStatusText",
        "xpSpec1Value", "xpSpec8Value",
        "examSelfTabButton", "examTeamTabButton", "examTeamPanel", "examTeamRow1", "examTeamDeleteButton",
        "careerSelfTabButton", "careerTeamTabButton", "careerTeamPanel", "careerTeamRow1", "careerTeamDeleteButton",
        "payrollPage", "navPayroll", "navPayrollBg", "navPayrollIcon", "navPayrollLabel",
        "payrollSelfTabButton", "payrollTeamTabButton", "payrollSelfPanel", "payrollTeamPanel",
        "payrollSelfBalanceValue", "payrollSelfSalaryValue", "payrollTeamRow1", "payrollSelectedNameValue", "payrollSalaryAutoButton"
        ,"onboardingModeButton", "onboardingActivateButton", "journalOpenButton"
        ,"tutorialOverlay", "tutorialProgressText", "tutorialTitleText", "tutorialBodyText", "tutorialChecklistText", "tutorialActionButton", "tutorialModeCycleButton", "tutorialGuideButton"
        ,"bankAdvisorButton", "examHudVisibleButton", "examHudLockButton", "examHudPositionButton"
        ,"payrollRecruitCdiButton", "payrollRecruitCddButton", "payrollRecruitApprenticeButton"
        ,"insuranceActiveValue", "insuranceCategoryButton", "insuranceBuyButton"
        ,"insurancePolicyNextButton", "insuranceCancelButton", "insuranceFileClaimButton", "insuranceClaimNextButton", "insuranceAssessButton", "insuranceAppealButton"
        ,"workshopSummaryValue", "workshopVehicleButton", "usedOfferButton", "leaseCreateButton"
        ,"examCertificationValue", "examCertificationButton"
        ,"companyOpenButton", "companyPage", "companyNameValue", "companyLegalValue", "companyCapitalValue"
        ,"companyProfileValue", "companyModeValue", "companyAssociateValue", "companyPersonalBalanceValue"
        ,"companyPersonalBankValue", "companyHousingValue", "companyPrivateVehicleValue", "companyTaxValue", "companyLegalDebtValue"
        ,"companyLegalStageValue", "companyLegalFormButton", "companyHousingButton", "companyPrivateVehicleButton", "companyExpenseButton", "legalSettleButton", "companyLedgerValue", "companyStatusText"
        ,"companyCapitalContributionButton", "companyAssociateAddButton", "companyAssociateRemoveButton", "companyReconcileButton"
        ,"bankAdvancedLoanValue", "bankOverdraftValue", "bankEarlyRepayButton", "bankRestructureButton", "bankOverdraftButton", "bankTaxPayButton"
        ,"bankFinancingPanel", "bankStatementPanel", "bankSetupFeeValue", "bankMonthlyFeePreviewValue", "bankStatementFeeSummary", "bankStatementDate1", "bankStatementLabel1", "bankStatementAmount1", "bankStatementBalance1"
        ,"payrollAttendanceValue", "payrollOvertimeButton", "payrollAbsenceButton", "payrollLeaveButton", "payrollSettleButton"
        ,"enterpriseViewButton", "enterpriseDetailOverlay", "enterpriseDetailTitle", "enterpriseDetailText", "enterpriseDetailPrevButton", "enterpriseDetailNextButton", "enterpriseDetailActionButton"
        ,"workshopAccidentsButton", "workshopLeasingButton", "workshopUsedButton", "workshopInsuranceButton"
        ,"workshop8ViewButton", "workshop8ProviderButton", "workshop8QualityButton", "workshop8UrgencyButton", "workshop8MechanicButton", "workshop8Overlay", "workshop8DetailTitle", "workshop8DetailText", "workshop8PrevButton", "workshop8NextButton", "workshop8ActionButton", "workshop8Action2Button"
        ,"workshopDiagnoseButton", "workshopServiceButton", "workshopRepairButton", "workshopTyresButton", "usedInspectButton", "usedBuyButton"
        ,"accidentsPage", "accidentCountValue", "accidentClaimsValue", "accidentPayoutValue", "accidentVehicleValue"
        ,"accidentDamageValue", "accidentCauseValue", "accidentResponsibleValue", "accidentClaimValue"
        ,"accidentDowntimeValue", "accidentClaimButton", "accidentExpertiseButton", "accidentStatusText"
        ,"leasingPage", "leaseOfferValue", "leaseAssetValue", "leaseTermValue", "leaseDepositValue", "leasePreviewValue"
        ,"leaseCreateAdvancedButton", "leaseActiveCountValue", "leaseMonthlyValue", "leaseCurrentValue"
        ,"leaseCurrentDetailValue", "leaseBuyoutButton", "leaseReturnButton", "leaseStatusText"
        ,"usedPage", "usedCountValue", "usedPurchasedValue", "usedInspectionCountValue", "usedNameValue"
        ,"usedPriceValue", "usedHistoryValue", "usedRiskValue", "usedInspectPageButton", "usedBuyPageButton", "usedStatusText"
    }
    local missingControls = {}
    for _, controlName in ipairs(requiredControls) do
        if self.frame[controlName] == nil then table.insert(missingControls, controlName) end
    end
    if #missingControls > 0 then
        self:clearGuiRegistration(self.frame)
        if self.frame.delete ~= nil then
            pcall(self.frame.delete, self.frame)
        end
        self.frame = nil
        self.guiLoaded = false
        return AgriLife.Result.fail("UI_CONTROLS_MISSING", "Required GUI controls were not mapped: " .. table.concat(missingControls, ", "), { fatal = true, missing = missingControls })
    end

    local menu = self.inGameMenu
    local integrationOk, integrationError = xpcall(function()
        if menu.pagingElement == nil then
            error("FS25 InGameMenu pagingElement unavailable")
        end
        if menu.registerPage == nil or menu.addPageTab == nil then
            error("FS25 InGameMenu page registration API unavailable")
        end

        -- FIX4F: mirror the proven FS25_SoilFertilizer PDA registration path.
        -- The ESC tab has its own dedicated 1024x1024 texture and is completely
        -- independent from AgriLife's internal navigation pictograms.
        if menu.controlIDs ~= nil then
            menu.controlIDs[self.pageName] = nil
        end
        menu[self.pageName] = self.frame

        local alreadyAdded = false
        if menu.pagingElement.elements ~= nil then
            for _, element in ipairs(menu.pagingElement.elements) do
                if element == self.frame then
                    alreadyAdded = true
                    break
                end
            end
        end
        if not alreadyAdded then
            menu.pagingElement:addElement(self.frame)
        end

        if menu.exposeControlsAsFields ~= nil then
            pcall(menu.exposeControlsAsFields, menu, self.pageName)
        end
        if menu.pagingElement.updateAbsolutePosition ~= nil then
            pcall(menu.pagingElement.updateAbsolutePosition, menu.pagingElement)
        end
        if menu.pagingElement.updatePageMapping ~= nil then
            pcall(menu.pagingElement.updatePageMapping, menu.pagingElement)
        end

        local okRegister, registerError = pcall(menu.registerPage, menu, self.frame, nil, function() return true end)
        if not okRegister then
            error("registerPage failed: " .. tostring(registerError))
        end

        local iconPath = Utils.getFilename("textures/ui/menuIcon.dds", AgriLife.Version.MOD_DIR)
        local iconUvs = GuiUtils.getUVs({ 0, 0, 1024, 1024 })
        local okTab, tabError = pcall(menu.addPageTab, menu, self.frame, iconPath, iconUvs)
        if not okTab then
            error("addPageTab failed: " .. tostring(tabError))
        end

        if menu.rebuildTabList ~= nil then
            pcall(menu.rebuildTabList, menu)
        end
        if menu.setPageSelectorTitles ~= nil then
            pcall(menu.setPageSelectorTitles, menu)
        end
        if self.frame.initialize ~= nil then
            pcall(self.frame.initialize, self.frame)
        end

        AgriLife.Logger.info("UI", "AgriLife ESC tab registered with dedicated textures/ui/menuIcon.dds using SoilFertilizer-compatible path")
    end, function(errorValue)
        return tostring(errorValue)
    end)

    if not integrationOk then
        self:detachFrame(menu, self.frame)
        self:clearGuiRegistration(self.frame)
        if self.frame.delete ~= nil then
            pcall(self.frame.delete, self.frame)
        end
        self.frame = nil
        self.inGameMenu = nil
        self.guiLoaded = false
        return AgriLife.Result.fail("UI_MENU_INTEGRATION_FAILED", tostring(integrationError), { fatal = true })
    end

    self.mounted = true
    self.tutorialPromptPollMs = 0
    self.tutorialGameplayReadyMs = 0
    self.tutorialLastBlockReason = nil
    -- The text guide is opened from update() only after gameplay is detected.
    -- This avoids the WardrobeScreen while no longer treating FS25's stale
    -- currentGui entry as an endless blocker.
    AgriLife.Logger.info("UI", "Application mounted (gui=%s); text tutorial deferred until gameplay", self.guiName)
    return AgriLife.Result.ok("UI_MOUNTED", "AgriLife UI mounted")
end

function AgriLife.UIManager:unmount()
    if not self.mounted and self.frame == nil then
        self:unloadTutorialDialog()
        self:unloadJournalDialog()
        self:unloadAccidentStatementDialog()
        return AgriLife.Result.ok("UI_NOT_MOUNTED", "UI already unmounted")
    end

    self:unloadTutorialDialog()
    self:unloadJournalDialog()
    self:unloadAccidentStatementDialog()

    local frame = self.frame
    local menu = self.inGameMenu or self:getInGameMenu()
    self:detachFrame(menu, frame)

    if menu ~= nil and menu.rebuildTabList ~= nil then
        pcall(menu.rebuildTabList, menu)
    end

    self:clearGuiRegistration(frame)
    if frame ~= nil and frame.delete ~= nil then
        pcall(frame.delete, frame)
    end

    self.frame = nil
    self.inGameMenu = nil
    self.mounted = false
    self.guiLoaded = false
    AgriLife.Logger.info("UI", "Application unmounted")
    return AgriLife.Result.ok("UI_UNMOUNTED", "AgriLife UI unmounted")
end

function AgriLife.UIManager:delete()
    self:unmount()
    self.core = nil
    self.guiName = nil
end
