# Synchronisation du source GitHub

Version package de référence : **0.8.0.0 TEST**

Le package joueur reste la source de vérité exécutable. GitHub publie la source texte maintenable lorsque le connecteur permet un transfert exact du fichier. Il ne faut jamais publier une copie tronquée ou reconstruite approximativement d'un gros fichier uniquement pour afficher un miroir artificiellement « complet ».

## Étape 8

Documentation déjà synchronisée :

- `docs/STEP8_WORKSHOP_ROADMAP.md` : cahier des charges complet et additif ;
- `docs/STEP8_IMPLEMENTATION_STATUS.md` : état 0.8.0.0 et contrôles ;
- `docs/IMPLEMENTATION_MATRIX.md` : Étape 8 écrite / à certifier ;
- `docs/VERIFICATION_REPORT.md` : résultats de vérification 0.8.0.0 ;
- `README.md` : état projet 0.8.0.0.

Le package 0.8.0.0 contient également les sources Étape 8 suivantes aux chemins du `modDesc.xml` :

- `src/modules/workshop/WorkshopRoadmap8.lua` ;
- `src/modules/market/DynamicMarketRoadmap8.lua` ;
- `src/modules/assets/AssetLifecycleRoadmap8.lua` ;
- `src/modules/compatibility/CompatibilityRoadmap8.lua` ;
- `src/ui/AgriLifeStep8UI.lua` ;
- mises à jour UI, tests, l10n et `modDesc.xml`.

Le gros fichier `WorkshopRoadmap8.lua`, les traductions complètes et certains fichiers UI ne doivent être marqués « synchronisés GitHub » qu'après transfert exact. Le connecteur utilisé dans cette session n'accepte pas directement un chemin de fichier local pour ces gros contenus texte. Le dépôt documente donc explicitement cette limite au lieu de prétendre à tort que le miroir est complet.

## Assets binaires

Les DDS, PNG, I3D, SHAPES et autres gros assets nécessaires au ZIP joueur ne sont pas automatiquement republiés dans le dépôt public. Ils restent dans le package lorsqu'ils sont nécessaires au fonctionnement du mod. Leur publication source dépend de leur origine et des droits de redistribution.

## Règle de feuille de route

Les idées validées restent additives. `docs/STEP8_WORKSHOP_ROADMAP.md` conserve la totalité des idées Étape 8 validées et `docs/ROADMAP.md` du package 0.8.0.0 contient la section fusionnée complète. La certification en jeu reste distincte de l'écriture du code.
