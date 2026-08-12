-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - startup tutorial and FS25 Assistance roadmap completion.
AgriLife = AgriLife or {}

AgriLife.TutorialRoadmapCompletion = AgriLife.TutorialRoadmapCompletion or {}
AgriLife.TutorialRoadmapCompletion.VERSION = "0.9.1.0"
AgriLife.TutorialRoadmapCompletion.PAGE_COUNT = 13

local function localized(key)
    if g_i18n == nil or g_i18n.getText == nil then return tostring(key or "") end
    local value = g_i18n:getText(key)
    if value == nil or value == key then return tostring(key or "") end
    return value
end

local function setText(element, value)
    if element ~= nil and element.setText ~= nil then element:setText(tostring(value or "")) end
end

if AgriLife.HomeFrame ~= nil then
    function AgriLife.HomeFrame:getTextTutorialPages()
        local pages = {}
        if self.textTutorialMigrationMode == true then
            for i=1,4 do
                pages[i] = localized(string.format("agrilife_migration_page_%d", i))
            end
            return pages
        end

        local pageCount = AgriLife.TutorialRoadmapCompletion.PAGE_COUNT
        local pageFormat = localized("agrilife_tutorial_page_fmt")
        for i=1,pageCount do
            local title = localized(string.format("agrilife_tutorial_topic_%02d_title", i))
            local body = localized(string.format("agrilife_tutorial_topic_%02d_body", i))
            pages[i] = string.format(pageFormat, i, pageCount, title, body)
        end
        return pages
    end

    local baseRefreshTutorialOverlay = AgriLife.HomeFrame.refreshTutorialOverlay
    function AgriLife.HomeFrame:refreshTutorialOverlay(farmId, snapshot)
        if baseRefreshTutorialOverlay ~= nil then baseRefreshTutorialOverlay(self, farmId, snapshot) end

        snapshot = snapshot or (self.getEconomyModule ~= nil and self:getEconomyModule() ~= nil and self:getEconomyModule():getSnapshot(farmId) or nil)
        if snapshot == nil or snapshot.tutorialEnabled ~= true or snapshot.tutorialCompleted == true then return end

        local step = tostring(snapshot.tutorialStep or "mode")
        if step == "mode" then
            setText(self.tutorialBodyText, localized("agrilife_tutorial_topic_02_body"))
            setText(self.tutorialChecklistText, localized("agrilife_tutorial_mode_instruction"))
        elseif step == "company" then
            -- This state validates the administrative start. Company creation is
            -- not mandatory in the current 0.9.1.0 Easy/Normal/Hard policies.
            setText(self.tutorialBodyText, localized("agrilife_tutorial_topic_03_body"))
        elseif step == "finish" then
            setText(self.tutorialBodyText, localized("agrilife_tutorial_topic_13_body"))
        end
    end
end
