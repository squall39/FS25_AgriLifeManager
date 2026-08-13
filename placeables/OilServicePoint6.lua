-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

OilServicePoint6 = {}
AgriLifeOilServiceActivatable6 = {}
local AgriLifeOilServiceActivatable6_mt = Class(AgriLifeOilServiceActivatable6)

function AgriLifeOilServiceActivatable6.new(placeable)
    return setmetatable({ placeable = placeable, activateText = g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_oil_service") or "Effectuer la révision AgriLife" }, AgriLifeOilServiceActivatable6_mt)
end
function AgriLifeOilServiceActivatable6:getIsActivatable()
    return self.placeable ~= nil and self.placeable.spec_oilServicePoint6 ~= nil and self.placeable.spec_oilServicePoint6.target ~= nil
end
function AgriLifeOilServiceActivatable6:getActivateText()
    local spec = self.placeable ~= nil and self.placeable.spec_oilServicePoint6 or nil
    return spec ~= nil and string.format(g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_oil_service_with_stock") or "Effectuer la révision AgriLife (%.0f L)", spec.storageLiters or 0) or self.activateText
end
function AgriLifeOilServiceActivatable6:getDistance() return 1 end
function AgriLifeOilServiceActivatable6:run()
    local spec = self.placeable ~= nil and self.placeable.spec_oilServicePoint6 or nil
    local result = spec ~= nil and spec.target ~= nil and self.placeable:performAgriLifeService() or nil
    AgriLife.PhysicalWorkshop6:notify(result ~= nil and result.message or (g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_oil_service_failed") or "Révision impossible"), result == nil or not result.ok)
end

function OilServicePoint6.prerequisitesPresent() return true end
function OilServicePoint6.registerFunctions(placeableType)
    SpecializationUtil.registerFunction(placeableType, "findAgriLifeServiceTarget", OilServicePoint6.findAgriLifeServiceTarget)
    SpecializationUtil.registerFunction(placeableType, "performAgriLifeService", OilServicePoint6.performAgriLifeService)
end
function OilServicePoint6.registerEventListeners(placeableType)
    SpecializationUtil.registerEventListener(placeableType, "onLoad", OilServicePoint6)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", OilServicePoint6)
    SpecializationUtil.registerEventListener(placeableType, "onUpdate", OilServicePoint6)
    SpecializationUtil.registerEventListener(placeableType, "saveToXMLFile", OilServicePoint6)
end

function OilServicePoint6:onLoad(savegame)
    local stored = 500
    if savegame ~= nil and savegame.xmlFile ~= nil and savegame.key ~= nil then
        local storageKey = savegame.key .. "." .. tostring(g_currentModName or "FS25_AgriLifeManager") .. ".OilServicePoint6#storageLiters"
        stored = savegame.xmlFile:getFloat(storageKey, stored)
    end
    self.spec_oilServicePoint6 = { accumulator = 0, target = nil, activatable = nil, range = 6, storageLiters = math.max(0, math.min(500, tonumber(stored) or 500)), storageCapacity = 500, litersPerService = 10, refillCost = 2500 }
    if self.raiseActive ~= nil then self:raiseActive() end
end
function OilServicePoint6:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_oilServicePoint6
    if spec ~= nil then xmlFile:setFloat(key .. "#storageLiters", math.max(0, tonumber(spec.storageLiters) or 0)) end
end
function OilServicePoint6:onDelete()
    local spec = self.spec_oilServicePoint6
    if spec ~= nil and spec.activatable ~= nil and g_currentMission ~= nil and g_currentMission.activatableObjectsSystem ~= nil then
        g_currentMission.activatableObjectsSystem:removeActivatable(spec.activatable)
    end
end
function OilServicePoint6:findAgriLifeServiceTarget()
    local controlled = g_currentMission ~= nil and g_currentMission.controlledVehicle or nil
    if controlled ~= nil and AgriLife.PhysicalWorkshop6:distanceSquared(self, controlled) <= (self.spec_oilServicePoint6.range ^ 2) then return controlled end
    return nil
end
function OilServicePoint6:ensureAgriLifeStorage(farmId, requiredLiters)
    local spec = self.spec_oilServicePoint6
    if spec == nil then return false, "Cuve indisponible" end
    if spec.storageLiters + 0.001 >= (tonumber(requiredLiters) or 0) then return true end
    local farm = g_farmManager ~= nil and g_farmManager.getFarmById ~= nil and g_farmManager:getFarmById(farmId) or nil
    if farm == nil or (tonumber(farm.money) or 0) + 0.001 < spec.refillCost or g_currentMission == nil or g_currentMission.addMoney == nil then return false, "Cuve insuffisante : 2 500 € sont nécessaires pour la remplir" end
    local ok, changed = pcall(g_currentMission.addMoney, g_currentMission, -spec.refillCost, farmId, MoneyType ~= nil and MoneyType.OTHER or nil, true, true)
    if not ok or changed == false then return false, "Le remplissage de la cuve a échoué" end
    spec.storageLiters = spec.storageCapacity
    local core = AgriLife.PhysicalWorkshop6:getCore()
    local economy = core ~= nil and core.registry ~= nil and core.registry.instances ~= nil and core.registry.instances.economy or nil
    if economy ~= nil and economy.service ~= nil and economy.service.record ~= nil then economy.service:record(farmId, "OIL_TANK_REFILL", -spec.refillCost, "WORKSHOP", nil, "Remplissage de la cuve d'atelier") end
    return true
end
function OilServicePoint6:getAgriLifeFillCapacity(vehicle, fillUnitIndex)
    if vehicle == nil or vehicle.getFillUnitCapacity == nil then return 0 end
    local ok, value = pcall(vehicle.getFillUnitCapacity, vehicle, fillUnitIndex)
    return ok and math.max(0, tonumber(value) or 0) or 0
end
function OilServicePoint6:performAgriLifeService()
    local spec = self.spec_oilServicePoint6
    if spec == nil or spec.target == nil then return AgriLife.Result.fail("OIL_POINT_TARGET_MISSING", "Aucun matériel dans la zone de révision") end
    local farmId = AgriLife.PhysicalWorkshop6:getFarmId(spec.target)
    local storageReady, storageMessage = self:ensureAgriLifeStorage(farmId, spec.litersPerService)
    if not storageReady then return AgriLife.Result.fail("OIL_POINT_STORAGE_LOW", storageMessage) end
    local result = AgriLife.PhysicalWorkshop6:run(spec.target, "service")
    if result ~= nil and result.ok then
        spec.storageLiters = math.max(0, spec.storageLiters - spec.litersPerService)
        result.message = tostring(result.message or "Révision terminée") .. string.format(" - stock cuve %.0f L", spec.storageLiters)
    end
    return result
end
function OilServicePoint6:onUpdate(dt)
    local spec = self.spec_oilServicePoint6
    if spec == nil then return end
    if self.raiseActive ~= nil then self:raiseActive() end
    spec.accumulator = spec.accumulator + dt
    if spec.accumulator < 500 then return end
    spec.accumulator = 0
    spec.target = self:findAgriLifeServiceTarget()
    local system = g_currentMission ~= nil and g_currentMission.activatableObjectsSystem or nil
    if spec.target ~= nil and spec.activatable == nil and system ~= nil then
        spec.activatable = AgriLifeOilServiceActivatable6.new(self)
        system:addActivatable(spec.activatable)
    elseif spec.target == nil and spec.activatable ~= nil and system ~= nil then
        system:removeActivatable(spec.activatable)
        spec.activatable = nil
    end
end
