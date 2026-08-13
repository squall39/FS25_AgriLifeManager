-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Logger = {
    LEVELS = { ERROR = 1, WARNING = 2, INFO = 3, DEBUG = 4, TRACE = 5 },
    level = 3
}

function AgriLife.Logger.normalizeLevel(level)
    local value = string.upper(tostring(level or "INFO"))
    if AgriLife.Logger.LEVELS[value] == nil then
        value = "INFO"
    end
    return value
end

function AgriLife.Logger.setLevel(level)
    local normalized = AgriLife.Logger.normalizeLevel(level)
    AgriLife.Logger.level = AgriLife.Logger.LEVELS[normalized]
    return normalized
end

function AgriLife.Logger.isEnabled(level)
    local normalized = AgriLife.Logger.normalizeLevel(level)
    return AgriLife.Logger.LEVELS[normalized] <= AgriLife.Logger.level
end

function AgriLife.Logger.write(component, level, message, ...)
    local normalized = AgriLife.Logger.normalizeLevel(level)
    if not AgriLife.Logger.isEnabled(normalized) then
        return
    end

    local text = tostring(message or "")
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        text = ok and formatted or (text .. " [format error]")
    end

    print(string.format("[AgriLife][%s][%s] %s", tostring(component or "Core"), normalized, text))
end

function AgriLife.Logger.error(component, message, ...)
    AgriLife.Logger.write(component, "ERROR", message, ...)
end

function AgriLife.Logger.warning(component, message, ...)
    AgriLife.Logger.write(component, "WARNING", message, ...)
end

function AgriLife.Logger.info(component, message, ...)
    AgriLife.Logger.write(component, "INFO", message, ...)
end

function AgriLife.Logger.debug(component, message, ...)
    AgriLife.Logger.write(component, "DEBUG", message, ...)
end

function AgriLife.Logger.trace(component, message, ...)
    AgriLife.Logger.write(component, "TRACE", message, ...)
end
