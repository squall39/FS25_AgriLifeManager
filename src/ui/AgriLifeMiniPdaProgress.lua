-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.MiniPdaProgress = {}

AgriLife.MiniPdaProgress.CIRCLE_STATE = 2
AgriLife.MiniPdaProgress.ATLAS_COLUMNS = 8
AgriLife.MiniPdaProgress.ATLAS_ROWS = 8
AgriLife.MiniPdaProgress.ATLAS_CELL_SIZE = 256
AgriLife.MiniPdaProgress.ATLAS_TEXTURE_SIZE = 2048
AgriLife.MiniPdaProgress.ATLAS_FRAMES = 64
AgriLife.MiniPdaProgress.RING_GAP = 0.0065
AgriLife.MiniPdaProgress.RING_RADIUS_PAD = 0.0030
AgriLife.MiniPdaProgress.trackOverlay = nil
AgriLife.MiniPdaProgress.fillOverlay = nil
AgriLife.MiniPdaProgress.overlayLoadFailed = false
AgriLife.MiniPdaProgress.atlasUvs = nil

local unpackValues = table ~= nil and table.unpack or unpack

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

local function callNumberPair(target, methodName)
    if target == nil or target[methodName] == nil then return nil, nil end
    local ok, first, second = pcall(target[methodName], target)
    if not ok then return nil, nil end
    return tonumber(first), tonumber(second)
end

local function getVisible(ingameMap)
    if ingameMap == nil then return false end
    if ingameMap.getVisible ~= nil then
        local ok, visible = pcall(ingameMap.getVisible, ingameMap)
        if ok and visible == false then return false end
    elseif ingameMap.isVisible == false then
        return false
    end
    return ingameMap.isFullscreen ~= true
end

function AgriLife.MiniPdaProgress.getBounds()
    local hud = g_currentMission ~= nil and g_currentMission.hud or nil
    local ingameMap = hud ~= nil and hud.ingameMap or nil
    if not getVisible(ingameMap) then return nil end

    -- IngameMap builds its layouts in this order: hidden, circle, square,
    -- square-large and fullscreen. The requested ring only belongs to the
    -- circular mini-PDA and deliberately disappears in the other layouts.
    if tonumber(ingameMap.state) ~= AgriLife.MiniPdaProgress.CIRCLE_STATE then return nil end

    -- mapPos/mapSize describe the circular picture itself. The generic HUD
    -- dimensions can also include the coordinate line below the mini-PDA.
    local layout = ingameMap.layout
    if layout ~= nil
        and tonumber(layout.mapPosX) ~= nil and tonumber(layout.mapPosY) ~= nil
        and tonumber(layout.mapSizeX) ~= nil and tonumber(layout.mapSizeY) ~= nil
        and tonumber(layout.mapSizeX) > 0 and tonumber(layout.mapSizeY) > 0 then
        return {
            x = tonumber(layout.mapPosX),
            y = tonumber(layout.mapPosY),
            width = tonumber(layout.mapSizeX),
            height = tonumber(layout.mapSizeY)
        }
    end

    local x, y = callNumberPair(ingameMap, "getPosition")
    local width, height = callNumberPair(ingameMap, "getDimension")
    if width == nil and ingameMap.getWidth ~= nil then
        local ok, value = pcall(ingameMap.getWidth, ingameMap)
        if ok then width = tonumber(value) end
    end
    if height == nil and ingameMap.getHeight ~= nil then
        local ok, value = pcall(ingameMap.getHeight, ingameMap)
        if ok then height = tonumber(value) end
    end
    x = x or tonumber(ingameMap.x)
    y = y or tonumber(ingameMap.y)
    width = width or tonumber(ingameMap.width)
    height = height or tonumber(ingameMap.height)
    if x == nil or y == nil or width == nil or height == nil or width <= 0 or height <= 0 then return nil end

    return { x = x, y = y, width = width, height = height }
end

local function drawShadowedText(x, y, size, value, color, bold)
    if renderText == nil or RenderText == nil or value == nil or tostring(value) == "" then return end
    local outlineX = math.max(0.00048, size * 0.050)
    local outlineY = math.max(0.00072, size * 0.065)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextBold(bold == true)

    -- Four-sided opaque outline: the compact label stays readable over pale
    -- crops, dark foliage and asphalt without adding a floating HUD panel.
    setTextColor(0.005, 0.008, 0.006, 0.98)
    renderText(x - outlineX, y, size, tostring(value))
    renderText(x + outlineX, y, size, tostring(value))
    renderText(x, y - outlineY, size, tostring(value))
    renderText(x, y + outlineY, size, tostring(value))
    setTextColor(color[1], color[2], color[3], color[4] or 1)
    renderText(x, y, size, tostring(value))
end

local function getModDirectory()
    return AgriLife ~= nil and AgriLife.Version ~= nil and AgriLife.Version.MOD_DIR
        or AgriLifeManager ~= nil and AgriLifeManager.MOD_DIR
        or ""
end

local function getTextureFilename(relativePath)
    local baseDirectory = getModDirectory()
    if Utils ~= nil and Utils.getFilename ~= nil then return Utils.getFilename(relativePath, baseDirectory) end
    return tostring(baseDirectory):gsub("[\\/]+$", "") .. "/" .. tostring(relativePath)
end

local function loadImageOverlay(relativePath)
    if createImageOverlay == nil then return nil end
    local filename = getTextureFilename(relativePath)
    if fileExists ~= nil and not fileExists(filename) then return nil end
    local ok, overlay = pcall(createImageOverlay, filename)
    if not ok or overlay == nil or overlay == 0 then return nil end
    return overlay
end

function AgriLife.MiniPdaProgress.ensureOverlays()
    if AgriLife.MiniPdaProgress.trackOverlay ~= nil and AgriLife.MiniPdaProgress.fillOverlay ~= nil then return true end
    if AgriLife.MiniPdaProgress.overlayLoadFailed then return false end

    AgriLife.MiniPdaProgress.trackOverlay = loadImageOverlay("textures/ui/miniPdaRingTrack.dds")
    AgriLife.MiniPdaProgress.fillOverlay = loadImageOverlay("textures/ui/miniPdaRingFillAtlas.dds")
    if AgriLife.MiniPdaProgress.trackOverlay == nil or AgriLife.MiniPdaProgress.fillOverlay == nil then
        AgriLife.MiniPdaProgress.delete()
        AgriLife.MiniPdaProgress.overlayLoadFailed = true
        if AgriLife.Logger ~= nil then AgriLife.Logger.warning("UI", "Continuous mini-PDA ring textures could not be loaded") end
        return false
    end
    return true
end

local function getAtlasUvs(frameIndex)
    if GuiUtils == nil or GuiUtils.getUVs == nil then return nil end
    if AgriLife.MiniPdaProgress.atlasUvs == nil then
        AgriLife.MiniPdaProgress.atlasUvs = {}
        for index = 0, AgriLife.MiniPdaProgress.ATLAS_FRAMES - 1 do
            local column = index % AgriLife.MiniPdaProgress.ATLAS_COLUMNS
            local row = math.floor(index / AgriLife.MiniPdaProgress.ATLAS_COLUMNS)
            AgriLife.MiniPdaProgress.atlasUvs[index] = GuiUtils.getUVs({
                column * AgriLife.MiniPdaProgress.ATLAS_CELL_SIZE,
                row * AgriLife.MiniPdaProgress.ATLAS_CELL_SIZE,
                AgriLife.MiniPdaProgress.ATLAS_CELL_SIZE,
                AgriLife.MiniPdaProgress.ATLAS_CELL_SIZE
            }, {
                AgriLife.MiniPdaProgress.ATLAS_TEXTURE_SIZE,
                AgriLife.MiniPdaProgress.ATLAS_TEXTURE_SIZE
            })
        end
    end
    return AgriLife.MiniPdaProgress.atlasUvs[math.max(0, math.min(frameIndex or 0, AgriLife.MiniPdaProgress.ATLAS_FRAMES - 1))]
end

local function drawRing(bounds, progress, color)
    if not AgriLife.MiniPdaProgress.ensureOverlays() or renderOverlay == nil or setOverlayColor == nil then return false end

    local aspect = math.max(1.0, tonumber(g_screenAspectRatio) or (16 / 9))
    local radius = bounds.height * 0.5 + AgriLife.MiniPdaProgress.RING_GAP + AgriLife.MiniPdaProgress.RING_RADIUS_PAD
    local diameterY = radius * 2
    local diameterX = diameterY / aspect
    local centerX = bounds.x + bounds.width * 0.5
    local centerY = bounds.y + bounds.height * 0.5
    local x = centerX - diameterX * 0.5
    local y = centerY - diameterY * 0.5

    setOverlayColor(AgriLife.MiniPdaProgress.trackOverlay, 1, 1, 1, 1)
    renderOverlay(AgriLife.MiniPdaProgress.trackOverlay, x, y, diameterX, diameterY)

    local ratio = clamp(progress, 0, 1)
    local frameIndex = math.floor(ratio * (AgriLife.MiniPdaProgress.ATLAS_FRAMES - 1) + 0.5)
    local uvs = getAtlasUvs(frameIndex)
    if uvs ~= nil and setOverlayUVs ~= nil and unpackValues ~= nil then
        setOverlayUVs(AgriLife.MiniPdaProgress.fillOverlay, unpackValues(uvs))
    end
    setOverlayColor(AgriLife.MiniPdaProgress.fillOverlay, color[1], color[2], color[3], color[4] or 1)
    renderOverlay(AgriLife.MiniPdaProgress.fillOverlay, x, y, diameterX, diameterY)
    return true
end

function AgriLife.MiniPdaProgress.draw(options)
    options = options or {}
    local bounds = AgriLife.MiniPdaProgress.getBounds()
    if bounds == nil then return false end
    bounds = {
        x = clamp(bounds.x + (tonumber(options.offsetX) or 0), 0, math.max(0, 1 - bounds.width)),
        y = clamp(bounds.y + (tonumber(options.offsetY) or 0), 0, math.max(0, 1 - bounds.height)),
        width = bounds.width,
        height = bounds.height
    }

    local color = options.color or { 0.70, 0.88, 0.12, 1 }
    drawRing(bounds, options.progress, color)

    if renderText ~= nil and RenderText ~= nil then
        local centerX = bounds.x + bounds.width * 0.5
        local titleSize = clamp(bounds.height * 0.068, 0.0105, 0.0140)
        local detailSize = clamp(bounds.height * 0.058, 0.0095, 0.0120)
        local lineGap = bounds.height * 0.073
        local baseY = bounds.y + bounds.height + bounds.height * 0.035

        if options.status ~= nil and tostring(options.status) ~= "" then
            drawShadowedText(centerX, baseY + lineGap * 2, detailSize, options.status, { 0.96, 0.98, 0.96, 1 }, true)
        end
        if options.detail ~= nil and tostring(options.detail) ~= "" then
            drawShadowedText(centerX, baseY + lineGap, detailSize, options.detail, { 0.96, 0.98, 0.96, 1 }, true)
        end
        drawShadowedText(centerX, baseY, titleSize, options.title, color, true)

        setTextBold(false)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextColor(1, 1, 1, 1)
    end
    return true, bounds
end

function AgriLife.MiniPdaProgress.delete()
    if delete ~= nil then
        if AgriLife.MiniPdaProgress.trackOverlay ~= nil then pcall(delete, AgriLife.MiniPdaProgress.trackOverlay) end
        if AgriLife.MiniPdaProgress.fillOverlay ~= nil then pcall(delete, AgriLife.MiniPdaProgress.fillOverlay) end
    end
    AgriLife.MiniPdaProgress.trackOverlay = nil
    AgriLife.MiniPdaProgress.fillOverlay = nil
    AgriLife.MiniPdaProgress.atlasUvs = nil
end
