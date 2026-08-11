-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 7 negotiation synchronization.
AgriLife = AgriLife or {}

if Class ~= nil and Event ~= nil and InitEventClass ~= nil then
    AgriLife.CommercialContractsRoadmap7NegotiationEvent = {}
    local CommercialContractsRoadmap7NegotiationEvent_mt = Class(AgriLife.CommercialContractsRoadmap7NegotiationEvent, Event)
    InitEventClass(AgriLife.CommercialContractsRoadmap7NegotiationEvent, "AgriLifeCommercialContractsRoadmap7NegotiationEvent")

    local function module()
        return g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil and g_agriLifeCore.registry.instances.commercialContracts or nil
    end

    local function authorize(connection, farmId)
        local people = g_agriLifeCore ~= nil and g_agriLifeCore.registry ~= nil and g_agriLifeCore.registry.instances ~= nil and g_agriLifeCore.registry.instances.people or nil
        if people == nil or people.service == nil then return false end
        if connection == nil and people.service.authorizeLocal ~= nil then return select(1, people.service:authorizeLocal(farmId, "contracts.manage")) end
        if connection ~= nil and people.service.authorizeConnection ~= nil then return select(1, people.service:authorizeConnection(connection, farmId, "contracts.manage")) end
        return false
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent.emptyNew()
        return Event.new(CommercialContractsRoadmap7NegotiationEvent_mt)
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent.new(farmId, offerId, stance)
        local self = AgriLife.CommercialContractsRoadmap7NegotiationEvent.emptyNew()
        self.farmId = tonumber(farmId) or 0
        self.offerId = tostring(offerId or "")
        self.stance = tostring(stance or "balanced")
        return self
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent:writeStream(streamId, connection)
        streamWriteInt32(streamId, self.farmId)
        streamWriteString(streamId, self.offerId)
        streamWriteString(streamId, self.stance)
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent:readStream(streamId, connection)
        self.farmId = streamReadInt32(streamId)
        self.offerId = streamReadString(streamId)
        self.stance = streamReadString(streamId)
        self:run(connection)
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent:run(connection)
        if connection ~= nil and connection.getIsServer ~= nil and connection:getIsServer() then return end
        if not authorize(connection, self.farmId) then return end
        local contracts = module()
        if contracts ~= nil and contracts.service ~= nil and contracts.service.setNegotiationStance ~= nil then contracts.service:setNegotiationStance(self.farmId, self.offerId, self.stance) end
    end

    function AgriLife.CommercialContractsRoadmap7NegotiationEvent.send(farmId, offerId, stance)
        local contracts = module()
        if contracts == nil or contracts.service == nil then return false end
        if g_server ~= nil then
            if not authorize(nil, farmId) then return false end
            local result = contracts.service:setNegotiationStance(farmId, offerId, stance)
            return result ~= nil and result.ok == true
        end
        if g_client ~= nil and g_client.getServerConnection ~= nil then
            g_client:getServerConnection():sendEvent(AgriLife.CommercialContractsRoadmap7NegotiationEvent.new(farmId, offerId, stance))
            return true
        end
        return false
    end
end

if AgriLife.CommercialContractsModule ~= nil then
    local baseNegotiateOffer = AgriLife.CommercialContractsModule.negotiateOffer
    function AgriLife.CommercialContractsModule:negotiateOffer(farmId, offer, stance)
        local result = baseNegotiateOffer(self, farmId, offer, stance)
        if result ~= nil and result.ok and AgriLife.CommercialContractsRoadmap7NegotiationEvent ~= nil and AgriLife.CommercialContractsRoadmap7NegotiationEvent.send ~= nil then
            AgriLife.CommercialContractsRoadmap7NegotiationEvent.send(farmId, offer ~= nil and offer.id or "", stance)
        end
        return result
    end
end
