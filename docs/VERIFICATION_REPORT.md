<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager 0.7.9.0 - rapport de vérification

Date : 11 août 2026.

## Portée

La build 0.7.9.0 contient les étapes 1 à 3 déjà intégrées et ferme côté écriture les étapes 4 Entreprise, 5 Carrière & Qualifications, 6 Administration et 7 Contrats & Marchés. Cette vérification est statique et comportementale hors jeu. Elle ne vaut pas certification FS25.

## Étape 7 - Contrats & Marchés

Sont intégrés : engagements commerciaux, négociation de prix/volume/délai, acheteurs et coopératives, surfaces conseillées, notation A-E, relations acheteurs, pénalités selon difficulté, marchés mondial et local, découverte dynamique maps/multifruits, hooks de prix réversibles, marché du neuf et de l'occasion, stocks et délais de livraison, intrants, carburants/énergie, foncier, productions/usines, locations, opportunités temporaires, rentabilité et enrichissements optionnels Precision Farming / Soil Fertilizer avec fallback vanilla.

## Étapes précédentes

- Étape 4 Entreprise : contrats CDI/CDD/saisonnier, RH, planning, paie unique, ordres, IA et réputation intégrés.
- Étape 5 Carrière & Qualifications : carrière durable, XP, permis et qualifications intégrés.
- Étape 6 Administration : statut, conformité, contrôles, sanctions, assurance et contentieux intégrés.

## Contrôles statiques et comportementaux

- tests fonctionnels : 64 assertions ;
- Entreprise : 159 assertions ;
- Carrière & Qualifications : 71 assertions ;
- Administration : 76 assertions ;
- Contrats & Marchés : 103 assertions ;
- Lua du package : 100 avec syntaxe contrôlée ;
- XML : 91 ;
- Lua actifs : 93 ;
- callbacks UI : 161 ;
- contrôles UI : 217 ;
- langues : 27 ;
- clés l10n : 4 961 ;
- sources `modDesc.xml` manquantes : 0.

## État

Étapes 4, 5, 6 et 7 : **écrites et intégrées, certification en jeu différée**. La prochaine passe fonctionnelle de feuille de route est l'étape 8 Atelier.
