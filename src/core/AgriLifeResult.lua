-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.Result = {}

function AgriLife.Result.ok(code, message, details)
    return {
        ok = true,
        code = code or "OK",
        message = message or "",
        details = details
    }
end

function AgriLife.Result.fail(code, message, details)
    return {
        ok = false,
        code = code or "ERROR",
        message = message or "",
        details = details
    }
end

function AgriLife.Result.fromPcall(success, value, code)
    if success then
        if type(value) == "table" and value.ok ~= nil then
            return value
        end
        if value == false then
            return AgriLife.Result.fail(code or "CALL_FAILED", "Operation returned false")
        end
        return AgriLife.Result.ok(code or "CALL_OK", "Operation completed", value)
    end
    return AgriLife.Result.fail(code or "CALL_FAILED", tostring(value))
end

function AgriLife.Result.normalize(value, successCode, failureCode)
    if type(value) == "table" and value.ok ~= nil then
        return value
    end
    if value == false then
        return AgriLife.Result.fail(failureCode or "CALL_FAILED", "Operation returned false")
    end
    return AgriLife.Result.ok(successCode or "CALL_OK", "Operation completed", value)
end
