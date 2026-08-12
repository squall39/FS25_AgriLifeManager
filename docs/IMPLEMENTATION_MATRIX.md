<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager - matrice d'implémentation 0.8.0.0

Cette matrice complète la feuille de route sans la remplacer. La feuille de route reste le registre maître additif de toutes les idées validées.

`INTÉGRÉ / À TESTER` signifie que le code est chargé et contrôlé statiquement. `ÉCRIT / À CERTIFIER` signifie que le bloc est écrit et intégré mais que sa certification FS25 réelle reste à faire. `VALIDÉ EN JEU` reste réservé aux scénarios réellement confirmés dans FS25.

## Règle de maintenance de la feuille de route

Une mise à jour ne doit jamais supprimer, condenser ou reformuler une idée au point d'en perdre le contenu. Elle sert uniquement à changer l'état d'un point déjà prévu, ajouter une idée explicitement validée ou préciser son avancement sans retirer son intention initiale.

| Bloc | État 0.8.0.0 | Résumé |
|---|---|---|
| Démarrage | INTÉGRÉ / CAMPAGNE À FINIR | Facile/Normal/Difficile, capital, banque, permis provisoire Normal, verrou Difficile, migration et persistance |
| Interface de base | INTÉGRÉ / À TESTER | tableau de bord 6 cartes, navigation, onboarding, tutoriel, journal, HUD et actions contextuelles |
| Banque | INTÉGRÉ / À TESTER | banque/conseiller, crédit, dette héritée, comptes pro/perso, comptabilité, fiscalité, prévision et restrictions administratives |
| Entreprise | ÉCRIT / À CERTIFIER | contrats, RH, planning, paie unique, ordres, IA FS25, Courseplay/AutoDrive optionnels, XP salarié, recrutement, incidents, réputation |
| Carrière & Qualifications | ÉCRIT / À CERTIFIER | carrière durable, XP par difficulté, permis 10 étapes, historique, qualifications spécialisées et verrous métier |
| Administration | ÉCRIT / À CERTIFIER | statut d'exploitation, santé administrative, documents, contrôles, récidive, sanctions, assurance, contentieux et huissier |
| Contrats & Marchés | ÉCRIT / À CERTIFIER | engagements commerciaux, négociation, notation A-E, relations acheteurs, marchés mondial/local, multifruits, neuf/occasion, intrants, énergie, foncier, locations, productions et PF/Soil optionnels |
| Atelier, Concessionnaire & Gestion technique | ÉCRIT / À CERTIFIER | composants, usure/stress, pannes fonctionnelles, pièces dynamiques, délais, garage interne/SAV, révisions, contrôle technique, rappels, dépannage, assurance, historique, occasion et ponts ADS/MudSystem |
| Finalisation | INFRASTRUCTURE PRÉSENTE | campagne A -> Z et fermeture étape 9 à faire |
| Multijoueur | PRÉPARÉ / DÉSACTIVÉ | `supported=false` jusqu'à certification réseau |

## Contrôles de la build 0.8.0.0

- 168 assertions Atelier 8 ;
- 21 assertions inspection technique occasion ;
- 103 assertions Contrats & Marchés ;
- 76 assertions Administration ;
- 71 assertions Carrière & Qualifications ;
- 159 assertions Entreprise ;
- 64 assertions fonctionnelles générales ;
- tests comportementaux généraux validés ;
- 27 langues avec 5 002 clés alignées ;
- 91 XML parsés ;
- 98 Lua actifs référencés par `modDesc.xml` ;
- 170 callbacks UI et 229 contrôles UI comptés ;
- aucune source `modDesc` manquante dans le package vérifié.

## Priorités validées après stabilisation

1. Réputation de l'exploitation et du dirigeant.
2. Comptabilité et fiscalité.
3. Contrôles administratifs et sanctions.

## Limite

Ces contrôles ne remplacent pas les tests FS25 réels. L'étape 8 reste à certifier avec sauvegarde/rechargement, log propre et essais avec/sans MudSystem et Advanced Damage System.
