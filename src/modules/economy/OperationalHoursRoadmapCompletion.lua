-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.0 - centralized operational opening hours.
AgriLife = AgriLife or {}

AgriLife.OperationalHours93 = AgriLife.OperationalHours93 or {}
local Hours = AgriLife.OperationalHours93
Hours.VERSION = "0.9.3.0"
Hours.SCHEDULES = {
    BANK = {{480,720},{840,1080}},       -- 08:00-12:00 / 14:00-18:00
    DEALER = {{480,1140}},               -- 08:00-19:00
    PERSONAL_WORKSHOP = {{0,1440}},       -- 24/7
    FACTORY = {{480,1140}},               -- 08:00-19:00 interactions; internal production continues
    SELL_POINT = {{480,720},{840,1080}}  -- 08:00-12:00 / 14:00-18:00
}

local function text(value, fallback)
    value = tostring(value or "")
    if value ~= "" then return value end
    return tostring(fallback or "")
end

function Hours:getEnvironment()
    return g_currentMission ~= nil and g_currentMission.environment or nil
end

function Hours:getMinuteOfDay()
    local environment = self:getEnvironment()
    local dayTime = tonumber(environment ~= nil and environment.dayTime) or 0
    local minute = math.floor((dayTime / 60000) % 1440)
    if minute < 0 then minute = minute + 1440 end
    return minute
end

function Hours:formatMinute(minute)
    minute = math.floor(tonumber(minute) or 0) % 1440
    return string.format("%02d:%02d", math.floor(minute / 60), minute % 60)
end

function Hours:isOpen(kind, minute)
    kind = tostring(kind or "")
    local schedule = self.SCHEDULES[kind]
    if schedule == nil then return true end
    minute = minute ~= nil and math.floor(tonumber(minute) or 0) or self:getMinuteOfDay()
    for _, window in ipairs(schedule) do if minute >= window[1] and minute < window[2] then return true end end
    return false
end

function Hours:getNextOpening(kind, minute)
    local schedule = self.SCHEDULES[tostring(kind or "")]
    if schedule == nil or #schedule == 0 then return nil end
    minute = minute ~= nil and math.floor(tonumber(minute) or 0) or self:getMinuteOfDay()
    for _, window in ipairs(schedule) do if minute < window[1] then return window[1], false end end
    return schedule[1][1], true
end

function Hours:getScheduleText(kind)
    local schedule = self.SCHEDULES[tostring(kind or "")]
    if schedule == nil then return "24/7" end
    local parts = {}
    for _, window in ipairs(schedule) do table.insert(parts, self:formatMinute(window[1]).."-"..self:formatMinute(window[2])) end
    return table.concat(parts, " / ")
end

function Hours:getResultCode(kind)
    return "AGRILIFE_HOURS_"..text(kind,"CLOSED").."_CLOSED"
end

function Hours:closedResult(kind)
    local nextOpen, tomorrow = self:getNextOpening(kind)
    return AgriLife.Result.fail(self:getResultCode(kind), "Service closed", {
        kind=tostring(kind or ""), currentMinute=self:getMinuteOfDay(), schedule=self:getScheduleText(kind),
        nextOpeningMinute=nextOpen, nextOpeningTomorrow=tomorrow == true
    })
end

function Hours:showClosedInfo(kind)
    if g_gui == nil then return end
    local key = "agrilife_hours93_closed_"..string.lower(tostring(kind or "service"))
    local label = g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText(key) or nil
    if label == nil or label == "" or label == key then label = "Fermé - horaires : "..self:getScheduleText(kind) end
    if g_gui.showInfoDialog ~= nil then pcall(g_gui.showInfoDialog, g_gui, {text=label}) end
end

local function wrapMethod(target, methodName, kind, closedReturn)
    if target == nil or type(target[methodName]) ~= "function" then return false end
    local marker = "agriLifeHours93_"..methodName
    if target[marker] == true then return true end
    local base = target[methodName]
    target[methodName] = function(self, ...)
        if not Hours:isOpen(kind) then
            Hours:showClosedInfo(kind)
            return closedReturn
        end
        return base(self, ...)
    end
    target[marker] = true
    return true
end

function Hours:getUnloadingStationKind(station)
    local placeable = station ~= nil and station.owningPlaceable or nil
    if placeable ~= nil and (placeable.spec_productionPoint ~= nil or placeable.spec_factory ~= nil) then return "FACTORY" end
    return "SELL_POINT"
end

function Hours:installBaseGameHooks()
    if self.baseGameHooksInstalled == true then return true end
    -- Dealership: block purchase/lease/sale operations when the dealership is closed.
    -- AgriLife's own dealership pages are also guarded in HomeFrame.
    if ShopMenu ~= nil then
        for _, method in ipairs({"onClickBuy","onClickLease","onClickSell","onClickBuyVehicle","onClickLeaseVehicle"}) do wrapMethod(ShopMenu, method, "DEALER", false) end
    end

    -- FS25 selling/production delivery path. UnloadingStation:addFillLevelFromTool returns
    -- the amount actually transferred, therefore returning 0 is a safe closed-state refusal.
    if UnloadingStation ~= nil and type(UnloadingStation.addFillLevelFromTool) == "function" and UnloadingStation.agriLifeHours93_addFillLevelFromTool ~= true then
        local baseAddFill = UnloadingStation.addFillLevelFromTool
        UnloadingStation.addFillLevelFromTool = function(station, ...)
            local kind = Hours:getUnloadingStationKind(station)
            if not Hours:isOpen(kind) then
                Hours:showClosedInfo(kind)
                return 0
            end
            return baseAddFill(station, ...)
        end
        UnloadingStation.agriLifeHours93_addFillLevelFromTool = true
    end

    -- Buying an unowned production point is a commercial interaction and follows factory hours.
    if ProductionPoint ~= nil and type(ProductionPoint.buyRequest) == "function" and ProductionPoint.agriLifeHours93_buyRequest ~= true then
        local baseBuyRequest = ProductionPoint.buyRequest
        ProductionPoint.buyRequest = function(point, ...)
            if not Hours:isOpen("FACTORY") then Hours:showClosedInfo("FACTORY"); return false end
            return baseBuyRequest(point, ...)
        end
        ProductionPoint.agriLifeHours93_buyRequest = true
    end

    self.baseGameHooksInstalled = true
    return true
end

Hours:installBaseGameHooks()

-- Bank: block manual customer actions only. Automatic instalments/fees continue overnight.
if AgriLife.Bank6Service ~= nil then
    local Bank = AgriLife.Bank6Service
    local function wrapBank(name)
        if type(Bank[name]) ~= "function" or Bank["agriLifeHours93_"..name] == true then return end
        local base = Bank[name]
        Bank[name] = function(self, ...)
            -- IMPORTANT: select(1, ...) can return several values. Passing that
            -- expression directly to tonumber would feed the second vararg as
            -- tonumber's optional base and crash whenever it is a string.
            local farmIdArg = select(1, ...)
            local providerIdArg = select(2, ...)
            local farmId = tonumber(farmIdArg) or 0
            local providerId = nil
            if name == "setProvider" then
                providerId = tostring(providerIdArg or "")
            else
                local state = self.getFarmState ~= nil and self:getFarmState(farmId, true) or nil
                providerId = state ~= nil and tostring(state.providerId or "") or ""
            end
            local digitalOpen = self.isDigitalProvider ~= nil and self:isDigitalProvider(providerId)
            if not digitalOpen and not Hours:isOpen("BANK") then return Hours:closedResult("BANK") end
            return base(self, ...)
        end
        Bank["agriLifeHours93_"..name] = true
    end
    for _, name in ipairs({"setProvider","setAdvisor","requestLoan","repayEarly","restructureLoan","setOverdraftLimit","signRelationshipContract","renewRelationshipContract","terminateRelationshipContract","requestRefinance","payTax"}) do wrapBank(name) end
    local baseSnapshot = Bank.getSnapshot
    if type(baseSnapshot) == "function" then
        function Bank:getSnapshot(farmId)
            local snapshot = baseSnapshot(self, farmId)
            local state = self.getFarmState ~= nil and self:getFarmState(farmId, true) or nil
            local providerId = state ~= nil and tostring(state.providerId or "") or ""
            local digitalOpen = self.isDigitalProvider ~= nil and self:isDigitalProvider(providerId)
            snapshot.bankOpen = digitalOpen or Hours:isOpen("BANK")
            snapshot.bankHours = digitalOpen and "24/7" or Hours:getScheduleText("BANK")
            snapshot.bankCurrentMinute = Hours:getMinuteOfDay()
            return snapshot
        end
    end
end

-- Dealer workshop jobs require an open dealership; personal workshop remains unrestricted.
if AgriLife.Workshop6Service ~= nil and type(AgriLife.Workshop6Service.createWorkshopJob) == "function" then
    local Workshop = AgriLife.Workshop6Service
    local baseCreateJobHours93 = Workshop.createWorkshopJob
    function Workshop:createWorkshopJob(farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        if tostring(provider or "") == "DEALER" and tostring(kind or "") ~= "RECOVERY" and not Hours:isOpen("DEALER") then return Hours:closedResult("DEALER") end
        return baseCreateJobHours93(self, farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
    end
    local baseWorkshopSnapshotHours93 = Workshop.getSnapshot
    function Workshop:getSnapshot(farmId)
        local snapshot = baseWorkshopSnapshotHours93(self, farmId)
        snapshot.operationalHours = {
            dealerOpen=Hours:isOpen("DEALER"), dealerHours=Hours:getScheduleText("DEALER"),
            personalWorkshopOpen=true, personalWorkshopHours="24/7",
            currentMinute=Hours:getMinuteOfDay()
        }
        return snapshot
    end
end

-- Used/new asset transactions performed through AgriLife also respect dealer hours.
if AgriLife.AssetLifecycle6Service ~= nil then
    local Assets = AgriLife.AssetLifecycle6Service
    for _, name in ipairs({"purchaseUsed","createLease","buyoutLease","returnLease","inspectOffer"}) do
        if type(Assets[name]) == "function" and Assets["agriLifeHours93_"..name] ~= true then
            local base = Assets[name]
            Assets[name] = function(self, ...)
                if not Hours:isOpen("DEALER") then return Hours:closedResult("DEALER") end
                return base(self, ...)
            end
            Assets["agriLifeHours93_"..name] = true
        end
    end
end

if AgriLife.DynamicMarket6Service ~= nil then
    local Market = AgriLife.DynamicMarket6Service
    local baseSnapshotMarketHours93 = Market.getSnapshot
    if type(baseSnapshotMarketHours93) == "function" then
        function Market:getSnapshot(farmId)
            local snapshot = baseSnapshotMarketHours93(self, farmId)
            snapshot.operationalHours = {
                factoryOpen=Hours:isOpen("FACTORY"), factoryHours=Hours:getScheduleText("FACTORY"),
                sellPointOpen=Hours:isOpen("SELL_POINT"), sellPointHours=Hours:getScheduleText("SELL_POINT"),
                dealerOpen=Hours:isOpen("DEALER"), dealerHours=Hours:getScheduleText("DEALER"),
                currentMinute=Hours:getMinuteOfDay()
            }
            return snapshot
        end
    end
end
