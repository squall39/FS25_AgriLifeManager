-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.GameTime09328 = AgriLife.GameTime09328 or {}
local Time = AgriLife.GameTime09328
Time.VERSION = "0.9.3.28"

local function integer(value, fallback)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return math.floor(tonumber(fallback) or 0) end
    return math.floor(value)
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function Time:getEnvironment()
    return g_currentMission ~= nil and g_currentMission.environment or nil
end

function Time:getYear()
    local env = self:getEnvironment()
    return math.max(0, integer(env ~= nil and env.currentYear or 1, 1))
end

function Time:getPeriod()
    local env = self:getEnvironment()
    return clamp(integer(env ~= nil and env.currentPeriod or 1, 1), 1, 12)
end

function Time:getPeriodKey()
    return self:getYear() * 12 + self:getPeriod()
end

function Time:getDaysPerPeriod()
    local env = self:getEnvironment()
    local candidates = {
        env ~= nil and env.daysPerPeriod or nil,
        g_currentMission ~= nil and g_currentMission.missionInfo ~= nil and g_currentMission.missionInfo.daysPerPeriod or nil,
        g_currentMission ~= nil and g_currentMission.missionInfo ~= nil and g_currentMission.missionInfo.environment ~= nil and g_currentMission.missionInfo.environment.daysPerPeriod or nil
    }
    for _, value in ipairs(candidates) do
        value = tonumber(value)
        if value ~= nil and value >= 1 and value <= 28 then return math.floor(value) end
    end
    return 1
end

function Time:getDayInPeriod()
    local env = self:getEnvironment()
    local days = self:getDaysPerPeriod()
    local direct = tonumber(env ~= nil and env.currentDayInPeriod or nil)
    if direct ~= nil then return clamp(math.floor(direct), 1, days) end
    local currentDay = tonumber(env ~= nil and env.currentDay or nil)
    if currentDay ~= nil and currentDay >= 1 and currentDay <= days then return math.floor(currentDay) end
    local monotonic = tonumber(env ~= nil and env.currentMonotonicDay or currentDay)
    if monotonic ~= nil and monotonic >= 0 then return (math.floor(monotonic) % days) + 1 end
    return 1
end

function Time:getMonotonicDay()
    local env = self:getEnvironment()
    local candidates = {
        env ~= nil and env.currentMonotonicDay or nil,
        env ~= nil and env.currentDay or nil
    }
    for _, value in ipairs(candidates) do
        value = tonumber(value)
        if value ~= nil and value >= 0 then return math.floor(value) end
    end
    return math.max(0, (self:getPeriodKey() - 1) * self:getDaysPerPeriod() + self:getDayInPeriod())
end

function Time:getDayKey()
    return self:getMonotonicDay()
end

function Time:getPeriodProgress()
    local days = self:getDaysPerPeriod()
    if days <= 1 then return 1 end
    return clamp(self:getDayInPeriod() / days, 0, 1)
end

function Time:isLastDayOfPeriod()
    return self:getDayInPeriod() >= self:getDaysPerPeriod()
end

function Time:getSnapshot()
    return {
        year = self:getYear(),
        period = self:getPeriod(),
        periodKey = self:getPeriodKey(),
        daysPerPeriod = self:getDaysPerPeriod(),
        dayInPeriod = self:getDayInPeriod(),
        dayKey = self:getDayKey(),
        periodProgress = self:getPeriodProgress()
    }
end

-- Monthly AgriLife systems must react to FS25 period changes, not to each day.
-- Daily systems must react to DAY_CHANGED. This keeps 1 to 28 days per month
-- fully equivalent from the point of view of monthly accounting and deadlines.
function Time:validateMessageTypes()
    return MessageType ~= nil and MessageType.PERIOD_CHANGED ~= nil and MessageType.DAY_CHANGED ~= nil
end

AgriLife.GameTime = Time
