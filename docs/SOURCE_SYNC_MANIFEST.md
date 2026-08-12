# Synchronisation du source GitHub

Version de référence : **0.9.1.0 TEST**

Le package joueur reste la source de vérité exécutable. Le dépôt GitHub publie les sources texte maintenables et la feuille de route complète. Une synchronisation de source ne vaut jamais certification en jeu.


## Fermeture d'écriture 0.9.1.0

- `src/modules/bank/BankRoadmap3Completion.lua` : financement marché/difficulté, consultation, comptabilité avancée, fiscalité, amortissements, bilan et CAF ;
- `src/modules/economy/EconomyAccountingRoadmapCompletion.lua` : métadonnées et filtres du grand livre ;
- `src/modules/dashboard/DashboardRoadmapWritingCompletion.lua` : synthèses finance/carrière ;
- `src/ui/AgriLifeRoadmapWritingCompletionUI.lua` : affichages Banque/Carrière ;
- `src/ui/AgriLifeInterfaceRoadmap2Completion.lua` : politique responsive ;
- `tools/audit_roadmap_writing_completion.py` : gate dédié à la fermeture d'écriture ;
- `tests/roadmap_writing_completion_spec.lua` : contrôle statique Lua de la présence des briques ;
- `docs/ROADMAP.md` : statut 0.9.1.0 additif, sans suppression d'idées.


## Tutoriel / Assistance 0.9.1.0

- `src/ui/AgriLifeTutorialRoadmapCompletion.lua` : guide initial 13 pages et raccordement au parcours guidé, sans réécrire le HomeFrame historique ;
- `gui/helpLine.xml` : Assistance FS25 reconstruite sur les mêmes clés l10n que le guide ;
- `tools/verify_release.py` : gate mis à jour pour les 13 rubriques et l'Assistance localisée ;
- `docs/L10N_AUDIT.md` : parité des 27 langues et dette linguistique héritée ;
- `translations/` : 5 047 clés par langue dans le package joueur, sans clé manquante ou vide.

Le dépôt public peut rester un miroir texte partiel. Le ZIP joueur 0.9.1.0 reste la source de vérité exécutable pour les fichiers `gui/`, les traductions complètes et les assets.

## Source Étape 9

- `src/core/AgriLifeNetworkRoadmap9.lua` ;
- `src/core/AgriLifeMigrationManager.lua` ;
- `src/core/AgriLifePersistence.lua` ;
- `src/core/AgriLifeCore.lua` ;
- `src/modules/compatibility/CompatibilityRoadmap9.lua` ;
- `src/modules/finalization/FinalizationRoadmap9.lua` ;
- `tests/finalization_roadmap9_spec.lua` ;
- `tools/audit_l10n_usage.py` ;
- `tools/audit_publication.py` ;
- `tools/package_release.py` ;
- `tools/verify_release.py` ;
- `docs/GLOSSARY.md` ;
- `docs/USER_GUIDE.md` ;
- `docs/THIRD_PARTY_COMPONENTS.md` ;
- `docs/PUBLICATION_CHECKLIST.md` ;
- `docs/STEP9_FINALIZATION.md` ;
- `docs/ROADMAP.md` complet et additif ;
- `modDesc.xml` et `src/core/AgriLifeVersion.lua` en 0.9.1.0 ;
- `translations/` avec 27 langues en parité.

## Fonctionnement du packaging

`tools/package_release.py` propose deux profils :

- `test` : conserve les tests, outils et documents de développement utiles ;
- `public` : retire les tests et outils du ZIP joueur tout en conservant le contenu nécessaire au mod.

Les deux profils passent d'abord par les gates XML/Lua/l10n/publication.

## Assets binaires

Les DDS, PNG, I3D, SHAPES et autres gros assets nécessaires au ZIP joueur ne sont pas automatiquement republiés dans le dépôt public. Leur publication source dépend de leur origine et des droits de redistribution.

## Règle de synchronisation

Une build livrée doit porter le même numéro de version, le même état de roadmap et la même liste de sources actives entre le package et GitHub. Les idées validées restent additives et ne sont jamais supprimées lors d'une simple mise à jour d'avancement.
