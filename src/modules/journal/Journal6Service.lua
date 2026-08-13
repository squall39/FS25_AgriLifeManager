-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.Journal6Service = {}
AgriLife.Journal6Service.__index = AgriLife.Journal6Service

local function clean(value, default, maxLength)
    local text = tostring(value or default or "")
    if maxLength ~= nil and #text > maxLength then text = string.sub(text, 1, maxLength) end
    return text
end

local function safeNumber(value, default)
    local number = tonumber(value)
    if number == nil then return default or 0 end
    return number
end

function AgriLife.Journal6Service.new(core)
    return setmetatable({core = core, farms = {}, maxEntries = 320}, AgriLife.Journal6Service)
end

function AgriLife.Journal6Service:createDefaultState()
    return {nextId = 1, entries = {}}
end

function AgriLife.Journal6Service:getState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local state = self.farms[farmId]
    if state == nil and create ~= false then
        state = self:createDefaultState()
        self.farms[farmId] = state
    end
    return state
end

function AgriLife.Journal6Service:getPeriodKey()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local year = math.max(1, math.floor(safeNumber(environment ~= nil and environment.currentYear, 1)))
    local period = math.max(1, math.min(12, math.floor(safeNumber(environment ~= nil and environment.currentPeriod, 1))))
    return year * 12 + period
end

function AgriLife.Journal6Service:getClock()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    return math.max(0, math.floor(safeNumber(environment ~= nil and environment.currentDay, 0))), math.max(0, safeNumber(environment ~= nil and environment.dayTime, 0))
end

function AgriLife.Journal6Service:record(farmId, category, titleKey, messageKey, severity, source, amount, referenceId)
    local state = self:getState(farmId, true)
    if state == nil then return AgriLife.Result.fail("JOURNAL_FARM_INVALID", "Invalid farm") end
    local day, dayTime = self:getClock()
    local entry = {
        id = string.format("JRN_%d_%06d", tonumber(farmId) or 0, state.nextId),
        periodKey = self:getPeriodKey(),
        day = day,
        dayTime = dayTime,
        category = clean(category, "GENERAL", 48),
        titleKey = clean(titleKey, "", 128),
        messageKey = clean(messageKey, "", 128),
        severity = clean(severity, "info", 24),
        source = clean(source, "CORE", 48),
        amount = safeNumber(amount, 0),
        referenceId = clean(referenceId, "", 96)
    }
    state.nextId = state.nextId + 1
    table.insert(state.entries, entry)
    while #state.entries > self.maxEntries do table.remove(state.entries, 1) end
    return AgriLife.Result.ok("JOURNAL_RECORDED", "Journal entry recorded", {entry = entry})
end

function AgriLife.Journal6Service:getSnapshot(farmId, limit)
    local state = self:getState(farmId, true)
    local entries = {}
    local count = math.max(1, math.min(100, math.floor(tonumber(limit) or 30)))
    local first = math.max(1, #state.entries - count + 1)
    for index = #state.entries, first, -1 do table.insert(entries, state.entries[index]) end
    return {count = #state.entries, entries = entries}
end

function AgriLife.Journal6Service:saveFarm(xmlFile, moduleKey, farmId)
    if xmlFile == nil or moduleKey == nil then return AgriLife.Result.ok("JOURNAL_SAVE_SKIPPED", "No journal save target") end
    local state = self:getState(farmId, true)
    xmlFile:setInt(moduleKey .. ".state#nextId", state.nextId)
    for index, entry in ipairs(state.entries) do
        local key = string.format("%s.entries.entry(%d)", moduleKey, index - 1)
        xmlFile:setString(key .. "#id", entry.id)
        xmlFile:setInt(key .. "#periodKey", entry.periodKey)
        xmlFile:setInt(key .. "#day", entry.day)
        xmlFile:setFloat(key .. "#dayTime", entry.dayTime)
        xmlFile:setString(key .. "#category", entry.category)
        xmlFile:setString(key .. "#titleKey", entry.titleKey)
        xmlFile:setString(key .. "#messageKey", entry.messageKey)
        xmlFile:setString(key .. "#severity", entry.severity)
        xmlFile:setString(key .. "#source", entry.source)
        xmlFile:setFloat(key .. "#amount", entry.amount)
        xmlFile:setString(key .. "#referenceId", entry.referenceId)
    end
    return AgriLife.Result.ok("JOURNAL_SAVED", "Journal saved", {count = #state.entries})
end

function AgriLife.Journal6Service:loadFarm(xmlFile, moduleKey, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("JOURNAL_CLIENT_LOAD_SKIPPED", "No farm journal on this runtime") end
    local state = self:createDefaultState()
    if xmlFile ~= nil and moduleKey ~= nil then
        state.nextId = math.max(1, xmlFile:getInt(moduleKey .. ".state#nextId", 1))
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".entries.entry", function(_, key)
                table.insert(state.entries, {
                    id = xmlFile:getString(key .. "#id", ""),
                    periodKey = xmlFile:getInt(key .. "#periodKey", 0),
                    day = xmlFile:getInt(key .. "#day", 0),
                    dayTime = xmlFile:getFloat(key .. "#dayTime", 0),
                    category = xmlFile:getString(key .. "#category", "GENERAL"),
                    titleKey = xmlFile:getString(key .. "#titleKey", ""),
                    messageKey = xmlFile:getString(key .. "#messageKey", ""),
                    severity = xmlFile:getString(key .. "#severity", "info"),
                    source = xmlFile:getString(key .. "#source", "CORE"),
                    amount = xmlFile:getFloat(key .. "#amount", 0),
                    referenceId = xmlFile:getString(key .. "#referenceId", "")
                })
            end)
        end
    end
    while #state.entries > self.maxEntries do table.remove(state.entries, 1) end
    self.farms[farmId] = state
    return AgriLife.Result.ok("JOURNAL_LOADED", "Journal loaded", {count = #state.entries})
end

function AgriLife.Journal6Service:delete()
    self.farms = {}
    self.core = nil
end
