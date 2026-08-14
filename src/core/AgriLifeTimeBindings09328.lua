-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

local Time = AgriLife.GameTime09328 or AgriLife.GameTime
if Time == nil then return end

local classes = {
    "Company6Service", "People6Service", "Bank6Service", "Career6Service",
    "Payroll6Service", "CommercialContracts6Service", "Economy6Service",
    "Integrity6Service", "Insurance6Service", "Workshop6Service",
    "AssetLifecycle6Service", "Legal6Service", "Journal6Service",
    "Qualifications6Service", "Enterprise6Service", "Administration6Service",
    "DynamicMarket6Service"
}

local patched = 0
for _, className in ipairs(classes) do
    local class = AgriLife[className]
    if type(class) == "table" then
        if type(class.getPeriodKey) == "function" then
            class.getPeriodKey = function() return Time:getPeriodKey() end
            patched = patched + 1
        end
        if type(class.getCurrentPeriodKey) == "function" then
            class.getCurrentPeriodKey = function() return Time:getPeriodKey() end
            patched = patched + 1
        end
    end
end

AgriLife.TimeBindings09328 = {
    VERSION = "0.9.3.28",
    patchedMethods = patched,
    monthlyMessage = MessageType ~= nil and MessageType.PERIOD_CHANGED or nil,
    dailyMessage = MessageType ~= nil and MessageType.DAY_CHANGED or nil
}
