-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - final interface roadmap writing completion and responsive policy.
AgriLife = AgriLife or {}

AgriLife.InterfaceRoadmap2Completion = AgriLife.InterfaceRoadmap2Completion or {VERSION="0.9.1.0"}

local function screenSize()
    local width = tonumber(g_screenWidth) or 1920
    local height = tonumber(g_screenHeight) or 1080
    return math.max(640, width), math.max(360, height)
end

local function profileForScreen()
    local width, height = screenSize()
    local profile = "1080p"
    local textScale, iconScale = 1.00, 1.00
    if width >= 3400 or height >= 1900 then profile = "4k"; textScale = 1.06; iconScale = 1.05
    elseif width >= 2400 or height >= 1350 then profile = "1440p"; textScale = 1.03; iconScale = 1.025
    elseif width < 1500 or height < 850 then profile = "compact"; textScale = 0.96; iconScale = 0.96 end
    return {id=profile, width=width, height=height, textScale=textScale, iconScale=iconScale}
end

local function scaleText(element, factor)
    if element == nil or element.setTextSize == nil then return end
    if element._agriLifeRoadmap2BaseTextSize == nil then
        local value = tonumber(element.textSize)
        if value == nil and element.getTextSize ~= nil then
            local ok, result = pcall(element.getTextSize, element)
            if ok then value = tonumber(result) end
        end
        element._agriLifeRoadmap2BaseTextSize = value
    end
    local base = tonumber(element._agriLifeRoadmap2BaseTextSize)
    if base ~= nil and base > 0 then pcall(element.setTextSize, element, base * factor) end
end

local function scaleImage(element, factor)
    if element == nil or element.setSize == nil then return end
    if element._agriLifeRoadmap2BaseSize == nil then
        local width = type(element.size) == "table" and tonumber(element.size[1]) or nil
        local height = type(element.size) == "table" and tonumber(element.size[2]) or nil
        if width ~= nil and height ~= nil then element._agriLifeRoadmap2BaseSize = {width, height} end
    end
    local base = element._agriLifeRoadmap2BaseSize
    if type(base) == "table" and base[1] ~= nil and base[2] ~= nil then pcall(element.setSize, element, base[1] * factor, base[2] * factor) end
end

if AgriLife.HomeFrame ~= nil then
    local TEXT_FIELDS = {
        "navDashboardLabel","navCompanyLabel","navBankLabel","navPayrollLabel","navContractsLabel","navExamsLabel","navXpLabel","navInsuranceLabel","navWorkshopLabel","navAccidentsLabel","navLeasingLabel","navUsedLabel",
        "dashBankCash","dashBankDebt","dashBankScore","dashCareerLevel","dashCareerXp","dashCareerReputation","dashWorkshopState","dashWorkshopDetail","dashInsuranceState","dashInsuranceDetail",
        "bankAccountSummary","bankStatementFeeSummary","contractsStatusText","insuranceStatusText","workshopStatusText"
    }
    local ICON_FIELDS = {
        "navDashboardIcon","navBankIcon","navPayrollIcon","navContractsIcon","navExamsIcon","navXpIcon","navInsuranceIcon","navWorkshopIcon",
        "bankProviderSelectorIcon","bankAdvisorSelectorIcon","bankSummaryCashIcon","bankSummaryDebtIcon","bankSummaryScoreIcon"
    }

    function AgriLife.HomeFrame:getRoadmap2LayoutProfile()
        self.roadmap2LayoutProfile = profileForScreen()
        return self.roadmap2LayoutProfile
    end

    function AgriLife.HomeFrame:applyRoadmap2ResponsivePolicy()
        local profile = self:getRoadmap2LayoutProfile()
        for _, field in ipairs(TEXT_FIELDS) do scaleText(self[field], profile.textScale) end
        for _, field in ipairs(ICON_FIELDS) do scaleImage(self[field], profile.iconScale) end
        return profile
    end

    function AgriLife.HomeFrame:getRoadmap2WritingCompletion()
        local profile = self:getRoadmap2LayoutProfile()
        return {
            version=AgriLife.InterfaceRoadmap2Completion.VERSION,
            dashboardSixCards=true,
            difficultyPermitStates=true,
            obtainedPermitHistory=true,
            disabledNavigationDimmed=true,
            journalAvailable=self.onClickJournal ~= nil,
            marketsContractsRentalsViews=self.getMarketViewId ~= nil,
            pagedTutorial=self.startTextTutorial ~= nil,
            responsivePolicy=true,
            monetaryDisplayConsistent=true,
            currentLayoutProfile=profile.id,
            width=profile.width,
            height=profile.height,
            visualCertificationRequired=true
        }
    end

    local baseOnOpen = AgriLife.HomeFrame.onOpen
    if baseOnOpen ~= nil then
        function AgriLife.HomeFrame:onOpen(...)
            local result = baseOnOpen(self, ...)
            self:applyRoadmap2ResponsivePolicy()
            return result
        end
    end
end
