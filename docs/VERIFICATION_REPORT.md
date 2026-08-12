<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager 0.8.1.0 - rapport de vérification

Date : 12 août 2026.

## Portée

La build 0.8.1.0 conserve l'étape 8 Atelier et ajoute la correspondance complète Constats -> Responsabilité -> Atelier -> Assurance ainsi que le bonus-malus durable. Cette vérification est statique et comportementale hors jeu. Elle ne vaut pas certification FS25.

## Étape 8 - Atelier, Concessionnaire & Gestion technique du parc

Sont intégrés : suivi de tout le parc, composants adaptés, usure/stress selon usage réel, pannes fonctionnelles par gravité, diagnostics et symptômes, pièces OEM/adaptables/reconditionnées/occasion, marché dynamique des pièces relié à l'étape 7, commandes et délais persistants, concessionnaire/SAV, atelier interne et compétences mécaniques, révision annuelle, contrôle technique tous les deux ans, contre-visite, immobilisation, dépannage, continuité d'activité, garanties, assurance, carnet de vie, valeur de revente, inspection technique de l'occasion et campagnes de rappel constructeur.

Advanced Damage System reste l'autorité mécanique lorsque son état est détectable. MudSystem reste l'autorité sur ses pneus/crevaisons exploitables. AgriLife ne copie ni ne remplace leurs moteurs et conserve un fallback autonome.

## Constats, responsabilité et bonus-malus

Le conducteur et la responsabilité sont maintenant séparés. Les constats peuvent conclure responsable, non responsable, partagé ou indéterminé. Une responsabilité indéterminée bloque le règlement. Le devis Atelier final devient la base de répartition entre assurance et exploitation. Les dommages tiers responsables passent par la responsabilité civile lorsqu'elle existe. Les recours/contre-expertises recalculent la décision sans double pénalité.

Le coefficient bonus-malus démarre à 1,00, évolue annuellement après une période sans sinistre responsable et augmente uniquement après une responsabilité établie. Le coefficient et la prime de référence sont persistants et les contrats véhicule, responsabilité civile et transport suivent réellement cette évolution.

## Contrôles statiques et comportementaux

- tests fonctionnels : 64 assertions ;
- Entreprise : 159 assertions ;
- Carrière & Qualifications : 71 assertions ;
- Administration : 76 assertions ;
- Contrats & Marchés : 103 assertions ;
- Atelier 8 : 168 assertions ;
- Inspection occasion Atelier 8 : 21 assertions ;
- Constats et responsabilité Atelier-Assurance : 76 assertions ;
- Bonus-malus assurance : 51 assertions ;
- Lua du package : 111 avec syntaxe contrôlée ;
- XML : 91 ;
- Lua actifs : 100 ;
- callbacks UI : 170 ;
- contrôles UI : 229 ;
- langues : 27 ;
- clés l10n : 5 010 ;
- sources `modDesc.xml` manquantes : 0.

## État

Étapes 4, 5, 6, 7 et 8 : **écrites et intégrées, certification en jeu différée**. La prochaine phase fonctionnelle de la feuille de route est l'étape 9 Finalisation, après poursuite des certifications terrain prévues.
