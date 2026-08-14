# Synchronisation du source GitHub

Version de test préparée : **0.9.3.37 TEST**
Version locale déclarée : **0.9.3.37 TEST**
Date : **14 août 2026**

La build ZIP joueur 0.9.3.36 devient la référence exécutable de cette passe après synchronisation du miroir GitHub. F01 et F02 restent validées. F03 Banque reste la phase de certification active.

## Éléments nouveaux de la build locale 0.9.3.27

- `src/modules/company/CompanyStructure09327.lua` : formes juridiques, activités, réseaux, coûts et migration CUMA ;
- `src/modules/bank/BankCompanyStructure09327.lua` : lien modéré entre structure juridique et analyse bancaire ;
- `src/modules/enterprise/ManagementAdvisor09327.lua` : conseiller de gestion dynamique et historique ;
- `src/modules/contracts/ContractCashflow09327.lua` : paiements immédiats, mensuels et différés des contrats AgriLife ;
- `src/ui/AgriLifeStrategy09327UI.lua` : explications et confirmations des choix de structure et du recrutement ;
- `src/ui/VanillaBypassGuards09327.lua` : remplacement de reset gratuit et garde visuelle Contrats ;
- `gui/AgriLifeHomeFrame.xml` : commandes Forme juridique, Activités et Réseaux ;
- les 27 traductions contiennent les nouvelles clés de cette passe.

## Limites volontairement conservées

- CUMA possède son socle de données, ses coûts et sa migration, mais sa sélection reste inactive tant que catalogue de matériel mutualisé, réservation et restitution ne sont pas réellement fonctionnels ;
- groupement d'employeurs, transformation, vente directe, méthanisation et forêt restent non sélectionnables tant que leur effet métier complet n'est pas raccordé ;
- le callback exact de réinitialisation du menu ESC doit être certifié dans FS25. La garde installe uniquement un remplacement sur une méthode réellement détectée ;
- ces systèmes sont écrits et audités statiquement, pas validés en jeu.


## Finition performance locale 0.9.3.35

- Setters GUI idempotents pour éviter les invalidations visuelles inutiles.
- Signature de navigation pour ne pas repeindre les mêmes états.
- Profiler UI abaissé à 1,5 ms avec mesures ouverture, navigation et page.
- Le ZIP local reste la référence exécutable jusqu'à vérification du miroir GitHub.

## Correction performance locale 0.9.3.32

- `src/ui/AgriLifeUIManager.lua` : garde Finances installée une seule fois, sans reconstruction périodique du menu ;
- `src/ui/VanillaBypassGuards09327.lua` : polling de protection arrêtè dès que Contrats, Finances et reset sont protégés ;
- `src/ui/AgriLifeHomeFrame.lua` : en-tête difficulté alimenté par l'état brut léger ;
- `src/core/AgriLifeCore.lua` : suppression du second refresh complet après montage GUI ;
- `src/modules/dashboard/Dashboard6Service.lua` et `DashboardRoadmapWritingCompletion.lua` : snapshot dashboard allégé et comptabilité avancée retirée du repaint ;
- `src/modules/economy/BusinessResilience09328.lua` : santé financière live issue de l'état mensuel stocké ;
- `src/modules/economy/AgriculturalSupport09328.lua` : plus de scan parcellaire dans le snapshot UI courant ;
- `src/modules/finalization/Finalization6Service.lua` : audit démarrage léger, audit profond uniquement à la demande.

## Règles de synchronisation

- distinguer clairement la version déclarée et l'état réel du miroir ;
- ne jamais annoncer un fichier comme synchronisé s'il n'est pas présent et vérifié ;
- conserver la build joueur comme référence exécutable tant que le miroir est incomplet ;
- retirer les helpers temporaires après usage ;
- aucun tiret cadratin dans les contenus du projet.


## Éléments nouveaux de la build locale 0.9.3.28

- `src/core/AgriLifeGameTime09328.lua` et `AgriLifeTimeBindings09328.lua` : calendrier FS25 central 1-28 jours/mois ;
- `src/modules/assets/CumaEquipment09328.lua` et `src/ui/AgriLifeCumaUI09328.lua` : CUMA jouable ;
- `src/modules/economy/BusinessResilience09328.lua` : santé financière, insolvabilité et faillite progressive ;
- `src/modules/economy/AgriculturalSupport09328.lua` : aide agricole annuelle simplifiée ;
- `src/modules/payroll/OwnerRemuneration09328.lua` : rémunération explicite du dirigeant ;
- `src/ui/AgriLifeDecisionHooks09328.lua` : conseiller/explication sur prêts et investissements supplémentaires.

Le ZIP local reste la référence exécutable jusqu'à comparaison du miroir GitHub après cette passe.


## Passe locale 0.9.3.35

Le ZIP de test contient la correction F03 de convention bancaire et la passe de micro-fluidité bancaire. La validation en jeu reste obligatoire avant de considérer cette correction comme certifiée.
## Passe locale 0.9.3.36

La page Banque affiche maintenant l'état d'ouverture et les horaires de la banque parcourue. Les banques numériques restent ouvertes 24/7. F03 reste active jusqu'au contrôle en jeu et au log propre.

## 0.9.3.37 TEST

- F03 Banque validée en jeu.
- F04 Entreprise active.
- Frais de recrutement raccordés au relevé professionnel via `PAYROLL_RECRUITMENT_FEE`.
- Le miroir GitHub doit contenir les trois sources Entreprise présentes dans le ZIP avant validation de synchronisation.
