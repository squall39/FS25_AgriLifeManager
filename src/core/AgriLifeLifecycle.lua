-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Lifecycle = {}
AgriLife.Lifecycle.__index = AgriLife.Lifecycle

AgriLife.Lifecycle.State = {
    NEW = "NEW",
    BOOTSTRAPPING = "BOOTSTRAPPING",
    WAITING_RUNTIME = "WAITING_RUNTIME",
    LOADING_SETTINGS = "LOADING_SETTINGS",
    LOADING_SAVE = "LOADING_SAVE",
    MOUNTING_UI = "MOUNTING_UI",
    RUNNING = "RUNNING",
    SAVING = "SAVING",
    DEGRADED = "DEGRADED",
    STOPPING = "STOPPING",
    STOPPED = "STOPPED",
    FAILED = "FAILED"
}

local transitions = {
    NEW = { BOOTSTRAPPING = true, FAILED = true },
    BOOTSTRAPPING = { WAITING_RUNTIME = true, LOADING_SETTINGS = true, FAILED = true, STOPPING = true },
    WAITING_RUNTIME = { LOADING_SETTINGS = true, FAILED = true, STOPPING = true },
    LOADING_SETTINGS = { LOADING_SAVE = true, FAILED = true, STOPPING = true },
    LOADING_SAVE = { MOUNTING_UI = true, DEGRADED = true, FAILED = true, STOPPING = true },
    MOUNTING_UI = { RUNNING = true, DEGRADED = true, FAILED = true, STOPPING = true },
    RUNNING = { SAVING = true, DEGRADED = true, STOPPING = true, FAILED = true },
    SAVING = { RUNNING = true, DEGRADED = true, FAILED = true, STOPPING = true },
    DEGRADED = { SAVING = true, RUNNING = true, STOPPING = true, FAILED = true },
    FAILED = { STOPPING = true, STOPPED = true },
    STOPPING = { STOPPED = true },
    STOPPED = {}
}

function AgriLife.Lifecycle.new()
    return setmetatable({
        state = AgriLife.Lifecycle.State.NEW,
        previousState = nil,
        lastReason = nil
    }, AgriLife.Lifecycle)
end

function AgriLife.Lifecycle:getState()
    return self.state
end

function AgriLife.Lifecycle:is(state)
    return self.state == state
end

function AgriLife.Lifecycle:canTransition(nextState)
    return transitions[self.state] ~= nil and transitions[self.state][nextState] == true
end

function AgriLife.Lifecycle:transition(nextState, reason)
    if nextState == self.state then
        return AgriLife.Result.ok("STATE_UNCHANGED", "Lifecycle already in " .. tostring(nextState))
    end

    if not self:canTransition(nextState) then
        AgriLife.Logger.warning("Lifecycle", "Rejected transition %s -> %s", tostring(self.state), tostring(nextState))
        return AgriLife.Result.fail("INVALID_STATE_TRANSITION", string.format("%s -> %s", tostring(self.state), tostring(nextState)))
    end

    self.previousState = self.state
    self.state = nextState
    self.lastReason = reason
    AgriLife.Logger.info("Lifecycle", "%s -> %s%s", tostring(self.previousState), tostring(nextState), reason ~= nil and (" (" .. tostring(reason) .. ")") or "")
    return AgriLife.Result.ok("STATE_CHANGED", "Lifecycle transition completed")
end
