-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.People6Service = {}
AgriLife.People6Service.__index = AgriLife.People6Service
AgriLife.People6Service.SCHEMA_VERSION = 1

AgriLife.People6Service.ROLES = {
    owner = { labelKey = "agrilife_people6_role_owner", rank = 100 },
    manager = { labelKey = "agrilife_people6_role_manager", rank = 80 },
    partner = { labelKey = "agrilife_people6_role_partner", rank = 60 },
    employee = { labelKey = "agrilife_people6_role_employee", rank = 40 },
    apprentice = { labelKey = "agrilife_people6_role_apprentice", rank = 20 }
}

AgriLife.People6Service.PERMISSIONS = {
    ["company.manage"] = { owner = true, manager = true },
    ["bank.manage"] = { owner = true },
    ["payroll.manage"] = { owner = true, manager = true },
    ["contracts.manage"] = { owner = true, manager = true },
    ["insurance.manage"] = { owner = true },
    ["insurance.declareAccident"] = { owner = true, manager = true, partner = true, employee = true, apprentice = true },
    ["workshop.manage"] = { owner = true, manager = true },
    ["assets.manage"] = { owner = true, manager = true },
    ["legal.manage"] = { owner = true, manager = true },
    ["profiles.manage"] = { owner = true, manager = true },
    ["roles.manage"] = { owner = true },
    ["career.viewTeam"] = { owner = true, manager = true, partner = true, employee = true, apprentice = true },
    ["exams.viewTeam"] = { owner = true, manager = true, partner = true, employee = true, apprentice = true },
    ["profile.viewSelf"] = { owner = true, manager = true, partner = true, employee = true, apprentice = true }
}

local function safeInt(v, d)
    v = tonumber(v)
    if v == nil or v ~= v or v == math.huge or v == -math.huge then return d or 0 end
    return math.floor(v)
end

local function clean(v, fallback, maxLen)
    v = tostring(v or fallback or ""):gsub("[%c]", " "):gsub("%s+", " ")
    v = v:match("^%s*(.-)%s*$") or v
    if #v > (maxLen or 96) then v = v:sub(1, maxLen or 96) end
    return v
end

function AgriLife.People6Service.new(core)
    return setmetatable({ core = core, farms = {}, syncAccumulator = 0, snapshotListeners = {} }, AgriLife.People6Service)
end

function AgriLife.People6Service:createDefaultFarmState()
    return { profiles = {}, audit = {}, nextAuditId = 1 }
end

function AgriLife.People6Service:getFarmState(farmId, create)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return nil end
    local state = self.farms[farmId]
    if state == nil and create ~= false then
        state = self:createDefaultFarmState()
        self.farms[farmId] = state
    end
    return state
end

function AgriLife.People6Service:getPeriodKey()
    local env = g_currentMission ~= nil and g_currentMission.environment or nil
    local year = env ~= nil and tonumber(env.currentYear) or 1
    local period = env ~= nil and tonumber(env.currentPeriod) or 1
    return math.max(1, safeInt(year, 1) * 12 + math.max(1, math.min(12, safeInt(period, 1))))
end

function AgriLife.People6Service:getDayStamp()
    local env = g_currentMission ~= nil and g_currentMission.environment or nil
    return math.max(0, safeInt(env ~= nil and (env.currentMonotonicDay or env.currentDay) or 0, 0))
end

function AgriLife.People6Service:getTimeStamp()
    local env = g_currentMission ~= nil and g_currentMission.environment or nil
    return math.max(0, safeInt(env ~= nil and env.dayTime or 0, 0))
end

function AgriLife.People6Service:getUserForPlayer(player)
    if player == nil or g_currentMission == nil or g_currentMission.userManager == nil then return nil end
    local manager = g_currentMission.userManager
    if player.userId ~= nil and manager.getUserByUserId ~= nil then
        local ok, user = pcall(manager.getUserByUserId, manager, player.userId)
        if ok then return user end
    end
    return nil
end

function AgriLife.People6Service:getPlayerIdentity(player, farmId)
    farmId = tonumber(farmId) or 0
    local fallback = "SP_FARM_" .. tostring(farmId)
    if player == nil then return fallback, "Joueur" end

    local uniqueId = nil
    if player.getUniqueUserId ~= nil then
        local ok, value = pcall(player.getUniqueUserId, player)
        if ok and value ~= nil and tostring(value) ~= "" then uniqueId = value end
    end
    if uniqueId == nil then uniqueId = player.uniqueUserId end

    local user = self:getUserForPlayer(player)
    if uniqueId == nil and user ~= nil then
        for _, key in ipairs({ "uniqueUserId", "userId", "platformUserId" }) do
            if user[key] ~= nil and tostring(user[key]) ~= "" then uniqueId = user[key]; break end
        end
    end

    local displayName = nil
    if user ~= nil then
        for _, fn in ipairs({ "getNickname", "getName" }) do
            if user[fn] ~= nil then
                local ok, value = pcall(user[fn], user)
                if ok and value ~= nil and tostring(value) ~= "" then displayName = value; break end
            end
        end
    end
    displayName = displayName or player.nickname or player.name or "Joueur"
    return clean(uniqueId, fallback, 96), clean(displayName, "Joueur", 48)
end

local function getRootVehicle(vehicle)
    if vehicle==nil then return nil end
    if vehicle.getRootVehicle~=nil then local ok,v=pcall(vehicle.getRootVehicle,vehicle); if ok and v~=nil then return v end end
    return vehicle
end

function AgriLife.People6Service:getPlayerVehicle(player)
    if player==nil then return nil end
    for _,fn in ipairs({"getCurrentVehicle","getControlledVehicle"}) do
        if player[fn]~=nil then local ok,v=pcall(player[fn],player); if ok and v~=nil then return getRootVehicle(v) end end
    end
    for _,key in ipairs({"controlledVehicle","currentVehicle","vehicle"}) do if player[key]~=nil then return getRootVehicle(player[key]) end end
    if g_currentMission~=nil then
        local isLocalPlayer = g_currentMission.player==player or (g_currentMission.playerSystem~=nil and g_currentMission.playerSystem.currentPlayer==player)
        if isLocalPlayer then return getRootVehicle(g_currentMission.controlledVehicle) end
    end
    return nil
end

function AgriLife.People6Service:getConnectedPlayerContexts()
    local result={}
    if g_currentMission==nil or g_currentMission.playerSystem==nil then return result end
    for _,player in pairs(g_currentMission.playerSystem.players or {}) do
        local farmId=tonumber(player.farmId) or 0
        if farmId>0 then
            local profileId,name=self:getPlayerIdentity(player,farmId)
            table.insert(result,{farmId=farmId,profileId=profileId,displayName=name,player=player,vehicle=self:getPlayerVehicle(player)})
        end
    end
    if #result==0 and self.core~=nil and self.core.context~=nil then
        local farmId=tonumber(self.core.context:getFarmId()) or 0
        if farmId>0 then
            local profileId,name,player=self:getConnectionIdentity(nil,farmId)
            -- The local Player object can be nil for a few frames during mission
            -- startup. Returning SP_FARM_x here used to leak that placeholder
            -- into Payroll/Career/Exam as a second real person. Wait for the
            -- actual player instead.
            if player~=nil and profileId~=nil and tostring(profileId)~="" then
                table.insert(result,{farmId=farmId,profileId=profileId,displayName=name,player=player,vehicle=getRootVehicle(g_currentMission~=nil and g_currentMission.controlledVehicle or nil)})
            end
        end
    end

    -- FS25 1.21 can expose the local player in playerSystem.players before that
    -- Player instance reports its controlled vehicle. Re-bind the global local
    -- controlledVehicle only to the matching local identity, never to another
    -- multiplayer profile.
    local controlled=getRootVehicle(g_currentMission~=nil and g_currentMission.controlledVehicle or nil)
    if controlled~=nil and self.core~=nil and self.core.context~=nil then
        local localFarmId=tonumber(self.core.context:getFarmId()) or 0
        if localFarmId>0 then
            local localProfileId,_,localPlayer=self:getConnectionIdentity(nil,localFarmId)
            if localPlayer~=nil and localProfileId~=nil and tostring(localProfileId)~="" then
                for _,ctx in ipairs(result) do
                    if tonumber(ctx.farmId)==localFarmId and tostring(ctx.profileId)==tostring(localProfileId) and ctx.vehicle==nil then
                        ctx.vehicle=controlled
                        break
                    end
                end
            end
        end
    end
    return result
end

function AgriLife.People6Service:getProfileIdForVehicle(farmId, vehicle)
    local root=getRootVehicle(vehicle)
    if root==nil then return nil end
    for _,ctx in ipairs(self:getConnectedPlayerContexts()) do
        if tonumber(ctx.farmId)==tonumber(farmId) and ctx.vehicle~=nil and getRootVehicle(ctx.vehicle)==root then return ctx.profileId end
    end
    -- Solo fallback: some FS25 builds expose the controlled vehicle globally before
    -- Player:getCurrentVehicle starts returning it. Never lose the owner's XP for that gap.
    local controlled=getRootVehicle(g_currentMission~=nil and g_currentMission.controlledVehicle or nil)
    if controlled~=nil and controlled==root then
        local profileId,_,player=self:getConnectionIdentity(nil,farmId)
        if player~=nil and profileId~=nil and tostring(profileId)~="" then return tostring(profileId) end
    end
    return nil
end

function AgriLife.People6Service:getConnectionIdentity(connection, farmId)
    if g_currentMission == nil then return nil, nil, nil end
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then
        return "SERVER", "Serveur", nil
    end

    local player = nil
    if connection ~= nil and g_currentMission.getPlayerByConnection ~= nil then
        local ok, value = pcall(g_currentMission.getPlayerByConnection, g_currentMission, connection)
        if ok then player = value end
    elseif connection == nil then
        player = g_currentMission.player
        if player == nil and g_currentMission.playerSystem ~= nil then
            player = g_currentMission.playerSystem.currentPlayer
        end
    end

    local profileId, name = self:getPlayerIdentity(player, farmId)
    return profileId, name, player
end

function AgriLife.People6Service:isMasterPlayer(player)
    local user = self:getUserForPlayer(player)
    if user ~= nil and user.getIsMasterUser ~= nil then
        local ok, value = pcall(user.getIsMasterUser, user)
        if ok then return value == true end
    end
    return false
end

function AgriLife.People6Service:getCompanyModule()
    local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    return instances ~= nil and instances.company or nil
end

function AgriLife.People6Service:getCompanyOwnerProfileId(farmId)
    local company = self:getCompanyModule()
    local snapshot = company ~= nil and company.getSnapshot ~= nil and company:getSnapshot(farmId) or nil
    local ownerProfileId = clean(snapshot ~= nil and snapshot.ownerProfileId or "", "", 96)
    if ownerProfileId == "" then return nil end
    return ownerProfileId
end

function AgriLife.People6Service:setCompanyOwnerProfileId(farmId, profileId)
    profileId = clean(profileId, "", 96)
    if profileId == "" then return false end
    local company = self:getCompanyModule()
    local snapshot = company ~= nil and company.getSnapshot ~= nil and company:getSnapshot(farmId) or nil
    if company == nil or company.service == nil or company.service.setIdentity == nil or snapshot == nil then return false end
    if tostring(snapshot.ownerProfileId or "") == profileId then return true end
    local result = company.service:setIdentity(farmId, snapshot.companyName, snapshot.legalFormId, profileId)
    return result ~= nil and result.ok == true
end

function AgriLife.People6Service:isFarmOwner(farmId, profileId)
    profileId = clean(profileId, "", 96)
    if profileId == "" then return false end
    local ownerProfileId = self:getCompanyOwnerProfileId(farmId)
    if ownerProfileId ~= nil then return ownerProfileId == profileId end
    local profile = self:getProfile(farmId, profileId)
    return profile ~= nil and profile.role == "owner"
end

function AgriLife.People6Service:resolveFarmOwner(farmId, preferredProfileId, preferredIsOwnerCandidate)
    local state = self:getFarmState(farmId, true)
    if state == nil then return nil end

    local ownerProfileId = self:getCompanyOwnerProfileId(farmId)
    if ownerProfileId == nil then
        local existingOwners = {}
        for profileId, profile in pairs(state.profiles or {}) do
            if profile.role == "owner" then table.insert(existingOwners, tostring(profileId)) end
        end
        table.sort(existingOwners)
        if #existingOwners > 0 then ownerProfileId = existingOwners[1] end

        preferredProfileId = clean(preferredProfileId, "", 96)
        if ownerProfileId == nil and preferredIsOwnerCandidate == true and preferredProfileId ~= "" then ownerProfileId = preferredProfileId end
        if ownerProfileId ~= nil then self:setCompanyOwnerProfileId(farmId, ownerProfileId) end
    end

    if ownerProfileId ~= nil then
        for profileId, profile in pairs(state.profiles or {}) do
            if tostring(profileId) == ownerProfileId then
                profile.role = "owner"
                profile.active = true
            elseif profile.role == "owner" then
                profile.role = "manager"
                self:addAudit(farmId, "SYSTEM", "OWNER_DUPLICATE_REPAIRED", profileId, "owner->manager")
            end
        end
    end
    return ownerProfileId
end

function AgriLife.People6Service:ensureProfile(farmId, profileId, displayName, role)
    local state = self:getFarmState(farmId, true)
    profileId = clean(profileId, "", 96)
    if state == nil or profileId == "" then return nil end
    local profile = state.profiles[profileId]
    if profile == nil then
        role = self.ROLES[role] ~= nil and role or "employee"
        profile = {
            profileId = profileId,
            displayName = clean(displayName, "Joueur", 48),
            role = role,
            active = true,
            connected = false,
            joinedPeriodKey = self:getPeriodKey(),
            lastSeenPeriodKey = self:getPeriodKey(),
            lastSeenDay = self:getDayStamp(),
            lastSeenTime = self:getTimeStamp()
        }
        state.profiles[profileId] = profile
    else
        profile.displayName = clean(displayName, profile.displayName, 48)
    end
    return profile
end

function AgriLife.People6Service:getProfile(farmId, profileId)
    local state = self:getFarmState(farmId, false)
    return state ~= nil and state.profiles[tostring(profileId or "")] or nil
end

function AgriLife.People6Service:getRole(farmId, profileId)
    local profile = self:getProfile(farmId, profileId)
    return profile ~= nil and profile.role or "employee"
end

function AgriLife.People6Service:hasPermission(farmId, profileId, permission)
    permission = tostring(permission or "")
    local allowed = self.PERMISSIONS[permission]
    if allowed == nil then return false end
    if permission == "roles.manage" then return self:isFarmOwner(farmId, profileId) end
    local role = self:getRole(farmId, profileId)
    return allowed[role] == true
end

function AgriLife.People6Service:authorizeConnection(connection, farmId, permission)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return false, "PEOPLE_FARM_INVALID", nil end
    if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return true, nil, "SERVER" end

    local profileId, name, player = self:getConnectionIdentity(connection, farmId)
    local isSinglePlayerServer = connection == nil and self.core ~= nil and self.core.context ~= nil and self.core.context.isServer and g_currentMission ~= nil and g_currentMission.missionDynamicInfo ~= nil and g_currentMission.missionDynamicInfo.isMultiplayer ~= true

    -- Never manufacture the SP_FARM_x placeholder as a real employee/owner just
    -- because FS25 has not exposed the local Player object yet. This was the
    -- source of the duplicate "Joueur" owner + real nickname employee in FIX2.
    if isSinglePlayerServer and player == nil then
        local existingOwner = self:getCompanyOwnerProfileId(farmId)
        if existingOwner ~= nil then
            local existingProfile = self:getProfile(farmId, existingOwner)
            if existingProfile ~= nil then
                profileId = existingOwner
                name = existingProfile.displayName
            else
                return false, "PEOPLE_LOCAL_PLAYER_NOT_READY", nil
            end
        else
            return false, "PEOPLE_LOCAL_PLAYER_NOT_READY", nil
        end
    end

    if profileId == nil then return false, "PEOPLE_IDENTITY_UNAVAILABLE", nil end
    if player ~= nil and tonumber(player.farmId) ~= farmId then return false, "PEOPLE_FARM_MISMATCH", profileId end

    local ownerCandidate = isSinglePlayerServer or self:isMasterPlayer(player)
    local ownerProfileId = self:resolveFarmOwner(farmId, profileId, ownerCandidate)
    local profile = self:ensureProfile(farmId, profileId, name, ownerProfileId == profileId and "owner" or "employee")
    if profile == nil then return false, "PEOPLE_PROFILE_UNAVAILABLE", profileId end
    if ownerProfileId == profileId then profile.role = "owner" elseif profile.role == "owner" then profile.role = "manager" end

    if self:hasPermission(farmId, profileId, permission) then return true, nil, profileId end
    return false, "PEOPLE_PERMISSION_DENIED", profileId
end

function AgriLife.People6Service:authorizeLocal(farmId, permission)
    return self:authorizeConnection(nil, farmId, permission)
end

function AgriLife.People6Service:addAudit(farmId, actorProfileId, action, targetProfileId, details)
    local state = self:getFarmState(farmId, true)
    if state == nil then return end
    local id = string.format("PEOPLE6_%d_%06d", tonumber(farmId) or 0, state.nextAuditId)
    state.nextAuditId = state.nextAuditId + 1
    table.insert(state.audit, {
        id = id,
        periodKey = self:getPeriodKey(),
        day = self:getDayStamp(),
        time = self:getTimeStamp(),
        actorProfileId = clean(actorProfileId, "SYSTEM", 96),
        action = clean(action, "UNKNOWN", 48),
        targetProfileId = clean(targetProfileId, "", 96),
        details = clean(details, "", 160)
    })
    while #state.audit > 128 do table.remove(state.audit, 1) end
end

function AgriLife.People6Service:setRole(farmId, actorProfileId, targetProfileId, newRole)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return AgriLife.Result.fail("PEOPLE_SERVER_REQUIRED", "Role changes require server") end
    if not self:isFarmOwner(farmId, actorProfileId) then return AgriLife.Result.fail("PEOPLE_OWNER_ONLY_ROLE_MANAGEMENT", "Only the farm owner can change player roles") end
    if not self:hasPermission(farmId, actorProfileId, "roles.manage") then return AgriLife.Result.fail("PEOPLE_PERMISSION_DENIED", "Insufficient permissions") end
    if self.ROLES[newRole] == nil then return AgriLife.Result.fail("PEOPLE_ROLE_INVALID", "Unknown role") end
    local target = self:getProfile(farmId, targetProfileId)
    if target == nil then return AgriLife.Result.fail("PEOPLE_PROFILE_NOT_FOUND", "Profile not found") end
    if self:isFarmOwner(farmId, targetProfileId) and newRole ~= "owner" then return AgriLife.Result.fail("PEOPLE_OWNER_PROTECTED", "Farm owner role cannot be removed here") end
    if newRole == "owner" and not self:isFarmOwner(farmId, targetProfileId) then return AgriLife.Result.fail("PEOPLE_OWNER_TRANSFER_REQUIRED", "Owner transfer requires dedicated workflow") end
    local oldRole = target.role
    target.role = newRole
    local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local payroll = instances ~= nil and instances.payroll or nil
    if payroll ~= nil and payroll.service ~= nil and payroll.service.setEmployeeRole ~= nil then
        payroll.service:setEmployeeRole(farmId, targetProfileId, newRole)
    end
    self:addAudit(farmId, actorProfileId, "ROLE_CHANGED", targetProfileId, tostring(oldRole) .. "->" .. tostring(newRole))
    return AgriLife.Result.ok("PEOPLE_ROLE_CHANGED", "Profile role changed", { profileId = targetProfileId, role = newRole })
end

function AgriLife.People6Service:canAdministerProfile(farmId, actorProfileId, targetProfileId)
    if self:isFarmOwner(farmId, actorProfileId) then return true end
    if tostring(actorProfileId or "") == tostring(targetProfileId or "") then return false end
    local actor = self:getProfile(farmId, actorProfileId)
    local target = self:getProfile(farmId, targetProfileId)
    if actor == nil or target == nil or actor.role ~= "manager" then return false end
    return target.role == "employee" or target.role == "apprentice"
end

function AgriLife.People6Service:setActive(farmId, actorProfileId, targetProfileId, active)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return AgriLife.Result.fail("PEOPLE_SERVER_REQUIRED", "Employment changes require server") end
    if not self:hasPermission(farmId, actorProfileId, "profiles.manage") then return AgriLife.Result.fail("PEOPLE_PERMISSION_DENIED", "Insufficient permissions") end
    local target = self:getProfile(farmId, targetProfileId)
    if target == nil then return AgriLife.Result.fail("PEOPLE_PROFILE_NOT_FOUND", "Profile not found") end
    if self:isFarmOwner(farmId, targetProfileId) and active ~= true then return AgriLife.Result.fail("PEOPLE_OWNER_PROTECTED", "Farm owner payroll cannot be suspended") end

    if not self:canAdministerProfile(farmId, actorProfileId, targetProfileId) then
        return AgriLife.Result.fail("PEOPLE_OWNER_APPROVAL_REQUIRED", "Owner approval is required for this profile")
    end

    active = active == true
    if target.active == active then return AgriLife.Result.ok(active and "PEOPLE_PROFILE_ALREADY_ACTIVE" or "PEOPLE_PROFILE_ALREADY_SUSPENDED", "Employment status unchanged", { profileId = targetProfileId, active = active }) end
    target.active = active

    local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local payroll = instances ~= nil and instances.payroll or nil
    if payroll ~= nil and payroll.service ~= nil and payroll.service.setEmployeeActive ~= nil then payroll.service:setEmployeeActive(farmId, targetProfileId, active) end
    self:addAudit(farmId, actorProfileId, active and "PROFILE_ACTIVATED" or "PROFILE_PAYROLL_SUSPENDED", targetProfileId, target.displayName)
    return AgriLife.Result.ok(active and "PEOPLE_PROFILE_ACTIVATED" or "PEOPLE_PROFILE_SUSPENDED", "Employment status updated", { profileId = targetProfileId, active = active })
end

function AgriLife.People6Service:isProfileConnected(farmId, profileId)
    local profile = self:getProfile(farmId, profileId)
    return profile ~= nil and profile.connected == true
end

function AgriLife.People6Service:deleteProfile(farmId, actorProfileId, targetProfileId)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return AgriLife.Result.fail("PEOPLE_SERVER_REQUIRED", "Profile deletion requires server") end
    if not self:hasPermission(farmId, actorProfileId, "profiles.manage") then return AgriLife.Result.fail("PEOPLE_PERMISSION_DENIED", "Insufficient permissions") end
    local state = self:getFarmState(farmId, false)
    local target = state ~= nil and state.profiles[tostring(targetProfileId or "")] or nil
    if target == nil then return AgriLife.Result.fail("PEOPLE_PROFILE_NOT_FOUND", "Profile not found") end
    if target.connected == true then return AgriLife.Result.fail("PEOPLE_PROFILE_CONNECTED", "Connected profile cannot be deleted") end
    if self:isFarmOwner(farmId, targetProfileId) then return AgriLife.Result.fail("PEOPLE_OWNER_PROTECTED", "Farm owner profile cannot be deleted") end
    if not self:canAdministerProfile(farmId, actorProfileId, targetProfileId) then return AgriLife.Result.fail("PEOPLE_OWNER_APPROVAL_REQUIRED", "Owner approval is required for this profile") end

    local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
    local payroll = instances ~= nil and instances.payroll or nil
    if payroll ~= nil and payroll.service ~= nil and payroll.service.canDeleteProfile ~= nil then
        local payrollCheck = payroll.service:canDeleteProfile(farmId, targetProfileId)
        if payrollCheck ~= nil and payrollCheck.ok == false then return AgriLife.Result.fail(payrollCheck.code or "PEOPLE_PROFILE_FINANCIALS_PENDING", payrollCheck.message or "Payroll account must be settled before deletion", payrollCheck.data) end
    end

    self:addAudit(farmId, actorProfileId, "PROFILE_DELETED", targetProfileId, target.displayName)
    state.profiles[targetProfileId] = nil

    if instances ~= nil then
        for _, moduleId in ipairs({ "payroll", "career", "exams" }) do
            local module = instances[moduleId]
            if module ~= nil and module.deleteProfile ~= nil then
                local ok, result = pcall(module.deleteProfile, module, farmId, targetProfileId)
                if not ok or (result ~= nil and result.ok == false) then
                    self:addAudit(farmId, "SYSTEM", "PROFILE_DELETE_CASCADE_WARNING", targetProfileId, tostring(result ~= nil and result.code or result))
                end
            end
        end
    end
    return AgriLife.Result.ok("PEOPLE_PROFILE_DELETED", "AgriLife profile deleted", { profileId = targetProfileId })
end

function AgriLife.People6Service:syncConnectedPlayers()
    if self.core == nil or self.core.context == nil or not self.core.context.isServer or g_currentMission == nil then return end
    for _, state in pairs(self.farms) do for _, profile in pairs(state.profiles) do profile.connected = false end end

    local players = g_currentMission.playerSystem ~= nil and g_currentMission.playerSystem.players or {}
    local byFarm = {}
    for _, player in pairs(players or {}) do
        local farmId = tonumber(player.farmId) or 0
        if farmId > 0 then
            local profileId, name = self:getPlayerIdentity(player, farmId)
            byFarm[farmId] = byFarm[farmId] or {}
            table.insert(byFarm[farmId], { player = player, profileId = profileId, displayName = name, master = self:isMasterPlayer(player) })
        end
    end

    for farmId, contexts in pairs(byFarm) do
        table.sort(contexts, function(a, b) return tostring(a.profileId or "") < tostring(b.profileId or "") end)
        local ownerProfileId = self:getCompanyOwnerProfileId(farmId)
        if ownerProfileId == nil then
            local state = self:getFarmState(farmId, true)
            local existingOwners = {}
            for profileId, profile in pairs(state.profiles or {}) do if profile.role == "owner" then table.insert(existingOwners, tostring(profileId)) end end
            table.sort(existingOwners)
            if #existingOwners > 0 then ownerProfileId = existingOwners[1] end
            if ownerProfileId == nil then
                for _, ctx in ipairs(contexts) do if ctx.master == true then ownerProfileId = ctx.profileId; break end end
            end
            if ownerProfileId == nil and g_currentMission.missionDynamicInfo ~= nil and g_currentMission.missionDynamicInfo.isMultiplayer ~= true and #contexts > 0 then ownerProfileId = contexts[1].profileId end
            if ownerProfileId ~= nil then self:setCompanyOwnerProfileId(farmId, ownerProfileId) end
        end

        self:resolveFarmOwner(farmId, ownerProfileId, ownerProfileId ~= nil)
        for _, ctx in ipairs(contexts) do
            local profile = self:ensureProfile(farmId, ctx.profileId, ctx.displayName, ctx.profileId == ownerProfileId and "owner" or "employee")
            if profile ~= nil then
                if ctx.profileId == ownerProfileId then profile.role = "owner" elseif profile.role == "owner" then profile.role = "manager" end
                profile.connected = true
                profile.lastSeenPeriodKey = self:getPeriodKey()
                profile.lastSeenDay = self:getDayStamp()
                profile.lastSeenTime = self:getTimeStamp()
            end
        end
    end

    for farmId, _ in pairs(self.farms) do self:resolveFarmOwner(farmId, nil, false) end
end

function AgriLife.People6Service:getSnapshot(farmId, viewerProfileId)
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer then self:resolveFarmOwner(farmId, nil, false) end
    local state = self:getFarmState(farmId, true)
    if state == nil then return nil end
    local profiles = {}
    for _, profile in pairs(state.profiles) do
        table.insert(profiles, {
            profileId = profile.profileId,
            displayName = profile.displayName,
            role = profile.role,
            roleLabelKey = (self.ROLES[profile.role] or self.ROLES.employee).labelKey,
            active = profile.active == true,
            connected = profile.connected == true,
            joinedPeriodKey = profile.joinedPeriodKey,
            lastSeenPeriodKey = profile.lastSeenPeriodKey,
            lastSeenDay = profile.lastSeenDay,
            lastSeenTime = profile.lastSeenTime,
            canDelete = viewerProfileId ~= nil and self:hasPermission(farmId, viewerProfileId, "profiles.manage") and self:canAdministerProfile(farmId, viewerProfileId, profile.profileId) and not self:isFarmOwner(farmId, profile.profileId) and profile.connected ~= true
        })
    end
    table.sort(profiles, function(a, b)
        if a.connected ~= b.connected then return a.connected == true end
        local ar = (self.ROLES[a.role] or self.ROLES.employee).rank
        local br = (self.ROLES[b.role] or self.ROLES.employee).rank
        if ar ~= br then return ar > br end
        return tostring(a.displayName) < tostring(b.displayName)
    end)
    return {
        farmId = tonumber(farmId) or 0,
        viewerProfileId = viewerProfileId,
        canManage = viewerProfileId ~= nil and self:hasPermission(farmId, viewerProfileId, "profiles.manage") or false,
        profiles = profiles,
        profileCount = #profiles,
        auditCount = #state.audit
    }
end

function AgriLife.People6Service:applyClientSnapshot(farmId, viewerProfileId, profiles)
    farmId=tonumber(farmId) or 0
    if farmId<=0 then return AgriLife.Result.fail("PEOPLE_FARM_INVALID","Invalid farm") end
    local state=self:createDefaultFarmState()
    state.viewerProfileId=tostring(viewerProfileId or "")
    for _,p in ipairs(profiles or {}) do
        local id=clean(p.profileId,"",96)
        if id~="" then
            local role=self.ROLES[p.role]~=nil and p.role or "employee"
            state.profiles[id]={profileId=id,displayName=clean(p.displayName,"Joueur",48),role=role,active=p.active==true,connected=p.connected==true,joinedPeriodKey=safeInt(p.joinedPeriodKey,0),lastSeenPeriodKey=safeInt(p.lastSeenPeriodKey,0),lastSeenDay=safeInt(p.lastSeenDay,0),lastSeenTime=safeInt(p.lastSeenTime,0)}
        end
    end
    self.farms[farmId]=state
    return AgriLife.Result.ok("PEOPLE_CLIENT_SNAPSHOT_APPLIED","People snapshot applied",{profileCount=#(profiles or {})})
end

function AgriLife.People6Service:update(dt)
    if self.core == nil or self.core.context == nil or not self.core.context.isServer then return end
    self.syncAccumulator = self.syncAccumulator + math.max(0, safeInt(dt, 0))
    if self.syncAccumulator >= 3000 then self.syncAccumulator = 0; self:syncConnectedPlayers() end
end

function AgriLife.People6Service:saveFarm(xmlFile, moduleKey, farmId)
    local state = self:getFarmState(farmId, true)
    if state == nil then return AgriLife.Result.fail("PEOPLE_FARM_INVALID", "Invalid farm") end
    xmlFile:setInt(moduleKey .. ".state#nextAuditId", math.max(1, safeInt(state.nextAuditId, 1)))
    local i = 0
    for _, p in pairs(state.profiles) do
        local k = string.format("%s.profiles.profile(%d)", moduleKey, i)
        xmlFile:setString(k .. "#profileId", p.profileId or "")
        xmlFile:setString(k .. "#displayName", p.displayName or "Joueur")
        xmlFile:setString(k .. "#role", p.role or "employee")
        xmlFile:setBool(k .. "#active", p.active == true)
        xmlFile:setInt(k .. "#joinedPeriodKey", safeInt(p.joinedPeriodKey, 0))
        xmlFile:setInt(k .. "#lastSeenPeriodKey", safeInt(p.lastSeenPeriodKey, 0))
        xmlFile:setInt(k .. "#lastSeenDay", safeInt(p.lastSeenDay, 0))
        xmlFile:setInt(k .. "#lastSeenTime", safeInt(p.lastSeenTime, 0))
        i = i + 1
    end
    local a = 0
    for _, entry in ipairs(state.audit) do
        local k = string.format("%s.audit.entry(%d)", moduleKey, a)
        xmlFile:setString(k .. "#id", entry.id or "")
        xmlFile:setInt(k .. "#periodKey", safeInt(entry.periodKey, 0))
        xmlFile:setInt(k .. "#day", safeInt(entry.day, 0))
        xmlFile:setInt(k .. "#time", safeInt(entry.time, 0))
        xmlFile:setString(k .. "#actorProfileId", entry.actorProfileId or "")
        xmlFile:setString(k .. "#action", entry.action or "")
        xmlFile:setString(k .. "#targetProfileId", entry.targetProfileId or "")
        xmlFile:setString(k .. "#details", entry.details or "")
        a = a + 1
    end
    return AgriLife.Result.ok("PEOPLE_FARM_SAVED", "People directory saved", { profileCount = i, auditCount = a })
end

function AgriLife.People6Service:loadFarm(xmlFile, moduleKey, farmId)
    farmId = tonumber(farmId) or 0
    if farmId <= 0 then return AgriLife.Result.ok("PEOPLE_CLIENT_LOAD_SKIPPED", "No people state on client runtime") end
    local state = self:createDefaultFarmState()
    if xmlFile ~= nil and moduleKey ~= nil then
        state.nextAuditId = math.max(1, xmlFile:getInt(moduleKey .. ".state#nextAuditId", 1))
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(moduleKey .. ".profiles.profile", function(_, k)
                local profileId = clean(xmlFile:getString(k .. "#profileId", ""), "", 96)
                if profileId ~= "" then
                    local role = xmlFile:getString(k .. "#role", "employee")
                    if self.ROLES[role] == nil then role = "employee" end
                    state.profiles[profileId] = {
                        profileId = profileId,
                        displayName = clean(xmlFile:getString(k .. "#displayName", "Joueur"), "Joueur", 48),
                        role = role,
                        active = xmlFile:getBool(k .. "#active", true),
                        connected = false,
                        joinedPeriodKey = xmlFile:getInt(k .. "#joinedPeriodKey", 0),
                        lastSeenPeriodKey = xmlFile:getInt(k .. "#lastSeenPeriodKey", 0),
                        lastSeenDay = xmlFile:getInt(k .. "#lastSeenDay", 0),
                        lastSeenTime = xmlFile:getInt(k .. "#lastSeenTime", 0)
                    }
                end
            end)
            xmlFile:iterate(moduleKey .. ".audit.entry", function(_, k)
                table.insert(state.audit, {
                    id = xmlFile:getString(k .. "#id", ""), periodKey = xmlFile:getInt(k .. "#periodKey", 0), day = xmlFile:getInt(k .. "#day", 0), time = xmlFile:getInt(k .. "#time", 0),
                    actorProfileId = xmlFile:getString(k .. "#actorProfileId", ""), action = xmlFile:getString(k .. "#action", ""), targetProfileId = xmlFile:getString(k .. "#targetProfileId", ""), details = xmlFile:getString(k .. "#details", "")
                })
            end)
        end
    end
    self.farms[farmId] = state
    if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer then self:resolveFarmOwner(farmId, nil, false) end
    return AgriLife.Result.ok("PEOPLE_FARM_LOADED", "People directory loaded")
end

function AgriLife.People6Service:delete()
    self.farms = {}
    self.snapshotListeners = {}
    self.core = nil
end
