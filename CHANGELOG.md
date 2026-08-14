# Changelog AgriLife Manager

## 0.9.3.28 TEST

- Centralise le calendrier AgriLife sur les périodes FS25 : un mois AgriLife correspond toujours à un changement de mois du jeu, que le joueur utilise 1 à 28 jours par mois.
- Sépare explicitement les traitements mensuels des futurs traitements quotidiens afin qu'un réglage de 28 jours ne multiplie jamais par 28 une mensualité, un salaire, un intérêt ou une échéance.
- Active le gameplay CUMA : adhésion professionnelle, catalogue de matériel mutualisé, réservation, frais, dépôt, délai en heures de jeu, mise à disposition, mensualités et restitution.
- Ajoute le choix Leasing / CUMA dans la page matériel et conserve une confirmation expliquée avant toute réservation.
- Ajoute une santé financière progressive de l'exploitation : surveillance, fragilité, difficulté, défaut, insolvabilité puis faillite si la mauvaise gestion persiste.
- Les difficultés modifient la vitesse d'escalade vers l'insolvabilité et la faillite. Les actions de redressement restent proposées et la remontée reste possible.
- Bloque les nouveaux emprunts, recrutements et investissements lorsque la situation financière a dépassé les seuils correspondants, sans bloquer remboursement, restructuration ou actions de sauvetage.
- En faillite, les nouveaux contrats sont suspendus tandis que les contrats existants et les actions de régularisation restent actifs.
- Formalise la rémunération du dirigeant et interdit de l'augmenter pendant une situation d'insolvabilité tout en permettant de la réduire.
- Étend le conseiller de gestion aux prêts, achats de parcelles, achats de productions ou matériels et locations, avec comparaison achat/location lorsque les données existent.
- Ajoute une aide agricole annuelle simplifiée, calculée sur les hectares détenus, la difficulté et la conformité administrative, versée en avance puis en solde à des changements de mois précis.
- Conserve les revenus AgriLife selon les trois modèles validés : immédiat, mensuel ou à échéance.
- F03 Banque reste la phase de certification active. Tous les ajouts 0.9.3.28 sont écrits mais restent à valider progressivement en jeu.

## 0.9.3.27 TEST

- Sépare définitivement le nom de ferme, la forme juridique, les activités économiques et les réseaux professionnels.
- Retire CUMA de la liste des formes juridiques et migre une ancienne sélection CUMA vers EI + adhésion CUMA conservée.
- Ajoute les formes EI, EARL, GAEC, SCEA, EURL, SARL, SASU et SAS avec conditions d'associés, coûts de transformation, charges administratives et limites d'activités distinctes.
- Raccorde la structure juridique à la capacité et au taux bancaires de façon modérée, avec pénalité en cas de frais structurels impayés.
- Ajoute le socle d'activités secondaires et active réellement ETA dans les règlements de prestations inter-exploitations.
- Ajoute le socle des réseaux professionnels et active réellement la coopérative agricole dans les offres commerciales compatibles.
- Prépare CUMA et groupement d'employeurs sans les rendre sélectionnables tant que leur gameplay matériel ou emploi n'est pas réellement raccordé.
- Ajoute un conseiller de gestion dynamique fondé sur la trésorerie, les engagements mensuels, la dette, le contentieux, les pénalités et la difficulté.
- Le conseiller de gestion est raccordé aux choix de forme juridique, d'activité, de réseau et au recrutement avant validation.
- Ajoute trois logiques de paiement AgriLife pour les contrats commerciaux : immédiat, mensuel et règlement différé après livraison, avec gestion d'acompte et de créance.
- Renforce le remplacement des contrats vanilla par AgriLife et conserve les anciens contrats déjà actifs comme héritage terminable.
- Maintient les opérations de crédit vanilla bloquées et l'onglet Finances vanilla limité aux informations utiles.
- Remplace la réinitialisation gratuite détectée des véhicules et outils par une demande de récupération AgriLife avec coût et délai, sans supprimer la possibilité de secours.
- Généralise l'explication avant toute décision conséquente : effets, coûts, risques, réversibilité et avis du conseiller quand il est pertinent.
- F03 Banque reste la phase de test active. Ces ajouts sont écrits et audités mais ne sont pas considérés validés en jeu.

## 0.9.3.26 TEST

- Corrige la progression des étoiles de spécialité : 1 étoile tous les 1 000 XP, jusqu'à 10 étoiles.
- Corrige le HUD mini-PDA pour ne plus mélanger XP total et progression du palier courant.
- Le HUD affiche désormais l'XP total séparément puis la progression réelle dans la tranche de 1 000 XP en cours.
- Exemple attendu : 3 036 XP = 3 étoiles, 36 / 1 000 XP vers le palier suivant, soit environ 4 %.
- F03 Banque reste active et aucune validation F03 supplémentaire n'est ouverte par cette correction XP.

## 0.9.3.25 TEST

- Corrige le bouton `Signer convention` dans Banque.
- Rend la convention bancaire obligatoire avant l'envoi réel d'une demande de prêt, tout en conservant la simulation libre.
- Ajoute un catalogue extensible de banques locales, régionales, nationales, internationales et 100 % en ligne.
- Ajoute des niveaux d'accès de 0 à 5 pour banques et conseillers, séparés de réputation et compétence.
- Le mode Facile peut choisir librement tous les profils compatibles. Normal et Difficile utilisent la progression bancaire.
- Rattache chaque conseiller à une ou plusieurs banques compatibles.
- Ajoute des banques en ligne disponibles 24 h/24 pour leurs opérations client et des banques internationales à critères renforcés.
- Ajoute une explication obligatoire avant validation d'une banque, d'un conseiller et d'une convention.
- Ajoute le socle `AgriLifeDecisionGuide` destiné à généraliser l'explication des choix conséquents dans les autres modules.

- Corrige le bouton `Signer` du contrat bancaire qui restait désactivé malgré les droits du propriétaire.
- Restaure le calcul local de l’autorisation `bank.manage` lors du rafraîchissement de la Banque.
- Ajoute un retour explicite si une action de contrat bancaire est appelée sans autorisation.
- F03 reste active jusqu’à validation en jeu du contrat bancaire.

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
