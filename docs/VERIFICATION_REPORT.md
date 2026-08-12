<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager 0.9.0.0 - rapport de vérification

Date : 12 août 2026.

## Portée

La build 0.9.0.0 ajoute l'étape 9 Finalisation côté écriture. Cette vérification reste hors jeu et ne vaut pas certification FS25.

## Finalisation 9

Sont intégrés : schéma de sauvegarde 4, migration 3 -> 4, identité de carrière, suivi de récupération backup, historique de migration, audit de couverture save/load, contrôle d'isolation multi-fermes, squelette réseau serveur autoritaire avec séparation par ferme, publication multijoueur bloquée, audit de compatibilités optionnelles, audit dynamique des contenus de map, tutoriel paginé rebasé, audits l10n et publication, documentation utilisateur et packaging TEST/PUBLIC.

## Compatibilités

Courseplay, AutoDrive, Precision Farming, Soil Fertilizer, MudSystem et Advanced Damage System restent optionnels. Leur absence ne crée aucune dépendance dure. Une donnée externe indisponible doit dégrader uniquement l'enrichissement concerné.

## Localisation

Les 27 langues distribuées restent alignées. Le gate l10n vérifie maintenant parité, doublons, valeurs vides, placeholders et clés statiquement référencées dans Lua/XML. Le bouton Précédent du tutoriel paginé possède désormais sa clé dans les 27 langues.

## Contrôles hors jeu

- Finalisation 9 : 39 assertions ;
- fonctionnel général : 64 assertions ;
- Entreprise : 159 assertions ;
- Carrière & Qualifications : 71 assertions ;
- Administration : 76 assertions ;
- Contrats & Marchés : 103 assertions ;
- Atelier 8 : 168 assertions ;
- inspection occasion : 21 assertions ;
- Constats/Responsabilité : 76 assertions ;
- Bonus-malus : 51 assertions ;
- parité l10n : 27 langues, 5 011 clés ;
- XML : 91 ;
- Lua actifs : 103 ;
- callbacks UI : 170 ;
- contrôles UI : 229 ;
- sources `modDesc.xml` manquantes : 0 ;
- audit publication : OK ;
- audit usages l10n : OK.

## État

Étapes 4 à 9 : **écrites et intégrées côté code, certification en jeu différée**. Les étapes 1 à 3 conservent plusieurs points historiques avancés à terminer avant de pouvoir considérer l'ensemble du mod fonctionnellement complet.
