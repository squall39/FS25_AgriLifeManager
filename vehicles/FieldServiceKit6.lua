-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

FieldServiceKit6 = {}
FieldServiceKit6.instances = {}
FieldServiceKit6.nearest = nil
FieldServiceKit6.actionEventId = nil
FieldServiceKit6.hookInstalled = false

function FieldServiceKit6.prerequisitesPresent() return true end
function FieldServiceKit6.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "activateAgriLifeFieldKit", FieldServiceKit6.activateAgriLifeFieldKit)
end
function FieldServiceKit6.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", FieldServiceKit6)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", FieldServiceKit6)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", FieldServiceKit6)
end
function FieldServiceKit6.initSpecialization()
    FieldServiceKit6.installPlayerHook()
end

function FieldServiceKit6:onLoad()
    self.spec_fieldServiceKit6 = { accumulator = 0, target = nil, pendingDelete = 0 }
    table.insert(FieldServiceKit6.instances, self)
    if self.raiseActive ~= nil then self:raiseActive() end
end

function FieldServiceKit6:onDelete()
    for index = #FieldServiceKit6.instances, 1, -1 do
        if FieldServiceKit6.instances[index] == self then table.remove(FieldServiceKit6.instances, index) end
    end
    if FieldServiceKit6.nearest == self then FieldServiceKit6.nearest = nil end
end

function FieldServiceKit6:onUpdate(dt)
    local spec = self.spec_fieldServiceKit6
    if spec == nil then return end
    if self.raiseActive ~= nil then self:raiseActive() end
    if spec.pendingDelete > 0 then
        spec.pendingDelete = spec.pendingDelete - dt
        if spec.pendingDelete <= 0 and self.delete ~= nil then self:delete() end
        return
    end
    spec.accumulator = spec.accumulator + dt
    if spec.accumulator < 350 then return end
    spec.accumulator = 0
    local px, py, pz = AgriLife.PhysicalWorkshop6:getPlayerPosition()
    local x, y, z = AgriLife.PhysicalWorkshop6:getPosition(self)
    local playerDistance = math.huge
    if px ~= nil and x ~= nil then playerDistance = math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2) end
    spec.target = playerDistance <= 3 and AgriLife.PhysicalWorkshop6:findNearestVehicle(self, 6, g_currentMission ~= nil and g_currentMission.controlledVehicle or nil) or nil
    if spec.target ~= nil and (FieldServiceKit6.nearest == nil or FieldServiceKit6.nearest == self or playerDistance < (FieldServiceKit6.nearestDistance or math.huge)) then
        FieldServiceKit6.nearest = self
        FieldServiceKit6.nearestDistance = playerDistance
    elseif FieldServiceKit6.nearest == self and spec.target == nil then
        FieldServiceKit6.nearest = nil
        FieldServiceKit6.nearestDistance = nil
    end
    FieldServiceKit6.updateAction()
end

function FieldServiceKit6.updateAction()
    if FieldServiceKit6.actionEventId == nil or g_inputBinding == nil then return end
    local kit = FieldServiceKit6.nearest
    local active = kit ~= nil and kit.spec_fieldServiceKit6 ~= nil and kit.spec_fieldServiceKit6.target ~= nil
    local prefix = g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_field_action") or "Diagnostic et dépannage d’urgence : %s"
    local text = active and string.format(prefix, AgriLife.PhysicalWorkshop6:getVehicleName(kit.spec_fieldServiceKit6.target)) or ""
    g_inputBinding:setActionEventActive(FieldServiceKit6.actionEventId, active)
    g_inputBinding:setActionEventTextVisibility(FieldServiceKit6.actionEventId, active)
    if active then g_inputBinding:setActionEventText(FieldServiceKit6.actionEventId, text) end
end

function FieldServiceKit6:activateAgriLifeFieldKit()
    local spec = self.spec_fieldServiceKit6
    if spec == nil or spec.target == nil then
        AgriLife.PhysicalWorkshop6:notify(g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_field_no_target") or "Aucun matériel maintenable à proximité", true)
        return
    end
    local diagnostic = AgriLife.PhysicalWorkshop6:run(spec.target, "diagnose")
    if diagnostic == nil or diagnostic.ok ~= true then
        AgriLife.PhysicalWorkshop6:notify(diagnostic ~= nil and diagnostic.message or (g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_field_diagnosis_failed") or "Diagnostic impossible"), true)
        return
    end
    local result = AgriLife.PhysicalWorkshop6:run(spec.target, "fieldEmergency")
    AgriLife.PhysicalWorkshop6:notify(result ~= nil and result.message or (g_i18n ~= nil and g_i18n:getText("agrilife_workshop81_field_no_fault") or "Aucun dépannage d’urgence disponible"), result == nil or result.ok ~= true)
    if result ~= nil and result.ok == true then
        spec.pendingDelete = 250
        if self.rootNode ~= nil and setVisibility ~= nil then setVisibility(self.rootNode, false) end
        FieldServiceKit6.nearest = nil
        FieldServiceKit6.updateAction()
    end
end

function FieldServiceKit6.actionCallback(_, _, inputValue)
    if (tonumber(inputValue) or 0) <= 0 then return end
    local kit = FieldServiceKit6.nearest
    if kit ~= nil then kit:activateAgriLifeFieldKit() end
end

function FieldServiceKit6.installPlayerHook()
    if FieldServiceKit6.hookInstalled or PlayerInputComponent == nil or PlayerInputComponent.registerActionEvents == nil then return end
    FieldServiceKit6.hookInstalled = true
    local original = PlayerInputComponent.registerActionEvents
    PlayerInputComponent.registerActionEvents = function(component, ...)
        original(component, ...)
        if g_inputBinding == nil or InputAction == nil or InputAction.AGRILIFE_FIELD_KIT == nil then return end
        g_inputBinding:beginActionEventsModification(PlayerInputComponent.INPUT_CONTEXT_NAME)
        local _, eventId = g_inputBinding:registerActionEvent(InputAction.AGRILIFE_FIELD_KIT, FieldServiceKit6, FieldServiceKit6.actionCallback, false, true, false, true)
        g_inputBinding:endActionEventsModification()
        FieldServiceKit6.actionEventId = eventId
        if eventId ~= nil then FieldServiceKit6.updateAction() end
    end
end
