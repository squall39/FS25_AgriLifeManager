-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - final economy ledger metadata and professional transaction writing completion.
AgriLife = AgriLife or {}

AgriLife.EconomyAccountingRoadmapCompletion = AgriLife.EconomyAccountingRoadmapCompletion or {}
AgriLife.EconomyAccountingRoadmapCompletion.VERSION = "0.9.1.0"

local function clean(value, fallback, limit)
    value = tostring(value or fallback or ""):gsub("[%c]", " "):gsub("%s+", " ")
    value = value:match("^%s*(.-)%s*$") or value
    limit = tonumber(limit) or 120
    if #value > limit then value = value:sub(1, limit) end
    return value
end

local function upper(value)
    return string.upper(clean(value, "", 96))
end

local function round(value)
    value = tonumber(value) or 0
    if value >= 0 then return math.floor(value * 100 + 0.5) / 100 end
    return math.ceil(value * 100 - 0.5) / 100
end

local function splitTags(value)
    local result, seen = {}, {}
    if type(value) == "table" then
        for _, item in pairs(value) do
            local tag = clean(item, "", 40)
            if tag ~= "" and not seen[tag] then seen[tag] = true; table.insert(result, tag) end
        end
    else
        for tag in tostring(value or ""):gmatch("[^|,;]+") do
            tag = clean(tag, "", 40)
            if tag ~= "" and not seen[tag] then seen[tag] = true; table.insert(result, tag) end
        end
    end
    table.sort(result)
    return result
end

local function joinTags(value)
    return table.concat(splitTags(value), "|")
end

local function containsTag(tags, wanted)
    wanted = clean(wanted, "", 40)
    if wanted == "" then return true end
    for _, tag in ipairs(splitTags(tags)) do if tag == wanted then return true end end
    return false
end

local function inferAccountingCategory(category, source, note, amount)
    local c = upper(category)
    if c ~= "FS25_MONEY" and c ~= "EXTERNAL_DIFFERENCE" then return c end
    local moneyType = upper(note)
    amount = tonumber(amount) or 0
    if moneyType:find("SOLD_PRODUCT", 1, true) or moneyType:find("HARVEST_INCOME", 1, true) then return "FS25_PRODUCT_SALE" end
    if moneyType:find("SOLD_VEHICLE", 1, true) then return "FS25_ASSET_SALE" end
    if moneyType:find("SOLD_LAND", 1, true) then return "FS25_LAND_SALE" end
    if moneyType:find("PURCHASE", 1, true) and (moneyType:find("SEED", 1, true) or moneyType:find("FERTIL", 1, true) or moneyType:find("LIME", 1, true) or moneyType:find("HERBICIDE", 1, true)) then return "FS25_INPUT_PURCHASE" end
    if moneyType:find("FUEL", 1, true) or moneyType:find("DIESEL", 1, true) or moneyType:find("ELECTRIC", 1, true) or moneyType:find("METHANE", 1, true) then return "FS25_ENERGY_COST" end
    if moneyType:find("VEHICLE_RUNNING", 1, true) or moneyType:find("VEHICLE_MAINTENANCE", 1, true) then return "FS25_VEHICLE_COST" end
    if moneyType:find("PROPERTY_MAINTENANCE", 1, true) or moneyType:find("PRODUCTION_COST", 1, true) then return "FS25_PRODUCTION_COST" end
    if moneyType:find("NEW_VEHICLE", 1, true) or moneyType:find("PURCHASE_VEHICLE", 1, true) then return "FS25_EQUIPMENT_PURCHASE" end
    if moneyType:find("LAND", 1, true) and amount < 0 then return "FS25_LAND_PURCHASE" end
    if moneyType:find("LOAN", 1, true) then return "FS25_LOAN_MOVEMENT" end
    if moneyType:find("MISSION", 1, true) or moneyType:find("CONTRACT", 1, true) then return amount >= 0 and "FS25_CONTRACT_INCOME" or "FS25_CONTRACT_COST" end
    if moneyType:find("WAGE", 1, true) or moneyType:find("HELPER", 1, true) then return "FS25_LABOUR_COST" end
    if moneyType:find("LEAS", 1, true) or moneyType:find("RENT", 1, true) then return "FS25_RENTAL_COST" end
    if moneyType:find("ANIMAL", 1, true) then return amount >= 0 and "FS25_ANIMAL_INCOME" or "FS25_ANIMAL_COST" end
    return amount >= 0 and "FS25_OTHER_INCOME" or "FS25_OTHER_EXPENSE"
end

local function inferFlowType(category, amount)
    local c = upper(category)
    amount = tonumber(amount) or 0
    if c:find("PURCHASE", 1, true) or c:find("DEPOSIT", 1, true) or c:find("CAPITAL", 1, true) then return "INVESTMENT" end
    if c:find("LOAN", 1, true) or c:find("REFINANCE", 1, true) or c:find("BANK_", 1, true) then return "FINANCING" end
    if c:find("TAX", 1, true) or c:find("FISCAL", 1, true) then return "TAX" end
    if c:find("PAYROLL", 1, true) or c:find("SALARY", 1, true) then return "PAYROLL" end
    if c:find("CONTRACT", 1, true) then return "CONTRACT" end
    if c:find("RENT", 1, true) or c:find("LEASE", 1, true) then return "RENTAL" end
    if c:find("INSURANCE", 1, true) or c:find("CLAIM", 1, true) then return "INSURANCE" end
    if c:find("REPAIR", 1, true) or c:find("MAINTENANCE", 1, true) or c:find("WORKSHOP", 1, true) or c:find("SERVICE", 1, true) then return "WORKSHOP" end
    if c:find("MARKET", 1, true) or c:find("SALE", 1, true) then return amount >= 0 and "SALE" or "PURCHASE" end
    if amount > 0 then return "INCOME" end
    if amount < 0 then return "EXPENSE" end
    return "INFORMATION"
end

local function inferReference(category, note)
    local c = upper(category)
    local n = clean(note, "", 120)
    if n == "" then return "" end
    if c:find("CONTRACT", 1, true) or c:find("LEASE", 1, true) or c:find("RENTAL", 1, true) or c:find("PURCHASE", 1, true) or c:find("ACCIDENT", 1, true) or c:find("CLAIM", 1, true) then
        local token = n:match("^([%w_%-%.:]+)")
        return clean(token or n, "", 80)
    end
    return ""
end

local function inferCounterparty(source, category, note)
    local sourceId = upper(source)
    if sourceId == "CONTRACTS" then return "COMMERCIAL_BUYER" end
    if sourceId == "MARKET" then return "MARKET" end
    if sourceId == "WORKSHOP" then return "WORKSHOP_OR_DEALER" end
    if sourceId == "INSURANCE" then return "INSURER" end
    if sourceId == "BANK" then return "BANK" end
    if sourceId == "PAYROLL" then return "EMPLOYEE" end
    if sourceId == "LEGAL" or sourceId == "ADMINISTRATION" then return "ADMINISTRATION" end
    if sourceId == "ASSETS" then return "DEALER_OR_LESSOR" end
    local c = upper(category)
    if c:find("FUEL", 1, true) then return "FUEL_SUPPLIER" end
    if c:find("INPUT", 1, true) or c:find("SEED", 1, true) or c:find("FERTIL", 1, true) then return "INPUT_SUPPLIER" end
    return clean(source, clean(note, "", 60), 60)
end

local function inferTags(category, source, flowType)
    local tags = {upper(source), upper(flowType)}
    local c = upper(category)
    if c:find("CONTRACT", 1, true) then table.insert(tags, "CONTRACT") end
    if c:find("FUEL", 1, true) then table.insert(tags, "FUEL") end
    if c:find("INPUT", 1, true) or c:find("SEED", 1, true) or c:find("FERTIL", 1, true) then table.insert(tags, "INPUT") end
    if c:find("WORKSHOP", 1, true) or c:find("REPAIR", 1, true) or c:find("MAINTENANCE", 1, true) then table.insert(tags, "WORKSHOP") end
    if c:find("PURCHASE", 1, true) then table.insert(tags, "PURCHASE") end
    if c:find("SALE", 1, true) then table.insert(tags, "SALE") end
    if c:find("TAX", 1, true) or c:find("FISCAL", 1, true) then table.insert(tags, "TAX") end
    return joinTags(tags)
end

if AgriLife.Economy6Service ~= nil then
    local Economy = AgriLife.Economy6Service
    local baseRecord = Economy.record
    local baseSaveFarm = Economy.saveFarm
    local baseLoadFarm = Economy.loadFarm
    local baseSanitize = Economy.sanitize
    local baseGetSnapshot = Economy.getSnapshot

    function Economy:normalizeLedgerMetadata(entry, metadata)
        if type(entry) ~= "table" then return entry end
        metadata = type(metadata) == "table" and metadata or {}
        entry.accountingCategory = clean(metadata.accountingCategory, entry.accountingCategory ~= nil and entry.accountingCategory or inferAccountingCategory(entry.category, entry.source, entry.note, entry.amount), 80)
        entry.flowType = clean(metadata.flowType, entry.flowType ~= nil and entry.flowType or inferFlowType(entry.accountingCategory or entry.category, entry.amount), 40)
        entry.counterparty = clean(metadata.counterparty, entry.counterparty ~= nil and entry.counterparty or inferCounterparty(entry.source, entry.category, entry.note), 80)
        entry.referenceId = clean(metadata.referenceId, entry.referenceId ~= nil and entry.referenceId or inferReference(entry.category, entry.note), 80)
        entry.contractId = clean(metadata.contractId, entry.contractId ~= nil and entry.contractId or (upper(entry.category):find("CONTRACT", 1, true) and entry.referenceId or ""), 80)
        entry.supplierId = clean(metadata.supplierId, entry.supplierId ~= nil and entry.supplierId or entry.counterparty, 80)
        local tags = splitTags(entry.tags)
        for _, tag in ipairs(splitTags(metadata.tags)) do table.insert(tags, tag) end
        for _, tag in ipairs(splitTags(inferTags(entry.category, entry.source, entry.flowType))) do table.insert(tags, tag) end
        entry.tags = joinTags(tags)
        entry.documentType = clean(metadata.documentType, entry.documentType ~= nil and entry.documentType or entry.flowType, 40)
        return entry
    end

    function Economy:record(farmId, category, amount, source, profileId, note, metadata)
        local entry = baseRecord(self, farmId, category, amount, source, profileId, note)
        return self:normalizeLedgerMetadata(entry, metadata)
    end

    function Economy:recordDetailed(farmId, category, amount, source, profileId, note, metadata)
        return self:record(farmId, category, amount, source, profileId, note, metadata)
    end

    function Economy:sanitize(state)
        state = baseSanitize(self, state)
        for _, entry in ipairs(state ~= nil and state.ledger or {}) do self:normalizeLedgerMetadata(entry, nil) end
        return state
    end

    function Economy:getProfessionalTransactions(farmId, filters)
        filters = type(filters) == "table" and filters or {}
        local state = self:getFarmState(farmId, true)
        local fromPeriod = math.max(0, math.floor(tonumber(filters.periodFrom) or 0))
        local toPeriod = math.max(0, math.floor(tonumber(filters.periodTo) or 0))
        local category = upper(filters.category)
        local supplier = upper(filters.supplier or filters.counterparty)
        local contractId = upper(filters.contractId or filters.contract)
        local flowType = upper(filters.flowType or filters.type)
        local source = upper(filters.source)
        local tag = clean(filters.tag, "", 40)
        local query = string.lower(clean(filters.query, "", 80))
        local limit = math.max(1, math.min(500, math.floor(tonumber(filters.limit) or 250)))
        local rows, incoming, outgoing = {}, 0, 0
        for _, raw in ipairs(state ~= nil and state.ledger or {}) do
            local entry = self:normalizeLedgerMetadata(raw, nil)
            local periodKey = tonumber(entry.periodKey) or 0
            local matches = (fromPeriod <= 0 or periodKey >= fromPeriod) and (toPeriod <= 0 or periodKey <= toPeriod)
            matches = matches and (category == "" or upper(entry.category) == category)
            matches = matches and (supplier == "" or upper(entry.supplierId) == supplier or upper(entry.counterparty) == supplier)
            matches = matches and (contractId == "" or upper(entry.contractId) == contractId or upper(entry.referenceId) == contractId)
            matches = matches and (flowType == "" or upper(entry.flowType) == flowType)
            matches = matches and (source == "" or upper(entry.source) == source)
            matches = matches and containsTag(entry.tags, tag)
            if matches and query ~= "" then
                local haystack = string.lower(table.concat({entry.category or "", entry.source or "", entry.note or "", entry.counterparty or "", entry.referenceId or "", entry.tags or ""}, " "))
                matches = string.find(haystack, query, 1, true) ~= nil
            end
            if matches then
                local amount = round(entry.amount)
                if amount >= 0 then incoming = incoming + amount else outgoing = outgoing + math.abs(amount) end
                table.insert(rows, {
                    id=entry.id, periodKey=periodKey, category=entry.category, amount=amount, source=entry.source,
                    profileId=entry.profileId, note=entry.note, flowType=entry.flowType, counterparty=entry.counterparty,
                    supplierId=entry.supplierId, referenceId=entry.referenceId, contractId=entry.contractId,
                    tags=entry.tags, documentType=entry.documentType, accountingCategory=entry.accountingCategory
                })
            end
        end
        table.sort(rows, function(a, b)
            if a.periodKey ~= b.periodKey then return a.periodKey > b.periodKey end
            return tostring(a.id or "") > tostring(b.id or "")
        end)
        while #rows > limit do table.remove(rows) end
        return {rows=rows, count=#rows, incoming=round(incoming), outgoing=round(outgoing), net=round(incoming-outgoing), filters=filters}
    end

    function Economy:saveFarm(xmlFile, key, farmId)
        local result = baseSaveFarm(self, xmlFile, key, farmId)
        if result == nil or not result.ok or xmlFile == nil or key == nil then return result end
        local state = self:getFarmState(farmId, true)
        for index, entry in ipairs(state ~= nil and state.ledger or {}) do
            entry = self:normalizeLedgerMetadata(entry, nil)
            local itemKey = string.format("%s.ledger.entry(%d)", key, index - 1)
            xmlFile:setString(itemKey .. "#accountingCategory", entry.accountingCategory or "")
            xmlFile:setString(itemKey .. "#flowType", entry.flowType or "")
            xmlFile:setString(itemKey .. "#counterparty", entry.counterparty or "")
            xmlFile:setString(itemKey .. "#supplierId", entry.supplierId or "")
            xmlFile:setString(itemKey .. "#referenceId", entry.referenceId or "")
            xmlFile:setString(itemKey .. "#contractId", entry.contractId or "")
            xmlFile:setString(itemKey .. "#tags", entry.tags or "")
            xmlFile:setString(itemKey .. "#documentType", entry.documentType or "")
        end
        return result
    end

    function Economy:loadFarm(xmlFile, key, farmId)
        local result = baseLoadFarm(self, xmlFile, key, farmId)
        if result == nil or not result.ok or xmlFile == nil or key == nil then return result end
        local state = self:getFarmState(farmId, true)
        local rows = {}
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(key .. ".ledger.entry", function(_, itemKey)
                table.insert(rows, {
                    accountingCategory=xmlFile:getString(itemKey .. "#accountingCategory", ""),
                    flowType=xmlFile:getString(itemKey .. "#flowType", ""),
                    counterparty=xmlFile:getString(itemKey .. "#counterparty", ""),
                    supplierId=xmlFile:getString(itemKey .. "#supplierId", ""),
                    referenceId=xmlFile:getString(itemKey .. "#referenceId", ""),
                    contractId=xmlFile:getString(itemKey .. "#contractId", ""),
                    tags=xmlFile:getString(itemKey .. "#tags", ""),
                    documentType=xmlFile:getString(itemKey .. "#documentType", "")
                })
            end)
        end
        for index, entry in ipairs(state ~= nil and state.ledger or {}) do self:normalizeLedgerMetadata(entry, rows[index]) end
        return result
    end

    function Economy:getAccountingLedgerCompletionSnapshot(farmId)
        local all = self:getProfessionalTransactions(farmId, {limit=500})
        local flows = {}
        for _, row in ipairs(all.rows) do
            local id = tostring(row.flowType or "INFORMATION")
            flows[id] = flows[id] or {count=0, incoming=0, outgoing=0}
            local bucket = flows[id]
            bucket.count = bucket.count + 1
            if row.amount >= 0 then bucket.incoming = round(bucket.incoming + row.amount) else bucket.outgoing = round(bucket.outgoing + math.abs(row.amount)) end
        end
        return {version=AgriLife.EconomyAccountingRoadmapCompletion.VERSION, transactionCount=all.count, incoming=all.incoming, outgoing=all.outgoing, net=all.net, flows=flows, metadataPersistent=true, filters={period=true, category=true, supplier=true, contract=true, flowType=true, source=true, tags=true}}
    end

    function Economy:getSnapshot(farmId)
        local snapshot = baseGetSnapshot(self, farmId) or {}
        snapshot.accountingLedger = self:getAccountingLedgerCompletionSnapshot(farmId)
        return snapshot
    end
end

if AgriLife.EconomyModule ~= nil then
    AgriLife.EconomyModule.VERSION = "0.9.1.0"
    AgriLife.EconomyModule.SCHEMA_VERSION = math.max(tonumber(AgriLife.EconomyModule.SCHEMA_VERSION) or 1, 6)
    function AgriLife.EconomyModule:recordDetailed(...) return self.service:recordDetailed(...) end
    function AgriLife.EconomyModule:getProfessionalTransactions(...) return self.service:getProfessionalTransactions(...) end
    function AgriLife.EconomyModule:getAccountingLedgerCompletionSnapshot(...) return self.service:getAccountingLedgerCompletionSnapshot(...) end
    local baseDescriptor = AgriLife.EconomyModule.getDescriptor
    function AgriLife.EconomyModule.getDescriptor()
        local descriptor = baseDescriptor()
        descriptor.version = "0.9.1.0"
        descriptor.schemaVersion = math.max(tonumber(descriptor.schemaVersion) or 1, 6)
        return descriptor
    end
end
