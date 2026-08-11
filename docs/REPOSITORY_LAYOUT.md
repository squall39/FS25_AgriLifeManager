# Organisation du dépôt

Le dépôt GitHub représente la source de développement lisible d'AgriLife Manager. Il ne doit pas servir de stockage de patches temporaires ou de copies multiples du même code.

## Racine

- `modDesc.xml` : déclaration FS25 de la version source synchronisée.
- `src/` : code Lua actif.
- `gui/` : définitions XML de l'interface lorsque publiables.
- `translations/` : fichiers l10n lorsque synchronisés.
- `tests/` : contrôles et tests du projet.
- `tools/` : outils de vérification et de packaging.
- `docs/` : documentation technique et conception.
- `development/` : notes de chantier uniquement, sans copie du source actif.

## Source active

Un fichier qui fait partie de la build courante doit être publié à son chemin réel. Les patches découpés ne sont plus utilisés comme représentation principale du code.

L'historique Git conserve naturellement les anciennes versions, ce qui évite de multiplier des dossiers `step`, `patch`, `part` ou `backup` dans la branche principale.

## Assets binaires

Le ZIP joueur contient aussi des textures, formes 3D et autres fichiers binaires. Ils ne sont ajoutés au dépôt public que si leur origine et leurs droits de redistribution sont compatibles avec cette publication.

Le fait qu'un asset soit présent dans une build locale ne suffit pas à autoriser automatiquement sa republication publique.

## Build joueur

Le package destiné à FS25 conserve toujours le nom `FS25_AgriLifeManager.zip`. Le numéro de version est stocké dans `modDesc.xml`, le code de version et le changelog.
