# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier, assurances, leasing, occasion et systèmes de gestion associés.

## État courant

- Version de travail : **0.9.3.13 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : infrastructure prévue, publication désactivée tant que la campagne réseau n'est pas certifiée
- Build de test actuelle : `FS25_AgriLifeManager_0.9.3.13_UI_ENTERPRISE_WORKSHOP_FIX.zip`
- F01 : validée en jeu
- F02 : active, stabilisation et cohérence de l'interface
- Phase Banque métier : en attente de validation complète de F02

## Feuille de route

`ROADMAP.md` est le registre maître additif du projet. Une idée validée ne doit pas disparaître lors d'une mise à jour.

Le cycle de travail reste : correction -> test ciblé en jeu -> validation complète -> phase suivante.

## GitHub

La branche `main` est en cours de remise au propre pour devenir le miroir complet du mod dézippé. Le dépôt doit contenir la source active, les traductions, les ressources GUI, les véhicules, les placeables et les assets nécessaires au mod lorsque leur redistribution est autorisée.

Le ZIP reste l'artefact utilisé pour les tests FS25 et la distribution. Tant que la synchronisation complète des 427 fichiers de la build 0.9.3.13 n'est pas terminée, `main` ne doit pas être présenté comme un miroir octet par octet du ZIP.

Voir `docs/PROJECT_SYNC_STATUS.md`, `docs/SOURCE_SYNC_MANIFEST.md` et `docs/REPOSITORY_LAYOUT.md`.

## Organisation

- `src/` : code Lua actif
- `gui/` : interface et ressources UI
- `translations/` : localisation
- `data/` : configurations
- `vehicles/` et `placeables/` : contenu du package
- `tests/` : contrôles automatisés
- `tools/` : audits et packaging
- `docs/` : documentation technique et état de reprise

Les anciens plans de test, rapports liés à des builds dépassées, workflows temporaires et doublons documentaires ne restent pas sur `main`. L'historique Git conserve les anciennes versions.

## Règles de développement

- Trois difficultés : **Facile / Normal / Difficile**.
- Chaque fonctionnalité doit avoir une conséquence réelle en jeu.
- Une fonction non validée dans FS25 reste à certifier.
- Les intégrations externes restent optionnelles.
- Les 27 langues distribuées gardent le même jeu de clés.
- La version reste sous `1.0.0.0` tant que le projet n'est pas entièrement certifié.
- Aucun em dash dans les contenus du projet.
- Aucun branding de générateur ou attribution automatique dans les contenus publics.

© 2026 Chez_Squall.
