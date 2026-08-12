# Synchronisation du source GitHub

Version de référence : **0.9.3.0 TEST**

Build jouable de référence : `FS25_AgriLifeManager_0.9.3.0_TEST_final.zip`  
SHA-256 : `303a1f11111e8e8d40be65f5e93081dec0686e89e2c69d05ba2f10521202a7fa`

Le package joueur reste la source de vérité exécutable. Le dépôt GitHub conserve les sources maintenables, la feuille de route, le registre d’idées, les audits et l’historique utile. Une synchronisation de source ne vaut jamais certification en jeu.

## Inventaire de référence 0.9.3.0

- 424 fichiers dans la build TEST ;
- 116 `extraSourceFiles` dans `modDesc.xml` ;
- 2 spécialisations Lua locales supplémentaires (`FieldServiceKit6`, `OilServicePoint6`) ;
- **118 Lua runtime actifs** ;
- 131 fichiers Lua dans le projet, dont 13 tests/specs non chargés en runtime ;
- 84 XML ;
- 27 langues ;
- 5 023 clés l10n par langue.

## Fermeture Atelier 8.1

Les modules de fermeture 0.9.2 restent la base de l’Atelier 0.9.3 :

- `WorkshopRoadmap81Completion.lua` : parc maintenable complet et verrou casse lourde ;
- `WorkshopRecoveryRoadmapCompletion.lua` : dépannage/remorquage vers concessionnaire ou atelier ;
- `WorkshopPhysicalPartsRoadmapCompletion.lua` : commandes/palettes physiques et stock atelier ;
- `WorkshopTurnaroundLoanerRoadmapCompletion.lua` : délai atelier personnel 2 à 3 fois supérieur, prêt concessionnaire et location de secours ;
- `InsuranceWorkshopRoadmapCompletion.lua` : couverture selon cause, assistance séparée et dépenses réellement engagées.

Le camion de service achetable par le joueur est supprimé. Les huiles, lubrifiants, cuves et points de service utiles restent conservés.

## Nouveaux systèmes 0.9.3.0

- `WorkshopBehavioralWearRoadmapCompletion.lua` : usure comportementale AgriLife et neutralisation de l’usure/réparation vanilla comme autorité mécanique concurrente ;
- `VehicleEnergyRoadmapCompletion.lua` : consommation carburant/énergie selon puissance, charge, régime, comportement, état mécanique et difficulté ;
- `InsuranceAccidentAuthorityRoadmapCompletion.lua` : constat joueur/IA, autorité du patron et classement perte totale/épave ;
- `OperationalHoursRoadmapCompletion.lua` : horaires centralisés Banque, concessionnaire, atelier personnel, usines et points de vente ;
- `AgriLifeAccidentStatementDialog.lua` : interface de constat pour conducteur joueur.

## Documentation et campagne active

- `docs/IDEA_REGISTRY.md` : état d’intégration réel jusqu’à WRK-023 / ENE-001 / INS-003 / OPS-001 ;
- `ROADMAP.md` et `docs/ROADMAP.md` : registre synchronisé automatiquement et conservé de manière additive ;
- `docs/FS25_TEST_ROADMAP_0.9.3.0.md` : campagne active Facile → Normal → Difficile ;
- `TESTING.md` : pointe sur la campagne 0.9.3.0 ;
- `docs/PROJECT_SYNC_STATUS.md` : statut courant de la build et du dépôt.

## Assets binaires

La build de référence contient environ 54 Mo de DDS/PNG/I3D et autres assets binaires. Le connecteur GitHub utilisé dans cette session ne permet pas de verser directement en masse l’arborescence binaire locale. Ces fichiers ne doivent donc pas être déclarés comme un miroir GitHub complet tant qu’un transfert binaire dédié n’a pas été réalisé.

Leur source exécutable de vérité reste le ZIP 0.9.3.0 validé. Les fichiers binaires devenus inutiles ne doivent pas être rajoutés sur `main` ; les restes du camion de service sont exclus.

## Nettoyage GitHub 2026-08-12

Les anciens runners, workflows et payloads one-shot de synchronisation 0.9.3 incomplets ont été supprimés de `main`. Les documents historiques utiles (anciens audits et anciennes roadmaps de test) sont conservés volontairement pour traçabilité.

## Règle de synchronisation conversation → projet

Une décision explicitement validée doit être enregistrée dans la roadmap et son registre maître. Si elle change le comportement joueur, tutoriel et Assistance sont mis à jour dans toutes les langues distribuées. GitHub et la build de référence doivent ensuite refléter la même décision. Une fonction codée mais non certifiée reste `À certifier`.
