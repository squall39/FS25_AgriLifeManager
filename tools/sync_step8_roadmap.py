from pathlib import Path
import re

ROOT = Path("ROADMAP.md")
STEP8 = Path("docs/STEP8_WORKSHOP_ROADMAP.md")
CLAIMS = Path("docs/STEP8_INSURANCE_CLAIMS.md")

root = ROOT.read_text(encoding="utf-8")
step8 = STEP8.read_text(encoding="utf-8").strip()
claims = CLAIMS.read_text(encoding="utf-8").strip()

step8 = step8.replace(
    "# Étape 8 - Atelier, Concessionnaire & Gestion technique du parc",
    "# 8 - Module Atelier, Concessionnaire & Gestion technique du parc",
    1,
)

state = (
    "> **État code 0.8.1.0 TEST :** l'ensemble des scripts prévus pour l'étape 8 est écrit et intégré. "
    "Le pont Constats -> Responsabilité -> Atelier -> Assurance ainsi que le bonus-malus assurance sont écrits et intégrés. "
    "Les cases restent ouvertes jusqu'à la certification FS25 réelle, sauvegarde/rechargement et contrôle du log."
)
heading = "# 8 - Module Atelier, Concessionnaire & Gestion technique du parc\n"
if state not in step8:
    step8 = step8.replace(heading, heading + "\n" + state + "\n", 1)

insert_before = "## Historique technique, économique et valeur de revente"
if "## Constats, responsabilité, prise en charge et bonus-malus" not in step8:
    step8 = step8.replace(insert_before, claims + "\n\n" + insert_before, 1)

pattern = re.compile(r"# 8 - Module Atelier.*?\n---\n\n# 9 - Finalisation", re.S)
replacement = step8.rstrip() + "\n\n---\n\n# 9 - Finalisation"
root, count = pattern.subn(replacement, root, count=1)
if count != 1:
    raise SystemExit("Unable to locate Step 8 section in ROADMAP.md")

root = re.sub(
    r"> \*\*État code [^\n]+",
    "> **État code 0.8.1.0 TEST :** les étapes 4 Entreprise, 5 Carrière & Qualifications, 6 Administration, 7 Contrats & Marchés et 8 Atelier, Concessionnaire & Gestion technique du parc sont écrites et intégrées. Le pont Constats -> Responsabilité -> Atelier -> Assurance ainsi que le bonus-malus assurance sont également écrits et intégrés. Leur certification FS25 réelle reste à effectuer avant de fermer leurs cases de validation terrain.",
    root,
    count=1,
)
root = re.sub(
    r"\*\*Statut actuel :[^\n]+",
    "**Statut actuel : développement pré-1.0 - Étapes 4, 5, 6, 7 et 8 écrites/intégrées ; constats, responsabilité Atelier/Assurance et bonus-malus écrits/intégrés ; certification FS25 réelle à poursuivre avant validation finale.**",
    root,
    count=1,
)

ROOT.write_text(root, encoding="utf-8")
print("ROADMAP.md Step 8 synchronized to 0.8.1.0")
