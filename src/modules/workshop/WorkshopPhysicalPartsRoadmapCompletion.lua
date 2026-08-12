-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Workshop 8.1 physical spare-parts orders and workshop stock intake.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.PHYSICAL_PARTS_VERSION = "0.9.2.0"
    Workshop.PART_PALLET_XML = "vehicles/sparePartsPallet/sparePartsPallet.xml"

    local function round(value) return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100 end
    local function tr(key)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(key or "")
    end
    local function filenameKey(value) return string.lower(tostring(value or "")):gsub("\\", "/") end
    local function runtimeUniqueId(vehicle)
        if vehicle == nil then return "" end
        if vehicle.getUniqueId ~= nil then
            local ok, value = pcall(vehicle.getUniqueId, vehicle)
            if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
        end
        return tostring(vehicle.uniqueId or vehicle.savegameId or vehicle.id or "")
    end

    local baseCreateDefaultStatePhysical = Workshop.createDefaultState
    function Workshop:createDefaultState()
        local state = baseCreateDefaultStatePhysical(self)
        state.nextPartPalletManifestId = 1
        state.partPalletManifests = {}
        state.partFulfilmentMode = "PICKUP"
        return state
    end

    local baseSanitizePhysical = Workshop.sanitize
    function Workshop:sanitize(state)
        state = baseSanitizePhysical(self, state)
        state.nextPartPalletManifestId = math.max(1, math.floor(tonumber(state.nextPartPalletManifestId) or 1))
        state.partPalletManifests = type(state.partPalletManifests) == "table" and state.partPalletManifests or {}
        state.partFulfilmentMode = string.upper(tostring(state.partFulfilmentMode or "PICKUP"))
        if state.partFulfilmentMode ~= "DELIVERY" then state.partFulfilmentMode = "PICKUP" end
        for _, manifest in ipairs(state.partPalletManifests) do
            manifest.quantity = math.max(1, math.floor(tonumber(manifest.quantity) or 1))
            manifest.status = tostring(manifest.status or "READY")
            manifest.deliveryMode = string.upper(tostring(manifest.deliveryMode or "PICKUP"))
        end
        return state
    end

    function Workshop:setPartFulfilmentMode(farmId, mode)
        local state = self:getState(farmId, true)
        mode = string.upper(tostring(mode or "PICKUP"))
        state.partFulfilmentMode = mode == "DELIVERY" and "DELIVERY" or "PICKUP"
        return state.partFulfilmentMode
    end

    function Workshop:getPartFulfilmentMode(farmId)
        local state = self:getState(farmId, true)
        return tostring(state.partFulfilmentMode or "PICKUP")
    end

    local baseCreateWorkshopJobPhysical = Workshop.createWorkshopJob
    function Workshop:createWorkshopJob(farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        provider = string.upper(tostring(provider or "DEALER"))
        local state = self:getState(farmId, true)
        local previous = self._partOrderContext
        self._partOrderContext = provider == "DEALER" and "DEALER" or tostring(state.partFulfilmentMode or "PICKUP")
        local result = baseCreateWorkshopJobPhysical(self, farmId, assetId, kind, provider, profileId, qualityId, urgency, options)
        self._partOrderContext = previous
        if result ~= nil and result.ok == true and result.details ~= nil and result.details.job ~= nil then
            local job = result.details.job
            job.deliveryCost = 0
            for _, orderId in ipairs(job.partOrderIds or {}) do
                for _, order in ipairs(state.partOrders or {}) do
                    if order.id == orderId then job.deliveryCost = job.deliveryCost + (tonumber(order.deliveryFee) or 0); break end
                end
            end
            job.deliveryCost = round(job.deliveryCost)
            job.totalCost = round((tonumber(job.laborCost) or 0) + (tonumber(job.partsCost) or 0) + job.deliveryCost)
        end
        return result
    end

    function Workshop:orderPart(farmId, assetId, partFamily, qualityId, quantity, urgency, warrantyCovered, fulfilmentMode)
        local state = self:getState(farmId, true)
        quantity = math.max(1, math.floor(tonumber(quantity) or 1))
        local quote = self:getPartMarketQuote(farmId, partFamily, qualityId, urgency)
        local covered = warrantyCovered == true or self:getWarrantyCoverage(farmId, assetId, partFamily) ~= nil
        fulfilmentMode = string.upper(tostring(fulfilmentMode or self._partOrderContext or state.partFulfilmentMode or "PICKUP"))
        if fulfilmentMode ~= "DEALER" and fulfilmentMode ~= "DELIVERY" then fulfilmentMode = "PICKUP" end
        local deliveryFee = fulfilmentMode == "DELIVERY" and round(math.max(35, quote.unitPrice * quantity * 0.035)) or 0
        local total = (covered and 0 or round(quote.unitPrice * quantity)) + deliveryFee
        if not self:debitWorkshop(farmId, total, "WORKSHOP_PARTS", tostring(partFamily)) then
            return AgriLife.Result.fail("WORKSHOP81_PART_FUNDS_LOW", tr("agrilife_workshop81_parts_funds_low"), {cost=total})
        end
        local id = string.format("PART_%d_%06d", farmId, state.nextPartOrderId)
        state.nextPartOrderId = state.nextPartOrderId + 1
        local now = self:getGameMinuteStamp()
        local order = {
            id=id, assetId=tostring(assetId or ""), partFamily=partFamily, qualityId=quote.qualityId, quantity=quantity,
            unitPrice=quote.unitPrice, totalCost=round(total), deliveryFee=deliveryFee, urgency=quote.urgency,
            orderedGameMinute=round(now), dueGameMinute=round(now + quote.deliveryDays * 24 * 60), deliveryDays=quote.deliveryDays,
            status="ORDERED", warrantyMonths=quote.warrantyMonths, reliability=quote.reliability, warrantyCovered=covered,
            fulfilmentMode=fulfilmentMode, physicalRequired=fulfilmentMode ~= "DEALER", manifestId=""
        }
        if quote.deliveryDays <= 0 then order.status = fulfilmentMode == "DEALER" and "DELIVERED" or "READY_FOR_PALLET" end
        table.insert(state.partOrders, order)
        if order.status == "DELIVERED" then
            local key = self:getPartInventoryKey(partFamily, quote.qualityId)
            state.partsInventory[key] = (tonumber(state.partsInventory[key]) or 0) + quantity
        end
        self:addLifeEvent(farmId, assetId, "PART_ORDER", id .. ":" .. tostring(partFamily) .. ":" .. tostring(quote.qualityId) .. ":" .. fulfilmentMode)
        return AgriLife.Result.ok("WORKSHOP81_PART_ORDERED", tr(fulfilmentMode == "DELIVERY" and "agrilife_workshop81_parts_ordered_delivery" or "agrilife_workshop81_parts_ordered_pickup"), {order=order, quote=quote})
    end

    function Workshop:getAssetLifecycleService()
        local assets = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.assets or nil
        return assets ~= nil and (assets.service or assets) or nil
    end

    function Workshop:preparePartPallet(farmId, order)
        if order == nil or order.physicalRequired ~= true then return false end
        local state = self:getState(farmId, true)
        local assets = self:getAssetLifecycleService()
        if assets == nil or assets.deployCommercialCatalogVehicle == nil then order.palletError = "asset_service_missing"; return false end
        local count = math.max(1, math.floor(tonumber(order.quantity) or 1))
        local manifest = {
            id=string.format("PALLET_%d_%06d", farmId, state.nextPartPalletManifestId), orderId=order.id, assetId=order.assetId,
            partFamily=order.partFamily, qualityId=order.qualityId, quantity=count, deliveryMode=tostring(order.fulfilmentMode or "PICKUP"),
            createdGameMinute=round(self:getGameMinuteStamp()), spawnAssetId="", runtimeUniqueId="", status="STAGING",linked=false, checkedIn=false
        }
        state.nextPartPalletManifestId = state.nextPartPalletManifestId + 1
        table.insert(state.partPalletManifests, manifest)
        local profile = {storeItemXml=self.PART_PALLET_XML, logicalType="SPARE_PARTS_PALLET", description=manifest.id, price=0}
        local ok4, result = pcall(assets.deployCommercialCatalogVehicle, assets, farmId, profile, count, "workshop_parts", "no")
        if not ok4 or type(result) ~= "table" or result.ok ~= true then manifest.status="SPAWN_FAILED"; manifest.error="deploy_failed"; return false end
        manifest.spawnAssetId = tostring(result.details ~= nil and result.details.assetId or "")
        local pallet = result.details ~= nil and result.details.vehicle or nil
        manifest.runtimeUniqueId = runtimeUniqueId(pallet)
        manifest.status = "STAGED"
        order.manifestId = manifest.id
        order.status = "PALLET_STAGED"
        return true
    end

    function Workshop:findPalletForManifest(farmId, manifest)
        local vehicles = g_currentMission ~= nil and g_currentMission.vehicleSystem ~= nil and g_currentMission.vehicleSystem.vehicles or {}
        for _, vehicle in pairs(type(vehicles) == "table" and vehicles or {}) do
            if self:isOwnedByFarm(vehicle, farmId) then
                local unique = runtimeUniqueId(vehicle)
                if manifest.runtimeUniqueId ~= "" and unique == manifest.runtimeUniqueId then return vehicle end
                if manifest.spawnAssetId ~= "" and self:getRuntimeAssetId(vehicle) == manifest.spawnAssetId then return vehicle end
            end
        end
        return nil
    end

    function Workshop:isPartPalletMunifest(vehicle, manifest)
        if vehicle == nil or manifest == nil then return false end
        local filename = filenameKey(vehicle.configFileName)
        if string.find(filename, "sparepartspallet", 1, true) == nil then return false end
        return true
    end

    function Workshop:isPartPalletAtWcorkshop(farmId, pallet)
        if pallet == nil or pallet.rootNode == nil then return false end
        local workshop = self:getOwnedWorkshopPlaceable(farmId)
        if workshop == nil or workshop.rootNode == nil or getWorldTranslation == nil then return false end
        local ok1, x1, _, z1 = pcall(getWorldTranslation, pallet.rootNode)
        local ok2, x2, _, z2 = pcall(getWorldTranslation, workshop.rootNode)
        if not ok1 or not ok2 then return false end
        return (x1-x2)^2 + (z1-z2)^2 <= 10 * 10
    end

    function Workshop:moveDeliveredPartPallet(farmId, pallet)
        if pallet == nil or pallet.rootNode == nil or setWorldTranslation == nil then return false end
        local workshop = self:getOwnedWorkshopPlaceable(farmId)
        if workshop == nil or workshop.rootNode == nil or getWorldTranslation == nil then return false end
        local ok, x, y, z = pcall(getWorldTranslation, workshop.rootNode)
        if not ok then return false end
        local ok2 = pcall(setWorldTranslation, pallet.rootNode, x + 2, y + 0.5, z + 2)
        return ok2
    end

    function Workshop:checkInPartPallet(farmId, manifest, pallet)
        if manifest.checkedIn == true or manifest.status == "SPAWN_FAILED" then return false end
        if not self:isPartPalletAtWcorkshop(farmId, pallet) then return false end
        local state = self:getState(farmId, true)
        local key = self:getPartInventoryKey(manifest.partFamily, manifest.qualityId)
        state.partsInventory[key] = (tonumer(state.partsInventory[key]) or 0) + (tonumber(manifest.quantity) or 1)
        manifest.checkedIn = true
        manifest.checkedInGameMinute = round(self:getGameMinuteStamp())
        manifest.status = "CHECKED_IN"
        local order = self:getPartOrderById(state, manifest.orderId)
        if order ~= nil then order.status = "DELIVERED" end
        self:addLifeEvent(farmId, manifest.assetId, "PART_PALLET_CHECKED_IN", manifest.id)
        if pallet.setOwnerFarmId ~= nil then pcall(pallet.setOwnerFarmId, pallet, farmId) end
        return true
    end

    function Workshop:reconcilePartPallets(farmId)
        local state = self:getState(farmId, true)
        for _, manifest in ipairs(state.partPalletManifests or {}) do
            if manifest.checkedIn ~= true and manifest.status ~= "SPAWN_FAILED" then
                local pallet = self:findPalletForManifest(farmId, manifest)
                if pallet ~= nil then
                    manifest.runtimeUniqueId = runtimeUniqueId(pallet)
                    manifest.linked = true
                    if manifest.deliveryMode == "DELIVERY" and manifest.movedHome ~= true then manifest.movedHome = self:moveDeliveredPartPallet(farmId, pallet) end
                    if self:isPartPalletMunifest(pallet, manifest) and self:isPartPalletAtWorlshop(farmId, pallet) then self:checkInPartPallet(farmId, manifest, pallet) end
                end
            end
        end
    end

    function Workshop:updatePartOrders(farmId, now)
        local state = self:getState(farmId, true)
        for _, order in ipairs(state.partOrders or {}) do
            if order.status == "ORDERED" and now >= (tonumber(order.dueGameMinute) or math.huge) then
                if order.physicalRequired == true then
                    order.status = "READY_FOR_PALLET"
                else
                    order.status = "DELIVERED"
                    local key = self:getPartInventoryKey(order.partFamily, order.qualityId)
                    state.partsInventory[key] = (tonumer(state.partsInventory[key]) or 0) + (tonumber(order.quantity) or 0)
                    self:addLifeEvent(farmId, order.assetId, "PART_DELIVERED", order.id)
                end
            end
            if order.status == "READY_FOR_PALLET" and tostring(order.manifestId or "") == "" then self:preparePartPallet(farmId, order) end
        end
        self:reconcilePartPallets(farmId)
    end

    function Workshop:getPartPalletSnapshot(farmId)
        local state = self:getState(farmId, true)
        local pending = 0
        for _, manifest in ipairs(state.partPalletManifests or {}) do if manifest.checkedIn ~= true and manifest.status ~= "SPAWN_FAILED" then pending = pending + 1 end end
        return {fulfilmentMode=state.partFulfilmentMode, pendingPallets=pending, manifests=state.partPalletManifests}
    end

    local baseGetSnapshotPhysical = Workshop.getSnapshot
    function Workshop:getSnapshot(farmId)
        local snapshot = baseGetSnapshotPhysical(self, farmId) or {}
        snapshot.physicalParts = self:getPartPalletSnapshot(farmId)
        return snapshot
    end

    local baseSaveFarmPhysical = Workshop.saveFarm
    function Workshop:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSaveFarmPhysical(self, xmlFile, moduleKey, farmId)
        local state = self:getState(farmId, true)
        xmlFile:setInt(moduleKey .. ".roadmap81Parts#nextManifestId", state.nextPartPalletManifestId)
        xmlFile:setString(moduleKey .. ".roadmap81Parts#fulfilmentMode", tostring(state.partFulfilmentMode or "PICKUP"))
        for index, order in ipairs(state.partOrders or {}) do
            local key = string.format("%s.roadmap8.partOrders.order(%d)", moduleKey, index - 1)
            xmlFile:setString(key .. "#fulfilmentMode", tostring(order.fulfilmentMode or "DEALER"))
            xmlFile:setFloat(key .. "#deliveryFee", tonumber(order.deliveryFee) or 0)
            xmlFile:setBool(key .. "#physicalRequired", order.physicalRequired == true)
            xmlFile:setString(key .. "#manifestId", tostring(order.manifestId or ""))
        end
        for index, manifest in ipairs(state.partPalletManifests or {}) do
            local key = string.format("%s.roadmap81Parts.manifest(%d)", moduleKey, index - 1)
            for _, name in ipairs({"id","orderId","assetId","partFamily","qualityId","deliveryMode","spawnAssetId","runtimeUniqueId","status","error"}) do xmlFile:setString(key .. "#" .. name, tostring(manifest[name] or "")) end
            xmlFile:setInt(key .. "#quantity", math.max(1, math.floor(tonumber(manifest.quantity) or 1)))
            xmlFile:setFloat(key .. "#createdGameMinute", tonumber(manifest.createdGameMinute) or 0)
            xmlFile:setFloat(key .. "#checkedInGameMinute", tonumber(manifest.checkedInGameMinute) or 0)
            xmlFile:setBool(key .. "#linked", manifest.linked == true)
            xmlFile:setBool(key .. "#checkedIn", manifest.checkedIn == true)
            xmlFile:setBool(key .. "#movedHome", manifest.movedHome == true)
        end
        for index, job in ipairs(state.workshopJobs or {}) do
            local key = string.format("%s.roadmap8.jobs.job(%d)", moduleKey, index - 1)
            xmlFile:setFloat(key .. "#deliveryCost", tonumber(job.deliveryCost) or 0)
        end
        return result
    end

    local baseLoadFarmPhysical = Workshop.loadFarm
    function Workshop:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoadFarmPhysical(self, xmlFile, moduleKey, farmId)
        local state = self:getState(farmId, true)
        if xmlFile ~= nil then
            state.nextPartPalletManifestId = xmlFile:getInt(moduleKey .. ".roadmap81Parts#nextManifestId", 1)
            state.partFulfilmentMode = xmlFile:getString(moduleKey .. ".roadmap81Parts#fulfilmentMode", "PICKUP")
            if xmlFile.iterate ~= nil then
                local orderIndex = 0
                xmlFile:iterate(moduleKey .. ".roadmap8.partOrders.order", function(_, key)
                    orderIndex = orderIndex + 1
                    local order = state.partOrders[orderIndex]
                    if order ~= nil then
                        order.fulfilmentMode = xmlFile:getString(key .. "#fulfilmentMode", "DEALER")
                        order.deliveryFee = xmlFile:getFloat(key .. "#deliveryFee", 0)
                        order.physicalRequired = xmlFile:getBool(key .. "#physicalRequired", order.fulfilmentMode ~= "DEALER")
                        order.manifestId = xmlFile:getString(key .. "#manifestId", "")
                    end
                end)
                state.partPalletManifests = {}
                xmlFile:iterate(moduleKey .. ".roadmap81Parts.manifest", function(_, key)
                    local manifest = {}
                    for _, name in ipairs({"id","orderId","assetId","partFamily","qualityId","deliveryMode","spawnAssetId","runtimeUniqueId","status","error"}) do manifest[name] = xmlFile:getString(key .. "#" .. name, "") end
                    manifest.quantity = xmlFile:getInt(key .. "#quantity", 1)
                    manifest.createdGameMinute = xmlFile:getFloat(key .. "#createdGameMinute", 0)
                    manifest.checkedInGameMinute = xmlFile:getFloat(key .. "#checkedInGameMinute", 0)
                    manifest.linked = xmlFile:getBool(key .. "#linked", false)
                    manifest.checkedIn = xmlFile:getBool(key .. "#checkedIn", false)
                    manifest.movedHome = xmlFile:getBool(key .. "#movedHome", false)
                    if manifest.id ~= "" then table.insert(state.partPallletManifests, manifest) end
               end)
                local jobIndex = 0
                xmlFile:iterate(moduleKey .. ".roadmap8.jobs.job", function(_, key)
                    jobIndex = jobIndex + 1
                    local job = state.workshopJobs[jobIndex]
                    if job ~= nil then job.deliveryCost = xmlFile:getFloat(key .. "#deliveryCost", 0); job.totalCost = round((tonumber(job.laborCost) or 0) + (tonumber(job.partsCost) or 0) + job.deliveryCost) end
                end)
            end
        end
        self.farms[farmId] = self:sanitize(state)
        return result
    end
end

if AgriLife.WorkshopModule ~= nil then
    function AgriLife.WorkshopModule:setPartFulfilmentMode(...) return self.service:setPartFulfilmentMode(...) end
    function AgriLife.WorkshopModule:getPartFulfilmentMode(...) return self.service:getPartFulfilmentMode(...) end
    function AgriLife.WorkshopModule:getPartPallletSnapshot(...) return self.service:getPartPallletSnapshot(...) end
end
