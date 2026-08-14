# Changelog AgriLife Manager

## 0.9.3.26 TEST

- Corrige la progression des étoiles de spécialité : 1 étoile tous les 1 000 XP, jusqu'à 10 étoiles.
- Corrige le HUD mini-PDA pour ne plus mélanger XP total et progression du palier courant.
- L'XP total est affiché séparément de la progression dans la tranche de 1 000 XP en cours.
- Exemple de référence : 3 036 XP = 3 étoiles, 36 / 1 000 XP et environ 4 % vers le palier suivant.
- F03 Banque reste active.

## 0.9.3.24 TEST

- Corrige la classification comptable du découvert, de son contentieux et des règlements fiscaux ou bancaires.

- Sépare les dossiers fiscaux et bancaires dans les plans de paiement, règlements et restrictions Juridiques.

- Met à jour le guide du mod et Assistance pour expliquer le découvert temporaire et son recouvrement.

- Bloque tout renouvellement de découvert pendant la régularisation, la mise en demeure ou le contentieux.
- F03 Banque : remplace le découvert permanent par une autorisation temporaire avec durée, frais d'ouverture ou de renouvellement et échéance enregistrée.
- F03 Banque : après échéance avec solde négatif, ouvre un délai de régularisation, puis une mise en demeure avec frais de recouvrement si la situation persiste.
- F03 Banque : après la mise en demeure non régularisée, convertit le découvert en dette contentieuse sans double comptabilisation du principal et transmet le dossier au module Juridique.
- F03 Banque : le passage au contentieux dégrade la relation bancaire, ferme la ligne de découvert et peut déclencher la résiliation bancaire.
- F03 Banque : les intérêts de découvert deviennent majorés pendant la phase de régularisation puis la mise en demeure.
- F03 Banque : les dossiers Juridique distinguent désormais leur origine afin qu'un contentieux bancaire ne soit plus fusionné silencieusement avec un dossier fiscal.
- F03 Banque : le renouvellement du contrat bancaire est transactionnel et restaure l’ancien état si la nouvelle signature échoue.
- F03 Banque : le refinancement utilise une capacité de remplacement dédiée, afin de ne plus évaluer le prêt remplacé comme s’il restait en plus du nouveau.
- F03 Banque : un ancien prêt actif ne bloque plus le changement d’établissement une fois la relation libérée ; le prêt conserve sa banque d’origine, tandis que le découvert et les arriérés du compte courant doivent être soldés.
- F03 Banque : les frais de dossier d’un crédit ou refinancement ne peuvent plus dépasser les fonds professionnels autorisés ; un échec de débit annule proprement la création du prêt.
- F03 Banque : toutes les périodes bancaires manquées sont maintenant rattrapées après reprise de sauvegarde, sans plafond silencieux à 12 mensualités.

- Ouvre la préparation fonctionnelle F03 Banque après validation de F02.
- Corrige la lecture du prêt actif : capital restant et mois restants utilisent désormais les vraies données du crédit.
- Corrige le réaménagement +12 mois pour l’appliquer au calendrier restant au lieu de repartir de la durée totale initiale.
- Corrige le remboursement anticipé pour calculer les 10 % sur le capital réellement restant.
- Ajoute une confirmation avant demande de prêt, remboursement anticipé, réaménagement, modification de découvert, signature/renouvellement/résiliation du contrat bancaire, refinancement et paiement fiscal.
- Affiche avant remboursement anticipé le montant, les frais de la banque d’origine et le débit total.
- Localise les messages Banque utilisés par ces actions et supprime plusieurs textes français codés en dur de l’écran Banque.
- Ajoute un retour explicite lorsque la banque est fermée selon les horaires AgriLife.
- Conserve les règles tarifaires de la banque d’origine pour les frais propres aux prêts existants après changement d’établissement.
- Rend le découvert professionnel fonctionnel : l’utilisation suit le solde négatif réel de la ferme, les échéances et frais bancaires peuvent consommer la ligne autorisée, et les crédits reçus la remboursent automatiquement lorsque le solde remonte.
- Ajoute les intérêts mensuels de découvert selon le taux de la banque, leur historique, leurs éventuels arriérés et leur persistance.
- Intègre le découvert utilisé et les intérêts en retard à la dette AgriLife et donc à la capacité bancaire.
- Affiche plafond, utilisation, disponible, taux, intérêts en retard et dépassement de plafond dans l’écran Banque.
- Conserve F03 active pour test ciblé en jeu.

## 0.9.3.23 TEST

- Termine le retest F02 du tableau de bord après contrôle en jeu de la 0.9.3.22.
- Élargit encore la zone d'aide contextuelle et raccourcit les textes français des trois modes pour supprimer la coupure en haut de l'écran.
- Remplace les glyphes Unicode étoile non supportés par la police FS25 par des notes numériques sur 5 dans le résumé Banque.
- Supprime les warnings de police associés aux caractères étoile du tableau de bord.
- Conserve la séparation Banque, Conseiller et Score de crédit validée visuellement.

## 0.9.3.22 TEST

- Corrige la lisibilité de l'aide contextuelle dans l'en-tête du tableau de bord.
- Réaligne la carte Banque sur la grille des autres modules.
- Affiche la banque et le conseiller sur deux lignes distinctes et persistantes.
- Retire le nom de la banque de la ligne Score de crédit, qui affiche désormais uniquement le score et son appréciation.
- Conserve F02 active pour validation en jeu.

## 0.9.3.21

- F02 interface conservée après validation visuelle.
- Compression DXT5 de `gui/icons/status_good.dds` pour supprimer le warning de texture brute dans FS25.

## 0.9.3.20 TEST

- Clarifie Acheter/Vendre, Louer/Résilier et Négocier/Signer dans Contrats & Marchés.
- Masque les boutons d'action Atelier lorsqu'aucune action n'est disponible.
- Conserve F02 active pour retest ciblé.

# 0.9.3.19 TEST

- rend visibles les vues Entreprise Dossier, Planning, Formations, Carrière et Incidents avec des onglets directs
- clarifie Contrats & Marchés avec des libellés explicites pour marché, article, volume, durée, prix, relation et négociation
- remplace le sélecteur cyclique Atelier par six onglets directs
- ajoute un pictogramme HUD cohérent dans chaque vue Atelier et retire les pictogrammes violets des pièces
- améliore les noms des familles de pièces et le nom affiché du mécanicien
- conserve F02 comme phase active de reprise des tests

# 0.9.3.18 TEST

- Ajoute la logistique de délai pour achats physiques neufs et occasion.
- Ajoute le choix retrait concessionnaire ou livraison à la ferme.
- Rend les délais de pièces de rechange obligatoires, y compris en urgence.
- Ajoute un délai de remise pour les biens remportés aux enchères.
- Conserve toutes les locations en disponibilité immédiate.
- Ajoute le socle téléphone par joueur et le registre des applications AgriLife.

# 0.9.3.17 TEST

- transferts physiques inter-fermes pour cultures, bottes et materiel
- location inter-fermes avec etat, degats, retard et retour
- progression automatique depuis travail de champ et transport
- factures fournisseurs avec echeances et retards
- saisies et encheres etendues au materiel, champs et productions
- reglements securises avec rollback en cas d echec
- F02 conservee comme phase de reprise des tests

# 0.9.3.16 TEST

- priorite permanente aux icones HUD comprehensibles et coherentes
- politique centrale de resolution des icones HUD
- socle de ventes aux encheres aleatoires pour materiel, champs, usines et saisies
- mises, reserve, concurrence automatique et controle des fonds par le serveur
- produits des saisies affectes a la dette contentieuse en priorite
- transfert impossible conserve en attente au lieu de supprimer ou dupliquer un bien

# 0.9.3.15 TEST

- relations fournisseurs reliees aux achats et aux conditions commerciales
- moral du patron, des joueurs reels et des salaries virtuels
- fidelite, promotions et evolution professionnelle des salaries
- reputation en cascade entre paie, administration, contrats, banque et fournisseurs
- icones HUD de familles de pieces dans les vues Atelier compatibles
- socle multijoueur inter-fermes avec entraide, prestations, ventes, location et remuneration configurable
- contrats inter-fermes geres par le serveur avec sauvegarde, relations entre fermes et penalites
- nouveaux contrats vanilla desactives lorsque AgriLife Manager est actif, les contrats vanilla deja acceptes restent terminables
- consequences renforcees en cas de contrat AgriLife non respecte
