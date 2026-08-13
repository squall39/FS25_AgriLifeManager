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

end
