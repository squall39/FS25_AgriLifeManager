# Synchronisation du source GitHub

Version de référence : **0.9.3.13 TEST**  
Date : **13 août 2026**

La build ZIP joueur reste la référence exécutable utilisée dans Farming Simulator 25 pendant la campagne de test. La branche `main` est en cours de conversion vers un miroir complet du mod dézippé.

## Build locale 0.9.3.13

- build : `FS25_AgriLifeManager_0.9.3.13_UI_ENTERPRISE_WORKSHOP_FIX.zip` ;
- SHA-256 : `60c0be2f728c96dcabc19ed83d69c6b05c0325f4bc41c6084c16d76b56cf4a48` ;
- arborescence décompressée contrôlée : **427 fichiers** ;
- sources/documents textuels : **253** ;
- actifs binaires : **174** ;
- taille décompressée : environ **70 MiB**.

## Nettoyage effectué sur main

Le dépôt a été débarrassé des anciens workflows à usage unique, des helpers de transfert devenus inutiles, des anciens plans de test versionnés, des rapports statiques dépassés, des documents Step 8/Step 9 temporaires et de plusieurs doublons documentaires.

Le workflow permanent conservé est le contrôle de style d'écriture.

## Source 0.9.3.13 déjà restaurée

- version GitHub et runtime alignées sur `0.9.3.13` ;
- UI : HelpIntegration, MiniPdaProgress, Step7UI et Step8UI restaurés ;
- coeur : Result, Logger, Lifecycle, MissionContext, Settings, SubscriptionManager, ModuleContract et ModuleRegistry restaurés ;
- bootstrap : `AgriLifeBootstrap.lua` restauré ;
- Company : service, événements réseau et module restaurés ;
- Journal : service et module restaurés ;
- Integrity : service et module restaurés ;
- Legal : service et module restaurés ;
- Qualifications : service et module restaurés ;
- People : module et événements réseau restaurés ;
- Career : module, événements réseau, HUD et tracker transport restaurés ;
- Payroll : module restauré ;
- Enterprise : module restauré ;
- Administration : module restauré ;
- Market : module et pont Workshop parts Roadmap8 restaurés.

## Gaps encore ouverts

`main` n'est pas encore un miroir octet par octet de la build 0.9.3.13. Restent notamment à synchroniser :

- coeur : `AgriLifeCore.lua` et `AgriLifePersistence.lua` ;
- services et extensions encore absents dans People, Career, Exam, Payroll, Enterprise, Administration et Market ;
- les 27 fichiers `translations/` ;
- les tests et outils courants manquants après contrôle de leur utilité ;
- les arbres `data/`, `vehicles/`, `placeables/`, `resources/`, `textures/` et les assets GUI nécessaires qui ne sont pas encore présents ;
- les binaires DDS/PNG/I3D/SHAPES utiles au package lorsque leur redistribution est autorisée ;
- les fichiers de package racine nécessaires pour obtenir un miroir dézippé fidèle.

Aucun gap ci-dessus ne doit être présenté comme terminé tant que le chemin n'est pas réellement présent et vérifié sur `main`.

## État fonctionnel à conserver

F01 reste validée. F02 est encore en cours et la 0.9.3.13 doit être retestée avant d'ouvrir la phase Banque métier. Voir `docs/PROJECT_SYNC_STATUS.md` et `docs/SESSION_HANDOFF_2026-08-13.md`.

## Règle de synchronisation

- la version GitHub et la version de test doivent être identifiées clairement ;
- une différence entre `main` et la build doit être signalée ;
- aucun fichier historique ne doit rester sur `main` uniquement pour conserver une ancienne version ;
- l'historique Git remplit ce rôle ;
- un asset actif n'est supprimé qu'après contrôle de ses références et de ses droits de redistribution ;
- aucun em dash, branding de générateur ou attribution automatique dans les contenus du projet.
