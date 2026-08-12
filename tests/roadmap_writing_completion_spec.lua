local ROOT=tostring(arg and arg[1] or "."):gsub("[\\/]+$","")
local assertions=0
local function truthy(value,name) assertions=assertions+1; assert(value,name or "expected truthy") end
local function contains(path,token,name) local h=assert(io.open(ROOT.."/"..path,"rb")); local s=h:read("*a");h:close();truthy(string.find(s,token,1,true)~=nil,name or(path..":"..token));return s end

local version=contains("src/core/AgriLifeVersion.lua",'MOD = "0.9.1.0"',"version 0.9.1.0")
contains("modDesc.xml",'<version>0.9.1.0</version>',"modDesc version")
for _,path in ipairs({
    "src/modules/bank/BankRoadmap3Completion.lua",
    "src/modules/economy/EconomyAccountingRoadmapCompletion.lua",
    "src/modules/dashboard/DashboardRoadmapWritingCompletion.lua",
    "src/ui/AgriLifeRoadmapWritingCompletionUI.lua",
    "src/ui/AgriLifeInterfaceRoadmap2Completion.lua"
}) do contains("modDesc.xml",path,"active source "..path) end

local bank=contains("src/modules/bank/BankRoadmap3Completion.lua","getBankConsultationOffers","bank consultations")
for _,token in ipairs({"getProviderRiskProfile","getAdvisorCompatibility","getMarketFinancingPressure","getAccountingJournal","getDepreciationForYear","getOwnedMarketAssetValues","getBalanceSheet","getAdvancedAccountingSnapshot","getAccountSeparationAudit","selfFinancingCapacity","profitabilityByActivity","refinancing=true","vanillaLoanOperationsBlocked=true"}) do truthy(string.find(bank,token,1,true)~=nil,"bank "..token) end
local economy=contains("src/modules/economy/EconomyAccountingRoadmapCompletion.lua","getProfessionalTransactions","professional filters")
for _,token in ipairs({"accountingCategory","counterparty","supplierId","referenceId","contractId","flowType","tags","metadataPersistent=true"}) do truthy(string.find(economy,token,1,true)~=nil,"economy "..token) end
local interface=contains("src/ui/AgriLifeInterfaceRoadmap2Completion.lua",'profile = "1440p"',"1440p policy")
truthy(string.find(interface,'profile = "4k"',1,true)~=nil,"4k policy")
truthy(string.find(interface,"visualCertificationRequired=true",1,true)~=nil,"visual certification kept separate")
contains("src/ui/AgriLifeHomeFrame.lua","formatMoney(value, 2, true, true)","cent-consistent professional money")
contains("translations/translation_fr.xml","agrilife_dashboard_career_history_fmt","career history l10n")
contains("translations/translation_fr.xml","agrilife_bank_completion_offer_fmt","consultation l10n")
contains("translations/translation_fr.xml","agrilife_bank_completion_separation_warning_fmt","separation l10n")
print(string.format("ROADMAP_WRITING_COMPLETION: %d assertions passed",assertions))
