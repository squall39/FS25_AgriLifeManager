-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.DynamicMarket6Service ~= nil then
    local Market = AgriLife.DynamicMarket6Service
    Market.AUCTION_COMPLETION_VERSION = "0.9.3.17"

    local function num(value, fallback)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return fallback or 0 end
        return value
    end

    local function integer(value, fallback)
        return math.floor(num(value, fallback or 0))
    end

    local function round(value)
        return math.floor(num(value, 0) * 100 + 0.5) / 100
    end

    function Market:isAuctionAssetAlreadyListed(viewFarmId, assetType, assetId)
        for _, state in pairs(self.farms or {}) do
            local auctions = state ~= nil and state.auctions or nil
            for _, listing in ipairs(auctions ~= nil and auctions.listings or {}) do
                if (listing.status == "open" or listing.status == "transfer_pending") and tostring(listing.assetType) == tostring(assetType) and tostring(listing.assetId) == tostring(assetId) then return true end
            end
        end
        return false
    end

    function Market:getSeizureCandidates(viewFarmId, seed)
        local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
        local legal = instances ~= nil and instances.legal ~= nil and instances.legal.service or nil
        local workshop = instances ~= nil and instances.workshop ~= nil and instances.workshop.service or nil
        if legal == nil then return {} end
        self:discoverRuntimeContent(false)
        local candidates = {}
        local farmIds = self.core ~= nil and self.core.context ~= nil and self.core.context.getFarmIds ~= nil and self.core.context:getFarmIds() or {}
        for _, sourceFarmId in ipairs(farmIds) do
            local snapshot = legal.getSnapshot ~= nil and legal:getSnapshot(sourceFarmId) or nil
            if snapshot ~= nil and tostring(snapshot.stage or "") == "seizure" then
                if workshop ~= nil and workshop.getState ~= nil then
                    local state = workshop:getState(sourceFarmId, false)
                    for assetId, vehicle in pairs(state ~= nil and state.vehicles or {}) do
                        if not self:isAuctionAssetAlreadyListed(viewFarmId, "equipment", assetId) then
                            local runtime = workshop.findRuntimeVehicle ~= nil and workshop:findRuntimeVehicle(sourceFarmId, assetId) or nil
                            table.insert(candidates, {
                                assetType = "equipment",
                                sourceType = "seizure",
                                sourceFarmId = sourceFarmId,
                                assetId = tostring(assetId),
                                assetName = tostring(vehicle.name or "Materiel saisi"),
                                xmlFilename = runtime ~= nil and tostring(runtime.configFileName or runtime.xmlFilename or "") or "",
                                marketValue = math.max(1000, tonumber(vehicle.value) or 10000),
                                reserveFactor = 0.42 + self:auctionRandom(seed + #candidates * 17) * 0.22,
                                durationPeriods = 1,
                                randomSeed = seed + #candidates * 29
                            })
                        end
                    end
                end
                for _, row in ipairs(self.content.farmlands or {}) do
                    if self:getFarmlandOwner(row.id) == tonumber(sourceFarmId) and not self:isAuctionAssetAlreadyListed(viewFarmId, "farmland", row.id) then
                        table.insert(candidates, {
                            assetType = "farmland", sourceType = "seizure", sourceFarmId = sourceFarmId, assetId = tostring(row.id),
                            assetName = string.format("Parcelle %s saisie", tostring(row.id)), marketValue = math.max(1000, tonumber(row.price) or 10000),
                            reserveFactor = 0.48 + self:auctionRandom(seed + #candidates * 19) * 0.20, durationPeriods = 1, randomSeed = seed + #candidates * 31
                        })
                    end
                end
                for _, row in ipairs(self.content.productions or {}) do
                    if self:getProductionOwner(row.id) == tonumber(sourceFarmId) and not self:isAuctionAssetAlreadyListed(viewFarmId, "production", row.id) then
                        table.insert(candidates, {
                            assetType = "production", sourceType = "seizure", sourceFarmId = sourceFarmId, assetId = tostring(row.id),
                            assetName = tostring(row.name or "Usine saisie"), marketValue = math.max(5000, tonumber(row.price) or 50000),
                            reserveFactor = 0.46 + self:auctionRandom(seed + #candidates * 23) * 0.22, durationPeriods = 1, randomSeed = seed + #candidates * 37
                        })
                    end
                end
            end
        end
        return candidates
    end

    function Market:getSeizureCandidate(viewFarmId, seed)
        local candidates = self:getSeizureCandidates(viewFarmId, seed)
        if #candidates == 0 then return nil end
        table.sort(candidates, function(a, b)
            if tonumber(a.sourceFarmId) == tonumber(b.sourceFarmId) then
                if tostring(a.assetType) == tostring(b.assetType) then return tostring(a.assetId) < tostring(b.assetId) end
                return tostring(a.assetType) < tostring(b.assetType)
            end
            return tonumber(a.sourceFarmId) < tonumber(b.sourceFarmId)
        end)
        local index = math.floor(self:auctionRandom(seed + 71) * #candidates) + 1
        return candidates[math.max(1, math.min(#candidates, index))]
    end

    function Market:restoreAuctionAssetToSource(listing)
        local sourceFarmId = integer(listing ~= nil and listing.sourceFarmId, 0)
        if sourceFarmId <= 0 or listing == nil then return true end
        local kind = tostring(listing.assetType or "")
        if kind == "equipment" then
            local currentFarmId = integer(listing.currentBidderFarmId, 0)
            if currentFarmId <= 0 then return true end
            local instances = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances or nil
            local contracts = instances ~= nil and instances.commercialContracts ~= nil and instances.commercialContracts.service or nil
            if contracts ~= nil and contracts.transferInterFarmVehicle ~= nil then return contracts:transferInterFarmVehicle(listing.assetId, currentFarmId, sourceFarmId) end
            return false, "vehicle rollback API unavailable"
        end
        if kind == "farmland" then return self:setFarmlandOwner(tonumber(listing.assetId), sourceFarmId) end
        if kind == "production" then return self:setProductionOwner(tostring(listing.assetId), sourceFarmId) end
        return true
    end

    function Market:settleAuction(farmId, listing)
        if listing == nil then return false end
        if listing.transferCompleted == true and listing.status == "sold" then return true end
        local finalBid = round(math.max(0, num(listing.currentBid, 0)))
        if finalBid + 0.01 < math.max(0, num(listing.reservePrice, 0)) then
            listing.status = "unsold"
            self:recordAuctionHistory(farmId, listing, "unsold")
            return true
        end
        local winnerFarmId = integer(listing.currentBidderFarmId, 0)
        if winnerFarmId > 0 and listing.paymentDebited ~= true then
            local farm = self:getFarm(winnerFarmId)
            if farm == nil or num(farm.money, 0) + 0.01 < finalBid then
                listing.status = "payment_failed"
                listing.settlementError = "winner funds unavailable"
                self:recordAuctionHistory(farmId, listing, "payment_failed")
                return false
            end
            if not self:addMoney(winnerFarmId, -finalBid) then
                listing.status = "payment_failed"
                listing.settlementError = "winner debit failed"
                self:recordAuctionHistory(farmId, listing, "payment_failed")
                return false
            end
            listing.paymentDebited = true
            self:recordEconomy(winnerFarmId, "AUCTION_PURCHASE", -finalBid, listing.id)
        end
        if listing.assetTransferred ~= true then
            local transferred, reason = self:transferAuctionAsset(listing, winnerFarmId)
            if not transferred then
                if winnerFarmId > 0 and listing.paymentDebited == true then
                    self:addMoney(winnerFarmId, finalBid)
                    self:recordEconomy(winnerFarmId, "AUCTION_PURCHASE_REFUND", finalBid, listing.id)
                    listing.paymentDebited = false
                end
                listing.status = "transfer_pending"
                listing.settlementError = tostring(reason or "transfer failed")
                return false
            end
            listing.assetTransferred = true
        end
        if listing.sellerPaid ~= true then
            if not self:applyAuctionSellerProceeds(listing, finalBid) then
                local restored = self:restoreAuctionAssetToSource(listing)
                if restored and winnerFarmId > 0 and listing.paymentDebited == true then
                    self:addMoney(winnerFarmId, finalBid)
                    self:recordEconomy(winnerFarmId, "AUCTION_PURCHASE_REFUND", finalBid, listing.id)
                    listing.paymentDebited = false
                    listing.assetTransferred = false
                end
                listing.status = "transfer_pending"
                listing.settlementError = "seller settlement failed"
                return false
            end
            listing.sellerPaid = true
        end
        listing.status = "sold"
        listing.transferCompleted = true
        listing.settlementError = ""
        self:recordAuctionHistory(farmId, listing, "sold")
        return true
    end

    local baseSave = Market.saveFarm
    function Market:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSave(self, xmlFile, moduleKey, farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        local auctions = self:getAuctionState(farmId, true)
        local root = moduleKey .. ".auctions"
        for index, listing in ipairs(auctions.listings or {}) do
            local key = string.format("%s.listings.listing(%d)", root, index - 1)
            xmlFile:setBool(key .. "#paymentDebited", listing.paymentDebited == true)
            xmlFile:setBool(key .. "#assetTransferred", listing.assetTransferred == true)
            xmlFile:setBool(key .. "#sellerPaid", listing.sellerPaid == true)
        end
        return result
    end

    local baseLoad = Market.loadFarm
    function Market:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoad(self, xmlFile, moduleKey, farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        local auctions = self:getAuctionState(farmId, true)
        local root = moduleKey .. ".auctions"
        for index, listing in ipairs(auctions.listings or {}) do
            local key = string.format("%s.listings.listing(%d)", root, index - 1)
            listing.paymentDebited = xmlFile:getBool(key .. "#paymentDebited", false)
            listing.assetTransferred = xmlFile:getBool(key .. "#assetTransferred", false)
            listing.sellerPaid = xmlFile:getBool(key .. "#sellerPaid", false)
        end
        return result
    end
end
