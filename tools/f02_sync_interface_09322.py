from pathlib import Path

p = Path("src/ui/AgriLifeInterface6.lua")
text = p.read_text(encoding="utf-8")

old = '''    return string.format("%.0f", value)
end

local function module(core, id)
'''
new = '''    return string.format("%.0f", value)
end

local function formatFiveStars(value)
    local count = math.max(0, math.min(5, math.floor((tonumber(value) or 0) + 0.5)))
    return string.rep("★", count) .. string.rep("☆", 5 - count)
end

local function module(core, id)
'''
if old not in text:
    raise SystemExit("Interface star formatter source not found")
text = text.replace(old, new, 1)

old = '''    local relationship = bank.relationship or {}
    local relationshipText = tr("agrilife_bank_relationship_none")
    if relationship.status == "active" then
        relationshipText = trf("agrilife_bank_relationship_active_fmt", tonumber(relationship.remainingMonths) or 0)
    elseif relationship.status == "expired" then
        relationshipText = tr("agrilife_bank_relationship_expired")
    elseif tostring(bank.providerName or "") ~= "" then
        relationshipText = tostring(bank.providerName)
    end
    setText(frame.dashBankScore, trf("agrilife_dashboard_bank_score_relation_fmt", tonumber(bank.score) or 0, relationshipText))
'''
new = '''    local providerName = tostring(bank.providerName or "")
    local advisorName = tostring(bank.advisorName or "")
    if providerName == "" then providerName = "--" end
    if advisorName == "" then advisorName = "--" end
    setText(frame.dashBankPartnerName, "Banque : " .. providerName)
    setText(frame.dashBankAdvisorName, "Conseiller : " .. advisorName)
    setText(frame.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bank.providerReputationStars), formatFiveStars(bank.providerCompetenceStars)))
    setText(frame.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bank.advisorReputationStars), formatFiveStars(bank.advisorCompetenceStars)))
    local rating = tr("agrilife_bank6_rating_" .. tostring(bank.rating or "standard"))
    if rating == "--" then rating = tostring(bank.rating or "") end
    local scoreText = tostring(math.floor((tonumber(bank.score) or 0) + 0.5))
    if rating ~= "" then scoreText = scoreText .. " - " .. rating end
    setText(frame.dashBankScore, scoreText)
'''
if old not in text:
    raise SystemExit("Interface bank source not found")
text = text.replace(old, new, 1)
p.write_text(text, encoding="utf-8")
