-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.Company6Service ~= nil then
    local Company = AgriLife.Company6Service
    Company.STRUCTURE_VERSION = "0.9.3.27"
    Company.SCHEMA_VERSION = math.max(2, tonumber(Company.SCHEMA_VERSION) or 1)

    -- Legal form, business activity and professional network are deliberately
    -- separate concepts. CUMA is a network/machinery cooperative, not the
    -- legal identity of the farm in AgriLife.
    Company.LEGAL_FORMS = {
        {id="EI",   labelKey="agrilife_company6_form_EI",   minMembers=1, maxMembers=1,   setupCost=0,    transformCost=450,  monthlyAdminCost=35,  separation=0.35, bankConfidence=0, maxExtraActivities=1},
        {id="EARL", labelKey="agrilife_company6_form_EARL", minMembers=1, maxMembers=10,  setupCost=2200, transformCost=1450, monthlyAdminCost=120, separation=0.85, bankConfidence=2, maxExtraActivities=2},
        {id="GAEC", labelKey="agrilife_company6_form_GAEC", minMembers=2, maxMembers=10,  setupCost=3200, transformCost=2100, monthlyAdminCost=180, separation=0.90, bankConfidence=3, maxExtraActivities=2},
        {id="SCEA", labelKey="agrilife_company6_form_SCEA", minMembers=2, maxMembers=100, setupCost=2800, transformCost=1850, monthlyAdminCost=160, separation=0.75, bankConfidence=1, maxExtraActivities=3},
        {id="EURL", labelKey="agrilife_company6_form_EURL", minMembers=1, maxMembers=1,   setupCost=2400, transformCost=1650, monthlyAdminCost=155, separation=0.90, bankConfidence=2, maxExtraActivities=3},
        {id="SARL", labelKey="agrilife_company6_form_SARL", minMembers=1, maxMembers=100, setupCost=3100, transformCost=2200, monthlyAdminCost=210, separation=0.90, bankConfidence=3, maxExtraActivities=4},
        {id="SASU", labelKey="agrilife_company6_form_SASU", minMembers=1, maxMembers=1,   setupCost=3400, transformCost=2350, monthlyAdminCost=230, separation=0.95, bankConfidence=3, maxExtraActivities=4},
        {id="SAS",  labelKey="agrilife_company6_form_SAS",  minMembers=2, maxMembers=999, setupCost=4400, transformCost=3050, monthlyAdminCost=300, separation=0.95, bankConfidence=4, maxExtraActivities=5}
    }

    Company.ACTIVITIES = {
        FARMING = {id="FARMING", labelKey="agrilife_company_activity_farming", setupCost=0, monthlyCost=0, permanent=true, contractKinds={production_supply=true,direct_sale=true}},
        ETA = {id="ETA", labelKey="agrilife_company_activity_eta", setupCost=1800, monthlyCost=120, gameplayReady=true, contractKinds={field_work=true,harvest_help=true,transport=true,service=true}, serviceRevenueFactor=1.04},
        PROCESSING = {id="PROCESSING", labelKey="agrilife_company_activity_processing", setupCost=2500, monthlyCost=150, gameplayReady=false, contractKinds={production_supply=true,direct_sale=true}, productionMarginFactor=1.03},
        DIRECT_SALES = {id="DIRECT_SALES", labelKey="agrilife_company_activity_direct_sales", setupCost=1250, monthlyCost=85, gameplayReady=false, contractKinds={direct_sale=true}, directSaleFactor=1.04},
        BIOGAS = {id="BIOGAS", labelKey="agrilife_company_activity_biogas", setupCost=4000, monthlyCost=240, gameplayReady=false, contractKinds={production_supply=true}, energyFactor=1.03},
        FORESTRY = {id="FORESTRY", labelKey="agrilife_company_activity_forestry", setupCost=1100, monthlyCost=70, gameplayReady=false, contractKinds={transport=true,service=true}, forestryFactor=1.03}
    }

    Company.NETWORKS = {
        CUMA = {id="CUMA", labelKey="agrilife_company_network_cuma", entryCost=2500, monthlyCost=175, gameplayReady=false, machineryAccess=true, rentalFactor=0.88},
        COOPERATIVE = {id="COOPERATIVE", labelKey="agrilife_company_network_cooperative", entryCost=900, monthlyCost=55, gameplayReady=true, commercialOfferFactor=1.03},
        EMPLOYER_GROUP = {id="EMPLOYER_GROUP", labelKey="agrilife_company_network_employer_group", entryCost=700, monthlyCost=80, gameplayReady=false, seasonalAccess=true}
    }

    local function num(value, default)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
        return value
    end
    local function round(value) return math.floor(num(value, 0) * 100 + 0.5) / 100 end
    local function sortedKeys(values)
        local out = {}
        for key, enabled in pairs(values or {}) do if enabled == true then table.insert(out, tostring(key)) end end
        table.sort(out)
        return out
    end

    local function ensureState(self, state)
        if state == nil then return nil end
        state.activities = type(state.activities) == "table" and state.activities or {FARMING=true}
        state.activities.FARMING = true
        state.memberships = type(state.memberships) == "table" and state.memberships or {}
        state.structureHistory = type(state.structureHistory) == "table" and state.structureHistory or {}
        state.lastStructureFeePeriodKey = math.max(0, math.floor(num(state.lastStructureFeePeriodKey, 0)))
        state.structureActivated = state.structureActivated == true
        -- Migration from the old prototype where CUMA was incorrectly listed
        -- as a legal form. Preserve the player's intent as a CUMA membership.
        if tostring(state.legalFormId or "") == "CUMA" then
            state.legalFormId = "EI"
            state.memberships.CUMA = true
            table.insert(state.structureHistory, {periodKey=self:getPeriodKey(), kind="MIGRATE_CUMA", value="CUMA"})
        end
        return state
    end

    local baseCreateDefaultState = Company.createDefaultState
    function Company:createDefaultState(farmId)
        return ensureState(self, baseCreateDefaultState(self, farmId))
    end

    local baseGetFarmState = Company.getFarmState
    function Company:getFarmState(farmId, create)
        return ensureState(self, baseGetFarmState(self, farmId, create))
    end

    function Company:getDifficultyId(farmId)
        local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
        local snapshot = economy ~= nil and economy.getSnapshot ~= nil and economy:getSnapshot(farmId) or nil
        return tostring(snapshot ~= nil and snapshot.modeId or "normal")
    end

    function Company:getStructureCostFactor(farmId)
        local mode = self:getDifficultyId(farmId)
        if mode == "facile" then return 0.65 end
        if mode == "difficile" then return 1.20 end
        return 1.0
    end

    function Company:getCash(farmId)
        local farm = self:getFarm(farmId)
        return math.max(0, num(farm ~= nil and farm.money, 0))
    end

    function Company:changeCompanyMoney(farmId, amount, kind, note)
        amount = round(amount)
        if math.abs(amount) < 0.001 then return true end
        local callback = nil
        if g_currentMission ~= nil and g_currentMission.addMoney ~= nil then
            callback = function() return g_currentMission:addMoney(amount, farmId, MoneyType ~= nil and MoneyType.OTHER or nil, true, true) end
        else
            local farm = self:getFarm(farmId)
            if farm ~= nil and farm.changeBalance ~= nil then callback = function() return farm:changeBalance(amount, MoneyType ~= nil and MoneyType.OTHER or nil) end end
        end
        if callback == nil then return false end
        local ok, result
        if AgriLife.Integrity6Service ~= nil and AgriLife.Integrity6Service.executeTrusted ~= nil then
            ok, result = AgriLife.Integrity6Service.executeTrusted(self.core, farmId, "COMPANY", callback)
        else
            ok, result = pcall(callback)
        end
        if ok and result ~= false then
            local economy = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.economy or nil
            if economy ~= nil and economy.service ~= nil and economy.service.record ~= nil then
                economy.service:record(farmId, tostring(kind or "COMPANY_STRUCTURE"), amount, "COMPANY", nil, tostring(note or ""))
            end
            return true
        end
        return false
    end

    function Company:getLegalFormProfile(formId)
        return self:getLegalForm(formId)
    end

    function Company:getActivity(activityId)
        return self.ACTIVITIES[string.upper(tostring(activityId or ""))]
    end

    function Company:getNetwork(networkId)
        return self.NETWORKS[string.upper(tostring(networkId or ""))]
    end

    function Company:getActiveExtraActivityCount(state)
        local count = 0
        for id, enabled in pairs(state ~= nil and state.activities or {}) do if enabled == true and id ~= "FARMING" then count = count + 1 end end
        return count
    end

    function Company:previewLegalFormChange(farmId, legalFormId)
        local state = self:getFarmState(farmId, true)
        local form = self:getLegalForm(legalFormId)
        local validation = self:validateLegalForm(farmId, form.id)
        if validation == nil or validation.ok ~= true then return validation end
        local current = self:getLegalForm(state.legalFormId)
        if current.id == form.id then return AgriLife.Result.ok("COMPANY_FORM_ALREADY_ACTIVE", "Legal form already active", {form=form, cost=0, current=current}) end
        if self:getActiveExtraActivityCount(state) > num(form.maxExtraActivities, 0) then
            return AgriLife.Result.fail("COMPANY_FORM_ACTIVITY_LIMIT", "Too many activities for this legal form", {form=form, activeExtraActivities=self:getActiveExtraActivityCount(state), maxExtraActivities=form.maxExtraActivities})
        end
        local cost = round(num(form.transformCost, 0) * self:getStructureCostFactor(farmId))
        return AgriLife.Result.ok("COMPANY_FORM_PREVIEW", "Legal form change preview", {form=form, current=current, cost=cost, cash=self:getCash(farmId), memberCount=validation.details.memberCount})
    end

    function Company:previewActivityChange(farmId, activityId, enabled)
        local state = self:getFarmState(farmId, true)
        local activity = self:getActivity(activityId)
        if activity == nil then return AgriLife.Result.fail("COMPANY_ACTIVITY_UNKNOWN", "Unknown business activity") end
        if activity.gameplayReady ~= true and activity.id ~= "FARMING" then return AgriLife.Result.fail("COMPANY_ACTIVITY_NOT_READY", "This business activity is not activated yet") end
        enabled = enabled == true
        local current = state.activities[activity.id] == true
        if activity.permanent == true and not enabled then return AgriLife.Result.fail("COMPANY_ACTIVITY_REQUIRED", "Primary farming activity cannot be disabled") end
        if current == enabled then return AgriLife.Result.ok("COMPANY_ACTIVITY_UNCHANGED", "Activity already in requested state", {activity=activity, enabled=enabled, cost=0}) end
        local form = self:getLegalForm(state.legalFormId)
        if enabled and activity.id ~= "FARMING" and self:getActiveExtraActivityCount(state) >= num(form.maxExtraActivities, 0) then
            return AgriLife.Result.fail("COMPANY_ACTIVITY_LIMIT", "Legal form activity limit reached", {activity=activity, form=form, maxExtraActivities=form.maxExtraActivities})
        end
        local baseCost = enabled and num(activity.setupCost, 0) or num(activity.setupCost, 0) * 0.15
        local cost = round(baseCost * self:getStructureCostFactor(farmId))
        return AgriLife.Result.ok("COMPANY_ACTIVITY_PREVIEW", "Business activity preview", {activity=activity, enabled=enabled, cost=cost, cash=self:getCash(farmId), form=form})
    end

    function Company:previewMembershipChange(farmId, networkId, enabled)
        local state = self:getFarmState(farmId, true)
        local network = self:getNetwork(networkId)
        if network == nil then return AgriLife.Result.fail("COMPANY_NETWORK_UNKNOWN", "Unknown professional network") end
        if network.gameplayReady ~= true then return AgriLife.Result.fail("COMPANY_NETWORK_NOT_READY", "This professional network is not activated yet") end
        enabled = enabled == true
        local current = state.memberships[network.id] == true
        if current == enabled then return AgriLife.Result.ok("COMPANY_NETWORK_UNCHANGED", "Membership already in requested state", {network=network, enabled=enabled, cost=0}) end
        local cost = enabled and round(num(network.entryCost, 0) * self:getStructureCostFactor(farmId)) or 0
        return AgriLife.Result.ok("COMPANY_NETWORK_PREVIEW", "Professional network preview", {network=network, enabled=enabled, cost=cost, cash=self:getCash(farmId)})
    end

    local baseSetIdentity = Company.setIdentity
    function Company:setIdentity(farmId, companyName, legalFormId, ownerProfileId)
        local state = self:getFarmState(farmId, true)
        local target = self:getLegalForm(legalFormId)
        local changed = tostring(state.legalFormId or "EI") ~= tostring(target.id)
        local preview = changed and self:previewLegalFormChange(farmId, target.id) or nil
        if changed and (preview == nil or preview.ok ~= true) then return preview end
        local fee = changed and num(preview.details ~= nil and preview.details.cost, 0) or 0
        if fee > self:getCash(farmId) + 0.01 then return AgriLife.Result.fail("COMPANY_STRUCTURE_FUNDS_LOW", "Insufficient funds for legal transformation", {cost=fee, cash=self:getCash(farmId)}) end
        if fee > 0 and not self:changeCompanyMoney(farmId, -fee, "COMPANY_LEGAL_CHANGE", tostring(state.legalFormId).."->"..tostring(target.id)) then
            return AgriLife.Result.fail("COMPANY_STRUCTURE_DEBIT_FAILED", "Legal transformation fee could not be charged", {cost=fee})
        end
        local result = baseSetIdentity(self, farmId, companyName, target.id, ownerProfileId)
        if result == nil or result.ok ~= true then
            if fee > 0 then self:changeCompanyMoney(farmId, fee, "COMPANY_LEGAL_CHANGE_ROLLBACK", tostring(target.id)) end
            return result
        end
        if changed then
            state.structureActivated = true
            table.insert(state.structureHistory, {periodKey=self:getPeriodKey(), kind="LEGAL_FORM", value=target.id, amount=fee})
            result.details = result.details or {}; result.details.cost = fee
        end
        return result
    end

    function Company:setActivity(farmId, activityId, enabled, actorProfileId)
        if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer ~= true then return AgriLife.Result.fail("COMPANY_SERVER_REQUIRED", "Server authority required") end
        local preview = self:previewActivityChange(farmId, activityId, enabled)
        if preview == nil or preview.ok ~= true then return preview end
        local details = preview.details or {}; local cost = num(details.cost, 0)
        if cost > self:getCash(farmId) + 0.01 then return AgriLife.Result.fail("COMPANY_STRUCTURE_FUNDS_LOW", "Insufficient funds for activity change", {cost=cost, cash=self:getCash(farmId)}) end
        if cost > 0 and not self:changeCompanyMoney(farmId, -cost, "COMPANY_ACTIVITY_CHANGE", tostring(activityId)) then return AgriLife.Result.fail("COMPANY_STRUCTURE_DEBIT_FAILED", "Activity fee could not be charged", {cost=cost}) end
        local state = self:getFarmState(farmId, true); local activity = details.activity
        state.activities[activity.id] = enabled == true
        state.structureActivated = true
        table.insert(state.structureHistory, {periodKey=self:getPeriodKey(), kind="ACTIVITY", value=activity.id, enabled=enabled==true, amount=cost, actorProfileId=tostring(actorProfileId or "")})
        return AgriLife.Result.ok("COMPANY_ACTIVITY_UPDATED", "Business activity updated", {activityId=activity.id, enabled=enabled==true, cost=cost})
    end

    function Company:setMembership(farmId, networkId, enabled, actorProfileId)
        if self.core ~= nil and self.core.context ~= nil and self.core.context.isServer ~= true then return AgriLife.Result.fail("COMPANY_SERVER_REQUIRED", "Server authority required") end
        local preview = self:previewMembershipChange(farmId, networkId, enabled)
        if preview == nil or preview.ok ~= true then return preview end
        local details = preview.details or {}; local cost = num(details.cost, 0)
        if cost > self:getCash(farmId) + 0.01 then return AgriLife.Result.fail("COMPANY_STRUCTURE_FUNDS_LOW", "Insufficient funds for membership", {cost=cost, cash=self:getCash(farmId)}) end
        if cost > 0 and not self:changeCompanyMoney(farmId, -cost, "COMPANY_NETWORK_JOIN", tostring(networkId)) then return AgriLife.Result.fail("COMPANY_STRUCTURE_DEBIT_FAILED", "Membership fee could not be charged", {cost=cost}) end
        local state = self:getFarmState(farmId, true); local network = details.network
        state.memberships[network.id] = enabled == true
        state.structureActivated = true
        table.insert(state.structureHistory, {periodKey=self:getPeriodKey(), kind="NETWORK", value=network.id, enabled=enabled==true, amount=cost, actorProfileId=tostring(actorProfileId or "")})
        return AgriLife.Result.ok("COMPANY_NETWORK_UPDATED", "Professional network updated", {networkId=network.id, enabled=enabled==true, cost=cost})
    end

    function Company:getMonthlyStructureCost(farmId)
        local state = self:getFarmState(farmId, true)
        if state.structureActivated ~= true then return 0 end
        local form = self:getLegalForm(state.legalFormId)
        local amount = num(form.monthlyAdminCost, 0)
        for id, enabled in pairs(state.activities or {}) do local activity=self:getActivity(id); if enabled==true and activity~=nil then amount=amount+num(activity.monthlyCost,0) end end
        for id, enabled in pairs(state.memberships or {}) do local network=self:getNetwork(id); if enabled==true and network~=nil then amount=amount+num(network.monthlyCost,0) end end
        return round(amount * self:getStructureCostFactor(farmId))
    end

    function Company:processStructurePeriod(farmId, periodKey)
        local state = self:getFarmState(farmId, false)
        if state == nil then return end
        periodKey = math.max(1, math.floor(num(periodKey, self:getPeriodKey())))
        if state.lastStructureFeePeriodKey >= periodKey then return end
        state.lastStructureFeePeriodKey = periodKey
        local amount = self:getMonthlyStructureCost(farmId)
        if amount <= 0 then return end
        local paid = math.min(amount, self:getCash(farmId))
        if paid > 0 then self:changeCompanyMoney(farmId, -paid, "COMPANY_STRUCTURE_MONTHLY", tostring(periodKey)) end
        local arrears = math.max(0, amount - paid)
        state.structureFeeArrears = round(math.max(0, num(state.structureFeeArrears, 0)) + arrears)
        table.insert(state.structureHistory, {periodKey=periodKey, kind="MONTHLY_STRUCTURE", value="", amount=paid, arrears=arrears})
    end

    function Company:onStructurePeriodChanged()
        if self.core == nil or self.core.context == nil or self.core.context.isServer ~= true then return end
        local key = self:getPeriodKey()
        for _, farmId in ipairs(self.core.context:getFarmIds() or {}) do self:processStructurePeriod(farmId, key) end
    end

    local baseSnapshot = Company.getSnapshot
    function Company:getSnapshot(farmId)
        local snapshot = baseSnapshot(self, farmId)
        if snapshot == nil then return nil end
        local state = self:getFarmState(farmId, true)
        local form = self:getLegalForm(state.legalFormId)
        snapshot.structureActivated = state.structureActivated == true
        snapshot.activities = sortedKeys(state.activities)
        snapshot.memberships = sortedKeys(state.memberships)
        snapshot.monthlyStructureCost = self:getMonthlyStructureCost(farmId)
        snapshot.structureFeeArrears = round(num(state.structureFeeArrears, 0))
        snapshot.personalSeparation = num(form.separation, 0)
        snapshot.bankConfidenceBonus = num(form.bankConfidence, 0)
        snapshot.maxExtraActivities = num(form.maxExtraActivities, 0)
        snapshot.cumaMember = state.memberships.CUMA == true
        snapshot.cooperativeMember = state.memberships.COOPERATIVE == true
        snapshot.employerGroupMember = state.memberships.EMPLOYER_GROUP == true
        snapshot.etaActive = state.activities.ETA == true
        return snapshot
    end

    local baseSave = Company.saveFarm
    function Company:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSave(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false or xmlFile == nil or moduleKey == nil then return result end
        local state = self:getFarmState(farmId, true)
        xmlFile:setBool(moduleKey..".structure#activated", state.structureActivated==true)
        xmlFile:setInt(moduleKey..".structure#lastFeePeriodKey", math.floor(num(state.lastStructureFeePeriodKey,0)))
        xmlFile:setFloat(moduleKey..".structure#feeArrears", num(state.structureFeeArrears,0))
        local index=0; for _,id in ipairs(sortedKeys(state.activities)) do local key=string.format("%s.structure.activities.item(%d)",moduleKey,index);xmlFile:setString(key.."#id",id);index=index+1 end
        index=0; for _,id in ipairs(sortedKeys(state.memberships)) do local key=string.format("%s.structure.memberships.item(%d)",moduleKey,index);xmlFile:setString(key.."#id",id);index=index+1 end
        index=0; for _,entry in ipairs(state.structureHistory or {}) do if index>=80 then break end;local key=string.format("%s.structure.history.item(%d)",moduleKey,index);xmlFile:setInt(key.."#periodKey",math.floor(num(entry.periodKey,0)));xmlFile:setString(key.."#kind",tostring(entry.kind or""));xmlFile:setString(key.."#value",tostring(entry.value or""));xmlFile:setBool(key.."#enabled",entry.enabled==true);xmlFile:setFloat(key.."#amount",num(entry.amount,0));xmlFile:setFloat(key.."#arrears",num(entry.arrears,0));index=index+1 end
        return result
    end

    local baseLoad = Company.loadFarm
    function Company:loadFarm(xmlFile, moduleKey, farmId)
        local legacyLegalFormId = xmlFile ~= nil and moduleKey ~= nil and xmlFile:getString(moduleKey..".identity#legalFormId", "") or ""
        local result = baseLoad(self, xmlFile, moduleKey, farmId)
        if result == nil or result.ok == false then return result end
        local state = self:getFarmState(farmId, true)
        if xmlFile ~= nil and moduleKey ~= nil then
            state.structureActivated = xmlFile:getBool(moduleKey..".structure#activated", false)
            state.lastStructureFeePeriodKey = xmlFile:getInt(moduleKey..".structure#lastFeePeriodKey", state.lastStructureFeePeriodKey or 0)
            state.structureFeeArrears = xmlFile:getFloat(moduleKey..".structure#feeArrears", state.structureFeeArrears or 0)
            local activities={FARMING=true}; if xmlFile.iterate~=nil then xmlFile:iterate(moduleKey..".structure.activities.item",function(_,key)local id=xmlFile:getString(key.."#id","");if self:getActivity(id)~=nil then activities[id]=true end end) end; state.activities=activities
            local memberships={}; if xmlFile.iterate~=nil then xmlFile:iterate(moduleKey..".structure.memberships.item",function(_,key)local id=xmlFile:getString(key.."#id","");if self:getNetwork(id)~=nil then memberships[id]=true end end) end; if tostring(legacyLegalFormId)=="CUMA" then state.legalFormId="EI";memberships.CUMA=true;state.structureActivated=true end;state.memberships=memberships
            state.structureHistory={}; if xmlFile.iterate~=nil then xmlFile:iterate(moduleKey..".structure.history.item",function(_,key)table.insert(state.structureHistory,{periodKey=xmlFile:getInt(key.."#periodKey",0),kind=xmlFile:getString(key.."#kind",""),value=xmlFile:getString(key.."#value",""),enabled=xmlFile:getBool(key.."#enabled",false),amount=xmlFile:getFloat(key.."#amount",0),arrears=xmlFile:getFloat(key.."#arrears",0)})end) end; if tostring(legacyLegalFormId)=="CUMA" then table.insert(state.structureHistory,{periodKey=self:getPeriodKey(),kind="MIGRATE_CUMA",value="CUMA"}) end
        end
        ensureState(self,state)
        return result
    end
end

if AgriLife.CompanyModule ~= nil then
    AgriLife.CompanyModule.SCHEMA_VERSION = math.max(3, tonumber(AgriLife.CompanyModule.SCHEMA_VERSION) or 2)
    function AgriLife.CompanyModule:getActivities() return AgriLife.Company6Service.ACTIVITIES end
    function AgriLife.CompanyModule:getNetworks() return AgriLife.Company6Service.NETWORKS end
    function AgriLife.CompanyModule:previewLegalFormChange(...) return self.service:previewLegalFormChange(...) end
    function AgriLife.CompanyModule:previewActivityChange(...) return self.service:previewActivityChange(...) end
    function AgriLife.CompanyModule:previewMembershipChange(...) return self.service:previewMembershipChange(...) end
    function AgriLife.CompanyModule:setActivity(farmId, activityId, enabled, actorProfileId)
        if not self:canManage(farmId) then return AgriLife.Result.fail("COMPANY_UNAUTHORIZED", "Only the owner or a manager can change company settings") end
        return self.service:setActivity(farmId, activityId, enabled, actorProfileId)
    end
    function AgriLife.CompanyModule:setMembership(farmId, networkId, enabled, actorProfileId)
        if not self:canManage(farmId) then return AgriLife.Result.fail("COMPANY_UNAUTHORIZED", "Only the owner or a manager can change company settings") end
        return self.service:setMembership(farmId, networkId, enabled, actorProfileId)
    end

    local baseStart = AgriLife.CompanyModule.start
    function AgriLife.CompanyModule:start()
        local result = baseStart(self)
        if result ~= nil and result.ok ~= false and self.core ~= nil and self.core.context ~= nil and self.core.context.isServer == true and self.core.subscriptions ~= nil and MessageType ~= nil and MessageType.PERIOD_CHANGED ~= nil then
            self.core.subscriptions:subscribe(self.ID.."_structure", MessageType.PERIOD_CHANGED, self.service, self.service.onStructurePeriodChanged)
        end
        return result
    end

    local baseStop = AgriLife.CompanyModule.stop
    function AgriLife.CompanyModule:stop()
        if self.core ~= nil and self.core.subscriptions ~= nil then self.core.subscriptions:unsubscribeOwner(self.ID.."_structure") end
        return baseStop(self)
    end
end
