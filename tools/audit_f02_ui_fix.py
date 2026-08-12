#!/usr/bin/env python3
from pathlib import Path
import re, sys, xml.etree.ElementTree as ET

root = Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
errors=[]
def req(cond,msg):
    if not cond: errors.append(msg)
def read(rel):
    p=root/rel
    req(p.is_file(), f'missing {rel}')
    return p.read_text(encoding='utf-8', errors='replace') if p.is_file() else ''

mod=read('modDesc.xml')
req('<version>0.9.3.1</version>' in mod, 'wrong patch version')
version=read('src/core/AgriLifeVersion.lua')
req('MOD = "0.9.3.1"' in version, 'Lua patch version missing')

ui=read('src/ui/AgriLifeUIManager.lua')
for gui in ('AgriLifeTutorialDialog.xml','AgriLifeJournalDialog.xml','RoadAccidentDialog.xml'):
    req(gui in ui, f'dialog not wired: {gui}')
req(len(re.findall(r'g_gui\.loadGui, g_gui, xmlPath, self\.(?:tutorialGuiName|journalGuiName|accidentStatementGuiName), dialog, false', ui)) == 3,
    'custom dialogs are not all registered with isFrame=false')

for rel in ('src/ui/AgriLifeTutorialDialog.lua','src/ui/AgriLifeJournalDialog.lua','src/ui/AgriLifeAccidentStatementDialog.lua'):
    text=read(rel)
    req('registerDialogControls' in text, f'FS25 1.21 control helper missing: {rel}')
    req('FrameElement.registerControls' in text, f'FrameElement control fallback missing: {rel}')

home=read('src/ui/AgriLifeHomeFrame.lua')
req('upperDisplay(modeText) .. "  |  " .. upperDisplay(accessText)' in home, 'difficulty/access header missing')
req('snapshot~=nil and snapshot.modeChosen==true then return end' in home, 'difficulty can still change after validation')
req('setDisabled(self.onboardingModeButton,not self:canManage("company.manage") or snapshot.modeChosen==true)' in home,
    'difficulty selector is not locked after validation')
accounting = home[home.find('-- Roadmap 0.7 banking accounting controls.'):]
req('getFarmId(self)' not in accounting, 'out-of-scope getFarmId remains in bank accounting extension')

xml=read('gui/AgriLifeHomeFrame.xml')
try: ET.fromstring(xml)
except Exception as exc: errors.append(f'HomeFrame XML invalid: {exc}')
req('<imageSelectedColor value="0 0 0 0"/>' in xml, 'nav selected overlay not neutralized')
req('<imageDisabledColor value="0 0 0 0"/>' in xml, 'nav disabled overlay not neutralized')
for bad in ('0.25 0.62 0.92','0.63 0.36 0.88','0.25 0.42 0.96','0.58 0.32 0.88','0.66 0.36 0.86'):
    req(bad not in xml, f'old blue/purple palette remains: {bad}')
req('id="headerAccessMode"' in xml and 'size="265px 24px"' in xml, 'difficulty header area too small/missing')

journal_xml=read('gui/AgriLifeJournalDialog.xml')
req('textAutoWrap="true"' in journal_xml, 'journal explanatory summary does not wrap')
fr=read('translations/translation_fr.xml')
req('name="agrilife_journal_open" text="Historique AgriLife"' in fr, 'journal label not clarified')
req('Réaliste active' not in fr, 'obsolete fourth difficulty exposed in Assistance')

translations=sorted((root/'translations').glob('translation_*.xml'))
req(len(translations)==27, f'expected 27 translations, got {len(translations)}')
counts=[]
for p in translations:
    try:
        tree=ET.parse(p).getroot(); rows=tree.findall('.//text'); counts.append(len(rows))
        values={r.attrib.get('name'):r.attrib.get('text','') for r in rows}
        for key in ('agrilife_journal_open','agrilife_journal_dialog_title','agrilife_journal_dialog_summary_fmt','agrilife_help_difficulty_body'):
            req(values.get(key,'').strip()!='', f'{p.name} missing/empty {key}')
        req('%d' in values.get('agrilife_journal_dialog_summary_fmt',''), f'{p.name} lost journal %d placeholder')
    except Exception as exc: errors.append(f'{p.name} invalid: {exc}')
req(set(counts)=={5023}, f'l10n parity mismatch: {sorted(set(counts))}')

if errors:
    print('F02 UI FIX AUDIT: FAILED')
    for e in errors: print(' -',e)
    raise SystemExit(1)
print('F02 UI FIX AUDIT: OK - version=0.9.3.1, dialogs=3, languages=27, keys=5023')
