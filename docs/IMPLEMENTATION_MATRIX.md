<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager - matrice d'implémentation 0.9.1.0

Cette matrice complète la feuille de route sans la remplacer. `docs/ROADMAP.md` reste le registre maître additif de toutes les idées validées.

`INTÉGRÉ / À TESTER` signifie que le code est chargé et contrôlé hors jeu. `ÉCRIT / À CERTIFIER` signifie que le bloc de feuille de route est écrit et intégré mais que sa certification FS25 réelle reste à faire. `VALIDÉ EN JEU` reste réservé aux scénarios réellement confirmés dans FS25.

## Règle de maintenance de la feuille de route

Une mise à jour ne doit jamais supprimer, condenser ou reformuler une idée au point d'en perdre le contenu. Elle sert uniquement à changer l'état d'un point déjà prévu, ajouter une idée explicitement validée ou préciser son avancement sans retirer son intention initiale.

| Bloc | État 0.9.1.0 | Résumé |
|---|---|---|
| Démarrage | ÉCRIT / À CERTIFIER | Facile/Normal/Difficile, capital, banque, permis provisoire Normal, verrou Difficile, migration et persistance |
| Interface de base | ÉCRIT / À CERTIFIER | tableau de bord 6 cartes, navigation, onboarding, tutoriel paginé, journal, HUD et actions contextuelles |
| Banque | ÉCRIT / À CERTIFIER | banque/conseiller, consultation, crédit, refinancement, grand livre filtrable, séparation pro/perso, comptabilité, fiscalité, amortissements, bilan, CAF, rentabilité, prévisions et restrictions |
| Entreprise | ÉCRIT / À CERTIFIER | contrats, RH, planning, paie unique, ordres, IA FS25, Courseplay/AutoDrive optionnels, XP salarié, recrutement, incidents, réputation |
| Carrière & Qualifications | ÉCRIT / À CERTIFIER | carrière durable, XP par difficulté, permis 10 étapes, historique, qualifications spécialisées et verrous métier |
| Administration | ÉCRIT / À CERTIFIER | statut d'exploitation, santé administrative, documents, contrôles, récidive, sanctions, assurance, contentieux et huissier |
| Contrats & Marchés | ÉCRIT / À CERTIFIER | engagements commerciaux, négociation, notation A-E, relations acheteurs, marchés mondial/local, multifruits, neuf/occasion, intrants, énergie, foncier, locations, productions et PF/Soil optionnels |
| Atelier, Concessionnaire & Gestion technique | ÉCRIT / À CERTIFIER | composants, usure/stress, pannes fonctionnelles, pièces dynamiques, délais, garage interne/SAV, révisions, contrôle technique, constats, responsabilité, bonus-malus, assurance, historique, occasion et ponts ADS/MudSystem |
| Finalisation | ÉCRIT / À CERTIFIER | sauvegardes/migrations, récupération backup, compatibilités, isolation multi-fermes, réseau non publié, l10n, audits, docs et packaging |
| Multijoueur | INFRASTRUCTURE ÉCRITE / DÉSACTIVÉ | serveur autoritaire, enveloppes séparées par ferme et miroir client ; `supported=false` jusqu'à certification réseau |

## Étape 9 - écriture 0.9.1.0

- schéma de sauvegarde 4 et migration 3 -> 4 ;
- identité durable de carrière et suivi de récupération du backup ;
- historique de migration ;
- audit de couverture save/load des modules persistants ;
- contrôle d'isolation multi-fermes en mémoire ;
- infrastructure réseau serveur autoritaire avec refus d'une enveloppe d'une autre ferme ;
- publication multijoueur désactivée jusqu'à certification ;
- matrice de compatibilités optionnelles avec fallback autonome ;
- audit runtime maps/fillTypes/productions/foncier sans liste fixe ;
- tutoriel paginé rebasé avec boutons l10n directs ;
- audit l10n de parité, doublons, valeurs vides, placeholders et usages statiques ;
- glossaire, guide utilisateur, composants tiers et checklist de publication ;
- packaging reproductible TEST/PUBLIC avec gates automatiques.

## État des contrôles hors jeu

- Étape 9 : 39 assertions dédiées ;
- Atelier 8 : 168 assertions ;
- inspection technique occasion : 21 assertions ;
- constats/responsabilité : 76 assertions ;
- bonus-malus : 51 assertions ;
- Contrats & Marchés : 103 assertions ;
- Administration : 76 assertions ;
- Carrière & Qualifications : 71 assertions ;
- Entreprise : 159 assertions ;
- fonctionnel général : 64 assertions ;
- 27 langues avec 5 019 clés alignées ;
- 115 fichiers Lua dans le package de travail ;
- 91 XML ;
- 108 Lua actifs déclarés ou spécialisés ;
- 170 callbacks UI et 229 contrôles UI ;
- aucune source `modDesc.xml` manquante.

## Priorités validées après stabilisation

1. Réputation de l'exploitation et du dirigeant.
2. Comptabilité et fiscalité.
3. Contrôles administratifs et sanctions.

## Limite

L'étape 9 côté écriture ne vaut pas certification finale. Les essais FS25 réels, le multijoueur, les différentes résolutions, plusieurs maps et la préparation d'une version publique stable restent distincts.

## Fermeture fonctionnelle de la roadmap

La passe 0.9.1.0 ferme les derniers scripts métier identifiés dans les étapes 1 à 3. Les cases restant ouvertes dans `ROADMAP.md` représentent désormais des tests FS25, validations visuelles, compatibilités réelles, relectures ou critères de publication. Elles ne sont pas considérées comme du code métier manquant.

**Écriture fonctionnelle hors tests : 100 % pour Facile, Normal et Difficile.**

## Synchronisation des idées validées

Le registre maître ajouté à `ROADMAP.md` distingue l’état du code, la présence dans le tutoriel/Assistance et la certification FS25. Le flux panne immobilisante -> dépannage/remorquage -> concessionnaire ou atelier -> pièces physiques -> réparation -> assurance est actuellement **partiellement intégré** ; le retrait du camion joueur et la finalisation de la réparation maison restent à intégrer/certifier.
