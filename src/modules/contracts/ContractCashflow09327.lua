-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.CommercialContracts6Service ~= nil then
    local Contracts = AgriLife.CommercialContracts6Service
    Contracts.CASHFLOW_VERSION = "0.9.3.27"
    Contracts.SCHEMA_VERSION = math.max(6, tonumber(Contracts.SCHEMA_VERSION) or 5)
    Contracts.REGULAR_MONTHLY_FILL_TYPES = {MILK=true, GOATMILK=true, SHEEPMILK=true, EGGS=true, EGG=true, WOOL=true}

    local function num(value, default)
        value = tonumber(value)
        if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end
        return value
    end
    local function round(value) return math.floor(num(value,0)*100+0.5)/100 end
    local function clamp(value,a,b) return math.max(a,math.min(b,num(value,a))) end

    function Contracts:getCompanyStructureSnapshot(farmId)
        local company = self.core ~= nil and self.core.registry ~= nil and self.core.registry.instances ~= nil and self.core.registry.instances.company or nil
        return company ~= nil and company.getSnapshot ~= nil and company:getSnapshot(farmId) or nil
    end

    function Contracts:getContractPaymentProfile(offer)
        local fillName = string.upper(tostring(offer ~= nil and offer.fillTypeName or ""))
        if self.REGULAR_MONTHLY_FILL_TYPES[fillName] == true then return "monthly", 0, 0 end
        if tostring(offer ~= nil and offer.buyerType or "") == "cooperative" then return "monthly", 0, 0 end
        if tostring(offer ~= nil and offer.buyerType or "") == "industrial" or tostring(offer ~= nil and offer.contractClass or "") == "production_supply" then
            return "due", 1, 0.05
        end
        return "immediate", 0, 0
    end

    function Contracts:getEffectiveContractUnitPrice(contract, currentUnitPrice)
        if contract == nil then return math.max(0,num(currentUnitPrice,0)) end
        if tostring(contract.priceMode or "fixed") == "indexed" then
            return round(math.max(0,num(currentUnitPrice,0))*clamp(contract.indexFactor,0.90,1.20))
        end
        return math.max(0,num(contract.contractPrice,0))
    end

    function Contracts:ensureReceivableState(contract)
        if contract == nil then return end
        contract.paymentMode = tostring(contract.paymentMode or "immediate")
        contract.paymentDelayMonths = math.max(0,math.floor(num(contract.paymentDelayMonths,0)))
        contract.advanceRate = clamp(contract.advanceRate,0,0.25)
        contract.advancePaid = math.max(0,num(contract.advancePaid,0))
        contract.advanceRemaining = math.max(0,num(contract.advanceRemaining,contract.advancePaid))
        contract.receivableDue = math.max(0,num(contract.receivableDue,0))
        contract.receivablePaid = math.max(0,num(contract.receivablePaid,0))
        contract.receivableDuePeriodKey = math.max(0,math.floor(num(contract.receivableDuePeriodKey,0)))
        contract.deferredSalesReversed = math.max(0,num(contract.deferredSalesReversed,0))
        contract.lastSettlementPeriodKey = math.max(0,math.floor(num(contract.lastSettlementPeriodKey,0)))
    end

    local baseBuild = Contracts.buildOpportunities
    function Contracts:buildOpportunities(farmId)
        local result = baseBuild(self,farmId)
        if result == nil or result.ok ~= true or result.details == nil then return result end
        local company = self:getCompanyStructureSnapshot(farmId)
        local cooperativeFactor = company ~= nil and company.cooperativeMember == true and 1.015 or 1.0
        for _,offer in ipairs(result.details.offers or {}) do
            local mode,delay,advance = self:getContractPaymentProfile(offer)
            offer.paymentMode = mode
            offer.paymentDelayMonths = delay
            offer.advanceRate = advance
            if cooperativeFactor > 1 and tostring(offer.buyerType or "") == "cooperative" then
                offer.contractPrice = round(math.max(0,num(offer.contractPrice,0))*cooperativeFactor)
                offer.cooperativeMemberBonus = cooperativeFactor-1
            end
        end
        return result
    end

    local baseAccept = Contracts.acceptOffer
    function Contracts:acceptOffer(farmId,offer,managerProfileId)
        local result = baseAccept(self,farmId,offer,managerProfileId)
        if result == nil or result.ok ~= true or result.details == nil then return result end
        local state=self:getFarmState(farmId,true);local contractId=tostring(result.details.contractId or "")
        for _,contract in ipairs(state.contracts or {}) do
            if tostring(contract.id)==contractId then
                contract.paymentMode=tostring(offer.paymentMode or "immediate")
                contract.paymentDelayMonths=math.max(0,math.floor(num(offer.paymentDelayMonths,0)))
                contract.advanceRate=clamp(offer.advanceRate,0,0.25)
                self:ensureReceivableState(contract)
                local estimatedValue=math.max(0,num(contract.volumeLiters,0)*num(contract.contractPrice,0))
                local advance=round(estimatedValue*contract.advanceRate)
                if advance>0 and self:addCompanyMoney(farmId,advance) then
                    contract.advancePaid=advance;contract.advanceRemaining=advance
                    self:recordEconomy(farmId,"CONTRACT_ADVANCE",advance,contract.id)
                else
                    contract.advancePaid=0;contract.advanceRemaining=0
                end
                result.details.paymentMode=contract.paymentMode;result.details.paymentDelayMonths=contract.paymentDelayMonths;result.details.advancePaid=contract.advancePaid
                break
            end
        end
        return result
    end

    local baseRecordDelivery = Contracts.recordDelivery
    function Contracts:recordDelivery(farmId,station,fillTypeIndex,liters,currentUnitPrice)
        local stationId=self.stationByObject[station] or self:getStationId(station,0)
        local before=self:getMatchingContract(farmId,stationId,fillTypeIndex)
        local beforeDelivered=before~=nil and num(before.deliveredLiters,0) or 0
        local effectivePrice=before~=nil and self:getEffectiveContractUnitPrice(before,currentUnitPrice) or 0
        baseRecordDelivery(self,farmId,station,fillTypeIndex,liters,currentUnitPrice)
        if before==nil then return end
        self:ensureReceivableState(before)
        if before.paymentMode=="immediate" then return end
        local applied=math.max(0,num(before.deliveredLiters,0)-beforeDelivered)
        if applied<=0 then return end
        local gross=round(applied*effectivePrice)
        if gross<=0 then return end
        -- Vanilla FS25 pays the sale immediately. The contract layer has also
        -- applied its price differential. Reverse the full contract sale now,
        -- then settle the receivable according to the signed payment terms.
        if not self:addCompanyMoney(farmId,-gross) then
            before.paymentMode="immediate"
            before.cashflowFallback=true
            return
        end
        self:recordEconomy(farmId,"CONTRACT_DEFERRED_REVERSAL",-gross,before.id)
        before.deferredSalesReversed=round(before.deferredSalesReversed+gross)
        local advanceApplied=math.min(before.advanceRemaining,gross)
        before.advanceRemaining=round(math.max(0,before.advanceRemaining-advanceApplied))
        local due=round(math.max(0,gross-advanceApplied))
        before.receivableDue=round(before.receivableDue+due)
        local currentPeriod=self:getPeriodKey()
        if before.paymentMode=="monthly" then before.receivableDuePeriodKey=math.max(before.receivableDuePeriodKey,currentPeriod+1)
        else before.receivableDuePeriodKey=math.max(before.receivableDuePeriodKey,currentPeriod+math.max(1,before.paymentDelayMonths)) end
    end

    function Contracts:settleContractReceivable(farmId,contract,periodKey)
        self:ensureReceivableState(contract)
        local due=math.max(0,num(contract.receivableDue,0))
        if due<=0.01 or periodKey<math.max(0,num(contract.receivableDuePeriodKey,0)) then return 0 end
        if not self:addCompanyMoney(farmId,due) then return 0 end
        contract.receivableDue=0
        contract.receivablePaid=round(contract.receivablePaid+due)
        contract.lastSettlementPeriodKey=periodKey
        contract.receivableDuePeriodKey=0
        self:recordEconomy(farmId,"CONTRACT_RECEIVABLE_PAYMENT",due,contract.id)
        return due
    end

    local baseProcess = Contracts.processPeriodForFarm
    function Contracts:processPeriodForFarm(farmId,periodKey)
        baseProcess(self,farmId,periodKey)
        local state=self:getFarmState(farmId,false);if state==nil then return end
        periodKey=math.max(1,math.floor(num(periodKey,self:getPeriodKey())))
        for _,contract in ipairs(state.contracts or {}) do self:settleContractReceivable(farmId,contract,periodKey) end
    end

    local baseSnapshot = Contracts.getSnapshot
    function Contracts:getSnapshot(farmId)
        local snapshot=baseSnapshot(self,farmId) or {}
        local state=self:getFarmState(farmId,true);local due,paid,advances=0,0,0
        for _,contract in ipairs(state.contracts or {}) do self:ensureReceivableState(contract);due=due+contract.receivableDue;paid=paid+contract.receivablePaid;advances=advances+contract.advancePaid end
        snapshot.receivablesDue=round(due);snapshot.receivablesPaid=round(paid);snapshot.advancesPaid=round(advances)
        return snapshot
    end

    local baseSave = Contracts.saveFarm
    function Contracts:saveFarm(xmlFile,moduleKey,farmId)
        local result=baseSave(self,xmlFile,moduleKey,farmId);if result==nil or result.ok==false or xmlFile==nil or moduleKey==nil then return result end
        local state=self:getFarmState(farmId,true)
        for index,contract in ipairs(state.contracts or {}) do self:ensureReceivableState(contract);local key=string.format("%s.contracts.contract(%d)",moduleKey,index-1);xmlFile:setString(key.."#paymentMode",contract.paymentMode);xmlFile:setInt(key.."#paymentDelayMonths",contract.paymentDelayMonths);xmlFile:setFloat(key.."#advanceRate",contract.advanceRate);xmlFile:setFloat(key.."#advancePaid",contract.advancePaid);xmlFile:setFloat(key.."#advanceRemaining",contract.advanceRemaining);xmlFile:setFloat(key.."#receivableDue",contract.receivableDue);xmlFile:setFloat(key.."#receivablePaid",contract.receivablePaid);xmlFile:setInt(key.."#receivableDuePeriodKey",contract.receivableDuePeriodKey);xmlFile:setFloat(key.."#deferredSalesReversed",contract.deferredSalesReversed);xmlFile:setInt(key.."#lastSettlementPeriodKey",contract.lastSettlementPeriodKey) end
        return result
    end

    local baseLoad = Contracts.loadFarm
    function Contracts:loadFarm(xmlFile,moduleKey,farmId)
        local result=baseLoad(self,xmlFile,moduleKey,farmId);if result==nil or result.ok==false then return result end
        local state=self:getFarmState(farmId,true)
        if xmlFile~=nil and moduleKey~=nil and xmlFile.iterate~=nil then
            local metadata={};xmlFile:iterate(moduleKey..".contracts.contract",function(_,key)table.insert(metadata,{paymentMode=xmlFile:getString(key.."#paymentMode","immediate"),paymentDelayMonths=xmlFile:getInt(key.."#paymentDelayMonths",0),advanceRate=xmlFile:getFloat(key.."#advanceRate",0),advancePaid=xmlFile:getFloat(key.."#advancePaid",0),advanceRemaining=xmlFile:getFloat(key.."#advanceRemaining",0),receivableDue=xmlFile:getFloat(key.."#receivableDue",0),receivablePaid=xmlFile:getFloat(key.."#receivablePaid",0),receivableDuePeriodKey=xmlFile:getInt(key.."#receivableDuePeriodKey",0),deferredSalesReversed=xmlFile:getFloat(key.."#deferredSalesReversed",0),lastSettlementPeriodKey=xmlFile:getInt(key.."#lastSettlementPeriodKey",0)})end)
            for index,contract in ipairs(state.contracts or {}) do local meta=metadata[index] or{};for key,value in pairs(meta)do contract[key]=value end;self:ensureReceivableState(contract) end
        end
        return result
    end

    -- ETA is a real activity: service-oriented inter-farm contracts pay a
    -- modest professional premium when the contractor has declared ETA.
    if Contracts.calculateInterFarmSettlement ~= nil then
        local baseInterFarmSettlement=Contracts.calculateInterFarmSettlement
        function Contracts:calculateInterFarmSettlement(offer)
            local moneyValue,productValue=baseInterFarmSettlement(self,offer)
            local kind=tostring(offer~=nil and offer.contractType or "")
            if moneyValue>0 and (kind=="field_work" or kind=="harvest_help" or kind=="transport" or kind=="service") then
                local company=self:getCompanyStructureSnapshot(offer.contractorFarmId)
                if company~=nil and company.etaActive==true then moneyValue=round(moneyValue*1.04) end
            end
            return moneyValue,productValue
        end
    end
end
