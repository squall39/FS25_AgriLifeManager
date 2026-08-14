-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

local function tr(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, value = pcall(g_i18n.getText, g_i18n, key)
        if ok and value ~= nil and tostring(value) ~= tostring(key) then return tostring(value) end
    end
    return tostring(fallback or key or "")
end

local function showInfo(message)
    if g_gui ~= nil and g_gui.showInfoDialog ~= nil then pcall(g_gui.showInfoDialog, g_gui, {text=tostring(message or "")}); return true end
    if InfoDialog ~= nil and InfoDialog.show ~= nil then pcall(InfoDialog.show, tostring(message or "")); return true end
    return false
end

local function showConfirm(message, callback)
    if g_gui ~= nil and g_gui.showYesNoDialog ~= nil then
        g_gui:showYesNoDialog({text=tostring(message or ""),title=tr("agrilife_reset_guard_title","AgriLife - récupération matériel"),callback=function(_,confirmed) callback(confirmed==true) end,target=nil,yesText=tr("agrilife_core_yes","Oui"),noText=tr("agrilife_core_no","Non")})
        return true
    end
    if YesNoDialog ~= nil and YesNoDialog.show ~= nil then YesNoDialog.show(function(confirmed) callback(confirmed==true) end,nil,tostring(message or "")); return true end
    return false
end

if AgriLife.Workshop6Service ~= nil then
    local Workshop=AgriLife.Workshop6Service
    Workshop.EMERGENCY_TRANSPORT_VERSION="0.9.3.27"

    function Workshop:requestEmergencyTransport(farmId,assetId,profileId,destination,urgency)
        local state=self:getState(farmId,true);self:syncVehicles(farmId)
        local vehicle=self:findVehicle(farmId,assetId)
        if vehicle==nil then return AgriLife.Result.fail("WORKSHOP_EMERGENCY_ASSET_MISSING",tr("agrilife_reset_guard_asset_missing","Selected vehicle could not be linked to AgriLife.")) end
        if tostring(vehicle.currentWorkshopJobId or "")~="" then return AgriLife.Result.fail("WORKSHOP8_JOB_ACTIVE",tr("agrilife_workshop81_job_active","A workshop operation is already active.")) end
        destination=string.upper(tostring(destination or "DEALER"));if destination~="DEALER" and destination~="INTERNAL" then destination="DEALER" end
        urgency=string.upper(tostring(urgency or "STANDARD"))
        local quote=self:getRecoveryQuote(farmId,assetId,destination,urgency)
        if quote==nil then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_QUOTE_FAILED",tr("agrilife_workshop81_recovery_quote_failed","Recovery quote unavailable.")) end
        if not self:debitWorkshop(farmId,quote.cost,"WORKSHOP_EMERGENCY_TRANSPORT",tostring(assetId)) then return AgriLife.Result.fail("WORKSHOP81_RECOVERY_FUNDS_LOW",tr("agrilife_workshop81_recovery_funds_low","Insufficient funds for recovery."),{cost=quote.cost}) end
        local id=string.format("RECOVERY_%d_%06d",farmId,state.nextWorkshopJobId);state.nextWorkshopJobId=state.nextWorkshopJobId+1
        local now=self:getGameMinuteStamp()
        local job={id=id,assetId=assetId,kind="RECOVERY",provider="RECOVERY_SERVICE",mechanicProfileId="",qualityId="OEM",urgency=quote.urgency,status="IN_PROGRESS",createdGameMinute=now,startedGameMinute=now,dueGameMinute=now+quote.delayHours*60,completedGameMinute=0,laborHours=quote.delayHours,laborCost=quote.cost,partsCost=0,deliveryCost=0,totalCost=quote.cost,parts={},partOrderIds={},partsConsumed=true,recoveryDestination=destination,recoveryDistanceKm=quote.distanceKm,assistancePaid=0,options={recoveryDestination=destination,requestedByProfileId=tostring(profileId or""),emergencyTransport=true}}
        table.insert(state.workshopJobs,job);vehicle.currentWorkshopJobId=id;vehicle.downtimePeriods=math.max(1,tonumber(vehicle.downtimePeriods)or 0);vehicle.recoveryDestination=destination
        self:addLifeEvent(farmId,assetId,"EMERGENCY_TRANSPORT_REQUESTED",id..":"..destination)
        return AgriLife.Result.ok("WORKSHOP_EMERGENCY_TRANSPORT_CREATED",tr("agrilife_reset_guard_created","Recovery transport requested."),{job=job,quote=quote})
    end
end

if AgriLife.WorkshopModule ~= nil then
    function AgriLife.WorkshopModule:requestEmergencyTransport(...) return self.service:requestEmergencyTransport(...) end
end

if AgriLife.UIManager ~= nil then
    local UI=AgriLife.UIManager
    UI.VANILLA_BYPASS_VERSION="0.9.3.27"

    function UI:getMapOverviewPage()
        local menu=self:getInGameMenu()
        return menu~=nil and (menu.pageMapOverview or menu.pageMap or menu.mapOverviewPage) or nil
    end

    function UI:resolveResetVehicle(page,...)
        local args={...}
        for _,value in ipairs(args) do if type(value)=="table" and value.rootNode~=nil and (value.getOwnerFarmId~=nil or value.ownerFarmId~=nil) then return value end end
        if type(page)=="table" then
            for _,field in ipairs({"selectedVehicle","currentVehicle","vehicle"}) do local value=page[field];if type(value)=="table" and value.rootNode~=nil then return value end end
            for _,field in ipairs({"selectedHotspot","currentHotspot","selectedMapHotspot","hotspot"}) do
                local hotspot=page[field]
                if type(hotspot)=="table" then
                    if type(hotspot.vehicle)=="table" then return hotspot.vehicle end
                    if hotspot.getVehicle~=nil then local ok,value=pcall(hotspot.getVehicle,hotspot);if ok and type(value)=="table" then return value end end
                    if type(hotspot.object)=="table" and hotspot.object.rootNode~=nil then return hotspot.object end
                end
            end
        end
        return nil
    end

    function UI:handleVanillaResetReplacement(page,...)
        local vehicle=self:resolveResetVehicle(page,...)
        if vehicle==nil then showInfo(tr("agrilife_reset_guard_unresolved","Vanilla reset is disabled. Use AgriLife > Workshop for recovery and transport."));return false end
        local farmId=0;if vehicle.getOwnerFarmId~=nil then local ok,value=pcall(vehicle.getOwnerFarmId,vehicle);if ok then farmId=tonumber(value)or 0 end end;if farmId<=0 then farmId=tonumber(vehicle.ownerFarmId)or 0 end
        local workshop=self.core~=nil and self.core.registry~=nil and self.core.registry.instances~=nil and self.core.registry.instances.workshop or nil
        local service=workshop~=nil and (workshop.service or workshop) or nil
        if service==nil or service.getVehicleId==nil or farmId<=0 then showInfo(tr("agrilife_reset_guard_unavailable","AgriLife recovery service is unavailable for this vehicle."));return false end
        service:syncVehicles(farmId);local assetId=service:getVehicleId(vehicle,0);local quote=service:getRecoveryQuote(farmId,assetId,"DEALER","STANDARD")
        if quote==nil then showInfo(tr("agrilife_reset_guard_unavailable","AgriLife recovery service is unavailable for this vehicle."));return false end
        local message=string.format(tr("agrilife_reset_guard_confirm_fmt","Vanilla reset is disabled. Recovery to the dealer will cost %s and take about %.1f h. Confirm the AgriLife recovery service?"),g_i18n~=nil and g_i18n.formatMoney~=nil and g_i18n:formatMoney(quote.cost,0,true,true) or tostring(quote.cost),tonumber(quote.delayHours)or 0)
        local profileId="";if service.getResponsibleProfileId~=nil then profileId=service:getResponsibleProfileId(farmId,vehicle) end
        showConfirm(message,function(confirmed)
            if confirmed~=true then return end
            local result=workshop.requestEmergencyTransport~=nil and workshop:requestEmergencyTransport(farmId,assetId,profileId,"DEALER","STANDARD") or nil
            showInfo(result~=nil and result.ok==true and tr("agrilife_reset_guard_created","Recovery transport requested. The vehicle will be moved after the announced delay.") or tostring(result~=nil and result.message or tr("agrilife_reset_guard_unavailable","Recovery request failed.")))
        end)
        return false
    end

    function UI:installMapResetGuard()
        local page=self:getMapOverviewPage();if page==nil then return false end
        if page._agriLifeResetGuardInstalled==true then return true end
        local installed=false
        for _,methodName in ipairs({"onClickResetVehicle","onClickReset","onResetVehicle","resetVehicle","onClickResetVehicles"}) do
            if type(page[methodName])=="function" then
                local original=page[methodName];local manager=self
                page["_agriLifeOriginal_"..methodName]=original
                page[methodName]=function(pageSelf,...) return manager:handleVanillaResetReplacement(pageSelf,...) end
                installed=true
            end
        end
        page._agriLifeResetGuardInstalled=installed
        if installed and AgriLife.Logger~=nil then AgriLife.Logger.info("UI","Vanilla vehicle/tool reset replaced by AgriLife recovery service") end
        return installed
    end

    function UI:enforceAgriLifeContractUI()
        local menu=self:getInGameMenu();local page=menu~=nil and (menu.pageContracts or menu.contractsPage) or nil
        if page==nil then return end
        for _,name in ipairs({"acceptButton","buttonAccept","startContractButton","newContractButton"}) do local element=page[name];if element~=nil then if element.setDisabled~=nil then pcall(element.setDisabled,element,true) end end end
        page.agriLifeContractsManaged=true
    end

    local baseUpdate=UI.update
    function UI:update(dt)
        local result=baseUpdate(self,dt)
        self.vanillaBypassPollMs=(tonumber(self.vanillaBypassPollMs)or 0)+(tonumber(dt)or 0)
        if self.vanillaBypassPollMs>=1000 then self.vanillaBypassPollMs=0;self:installMapResetGuard();self:enforceAgriLifeContractUI();self:enforceAgriLifeBankingUI() end
        return result
    end
end
