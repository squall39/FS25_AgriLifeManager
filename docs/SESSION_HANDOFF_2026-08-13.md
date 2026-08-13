# Reprise de session — 13 août 2026

## Version à reprendre

**0.9.3.13 TEST** — `FS25_AgriLifeManager_0.9.3.13_UI_ENTERPRISE_WORKSHOP_FIX.zip`

SHA-256 : `60c0be2f728c96dcabc19ed83d69c6b05c0325f4bc41c6084c16d76b56cf4a48`

## Où nous en sommes

Nous sommes encore en **F02 : stabilisation / cohérence UI**. La phase Banque métier n'a pas commencé.

### Déjà acquis

- chargement du mod et navigation générale ;
- gel souris Banque corrigé ;
- pictogrammes principaux harmonisés ;
- aide contextuelle rétablie ;
- conseiller actif affiché dans Banque ;
- corrections successives de lisibilité Entreprise / Administration / Contrats / Atelier.

### Correctifs inclus dans 0.9.3.13 à retester

- Entreprise : vues Dossier salarié / Planning / Formation / Carrière / Incidents ne doivent plus se superposer au profil de base ;
- Entreprise : icône HUD/store du matériel relevée ; étoiles salarié relevées ;
- Entreprise : blocage du recrutement multiple d'un même candidat ; génération de noms distincts ;
- Contrats : suppression de pictogrammes/flèches incohérents ;
- Atelier : vues Diagnostic / Pièces / Travaux / Conformité doivent remplacer proprement les panneaux de base ;
- Marché de l'occasion : icône HUD/store de l'offre ;
- Banque : boutons du bas agrandis ; résumé tableau de bord enrichi banque/conseiller/étoiles.

## Premier test à la reprise

Test court de la 0.9.3.13 : **Entreprise -> toutes les vues -> recrutement doublon -> Contrats -> Atelier -> Marché occasion -> Banque/tableau de bord**. Corriger immédiatement tout chevauchement ou élément illisible avant de poursuivre.

## Après validation F02

Commencer la Banque fonctionnelle par : **sélection banque + conseiller et persistance**, puis avancer bloc par bloc.
