-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Version = {
    MOD = "0.9.3.1",
    SAVE_SCHEMA = 4,
    SETTINGS_SCHEMA = 2,
    DISPLAY_NAME = "AgriLife Manager",
    SAVE_FILE = "AgriLifeManager.xml",
    MOD_NAME = g_currentModName or "FS25_AgriLifeManager",
    SETTINGS_NAMESPACE = "FS25_AgriLifeManager",
    MOD_DIR = g_currentModDirectory or ""
}

function AgriLife.Version.getDisplayVersion()
    return AgriLife.Version.MOD
end
