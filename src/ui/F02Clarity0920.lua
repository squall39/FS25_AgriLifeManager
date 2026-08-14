-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local baseRefreshContracts0920 = AgriLife.HomeFrame.refreshContracts
    function AgriLife.HomeFrame:refreshContracts()
        if baseRefreshContracts0920 ~= nil then baseRefreshContracts0920(self) end
        if self.lastMarketMessage == nil or tostring(self.lastMarketMessage) == "" then
            if self.contractsStatusText ~= nil and self.contractsStatusText.setText ~= nil then
                self.contractsStatusText:setText("Repère : Acheter/Vendre = opération directe sur le marché sélectionné. Louer/Résilier = location de champs ou productions quand cette vue le permet. Négocier/Signer = contrat commercial avec volume, durée et pénalités.")
            end
        end
    end

    local baseRefreshWorkshop0920 = AgriLife.HomeFrame.refreshWorkshop
    function AgriLife.HomeFrame:refreshWorkshop()
        if baseRefreshWorkshop0920 ~= nil then baseRefreshWorkshop0920(self) end
        local function hideWhenEmpty(button)
            if button == nil or button.setVisible == nil then return end
            local text = tostring(button.text or "")
            if button.getText ~= nil then
                local ok, value = pcall(button.getText, button)
                if ok and value ~= nil then text = tostring(value) end
            end
            button:setVisible(text ~= "" and text ~= "--")
        end
        hideWhenEmpty(self.workshop8ActionButton)
        hideWhenEmpty(self.workshop8Action2Button)
    end

    local baseRefresh0922 = AgriLife.HomeFrame.refresh
    function AgriLife.HomeFrame:refresh()
        if baseRefresh0922 ~= nil then baseRefresh0922(self) end
        if self.headerContextHelp == nil or self.headerContextHelp.setText == nil then return end
        local page = tostring(self.activePage or "dashboard")
        local modeId = tostring(self.currentModeId or "facile")
        local keys = {
            dashboard = "agrilife_context_dashboard_" .. modeId,
            company = "agrilife_context_company",
            bank = "agrilife_context_bank_ready",
            payroll = "agrilife_context_payroll",
            exams = "agrilife_context_career_" .. modeId,
            xp = "agrilife_context_career_" .. modeId,
            insurance = "agrilife_context_insurance",
            contracts = "agrilife_context_contracts",
            workshop = "agrilife_context_workshop",
            accidents = "agrilife_context_accidents",
            leasing = "agrilife_context_leasing",
            used = "agrilife_context_used"
        }
        local key = keys[page]
        local value = key ~= nil and g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText(key) or ""
        if value == nil or value == key then value = "" end
        self.headerContextHelp:setText(tostring(value or ""))
    end

    -- F03 0.9.3.36: show opening hours for the bank currently browsed.
    local baseRefreshBank09336 = AgriLife.HomeFrame.refreshBank
    function AgriLife.HomeFrame:refreshBank()
        if baseRefreshBank09336 ~= nil then baseRefreshBank09336(self) end

        local element = self.bankSelectionNoticeText
        local bank = self.getBankModule ~= nil and self:getBankModule() or nil
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        if element == nil or element.setText == nil or bank == nil or farmId <= 0 or bank.getProviders == nil then
            if element ~= nil and element.setVisible ~= nil then element:setVisible(false) end
            return
        end

        local snapshot = self.bankLastSnapshot
        if snapshot == nil and bank.getSnapshot ~= nil then snapshot = bank:getSnapshot(farmId) end
        if snapshot == nil then
            if element.setVisible ~= nil then element:setVisible(false) end
            return
        end

        local order, providers = bank:getProviders()
        local count = type(order) == "table" and #order or 0
        local index = math.max(1, math.min(math.max(1, count), tonumber(self.bankProviderIndex) or 1))
        local providerId = count > 0 and order[index] or snapshot.providerId
        local provider = providers ~= nil and providers[providerId] or nil
        local digital = bank.isDigitalProvider ~= nil and bank:isDigitalProvider(providerId) or (provider ~= nil and provider.online == true)
        local hours = AgriLife.OperationalHours93
        local schedule = digital and "24/7" or (hours ~= nil and hours.getScheduleText ~= nil and hours:getScheduleText("BANK") or tostring(snapshot.bankHours or "08:00-12:00 / 14:00-18:00"))
        local isOpen = digital or (hours ~= nil and hours.isOpen ~= nil and hours:isOpen("BANK") or snapshot.bankOpen == true)

        local label
        if isOpen then
            local openLabel = g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText("agrilifemanager_fp_open") or "Open"
            label = string.format("%s | %s", tostring(openLabel), tostring(schedule))
        else
            local closedFormat = g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText("agrilife_bank6_bank_closed_fmt") or "Bank closed. Opening hours: %s."
            label = string.format(tostring(closedFormat), tostring(schedule))
        end

        element:setText(label)
        if element.setVisible ~= nil then element:setVisible(true) end
        if element.setTextColor ~= nil then
            if isOpen then
                element:setTextColor(0.67, 0.91, 0.45, 1)
            else
                element:setTextColor(0.94, 0.67, 0.30, 1)
            end
        end
    end

end
