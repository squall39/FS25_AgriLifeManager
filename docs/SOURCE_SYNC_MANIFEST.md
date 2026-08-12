# Synchronisation du source GitHub

Version de référence : **0.9.1.0 TEST**

Le package joueur reste la source de vérité exécutable. GitHub publie les sources texte maintenables et la feuille de route complète. Une synchronisation de source ne vaut jamais certification en jeu.

## Fermeture d'écriture 0.9.1.0

Publiés sur GitHub :

- `src/modules/bank/BankRoadmap3Completion.lua`, source exact vérifié par SHA-256 ;
- `src/modules/economy/EconomyAccountingRoadmapCompletion.lua` ;
- `src/modules/dashboard/DashboardRoadmapWritingCompletion.lua` ;
- `src/ui/AgriLifeRoadmapWritingCompletionUI.lua` ;
- `src/ui/AgriLifeInterfaceRoadmap2Completion.lua` ;
- `tools/audit_roadmap_writing_completion.py` ;
- `tests/roadmap_writing_completion_spec.lua` ;
- `src/core/AgriLifeVersion.lua` en 0.9.1.0 ;
- `modDesc.xml`, source exact du package vérifié par SHA-256 ;
- `ROADMAP.md`, copie maître exacte du `docs/ROADMAP.md` embarqué, vérifiée par SHA-256.

## Limites du miroir public

Le dépôt n'est pas un miroir binaire complet du ZIP joueur. Certains gros fichiers historiques, les 27 fichiers de traduction complets et les assets binaires restent garantis dans le package source de vérité lorsqu'ils ne sont pas publiés séparément sur GitHub. Le `modDesc.xml` du dépôt peut donc référencer des fichiers actifs présents dans le package mais non exposés dans ce miroir texte partiel.

Cette limitation ne change pas la règle de build : la roadmap, la version et les sources nouvelles de la passe doivent être cohérentes avec le ZIP livré.

## État fonctionnel

**Écriture fonctionnelle hors tests : 100 % pour Facile, Normal et Difficile.**

Les validations restantes sont des certifications FS25, relectures, essais de compatibilité, contrôles visuels ou critères de publication.
