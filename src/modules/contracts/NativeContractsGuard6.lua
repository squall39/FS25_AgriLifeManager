-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}
AgriLife.NativeContractsGuard6 = AgriLife.NativeContractsGuard6 or {installed = false, legacyActiveAllowed = true}

local Guard = AgriLife.NativeContractsGuard6
Guard.VERSION = "0.9.3.15"

local function installClassGuard()
    if MissionManager == nil or Utils == nil or Utils.overwrittenFunction == nil then return false end
    if MissionManager.generateMissions ~= nil and Guard.originalGenerateMissions == nil then
        Guard.originalGenerateMissions = MissionManager.generateMissions
        MissionManager.generateMissions = Utils.overwrittenFunction(MissionManager.generateMissions, function(self, superFunc, ...)
            if Guard.enabled ~= false then return false end
            return superFunc(self, ...)
        end)
    end
    if MissionManager.startMission ~= nil and Guard.originalStartMission == nil then
        Guard.originalStartMission = MissionManager.startMission
        MissionManager.startMission = Utils.overwrittenFunction(MissionManager.startMission, function(self, superFunc, mission, ...)
            if Guard.enabled ~= false and mission ~= nil and mission.isStarted ~= true and mission.status ~= "running" then
                if AgriLife.Logger ~= nil then AgriLife.Logger.info("Contracts", "Native FS contract start blocked because AgriLife contracts are active") end
                return false
            end
            return superFunc(self, mission, ...)
        end)
    end
    return true
end

function Guard:install()
    if self.installed then return true end
    self.enabled = true
    self.installed = installClassGuard()
    if self.installed and AgriLife.Logger ~= nil then AgriLife.Logger.info("Contracts", "Native FS contracts disabled for new offers; existing active contracts remain finishable") end
    return self.installed
end

function Guard:update()
    if not self.installed then self:install() end
end

if Mission00 ~= nil and Utils ~= nil and Utils.appendedFunction ~= nil and Guard.missionHookInstalled ~= true then
    Guard.missionHookInstalled = true
    Mission00.update = Utils.appendedFunction(Mission00.update, function()
        Guard:update()
    end)
end
