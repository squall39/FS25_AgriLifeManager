-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager 0.9.3.0 - player accident statement dialog.
AgriLife = AgriLife or {}

AgriLife.AccidentStatementDialog = {}
AgriLife.AccidentStatementDialog_mt = Class(AgriLife.AccidentStatementDialog, DialogElement)

-- FS25 1.21 compatibility: custom controllers are FrameElement descendants, but
-- some runtime builds do not expose registerControls through the custom dialog
-- metatable at constructor time. Call the FrameElement implementation directly
-- as a safe fallback so IDs are still exposed after g_gui:loadGui().
local function registerDialogControls(controller, controlIds)
    if controller ~= nil and type(controller.registerControls) == "function" then
        controller:registerControls(controlIds)
        return
    end
    if controller ~= nil and FrameElement ~= nil and type(FrameElement.registerControls) == "function" then
        controller.controlIDs = controller.controlIDs or {}
        FrameElement.registerControls(controller, controlIds)
        return
    end
    error("AgriLife dialog controller cannot register GUI controls")
end

local function tr(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local value = g_i18n:getText(key)
        if value ~= nil and value ~= "" and value ~= key then return value end
    end
    return tostring(fallback or key or "")
end

local function setText(element, value)
    if element ~= nil and element.setText ~= nil then element:setText(tostring(value or "")) end
end

local function setVisible(element, visible)
    if element ~= nil and element.setVisible ~= nil then element:setVisible(visible == true) end
end

local function setDisabled(element, disabled)
    if element ~= nil and element.setDisabled ~= nil then element:setDisabled(disabled == true) end
end

local CIRCUMSTANCES = {
    {id="COLLISION_OBSTACLE", key="agrilife_accident93_circumstance_obstacle", fallback="Collision avec un obstacle"},
    {id="ROAD_COLLISION", key="agrilife_accident93_circumstance_collision", fallback="Collision en circulation"},
    {id="LOSS_OF_CONTROL", key="agrilife_accident93_circumstance_control", fallback="Perte de contrôle"},
    {id="HARSH_BRAKING", key="agrilife_accident93_circumstance_braking", fallback="Freinage / évitement"},
    {id="WORK_ACCIDENT", key="agrilife_accident93_circumstance_work", fallback="Accident pendant le travail"},
    {id="OTHER", key="agrilife_accident93_circumstance_other", fallback="Autre circonstance"}
}

local IMPACTS = {
    {id="FRONT", key="agrilife_accident93_impact_front", fallback="Avant"},
    {id="REAR", key="agrilife_accident93_impact_rear", fallback="Arrière"},
    {id="LEFT", key="agrilife_accident93_impact_left", fallback="Côté gauche"},
    {id="RIGHT", key="agrilife_accident93_impact_right", fallback="Côté droit"},
    {id="WHEEL", key="agrilife_accident93_impact_wheel", fallback="Roue / essieu"},
    {id="IMPLEMENT", key="agrilife_accident93_impact_implement", fallback="Outil / accessoire"}
}

local OBSERVATIONS = {
    {id="NO_THIRD_PARTY", key="agrilife_accident93_observation_alone", fallback="Aucun tiers impliqué"},
    {id="THIRD_PARTY", key="agrilife_accident93_observation_thirdparty", fallback="Un tiers est impliqué"},
    {id="WITNESS", key="agrilife_accident93_observation_witness", fallback="Présence d'un témoin"},
    {id="MATERIAL_ONLY", key="agrilife_accident93_observation_material", fallback="Dégâts matériels uniquement"}
}

local function selectorTexts(rows)
    local values = {}
    for _, row in ipairs(rows) do table.insert(values, tr(row.key, row.fallback)) end
    return values
end

local function selectorRow(element, rows)
    local index = 1
    if element ~= nil and element.getState ~= nil then
        local ok, value = pcall(element.getState, element)
        if ok and tonumber(value) ~= nil then index = math.max(1, math.min(#rows, math.floor(tonumber(value)))) end
    elseif element ~= nil and tonumber(element.state) ~= nil then
        index = math.max(1, math.min(#rows, math.floor(tonumber(element.state))))
    end
    return rows[index]
end

function AgriLife.AccidentStatementDialog.new()
    local self = DialogElement.new(nil, AgriLife.AccidentStatementDialog_mt)
    registerDialogControls(self, {
        "accidentSelector", "emptyText", "statementPanel", "vehicleText", "otherText", "contactText",
        "incidentTypeText", "locationText", "circumstanceSelector", "impactSelector", "observationSelector",
        "statusText", "resultText", "submitButton"
    })
    self.workshop = nil
    self.farmId = 0
    self.actorProfileId = ""
    self.accidents = {}
    self.selectedIndex = 1
    self.onCompleted = nil
    return self
end

function AgriLife.AccidentStatementDialog:setData(workshop, farmId, accidents, selectedAccidentId, actorProfileId, callback)
    self.workshop = workshop
    self.farmId = tonumber(farmId) or 0
    self.actorProfileId = tostring(actorProfileId or "")
    self.accidents = {}
    for _, accident in ipairs(type(accidents) == "table" and accidents or {}) do
        local responsible = tostring(accident.driverProfileId or accident.responsibleProfileId or "")
        if responsible == self.actorProfileId and tostring(accident.declarationStatus or "PENDING_DRIVER") ~= "COMPLETED" and tostring(accident.driverType or "PLAYER") ~= "AI_WORKER" then
            table.insert(self.accidents, accident)
        end
    end
    self.selectedIndex = 1
    for index, accident in ipairs(self.accidents) do if tostring(accident.id or "") == tostring(selectedAccidentId or "") then self.selectedIndex = index; break end end
    self.onCompleted = callback
    self:refreshSelectors()
    self:refreshContent()
end

function AgriLife.AccidentStatementDialog:refreshSelectors()
    if self.circumstanceSelector ~= nil and self.circumstanceSelector.setTexts ~= nil then self.circumstanceSelector:setTexts(selectorTexts(CIRCUMSTANCES)) end
    if self.impactSelector ~= nil and self.impactSelector.setTexts ~= nil then self.impactSelector:setTexts(selectorTexts(IMPACTS)) end
    if self.observationSelector ~= nil and self.observationSelector.setTexts ~= nil then self.observationSelector:setTexts(selectorTexts(OBSERVATIONS)) end
    if self.accidentSelector ~= nil and self.accidentSelector.setTexts ~= nil then
        local rows = {}
        for _, accident in ipairs(self.accidents) do table.insert(rows, string.format("%s - %s", tostring(accident.vehicleName or "Matériel"), tostring(accident.id or ""))) end
        self.accidentSelector:setTexts(rows)
        if #rows > 0 and self.accidentSelector.setState ~= nil then pcall(self.accidentSelector.setState, self.accidentSelector, self.selectedIndex) end
    end
end

function AgriLife.AccidentStatementDialog:getSelectedAccident()
    if #self.accidents == 0 then return nil end
    self.selectedIndex = math.max(1, math.min(#self.accidents, self.selectedIndex))
    return self.accidents[self.selectedIndex]
end

function AgriLife.AccidentStatementDialog:refreshContent()
    local accident = self:getSelectedAccident()
    setVisible(self.emptyText, accident == nil)
    setVisible(self.statementPanel, accident ~= nil)
    setDisabled(self.submitButton, accident == nil)
    if accident == nil then
        setText(self.resultText, "")
        return
    end
    setText(self.vehicleText, tostring(accident.vehicleName or accident.assetId or "--"))
    setText(self.otherText, tostring(accident.id or "--"))
    setText(self.contactText, tr("agrilife_accident93_owner_notice", "Le patron recevra le constat avant toute décision d'assurance."))
    setText(self.incidentTypeText, tr("agrilife_accident93_driver_statement", "Constat du conducteur"))
    setText(self.locationText, tostring(accident.cause or "collision"))
    setText(self.statusText, tr("agrilife_accident93_statement_required", "Renseignez les faits puis validez le constat."))
    setText(self.resultText, tr("agrilife_accident93_statement_no_decision", "Cette déclaration décrit les faits. Elle ne valide aucune indemnisation ni décision bancaire."))
end

function AgriLife.AccidentStatementDialog:onOpen()
    AgriLife.AccidentStatementDialog:superClass().onOpen(self)
    self:refreshSelectors()
    self:refreshContent()
end

function AgriLife.AccidentStatementDialog:onAccidentChanged()
    if self.accidentSelector ~= nil and self.accidentSelector.getState ~= nil then
        local ok, value = pcall(self.accidentSelector.getState, self.accidentSelector)
        if ok and tonumber(value) ~= nil then self.selectedIndex = math.max(1, math.floor(tonumber(value))) end
    end
    self:refreshContent()
end

function AgriLife.AccidentStatementDialog:onSubmitStatement()
    local accident = self:getSelectedAccident()
    if accident == nil or self.workshop == nil or self.workshop.submitAccidentDeclaration93 == nil then return end
    local circumstance = selectorRow(self.circumstanceSelector, CIRCUMSTANCES)
    local impact = selectorRow(self.impactSelector, IMPACTS)
    local observation = selectorRow(self.observationSelector, OBSERVATIONS)
    local result = self.workshop:submitAccidentDeclaration93(self.farmId, accident.id, self.actorProfileId, {
        circumstanceCode = circumstance.id,
        impactZone = impact.id,
        observationCode = observation.id,
        notes = observation.id,
        witnessCount = observation.id == "WITNESS" and 1 or 0,
        thirdPartyPresent = observation.id == "THIRD_PARTY"
    }, false)
    if result ~= nil and result.ok == true then
        setText(self.statusText, tr("agrilife_accident93_statement_sent", "Constat transmis au patron."))
        setText(self.resultText, tr("agrilife_accident93_owner_decides", "Le patron décidera maintenant de transmettre ou non le dossier à l'assurance."))
        setDisabled(self.submitButton, true)
        if self.onCompleted ~= nil then pcall(self.onCompleted, result) end
    else
        setText(self.statusText, result ~= nil and tostring(result.message or result.code or "") or tr("agrilife_accident93_statement_failed", "Le constat n'a pas pu être enregistré."))
    end
end

function AgriLife.AccidentStatementDialog:onClickBack(forceBack, usedMenuButton)
    if usedMenuButton then return true end
    self:close()
    return false
end
