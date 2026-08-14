# Synchronisation du source GitHub

Version de test préparée : **0.9.3.26 TEST**
Version déclarée sur `main` : **0.9.3.26 TEST**
Date : **14 août 2026**

La build joueur 0.9.3.26 reste la référence exécutable complète. F01 et F02 sont validées en jeu. F03 Banque est active. Le retest XP 0.9.3.26 est reporté et ne bloque pas la reprise F03.

## Éléments 0.9.3.26 présents sur `main`

- `modDesc.xml` déclare 0.9.3.26 ;
- `src/core/AgriLifeVersion.lua` déclare 0.9.3.26 ;
- `src/core/AgriLifeDecisionGuide.lua` est présent ;
- `src/modules/career/Career6Service.lua` est présent et contient la progression 1 étoile tous les 1 000 XP jusqu’à 10 étoiles ;
- `src/modules/career/Career6Hud.lua` sépare l’XP total de la progression du palier courant ;
- `CHANGELOG.md`, `TESTING.md`, `ROADMAP.md`, `docs/ROADMAP.md` et `docs/PROJECT_SYNC_STATUS.md` contiennent le suivi de la campagne actuelle ;
- les workflows temporaires de synchronisation ont été retirés.

## Miroir encore incomplet

La build ZIP reste la référence complète tant que les chemins actifs suivants ne sont pas présents et vérifiés sur `main` :

- `src/modules/bank/Bank6Service.lua` ;
- `src/modules/bank/Bank6Events.lua` ;
- `src/modules/bank/BankModule.lua` ;
- `src/modules/bank/BankCatalog09325.lua` ;
- `src/modules/administration/Administration6Service.lua` ;
- `src/modules/administration/AdministrationRoadmap6.lua` ;
- le répertoire `translations/` ;
- `tools/verify_release.py`.

Les modifications F03 de certains gros fichiers déjà présents restent à comparer avec la build avant de déclarer le miroir complet.

Le connecteur GitHub peut refuser certaines écritures volumineuses. Un fichier n’est jamais considéré synchronisé tant que sa présence et son contenu n’ont pas été vérifiés sur `main`.

## Priorité de maintenance

1. Continuer à réduire les gaps du miroir sans modifier la build de test.
2. Ne pousser sur `main` que des fichiers vérifiés par rapport au ZIP de référence.
3. Conserver F03 comme seule phase de test active.
4. Garder le retest XP dans la liste des validations différées.

## Règles de synchronisation

- distinguer clairement la version déclarée et l’état réel du miroir ;
- ne jamais annoncer un fichier comme synchronisé s’il n’est pas présent et vérifié ;
- conserver la build joueur comme référence exécutable tant que le miroir est incomplet ;
- retirer les helpers temporaires après usage ;
- aucun tiret cadratin dans les contenus du projet.
