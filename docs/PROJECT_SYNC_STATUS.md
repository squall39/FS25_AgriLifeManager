# État de synchronisation AgriLife Manager

Version de référence : **0.9.3.26 TEST**
Date : **14 août 2026**

## État campagne

- F01 : **VALIDÉE EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉE EN JEU** en 0.9.3.23.
- F03 : **ACTIVE - Banque fonctionnelle**.
- F04 et phases suivantes : en attente de validation complète de F03.
- Correction XP 0.9.3.26 : écrite et auditée, retest en jeu reporté à la demande de Seb. Ce report ne bloque pas la reprise des tests F03 Banque.

## Reprise F03 Banque

La reprise se fait sur la build 0.9.3.26, qui contient le travail Banque développé dans les versions précédentes.

Points actuellement préparés :

- convention bancaire entre exploitation, banque et conseiller ;
- bouton de signature corrigé ;
- simulation de crédit possible avant convention, envoi réel réservé à une convention active ;
- banques et conseillers avec accès et progression de 0 à 5 ;
- accès libre aux profils compatibles en mode Facile ;
- progression requise dans les autres difficultés ;
- banques locales, régionales, nationales, internationales et en ligne ;
- conseillers rattachés à leur établissement ;
- explication obligatoire avant chaque choix ayant une conséquence ;
- découvert autorisé temporaire avec frais, intérêts, régularisation, mise en demeure et contentieux ;
- dossiers fiscaux et bancaires séparés dans le Juridique.

## Anti-contournements vanilla validés à intégrer

Ces protections sont des règles globales AgriLife et doivent s'appliquer quelle que soit la difficulté. La difficulté peut modifier coûts, délais, tolérances et conséquences, mais ne doit pas réouvrir un contournement vanilla.

### Contrats du menu Échap

- bloquer la création et l'acceptation de nouveaux contrats vanilla lorsque AgriLife Manager est actif ;
- AgriLife Contrats & Marchés devient la source principale des nouveaux contrats ;
- les anciens contrats vanilla déjà acceptés sur une sauvegarde existante doivent pouvoir être terminés proprement sans créer de nouveau contrat vanilla ;
- lorsque c'est techniquement sûr, masquer ou désactiver l'accès vanilla devenu inutile et expliquer que les contrats sont gérés par AgriLife.

### Finances du menu Échap

- empêcher toute opération vanilla d'emprunt ou de remboursement qui contournerait AgriLife Banque ;
- conserver uniquement les informations financières vanilla qui restent utiles et cohérentes ;
- si l'onglet Finances reste visible, le rendre informatif et indiquer clairement que les opérations bancaires sont gérées dans AgriLife Manager > Banque ;
- aucune dette, aucun remboursement et aucun crédit ne doivent pouvoir être créés par une deuxième logique concurrente.

### Réinitialisation des véhicules et outils

- bloquer la réinitialisation vanilla gratuite des véhicules et outils lorsque AgriLife Manager est actif ;
- remplacer cette téléportation par une procédure AgriLife de récupération, dépannage, enlèvement ou transport ;
- proposer une destination cohérente selon le cas, concessionnaire, atelier, dépôt ou ferme ;
- appliquer coût, délai et éventuelle immobilisation selon la situation et la difficulté ;
- conserver une récupération de secours pour les cas réellement bloqués, mais jamais comme téléportation gratuite permettant de contourner livraison, panne, remorquage ou logistique ;
- relier cette procédure aux systèmes Concessionnaire, Atelier, Assurance et logistique lorsque ces blocs sont disponibles.

Ces trois règles doivent être reportées de façon additive dans la feuille de route maître lors de la prochaine passe d'écriture concernée, puis testées séparément dans Farming Simulator 25 avant validation.

## Prochain contrôle F03

1. Ouvrir Banque sur la 0.9.3.26.
2. Parcourir plusieurs banques et conseillers.
3. Vérifier que les explications et conditions d'accès sont compréhensibles.
4. Revenir sur la banque et le conseiller de référence de la sauvegarde.
5. Ouvrir la confirmation de signature de convention.
6. Répondre Non pour ce contrôle.
7. Envoyer les captures et le log avant toute vraie signature.

## État GitHub

Le numéro de version 0.9.3.26 est présent sur `main`. Le dépôt reste un miroir partiel tant que tous les gros fichiers Banque, Administration et toutes les traductions distribuées dans le ZIP ne sont pas présents et vérifiés.

La build ZIP 0.9.3.26 reste la référence exécutable complète pour les tests en jeu.

## Règles permanentes

- correction, test ciblé, validation complète, puis étape suivante ;
- aucune fonction validée uniquement parce que son code existe ;
- aucune phase de test ne doit être sautée ;
- aucun tiret cadratin dans les contenus du projet ;
- aucune attribution automatique à une IA ou à un fournisseur ;
- aucun fichier déclaré synchronisé tant que sa présence et son contenu ne sont pas réellement vérifiés sur `main`.
