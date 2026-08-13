-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.Phone6 = AgriLife.Phone6 or {}
local Phone = AgriLife.Phone6
Phone.VERSION = "0.9.3.18"
Phone.DEVICE_PROFILE = "modern_fullscreen_smartphone"
Phone.PER_PLAYER = true
Phone.KEEP_AGRILIFE_IN_S_MENU = true
Phone.APPS = {
    {id="dashboard", page="dashboard", labelKey="agrilife_ui6_dashboard", icon="info"},
    {id="bank", page="bank", labelKey="agrilife_ui6_bank", icon="finance"},
    {id="enterprise", page="enterprise", labelKey="agrilife_ui6_enterprise", icon="career"},
    {id="careerQualifications", page="careerQualifications", labelKey="agrilife_ui6_career_qualifications", icon="career"},
    {id="administration", page="administration", labelKey="agrilife_ui6_administration", icon="inspection"},
    {id="contractsMarkets", page="contractsMarkets", labelKey="agrilife_ui6_contracts_markets", icon="contract"},
    {id="workshop", page="workshop", labelKey="agrilife_ui6_workshop", icon="repair"}
}

function Phone:getApps(core, farmId)
    local rows = {}
    local policy = AgriLife.HudIconPolicy
    for _, app in ipairs(self.APPS) do
        table.insert(rows, {
            id=app.id,
            page=app.page,
            labelKey=app.labelKey,
            icon=policy ~= nil and policy.resolve ~= nil and policy:resolve(app.icon, "info") or "",
            enabled=true,
            farmId=tonumber(farmId) or 0
        })
    end
    return rows
end

function Phone:openApp(core, appId)
    local frame = core ~= nil and core.ui ~= nil and core.ui.frame or nil
    if frame == nil or frame.showPage == nil then return AgriLife.Result.fail("PHONE_UI_UNAVAILABLE", "AgriLife interface unavailable") end
    local requested = tostring(appId or "dashboard")
    for _, app in ipairs(self.APPS) do
        if app.id == requested then
            frame:showPage(app.page)
            return AgriLife.Result.ok("PHONE_APP_OPENED", "Application ouverte", {appId=app.id, page=app.page})
        end
    end
    return AgriLife.Result.fail("PHONE_APP_UNKNOWN", "Application inconnue")
end

function Phone:getSnapshot(core, farmId, profileId)
    return {
        version=self.VERSION,
        deviceProfile=self.DEVICE_PROFILE,
        perPlayer=true,
        profileId=tostring(profileId or ""),
        farmId=tonumber(farmId) or 0,
        apps=self:getApps(core, farmId),
        keepAgriLifeInSMenu=true
    }
end
