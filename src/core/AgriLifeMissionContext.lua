-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.MissionContext = {}
AgriLife.MissionContext.__index = AgriLife.MissionContext
AgriLife.MissionContext.nextSessionId = 0

local function safeCall(target, methodName, fallback)
    if target ~= nil and target[methodName] ~= nil then
        local ok, value = pcall(target[methodName], target)
        if ok then
            return value
        end
    end
    return fallback
end

local function addFarmId(target, farmId)
    farmId = tonumber(farmId)
    if farmId ~= nil and farmId > 0 and farmId % 1 == 0 then
        target[farmId] = true
    end
end

function AgriLife.MissionContext.new(mission)
    AgriLife.MissionContext.nextSessionId = AgriLife.MissionContext.nextSessionId + 1

    local missionInfo = mission ~= nil and mission.missionInfo or nil
    local savegameDirectory = missionInfo ~= nil and missionInfo.savegameDirectory or nil
    if savegameDirectory == nil and mission ~= nil then
        savegameDirectory = mission.savegameDirectory
    end

    local isServer = safeCall(mission, "getIsServer", g_server ~= nil)
    local isClient = g_client ~= nil
    local isMultiplayer = mission ~= nil and mission.missionDynamicInfo ~= nil and mission.missionDynamicInfo.isMultiplayer == true

    return setmetatable({
        mission = mission,
        missionInfo = missionInfo,
        savegameDirectory = savegameDirectory,
        isServer = isServer == true,
        isClient = isClient == true,
        isMultiplayer = isMultiplayer,
        isDedicatedServer = g_dedicatedServerInfo ~= nil,
        sessionId = AgriLife.MissionContext.nextSessionId,
        isDeleted = false
    }, AgriLife.MissionContext)
end

function AgriLife.MissionContext:refreshRuntimeInfo()
    if self.isDeleted or self.mission == nil then
        return
    end

    self.missionInfo = self.mission.missionInfo or self.missionInfo
    local missionInfo = self.missionInfo
    local directory = missionInfo ~= nil and missionInfo.savegameDirectory or nil
    if (directory == nil or directory == "") and self.mission.savegameDirectory ~= nil then
        directory = self.mission.savegameDirectory
    end
    if directory ~= nil and directory ~= "" then
        self.savegameDirectory = directory
    end
end

function AgriLife.MissionContext:isValid()
    return not self.isDeleted and self.mission ~= nil
end

function AgriLife.MissionContext:getFarmId()
    if self.isDeleted then
        return 0
    end

    if self.mission ~= nil and self.mission.getFarmId ~= nil then
        local ok, farmId = pcall(self.mission.getFarmId, self.mission)
        if ok and tonumber(farmId) ~= nil then
            return tonumber(farmId)
        end
    end

    if self.mission ~= nil and self.mission.player ~= nil and self.mission.player.farmId ~= nil then
        return tonumber(self.mission.player.farmId) or 0
    end

    return 0
end

function AgriLife.MissionContext:getFarmIds()
    local ids = {}
    if self.isDeleted then
        return ids
    end

    if g_farmManager ~= nil and g_farmManager.getFarms ~= nil then
        local ok, farms = pcall(g_farmManager.getFarms, g_farmManager)
        if ok and type(farms) == "table" then
            for key, farm in pairs(farms) do
                if type(farm) == "table" then
                    addFarmId(ids, farm.farmId or farm.id or key)
                else
                    addFarmId(ids, key)
                end
            end
        end
    end

    addFarmId(ids, self:getFarmId())

    local sorted = {}
    for farmId in pairs(ids) do
        table.insert(sorted, farmId)
    end
    table.sort(sorted)
    return sorted
end

function AgriLife.MissionContext:requireServer(operationName)
    if self.isServer then
        return AgriLife.Result.ok("SERVER_ALLOWED", operationName or "Server operation allowed")
    end
    return AgriLife.Result.fail("SERVER_REQUIRED", operationName or "Operation requires the server")
end

function AgriLife.MissionContext:delete()
    self.isDeleted = true
    self.mission = nil
    self.missionInfo = nil
    self.savegameDirectory = nil
end
