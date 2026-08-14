-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04.2: unify the employee file and employee career views without removing career logic.
AgriLife = AgriLife or {}
AgriLife.F04EmployeeSheetUnifiedUI = AgriLife.F04EmployeeSheetUnifiedUI or {VERSION = "0.9.3.38"}

local Frame = AgriLife.HomeFrame
if Frame ~= nil and Frame.refreshPayroll ~= nil and Frame._f04EmployeeSheetUnifiedInstalled ~= true then
    Frame._f04EmployeeSheetUnifiedInstalled = true

    local VIEWS = {"OVERVIEW", "EMPLOYEE", "PLANNING", "TRAINING", "INCIDENTS"}
    local baseGetView = Frame.getEnterpriseDetailView
    local baseRefreshPayroll = Frame.refreshPayroll
    local baseDetailAction = Frame.onClickEnterpriseDetailAction

    local function tr(key, fallback)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" and tostring(value) ~= tostring(key) then
                return tostring(value)
            end
        end
        return fallback or tostring(key)
    end

    local function setText(element, value)
        if element ~= nil and element.setText ~= nil then pcall(element.setText, element, tostring(value or "")) end
    end

    local function getText(element)
        if element ~= nil and element.getText ~= nil then
            local ok, value = pcall(element.getText, element)
            if ok and value ~= nil then return tostring(value) end
        end
        return element ~= nil and tostring(element.text or "") or ""
    end

    local function setVisible(element, visible)
        if element ~= nil and element.setVisible ~= nil then pcall(element.setVisible, element, visible == true) end
    end

    local function setDisabled(element, disabled)
        if element ~= nil and element.setDisabled ~= nil then pcall(element.setDisabled, element, disabled == true) end
    end

    local function scaleTextOnce(element, factor, marker)
        if element == nil or element.setTextSize == nil or element[marker] == true then return end
        local base = tonumber(element.textSize)
        if base == nil and element.getTextSize ~= nil then
            local ok, value = pcall(element.getTextSize, element)
            if ok then base = tonumber(value) end
        end
        if base ~= nil and base > 0 then
            pcall(element.setTextSize, element, base * factor)
            element[marker] = true
        end
    end

    local function expandDetailAreaOnce(element)
        if element == nil or element._f04UnifiedExpanded == true then return end
        local size = element.size
        local position = element.position
        if type(size) == "table" and type(position) == "table" and element.setSize ~= nil and element.setPosition ~= nil then
            local width = tonumber(size[1])
            local height = tonumber(size[2])
            local x = tonumber(position[1])
            local y = tonumber(position[2])
            if width ~= nil and height ~= nil and x ~= nil and y ~= nil and height > 0 then
                local extra = height * 0.117
                pcall(element.setPosition, element, x, math.max(0, y - height * 0.078))
                pcall(element.setSize, element, width, height + extra)
            end
        end
        element._f04UnifiedExpanded = true
    end

    local function moveIncidentsIntoCareerSlotOnce(self)
        local incidents = self.enterpriseIncidentsViewButton
        local career = self.enterpriseCareerViewButton
        if incidents == nil or incidents._f04UnifiedMoved == true or career == nil then return end
        if incidents.setPosition ~= nil and type(career.position) == "table" then
            local x = tonumber(career.position[1])
            local y = tonumber(career.position[2])
            if x ~= nil and y ~= nil then pcall(incidents.setPosition, incidents, x, y) end
        end
        incidents._f04UnifiedMoved = true
    end

    local function normalizeIndex(value)
        value = math.floor(tonumber(value) or 1)
        while value < 1 do value = value + #VIEWS end
        while value > #VIEWS do value = value - #VIEWS end
        return value
    end

    local function setUnifiedView(self, name)
        for index, viewName in ipairs(VIEWS) do
            if viewName == name then
                self.enterpriseUnifiedDetailViewIndex = index
                self.enterpriseDetailViewIndex = index
                self.enterpriseDetailRowIndex = 1
                self:refreshPayroll()
                return
            end
        end
    end

    function Frame:getEnterpriseDetailView()
        if self.enterpriseUnifiedDetailViewIndex == nil then
            local legacy = baseGetView ~= nil and baseGetView(self) or "OVERVIEW"
            if legacy == "CAREER" then legacy = "EMPLOYEE" end
            for index, name in ipairs(VIEWS) do
                if name == legacy then self.enterpriseUnifiedDetailViewIndex = index break end
            end
        end
        self.enterpriseUnifiedDetailViewIndex = normalizeIndex(self.enterpriseUnifiedDetailViewIndex)
        return VIEWS[self.enterpriseUnifiedDetailViewIndex]
    end

    function Frame:onClickEnterpriseView()
        self.enterpriseUnifiedDetailViewIndex = normalizeIndex((tonumber(self.enterpriseUnifiedDetailViewIndex) or 1) + 1)
        self.enterpriseDetailRowIndex = 1
        self:refreshPayroll()
    end

    function Frame:onClickEnterpriseOverview() setUnifiedView(self, "OVERVIEW") end
    function Frame:onClickEnterpriseEmployee() setUnifiedView(self, "EMPLOYEE") end
    function Frame:onClickEnterprisePlanning() setUnifiedView(self, "PLANNING") end
    function Frame:onClickEnterpriseTraining() setUnifiedView(self, "TRAINING") end
    function Frame:onClickEnterpriseCareer() setUnifiedView(self, "EMPLOYEE") end
    function Frame:onClickEnterpriseIncidents() setUnifiedView(self, "INCIDENTS") end

    function Frame:onClickEnterpriseDetailAction(...)
        if self:getEnterpriseDetailView() == "EMPLOYEE" then
            local enterprise = self.getEnterpriseModule ~= nil and self:getEnterpriseModule() or nil
            local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
            local profileId = tostring(self.payrollSelectedProfileId or "")
            if enterprise == nil or farmId <= 0 or profileId == "" then return end
            local planning = enterprise.getWorkforcePlanningSnapshot ~= nil and enterprise:getWorkforcePlanningSnapshot(farmId, profileId) or nil
            local promotion = planning ~= nil and planning.promotion or nil
            if promotion == nil or promotion.eligible ~= true then return end
            local actor = self.getLocalPayrollProfileId ~= nil and tostring(self:getLocalPayrollProfileId(farmId) or "") or ""
            local result = enterprise.promoteEmployeeCareer ~= nil and enterprise:promoteEmployeeCareer(farmId, actor, profileId) or nil
            if result ~= nil and result.message ~= nil then self.lastEnterpriseMessage = tostring(result.message) end
            self:refreshPayroll()
            return
        end
        if baseDetailAction ~= nil then return baseDetailAction(self, ...) end
    end

    function Frame:refreshPayroll(...)
        local result = baseRefreshPayroll(self, ...)

        setVisible(self.enterpriseCareerViewButton, false)
        moveIncidentsIntoCareerSlotOnce(self)
        scaleTextOnce(self.enterpriseDetailTitle, 1.18, "_f04UnifiedTitleScaled")
        scaleTextOnce(self.enterpriseDetailText, 1.18, "_f04UnifiedBodyScaled")
        expandDetailAreaOnce(self.enterpriseDetailText)

        if self:getEnterpriseDetailView() == "EMPLOYEE" then
            local enterprise = self.getEnterpriseModule ~= nil and self:getEnterpriseModule() or nil
            local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
            local profileId = tostring(self.payrollSelectedProfileId or "")
            local planning = enterprise ~= nil and enterprise.getWorkforcePlanningSnapshot ~= nil and profileId ~= "" and enterprise:getWorkforcePlanningSnapshot(farmId, profileId) or nil
            local career = planning ~= nil and planning.career or nil
            local promotion = planning ~= nil and planning.promotion or nil

            if career ~= nil then
                local eligibility = promotion ~= nil and promotion.eligible == true
                    and tr("agrilife_enterprise_promotion_ready", "Promotion possible")
                    or tr("agrilife_enterprise_promotion_locked", "Promotion non disponible")
                local careerText = string.format(
                    tr("agrilife_enterprise_career_fmt", "Niveau %d | XP %d | ancienneté %d mois\nPerformance %.0f/100 | réussites %d | échecs %d\nFormations %d | incidents %d | promotions %d\n%s"),
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
                local current = getText(self.enterpriseDetailText)
                if current ~= "" and not string.find(current, careerText, 1, true) then
                    setText(self.enterpriseDetailText, current .. "\n" .. careerText)
                end
                setText(self.enterpriseDetailActionButton, tr("agrilife_enterprise_promotion_action", "Promouvoir"))
                setDisabled(self.enterpriseDetailActionButton, promotion == nil or promotion.eligible ~= true)
            end
        end

        return result
    end
end
