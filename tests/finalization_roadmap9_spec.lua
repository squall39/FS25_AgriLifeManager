local ROOT=tostring(arg and arg[1] or "."):gsub("[\\/]+$","")
local function load(path)dofile(ROOT.."/"..path)end
local assertions=0
local function truthy(v,n) assertions=assertions+1;assert(v,n or "expected truthy") end
local function falsy(v,n) assertions=assertions+1;assert(not v,n or "expected falsy") end
local function equal(a,b,n) assertions=assertions+1;assert(a==b,string.format("%s: expected %s got %s",n or "equal",tostring(b),tostring(a))) end
local function fileText(path)local h=assert(io.open(ROOT.."/"..path,"rb"));local s=h:read("*a");h:close();return s end

AgriLife={}
g_time=12500
g_currentMission={missionInfo={mapId="testMap"}}
g_modManager={mods={}}
load("src/core/AgriLifeResult.lua")
AgriLife.Logger={info=function()end,warning=function()end,error=function()end,debug=function()end}
AgriLife.ModuleRegistry={Status={FAILED="FAILED"}}
load("src/core/AgriLifeMigrationManager.lua")
load("src/core/AgriLifeNetworkRoadmap9.lua")
load("src/modules/compatibility/Compatibility6Service.lua")
AgriLife.CompatibilityModule={VERSION="0.8.0.0",getDescriptor=function()return{id="compatibility",version="0.8.0.0",schemaVersion=1,dependencies={},defaultEnabled=true,serverOnly=false,critical=false,factory=function()end}end}
load("src/modules/compatibility/CompatibilityRoadmap9.lua")
load("src/modules/finalization/Finalization6Service.lua")
AgriLife.FinalizationModule={VERSION="0.7.0.0",SCHEMA_VERSION=1,getDescriptor=function()return{id="finalization",version="0.7.0.0",schemaVersion=1,dependencies={},defaultEnabled=true,serverOnly=false,critical=false,factory=function()end}end}
load("src/modules/finalization/FinalizationRoadmap9.lua")

local migrations=AgriLife.MigrationManager.new()
local fakeXml={values={},setInt=function(self,key,value)self.values[key]=value end,setString=function(self,key,value)self.values[key]=value end}
truthy(migrations:register(3,4,function(xml)xml:setString("agriLifeManager.storage#roadmapFinalizationVersion","0.9.0.0");return AgriLife.Result.ok("OK","ok")end).ok,"register schema 4")
local migrated=migrations:migrate(fakeXml,3,4)
truthy(migrated.ok,"schema migration")
equal(migrated.details.schemaVersion,4,"schema target")
equal(#migrations.history,1,"migration history")
equal(migrations.lastRun.steps,1,"migration run steps")

local core={context={isServer=true,isClient=false,isMultiplayer=false,getFarmId=function()return 1 end,getFarmIds=function()return{1,2}end},registry={instances={},descriptors={},statuses={}}}
local compat=AgriLife.Compatibility6Service.new(core)
core.registry.instances.compatibility={service=compat,getSnapshot=function()return compat:getSnapshot()end,runRoadmap9CompatibilityAudit=function(_,...)return compat:runRoadmap9CompatibilityAudit(...)end}
core.registry.instances.market={service={discoverRuntimeContent=function()return{fillTypes={WHEAT={}},storeItems={{}},farmlands={{}},productions={{}}}end}}
core.registry.descriptors.compatibility={id="compatibility"};core.registry.statuses.compatibility="STARTED"
core.registry.instances.dashboardFacade={getSnapshot=function()return{cards={bank={},enterprise={},careerQualifications={},administration={},contractsMarkets={},workshop={}}}end}
core.registry.descriptors.dashboardFacade={id="dashboardFacade"};core.registry.statuses.dashboardFacade="STARTED"
local matrix=compat:getRoadmap9IntegrationMatrix()
truthy(matrix.autonomousFallback,"autonomous compatibility fallback")
equal(matrix.hardDependencies,0,"no hard dependencies")
falsy(matrix.courseplay.loaded,"courseplay optional")
falsy(matrix.autoDrive.loaded,"autodrive optional")
local content=compat:auditRuntimeContent()
truthy(content.mapAgnostic,"map agnostic")
truthy(content.multifruitReady,"runtime fillType discovery")
equal(content.fillTypes,1,"runtime fillType count")

local moduleIds={"economy","bank","company","people","enterprise","payroll","career","exams","qualifications","administration","insurance","commercialContracts","market","workshop","assets","legal","journal","finalization"}
for _,id in ipairs(moduleIds) do
    if id~="market" and id~="compatibility" then
        local service={farms={[1]={farmId=1},[2]={farmId=2}}}
        core.registry.instances[id]={service=service,save=function()return AgriLife.Result.ok("SAVE","ok")end,load=function()return AgriLife.Result.ok("LOAD","ok")end,getSnapshot=function(_,farmId)return{farmId=farmId,moduleId=id}end}
    else
        core.registry.instances[id].save=function()return AgriLife.Result.ok("SAVE","ok")end
        core.registry.instances[id].load=function()return AgriLife.Result.ok("LOAD","ok")end
        core.registry.instances[id].getSnapshot=function(_,farmId)return{farmId=farmId,moduleId=id}end
    end
    core.registry.descriptors[id]={id=id}
    core.registry.statuses[id]="STARTED"
end
local network=AgriLife.NetworkRoadmap9.new(core)
truthy(network:markDirty(1,"market"),"farm 1 dirty")
truthy(network:markDirty(2,"workshop"),"farm 2 dirty")
local env1=network:buildFarmEnvelope(1)
local env2=network:buildFarmEnvelope(2)
truthy(env1.ok and env2.ok,"server envelopes")
equal(env1.details.farmId,1,"farm 1 envelope")
equal(env2.details.farmId,2,"farm 2 envelope")
falsy(network:getReadiness().publicationEnabled,"multiplayer publication disabled")
truthy(network:getReadiness().authoritativeServer,"server authority declared")
truthy(network:getReadiness().perFarmIsolation,"farm isolation declared")

local clientCore={context={isServer=false,isClient=true,isMultiplayer=true},registry={instances={}}}
local clientNetwork=AgriLife.NetworkRoadmap9.new(clientCore)
truthy(clientNetwork:applyFarmEnvelope(env1.details,1).ok,"own farm mirror accepted")
falsy(clientNetwork:applyFarmEnvelope(env2.details,1).ok,"foreign farm mirror rejected")

core.persistence={readOnly=false,getRoadmap9RecoverySnapshot=function()return{careerIdentity="ALM_TEST",backupRecoveryCount=1,lastRecoverySource="backup",lastLoadedPath="save/AgriLifeManager_backup.xml"}end}
core.migrations=migrations
local finalization=AgriLife.Finalization6Service.new(core)
core.registry.instances.finalization={service=finalization,save=function()return AgriLife.Result.ok("SAVE","ok")end,load=function()return AgriLife.Result.ok("LOAD","ok")end,getSnapshot=function(_,farmId)return{farmId=farmId}end}
local audit=finalization:runRoadmap9Audit(1)
truthy(audit.persistence.ok,"persistent module coverage")
truthy(audit.isolation.ok,"multi-farm state tables isolated")
truthy(audit.compatibility.autonomousFallback,"compatibility fallback audited")
falsy(audit.network.publicationEnabled,"network publication still disabled")
truthy(audit.recovery.backupRecoveryCount==1,"backup recovery exposed")
local ready=finalization:getReleaseReadiness(1)
truthy(ready.codeReady,"step 9 code readiness")
falsy(ready.publicReleaseAllowed,"public release still needs certification")
truthy(ready.inGameCertificationRequired,"in-game certification preserved")

local version=fileText("src/core/AgriLifeVersion.lua")
truthy(version:find('MOD = "0.9.0.0"',1,true)~=nil,"0.9 version")
truthy(version:find('SAVE_SCHEMA = 4',1,true)~=nil,"save schema 4")
local coreSource=fileText("src/core/AgriLifeCore.lua")
truthy(coreSource:find('register(3, 4',1,true)~=nil,"3 to 4 migration registered")
local modDesc=fileText("modDesc.xml")
truthy(modDesc:find('<multiplayer supported="false" />',1,true)~=nil,"multiplayer unpublished")
truthy(modDesc:find('CompatibilityRoadmap9.lua',1,true)~=nil,"compatibility step 9 active")
truthy(modDesc:find('FinalizationRoadmap9.lua',1,true)~=nil,"finalization step 9 active")
truthy(modDesc:find('AgriLifeNetworkRoadmap9.lua',1,true)~=nil,"network scaffold active")
local tutorialXml=fileText("gui/AgriLifeTutorialDialog.xml")
truthy(tutorialXml:find('$l10n_agrilife_tutorial_prev',1,true)~=nil,"paged tutorial previous localized")
truthy(tutorialXml:find('$l10n_agrilife_tutorial_next',1,true)~=nil,"paged tutorial next localized")

print(string.format("FINALIZATION_ROADMAP9: %d assertions passed",assertions))
