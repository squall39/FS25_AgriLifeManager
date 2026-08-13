# Changelog AgriLife Manager

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
