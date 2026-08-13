-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.SubscriptionManager = {}
AgriLife.SubscriptionManager.__index = AgriLife.SubscriptionManager

function AgriLife.SubscriptionManager.new()
    return setmetatable({ subscriptions = {}, deleted = false }, AgriLife.SubscriptionManager)
end

local function makeKey(ownerId, messageType, target, callback)
    return string.format("%s|%s|%s|%s", tostring(ownerId), tostring(messageType), tostring(target), tostring(callback))
end

function AgriLife.SubscriptionManager:subscribe(ownerId, messageType, target, callback)
    if self.deleted then
        return AgriLife.Result.fail("SUBSCRIPTIONS_DELETED", "Subscription manager already deleted")
    end
    if ownerId == nil or messageType == nil or target == nil or callback == nil then
        return AgriLife.Result.fail("SUBSCRIPTION_INVALID", "Missing subscription argument")
    end
    if g_messageCenter == nil or g_messageCenter.subscribe == nil then
        return AgriLife.Result.fail("MESSAGE_CENTER_UNAVAILABLE", "Message center unavailable")
    end

    local key = makeKey(ownerId, messageType, target, callback)
    if self.subscriptions[key] ~= nil then
        return AgriLife.Result.fail("SUBSCRIPTION_DUPLICATE", "Duplicate subscription refused", { ownerId = ownerId })
    end

    local ok, value = pcall(g_messageCenter.subscribe, g_messageCenter, messageType, callback, target)
    if not ok or value == false then
        return AgriLife.Result.fail("SUBSCRIPTION_ADD_FAILED", tostring(value), { ownerId = ownerId })
    end

    self.subscriptions[key] = {
        ownerId = ownerId,
        messageType = messageType,
        target = target,
        callback = callback
    }
    return AgriLife.Result.ok("SUBSCRIPTION_ADDED", "Subscription added")
end

function AgriLife.SubscriptionManager:unsubscribeOwner(ownerId)
    local removed = 0
    for key, item in pairs(self.subscriptions) do
        if item.ownerId == ownerId then
            if g_messageCenter ~= nil and g_messageCenter.unsubscribe ~= nil then
                pcall(g_messageCenter.unsubscribe, g_messageCenter, item.messageType, item.target)
            end
            self.subscriptions[key] = nil
            removed = removed + 1
        end
    end
    return AgriLife.Result.ok("OWNER_UNSUBSCRIBED", "Owner subscriptions removed", { count = removed })
end

function AgriLife.SubscriptionManager:getCount()
    local count = 0
    for _ in pairs(self.subscriptions) do
        count = count + 1
    end
    return count
end

function AgriLife.SubscriptionManager:delete()
    if self.deleted then
        return
    end
    local owners = {}
    for _, item in pairs(self.subscriptions) do
        owners[item.ownerId] = true
    end
    for ownerId in pairs(owners) do
        self:unsubscribeOwner(ownerId)
    end
    self.subscriptions = {}
    self.deleted = true
end
