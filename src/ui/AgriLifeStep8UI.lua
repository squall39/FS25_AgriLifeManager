-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager - Roadmap step 8 UI bindings.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local VIEWS={"FLEET","DIAGNOSTIC","PARTS","JOBS","COMPLIANCE","DEALER"}
    local PROVIDERS={"DEALER","INTERNAL"}
    local QUALITIES={"OEM","AFTERMARKET","REMANUFACTURED","USED"}
    local URGENCIES={"STANDARD","PRIORITY","EXPRESS"}
    local function setText(element,value) if element~=nil and element.setText~=nil then element:setText(tostring(value or "")) end end
    local function setDisabled(element,value) if element~=nil and element.setDisabled~=nil then element:setDisabled(value==true) end end
    local function setVisible(element,value) if element~=nil and element.setVisible~=nil then element:setVisible(value==true) end end
    local function tr(key) return g_i18n~=nil and g_i18n.getText~=nil and g_i18n:getText(key) or key end
    local function money(value) if g_i18n~=nil and g_i18n.formatMoney~=nil then return g_i18n:formatMoney(tonumber(value)or 0,0,true,true) end;return string.format("%.0f",tonumber(value)or 0) end
    local function normalize(index,count) if count<=0 then return 1 end;index=math.floor(tonumber(index)or 1);return ((index-1)%count)+1 end
    local function join(rows,sep) return #rows>0 and table.concat(rows,sep or " | ") or "--" end

    function AgriLife.HomeFrame:getWorkshop8Options()
        self.workshop8ProviderIndex=normalize(self.workshop8ProviderIndex,#PROVIDERS);self.workshop8QualityIndex=normalize(self.workshop8QualityIndex,#QUALITIES);self.workshop8UrgencyIndex=normalize(self.workshop8UrgencyIndex,#URGENCIES)
        return PROVIDERS[self.workshop8ProviderIndex],QUALITIES[self.workshop8QualityIndex],URGENCIES[self.workshop8UrgencyIndex]
    end

    function AgriLife.HomeFrame:getWorkshop8View()
        self.workshop8ViewIndex=normalize(self.workshop8ViewIndex,#VIEWS);return VIEWS[self.workshop8ViewIndex]
    end

    function AgriLife.HomeFrame:onClickWorkshop8View() self.workshop8ViewIndex=normalize((self.workshop8ViewIndex or 1)+1,#VIEWS);self.workshop8RowIndex=1;self.lastWorkshopMessage=nil;self:refreshWorkshop() end
    function AgriLife.HomeFrame:onClickWorkshop8Provider() self.workshop8ProviderIndex=normalize((self.workshop8ProviderIndex or 1)+1,#PROVIDERS);self:refreshWorkshop() end
    function AgriLife.HomeFrame:onClickWorkshop8Quality() self.workshop8QualityIndex=normalize((self.workshop8QualityIndex or 1)+1,#QUALITIES);self:refreshWorkshop() end
    function AgriLife.HomeFrame:onClickWorkshop8Urgency() self.workshop8UrgencyIndex=normalize((self.workshop8UrgencyIndex or 1)+1,#URGENCIES);self:refreshWorkshop() end
    function AgriLife.HomeFrame:onClickWorkshop8Prev() self.workshop8RowIndex=math.max(1,(tonumber(self.workshop8RowIndex)or 1)-1);self:refreshWorkshop() end
    function AgriLife.HomeFrame:onClickWorkshop8Next() self.workshop8RowIndex=(tonumber(self.workshop8RowIndex)or 1)+1;self:refreshWorkshop() end

    function AgriLife.HomeFrame:getWorkshop8Employees(farmId)
        local payroll=self.getPayrollModule~=nil and self:getPayrollModule() or nil;local snapshot=payroll~=nil and payroll.getSnapshot~=nil and payroll:getSnapshot(farmId) or nil;local rows={}
        for _,employee in ipairs(snapshot~=nil and snapshot.employees or {}) do if employee.active==true and tostring(employee.role or "")~="owner" and tostring(employee.employmentStatus or "")~="TERMINATED" then table.insert(rows,employee) end end
        table.sort(rows,function(a,b)return tostring(a.name or a.profileId)<tostring(b.name or b.profileId) end);return rows
    end

    function AgriLife.HomeFrame:getWorkshop8Mechanic(farmId)
        local rows=self:getWorkshop8Employees(farmId);if #rows<=0 then self.workshop8MechanicIndex=1;return nil,rows end;self.workshop8MechanicIndex=normalize(self.workshop8MechanicIndex,#rows);return rows[self.workshop8MechanicIndex],rows
    end
    function AgriLife.HomeFrame:onClickWorkshop8Mechanic() local farmId=self.core.context:getFarmId();local _,rows=self:getWorkshop8Mechanic(farmId);if #rows>0 then self.workshop8MechanicIndex=normalize((self.workshop8MechanicIndex or 1)+1,#rows) end;self:refreshWorkshop() end

    local baseRunWorkshopAction=AgriLife.HomeFrame.runWorkshopAction
    function AgriLife.HomeFrame:runWorkshopAction(action)
        local workshop=self:getWorkshopModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0;local snapshot=workshop~=nil and workshop:getSnapshot(farmId) or nil;local vehicle=self:getWorkshopSelection(snapshot)
        if workshop==nil or vehicle==nil or not self:canManage("workshop.manage") then return baseRunWorkshopAction(self,action) end
        local provider,quality,urgency=self:getWorkshop8Options();local mechanic=self:getWorkshop8Mechanic(farmId);local profileId=provider=="INTERNAL" and (mechanic~=nil and mechanic.profileId or self:getLocalPayrollProfileId(farmId)) or self:getLocalPayrollProfileId(farmId);local result=nil
        if action=="diagnose" then result=workshop:diagnose(farmId,vehicle.assetId,profileId,"STANDARD")
        elseif action=="service" then result=workshop:startAnnualReview(farmId,vehicle.assetId,provider,quality,profileId,urgency)
        elseif action=="repair" then result=workshop:startRepair(farmId,vehicle.assetId,provider,quality,profileId,urgency)
        elseif action=="tyres" then result=workshop:startTyreReplacement(farmId,vehicle.assetId,provider,quality,profileId,urgency)
        else return baseRunWorkshopAction(self,action) end
        self.lastWorkshopMessage=result~=nil and result.message or tr("agrilife_workshop8_action_unavailable");self:refreshWorkshop()
    end

    local function selectedVehicle(self,snapshot) return self:getWorkshopSelection(snapshot) end
    local function selectRow(self,rows) if #rows<=0 then self.workshop8RowIndex=1;return nil end;self.workshop8RowIndex=normalize(self.workshop8RowIndex,#rows);return rows[self.workshop8RowIndex] end

    function AgriLife.HomeFrame:onClickWorkshop8Action()
        local workshop=self:getWorkshopModule();local farmId=self.core.context:getFarmId();local snapshot=workshop~=nil and workshop:getSnapshot(farmId) or nil;local vehicle=selectedVehicle(self,snapshot);if workshop==nil or vehicle==nil then return end
        local view=self:getWorkshop8View();local provider,quality,urgency=self:getWorkshop8Options();local mechanic=self:getWorkshop8Mechanic(farmId);local profileId=provider=="INTERNAL" and (mechanic~=nil and mechanic.profileId or self:getLocalPayrollProfileId(farmId)) or self:getLocalPayrollProfileId(farmId);local result=nil
        if view=="DIAGNOSTIC" then result=workshop:startFullDiagnostic(farmId,vehicle.assetId,provider,profileId)
        elseif view=="PARTS" then local row=selectRow(self,snapshot.partsMarket or {});if row~=nil then local mode=workshop.getPartFulfilmentMode~=nil and workshop:getPartFulfilmentMode(farmId) or "PICKUP";result=workshop:orderPart(farmId,vehicle.assetId,row.partFamily,row.qualityId,1,urgency,false,provider=="DEALER" and "DEALER" or mode) end
        elseif view=="JOBS" then local row=selectRow(self,snapshot.workshopJobs or {});if row~=nil then result=workshop:fileWorkshopInsuranceClaim(farmId,row.id) end
        elseif view=="COMPLIANCE" then result=workshop:startAnnualReview(farmId,vehicle.assetId,provider,quality,profileId,urgency)
        elseif view=="DEALER" then local recalls={};for _,recall in ipairs(snapshot.dealer~=nil and snapshot.dealer.activeRecalls or {}) do if tostring(recall.assetId)==tostring(vehicle.assetId) then table.insert(recalls,recall) end end;local row=selectRow(self,recalls);if row~=nil then result=workshop:startDealerRecall(farmId,row.id,profileId,urgency) end
        end
        if result~=nil then self.lastWorkshopMessage=result.message end;self:refreshWorkshop()
    end

    function AgriLife.HomeFrame:onClickWorkshop8Action2()
        local workshop=self:getWorkshopModule();local farmId=self.core.context:getFarmId();local snapshot=workshop~=nil and workshop:getSnapshot(farmId) or nil;local vehicle=selectedVehicle(self,snapshot);if workshop==nil or vehicle==nil then return end
        local view=self:getWorkshop8View();local provider=self:getWorkshop8Options();local mechanic=self:getWorkshop8Mechanic(farmId);local profileId=provider=="INTERNAL" and (mechanic~=nil and mechanic.profileId or self:getLocalPayrollProfileId(farmId)) or self:getLocalPayrollProfileId(farmId);local result=nil
        if view=="DIAGNOSTIC" then local continuity=workshop:getContinuityOptions(farmId,vehicle.assetId);if continuity~=nil and continuity.canRequestRecovery==true then result=workshop:requestRecovery(farmId,vehicle.assetId,"EXPRESS",profileId,provider=="INTERNAL" and "INTERNAL" or "DEALER") end
        elseif view=="JOBS" then local row=selectRow(self,snapshot.workshopJobs or {});if row~=nil and workshop.getDealerLoanerOffer81~=nil then local offer=workshop:getDealerLoanerOffer81(farmId,row.id);if offer~=nil and offer.active==true and offer.loaner~=nil then result=workshop:returnDealerLoaner81(farmId,offer.loaner.id,false) elseif offer~=nil and offer.available==true then result=workshop:requestDealerLoaner81(farmId,row.id) end end
        elseif view=="COMPLIANCE" then result=workshop:startTechnicalInspection(farmId,vehicle.assetId,provider,profileId,vehicle.counterInspectionRequired==true) end
        if result~=nil then self.lastWorkshopMessage=result.message end;self:refreshWorkshop()
    end

    local baseRefreshWorkshop=AgriLife.HomeFrame.refreshWorkshop
    function AgriLife.HomeFrame:refreshWorkshop()
        baseRefreshWorkshop(self)
        local workshop=self:getWorkshopModule();local farmId=self.core~=nil and self.core.context~=nil and self.core.context:getFarmId() or 0;local snapshot=workshop~=nil and workshop:getSnapshot(farmId) or nil;if snapshot==nil then return end
        local vehicle=selectedVehicle(self,snapshot);local provider,quality,urgency=self:getWorkshop8Options();local mechanic,mechanics=self:getWorkshop8Mechanic(farmId);local profileId=provider=="INTERNAL" and (mechanic~=nil and mechanic.profileId or self:getLocalPayrollProfileId(farmId)) or self:getLocalPayrollProfileId(farmId);local view=self:getWorkshop8View()
        setText(self.workshop8ProviderButton,tr("agrilife_workshop8_provider_"..string.lower(provider)));setText(self.workshop8QualityButton,tr("agrilife_workshop8_quality_"..string.lower(quality)));setText(self.workshop8UrgencyButton,tr("agrilife_workshop8_urgency_"..string.lower(urgency)));setText(self.workshop8MechanicButton,mechanic~=nil and string.format(tr("agrilife_workshop8_mechanic_fmt"),tostring(mechanic.name or mechanic.profileId)) or tr("agrilife_workshop8_no_mechanic"));setDisabled(self.workshop8MechanicButton,#mechanics<=1);setText(self.workshop8ViewButton,tr("agrilife_workshop8_view_"..string.lower(view)))
        setText(self.workshopSummaryValue,string.format(tr("agrilife_workshop8_summary_fmt"),snapshot.vehicleCount or 0,snapshot.activeWorkshopJobs or 0,snapshot.waitingParts or 0,snapshot.annualReviewsDue or 0,snapshot.technicalInspectionsDue or 0))
        if vehicle~=nil then
            local faults=vehicle.activeFaults or {};local authority=tostring(vehicle.externalMechanicalAuthority or "AGRILIFE");setText(self.workshopVehicleState,string.format(tr("agrilife_workshop8_vehicle_fmt"),tostring(vehicle.assetKind or "equipment"),(vehicle.condition or 0)*100,#faults,tostring(vehicle.technicalInspectionStatus or "VALID"),authority,(tonumber(vehicle.maxSafeSpeedKph)or 0)))
        end
        local overlay=view~="FLEET";setVisible(self.workshop8Overlay,overlay);setVisible(self.workshopVehiclePanel,not overlay);setVisible(self.workshopUsedPanel,not overlay);if not overlay then return end
        local title,detail=tr("agrilife_workshop8_view_"..string.lower(view)),tr("agrilife_workshop8_empty");local rows={};local canPrevNext=false;local action="";local action2="";local actionEnabled=false;local action2Enabled=false
        if view=="DIAGNOSTIC" and vehicle~=nil then
            local report=workshop:getDiagnosticReport(farmId,vehicle.assetId,"STANDARD") or {};local parts={};for _,fault in ipairs(report.faults or {}) do table.insert(parts,string.format("%s S%d [%s]",tostring(fault.id),tonumber(fault.stage)or 1,tostring(fault.systemId))) end;local continuity=workshop:getContinuityOptions(farmId,vehicle.assetId) or {};detail=string.format(tr("agrilife_workshop8_diagnostic_fmt"),tostring(report.authority or "AGRILIFE"),#(report.systems or {}),#(report.faults or {}),join(parts,", ")).."\n"..string.format(tr("agrilife_workshop8_continuity_fmt"),tonumber(continuity.waitMinutes)or 0,#(continuity.alternatives or {}));if workshop.getRepairTimeComparison81~=nil and #(report.faults or {})>0 then local comparison=workshop:getRepairTimeComparison81(farmId,vehicle.assetId,profileId,quality,urgency);if comparison~=nil then detail=detail.."\n"..string.format(tr("agrilife_workshop81_time_comparison_fmt"),tonumber(comparison.dealerHours)or 0,tonumber(comparison.internalHours)or 0,tonumber(comparison.internalRatio)or 0) end end;action=tr("agrilife_workshop8_full_diagnostic");actionEnabled=true;if continuity.canRequestRecovery==true then action2=tr("agrilife_workshop8_recovery");action2Enabled=true end
        elseif view=="PARTS" then rows=snapshot.partsMarket or {};local row=selectRow(self,rows);canPrevNext=#rows>1;if row~=nil then detail=string.format(tr("agrilife_workshop8_part_fmt"),self.workshop8RowIndex,#rows,tostring(row.partFamily),tr("agrilife_workshop8_quality_"..string.lower(tostring(row.qualityId))),money(row.unitPrice),tonumber(row.stockLevel)or 0,tonumber(row.deliveryDays)or 0);action=tr("agrilife_workshop8_order_part");actionEnabled=true end
        elseif view=="JOBS" then rows=snapshot.workshopJobs or {};local row=selectRow(self,rows);canPrevNext=#rows>1;if row~=nil then detail=string.format(tr("agrilife_workshop8_job_fmt"),self.workshop8RowIndex,#rows,tostring(row.kind),tostring(row.status),tostring(row.provider),tonumber(row.turnaroundHours or row.laborHours)or 0,money(row.totalCost or 0));if tonumber(row.bookLaborHours)~=nil and tonumber(row.turnaroundHours)~=nil then detail=detail.."\n"..string.format(tr("agrilife_workshop81_job_time_fmt"),tonumber(row.bookLaborHours)or 0,tonumber(row.turnaroundHours)or 0,tonumber(row.internalTimeRatio)or 1) end;local coverage=workshop:getInsuranceRepairCoverage(farmId,row.assetId,row);if tostring(row.kind)=="REPAIR" and tostring(row.insuranceClaimId or "")=="" and coverage~=nil and coverage.eligible==true then action=tr("agrilife_workshop8_insurance_claim");actionEnabled=true end;if workshop.getDealerLoanerOffer81~=nil and tostring(row.provider)=="DEALER" and tostring(row.status)~="COMPLETED" and tostring(row.status)~="FAILED" and tostring(row.status)~="CANCELLED" then local offer=workshop:getDealerLoanerOffer81(farmId,row.id);if offer~=nil and offer.active==true and offer.loaner~=nil then detail=detail.."\n"..tr("agrilife_workshop81_loaner_active");action2=tr("agrilife_workshop81_return_loaner");action2Enabled=true elseif offer~=nil and offer.available==true then detail=detail.."\n"..string.format(tr("agrilife_workshop81_loaner_offer_fmt"),money(offer.deposit or 0),money(offer.serviceFee or 0));action2=tr("agrilife_workshop81_request_loaner");action2Enabled=true elseif offer~=nil and offer.reason=="dealer_relation_low" then detail=detail.."\n"..string.format(tr("agrilife_workshop81_loaner_relation_fmt"),tonumber(offer.dealerScore)or 0,tonumber(offer.requiredScore)or 0) end end end
        elseif view=="COMPLIANCE" and vehicle~=nil then detail=string.format(tr("agrilife_workshop8_compliance_fmt"),vehicle.annualReviewOverdue and tr("agrilife_workshop8_overdue") or tostring(vehicle.nextAnnualReviewPeriodKey or "--"),vehicle.technicalInspectionOverdue and tr("agrilife_workshop8_overdue") or tostring(vehicle.nextTechnicalInspectionPeriodKey or "--"),tostring(vehicle.technicalInspectionStatus or "VALID"),vehicle.counterInspectionRequired and tr("agrilife_workshop8_yes") or tr("agrilife_workshop8_no"));action=tr("agrilife_workshop8_annual_review");action2=vehicle.counterInspectionRequired and tr("agrilife_workshop8_counter_inspection") or tr("agrilife_workshop8_technical_inspection");actionEnabled=true;action2Enabled=true
        elseif view=="DEALER" then local d=snapshot.dealer or {};rows={};if vehicle~=nil then for _,recall in ipairs(d.activeRecalls or {}) do if tostring(recall.assetId)==tostring(vehicle.assetId) then table.insert(rows,recall) end end end;local row=selectRow(self,rows);canPrevNext=#rows>1;detail=string.format(tr("agrilife_workshop8_dealer_fmt"),tonumber(d.score)or 0,tonumber(d.completedJobs)or 0,money(d.totalSpent or 0),(tonumber(d.laborDiscount)or 0)*100).."\n"..string.format(tr("agrilife_workshop8_dealer_recalls_fmt"),tonumber(d.activeRecallCount)or 0);if row~=nil then detail=detail.."\n"..tostring(row.partFamily).." | "..tostring(row.reason);action=tr("agrilife_workshop8_recall");actionEnabled=true end
        end
        setText(self.workshop8DetailTitle,title);setText(self.workshop8DetailText,detail);setDisabled(self.workshop8PrevButton,not canPrevNext);setDisabled(self.workshop8NextButton,not canPrevNext);setText(self.workshop8ActionButton,action);setText(self.workshop8Action2Button,action2);setDisabled(self.workshop8ActionButton,not actionEnabled);setDisabled(self.workshop8Action2Button,not action2Enabled)
    end
end
