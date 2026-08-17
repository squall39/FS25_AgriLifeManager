# Manifeste de synchronisation source

Version de référence : **0.9.3.97 TEST**.

## Source active à maintenir sur GitHub

- `modDesc.xml` ;
- `src/` : Lua actif ;
- `gui/` : définitions d'interface et ressources texte ;
- `translations/` : fichiers l10n distribués ;
- `data/` : configurations texte ;
- `placeables/` et `vehicles/` : Lua/XML publiables ;
- `tests/` et `tools/` : contrôles utiles au développement ;
- `docs/` : documentation technique encore active ;
- `CHANGELOG.md`, `ROADMAP.md` et `TESTING.md`.

## État 0.9.3.97

- version interne : 0.9.3.97 ;
- multijoueur : désactivé ;
- correctif actif : staging natif puis accostage d'attelage en boucle fermée ;
- test prioritaire : Louise Martin + MT635 + 980 + champ 45 ;
- certification FS25 : encore requise ;
- sauvegardes, logs, backups, archives de transfert et anciens rapports ponctuels : exclus de la branche principale.

## Règle de synchronisation

Le ZIP joueur et GitHub doivent décrire le même état du code actif. GitHub n'a pas vocation à conserver une seconde archive de chaque build. L'historique Git conserve les versions précédentes.

Le mémo personnel de Gérard reste hors du dépôt GitHub.
