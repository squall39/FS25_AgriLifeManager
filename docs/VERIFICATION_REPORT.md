<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager 0.7.8.0 - rapport de vérification

Date : 11 août 2026.

## Portée

La build 0.7.8.0 contient les étapes 1 à 3 déjà intégrées et ferme côté écriture les étapes 4 Entreprise, 5 Carrière & Qualifications et 6 Administration. Cette vérification est statique et comportementale hors jeu. Elle ne vaut pas certification FS25.

## Étape 4 - Entreprise

Contrats CDI/CDD/saisonnier, RH, planning, une personne = une tâche, paie unique, ordres de travail, IA native FS25, adaptateurs optionnels Courseplay/AutoDrive, progression salarié, recrutement, formation, incidents et réputation sont intégrés.

## Étape 5 - Carrière & Qualifications

Carrière durable, XP par difficulté, séparation XP/examen, permis agricole 10 étapes, historique des résultats, affichage PERMIS OBTENU et qualifications spécialisées avec verrous métier sont intégrés. La chaîne réelle des examens reste à certifier en jeu.

## Étape 6 - Administration

Statut d'exploitation évolutif, documents et obligations, santé administrative, contrôles, récidive, régularisation, sanctions, immobilisation, assurance, événements de gestion, contentieux, huissier, saisie et plans de paiement sont intégrés. Les restrictions alimentent réellement Banque, Contrats et Entreprise.

## Contrôles statiques

- tests fonctionnels : 64 assertions ;
- Entreprise : 159 assertions ;
- Carrière & Qualifications : 71 assertions ;
- Administration : 76 assertions ;
- Lua du package : 93 ;
- XML : 91 ;
- Lua actifs : 87 ;
- callbacks UI : 156 ;
- contrôles UI : 217 ;
- langues : 27 ;
- clés l10n : 4 933 ;
- sources `modDesc.xml` manquantes : 0.

## État

Étapes 4, 5 et 6 : **écrites et intégrées, certification en jeu différée**. La prochaine passe fonctionnelle de feuille de route est l'étape 7 Contrats & Marchés.
