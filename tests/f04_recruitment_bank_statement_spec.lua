-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- F04 regression: recruitment fee must be visible in the professional bank statement.
local root=tostring(arg and arg[1]or"."):gsub("[\\/]+$","")
local function load(relative)dofile(root.."/"..relative)end
local function truthy(v,label)if not v then error(label..": expected true",2)end end
local function equal(a,b,label)if a~=b then error(string.format("%s: expected %s, got %s",label,tostring(b),tostring(a)),2)end end
local function near(a,b,t,label)if math.abs((tonumber(a)or 0)-(tonumber(b)or 0))>(t or 0.01)then error(string.format("%s: expected %.2f, got %.2f",label,b,a),2)end end

AgriLife={}
load("src/core/AgriLifeResult.lua")
AgriLife.Logger={info=function()end,warning=function()end,error=function()end}
local farm={money=200000,loan=0}
g_farmManager={getFarmById=function(_,farmId)if tonumber(farmId)==1 then return farm end end}
g_currentMission={
    environment={currentYear=1,currentPeriod=1,currentDay=1,currentMonotonicDay=1,dayTime=36000000},
    addMoney=function(_,amount,farmId)if tonumber(farmId)~=1 then return false end farm.money=farm.money+(tonumber(amount)or 0);return true end
}
load("src/modules/bank/Bank6Service.lua")
load("src/modules/payroll/Payroll6Service.lua")
load("src/modules/payroll/F04RecruitmentBankStatement.lua")
local people={}
function people:hasPermission(_,profileId)return tostring(profileId)=="OWNER" end
function people:ensureProfile(_,profileId,displayName,role)return{profileId=profileId,displayName=displayName,role=role}end
function people:addAudit()end
local economyRecords={}
local economy={record=function(_,farmId,category,amount,source,profileId,note)table.insert(economyRecords,{category=category,amount=amount,source=source,note=note})end}
local core={context={isServer=true},registry={instances={people={service=people},economy={service=economy}}}}
local bank=AgriLife.Bank6Service.new(core);core.registry.instances.bank={service=bank}
local payroll=AgriLife.Payroll6Service.new(core);core.registry.instances.payroll={service=payroll}

local before=farm.money
local result=payroll:recruitVirtualEmployee(1,"OWNER","employee","CDI","Hugo Bernard")
truthy(result~=nil and result.ok==true,"recruitment succeeds")
near(farm.money,before-AgriLife.Payroll6Service.RECRUITMENT_FEE,0.01,"fee debited")
local rows=bank:getRecentBankMovements(1,8)
truthy(#rows==1,"one bank movement")
equal(rows[1].kind,"PAYROLL_RECRUITMENT_FEE","movement kind")
near(rows[1].amount,-350,0.01,"movement amount")
near(rows[1].balanceAfter,farm.money,0.01,"movement balance")
truthy(tostring(rows[1].tags or ""):find("FRAIS RECRUTEMENT",1,true)~=nil,"movement tag")
truthy(tostring(rows[1].tags or ""):find("Hugo Bernard",1,true)~=nil,"employee tag")
truthy(#economyRecords==1,"bank movement recorded once in economy ledger")
print("F04_RECRUITMENT_BANK_STATEMENT: OK")
