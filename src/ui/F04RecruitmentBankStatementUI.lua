-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04: keep recruitment costs readable in the professional account statement.
AgriLife = AgriLife or {}
AgriLife.F04RecruitmentBankStatementUI = AgriLife.F04RecruitmentBankStatementUI or {}

local Frame = AgriLife.HomeFrame
if Frame ~= nil and Frame.refreshBank ~= nil and Frame._f04RecruitmentBankStatementWrapped ~= true then
    Frame._f04RecruitmentBankStatementWrapped = true
    local baseRefreshBank = Frame.refreshBank

    function Frame:refreshBank(...)
        local result = baseRefreshBank(self, ...)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local bank = self.getBankModule ~= nil and self:getBankModule() or nil
        local snapshot = bank ~= nil and bank.getSnapshot ~= nil and bank:getSnapshot(farmId) or nil
        local movements = snapshot ~= nil and snapshot.recentBankMovements or {}

        for index = 1, 6 do
            local movement = movements[index]
            if movement ~= nil and tostring(movement.kind or "") == "PAYROLL_RECRUITMENT_FEE" then
                local element = self["bankStatementLabel" .. index]
                if element ~= nil and element.setText ~= nil and g_i18n ~= nil then
                    element:setText(g_i18n:getText("agrilife_journal_employee_hired_title"))
                end
            end
        end
        return result
    end
end
