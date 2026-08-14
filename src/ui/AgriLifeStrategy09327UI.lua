-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.HomeFrame ~= nil then
    local Frame = AgriLife.HomeFrame
    Frame.STRATEGY_UI_VERSION = "0.9.3.27"

    local function tr(key, fallback)
        if g_i18n ~= nil and g_i18n.getText ~= nil then
            local ok, value = pcall(g_i18n.getText, g_i18n, key)
            if ok and value ~= nil and tostring(value) ~= tostring(key) then return tostring(value) end
        end
        return tostring(fallback or key or "")
    end
    local function money(value)
        value = tonumber(value) or 0
        if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
            local ok, result = pcall(g_i18n.formatMoney, g_i18n, value, 0, true, true)
            if ok and result ~= nil then return tostring(result) end
        end
        return string.format("%.0f EUR", value)
    end
    local function setElementText(element, value)
        if element ~= nil and element.setText ~= nil then pcall(element.setText, element, tostring(value or "")) end
    end
    local function resultText(result, fallback)
        if result ~= nil and tostring(result.message or "") ~= "" then return tostring(result.message) end
        return tostring(fallback or "")
    end
    local function showInfo(message)
        if g_gui ~= nil and g_gui.showInfoDialog ~= nil then g_gui:showInfoDialog({text=tostring(message or "")}); return true end
        if InfoDialog ~= nil and InfoDialog.show ~= nil then InfoDialog.show(tostring(message or "")); return true end
        return false
    end
    local function showDecision(self, title, message, perform)
        if type(perform) ~= "function" then return false end
        if g_gui ~= nil and g_gui.showYesNoDialog ~= nil then
            g_gui:showYesNoDialog({text=tostring(message or ""),title=tostring(title or "AgriLife Manager"),callback=function(target,confirmed) if confirmed==true then perform() end end,target=self,yesText=tr("agrilife_core_yes","Oui"),noText=tr("agrilife_core_no","Non")})
            return true
        end
        if YesNoDialog ~= nil and YesNoDialog.show ~= nil then
            YesNoDialog.show(function(confirmed) if confirmed==true then perform() end end,nil,tostring(message or ""))
            return true
        end
        showInfo(tr("agrilife_decision_dialog_unavailable","La confirmation de décision est indisponible. Aucune modification n'a été appliquée."))
        return false
    end
    local function farmId(self)
        return self.core ~= nil and self.core.context ~= nil and self.core.context:getFarmId() or 0
    end
    local function actorId(self, id)
        return self.getLocalPayrollProfileId ~= nil and self:getLocalPayrollProfileId(id) or ""
    end
    local function listContains(values, id)
        for _, value in ipairs(values or {}) do if tostring(value) == tostring(id) then return true end end
        return false
    end
    local function advisorBlock(self, id, decisionType, params)
        local enterprise = self.getEnterpriseModule ~= nil and self:getEnterpriseModule() or nil
        if enterprise == nil or enterprise.getManagementAdvice == nil then return "" end
        local result = enterprise:getManagementAdvice(id, decisionType, params or {}, true)
        if result == nil or result.ok ~= true or result.details == nil then return "" end
        local formatted = AgriLife.ManagementAdvisor09327 ~= nil and AgriLife.ManagementAdvisor09327.formatAdvice ~= nil and AgriLife.ManagementAdvisor09327:formatAdvice(result) or ""
        if formatted == "" then return "" end
        return "\n\n" .. tr("agrilife_advisor_title","Avis du conseiller de gestion") .. "\n" .. formatted
    end
    local function buildDecision(data)
        if AgriLife.DecisionGuide ~= nil and AgriLife.DecisionGuide.build ~= nil then return AgriLife.DecisionGuide.build(data) end
        return tostring(data.summary or "") .. "\n\n" .. tostring(data.confirmQuestion or "")
    end
    local function legalLabel(form)
        return form ~= nil and tr(form.labelKey, tostring(form.id or "")) or "--"
    end
    local function activityLabel(activity)
        return activity ~= nil and tr(activity.labelKey, tostring(activity.id or "")) or "--"
    end
    local function networkLabel(network)
        return network ~= nil and tr(network.labelKey, tostring(network.id or "")) or "--"
    end

    function Frame:getReadyCompanyActivities()
        local company = self:getCompanyModule()
        local source = company ~= nil and company.getActivities ~= nil and company:getActivities() or {}
        local out = {}
        for _, id in ipairs({"ETA","PROCESSING","DIRECT_SALES","BIOGAS","FORESTRY"}) do
            local item = source[id]
            if item ~= nil and item.gameplayReady == true then table.insert(out,item) end
        end
        return out
    end

    function Frame:getReadyCompanyNetworks()
        local company = self:getCompanyModule()
        local source = company ~= nil and company.getNetworks ~= nil and company:getNetworks() or {}
        local out = {}
        for _, id in ipairs({"CUMA","COOPERATIVE","EMPLOYER_GROUP"}) do
            local item = source[id]
            if item ~= nil and item.gameplayReady == true then table.insert(out,item) end
        end
        return out
    end

    function Frame:onClickCompanyLegalForm()
        if not self:canManage("company.manage") then return end
        local company = self:getCompanyModule(); local id = farmId(self); local snapshot = company ~= nil and company:getSnapshot(id) or nil
        if snapshot == nil then return end
        local forms = company:getLegalForms() or {}; if #forms <= 0 then return end
        local index = 1; for i, form in ipairs(forms) do if form.id == snapshot.legalFormId then index = i break end end
        local target = forms[index % #forms + 1]
        local preview = company:previewLegalFormChange(id,target.id)
        if preview == nil or preview.ok ~= true then self.lastCompanyMessage=resultText(preview,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany();return end
        local d=preview.details or {}; local form=d.form or target
        local effects={
            string.format(tr("agrilife_company_effect_cost_fmt","Coût de transformation : %s"),money(d.cost or 0)),
            string.format(tr("agrilife_company_effect_monthly_fmt","Frais administratifs mensuels : %s"),money(form.monthlyAdminCost or 0)),
            string.format(tr("agrilife_company_effect_members_fmt","Associés autorisés : %d à %d"),tonumber(form.minMembers)or 1,tonumber(form.maxMembers)or 1),
            string.format(tr("agrilife_company_effect_activity_limit_fmt","Activités secondaires maximum : %d"),tonumber(form.maxExtraActivities)or 0)
        }
        local summary=string.format(tr("agrilife_company_decision_form_summary","Passer de %s à %s modifie la structure juridique de l'exploitation."),legalLabel(d.current),legalLabel(form))
        local message=buildDecision({title=tr("agrilife_company_structure_change_form","Changer de forme juridique"),summary=summary,effects=effects,reversibility=tr("agrilife_company_reversible_form","Une nouvelle transformation restera possible, avec de nouveaux frais et sous réserve des conditions de la forme choisie."),difficulty=tr("agrilife_company_choice_difficulty","La difficulté modifie certains coûts et tolérances."),confirmQuestion=tr("agrilife_company_confirm_form","Confirmer cette transformation juridique ?")})
        message=message..advisorBlock(self,id,"LEGAL_FORM",{cost=d.cost or 0,monthlyCost=form.monthlyAdminCost or 0})
        showDecision(self,tr("agrilife_company_structure_change_form","Changer de forme juridique"),message,function()
            local result=company:setIdentity(id,snapshot.companyName,form.id);self.lastCompanyMessage=resultText(result,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany()
        end)
    end

    function AgriLife.HomeFrame:onClickCompanyActivity()
        if not self:canManage("company.manage") then return end
        local company=self:getCompanyModule();local id=farmId(self);local snapshot=company~=nil and company:getSnapshot(id)or nil;if snapshot==nil then return end
        local rows=self:getReadyCompanyActivities();if #rows<=0 then self.lastCompanyMessage=tr("agrilife_company_no_ready_activity","Aucune activité secondaire n'est encore activée pour cette version.");self:refreshCompany();return end
        self.companyActivityChoiceIndex=((tonumber(self.companyActivityChoiceIndex)or 0)%#rows)+1;local activity=rows[self.companyActivityChoiceIndex]
        local enabled=not listContains(snapshot.activities,activity.id);local preview=company:previewActivityChange(id,activity.id,enabled)
        if preview==nil or preview.ok~=true then self.lastCompanyMessage=resultText(preview,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany();return end
        local d=preview.details or {};local effects={string.format(tr("agrilife_company_effect_cost_fmt","Coût de mise en place : %s"),money(d.cost or 0)),string.format(tr("agrilife_company_effect_monthly_fmt","Charge mensuelle : %s"),money(activity.monthlyCost or 0))}
        if activity.id=="ETA" then table.insert(effects,tr("agrilife_company_effect_eta","Débloque la logique d'entreprise de travaux agricoles et améliore la valorisation des prestations compatibles.")) end
        local summary=enabled and string.format(tr("agrilife_company_decision_activity_enable_summary","Ajouter l'activité %s à l'entreprise."),activityLabel(activity)) or string.format(tr("agrilife_company_decision_activity_disable_summary","Retirer l'activité %s de l'entreprise."),activityLabel(activity))
        local message=buildDecision({title=tr("agrilife_company_structure_change_activity","Modifier une activité"),summary=summary,effects=effects,reversibility=tr("agrilife_company_reversible_activity","L'activité pourra être arrêtée ou réactivée plus tard. Des frais peuvent s'appliquer à chaque changement."),difficulty=tr("agrilife_company_choice_difficulty","La difficulté modifie certains coûts et tolérances."),confirmQuestion=tr("agrilife_company_confirm_activity","Confirmer cette modification d'activité ?")})
        message=message..advisorBlock(self,id,"ACTIVITY",{cost=d.cost or 0,monthlyCost=activity.monthlyCost or 0})
        showDecision(self,tr("agrilife_company_structure_change_activity","Modifier une activité"),message,function()
            local result=company:setActivity(id,activity.id,enabled,actorId(self,id));self.lastCompanyMessage=resultText(result,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany()
        end)
    end

    function AgriLife.HomeFrame:onClickCompanyNetwork()
        if not self:canManage("company.manage") then return end
        local company=self:getCompanyModule();local id=farmId(self);local snapshot=company~=nil and company:getSnapshot(id)or nil;if snapshot==nil then return end
        local rows=self:getReadyCompanyNetworks();if #rows<=0 then self.lastCompanyMessage=tr("agrilife_company_no_ready_network","Aucun réseau professionnel n'est encore activé pour cette version.");self:refreshCompany();return end
        self.companyNetworkChoiceIndex=((tonumber(self.companyNetworkChoiceIndex)or 0)%#rows)+1;local network=rows[self.companyNetworkChoiceIndex]
        local enabled=not listContains(snapshot.memberships,network.id);local preview=company:previewMembershipChange(id,network.id,enabled)
        if preview==nil or preview.ok~=true then self.lastCompanyMessage=resultText(preview,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany();return end
        local d=preview.details or {};local effects={string.format(tr("agrilife_company_effect_cost_fmt","Coût d'adhésion ou de sortie : %s"),money(d.cost or 0)),string.format(tr("agrilife_company_effect_monthly_fmt","Cotisation mensuelle : %s"),money(network.monthlyCost or 0))}
        if network.id=="COOPERATIVE" then table.insert(effects,tr("agrilife_company_effect_cooperative","Donne accès aux avantages commerciaux coopératifs prévus dans les contrats compatibles.")) end
        local summary=enabled and string.format(tr("agrilife_company_decision_network_join_summary","Adhérer au réseau %s."),networkLabel(network)) or string.format(tr("agrilife_company_decision_network_leave_summary","Quitter le réseau %s."),networkLabel(network))
        local message=buildDecision({title=tr("agrilife_company_structure_change_network","Modifier une adhésion"),summary=summary,effects=effects,reversibility=tr("agrilife_company_reversible_network","L'adhésion peut être résiliée puis souscrite de nouveau. Une nouvelle adhésion peut entraîner de nouveaux frais."),difficulty=tr("agrilife_company_choice_difficulty","La difficulté modifie certains coûts et tolérances."),confirmQuestion=tr("agrilife_company_confirm_network","Confirmer cette modification d'adhésion ?")})
        message=message..advisorBlock(self,id,"NETWORK",{cost=d.cost or 0,monthlyCost=network.monthlyCost or 0})
        showDecision(self,tr("agrilife_company_structure_change_network","Modifier une adhésion"),message,function()
            local result=company:setMembership(id,network.id,enabled,actorId(self,id));self.lastCompanyMessage=resultText(result,tr("agrilife_company_change_unavailable","Modification indisponible"));self:refreshCompany()
        end)
    end

    local baseRefreshCompany=Frame.refreshCompany
    function Frame:refreshCompany()
        baseRefreshCompany(self)
        local company=self:getCompanyModule();local id=farmId(self);local snapshot=company~=nil and company:getSnapshot(id)or nil;if snapshot==nil then return end
        local activityLabels={};local activitySource=company:getActivities()or{}
        for _,activityId in ipairs(snapshot.activities or{})do if activityId~="FARMING" then local a=activitySource[activityId];table.insert(activityLabels,activityLabel(a or{id=activityId,labelKey=""}))end end
        local networkLabels={};local networkSource=company:getNetworks()or{}
        for _,networkId in ipairs(snapshot.memberships or{})do local n=networkSource[networkId];table.insert(networkLabels,networkLabel(n or{id=networkId,labelKey=""}))end
        local activityText=#activityLabels>0 and table.concat(activityLabels,", ") or tr("agrilife_company_structure_none_activity","aucune activité secondaire")
        local networkText=#networkLabels>0 and table.concat(networkLabels,", ") or tr("agrilife_company_structure_none_network","aucun réseau")
        local summary=string.format(tr("agrilife_company_structure_summary_fmt","Activités : %s | Réseaux : %s | Structure : %s/mois | Impayés : %s"),activityText,networkText,money(snapshot.monthlyStructureCost or 0),money(snapshot.structureFeeArrears or 0))
        setElementText(self.companyStructureValue,summary)
        setElementText(self.companyLegalFormButton,tr("agrilife_company_button_legal_form","Forme juridique"))
        setElementText(self.companyActivityButton,tr("agrilife_company_button_activity","Activités"))
        setElementText(self.companyNetworkButton,tr("agrilife_company_button_network","Réseaux"))
        local allowed=self:canManage("company.manage")
        if self.companyActivityButton~=nil and self.companyActivityButton.setDisabled~=nil then self.companyActivityButton:setDisabled(not allowed) end
        if self.companyNetworkButton~=nil and self.companyNetworkButton.setDisabled~=nil then self.companyNetworkButton:setDisabled(not allowed) end
    end

    -- Recruitment is a consequential decision. The advisor evaluates the
    -- candidate against the live farm finances before the hire can be signed.
    local baseEnterpriseHire=Frame.onClickEnterpriseHire
    function Frame:onClickEnterpriseHire()
        local id=farmId(self);local enterprise=self:getEnterpriseModule();local snapshot=enterprise~=nil and enterprise:getSnapshot(id)or nil
        local candidates=snapshot~=nil and(snapshot.recruitmentMarket or snapshot.candidates)or{}
        if #candidates<=0 then return baseEnterpriseHire(self) end
        local index=math.max(1,math.min(#candidates,tonumber(self.enterpriseCandidateIndex)or 1));local candidate=candidates[index]
        local monthlySalary=tonumber(candidate.requestedSalary)or 0;local monthlyEmployerCost=monthlySalary*1.35
        local advice=enterprise.getManagementAdvice~=nil and enterprise:getManagementAdvice(id,"HIRE",{monthlySalary=monthlySalary,monthlyEmployerCost=monthlyEmployerCost},true)or nil
        local adviceText=AgriLife.ManagementAdvisor09327~=nil and AgriLife.ManagementAdvisor09327.formatAdvice~=nil and AgriLife.ManagementAdvisor09327:formatAdvice(advice)or tr("agrilife_advisor_unavailable","Avis de gestion indisponible")
        local message=buildDecision({title=tr("agrilife_enterprise_hire_decision_title","Recrutement"),summary=string.format(tr("agrilife_enterprise_hire_decision_summary","Recruter %s engage l'entreprise sur une nouvelle charge de personnel."),tostring(candidate.name or candidate.displayName or candidate.id or"--")),effects={string.format(tr("agrilife_enterprise_hire_salary_fmt","Salaire demandé : %s/mois"),money(monthlySalary)),string.format(tr("agrilife_enterprise_hire_cost_fmt","Coût employeur indicatif : %s/mois"),money(monthlyEmployerCost))},reversibility=tr("agrilife_enterprise_hire_reversible","Une rupture ultérieure peut avoir un coût, des contraintes et des effets sur la réputation."),difficulty=tr("agrilife_company_choice_difficulty","La difficulté modifie certains coûts et tolérances."),confirmQuestion=tr("agrilife_enterprise_hire_confirm","Confirmer ce recrutement ?")}).."\n\n"..tr("agrilife_advisor_title","Avis du conseiller de gestion").."\n"..adviceText
        showDecision(self,tr("agrilife_enterprise_hire_decision_title","Recrutement"),message,function()
            local actor=actorId(self,id);local result=enterprise.hireCandidateWithOffer~=nil and enterprise:hireCandidateWithOffer(id,actor,candidate.id,candidate.requestedContract,candidate.requestedSalary)or enterprise:hireCandidate(id,actor,candidate.id,candidate.requestedContract)
            self.lastEnterpriseMessage=resultText(result,tr("agrilife_enterprise_hire_failed","Recrutement impossible"));self.enterpriseCandidateIndex=1;self:refreshPayroll()
        end)
    end
end
