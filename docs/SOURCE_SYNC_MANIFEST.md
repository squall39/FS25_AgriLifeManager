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

## État GitHub

Le dépôt a été nettoyé des anciens workflows à usage unique, des helpers devenus inutiles, des anciens plans de test versionnés, des rapports statiques dépassés et de plusieurs doublons documentaires.

`main` n'est pas encore déclaré miroir octet par octet de la build 0.9.3.13 tant que les fichiers manquants du package complet n'ont pas tous été synchronisés.

## État fonctionnel à conserver

F01 reste validée. F02 est encore en cours et la 0.9.3.13 doit être retestée avant d'ouvrir la phase Banque métier. Voir `docs/PROJECT_SYNC_STATUS.md` et `docs/SESSION_HANDOFF_2026-08-13.md`.

## Règle de synchronisation

- la version GitHub et la version de test doivent être identifiées clairement ;
- une différence entre `main` et la build doit être signalée ;
- aucun fichier historique ne doit rester sur `main` uniquement pour conserver une ancienne version ;
- l'historique Git remplit ce rôle ;
- un asset actif n'est supprimé qu'après contrôle de ses références et de ses droits de redistribution.
