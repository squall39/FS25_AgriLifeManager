# Synchronisation du source GitHub

Version de référence : **0.8.1.0 TEST**

Le package joueur reste la source de vérité exécutable. GitHub publie le source texte maintenable et la feuille de route additive.

## Source 0.8.1.0 - constats et bonus-malus

- `src/modules/insurance/InsuranceClaimsLiability8.lua` : source exact réassemblé sur GitHub avec contrôle du hash avant commit ;
- `src/modules/insurance/InsuranceBonusMalus8.lua` ;
- `src/ui/AgriLifeHomeFrame.lua` dans le package ;
- `tests/claims_liability_roadmap8_spec.lua` dans le package ;
- `tests/insurance_bonus_malus8_spec.lua` dans le package ;
- `translations/` avec les clés d'affichage responsabilité/bonus-malus dans le package ;
- `docs/STEP8_INSURANCE_CLAIMS.md` ;
- `ROADMAP.md` maître reconstruit automatiquement à partir du cahier Étape 8 sans supprimer les autres étapes ;
- `modDesc.xml` et `src/core/AgriLifeVersion.lua` en 0.8.1.0.

## Feuille de route

Le workflow `sync-step8-roadmap.yml` fusionne le cahier Atelier et le bloc Constats/Assurance dans la section 8 de `ROADMAP.md`. Les étapes 1 à 7 et 9 restent hors de cette zone de remplacement. Les cases de certification terrain restent ouvertes tant que les scénarios ne sont pas validés dans FS25.

## Package

Le ZIP 0.8.1.0 contient la roadmap complète sous `docs/ROADMAP.md`, les deux moteurs Assurance 8, l'interface mise à jour, les 27 traductions et les tests. Une synchronisation GitHub ne vaut jamais certification en jeu.

## Assets binaires

Les DDS, PNG, I3D, SHAPES et autres assets nécessaires au ZIP joueur ne sont pas automatiquement republiés dans le dépôt public. Leur publication dépend de leur origine et des droits de redistribution.
