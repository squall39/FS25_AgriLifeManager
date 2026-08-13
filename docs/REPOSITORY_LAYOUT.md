# Organisation du dépôt

Le dépôt GitHub doit devenir la source complète, lisible et maintenable d'AgriLife Manager sous forme dézippée. Le ZIP joueur reste un artefact séparé pour les tests et la distribution.

## Racine

- `README.md` : présentation et état courant.
- `ROADMAP.md` : feuille de route de référence.
- `CHANGELOG.md` : historique des versions de développement.
- `modDesc.xml` : déclaration FS25 de la version synchronisée.
- `CONTRIBUTING.md`, `TESTING.md`, `SOURCE_PUBLICATION.md`, `COPYRIGHT.md` : règles du projet.

## Source active du mod

- `src/` : code Lua actif.
- `gui/` : XML et ressources de l'interface.
- `translations/` : l10n.
- `data/` : configurations.
- `placeables/` et `vehicles/` : fichiers du package.
- textures, DDS, PNG, I3D, SHAPES et autres assets réellement utilisés par le mod lorsque leur redistribution est autorisée.
- toute ressource référencée par `modDesc.xml`, Lua, XML, I3D, GUI, véhicule ou placeable.

## Développement

- `tests/` : contrôles automatisés.
- `tools/` : vérification et packaging.
- `docs/` : documentation technique et état de reprise utile.

## Ce qui ne doit plus revenir

- dossiers `builds/` servant de seconde archive ;
- morceaux de transfert temporaires ;
- workflows de synchronisation à usage unique ;
- copies de Lua à plusieurs emplacements ;
- captures et logs temporaires ;
- anciens plans de test gardés uniquement pour l'historique ;
- doublons de documents de conception.

L'historique Git conserve les versions précédentes. `main` doit représenter l'état de travail actuel, pas empiler toutes les anciennes versions.

## Assets binaires

L'objectif est que `main` reflète le mod complet dézippé, y compris les assets binaires nécessaires au fonctionnement. Un asset tiers ne peut être publié que si sa redistribution est autorisée. Toute exception doit être documentée explicitement, jamais remplacée par un miroir partiel présenté comme complet.
