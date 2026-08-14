-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04.2: restore the complete employee file after the career merge and include owner details.
AgriLife = AgriLife or {}
AgriLife.F04EmployeeSheetDetail09339 = AgriLife.F04EmployeeSheetDetail09339 or {VERSION = "0.9.3.39"}

local Frame = AgriLife.HomeFrame
if Frame ~= nil and Frame.refreshPayroll ~= nil and Frame._f04EmployeeSheetDetail09339Installed ~= true then
    Frame._f04EmployeeSheetDetail09339Installed = true

    local baseRefreshPayroll = Frame.refreshPayroll

    local function tr(key, fallback)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" and tostring(value) ~= tostring(key) then return tostring(value) end
        end
        return fallback or tostring(key)
    end

    local function money(value)
        if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
            local ok, text = pcall(g_i18n.formatMoney, g_i18n, tonumber(value) or 0, 0, true, true)
            if ok and text ~= nil then return tostring(text) end
        end
        return string.format("%.0f", tonumber(value) or 0)
    end

    local function setText(element, value)
        if element ~= nil and element.setText ~= nil then pcall(element.setText, element, tostring(value or "")) end
    end

    local function setDisabled(element, disabled)
        if element ~= nil and element.setDisabled ~= nil then pcall(element.setDisabled, element, disabled == true) end
    end

    local function fitDetailTextOnce(element)
        if element == nil or element._f04Detail09339Fitted == true or element.setTextSize == nil then return end
        local size = tonumber(element.textSize)
        if size ~= nil and size > 0 then pcall(element.setTextSize, element, size * 0.92) end
        element._f04Detail09339Fitted = true
    end

    local function statusLabel(status)
        status = tostring(status or "AVAILABLE")
        return tr("agrilife_enterprise_status_" .. string.lower(status), status)
    end

    local function specialtyLabel(value)
        value = tostring(value or "none")
        return tr("agrilife_enterprise_specialty_" .. value, value)
    end

    local function findPayrollEmployee(self, farmId, profileId)
        local payroll = self.getPayrollModule ~= nil and self:getPayrollModule() or nil
        local snapshot = payroll ~= nil and payroll.getSnapshot ~= nil and payroll:getSnapshot(farmId) or nil
        for _, employee in ipairs(snapshot ~= nil and snapshot.employees or {}) do
            if tostring(employee.profileId or "") == tostring(profileId or "") then return employee end
        end
        return nil
    end

    function Frame:refreshPayroll(...)
        local result = baseRefreshPayroll(self, ...)
        if self.getEnterpriseDetailView == nil or self:getEnterpriseDetailView() ~= "EMPLOYEE" then return result end

        local enterprise = self.getEnterpriseModule ~= nil and self:getEnterpriseModule() or nil
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local profileId = tostring(self.payrollSelectedProfileId or "")
        if enterprise == nil or farmId <= 0 or profileId == "" or enterprise.getEmployeeFullSheet == nil then return result end

        local sheet = enterprise:getEmployeeFullSheet(farmId, profileId)
        if sheet == nil then return result end
        fitDetailTextOnce(self.enterpriseDetailText)

        local payrollEmployee = findPayrollEmployee(self, farmId, profileId)
        local role = tostring(payrollEmployee ~= nil and payrollEmployee.role or sheet.role or "employee")
        local roleKey = payrollEmployee ~= nil and payrollEmployee.roleLabelKey or ("agrilife_payroll6_role_" .. role)
        local roleText = tr(roleKey, role)
        local specialty = sheet.specialty or {}
        local career = sheet.career or {}
        local work = sheet.workSummary or {}
        local activeOrder = sheet.activeOrder
        local workType = activeOrder ~= nil and tostring(activeOrder.workType or "--") or ""
        local orderText = activeOrder ~= nil
            and string.format("%s / %s / %d%%", tr("agrilife_enterprise_work_" .. string.lower(workType), workType), tostring(activeOrder.status or "--"), math.floor((tonumber(activeOrder.progress) or 0) * 100 + 0.5))
            or tr("agrilife_enterprise_no_order", "Aucun ordre actif")

        local body = string.format(
            tr("agrilife_enterprise_employee_sheet_fmt", "%s | %s | %s | ancienneté %d mois\nStatut %s | salaire %s | brut %s | coût employeur %s\nSpécialité %s %d/100 | XP %d | performance %.0f/100\nHeures %.1f | sup. %.1f | congés %.1f j | maladie %.1f j | absences %.1f j\nOrdre : %s"),
            tostring(sheet.displayName or "--"), roleText, tostring(sheet.contractType or "--"), tonumber(sheet.seniorityMonths) or 0,
            statusLabel(sheet.status), money(sheet.monthlySalary or 0), money(sheet.monthlyGross or 0), money(sheet.employerCost or 0),
            specialtyLabel(specialty.primary or "none"), tonumber(specialty.specialtySkill) or 0, tonumber(career.totalXP or (sheet.xp ~= nil and sheet.xp.total) or 0) or 0, tonumber(career.performanceScore) or 50,
            (tonumber(work.workedMinutes) or 0) / 60, tonumber(sheet.overtimeHours) or 0, tonumber(sheet.leaveBalanceDays) or 0, tonumber(sheet.sickDays) or 0, tonumber(sheet.absenceDays) or 0, orderText
        )

        if payrollEmployee ~= nil then
            local payRange = string.format("%s %s | %s - %s", tr("agrilife_payroll6_recommended", "Salaire recommandé"), money(payrollEmployee.recommendedSalary or 0), money(payrollEmployee.salaryMin or 0), money(payrollEmployee.salaryMax or 0))
            local morale = math.floor((tonumber(payrollEmployee.morale) or 70) + 0.5)
            local reputation = math.floor((tonumber(payrollEmployee.reputation) or 50) + 0.5)
            local level = math.max(1, tonumber(payrollEmployee.careerLevel) or 1)
            local stage = tostring(payrollEmployee.professionalStageLabel or "")
            local careerPayroll = string.format(tr("agrilife_payroll_self_career_morale_fmt", "Niv. %d | Rép. %d/100 | Moral %d/100"), level, reputation, morale)
            if role ~= "owner" then
                local loyalty = math.floor((tonumber(payrollEmployee.loyalty) or 60) + 0.5)
                local moraleLoyalty = string.format(tr("agrilife_payroll_morale_virtual_fmt", "Moral : %d/100 | Fidélité : %d/100 | %s"), morale, loyalty, stage)
                local loyaltyStage = string.match(moraleLoyalty, "^[^|]+|%s*(.*)$") or moraleLoyalty
                careerPayroll = careerPayroll .. " | " .. loyaltyStage
            end
            body = body .. "\n" .. payRange .. "\n" .. careerPayroll
        end

        if role ~= "owner" then
            local planning = enterprise.getWorkforcePlanningSnapshot ~= nil and enterprise:getWorkforcePlanningSnapshot(farmId, profileId) or nil
            local promotion = planning ~= nil and planning.promotion or sheet.promotion
            local eligibility = promotion ~= nil and promotion.eligible == true
                and tr("agrilife_enterprise_promotion_ready", "Promotion disponible")
                or tr("agrilife_enterprise_promotion_locked", "Conditions de promotion non remplies")
            local careerText = string.format(
                tr("agrilife_enterprise_career_fmt", "Niveau %d | XP %d | ancienneté %d mois | Performance %.0f/100 | réussites %d | échecs %d | Formations %d | incidents %d | promotions %d | %s"),
                tonumber(career.workforceLevel) or 1,
                tonumber(career.totalXP) or 0,
                tonumber(career.seniorityMonths) or tonumber(sheet.seniorityMonths) or 0,
                tonumber(career.performanceScore) or 50,
                tonumber(career.completedOrders) or 0,
                tonumber(career.failedOrders) or 0,
                tonumber(career.trainingCount) or 0,
                tonumber(career.incidents) or 0,
                tonumber(career.promotions) or 0,
                eligibility
            )
            body = body .. "\n" .. careerText
            setText(self.enterpriseDetailActionButton, tr("agrilife_enterprise_promotion_action", "Promouvoir"))
            setDisabled(self.enterpriseDetailActionButton, promotion == nil or promotion.eligible ~= true)
        else
            setText(self.enterpriseDetailTitle, tr("agrilife_enterprise_employee_sheet_title", "Dossier salarié") .. " - " .. roleText)
            setText(self.enterpriseDetailActionButton, tr("agrilife_enterprise_action_none", "--"))
            setDisabled(self.enterpriseDetailActionButton, true)
        end

        setText(self.enterpriseDetailText, body)
        return result
    end
end
