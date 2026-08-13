-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.DynamicMarket6Service ~= nil then
    local Market = AgriLife.DynamicMarket6Service
    Market.SUPPLIER_CREDIT_VERSION = "0.9.3.17"

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

    local function clamp(value, minimum, maximum)
        value = num(value, minimum)
        if value < minimum then return minimum end
        if value > maximum then return maximum end
        return value
    end

    function Market:ensureSupplierCreditState(farmId)
        local state = self:ensureSupplierState(farmId)
        state.supplierInvoices = state.supplierInvoices or {}
        state.supplierNextInvoiceId = math.max(1, integer(state.supplierNextInvoiceId, 1))
        state.supplierInvoiceLastProcessedPeriodKey = integer(state.supplierInvoiceLastProcessedPeriodKey, 0)
        return state
    end

    function Market:getSupplierPaymentPolicy(farmId, supplierId)
        local benefits = self:getSupplierBenefits(farmId, supplierId)
        local days = integer(benefits.paymentTermDays, 0)
        local months = days >= 60 and 2 or (days >= 15 and 1 or 0)
        local trust = num(benefits.trust, 50)
        return {
            supplierId = supplierId,
            trust = trust,
            paymentTermDays = days,
            termPeriods = months,
            lateRate = trust >= 85 and 0.015 or (trust >= 70 and 0.025 or 0.045),
            creditAllowed = months > 0
        }
    end

    function Market:createSupplierInvoice(farmId, supplierId, amount, reference, forceImmediate)
        amount = round(math.max(0, num(amount, 0)))
        if amount <= 0 then return AgriLife.Result.ok("SUPPLIER_INVOICE_ZERO", "Aucune facture a creer") end
        local state = self:ensureSupplierCreditState(farmId)
        local policy = self:getSupplierPaymentPolicy(farmId, supplierId)
        local current = self:getPeriodKey()
        local id = string.format("SUP_%d_%06d", tonumber(farmId) or 0, state.supplierNextInvoiceId)
        state.supplierNextInvoiceId = state.supplierNextInvoiceId + 1
        local invoice = {
            id = id,
            supplierId = tostring(supplierId or "inputs"),
            amount = amount,
            principal = amount,
            paid = 0,
            lateFees = 0,
            status = "open",
            createdPeriodKey = current,
            duePeriodKey = current + (forceImmediate == true and 0 or policy.termPeriods),
            paidPeriodKey = 0,
            reference = tostring(reference or ""),
            lateRate = policy.lateRate,
            paymentTermDays = policy.paymentTermDays,
            overduePeriods = 0
        }
        table.insert(state.supplierInvoices, invoice)
        self:recordEconomy(farmId, "SUPPLIER_INVOICE_CREATED", 0, id)
        if invoice.duePeriodKey <= current then
            local payment = self:paySupplierInvoice(farmId, id)
            if payment.ok then return AgriLife.Result.ok("SUPPLIER_INVOICE_PAID", "Facture fournisseur reglee", {invoice = invoice}) end
        end
        return AgriLife.Result.ok("SUPPLIER_INVOICE_CREATED", "Facture fournisseur creee", {invoice = invoice})
    end

    function Market:findSupplierInvoice(farmId, invoiceId)
        local state = self:ensureSupplierCreditState(farmId)
        for _, invoice in ipairs(state.supplierInvoices) do
            if tostring(invoice.id) == tostring(invoiceId) then return invoice end
        end
        return nil
    end

    function Market:paySupplierInvoice(farmId, invoiceId)
        local invoice = self:findSupplierInvoice(farmId, invoiceId)
        if invoice == nil then return AgriLife.Result.fail("SUPPLIER_INVOICE_NOT_FOUND", "Facture fournisseur introuvable") end
        if invoice.status == "paid" then return AgriLife.Result.ok("SUPPLIER_INVOICE_ALREADY_PAID", "Facture deja reglee", {invoice = invoice}) end
        local due = round(math.max(0, num(invoice.principal, 0) + num(invoice.lateFees, 0) - num(invoice.paid, 0)))
        if due <= 0 then invoice.status = "paid"; return AgriLife.Result.ok("SUPPLIER_INVOICE_PAID", "Facture reglee", {invoice = invoice}) end
        local farm = self:getFarm(farmId)
        local available = farm ~= nil and math.max(0, num(farm.money, 0)) or 0
        local payment = math.min(available, due)
        if payment <= 0 or not self:addMoney(farmId, -payment) then return AgriLife.Result.fail("SUPPLIER_INVOICE_FUNDS_LOW", "Tresorerie insuffisante", {invoice = invoice, due = due}) end
        invoice.paid = round(num(invoice.paid, 0) + payment)
        self:recordEconomy(farmId, "SUPPLIER_PAYMENT", -payment, invoice.id)
        local remaining = round(math.max(0, num(invoice.principal, 0) + num(invoice.lateFees, 0) - num(invoice.paid, 0)))
        if remaining <= 0.01 then
            invoice.status = "paid"
            invoice.paidPeriodKey = self:getPeriodKey()
            self:recordSupplierTransaction(farmId, invoice.supplierId, invoice.principal, invoice.overduePeriods <= 0)
            return AgriLife.Result.ok("SUPPLIER_INVOICE_PAID", "Facture fournisseur reglee", {invoice = invoice})
        end
        invoice.status = "partial"
        return AgriLife.Result.fail("SUPPLIER_INVOICE_PARTIAL", "Paiement fournisseur partiel", {invoice = invoice, remaining = remaining})
    end

    function Market:processSupplierInvoices(farmId, periodKey)
        local state = self:ensureSupplierCreditState(farmId)
        periodKey = integer(periodKey, self:getPeriodKey())
        if state.supplierInvoiceLastProcessedPeriodKey <= 0 then state.supplierInvoiceLastProcessedPeriodKey = periodKey - 1 end
        if periodKey <= state.supplierInvoiceLastProcessedPeriodKey then return end
        for _, invoice in ipairs(state.supplierInvoices) do
            if invoice.status ~= "paid" and periodKey >= integer(invoice.duePeriodKey, periodKey) then
                local result = self:paySupplierInvoice(farmId, invoice.id)
                if result == nil or not result.ok then
                    local overdue = math.max(1, periodKey - integer(invoice.duePeriodKey, periodKey) + 1)
                    if overdue > integer(invoice.overduePeriods, 0) then
                        invoice.overduePeriods = overdue
                        local outstanding = math.max(0, num(invoice.principal, 0) + num(invoice.lateFees, 0) - num(invoice.paid, 0))
                        local fee = round(math.max(25, outstanding * clamp(invoice.lateRate, 0.005, 0.15)))
                        invoice.lateFees = round(num(invoice.lateFees, 0) + fee)
                        local relation = self:getSupplierRelation(farmId, invoice.supplierId)
                        relation.paymentIssues = integer(relation.paymentIssues, 0) + 1
                        relation.lastDelta = round(-2.5 - math.min(5, overdue * 0.75))
                        relation.trust = round(clamp(num(relation.trust, 50) + relation.lastDelta, 0, 100))
                        self:recordEconomy(farmId, "SUPPLIER_LATE_FEE", -fee, invoice.id)
                    end
                end
            end
        end
        state.supplierInvoiceLastProcessedPeriodKey = periodKey
    end

    function Market:getSupplierCreditSnapshot(farmId)
        local state = self:ensureSupplierCreditState(farmId)
        local open, overdue, totalDue = 0, 0, 0
        local rows = {}
        for _, invoice in ipairs(state.supplierInvoices) do
            if invoice.status ~= "paid" then
                open = open + 1
                if integer(invoice.overduePeriods, 0) > 0 then overdue = overdue + 1 end
                totalDue = totalDue + math.max(0, num(invoice.principal, 0) + num(invoice.lateFees, 0) - num(invoice.paid, 0))
                table.insert(rows, invoice)
            end
        end
        table.sort(rows, function(a, b)
            if integer(a.duePeriodKey, 0) == integer(b.duePeriodKey, 0) then return tostring(a.id) < tostring(b.id) end
            return integer(a.duePeriodKey, 0) < integer(b.duePeriodKey, 0)
        end)
        return {open = open, overdue = overdue, totalDue = round(totalDue), invoices = rows}
    end

    local baseProcess = Market.processPeriodForFarm
    function Market:processPeriodForFarm(farmId, periodKey)
        local result = baseProcess(self, farmId, periodKey)
        self:processSupplierInvoices(farmId, periodKey)
        return result
    end

    local baseSnapshot = Market.getSnapshot
    function Market:getSnapshot(farmId)
        local snapshot = baseSnapshot(self, farmId)
        snapshot.supplierCredit = self:getSupplierCreditSnapshot(farmId)
        return snapshot
    end

    local baseSave = Market.saveFarm
    function Market:saveFarm(xmlFile, moduleKey, farmId)
        local result = baseSave(self, xmlFile, moduleKey, farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        local state = self:ensureSupplierCreditState(farmId)
        local root = moduleKey .. ".supplierCredit"
        xmlFile:setInt(root .. "#nextInvoiceId", state.supplierNextInvoiceId)
        xmlFile:setInt(root .. "#lastProcessedPeriodKey", state.supplierInvoiceLastProcessedPeriodKey)
        for index, invoice in ipairs(state.supplierInvoices) do
            local key = string.format("%s.invoices.invoice(%d)", root, index - 1)
            for _, name in ipairs({"id", "supplierId", "status", "reference"}) do xmlFile:setString(key .. "#" .. name, tostring(invoice[name] or "")) end
            for _, name in ipairs({"createdPeriodKey", "duePeriodKey", "paidPeriodKey", "paymentTermDays", "overduePeriods"}) do xmlFile:setInt(key .. "#" .. name, integer(invoice[name], 0)) end
            for _, name in ipairs({"amount", "principal", "paid", "lateFees", "lateRate"}) do xmlFile:setFloat(key .. "#" .. name, num(invoice[name], 0)) end
        end
        return result
    end

    local baseLoad = Market.loadFarm
    function Market:loadFarm(xmlFile, moduleKey, farmId)
        local result = baseLoad(self, xmlFile, moduleKey, farmId)
        local state = self:ensureSupplierCreditState(farmId)
        if xmlFile == nil or moduleKey == nil then return result end
        local root = moduleKey .. ".supplierCredit"
        state.supplierNextInvoiceId = math.max(1, xmlFile:getInt(root .. "#nextInvoiceId", 1))
        state.supplierInvoiceLastProcessedPeriodKey = xmlFile:getInt(root .. "#lastProcessedPeriodKey", 0)
        state.supplierInvoices = {}
        if xmlFile.iterate ~= nil then
            xmlFile:iterate(root .. ".invoices.invoice", function(_, key)
                local invoice = {}
                for _, name in ipairs({"id", "supplierId", "status", "reference"}) do invoice[name] = xmlFile:getString(key .. "#" .. name, "") end
                for _, name in ipairs({"createdPeriodKey", "duePeriodKey", "paidPeriodKey", "paymentTermDays", "overduePeriods"}) do invoice[name] = xmlFile:getInt(key .. "#" .. name, 0) end
                for _, name in ipairs({"amount", "principal", "paid", "lateFees", "lateRate"}) do invoice[name] = xmlFile:getFloat(key .. "#" .. name, 0) end
                if invoice.id ~= "" then table.insert(state.supplierInvoices, invoice) end
            end)
        end
        return result
    end
end

if AgriLife.DynamicMarketModule ~= nil then
    function AgriLife.DynamicMarketModule:getSupplierCreditSnapshot(...) return self.service:getSupplierCreditSnapshot(...) end
    function AgriLife.DynamicMarketModule:createSupplierInvoice(...) return self.service:createSupplierInvoice(...) end
    function AgriLife.DynamicMarketModule:paySupplierInvoice(...) return self.service:paySupplierInvoice(...) end
end

if AgriLife.Workshop6Service ~= nil and AgriLife.DynamicMarket6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    local baseOrderPartCredit = Workshop.orderPart
    if baseOrderPartCredit ~= nil then
        function Workshop:orderPart(farmId, assetId, partFamily, qualityId, quantity, urgency, warrantyCovered, fulfilmentMode)
            local marketModule = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.market or nil
            local market = marketModule ~= nil and (marketModule.service or marketModule) or nil
            local quote = self.getPartMarketQuote ~= nil and self:getPartMarketQuote(farmId, partFamily, qualityId, urgency) or nil
            local supplierId = quote ~= nil and tostring(quote.supplierId or "parts_oem") or "parts_oem"
            local policy = market ~= nil and market.getSupplierPaymentPolicy ~= nil and market:getSupplierPaymentPolicy(farmId, supplierId) or {creditAllowed = false, paymentTermDays = 0}
            local useCredit = policy.creditAllowed == true and warrantyCovered ~= true
            local farm = self.getFarm ~= nil and self:getFarm(farmId) or nil
            local temporaryCredit = 0
            if useCredit and quote ~= nil then
                local count = math.max(1, math.floor(tonumber(quantity) or 1))
                local deliveryMode = string.upper(tostring(fulfilmentMode or self._partOrderContext or (self.getPartFulfilmentMode ~= nil and self:getPartFulfilmentMode(farmId)) or "PICKUP"))
                local deliveryFee = deliveryMode == "DELIVERY" and math.max(35, (tonumber(quote.unitPrice) or 0) * count * 0.035) or 0
                local estimated = math.max(0, (tonumber(quote.unitPrice) or 0) * count + deliveryFee)
                local available = farm ~= nil and math.max(0, tonumber(farm.money) or 0) or 0
                temporaryCredit = math.max(0, estimated - available)
                if temporaryCredit > 0 and self.addMoney ~= nil then self:addMoney(farmId, temporaryCredit) end
            end
            local previous = self._supplierCreditDeferral
            self._supplierCreditDeferral = useCredit
            local result = baseOrderPartCredit(self, farmId, assetId, partFamily, qualityId, quantity, urgency, warrantyCovered, fulfilmentMode)
            self._supplierCreditDeferral = previous
            if result ~= nil and result.ok == true and result.details ~= nil and result.details.order ~= nil and market ~= nil then
                local order = result.details.order
                local actualQuote = result.details.quote or quote or {}
                order.supplierId = tostring(actualQuote.supplierId or supplierId)
                order.paymentTermDays = tonumber(actualQuote.paymentTermDays) or tonumber(policy.paymentTermDays) or 0
                if useCredit and (tonumber(order.totalCost) or 0) > 0 then
                    local actualCost = tonumber(order.totalCost) or 0
                    -- Restore the real purchase debit first, then remove the temporary
                    -- bridge. This guarantees the farm finishes at its original cash
                    -- balance even when the final supplier quote differs from estimate.
                    if self.addMoney ~= nil then self:addMoney(farmId, actualCost) end
                    if temporaryCredit > 0 and self.addMoney ~= nil then self:addMoney(farmId, -temporaryCredit) end
                    if self.recordEconomy ~= nil then self:recordEconomy(farmId, "WORKSHOP_PARTS_CREDIT", actualCost, order.id) end
                    local invoiceResult = market:createSupplierInvoice(farmId, order.supplierId, actualCost, order.id, false)
                    if invoiceResult ~= nil and invoiceResult.details ~= nil and invoiceResult.details.invoice ~= nil then
                        order.supplierInvoiceId = invoiceResult.details.invoice.id
                    end
                elseif temporaryCredit > 0 and self.addMoney ~= nil then
                    self:addMoney(farmId, -temporaryCredit)
                end
            elseif temporaryCredit > 0 and self.addMoney ~= nil then
                self:addMoney(farmId, -temporaryCredit)
            end
            return result
        end
    end
end
