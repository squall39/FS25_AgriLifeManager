# Développement — AgriLife Manager

Ce dépôt est actuellement privé et sert de base de développement à AgriLife Manager.

## Règles de travail

- Ne pas publier de build TEST en dehors des canaux décidés par Chez_Squall.
- Conserver la compatibilité de sauvegarde autant que possible.
- Toute modification majeure doit être documentée dans le tutoriel initial et dans Échap → Assistance.
- Les nouvelles fonctions doivent être testées sur une partie propre et, si nécessaire, sur une sauvegarde existante migrée.
- Les intégrations Courseplay, AutoDrive, Soil Fertilizer et autres doivent rester optionnelles.
- Ne pas introduire de dépendance obligatoire inutile.
- Conserver l’auteur du projet sous le nom **Chez_Squall**.
- Ne jamais retirer les copyrights/licences des composants tiers.
- Avant une build de test : contrôler XML, Lua, l10n, assets référencés et intégrité du ZIP.

## Convention de version

Tant qu’AgriLife Manager n’est pas terminé, la version reste **inférieure à 1.0.0.0**.

Les versions intermédiaires peuvent porter le suffixe conceptuel `TEST` dans les noms de package de développement, mais le numéro déclaré dans le mod doit rester conforme au format FS25.

## Branches

Pendant la phase actuelle :

- `main` : base de travail validée.
- Des branches dédiées pourront être ajoutées plus tard pour les grosses refontes (Banque, Personnel, Huissier, compatibilités, multijoueur).

## Tests

Après chaque correction significative, conserver un plan de test court et reproductible afin de valider uniquement la fonction modifiée avant de poursuivre.
