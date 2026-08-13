from pathlib import Path

p = Path("gui/AgriLifeHomeFrame.xml")
text = p.read_text(encoding="utf-8")

subtitle = '<Text profile="fs25_textDefault" text="$l10n_agrilife_ui6_dashboard_subtitle" position="340px 34px" size="650px 22px" textSize="13px" textColor="0.68 0.78 0.76 1" visible="false"/>'
context = '<Text profile="fs25_textDefault" id="headerContextHelp" text="--" position="340px 9px" size="640px 44px" textSize="12px" textColor="0.84 0.90 0.88 1" textWrap="true"/>'
if 'id="headerContextHelp"' not in text:
    if subtitle not in text:
        raise SystemExit("Dashboard subtitle source not found")
    text = text.replace(subtitle, subtitle + "\n            " + context, 1)

changes = [
    ('id="headerAccessMode" text="--" position="730px 18px" size="265px 24px" textSize="12px" textBold="true" textAlignment="right" textColor="0.67 0.91 0.45 1"', 'id="headerAccessMode" text="--" position="995px 18px" size="145px 24px" textSize="12px" textBold="true" textAlignment="right" textColor="0.72 0.94 0.50 1"'),
    ('id="headerVersion" text="--" position="1010px 18px" size="145px 24px" textSize="14px"', 'id="headerVersion" text="--" position="1150px 18px" size="135px 24px" textSize="13px"'),
    ('id="headerFarm" text="--" position="1170px 18px" size="180px 24px" textSize="14px" textAlignment="right"', 'id="headerFarm" text="--" position="1295px 18px" size="170px 24px" textSize="13px" textAlignment="right" textColor="0.88 0.92 0.90 1"'),
    ('id="headerCash" text="--" position="1370px 18px" size="200px 24px" textSize="16px" textBold="true"', 'id="headerCash" text="--" position="1480px 18px" size="220px 24px" textSize="15px" textBold="true"'),
    ('id="resolvedModImage02" profile="ui6Icon" imageFilename="$moddir$gui/ui6icons/bank.dds" position="18px 122px" size="48px 48px" visible="true" imageColor="0.55 0.82 0.12 1"', 'id="resolvedModImage02" profile="ui6Icon" imageFilename="$moddir$gui/ui6icons/bank.dds" position="18px 122px" size="48px 48px" visible="true" imageColor="0.86 0.90 0.88 1"'),
    ('text="$l10n_agrilife_bank6_cash" position="24px 96px"', 'text="$l10n_agrilife_bank6_cash" position="24px 46px"'),
    ('id="dashBankCash" text="--" position="198px 94px"', 'id="dashBankCash" text="--" position="198px 44px"'),
    ('text="$l10n_agrilife_bank6_debt" position="24px 66px"', 'text="$l10n_agrilife_bank6_debt" position="24px 25px"'),
    ('id="dashBankDebt" text="--" position="198px 64px"', 'id="dashBankDebt" text="--" position="198px 23px"'),
    ('text="$l10n_agrilife_bank6_score" position="24px 36px"', 'text="$l10n_agrilife_bank6_score" position="24px 4px"'),
    ('id="dashBankScore" text="--" position="198px 34px" size="150px 22px" textSize="15px"', 'id="dashBankScore" text="--" position="178px 2px" size="170px 22px" textSize="14px"'),
]
for old, new in changes:
    if old not in text:
        raise SystemExit("Expected dashboard XML source not found: " + old)
    text = text.replace(old, new, 1)

needle = '<Text profile="fs25_textDefault" text="$l10n_agrilife_ui6_bank" position="78px 146px" size="260px 28px" textSize="21px" textBold="true"/>'
rows = needle + '\n                    <Text profile="fs25_textDefault" id="dashBankPartnerName" text="Banque : --" position="24px 116px" size="324px 18px" textSize="12px" textBold="true" textColor="0.88 0.92 0.90 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankAdvisorName" text="Conseiller : --" position="24px 98px" size="324px 17px" textSize="11px" textColor="0.78 0.84 0.82 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankPartnerStars" text="Banque R -- | C --" position="24px 82px" size="324px 14px" textSize="10px" textColor="0.74 0.82 0.56 1"/>\n                    <Text profile="fs25_textDefault" id="dashBankAdvisorStars" text="Conseiller R -- | C --" position="24px 68px" size="324px 14px" textSize="10px" textColor="0.68 0.75 0.74 1"/>'
if 'id="dashBankPartnerName"' not in text:
    if needle not in text:
        raise SystemExit("Bank title source not found")
    text = text.replace(needle, rows, 1)

p.write_text(text, encoding="utf-8")
