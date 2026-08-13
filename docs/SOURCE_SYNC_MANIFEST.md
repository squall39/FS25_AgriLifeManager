# Synchronisation du source GitHub

Version de référence : **0.9.3.13 TEST**  
Date : **13 août 2026**

Le dépôt sert de miroir de travail pour le code et la documentation. La build ZIP joueur reste la référence exécutable utilisée dans Farming Simulator 25.

## État de la build locale 0.9.3.13

- build : `FS25_AgriLifeManager_0.9.3.13_UI_ENTERPRISE_WORKSHOP_FIX.zip` ;
- SHA-256 : `60c0be2f728c96dcabc19ed83d69c6b05c0325f4bc41c6084c16d76b56cf4a48` ;
- arborescence décompressée contrôlée : **427 fichiers** ;
- sources/documents textuels : **253** ;
- actifs binaires : **174** ;
- taille décompressée : environ **70 MiB**.

## État fonctionnel à conserver

F01 reste validée. F02 est encore en cours et la 0.9.3.13 doit être retestée avant d'ouvrir la phase Banque métier. Voir `docs/PROJECT_SYNC_STATUS.md` et `docs/SESSION_HANDOFF_2026-08-13.md`.

## Règle de synchronisation

La documentation GitHub doit toujours donner la version exacte à reprendre, les correctifs en attente de validation et le prochain test. Une différence entre le dépôt et la build joueur doit être signalée ; elle ne doit jamais être présentée comme validée implicitement.
