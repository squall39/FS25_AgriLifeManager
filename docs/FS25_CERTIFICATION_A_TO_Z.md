<!-- Copyright (C) 2026 Chez_Squall. All rights reserved. -->
# AgriLife Manager 0.9.1.0 - certification FS25 A à Z

Ce protocole transforme l'état **ÉCRIT / À CERTIFIER** en validation terrain reproductible. Il ne remplace pas `ROADMAP.md` : il sert uniquement à certifier les fonctions déjà écrites.

## Règles générales

Pour chaque scénario, noter :

- date du test ;
- version AgriLife Manager ;
- map utilisée ;
- difficulté ;
- liste des mods tiers actifs ;
- sauvegarde neuve ou existante ;
- résultat : `OK`, `KO`, `À REFAIRE` ;
- anomalie observée ;
- extrait pertinent du `log.txt` si nécessaire ;
- capture d'écran lorsque l'UI ou une validation visuelle est concernée.

Un scénario persistant doit être contrôlé avant sauvegarde puis après rechargement.

---

# A. Préparation de la build TEST

## A1 - Installation propre

1. Retirer toute ancienne copie de `FS25_AgriLifeManager` du dossier mods.
2. Installer uniquement la build TEST 0.9.1.0 à certifier.
3. Lancer FS25 avec AgriLife Manager comme seul mod scripté non indispensable au scénario.
4. Ouvrir le menu des mods et vérifier que le mod est détecté sans dépendance dure absente.
5. Quitter après chargement et contrôler le `log.txt`.

Attendu : aucun doublon de mod, aucune erreur de chargement AgriLife Manager, aucune source Lua manquante.

## A2 - Référence de test

Conserver une copie du `log.txt` initial et noter la version exacte de FS25. Toute anomalie future doit être comparée à cette référence.

---

# B. Nouvelle carrière - Facile

## B1 - Création

1. Créer une nouvelle partie sur une map vanilla.
2. Choisir **Facile**.
3. Terminer la création du personnage.
4. Entrer réellement sur la map.

Attendu : l'interface AgriLife Manager ne doit pas interrompre la sélection vestimentaire. L'onboarding doit commencer après l'entrée effective dans la partie selon sa logique prévue.

## B2 - Onboarding et tutoriel

1. Ouvrir le tutoriel lors de sa première proposition.
2. Parcourir toutes les pages avec Suivant/Précédent.
3. Fermer le tutoriel.
4. Vérifier qu'il ne se relance pas en boucle sur la même sauvegarde.
5. Vérifier l'accès manuel à l'aide/tutoriel depuis l'interface prévue.

Attendu : textes localisés, boutons fonctionnels, ordre des étapes cohérent, aucune superposition bloquante.

## B3 - Démarrage économique

Contrôler capital, banque, conseiller et état de l'exploitation correspondant au mode Facile. Les restrictions propres aux difficultés supérieures ne doivent pas être appliquées par erreur.

---

# C. Nouvelle carrière - Normal

## C1 - Création et persistance

Créer une nouvelle partie en **Normal**, noter le capital, les états banque/exploitation/permis, sauvegarder, quitter puis recharger.

Attendu : tous les états reviennent à l'identique.

## C2 - Permis provisoire et progression

Vérifier le comportement prévu du permis en Normal, son historique et les éventuels verrous fonctionnels associés.

---

# D. Nouvelle carrière - Difficile

## D1 - Verrous de démarrage

Créer une nouvelle partie en **Difficile** et vérifier l'application des exigences prévues avant accès complet aux fonctions concernées.

## D2 - Banque et exploitation

Vérifier les restrictions banque/conseiller, financement, statut d'exploitation et progression de déblocage.

## D3 - Sauvegarde/rechargement

Sauvegarder à chaque état intermédiaire important puis recharger pour confirmer qu'aucun verrou ne se réinitialise ou ne saute.

---

# E. Permis agricole - parcours complet 1 à 10

Effectuer les 10 étapes dans une sauvegarde dédiée.

Pour chaque étape :

1. noter l'objectif affiché ;
2. exécuter uniquement l'action demandée ;
3. vérifier que l'étape ne se valide pas trop tôt ;
4. vérifier qu'elle se valide une seule fois ;
5. contrôler le retour visuel et textuel ;
6. sauvegarder/recharger après les étapes 3, 6, 9 et 10.

Points critiques :

- l'XP carrière ne doit pas progresser pendant un examen si ce comportement est prévu ;
- la dernière étape doit produire une confirmation claire d'obtention ;
- après réussite finale, l'interface ne doit pas redemander de recommencer l'examen ;
- le démarrage/arrêt du véhicule doit respecter la logique attendue de l'étape ;
- l'historique du permis doit rester correct après reload.

---

# F. XP, catégories d'activité et HUD

## F1 - Conduite et transport

1. Rouler sur route avec véhicule sans travail actif.
2. Vérifier la catégorie XP affichée.
3. Relever puis abaisser un outil sans travailler le sol.

Attendu : aucune attribution incohérente de travail du sol sur route.

## F2 - Travail du sol

1. Entrer dans un champ.
2. Travailler réellement avec cultivateur ou outil compatible.
3. Vérifier la catégorie XP et la progression.
4. Relever l'outil dans le champ et vérifier le changement de catégorie si prévu.

## F3 - Moisson et autres catégories

Répéter avec moisson, livraison et autres activités supportées.

## F4 - Niveaux et étoiles

Faire franchir au moins un seuil de niveau et vérifier compteur, étoile/niveau, persistance et absence de double attribution.

## F5 - HUD

Contrôler :

- barre/couronne XP ;
- progression permis ;
- libellé de l'activité ;
- lisibilité ;
- absence de chevauchement avec mini-PDA et HUD FS25 ;
- comportement après changement de résolution/UI scale.

---

# G. Banque, comptabilité et fiscalité

## G1 - Consultation bancaire

Ouvrir la banque et vérifier profils, conseiller, conditions et informations de financement.

## G2 - Crédit

Créer au moins un crédit autorisé puis vérifier :

- montant reçu ;
- échéancier/état ;
- grand livre ;
- séparation financement/résultat ;
- sauvegarde/rechargement.

## G3 - Refinancement

Tester un refinancement valide et un cas refusé.

## G4 - Grand livre et filtres

Créer plusieurs types de mouvements et vérifier filtres, métadonnées et totaux.

## G5 - Comptabilité

Vérifier au minimum résultat, investissements, amortissements, bilan, capacité d'autofinancement et rentabilité par activité avec des transactions connues.

## G6 - Fiscalité

Déclencher un cas fiscal mesurable et comparer les montants avant/après sauvegarde.

---

# H. Entreprise et salariés

## H1 - Recrutement

Recruter un salarié et vérifier coût, fiche, XP/compétence et persistance.

## H2 - Planning et ordre de travail

Créer un ordre, l'affecter puis vérifier exécution, annulation et changement de salarié.

## H3 - IA FS25

Tester un ordre reposant sur l'IA native sans Courseplay ni AutoDrive.

## H4 - Paie

Vérifier qu'une même période de paie ne peut pas être débitée deux fois.

## H5 - Incident et réputation

Déclencher au moins un événement influençant réputation/incident et vérifier son historique.

---

# I. Administration

Tester les états administratifs supportés : documents, contrôle, sanction, récidive, assurance, contentieux et huissier lorsque les préconditions peuvent être réunies.

Pour chaque mécanisme : vérifier déclenchement, conséquence, journal/historique, persistance et impossibilité de répétition abusive sur la même occurrence.

---

# J. Contrats et marchés

## J1 - Contrat commercial

Créer/accepter un engagement puis le mener à succès.

## J2 - Échec

Créer un second scénario menant volontairement à l'échec ou à l'expiration.

## J3 - Négociation et notation

Vérifier impact sur relation acheteur et notation A-E.

## J4 - Marchés

Contrôler au minimum :

- marché mondial/local ;
- intrants ;
- énergie ;
- foncier ;
- location ;
- productions ;
- neuf/occasion ;
- fruits détectés dynamiquement.

## J5 - Multifruits

Refaire le contrôle sur une modmap multifruits et vérifier qu'aucune liste fixe ne bloque les fruits supplémentaires.

---

# K. Atelier, concessionnaire et assurance

## K1 - Usure et entretien

Utiliser un véhicule suffisamment pour produire des données d'usure puis vérifier entretien/révision.

## K2 - Panne

Déclencher ou reproduire un scénario de panne supporté et vérifier immobilisation/conséquence/réparation.

## K3 - Pièces et délais

Tester une opération nécessitant pièces et délai si le système le permet dans les conditions choisies.

## K4 - Contrôle technique et historique

Vérifier statut, inspection, historique et persistance.

## K5 - Occasion

Tester inspection/achat/vente d'occasion et cohérence de l'état technique.

## K6 - Accident, responsabilité et assurance

Tester constat, responsabilité, bonus-malus et sinistre sans double indemnisation.

---

# L. Sauvegardes et migrations

## L1 - Sauvegarde 0.9.1.0

Créer plusieurs états persistants répartis dans les modules, sauvegarder, quitter complètement FS25 et recharger.

Attendu : aucun module ne revient à sa valeur par défaut de façon injustifiée.

## L2 - Migration

Tester au moins une sauvegarde de schéma précédent compatible avec la migration prévue.

## L3 - Backup/récupération

Tester le mécanisme de récupération documenté avec une copie de sauvegarde dédiée, jamais sur la sauvegarde principale de test.

---

# M. Compatibilités optionnelles

Le mod doit d'abord être validé seul. Ensuite activer séparément, puis en combinaisons raisonnables :

- Courseplay ;
- AutoDrive ;
- Precision Farming ;
- Soil Fertilizer ;
- MudSystem ;
- Advanced Damage System ;
- autres intégrations officiellement déclarées par la build.

Attendu : l'absence d'un mod tiers ne casse jamais AgriLife Manager ; sa présence enrichit uniquement le bloc prévu.

---

# N. Maps et contenu dynamique

Certifier au minimum :

1. une map vanilla ;
2. une modmap standard ;
3. une modmap multifruits ;
4. une map avec productions supplémentaires si disponible.

Contrôler détection des fruits, productions, fillTypes, foncier et contenus économiques sans dépendance à une liste fixe obsolète.

---

# O. Interface, résolutions et localisation

Tester au minimum plusieurs configurations d'affichage pertinentes :

- 1920x1080 ;
- une résolution large supérieure si disponible ;
- un UI scale différent de la valeur habituelle.

Contrôler tableau de bord, six cartes, navigation, tutoriel, journal, HUD, fenêtres banque/entreprise/administration/marchés/atelier et boutons contextuels.

Effectuer la certification fonctionnelle principale en français. Faire au moins un lancement dans une autre langue distribuée pour vérifier qu'aucune clé brute n'apparaît.

---

# P. Log et stabilité

Après chaque grande phase :

1. sauvegarder ;
2. quitter au menu principal ;
3. quitter complètement FS25 ;
4. archiver le `log.txt` ;
5. rechercher `Error`, `Warning`, `AgriLife`, `stack traceback`, `nil value`, `attempt to`.

Un warning FS25 externe au mod doit être identifié comme tel, pas simplement ignoré.

---

# Q. Multijoueur

La publication multijoueur reste désactivée tant que la certification réseau dédiée n'est pas faite.

Ne pas considérer la présence de code réseau ou de séparation par ferme comme une preuve de compatibilité publique.

Lorsque la phase multi sera ouverte, elle devra couvrir au minimum serveur autoritaire, deux fermes, permissions, synchronisation, join-in-progress, sauvegarde serveur et refus des données appartenant à une autre ferme.

---

# R. Validation finale de la 0.9.1.0 TEST

La build peut être considérée comme candidate stable uniquement si :

- tous les scénarios bloquants A à P sont `OK` ou documentés comme non applicables ;
- aucun bug de corruption de sauvegarde n'est connu ;
- aucun crash reproductible n'est connu ;
- aucun doublon de paiement/XP/récompense bloquant n'est connu ;
- aucun verrou de progression principal ne reste cassé ;
- les logs des scénarios de référence sont propres côté AgriLife Manager ;
- les régressions UI bloquantes sont absentes ;
- les cases de roadmap nécessitant une validation terrain ne sont fermées qu'après preuve réelle.

## Ordre conseillé pour les sessions réelles

Pour éviter de refaire inutilement des heures de test :

1. A + B2 : installation et onboarding ;
2. E : permis 1 à 10 ;
3. F : XP/HUD ;
4. B/C/D : difficultés et démarrage économique ;
5. G : banque/comptabilité ;
6. L : sauvegarde/reload/migration ;
7. H + I + J : entreprise, administration, marchés ;
8. K : atelier/assurance ;
9. M + N : compatibilités et maps ;
10. O + P : UI, localisation, logs ;
11. Q uniquement lorsque le multijoueur sera officiellement ouvert aux tests.
