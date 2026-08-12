-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.JournalDialog = {}
AgriLife.JournalDialog_mt = Class(AgriLife.JournalDialog, DialogElement)

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

local function setText(element, value)
    if element ~= nil and element.setText ~= nil then element:setText(tostring(value or "")) end
end

local function formatMoney(value)
    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then return g_i18n:formatMoney(tonumber(value) or 0, 0, true, true) end
    return string.format("%.0f", tonumber(value) or 0)
end

local function localized(key, fallback)
    if g_i18n == nil or g_i18n.getText == nil then return tostring(fallback or key or "") end
    local value = g_i18n:getText(tostring(key or ""))
    if value == nil or value == "" or value == key then return tostring(fallback or key or "") end
    return value
end

function AgriLife.JournalDialog.new()
    local self = DialogElement.new(nil, AgriLife.JournalDialog_mt)
    registerDialogControls(self, {"dialogTitle", "summaryText", "bodyText", "closeButton"})
    self.entries = {}
    self.totalCount = 0
    return self
end

function AgriLife.JournalDialog:setData(snapshot)
    snapshot = type(snapshot) == "table" and snapshot or {}
    self.entries = type(snapshot.entries) == "table" and snapshot.entries or {}
    self.totalCount = math.max(0, math.floor(tonumber(snapshot.count) or #self.entries))
    self:refreshContent()
end

function AgriLife.JournalDialog:formatEntry(entry)
    local title = localized(entry.titleKey, entry.category or "AgriLife")
    local message = localized(entry.messageKey, "")
    local period = math.floor(tonumber(entry.periodKey) or 0)
    local amount = tonumber(entry.amount) or 0
    local amountText = ""
    if math.abs(amount) >= 0.005 then
        amountText = string.format(" | %s%s", amount > 0 and "+" or "", formatMoney(amount))
    end
    if message ~= "" then
        return string.format("P%d | %s%s\n%s", period, title, amountText, message)
    end
    return string.format("P%d | %s%s", period, title, amountText)
end

function AgriLife.JournalDialog:refreshContent()
    setText(self.dialogTitle, localized("agrilife_journal_dialog_title", "Historique de l’exploitation"))
    setText(self.summaryText, string.format(localized("agrilife_journal_dialog_summary_fmt", "Décisions, finances, contrats et incidents importants  -  %d événement(s) enregistré(s)"), self.totalCount))
    local lines = {}
    local limit = math.min(12, #self.entries)
    for index = 1, limit do
        table.insert(lines, self:formatEntry(self.entries[index]))
        if index < limit then table.insert(lines, "") end
    end
    if #lines == 0 then table.insert(lines, localized("agrilife_journal_dialog_empty", "Aucun événement enregistré.")) end
    setText(self.bodyText, table.concat(lines, "\n"))
end

function AgriLife.JournalDialog:onOpen()
    AgriLife.JournalDialog:superClass().onOpen(self)
    self:refreshContent()
end

function AgriLife.JournalDialog:onClickClose()
    self:close()
end

function AgriLife.JournalDialog:onClickBack(forceBack, usedMenuButton)
    if usedMenuButton then return true end
    self:close()
    return false
end
