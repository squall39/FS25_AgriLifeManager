# État de synchronisation AgriLife Manager

Version de référence : **0.9.3.36 TEST**
Date : **14 août 2026**

## État campagne

- F01 : **VALIDÉE EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉE EN JEU** en 0.9.3.23.
- F03 : **ACTIVE - Banque fonctionnelle**.
- F04 et phases suivantes : en attente de validation complète de F03.
- Correction XP intégrée depuis 0.9.3.26 : retest reporté, sans bloquer la reprise de F03 Banque.

## Préparation transversale 0.9.3.27

Cette passe a été explicitement autorisée avant la reprise des tests. Elle écrit les systèmes mais ne les certifie pas en jeu.

- séparation nom de ferme, forme juridique, activités et réseaux professionnels ;
- formes EI, EARL, GAEC, SCEA, EURL, SARL, SASU et SAS ;
- ETA raccordée aux prestations inter-exploitations ;
- coopérative agricole raccordée aux offres commerciales compatibles ;
- CUMA retirée des formes juridiques, migration conservée, sélection non activée tant que le matériel mutualisé n'est pas réellement jouable ;
- conseiller de gestion dynamique connecté au recrutement et aux choix de structure ;
- paiements de contrats AgriLife immédiats, mensuels ou différés ;
- nouveaux contrats vanilla neutralisés ;
- crédit vanilla neutralisé par UI et contrôle économique ;
- reset matériel gratuit remplacé par récupération AgriLife lorsqu'un callback FS25 compatible est détecté ;
- explication obligatoire avant chaque choix conséquent.

## Prochain contrôle F03

La build 0.9.3.36 doit valider l'affichage des horaires de la banque parcourue : banques physiques ouvertes ou fermées selon l'heure du jeu, banques numériques ouvertes 24/7, sans masquer les messages Banque/Conseiller. F03 reste active jusqu'au contrôle visuel et au log propre.

## Règles permanentes

- correction, test ciblé, validation complète, puis étape suivante ;
- aucune fonction validée uniquement parce que son code existe ;
- aucun tiret cadratin dans les contenus du projet ;
- aucune attribution automatique à une IA ou à un fournisseur ;
- aucun fichier déclaré synchronisé tant que sa présence et son contenu ne sont pas réellement vérifiés sur `main`.


## Préparation transversale 0.9.3.28

Écrite localement avant reprise des tests : calendrier 1-28 jours/mois, CUMA jouable, conseiller de gestion étendu, santé financière jusqu'à faillite, rémunération dirigeant, aide agricole annuelle et explications sur les investissements. Ces fonctions restent non certifiées en jeu.


## F03 Banque 0.9.3.35

Correction locale de la signature de convention : sélection banque/conseiller obligatoire avant signature, faux message de refus de crédit supprimé, conseiller obsolète masqué pendant le parcours, aperçu de prêt allégé pour la fluidité. Validation FS25 encore requise.
## F03 Banque 0.9.3.36

Ajout du statut d'ouverture directement sous la banque parcourue. Les banques physiques affichent leurs horaires 08:00-12:00 / 14:00-18:00 et leur état selon l'heure du jeu. Les banques numériques affichent 24/7. Le message de verrouillage ou de confirmation reste séparé. Validation FS25 requise.
