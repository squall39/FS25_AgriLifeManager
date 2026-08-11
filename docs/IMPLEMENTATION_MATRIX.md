<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager - matrice d'implémentation 0.7.8.0

`INTÉGRÉ / À TESTER` signifie que le code est chargé et contrôlé statiquement. `VALIDÉ EN JEU` reste réservé aux scénarios réellement confirmés dans FS25.

| Bloc | État 0.7.8.0 | Résumé |
|---|---|---|
| Démarrage | INTÉGRÉ / CAMPAGNE À FINIR | Facile/Normal/Difficile, capital, banque, permis provisoire Normal, verrou Difficile, migration et persistance |
| Interface de base | INTÉGRÉ / À TESTER | tableau de bord 6 cartes, navigation, onboarding, tutoriel, journal, HUD et actions contextuelles |
| Banque | INTÉGRÉ / À TESTER | banque/conseiller, crédit, dette héritée, comptes pro/perso, comptabilité, fiscalité, prévision et restrictions administratives |
| Entreprise | ÉCRIT / À CERTIFIER | contrats, RH, planning, paie unique, ordres, IA FS25, Courseplay/AutoDrive optionnels, XP salarié, recrutement, incidents, réputation |
| Carrière & Qualifications | ÉCRIT / À CERTIFIER | carrière durable, XP par difficulté, permis 10 étapes, historique, qualifications spécialisées et verrous métier |
| Administration | ÉCRIT / À CERTIFIER | statut d'exploitation, santé administrative, documents, contrôles, récidive, sanctions, assurance, contentieux et huissier |
| Contrats & Marchés | FONDATIONS PRÉSENTES | passe dédiée étape 7 encore à fermer |
| Atelier | FONDATIONS PRÉSENTES | passe dédiée étape 8 encore à fermer |
| Finalisation | INFRASTRUCTURE PRÉSENTE | campagne A -> Z et fermeture étape 9 à faire |
| Multijoueur | PRÉPARÉ / DÉSACTIVÉ | `supported=false` jusqu'à certification réseau |

## Contrôles de la build 0.7.8.0

- 76 assertions Administration ;
- 71 assertions Carrière & Qualifications ;
- 159 assertions Entreprise ;
- 64 assertions fonctionnelles générales ;
- 27 langues avec 4 933 clés alignées lors de la build ;
- 93 Lua du package avec syntaxe contrôlée ;
- 91 XML parsés ;
- 87 Lua actifs référencés par `modDesc.xml` ;
- 156 callbacks UI et 217 contrôles UI comptés ;
- aucune source `modDesc` manquante lors de la vérification.

## Limite

Ces contrôles ne remplacent pas les tests FS25 réels. La feuille de route distingue explicitement écriture/intégration et certification en jeu.
