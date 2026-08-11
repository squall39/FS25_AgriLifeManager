# Synchronisation du source GitHub

Version de référence : **0.7.9.0 TEST**

Le package joueur et le dépôt GitHub utilisent les mêmes chemins pour les fichiers de source et de configuration publiables. La feuille de route complète est synchronisée automatiquement à chaque nouveau ZIP.

## Source de l'étape 7

- `src/modules/market/DynamicMarketRoadmap7.lua` ;
- `src/modules/contracts/CommercialContractsRoadmap7.lua` ;
- `src/modules/contracts/CommercialContractsRoadmap7Events.lua` ;
- `src/modules/assets/AssetLifecycleRoadmap7.lua` ;
- `src/modules/compatibility/CompatibilityRoadmap7.lua` ;
- `src/ui/AgriLifeStep7UI.lua` ;
- `gui/AgriLifeHomeFrame.xml` ;
- `tests/contracts_markets_roadmap7_spec.lua` ;
- `tools/verify_release.py` ;
- `modDesc.xml` ;
- `src/core/AgriLifeVersion.lua` ;
- `translations/` avec les clés Étape 7 ;
- `docs/ROADMAP.md` complet et additif.

## Source publiée

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

Une build n'est considérée prête à être envoyée que lorsque `ROADMAP.md` sur GitHub et `docs/ROADMAP.md` dans le package décrivent le même registre maître et le même état d'avancement. Une synchronisation de source ne vaut jamais certification en jeu.
