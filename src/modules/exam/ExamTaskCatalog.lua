-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.ExamTaskCatalog = {}
AgriLife.ExamTaskCatalog.__index = AgriLife.ExamTaskCatalog
AgriLife.ExamTaskCatalog.MIN_TASKS = 100
AgriLife.ExamTaskCatalog.TASKS_PER_EXAM = 10
AgriLife.ExamTaskCatalog.HISTORY_LIMIT = 80

local SCENARIOS = {
    { id = "cultivation", order = 1, labelKey = "agrilife_exam6_scenario_cultivation", specs = { "spec_cultivator" } },
    { id = "ploughing", order = 2, labelKey = "agrilife_exam6_scenario_ploughing", specs = { "spec_plow" } },
    { id = "sowing", order = 3, labelKey = "agrilife_exam6_scenario_sowing", specs = { "spec_sowingMachine", "spec_planter" } },
    { id = "fertilizing", order = 4, labelKey = "agrilife_exam6_scenario_fertilizing", specs = { "spec_fertilizingSowingMachine", "spec_sprayer" } },
    { id = "spraying", order = 5, labelKey = "agrilife_exam6_scenario_spraying", specs = { "spec_sprayer" } },
    { id = "mowing", order = 6, labelKey = "agrilife_exam6_scenario_mowing", specs = { "spec_mower" } },
    { id = "windrowing", order = 7, labelKey = "agrilife_exam6_scenario_windrowing", specs = { "spec_windrower" } },
    { id = "tedding", order = 8, labelKey = "agrilife_exam6_scenario_tedding", specs = { "spec_tedder" } },
    { id = "harvesting", order = 9, labelKey = "agrilife_exam6_scenario_harvesting", specs = { "spec_combine", "spec_forageHarvester" } },
    { id = "baling", order = 10, labelKey = "agrilife_exam6_scenario_baling", specs = { "spec_baler" } },
    { id = "forage", order = 11, labelKey = "agrilife_exam6_scenario_forage", specs = { "spec_forageWagon", "spec_loadingWagon" } },
    { id = "transport", order = 12, labelKey = "agrilife_exam6_scenario_transport", specs = { "spec_trailer", "spec_tensionBelts" } }
}

local PHASES = {
    { id = "vehicle", order = 1, objectiveKey = "agrilife_exam6_objective_vehicle", criterionKey = "agrilife_exam6_criterion_vehicle" },
    { id = "attach", order = 2, objectiveKey = "agrilife_exam6_objective_attach", criterionKey = "agrilife_exam6_criterion_attach" },
    { id = "route", order = 3, objectiveKey = "agrilife_exam6_objective_route", criterionKey = "agrilife_exam6_criterion_route" },
    { id = "prepare", order = 4, objectiveKey = "agrilife_exam6_objective_prepare", criterionKey = "agrilife_exam6_criterion_prepare" },
    { id = "work", order = 5, objectiveKey = "agrilife_exam6_objective_work", criterionKey = "agrilife_exam6_criterion_work" },
    { id = "secure", order = 6, objectiveKey = "agrilife_exam6_objective_secure", criterionKey = "agrilife_exam6_criterion_secure" },
    { id = "return", order = 7, objectiveKey = "agrilife_exam6_objective_return", criterionKey = "agrilife_exam6_criterion_return" },
    { id = "detach", order = 8, objectiveKey = "agrilife_exam6_objective_detach", criterionKey = "agrilife_exam6_criterion_detach" },
    { id = "park", order = 9, objectiveKey = "agrilife_exam6_objective_park", criterionKey = "agrilife_exam6_criterion_park" },
    { id = "exit", order = 10, objectiveKey = "agrilife_exam6_objective_exit", criterionKey = "agrilife_exam6_criterion_exit" }
}

local function copyArray(source)
    local result = {}
    for index, value in ipairs(source or {}) do result[index] = value end
    return result
end

local function hasAnySpec(object, specs)
    if object == nil then return false end
    for _, specName in ipairs(specs or {}) do
        if object[specName] ~= nil then return true end
    end
    return false
end

local function ownerFarmId(object)
    if object == nil then return 0 end
    if object.getOwnerFarmId ~= nil then
        local ok, value = pcall(object.getOwnerFarmId, object)
        if ok and tonumber(value) ~= nil then return tonumber(value) end
    end
    return tonumber(object.ownerFarmId) or 0
end

local function isUsableFarmObject(object, farmId)
    if object == nil or tonumber(farmId) == nil or tonumber(farmId) <= 0 then return false end
    return ownerFarmId(object) == tonumber(farmId)
end

local function makeSeed(farmId, sessionId, historyCount)
    local day = 0
    if g_currentMission ~= nil and g_currentMission.environment ~= nil then
        day = tonumber(g_currentMission.environment.currentMonotonicDay) or 0
    end
    local raw = (tonumber(farmId) or 0) * 1000003 + (tonumber(sessionId) or 0) * 9176 + day * 131 + (tonumber(historyCount) or 0) * 53 + 7919
    raw = math.floor(math.abs(raw)) % 2147483647
    if raw == 0 then raw = 1234567 end
    return raw
end

local function nextRandom(state, maxValue)
    state.value = (state.value * 48271) % 2147483647
    if maxValue == nil or maxValue <= 1 then return 1 end
    return (state.value % maxValue) + 1
end

function AgriLife.ExamTaskCatalog.new()
    local self = setmetatable({ tasks = {}, taskById = {}, scenarios = SCENARIOS, phases = PHASES }, AgriLife.ExamTaskCatalog)
    self:build()
    return self
end

function AgriLife.ExamTaskCatalog:build()
    self.tasks = {}
    self.taskById = {}
    for _, phase in ipairs(PHASES) do
        for _, scenario in ipairs(SCENARIOS) do
            local task = {
                id = string.format("EX6_%02d_%s", phase.order, string.upper(scenario.id)),
                phaseId = phase.id,
                phaseOrder = phase.order,
                scenarioId = scenario.id,
                scenarioOrder = scenario.order,
                scenarioLabelKey = scenario.labelKey,
                objectiveKey = phase.objectiveKey,
                criterionKey = phase.criterionKey,
                -- FIX4D: keep the ten stages of one exam on the same professional
                -- activity. Route/work targets are now long enough to feel like an
                -- actual agricultural qualification rather than a 20 m checklist.
                targetDistance = scenario.id == "transport" and 2500 or 800,
                targetWorkDistance = scenario.id == "transport" and 3000 or 1200,
                targetFieldPercent = 90,
                parkSeconds = 8 + (scenario.order % 5)
            }
            table.insert(self.tasks, task)
            self.taskById[task.id] = task
        end
    end
end

function AgriLife.ExamTaskCatalog:getCount()
    return #self.tasks
end

function AgriLife.ExamTaskCatalog:getTaskById(taskId)
    return self.taskById[tostring(taskId or "")]
end

function AgriLife.ExamTaskCatalog:getScenarios()
    return self.scenarios
end

function AgriLife.ExamTaskCatalog:detectFeasibleScenarios(farmId)
    local supported = {}
    local objects = nil
    if g_currentMission ~= nil and g_currentMission.vehicleSystem ~= nil then
        objects = g_currentMission.vehicleSystem.vehicles
    end
    if objects == nil and g_currentMission ~= nil then objects = g_currentMission.vehicles end

    for _, scenario in ipairs(SCENARIOS) do
        local found = false
        for _, object in pairs(objects or {}) do
            if isUsableFarmObject(object, farmId) and hasAnySpec(object, scenario.specs) then
                found = true
                break
            end
        end
        if found then table.insert(supported, scenario.id) end
    end
    return supported
end

function AgriLife.ExamTaskCatalog:buildPlan(farmId, sessionId, history, feasibleScenarioIds)
    if self:getCount() < self.MIN_TASKS then
        return AgriLife.Result.fail("EXAM_CATALOG_TOO_SMALL", "Exam catalog must contain at least 100 tasks", { count = self:getCount() })
    end

    local feasible = copyArray(feasibleScenarioIds)
    if #feasible == 0 then
        return AgriLife.Result.fail("EXAM_NO_FEASIBLE_SCENARIO", "No compatible owned equipment was found for the exam")
    end

    -- A professional exam is one coherent job from start to finish. The previous
    -- generator changed activity at every stage (attach a seeder, drive a trailer,
    -- prepare a combine...), which was technically varied but not believable.
    -- Select one feasible activity, then run its ten phases in order.
    local historyCountByScenario = {}
    for _, taskId in ipairs(history or {}) do
        local oldTask = self.taskById[tostring(taskId)]
        if oldTask ~= nil then
            historyCountByScenario[oldTask.scenarioId] = (historyCountByScenario[oldTask.scenarioId] or 0) + 1
        end
    end

    local rng = { value = makeSeed(farmId, sessionId, #(history or {})) }
    local candidates = {}
    for _, scenarioId in ipairs(feasible) do
        local scenario = nil
        for _, item in ipairs(SCENARIOS) do
            if item.id == scenarioId then scenario = item break end
        end
        if scenario ~= nil then
            table.insert(candidates, {
                scenario = scenario,
                score = historyCountByScenario[scenario.id] or 0,
                tie = nextRandom(rng, 100000)
            })
        end
    end

    table.sort(candidates, function(a, b)
        if a.score == b.score then return a.tie < b.tie end
        return a.score < b.score
    end)
    if #candidates == 0 then
        return AgriLife.Result.fail("EXAM_PLAN_INCOMPLETE", "Unable to select a feasible professional activity")
    end

    local selected = candidates[1].scenario
    local plan = {}
    for _, phase in ipairs(PHASES) do
        local taskId = string.format("EX6_%02d_%s", phase.order, string.upper(selected.id))
        local task = self.taskById[taskId]
        if task == nil then
            return AgriLife.Result.fail("EXAM_PLAN_INCOMPLETE", "Unable to build the complete ten-stage professional exam", { taskId = taskId })
        end
        table.insert(plan, task)
    end

    if #plan ~= self.TASKS_PER_EXAM then
        return AgriLife.Result.fail("EXAM_PLAN_SIZE_INVALID", "Generated exam plan does not contain exactly ten tasks", { count = #plan })
    end

    return AgriLife.Result.ok("EXAM_PLAN_READY", "Professional exam plan generated", {
        plan = plan,
        distinctScenarioCount = 1,
        scenarioId = selected.id
    })
end

function AgriLife.ExamTaskCatalog:appendHistory(history, plan)
    history = history or {}
    for _, task in ipairs(plan or {}) do table.insert(history, task.id) end
    while #history > self.HISTORY_LIMIT do table.remove(history, 1) end
    return history
end
