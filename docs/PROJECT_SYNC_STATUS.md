# État de synchronisation AgriLife Manager

Version de référence : **0.9.3.27 TEST**
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

La reprise se fait sur la build 0.9.3.27. Le premier contrôle reste Banque : parcourir banques et conseillers, revenir sur le couple de référence, ouvrir `Signer convention`, lire l'explication puis répondre Non.

## Règles permanentes

- correction, test ciblé, validation complète, puis étape suivante ;
- aucune fonction validée uniquement parce que son code existe ;
- aucun tiret cadratin dans les contenus du projet ;
- aucune attribution automatique à une IA ou à un fournisseur ;
- aucun fichier déclaré synchronisé tant que sa présence et son contenu ne sont pas réellement vérifiés sur `main`.
