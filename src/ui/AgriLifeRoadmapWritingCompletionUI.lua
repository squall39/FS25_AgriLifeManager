-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - final writing pass for roadmap UI states.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local function setText(element, value)
        if element ~= nil and element.setText ~= nil then element:setText(tostring(value or "")) end
    end

    local function formatMoney(value)
        value = tonumber(value) or 0
        if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
            local ok, result = pcall(g_i18n.formatMoney, g_i18n, value, 2, true, true)
            if ok and result ~= nil then return result end
        end
        return string.format("%.2f", value)
    end

    local function textOf(element)
        if element == nil then return "" end
        return tostring(element.text or "")
    end

    local baseDecisionReason = AgriLife.HomeFrame.getBankDecisionReasonText
    function AgriLife.HomeFrame:getBankDecisionReasonText(reasonCode)
        local extra = {
            market = "agrilife_bank6_decision_reason_market",
            accounting = "agrilife_bank6_decision_reason_accounting"
        }
        local key = extra[tostring(reasonCode or "")]
        if key ~= nil and g_i18n ~= nil then return g_i18n:getText(key) end
        return baseDecisionReason ~= nil and baseDecisionReason(self, reasonCode) or tostring(reasonCode or "")
    end

    local baseRefreshDashboard = AgriLife.HomeFrame.refreshDashboard
    function AgriLife.HomeFrame:refreshDashboard()
        baseRefreshDashboard(self)
        if self.core == nil or self.core.context == nil then return end
        local farmId = self.core.context:getFarmId()
        local facade = self.getDashboardFacadeModule ~= nil and self:getDashboardFacadeModule() or nil
        local snapshot = facade ~= nil and facade.getSnapshot ~= nil and facade:getSnapshot(farmId) or nil
        local cards = snapshot ~= nil and snapshot.cards or nil
        local career = cards ~= nil and cards.careerQualifications or nil
        local difficulty = tostring(snapshot ~= nil and snapshot.difficulty or "")
        if career ~= nil and career.examRunning ~= true and tostring(career.generalLicence or "unknown") ~= "obtained" then
            if difficulty == "facile" then
                setText(self.dashCareerXp, g_i18n:getText("agrilife_exam6_state_optional"))
            elseif difficulty == "difficile" then
                setText(self.dashCareerXp, g_i18n:getText("agrilife_dashboard_exam_required_locked"))
            end
        end
        if career ~= nil then
            setText(self.dashCareerReputation, string.format(
                g_i18n:getText("agrilife_dashboard_career_history_fmt"),
                tonumber(career.qualificationCount) or 0,
                tonumber(career.attempts) or 0,
                tonumber(career.passes) or 0,
                tonumber(career.historyCount) or 0
            ))
        end
    end

    local baseRefreshBank = AgriLife.HomeFrame.refreshBank
    function AgriLife.HomeFrame:refreshBank()
        baseRefreshBank(self)
        if self.core == nil or self.core.context == nil then return end
        local farmId = self.core.context:getFarmId()
        local bank = self:getBankModule()
        if bank == nil then return end
        local advanced = bank.getAdvancedAccountingSnapshot ~= nil and bank:getAdvancedAccountingSnapshot(farmId, false) or nil
        local snapshot = bank.getSnapshot ~= nil and bank:getSnapshot(farmId) or nil
        if advanced ~= nil then
            local accountingText = string.format(
                g_i18n:getText("agrilife_bank_completion_accounting_fmt"),
                formatMoney(advanced.netIncome or 0),
                formatMoney(advanced.depreciation or 0),
                formatMoney(advanced.selfFinancingCapacity or 0),
                formatMoney(advanced.balance ~= nil and advanced.balance.equity or 0),
                formatMoney(advanced.outstandingTax or 0)
            )
            local current = textOf(self.bankAccountSummary)
            if current ~= "" and not string.find(current, accountingText, 1, true) then
                setText(self.bankAccountSummary, current .. " | " .. accountingText)
            elseif current == "" then
                setText(self.bankAccountSummary, accountingText)
            end
            if self.bankAccountView == "statement" then setText(self.bankStatementFeeSummary, accountingText) end
        end
        if snapshot ~= nil and snapshot.providerRisk ~= nil and snapshot.marketFinancing ~= nil then
            local risk = snapshot.providerRisk
            local market = snapshot.marketFinancing
            local riskText = string.format(
                g_i18n:getText("agrilife_bank_completion_risk_fmt"),
                tonumber(risk.solidity) or 0,
                tonumber(risk.severity) or 0,
                tonumber(risk.studySpeed) or 0,
                tonumber(market.index) or 1
            )
            local progress = textOf(self.bankProgressValue)
            if progress ~= "" and not string.find(progress, riskText, 1, true) then setText(self.bankProgressValue, progress .. " | " .. riskText) end
        end
        if bank.getBankConsultationOffers ~= nil then
            local amount = self.getSelectedBankAmount ~= nil and self:getSelectedBankAmount(farmId) or 50000
            local term = self.getSelectedBankTerm ~= nil and self:getSelectedBankTerm() or 36
            local purpose = self.getSelectedBankPurpose ~= nil and self:getSelectedBankPurpose() or "cash"
            local offers = bank:getBankConsultationOffers(farmId, purpose, amount, term) or {}
            local best = offers[1]
            if best ~= nil then
                local offerText = string.format(g_i18n:getText("agrilife_bank_completion_offer_fmt"), tostring(best.providerName or best.providerId or ""), tostring(best.bestAdvisorId or "--"), (tonumber(best.indicativeAnnualRate) or 0) * 100, tonumber(best.risk ~= nil and best.risk.studySpeed or 0) or 0)
                local progress = textOf(self.bankProgressValue)
                if progress == "" then setText(self.bankProgressValue, offerText) elseif not string.find(progress, offerText, 1, true) then setText(self.bankProgressValue, progress .. " | " .. offerText) end
            end
        end
        if bank.getAccountSeparationAudit ~= nil then
            local separation = bank:getAccountSeparationAudit(farmId)
            if separation ~= nil and separation.compliant ~= true then
                local warning = string.format(g_i18n:getText("agrilife_bank_completion_separation_warning_fmt"), tonumber(separation.excessViolations) or 0)
                local current = textOf(self.bankAccountSummary)
                if current == "" then setText(self.bankAccountSummary, warning) elseif not string.find(current, warning, 1, true) then setText(self.bankAccountSummary, current .. " | " .. warning) end
            end
        end
    end
end
