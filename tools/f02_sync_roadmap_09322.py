from pathlib import Path

section = '''
## Correction F02 0.9.3.22 - tableau de bord et carte Banque

- L'aide contextuelle supérieure du tableau de bord dispose de davantage de largeur et de contraste.
- La carte Banque est réalignée sur la grille des autres cartes.
- Le nom de la banque et le nom du conseiller sont affichés sur deux lignes distinctes.
- Le score de crédit contient uniquement sa valeur et son appréciation, sans nom de banque.
- F02 reste active jusqu'à validation dans Farming Simulator 25.
'''
marker = "## Correction F02 0.9.3.22 - tableau de bord et carte Banque"
for path in ("ROADMAP.md", "docs/ROADMAP.md"):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if marker not in text:
        p.write_text(text.rstrip() + "\n\n" + section.strip() + "\n", encoding="utf-8")
