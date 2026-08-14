-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.36 - visible opening hours for the browsed bank.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local baseRefreshBank09336 = AgriLife.HomeFrame.refreshBank

    local function setBankHoursDisplay(frame)
        local element = frame ~= nil and frame.bankSelectionNoticeText or nil
        if element == nil or element.setText == nil then return end

        local bank = frame.getBankModule ~= nil and frame:getBankModule() or nil
        local farmId = frame.core ~= nil and frame.core.context ~= nil and frame.core.context:getFarmId() or 0
        if bank == nil or farmId <= 0 or bank.getProviders == nil then
            if element.setVisible ~= nil then element:setVisible(false) end
            return
        end

        local snapshot = frame.bankLastSnapshot
        if snapshot == nil and bank.getSnapshot ~= nil then snapshot = bank:getSnapshot(farmId) end
        if snapshot == nil then
            if element.setVisible ~= nil then element:setVisible(false) end
            return
        end

        local order, providers = bank:getProviders()
        local index = math.max(1, math.min(type(order) == "table" and #order or 1, tonumber(frame.bankProviderIndex) or 1))
        local providerId = type(order) == "table" and order[index] or snapshot.providerId
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

    function AgriLife.HomeFrame:refreshBank()
        if baseRefreshBank09336 ~= nil then baseRefreshBank09336(self) end
        setBankHoursDisplay(self)
    end
end
