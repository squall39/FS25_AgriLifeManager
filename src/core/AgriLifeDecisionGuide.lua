-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.DecisionGuide = AgriLife.DecisionGuide or {}
AgriLife.DecisionGuide.VERSION = "0.9.3.25"

local function tr(key)
    if key == nil or key == "" then return "" end
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local value = g_i18n:getText(key)
        if value ~= nil and value ~= key then return tostring(value) end
    end
    return tostring(key)
end

local function addLine(lines, value)
    value = tostring(value or "")
    if value ~= "" then table.insert(lines, value) end
end

-- Builds a compact explanation for a consequential player choice.
-- Modules provide localized text or already formatted values. The guide only
-- imposes a common structure so the player understands the decision before
-- validating it. It never recommends which option is best.
function AgriLife.DecisionGuide.build(data)
    data = type(data) == "table" and data or {}
    local lines = {}

    addLine(lines, data.title)
    addLine(lines, data.summary)

    if type(data.effects) == "table" and #data.effects > 0 then
        addLine(lines, "")
        addLine(lines, tr("agrilife_decision_effects"))
        for _, value in ipairs(data.effects) do
            value = tostring(value or "")
            if value ~= "" then addLine(lines, "- " .. value) end
        end
    end

    if tostring(data.reversibility or "") ~= "" then
        addLine(lines, "")
        addLine(lines, tr("agrilife_decision_reversibility") .. " " .. tostring(data.reversibility))
    end

    if tostring(data.difficulty or "") ~= "" then
        addLine(lines, tr("agrilife_decision_difficulty") .. " " .. tostring(data.difficulty))
    end

    if data.confirmQuestion ~= nil then
        addLine(lines, "")
        addLine(lines, tostring(data.confirmQuestion))
    end

    return table.concat(lines, "\n")
end

function AgriLife.DecisionGuide.localize(key)
    return tr(key)
end
