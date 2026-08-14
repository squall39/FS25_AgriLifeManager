# Synchronisation du source GitHub

Version de test préparée : **0.9.3.27 TEST**
Version déclarée sur `main` : **0.9.3.27 TEST**
Date : **14 août 2026**

La build joueur 0.9.3.27 reste la référence exécutable complète. F01 et F02 sont validées en jeu. F03 Banque est active. La préparation transversale 0.9.3.27 est écrite et auditée statiquement, mais elle n'est pas certifiée en jeu.

## Éléments 0.9.3.27 présents et vérifiés sur `main`

- `modDesc.xml` et `src/core/AgriLifeVersion.lua` déclarent 0.9.3.27 ;
- `src/core/AgriLifeDecisionGuide.lua` est aligné sur 0.9.3.27 ;
- `src/modules/company/CompanyStructure09327.lua` sépare formes juridiques, activités et réseaux professionnels ;
- `src/modules/bank/BankCompanyStructure09327.lua` raccorde modérément la structure à l'analyse bancaire ;
- `src/modules/enterprise/ManagementAdvisor09327.lua` fournit le conseiller de gestion dynamique et son historique ;
- `src/modules/contracts/ContractCashflow09327.lua` gère les profils de paiement immédiat, mensuel et différé ;
- `src/ui/AgriLifeStrategy09327UI.lua` ajoute les explications des choix de structure et du recrutement ;
- `src/ui/VanillaBypassGuards09327.lua` ajoute les gardes Contrats et récupération matériel ;
- `CHANGELOG.md`, `TESTING.md` et `docs/PROJECT_SYNC_STATUS.md` suivent la build 0.9.3.27.

## Limites volontaires de la 0.9.3.27

- CUMA possède son socle de données, ses coûts et sa migration, mais sa sélection reste inactive tant que catalogue de matériel mutualisé, réservation et restitution ne sont pas réellement fonctionnels ;
- groupement d'employeurs, transformation, vente directe, méthanisation et forêt restent non sélectionnables tant que leur effet métier complet n'est pas raccordé ;
- le callback exact de réinitialisation du menu Échap doit être certifié dans FS25. La garde installe uniquement un remplacement sur une méthode réellement détectée ;
- ces systèmes ne sont pas considérés validés tant que leurs tests en jeu n'ont pas été effectués.

## Miroir encore incomplet

Le dépôt `main` reste un miroir partiel de la build ZIP. Les éléments suivants doivent encore être présents ou comparés avant de déclarer un miroir complet :

- plusieurs gros fichiers Banque et Administration historiquement absents du miroir ;
- `gui/AgriLifeHomeFrame.xml` 0.9.3.27 avec les commandes Forme juridique, Activités et Réseaux ;
- les 27 fichiers du répertoire `translations/` contenant les nouvelles clés 0.9.3.27 ;
- `tools/verify_release.py` ;
- `ROADMAP.md` et `docs/ROADMAP.md` doivent encore être comparés avec les copies 0.9.3.27 de la build avant d'annoncer leur synchronisation complète.

Un fichier n'est jamais considéré comme synchronisé tant que sa présence et son contenu n'ont pas été vérifiés sur `main`.

## Règles de synchronisation

- distinguer clairement la version déclarée et l'état réel du miroir ;
- ne jamais annoncer un fichier comme synchronisé s'il n'est pas présent et vérifié ;
- conserver la build joueur comme référence exécutable tant que le miroir est incomplet ;
- retirer les helpers temporaires après usage ;
- aucun tiret cadratin dans les contenus du projet.
