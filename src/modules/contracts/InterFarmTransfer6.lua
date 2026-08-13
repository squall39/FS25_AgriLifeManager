-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.CommercialContracts6Service ~= nil then
    local Contracts = AgriLife.CommercialContracts6Service
    Contracts.INTERFARM_RUNTIME_VERSION = "0.9.3.17"

    local function num(value, fallback)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return fallback or 0 end
        return value
    end

    local function integer(value, fallback)
        return math.floor(num(value, fallback or 0))
    end

    local function clamp(value, minimum, maximum)
        value = num(value, minimum)
        if value < minimum then return minimum end
        if value > maximum then return maximum end
        return value
    end

    local function round(value)
        return math.floor(num(value, 0) * 100 + 0.5) / 100
    end

    local unpackValues = table ~= nil and table.unpack or unpack

    local function getVehicleOwnerFarmId(vehicle)
        if vehicle == nil then return 0 end
        if vehicle.getOwnerFarmId ~= nil then
            local ok, value = pcall(vehicle.getOwnerFarmId, vehicle)
            if ok then return tonumber(value) or 0 end
        end
        return tonumber(vehicle.ownerFarmId or vehicle.farmId) or 0
    end

    local function setVehicleOwnerFarmId(vehicle, farmId)
        if vehicle == nil then return false, "vehicle not found" end
        for _, methodName in ipairs({"setOwnerFarmId", "setOwnerFarm", "changeOwnerFarmId"}) do
            local method = vehicle[methodName]
            if method ~= nil then
                local ok, result = pcall(method, vehicle, tonumber(farmId) or 0)
                if ok and result ~= false then return true end
            end
        end
        return false, "vehicle ownership API unavailable"
    end

    function Contracts:findRuntimeVehicleForInterFarm(farmId, assetId)
        local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local workshop = instances ~= nil and instances.workshop ~= nil and instances.workshop.service or nil
        if workshop ~= nil and workshop.findRuntimeVehicle ~= nil then
            local runtime = workshop:findRuntimeVehicle(farmId, assetId)
            if runtime ~= nil then return runtime end
        end
        local vehicles = g_currentMission ~= nil and (g_currentMission.vehicles or g_currentMission.vehicleSystem ~= nil and g_currentMission.vehicleSystem.vehicles) or nil
        for _, vehicle in pairs(type(vehicles) == "table" and vehicles or {}) do
            if getVehicleOwnerFarmId(vehicle) == tonumber(farmId) then
                if tostring(vehicle.agriLifeAssetId or "") == tostring(assetId or "") then return vehicle end
                if tostring(vehicle.configFileName or vehicle.xmlFilename or "") == tostring(assetId or "") then return vehicle end
            end
        end
        return nil
    end

    function Contracts:moveWorkshopAssetState(assetId, sourceFarmId, targetFarmId)
        local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local workshop = instances ~= nil and instances.workshop ~= nil and instances.workshop.service or nil
        if workshop == nil or workshop.getState == nil then return end
        local source = workshop:getState(sourceFarmId, false)
        local target = targetFarmId > 0 and workshop:getState(targetFarmId, true) or nil
        local row = source ~= nil and source.vehicles ~= nil and source.vehicles[tostring(assetId or "")] or nil
        if source ~= nil and source.vehicles ~= nil then source.vehicles[tostring(assetId or "")] = nil end
        if target ~= nil and target.vehicles ~= nil and row ~= nil then target.vehicles[tostring(assetId or "")] = row end
    end

    function Contracts:transferInterFarmVehicle(assetId, sourceFarmId, targetFarmId)
        sourceFarmId = integer(sourceFarmId, 0)
        targetFarmId = integer(targetFarmId, 0)
        if sourceFarmId <= 0 or targetFarmId <= 0 or sourceFarmId == targetFarmId then return false, "invalid vehicle transfer farms" end
        local vehicle = self:findRuntimeVehicleForInterFarm(sourceFarmId, assetId)
        if vehicle == nil then return false, "runtime vehicle not found" end
        if getVehicleOwnerFarmId(vehicle) ~= sourceFarmId then return false, "vehicle ownership changed" end
        local ok, reason = setVehicleOwnerFarmId(vehicle, targetFarmId)
        if not ok then return false, reason end
        self:moveWorkshopAssetState(assetId, sourceFarmId, targetFarmId)
        return true
    end

    function Contracts:findFarmStorage(farmId)
        local farm = self:getFarm(farmId)
        if farm ~= nil then
            for _, key in ipairs({"storage", "farmStorage", "storageSystem"}) do
                if farm[key] ~= nil then return farm[key] end
            end
        end
        local mission = g_currentMission
        if mission ~= nil and mission.storageSystem ~= nil then return mission.storageSystem end
        return nil
    end

    function Contracts:getFarmFillLevel(farmId, fillTypeIndex)
        local farm = self:getFarm(farmId)
        if farm ~= nil then
            for _, methodName in ipairs({"getFillLevel", "getFillLevelForFillType", "getFarmFillLevel"}) do
                local method = farm[methodName]
                if method ~= nil then
                    local ok, value = pcall(method, farm, fillTypeIndex)
                    if ok and tonumber(value) ~= nil then return math.max(0, tonumber(value)) end
                end
            end
        end
        local storage = self:findFarmStorage(farmId)
        if storage ~= nil then
            for _, methodName in ipairs({"getFillLevel", "getFillLevelForFillType"}) do
                local method = storage[methodName]
                if method ~= nil then
                    local ok, value = pcall(method, storage, fillTypeIndex, farmId)
                    if ok and tonumber(value) ~= nil then return math.max(0, tonumber(value)) end
                    ok, value = pcall(method, storage, fillTypeIndex)
                    if ok and tonumber(value) ~= nil then return math.max(0, tonumber(value)) end
                end
            end
        end
        return nil
    end

    function Contracts:changeFarmFillLevel(farmId, fillTypeIndex, delta)
        delta = num(delta, 0)
        if math.abs(delta) < 0.001 then return true end
        local farm = self:getFarm(farmId)
        if farm ~= nil then
            local calls = {
                {"addFillLevel", {fillTypeIndex, delta}},
                {"changeFillLevel", {fillTypeIndex, delta}},
                {"addFillTypeLevel", {fillTypeIndex, delta}}
            }
            for _, row in ipairs(calls) do
                local method = farm[row[1]]
                if method ~= nil then
                    local ok, result = pcall(method, farm, unpackValues(row[2]))
                    if ok and result ~= false then return true end
                end
            end
        end
        local storage = self:findFarmStorage(farmId)
        if storage ~= nil then
            local calls = {
                {"addFillLevel", {fillTypeIndex, delta, farmId}},
                {"addFillLevel", {fillTypeIndex, delta}},
                {"changeFillLevel", {fillTypeIndex, delta, farmId}},
                {"changeFillLevel", {fillTypeIndex, delta}}
            }
            for _, row in ipairs(calls) do
                local method = storage[row[1]]
                if method ~= nil then
                    local ok, result = pcall(method, storage, unpackValues(row[2]))
                    if ok and result ~= false then return true end
                end
            end
        end
        return false
    end

    function Contracts:transferInterFarmProduct(fromFarmId, toFarmId, fillTypeIndex, liters, note)
        fromFarmId = integer(fromFarmId, 0)
        toFarmId = integer(toFarmId, 0)
        fillTypeIndex = integer(fillTypeIndex, 0)
        liters = round(math.max(0, num(liters, 0)))
        if fromFarmId <= 0 or toFarmId <= 0 or fromFarmId == toFarmId or fillTypeIndex <= 0 or liters <= 0 then return false, 0, "invalid product transfer" end
        local available = self:getFarmFillLevel(fromFarmId, fillTypeIndex)
        if available ~= nil and available + 0.01 < liters then liters = round(math.max(0, available)) end
        if liters <= 0 then return false, 0, "product unavailable" end
        if not self:changeFarmFillLevel(fromFarmId, fillTypeIndex, -liters) then return false, 0, "source storage API unavailable" end
        if not self:changeFarmFillLevel(toFarmId, fillTypeIndex, liters) then
            self:changeFarmFillLevel(fromFarmId, fillTypeIndex, liters)
            return false, 0, "target storage API unavailable"
        end
        self:recordEconomy(fromFarmId, "INTERFARM_PRODUCT_OUT", 0, note)
        self:recordEconomy(toFarmId, "INTERFARM_PRODUCT_IN", 0, note)
        return true, liters
    end

    function Contracts:transferInterFarmBales(sourceFarmId, targetFarmId, maxCount)
        sourceFarmId = integer(sourceFarmId, 0)
        targetFarmId = integer(targetFarmId, 0)
        maxCount = math.max(1, integer(maxCount, 1))
        local mission = g_currentMission
        local bales = mission ~= nil and (mission.baleSystem ~= nil and mission.baleSystem.bales or mission.bales) or nil
        if type(bales) ~= "table" then return false, 0, "bale system unavailable" end
        local changed = 0
        for _, bale in pairs(bales) do
            if changed >= maxCount then break end
            local owner = tonumber(bale.ownerFarmId or bale.farmId) or 0
            if bale.getOwnerFarmId ~= nil then local ok, value = pcall(bale.getOwnerFarmId, bale); if ok then owner = tonumber(value) or owner end end
            if owner == sourceFarmId then
                for _, methodName in ipairs({"setOwnerFarmId", "setOwnerFarm", "setFarmId"}) do
                    local method = bale[methodName]
                    if method ~= nil then
                        local ok, result = pcall(method, bale, targetFarmId)
                        if ok and result ~= false then changed = changed + 1; break end
                    end
                end
            end
        end
        return changed > 0, changed, changed > 0 and nil or "bale ownership API unavailable"
    end

    local baseValidateInterFarmTermsRuntime = Contracts.validateInterFarmTerms
    function Contracts:validateInterFarmTerms(sourceFarmId, data)
        local result = baseValidateInterFarmTermsRuntime(self, sourceFarmId, data)
        if result == nil or result.ok ~= true or result.details == nil then return result end
        local terms = result.details
        local kind = tostring(terms.contractType or "")
        if (kind == "field_work" or kind == "harvest_help") and integer(terms.fieldId, 0) <= 0 then
            return AgriLife.Result.fail("INTERFARM_FIELD_REQUIRED", "Un champ doit etre selectionne pour ce contrat")
        end
        if kind == "crop_sale" and (integer(terms.fillTypeIndex, 0) <= 0 or num(terms.quantity, 0) <= 0) then
            return AgriLife.Result.fail("INTERFARM_CROP_TERMS_INVALID", "Culture et quantite requises pour la vente")
        end
        if kind == "bale_sale" and num(terms.quantity, 0) < 1 then
            return AgriLife.Result.fail("INTERFARM_BALE_QUANTITY_INVALID", "Nombre de bottes invalide")
        end
        if kind == "asset_sale" or kind == "equipment_rental" then
            if tostring(terms.assetId or "") == "" then return AgriLife.Result.fail("INTERFARM_ASSET_REQUIRED", "Materiel requis pour ce contrat") end
            local runtime = self:findRuntimeVehicleForInterFarm(sourceFarmId, terms.assetId)
            if runtime == nil then return AgriLife.Result.fail("INTERFARM_ASSET_NOT_OWNED", "Materiel source introuvable ou non possede") end
        end
        return result
    end

end
