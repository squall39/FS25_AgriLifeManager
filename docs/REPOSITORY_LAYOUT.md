# Organisation du dépôt

Le dépôt GitHub représente la source lisible et maintenable d'AgriLife Manager. Le ZIP joueur reste un artefact séparé.

## Racine

- `README.md` : présentation et état courant.
- `ROADMAP.md` : feuille de route de référence.
- `CHANGELOG.md` : historique des versions de développement.
- `modDesc.xml` : déclaration FS25 de la version synchronisée.
- `CONTRIBUTING.md`, `TESTING.md`, `SOURCE_PUBLICATION.md`, `COPYRIGHT.md` : règles du projet.

## Source active

- `src/` : code Lua actif.
- `gui/` : XML et définitions texte de l'interface publiables.
- `translations/` : l10n.
- `data/` : configurations texte.
- `placeables/` et `vehicles/` : Lua/XML publiables du package.
- `tests/` : contrôles automatisés.
- `tools/` : vérification et packaging.
- `docs/` : documentation technique.
- `development/` : notes de chantier uniquement, sans copie du source actif.

## Ce qui ne doit plus revenir

- dossiers `builds/` servant de seconde archive ;
- patches découpés ;
- copies de Lua à plusieurs emplacements ;
- worklogs datés laissés à la racine ;
- anciens plans de test liés à une build 0.6.x ;
- doublons de documents de conception.

L'historique Git conserve les versions précédentes.

## Assets binaires

Les assets binaires du package joueur restent séparés lorsque leur publication source n'est pas nécessaire ou que leurs droits de redistribution ne sont pas établis. Le dépôt ne doit pas devenir un miroir lourd du ZIP joueur.
