<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# Architecture multijoueur multi-fermes

## État 0.7.8.0

Le multijoueur reste volontairement désactivé dans `modDesc.xml` avec `supported=false`. Le code métier utilise déjà `farmId`, `profileId`, permissions et autorité serveur afin de préparer l'activation future sans mélanger les exploitations.

## Isolation

Chaque état d'exploitation est indexé par `farmId`. Les données personnelles utilisent en plus `profileId`. Une action sensible doit être exécutée par le serveur et ne doit jamais modifier une autre ferme.

Les services Banque, Entreprise, Carrière, Examens, Paie, Administration, Contrats, Marchés, Assurance, Atelier, Actifs, Juridique, Journal et Finalisation suivent cette séparation.

## Règles d'accès prévues

- propriétaire : administration complète de sa ferme ;
- gérant : fonctions accordées par permission ;
- salarié : accès limité à son profil, ses tâches, sa paie et aux pages autorisées ;
- aucun accès croisé aux comptes personnels d'un autre joueur ;
- aucun accès croisé aux données d'une autre ferme sans appartenance réelle ;
- un futur sélecteur multi-fermes devra uniquement montrer les fermes auxquelles le joueur appartient.

## Réseau et sécurité

Les façades sensibles rejettent les écritures non autorisées côté client. Les intégrations externes restent optionnelles. Une incompatibilité Courseplay, AutoDrive, Precision Farming ou Soil Fertilizer ne doit pas casser le coeur AgriLife.

## Campagne requise avant activation

1. Deux joueurs dans une même ferme avec rôles différents.
2. Deux fermes indépendantes sur la même carte.
3. Un joueur membre de deux fermes et un joueur limité à une seule.
4. Reconnexion, changement de ferme et reprise de sauvegarde.
5. Tentatives d'accès croisé Banque, Paie, Administration, Contrats et Atelier.
6. Actions simultanées et sauvegarde sur serveur dédié.
7. Vérification des snapshots et de l'absence de duplication économique.

Le drapeau multijoueur ne doit être activé qu'après réussite de cette campagne.
