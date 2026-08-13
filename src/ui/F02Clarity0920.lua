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
end
