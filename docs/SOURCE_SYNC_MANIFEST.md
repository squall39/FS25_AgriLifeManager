# Synchronisation du source GitHub

Version de référence : **0.7.8.0 TEST**

Le package joueur et le dépôt GitHub utilisent les mêmes chemins pour les fichiers de source et de configuration publiables.

## Source publiée

- `modDesc.xml` ;
- `src/` : Lua actif ;
- `gui/` : XML et définitions texte de l'interface ;
- `translations/` : l10n distribuée ;
- `tests/` : tests statiques et comportementaux ;
- `tools/` : vérification de release ;
- `data/` : configuration texte ;
- `placeables/` et `vehicles/` : Lua/XML publiables ;
- `docs/` : documentation technique et feuille de route ;
- `CHANGELOG.md` côté dépôt, dérivé du `CHANGELOG.txt` du package.

## Assets binaires

Les DDS, PNG, I3D, SHAPES et autres gros assets nécessaires au ZIP joueur ne sont pas automatiquement republiés dans le dépôt public. Ils restent dans le package lorsqu'ils sont nécessaires au fonctionnement du mod. Leur publication source dépend de leur origine et des droits de redistribution.

## Règle de synchronisation

Le dépôt ne conserve plus de copie permanente des anciennes builds ni de patches découpés. L'historique Git remplit ce rôle. Une build n'est annoncée comme synchronisée que lorsque son `modDesc.xml`, son source texte publié, ses tests, sa documentation et sa feuille de route correspondent à la même version.

La synchronisation source ne remplace pas la certification en jeu.
