-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.HudIconPolicy = AgriLife.HudIconPolicy or {}
local Policy = AgriLife.HudIconPolicy
Policy.VERSION = "0.9.3.16"

Policy.ICONS = {
    info = "gui/icons/info.dds",
    success = "gui/icons/success.dds",
    warning = "gui/icons/status_warning.dds",
    failure = "gui/icons/failure.dds",
    pending = "gui/icons/status_pending.dds",
    money = "gui/icons/cash.dds",
    finance = "gui/icons/finances.dds",
    percentage = "gui/icons/percentage.dds",
    contract = "gui/icons/contract.dds",
    cooperation = "gui/icons/handshake.dds",
    offer = "gui/icons/offer.dds",
    sale = "gui/icons/sale.dds",
    lease = "gui/icons/lease.dds",
    auction = "gui/icons/offer.dds",
    vehicle = "gui/icons/vehicle.dds",
    land = "gui/icons/land.dds",
    production = "gui/icons/finance.dds",
    seizure = "gui/icons/bailiff.dds",
    inspection = "gui/icons/inspect.dds",
    reputation = "gui/icons/quality_star.dds",
    supplier = "gui/icons/handshake.dds",
    morale = "gui/icons/status_good.dds",
    career = "gui/icons/quality_star.dds",
    timer = "gui/icons/timer.dds",
    engine = "gui/icons/sys_engine.dds",
    electrical = "gui/icons/sys_electrical.dds",
    hydraulic = "gui/icons/sys_hydraulic.dds",
    tyre = "gui/icons/fsk_tire.dds",
    repair = "gui/icons/fsk_repair.dds",
    diagnostic = "gui/icons/fsk_diagnostics.dds",
    oil = "gui/icons/oil.dds"
}

local function modDirectory()
    if AgriLife.Version ~= nil and tostring(AgriLife.Version.MOD_DIR or "") ~= "" then
        return tostring(AgriLife.Version.MOD_DIR)
    end
    return tostring(g_currentModDirectory or "")
end

function Policy:resolve(key, fallback)
    local relative = self.ICONS[tostring(key or "")] or self.ICONS[tostring(fallback or "")] or self.ICONS.info
    if tostring(relative or ""):sub(1, 1) == "$" then return relative end
    return modDirectory() .. tostring(relative or "")
end

function Policy:decorate(row, key, fallback)
    if type(row) ~= "table" then return row end
    row.hudIconKey = tostring(key or fallback or "info")
    row.hudIcon = self:resolve(key, fallback)
    return row
end

function Policy:getRuleSummary()
    return {
        preferHudIcons = true,
        keepTextWhenUseful = true,
        requireImmediateMeaning = true,
        requireAgriLifeVisualConsistency = true,
        decorativeIconsForbidden = true
    }
end
