-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Career6Hud = {}
AgriLife.Career6Hud.__index = AgriLife.Career6Hud

AgriLife.Career6Hud.XP_COLOR = { 0.70, 0.88, 0.12, 1.00 }

local function text(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local value = g_i18n:getText(key)
        if value ~= nil and value ~= key then return value end
    end
    return fallback or key
end

local function isGuiOpen()
    if g_gui == nil then return false end
    if g_gui.currentGui ~= nil then return true end
    if g_gui.currentGuiName ~= nil and tostring(g_gui.currentGuiName) ~= "" then return true end
    return false
end

function AgriLife.Career6Hud.new(core, service)
    return setmetatable({
        core = core,
        service = service,
        drawable = nil,
        installed = false,
        starOverlay = nil,
        starOverlayFailed = false,
        lastStarsBySpecialty = {},
        starPulseUntil = 0,
        pulsedStarLevel = 0
    }, AgriLife.Career6Hud)
end

function AgriLife.Career6Hud:getStarOverlay()
    if self.starOverlay ~= nil then return self.starOverlay end
    if self.starOverlayFailed or Overlay == nil or Overlay.new == nil then return nil end

    local baseDirectory = AgriLife ~= nil and AgriLife.Version ~= nil and AgriLife.Version.MOD_DIR
        or AgriLifeManager ~= nil and AgriLifeManager.MOD_DIR
        or ""
    local filename = tostring(baseDirectory):gsub("[\\/]+$", "") .. "/gui/icons/star_filled.dds"
    if Utils ~= nil and Utils.getFilename ~= nil then filename = Utils.getFilename("gui/icons/star_filled.dds", baseDirectory) end
    if fileExists ~= nil and not fileExists(filename) then
        self.starOverlayFailed = true
        if AgriLife.Logger ~= nil then AgriLife.Logger.warning("Career", "Career star texture not found: %s", tostring(filename)) end
        return nil
    end
    local ok, overlay = pcall(Overlay.new, filename, 0, 0, 0.01, 0.01)
    if not ok or overlay == nil then
        self.starOverlayFailed = true
        if AgriLife.Logger ~= nil then AgriLife.Logger.warning("Career", "Career star overlay could not be created: %s", tostring(filename)) end
        return nil
    end
    self.starOverlay = overlay
    return overlay
end

function AgriLife.Career6Hud:drawStarBadge(bounds, specialtyId, stars)
    stars = math.max(0, math.min(AgriLife.Career6Service ~= nil and AgriLife.Career6Service.MAX_STARS or 10, math.floor(tonumber(stars) or 0)))
    specialtyId = tostring(specialtyId or "")
    local previousStars = self.lastStarsBySpecialty[specialtyId]
    if previousStars ~= nil and stars > previousStars then
        self.starPulseUntil = (tonumber(g_time) or 0) + 2200
        self.pulsedStarLevel = stars
    end
    self.lastStarsBySpecialty[specialtyId] = stars
    if stars <= 0 or bounds == nil then return end

    local overlay = self:getStarOverlay()
    if overlay == nil then return end
    local now = tonumber(g_time) or 0
    local aspect = math.max(1.0, tonumber(g_screenAspectRatio) or (16 / 9))
    local baseIconH = bounds.height * 0.060
    local baseIconW = baseIconH / aspect
    local gap = bounds.width * 0.010
    local rowWidth = baseIconW * stars + gap * math.max(0, stars - 1)
    local rowX = bounds.x + (bounds.width - rowWidth) * 0.5
    local centerY = bounds.y + bounds.height * 0.785

    for index = 1, stars do
        local pulse = 1
        if index == self.pulsedStarLevel and now < self.starPulseUntil then
            pulse = 1 + math.abs(math.sin((self.starPulseUntil - now) / 150)) * 0.28
        end
        local iconH = baseIconH * pulse
        local iconW = baseIconW * pulse
        local centerX = rowX + (index - 1) * (baseIconW + gap) + baseIconW * 0.5
        local iconX = centerX - iconW * 0.5
        local iconY = centerY - iconH * 0.5
        if overlay.setPosition ~= nil then overlay:setPosition(iconX, iconY) else overlay.x, overlay.y = iconX, iconY end
        if overlay.setDimension ~= nil then overlay:setDimension(iconW, iconH) else overlay.width, overlay.height = iconW, iconH end
        if overlay.setColor ~= nil then overlay:setColor(1, 1, 1, 1) end
        overlay:render()
    end
end

function AgriLife.Career6Hud:getActivity()
    if self.core == nil or self.core.context == nil or self.service == nil then return nil end
    local farmId = tonumber(self.core.context:getFarmId()) or 0
    if farmId <= 0 then return nil end
    local profileId = self.service:resolveProfileId(farmId, nil, g_currentMission ~= nil and g_currentMission.controlledVehicle or nil)
    if profileId == nil then return nil end
    return self.service:getActivitySnapshot(farmId, profileId)
end

function AgriLife.Career6Hud:isExamHudActive()
    local registry = self.core ~= nil and self.core.registry or nil
    local examModule = registry ~= nil and registry.instances ~= nil and (registry.instances.exams or registry.instances.exam) or nil
    local examService = examModule ~= nil and examModule.service or nil
    if examService == nil or examService.getSnapshot == nil or self.core == nil or self.core.context == nil then return false end
    local farmId = tonumber(self.core.context:getFarmId()) or 0
    local ok, snapshot = pcall(examService.getSnapshot, examService, farmId)
    return ok and snapshot ~= nil and snapshot.examRunning == true
end

function AgriLife.Career6Hud:draw()
    if renderText == nil or RenderText == nil or isGuiOpen() or self:isExamHudActive() then return end
    local activity = self:getActivity()
    if activity == nil or AgriLife.MiniPdaProgress == nil then return end

    local label = text(activity.labelKey, tostring(activity.specialtyId))
    local detail
    local status = string.format("%s : %d XP", text("agrilife_career6_totalXp", "XP totale"), tonumber(activity.xp) or 0)
    if activity.nextXP == nil then
        detail = text("agrilife_career6_specialty_max", "Niveau maximum")
    else
        local floorXP = tonumber(activity.floorXP) or 0
        local nextXP = tonumber(activity.nextXP) or floorXP
        local currentStepXP = math.max(0, (tonumber(activity.xp) or 0) - floorXP)
        local stepTargetXP = math.max(1, nextXP - floorXP)
        detail = string.format("%d / %d XP  -  %d%%", currentStepXP, stepTargetXP, tonumber(activity.progress) or 0)
    end
    local drawn, bounds = AgriLife.MiniPdaProgress.draw({
        progress = math.max(0, math.min(100, tonumber(activity.progress) or 0)) / 100,
        color = self.XP_COLOR,
        title = label,
        detail = detail,
        status = status
    })
    if drawn then self:drawStarBadge(bounds, activity.specialtyId, activity.stars) end
end

function AgriLife.Career6Hud:install()
    if self.installed then return AgriLife.Result.ok("CAREER_HUD_ALREADY_INSTALLED", "Career HUD already installed") end
    if g_currentMission == nil or g_currentMission.addDrawable == nil then
        return AgriLife.Result.fail("CAREER_HUD_RUNTIME_MISSING", "Mission drawable API unavailable")
    end
    self.drawable = { draw = function() self:draw() end }
    local ok, result = pcall(g_currentMission.addDrawable, g_currentMission, self.drawable)
    if not ok or result == false then
        self.drawable = nil
        return AgriLife.Result.fail("CAREER_HUD_INSTALL_FAILED", tostring(result))
    end
    self.installed = true
    return AgriLife.Result.ok("CAREER_HUD_INSTALLED", "Contextual Career XP mini-PDA HUD installed")
end

function AgriLife.Career6Hud:uninstall()
    if g_currentMission ~= nil and self.drawable ~= nil and g_currentMission.removeDrawable ~= nil then
        pcall(g_currentMission.removeDrawable, g_currentMission, self.drawable)
    end
    self.drawable = nil
    self.installed = false
    self.lastStarsBySpecialty = {}
    self.starPulseUntil = 0
    self.pulsedStarLevel = 0
end

function AgriLife.Career6Hud:delete()
    self:uninstall()
    if self.starOverlay ~= nil and self.starOverlay.delete ~= nil then pcall(self.starOverlay.delete, self.starOverlay) end
    if AgriLife.MiniPdaProgress ~= nil and AgriLife.MiniPdaProgress.delete ~= nil then AgriLife.MiniPdaProgress.delete() end
    self.starOverlay = nil
    self.starOverlayFailed = false
    self.service = nil
    self.core = nil
end
