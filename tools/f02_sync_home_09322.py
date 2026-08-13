from pathlib import Path

p = Path("src/ui/AgriLifeHomeFrame.lua")
text = p.read_text(encoding="utf-8")

old = '''local function formatStars(stars)
    stars = math.max(0, math.min(10, math.floor(tonumber(stars) or 0)))
    return string.format("%d/10", stars)
end
'''
new = old + '''
local function formatFiveStars(value)
    local count = math.max(0, math.min(5, math.floor((tonumber(value) or 0) + 0.5)))
    return string.rep("★", count) .. string.rep("☆", 5 - count)
end
'''
if old not in text:
    raise SystemExit("HomeFrame star formatter source not found")
text = text.replace(old, new, 1)

old = '        setText(self.dashBankScore, string.format("%d - %s", bankSnapshot.score or 0, g_i18n:getText("agrilife_bank6_rating_" .. tostring(bankSnapshot.rating or "standard"))))'
new = old + '''
        local providerName = tostring(bankSnapshot.providerName or bankSnapshot.providerLabel or "")
        local advisorName = tostring(bankSnapshot.advisorName or "")
        if providerName == "" then providerName = "--" end
        if advisorName == "" then advisorName = "--" end
        setText(self.dashBankPartnerName, "Banque : " .. providerName)
        setText(self.dashBankAdvisorName, "Conseiller : " .. advisorName)
        setText(self.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bankSnapshot.providerReputationStars or bankSnapshot.providerStars or 0), formatFiveStars(bankSnapshot.providerCompetenceStars or bankSnapshot.providerStars or 0)))
        setText(self.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bankSnapshot.advisorReputationStars or bankSnapshot.advisorStars or 0), formatFiveStars(bankSnapshot.advisorCompetenceStars or bankSnapshot.advisorStars or 0)))'''
if old not in text:
    raise SystemExit("HomeFrame initial bank source not found")
text = text.replace(old, new, 1)

old = '''        local bank = cards.bank or {}
        local relationship = bank.relationship or {}
        local relationText = tostring(relationship.status or "none")
        if relationship.status == "active" then relationText = string.format("%s, %d mois", tostring(bank.providerName or ""), tonumber(relationship.remainingMonths) or 0)
        elseif tostring(bank.providerName or "") ~= "" then relationText = tostring(bank.providerName) end
        setText(self.dashBankScore, string.format(g_i18n:getText("agrilife_dashboard_bank_score_relation_fmt"), tonumber(bank.score) or 0, relationText))
'''
new = '''        local bank = cards.bank or {}
        local providerName = tostring(bank.providerName or "")
        local advisorName = tostring(bank.advisorName or "")
        if providerName == "" then providerName = "--" end
        if advisorName == "" then advisorName = "--" end
        setText(self.dashBankPartnerName, "Banque : " .. providerName)
        setText(self.dashBankAdvisorName, "Conseiller : " .. advisorName)
        setText(self.dashBankPartnerStars, string.format("Banque  RÉP %s  |  COMP %s", formatFiveStars(bank.providerReputationStars or 0), formatFiveStars(bank.providerCompetenceStars or 0)))
        setText(self.dashBankAdvisorStars, string.format("Conseiller  RÉP %s  |  COMP %s", formatFiveStars(bank.advisorReputationStars or 0), formatFiveStars(bank.advisorCompetenceStars or 0)))
        local rating = g_i18n:getText("agrilife_bank6_rating_" .. tostring(bank.rating or "standard"))
        if rating == nil or rating == "" or rating == "agrilife_bank6_rating_" .. tostring(bank.rating or "standard") then rating = tostring(bank.rating or "") end
        local scoreText = tostring(math.floor((tonumber(bank.score) or 0) + 0.5))
        if rating ~= "" then scoreText = scoreText .. " - " .. rating end
        setText(self.dashBankScore, scoreText)
'''
if old not in text:
    raise SystemExit("HomeFrame facade bank source not found")
text = text.replace(old, new, 1)
p.write_text(text, encoding="utf-8")
