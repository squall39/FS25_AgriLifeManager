-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 7 UI bindings.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local function setText(element, value) if element ~= nil and element.setText ~= nil then element:setText(tostring(value or "")) end end
    local function setDisabled(element, value) if element ~= nil and element.setDisabled ~= nil then element:setDisabled(value == true) end end
    local function tr(key) return g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText(key) or key end
    local function money(value) if g_i18n ~= nil and g_i18n.formatMoney ~= nil then return g_i18n:formatMoney(tonumber(value) or 0, 0, true, true) end; return string.format("%.0f", tonumber(value) or 0) end
    local function normalize(index, count) if count <= 0 then return 1 end; index = math.floor(tonumber(index) or 1); return ((index - 1) % count) + 1 end

    function AgriLife.HomeFrame:getMarketViewId()
        local views = {"commodities", "inputs", "energy", "equipment", "used", "farmland", "productions", "rentals"}
        self.marketViewIndex = normalize(self.marketViewIndex, #views)
        return views[self.marketViewIndex]
    end

    function AgriLife.HomeFrame:onClickMarketView()
        self.marketViewIndex = normalize((self.marketViewIndex or 1) + 1, 8)
        self.marketRowIndex = 1
        self.lastMarketMessage = nil
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickMarketRowPrev()
        self.marketRowIndex = math.max(1, (tonumber(self.marketRowIndex) or 1) - 1)
        self.lastMarketMessage = nil
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickMarketRowNext()
        self.marketRowIndex = (tonumber(self.marketRowIndex) or 1) + 1
        self.lastMarketMessage = nil
        self:refreshContracts()
    end

    local function selectedRow(self, snapshot, view)
        local rows = {}
        if view == "inputs" then rows = snapshot.inputMarket or {}
        elseif view == "energy" then rows = snapshot.energyMarket or {}
        elseif view == "equipment" then rows = snapshot.newEquipmentMarket or {}
        elseif view == "used" then rows = snapshot.usedEquipmentMarket or {}
        elseif view == "farmland" then rows = snapshot.farmlandMarket or {}
        elseif view == "productions" then rows = snapshot.productionEconomics or snapshot.productionMarket or {}
        elseif view == "rentals" then rows = snapshot.assetRentals or {}
        else rows = snapshot.rising or {} end
        if #rows <= 0 then self.marketRowIndex = 1; return nil, rows end
        self.marketRowIndex = normalize(self.marketRowIndex, #rows)
        return rows[self.marketRowIndex], rows
    end

    function AgriLife.HomeFrame:onClickMarketPurchase()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local market = self:getMarketModule()
        local snapshot = market ~= nil and market:getSnapshot(farmId) or nil
        if snapshot == nil then return end
        local view = self:getMarketViewId()
        local row = selectedRow(self, snapshot, view)
        local result = nil
        if view == "farmland" and row ~= nil then result = market:purchaseFarmland(farmId, row.id)
        elseif view == "productions" and row ~= nil then result = market:purchaseProduction(farmId, row.id)
        elseif view == "equipment" and row ~= nil then
            local assets = self.getAssetsModule ~= nil and self:getAssetsModule() or nil
            result = assets ~= nil and assets.purchaseNew ~= nil and assets:purchaseNew(farmId, row.xmlFilename) or nil
        elseif view == "used" and row ~= nil then
            local assets = self.getAssetsModule ~= nil and self:getAssetsModule() or nil
            result = assets ~= nil and assets.purchaseUsed ~= nil and assets:purchaseUsed(farmId, row.id or row.offerId) or nil
        end
        self.lastMarketMessage = result ~= nil and result.ok and tr("agrilife_market_purchase_ok") or tr("agrilife_market_purchase_failed")
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickMarketSell()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local market = self:getMarketModule()
        local snapshot = market ~= nil and market:getSnapshot(farmId) or nil
        if snapshot == nil then return end
        local view = self:getMarketViewId()
        local row = selectedRow(self, snapshot, view)
        local result = nil
        if view == "farmland" and row ~= nil then result = market:sellFarmland(farmId, row.id)
        elseif view == "productions" and row ~= nil then result = market:sellProduction(farmId, row.id) end
        self.lastMarketMessage = result ~= nil and result.ok and tr("agrilife_market_sale_ok") or tr("agrilife_market_sale_failed")
        self:refreshContracts()
    end

    function AgriLife.HomeFrame:onClickContractNegotiate()
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local contracts = self.getContractsModule ~= nil and self:getContractsModule() or nil
        local offer = self.contractOffers ~= nil and self.contractOffers[self.contractOfferIndex or 1] or nil
        if contracts == nil or offer == nil or contracts.negotiateOffer == nil then return end
        self.contractNegotiationIndex = normalize((tonumber(self.contractNegotiationIndex) or 0) + 1, 4)
        local stances = {"balanced", "price", "time", "volume"}
        local stance = stances[self.contractNegotiationIndex]
        local result = contracts:negotiateOffer(farmId, offer, stance)
        if result ~= nil and result.ok and result.details ~= nil and result.details.offer ~= nil then
            self.contractOffers[self.contractOfferIndex or 1] = result.details.offer
            self.lastContractsMessage = string.format(tr("agrilife_contracts7_negotiated_fmt"), tr("agrilife_contracts7_stance_" .. stance))
        else
            self.lastContractsMessage = tr("agrilife_contracts7_negotiation_failed")
        end
        self:refreshContracts()
    end

    local baseRefreshContracts = AgriLife.HomeFrame.refreshContracts
    function AgriLife.HomeFrame:refreshContracts()
        baseRefreshContracts(self)
        local farmId = self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
        local market = self:getMarketModule()
        local contracts = self.getContractsModule ~= nil and self:getContractsModule() or nil
        local marketSnapshot = market ~= nil and market.getSnapshot ~= nil and market:getSnapshot(farmId) or nil
        local contractSnapshot = contracts ~= nil and contracts.getSnapshot ~= nil and contracts:getSnapshot(farmId) or nil
        if marketSnapshot == nil then return end
        local view = self:getMarketViewId()
        local row, rows = selectedRow(self, marketSnapshot, view)
        local summary = tr("agrilife_market_empty")
        local canBuy, canSell, canRent = false, false, false
        if view == "commodities" then
            local categories = marketSnapshot.categories or {}; local commodity = categories.commodities or {}
            summary = string.format(tr("agrilife_market_world_fmt"), tonumber(commodity.index) or 1, #(marketSnapshot.rising or {}), #(marketSnapshot.falling or {}), #(marketSnapshot.marketEvents or {}))
        elseif view == "inputs" and row ~= nil then
            summary = string.format(tr("agrilife_market_input_fmt"), tostring(row.title or row.name), money((row.marketPrice or 0) * 1000), tonumber(row.multiplier) or 1)
        elseif view == "energy" and row ~= nil then
            summary = string.format(tr("agrilife_market_energy_fmt"), tostring(row.title or row.name), money((row.marketPrice or 0) * 1000), tonumber(row.multiplier) or 1)
        elseif view == "equipment" and row ~= nil then
            summary = string.format(tr("agrilife_market_equipment_fmt"), tostring(row.name or "--"), money(row.marketPrice or 0), tonumber(row.multiplier) or 1); canBuy = true
        elseif view == "used" and row ~= nil then
            summary = string.format(tr("agrilife_market_used_fmt"), tostring(row.name or "--"), money(row.price or row.marketPrice or 0), tonumber(row.condition or row.serviceScore or 0) * 100); canBuy = true
        elseif view == "farmland" and row ~= nil then
            summary = string.format(tr("agrilife_market_farmland_fmt"), tostring(row.id), tonumber(row.areaInHa) or 0, money(row.marketPrice or 0), money(row.monthlyLeaseEstimate or 0)); canBuy = true; canSell = true; canRent = true
        elseif view == "productions" and row ~= nil then
            summary = string.format(tr("agrilife_market_production7_fmt"), tostring(row.name or row.id), money(row.marketValue or 0), tonumber(row.marginIndex) or 1, tonumber(row.inputCount) or 0, tonumber(row.outputCount) or 0); canBuy = true; canSell = true; canRent = true
        elseif view == "rentals" then
            summary = string.format(tr("agrilife_market_rentals_fmt"), tonumber(marketSnapshot.activeAssetRentals) or 0, money(marketSnapshot.monthlyAssetRental or 0), money(marketSnapshot.assetRentalExposure or 0))
        end
        if #rows > 0 then summary = string.format("%d/%d | %s", self.marketRowIndex or 1, #rows, summary) end
        setText(self.marketSummaryText, summary)
        setText(self.marketViewButton, tr("agrilife_market_view_" .. view))
        setDisabled(self.marketPurchaseButton, not canBuy)
        setDisabled(self.marketSellButton, not canSell)
        setDisabled(self.marketRentButton, not canRent)
        setDisabled(self.marketRowPrevButton, #rows <= 1)
        setDisabled(self.marketRowNextButton, #rows <= 1)
        setDisabled(self.marketTerminateButton, (tonumber(marketSnapshot.activeAssetRentals) or 0) <= 0)

        local offer = self.contractOffers ~= nil and self.contractOffers[self.contractOfferIndex or 1] or nil
        setDisabled(self.contractsNegotiateButton, offer == nil or not self:canManage("contracts.manage"))
        if offer ~= nil then
            local quality = offer.qualityRequired == true and string.format(tr("agrilife_contracts7_quality_required"), tonumber(offer.qualityMinimum) or 0) or tr("agrilife_contracts7_quality_none")
            setText(self.contractsOfferTerms, string.format(tr("agrilife_contracts7_offer_meta_fmt"), tonumber(offer.volumeLiters or 0) / 1000, tonumber(offer.durationMonths) or 0, tonumber(offer.recommendedHectares) or 0, quality))
            setText(self.contractsOfferPrice, string.format(tr("agrilife_contracts7_offer_price_fmt"), money((offer.contractPrice or 0) * 1000), tostring(offer.buyerStrategy or "balanced"), tonumber(offer.buyerRelationship) or 50, tonumber(offer.negotiationScore) or 50))
        end
        if self.lastMarketMessage ~= nil then setText(self.contractsStatusText, tostring(self.lastMarketMessage))
        elseif contractSnapshot ~= nil then setText(self.contractsStatusText, string.format(tr("agrilife_contracts7_status_fmt"), tonumber(contractSnapshot.averageContractScore) or 0, tonumber(contractSnapshot.ratedContracts) or 0, tonumber(contractSnapshot.qualityContracts) or 0, tonumber(contractSnapshot.topBuyerScore) or 0)) end
    end
end
