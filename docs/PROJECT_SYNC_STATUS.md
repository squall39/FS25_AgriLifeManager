# État de synchronisation du projet - 0.9.3.97 TEST

## Référence de travail

- Version AgriLife Manager : **0.9.3.97 TEST**.
- `modDesc.xml` et `src/core/AgriLifeVersion.lua` sont alignés sur 0.9.3.97.
- Le multijoueur reste désactivé tant que la campagne réseau réelle n'est pas certifiée.
- Le ZIP de test conserve le nom `FS25_AgriLifeManager.zip`.

## Correctif actif

La 0.9.3.97 remplace l'approche finale de récupération d'outil par deux phases distinctes :

1. `HITCH_STAGE` utilise le GOTO natif FS25 pour rejoindre une zone de mise en place sur l'axe réel d'attelage.
2. `HITCH_DOCK` prend ensuite le relais avec un contrôle fermé basé sur les nœuds d'attelage réels du véhicule et de l'outil.

L'attelage n'est accepté que lorsque la distance réelle entre les nœuds compatibles atteint le seuil prévu. Les échecs de progression, divergence, blocage et timeout restent explicitement détectés.

## Test FS25 à reprendre

Scénario prioritaire : **Louise Martin + MT635 + cultivateur 980 + champ 45**.

Attendu :

- sélection du salarié, véhicule, outil et champ ;
- trajet vers un point `HITCH_STAGE_24`, `HITCH_STAGE_20` ou `HITCH_STAGE_16` ;
- passage en `HITCH_DOCK` ;
- diminution réelle du `jointGap` ;
- attelage physique du 980 ;
- départ vers le champ 45 ;
- démarrage du travail demandé.

La fonction reste **À TESTER EN JEU** tant que cette chaîne n'a pas été validée dans Farming Simulator 25.

## GitHub

La source active 0.9.3.97 doit être synchronisée sur `main` sans archives de transfert, backups, logs, anciens audits ponctuels ni doublons de build. Les assets binaires ne sont conservés dans Git que lorsqu'ils sont utiles au projet et que leur publication est appropriée.

La validation GitHub confirme l'alignement du source, pas la certification fonctionnelle FS25.
