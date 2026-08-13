from pathlib import Path


def read(path):
    return Path(path).read_text(encoding="utf-8")


def write(path, text):
    Path(path).write_text(text, encoding="utf-8")


def replace_once(text, old, new, label):
    if old not in text:
        raise SystemExit(f"{label}: expected source not found")
    return text.replace(old, new, 1)


# Runtime version and mod metadata.
path = "src/core/AgriLifeVersion.lua"
text = read(path)
text = text.replace('MOD = "0.9.3.22"', 'MOD = "0.9.3.23"', 1)
write(path, text)

path = "modDesc.xml"
text = read(path)
text = text.replace('<version>0.9.3.22</version>', '<version>0.9.3.23</version>', 1)
write(path, text)

# Dashboard XML, direct from the older main layout to the tested 0.9.3.23 layout.
path = "gui/AgriLifeHomeFrame.xml"
text = read(path)
subtitle = '<Text profile="fs25_textDefault" text="$l10n_agrilife_ui6_dashboard_subtitle" position="340px 34px" size="650px 22px" textSize="13px" textColor="0.68 0.78 0.76 1" visible="false"/>'
context = '<Text profile="fs25_textDefault" id="headerContextHelp" text="--" position="340px 9px" size="780px 44px" textSize="11px" textColor="0.84 0.90 0.88 1" textWrap="true"/>'
if 'id="headerContextHelp"' not in text:
    text = replace_once(text, subtitle, subtitle + "\n            " + context, "header context")

pairs = [
    ('id="headerAccessMode" text="--" position="730px 18px" size="265px 24px" textSize="12px" textBold="true" textAlignment="right" textColor="0.67 0.91 0.45 1"', 'id="headerAccessMode" text="--" position="1135px 18px" size="130px 24px" textSize="12px" textBold="true" textAlignment="right" textColor="0.72 0.94 0.50 1"'),
    ('id="headerVersion" text="--" position="1010px 18px" size="145px 24px" textSize="14px"', 'id="headerVersion" text="--" position="1280px 18px" size="105px 24px" textSize="13px"'),
    ('id="headerFarm" text="--" position="1170px 18px" size="180px 24px" textSize="14px" textAlignment="right"', 'id="headerFarm" text="--" position="1400px 18px" size="145px 24px" textSize="13px" textAlignment="right" textColor="0.88 0.92 0.90 1"'),
    ('id="headerCash" text="--" position="1370px 18px" size="200px 24px" textSize="16px" textBold="true"', 'id="headerCash" text="--" position="1560px 18px" size="220px 24px" textSize="15px" textBold="true"'),
    ('id="resolvedModImage02" profile="ui6Icon" imageFilename="$moddir$gui/ui6icons/bank.dds" position="18px 122px" size="48px 48px" visible="true" imageColor="0.55 0.82 0.12 1"', 'id="resolvedModImage02" profile="ui6Icon" imageFilename="$moddir$gui/ui6icons/bank.dds" position="18px 122px" size="48px 48px" visible="true" imageColor="0.86 0.90 0.88 1"'),
    ('text="$l10n_agrilife_bank6_cash" position="24px 96px"', 'text="$l10n_agrilife_bank6_cash" position="24px 46px"'),
    ('id="dashBankCash" text="--" position="198px 94px"', 'id="dashBankCash" text="--" position="198px 44px"'),
    ('text="$l10n_agrilife_bank6_debt" position="24px 66px"', 'text="$l10n_agrilife_bank6_debt" position="24px 25px"'),
    ('id="dashBankDebt" text="--" position="198px 64px"', 'id="dashBankDebt" text="--" position="198px 23px"'),
    ('text="$l10n_agrilife_bank6_score" position="24px 36px"', 'text="$l10n_agrilife_bank6_score" position="24px 4px"'),
    ('id="dashBankScore" text="--" position="198px 34px" size="150px 22px" textSize="15px"', 'id="dashBankScore" text="--" position="178px 2px" size="170px 22px" textSize="14px"'),
]
for old, new in pairs:
    if old in text:
        text = text.replace(old, new, 1)

bank_title = '<Text profile="fs25_textDefault" text="$l10n_agrilife_ui6_bank" position="78px 146px" size="260px 28px" textSize="21px" textBold="true"/>'
if 'id="dashBankPartnerName"' not in text:
    bank_rows = bank_title + '\n                    <Text profile="fs25_textDefault" id="dashBankPartnerName" text="Banque : --" position="24px 116px" size="324px 18px" textSize="12px" textBold="true" textColor="0.88 0.92 0.90 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankAdvisorName" text="Conseiller : --" position="24px 98px" size="324px 17px" textSize="11px" textColor="0.78 0.84 0.82 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankPartnerStars" text="Banque RÉP --/5 | COMP --/5" position="24px 82px" size="324px 14px" textSize="10px" textColor="0.74 0.82 0.56 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankAdvisorStars" text="Conseiller RÉP --/5 | COMP --/5" position="24px 68px" size="324px 14px" textSize="10px" textColor="0.68 0.75 0.74 1"/>'
    text = replace_once(text, bank_title, bank_rows, "bank identity rows")
write(path, text)

# Home frame bindings.
path = "src/ui/AgriLifeHomeFrame.lua"
text = read(path)
if "local function formatFiveStars" not in text:
    anchor = '''local function formatStars(stars)\n    stars = math.max(0, math.min(10, math.floor(tonumber(stars) or 0)))\n    return string.format("%d/10", stars)\nend\n'''
    addition = anchor + '''\nlocal function formatFiveStars(stars)\n    stars = math.max(0, math.min(5, math.floor(tonumber(stars) or 0)))\n    return string.format("%d/5", stars)\nend\n'''
    text = replace_once(text, anchor, addition, "home rating formatter")

initial_score = '        setText(self.dashBankScore, string.format("%d - %s", bankSnapshot.score or 0, g_i18n:getText("agrilife_bank6_rating_" .. tostring(bankSnapshot.rating or "standard"))))'
if 'setText(self.dashBankPartnerName, "Banque : " .. providerName)' not in text:
    addition = initial_score + '''\n        local providerName = tostring(bankSnapshot.providerName or bankSnapshot.providerLabel or "")\n        local advisorName = tostring(bankSnapshot.advisorName or "")\n        if providerName == "" then providerName = "--" end\n        if advisorName == "" then advisorName = "--" end\n        setText(self.dashBankPartnerName, "Banque : " .. providerName)\n        setText(self.dashBankAdvisorName, "Conseiller : " .. advisorName)\n        setText(self.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bankSnapshot.providerReputationStars or bankSnapshot.providerStars or 0), formatFiveStars(bankSnapshot.providerCompetenceStars or bankSnapshot.providerStars or 0)))\n        setText(self.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bankSnapshot.advisorReputationStars or bankSnapshot.advisorStars or 0), formatFiveStars(bankSnapshot.advisorCompetenceStars or bankSnapshot.advisorStars or 0)))'''
    text = replace_once(text, initial_score, addition, "home initial bank binding")

old_facade = '''        local bank = cards.bank or {}\n        local relationship = bank.relationship or {}\n        local relationText = tostring(relationship.status or "none")\n        if relationship.status == "active" then relationText = string.format("%s, %d mois", tostring(bank.providerName or ""), tonumber(relationship.remainingMonths) or 0)\n        elseif tostring(bank.providerName or "") ~= "" then relationText = tostring(bank.providerName) end\n        setText(self.dashBankScore, string.format(g_i18n:getText("agrilife_dashboard_bank_score_relation_fmt"), tonumber(bank.score) or 0, relationText))\n'''
new_facade = '''        local bank = cards.bank or {}\n        local providerName = tostring(bank.providerName or "")\n        local advisorName = tostring(bank.advisorName or "")\n        if providerName == "" then providerName = "--" end\n        if advisorName == "" then advisorName = "--" end\n        setText(self.dashBankPartnerName, "Banque : " .. providerName)\n        setText(self.dashBankAdvisorName, "Conseiller : " .. advisorName)\n        setText(self.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bank.providerReputationStars or 0), formatFiveStars(bank.providerCompetenceStars or 0)))\n        setText(self.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bank.advisorReputationStars or 0), formatFiveStars(bank.advisorCompetenceStars or 0)))\n        local rating = g_i18n:getText("agrilife_bank6_rating_" .. tostring(bank.rating or "standard"))\n        if rating == nil or rating == "" or rating == "agrilife_bank6_rating_" .. tostring(bank.rating or "standard") then rating = tostring(bank.rating or "") end\n        local scoreText = tostring(math.floor((tonumber(bank.score) or 0) + 0.5))\n        if rating ~= "" then scoreText = scoreText .. " - " .. rating end\n        setText(self.dashBankScore, scoreText)\n'''
if old_facade in text:
    text = text.replace(old_facade, new_facade, 1)
write(path, text)

# Interface facade bindings.
path = "src/ui/AgriLifeInterface6.lua"
text = read(path)
if "local function formatFiveStars(value)" not in text:
    anchor = '''    return string.format("%.0f", value)\nend\n\nlocal function module(core, id)\n'''
    addition = '''    return string.format("%.0f", value)\nend\n\nlocal function formatFiveStars(value)\n    local count = math.max(0, math.min(5, math.floor((tonumber(value) or 0) + 0.5)))\n    return string.format("%d/5", count)\nend\n\nlocal function module(core, id)\n'''
    text = replace_once(text, anchor, addition, "interface rating formatter")

old_bank = '''    local relationship = bank.relationship or {}\n    local relationshipText = tr("agrilife_bank_relationship_none")\n    if relationship.status == "active" then\n        relationshipText = trf("agrilife_bank_relationship_active_fmt", tonumber(relationship.remainingMonths) or 0)\n    elseif relationship.status == "expired" then\n        relationshipText = tr("agrilife_bank_relationship_expired")\n    elseif tostring(bank.providerName or "") ~= "" then\n        relationshipText = tostring(bank.providerName)\n    end\n    setText(frame.dashBankScore, trf("agrilife_dashboard_bank_score_relation_fmt", tonumber(bank.score) or 0, relationshipText))\n'''
new_bank = '''    local providerName = tostring(bank.providerName or "")\n    local advisorName = tostring(bank.advisorName or "")\n    if providerName == "" then providerName = "--" end\n    if advisorName == "" then advisorName = "--" end\n    setText(frame.dashBankPartnerName, "Banque : " .. providerName)\n    setText(frame.dashBankAdvisorName, "Conseiller : " .. advisorName)\n    setText(frame.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bank.providerReputationStars), formatFiveStars(bank.providerCompetenceStars)))\n    setText(frame.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bank.advisorReputationStars), formatFiveStars(bank.advisorCompetenceStars)))\n    local rating = tr("agrilife_bank6_rating_" .. tostring(bank.rating or "standard"))\n    if rating == "--" then rating = tostring(bank.rating or "") end\n    local scoreText = tostring(math.floor((tonumber(bank.score) or 0) + 0.5))\n    if rating ~= "" then scoreText = scoreText .. " - " .. rating end\n    setText(frame.dashBankScore, scoreText)\n'''
if old_bank in text:
    text = text.replace(old_bank, new_bank, 1)
write(path, text)

# French header strings used by the validated 1080p dashboard.
path = "translations/translation_fr.xml"
text = read(path)
replacements = {
    'FACILE : démarrage libre. Banque, permis et assurance ne bloquent pas la carrière. Ordre conseillé : Banque → Entreprise → Carrière → Administration → Contrats → Atelier.': 'FACILE : démarrage libre. Parcours conseillé : Banque > Entreprise > Carrière > Administration > Contrats > Atelier.',
    'NORMAL : choisissez d’abord une banque puis un conseiller. Vous obtenez ensuite un permis provisoire de 3 mois. Suivez ensuite Entreprise → Carrière → Administration → Contrats → Atelier.': 'NORMAL : Banque + conseiller, puis permis provisoire 3 mois. Ensuite : Entreprise > Carrière > Administration > Contrats > Atelier.',
    'DIFFICILE : banque + conseiller obligatoires, puis permis agricole obligatoire. Assurance obligatoire. Suivez les étapes affichées avant d’utiliser librement les services de carrière.': 'DIFFICILE : Banque + conseiller + permis + assurance obligatoires. Suivez les étapes affichées avant la carrière.'
}
for old, new in replacements.items():
    if old in text:
        text = text.replace(old, new, 1)
write(path, text)

# Complete the small F02 clarity layer with the context header refresh.
path = "src/ui/F02Clarity0920.lua"
text = read(path)
if "local baseRefresh0922" not in text:
    marker = '''        hideWhenEmpty(self.workshop8ActionButton)\n        hideWhenEmpty(self.workshop8Action2Button)\n    end\nend\n'''
    block = '''        hideWhenEmpty(self.workshop8ActionButton)\n        hideWhenEmpty(self.workshop8Action2Button)\n    end\n\n    local baseRefresh0922 = AgriLife.HomeFrame.refresh\n    function AgriLife.HomeFrame:refresh()\n        if baseRefresh0922 ~= nil then baseRefresh0922(self) end\n        if self.headerContextHelp == nil or self.headerContextHelp.setText == nil then return end\n        local page = tostring(self.activePage or "dashboard")\n        local modeId = tostring(self.currentModeId or "facile")\n        local keys = {\n            dashboard = "agrilife_context_dashboard_" .. modeId,\n            company = "agrilife_context_company",\n            bank = "agrilife_context_bank_ready",\n            payroll = "agrilife_context_payroll",\n            exams = "agrilife_context_career_" .. modeId,\n            xp = "agrilife_context_career_" .. modeId,\n            insurance = "agrilife_context_insurance",\n            contracts = "agrilife_context_contracts",\n            workshop = "agrilife_context_workshop",\n            accidents = "agrilife_context_accidents",\n            leasing = "agrilife_context_leasing",\n            used = "agrilife_context_used"\n        }\n        local key = keys[page]\n        local value = key ~= nil and g_i18n ~= nil and g_i18n.getText ~= nil and g_i18n:getText(key) or ""\n        if value == nil or value == key then value = "" end\n        self.headerContextHelp:setText(tostring(value or ""))\n    end\nend\n'''
    text = replace_once(text, marker, block, "F02 context refresh")
write(path, text)

# Append F02 history and validation without deleting roadmap content.
sections = '''\n\n## Correction F02 0.9.3.22 - tableau de bord et carte Banque\n\n- L'aide contextuelle supérieure du tableau de bord dispose de davantage de largeur et de contraste.\n- La carte Banque est réalignée sur la grille des autres cartes.\n- Le nom de la banque et le nom du conseiller sont affichés sur deux lignes distinctes.\n- Le score de crédit contient uniquement sa valeur et son appréciation, sans nom de banque.\n\n## Correction F02 0.9.3.23 - en-tête et notation Banque\n\n- La zone d'aide supérieure est élargie et les textes français de mode sont raccourcis pour rester entièrement visibles.\n- Les caractères étoile Unicode non pris en charge par la police FS25 ne sont plus utilisés dans le résumé Banque.\n- Les évaluations Banque et Conseiller utilisent une note lisible sur 5 dans le tableau de bord.\n- F02 est validée dans Farming Simulator 25 en 0.9.3.23 sur le retest 1080p.\n- La phase Banque fonctionnelle peut maintenant ouvrir ses tests ciblés.\n'''
for roadmap in ("ROADMAP.md", "docs/ROADMAP.md"):
    text = read(roadmap)
    if "## Correction F02 0.9.3.23 - en-tête et notation Banque" not in text:
        text = text.rstrip() + sections + "\n"
    write(roadmap, text)
