# Synchronisation du source GitHub

Version de test préparée : **0.9.3.28 TEST**
Version déclarée sur `main` : **0.9.3.28 TEST**
Date : **14 août 2026**

La build joueur 0.9.3.28 reste la référence exécutable complète. F01 et F02 sont validées en jeu. F03 Banque reste active. La préparation transversale 0.9.3.28 est écrite et auditée statiquement, mais elle n'est pas certifiée en jeu.

## Éléments 0.9.3.28 présents et vérifiés sur `main`

- `modDesc.xml` et `src/core/AgriLifeVersion.lua` déclarent 0.9.3.28 ;
- `src/core/AgriLifeGameTime09328.lua` centralise année, période, jours par mois et progression du mois FS25 ;
- `src/core/AgriLifeTimeBindings09328.lua` raccorde les services mensuels au même numéro de période ;
- `src/modules/payroll/OwnerRemuneration09328.lua` ajoute la gestion explicite de la rémunération du dirigeant ;
- `CHANGELOG.md` et `TESTING.md` enregistrent la préparation 0.9.3.28 et conservent F03 Banque comme phase de certification active.

## Éléments 0.9.3.28 présents dans le ZIP mais pas encore garantis sur `main`

- `src/modules/assets/CumaEquipment09328.lua` ;
- `src/modules/economy/AgriculturalSupport09328.lua` ;
- `src/modules/economy/BusinessResilience09328.lua` ;
- `src/ui/AgriLifeDecisionHooks09328.lua` ;
- `src/ui/AgriLifeCumaUI09328.lua` ;
- les modifications 0.9.3.28 de `src/modules/enterprise/ManagementAdvisor09327.lua` ;
- les modifications UI 0.9.3.28 de `src/ui/AgriLifeHomeFrame.lua`, `src/ui/AgriLifeUIManager.lua` et `gui/AgriLifeHomeFrame.xml` ;
- les 27 traductions avec les nouvelles clés 0.9.3.28 ;
- `tools/verify_release.py` ;
- `ROADMAP.md` et `docs/ROADMAP.md` doivent encore être comparés avec les copies de la build.

Une tentative d'écriture directe du module d'aide agricole a été refusée par le connecteur. Aucun fichier refusé n'est présenté comme synchronisé.

## Miroir historique encore incomplet

Plusieurs gros fichiers Banque et Administration déjà signalés dans les versions précédentes restent absents ou non comparés sur `main`. Le dépôt ne doit donc pas être utilisé comme remplacement byte pour byte du ZIP de test tant que ce chantier de miroir n'est pas terminé.

## Règles de synchronisation

- distinguer clairement la version déclarée et l'état réel du miroir ;
- ne jamais annoncer un fichier comme synchronisé s'il n'est pas présent et vérifié ;
- conserver la build joueur comme référence exécutable tant que le miroir est incomplet ;
- retirer les helpers temporaires après usage ;
- aucun tiret cadratin dans les contenus du projet.
