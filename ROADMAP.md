# Feuille de route — AgriLife Manager

Cette feuille de route décrit l’ordre de développement actuellement retenu pour AgriLife Manager. Elle évoluera au fil des tests.

## Phase 1 — Banque & finance

### Banque / conseiller
- [x] Banque et conseiller obligatoires selon le flux AgriLife.
- [x] Demande de crédit avec délai d’étude.
- [x] Délai basé sur l’horloge de jeu FS25, pas sur le temps réel.
- [x] Décision réelle : acceptation, refus ou validation conditionnelle selon le dossier.
- [x] Persistance du dossier bancaire en sauvegarde.
- [x] Une seule demande active à la fois.
- [x] Objet du financement sélectionnable.
- [x] Profils bancaires et conseillers différenciés.
- [x] Réputation et compétence affichées séparément en étoiles pour les banques et les conseillers.
- [x] Valeurs d’étoiles différentes d’une banque/conseiller à l’autre.
- [x] Qualité intrinsèque du professionnel séparée de la relation/confiance personnelle du joueur.
- [ ] Ajouter/affiner solidité bancaire, politique de risque, sévérité et rapidité d’étude.
- [ ] Bloquer le changement de banque/conseiller pendant une demande en cours.
- [ ] Ajouter des raisons détaillées de décision et journaliser les facteurs déterminants.
- [ ] Faire varier davantage taux, plafond, durée, garanties et délai selon banque, conseiller, objet et qualité du dossier.

### Comptes & finances
- [x] Base du compte professionnel.
- [x] Base du compte personnel.
- [x] Début de relevé/mouvements sur le compte professionnel.
- [ ] Historique complet des transactions avec catégories/tags.
- [ ] Filtres par période, catégorie, fournisseur, contrat et type de flux.
- [ ] Détail des prêts : capital, restant dû, taux, mensualité, échéance, durée, coût total, remboursement anticipé.
- [ ] Affichage séparé de la dette FS25 héritée sur les sauvegardes existantes.
- [ ] Prévision de trésorerie et capacité d’emprunt.
- [ ] Refinancement / renégociation via conseiller.
- [ ] Séparation stricte pro/perso en difficulté Difficile.

### Menu Finances vanilla FS25
- [x] Blocage fonctionnel des nouvelles opérations de crédit vanilla.
- [ ] Intercepter les actions avant comptabilisation FS25.
- [ ] Supprimer/désactiver visuellement les commandes Emprunter / Rembourser dans le menu Finances vanilla.
- [ ] Préserver le reste des informations financières utiles du jeu.
- [ ] À terme, faire d’AgriLife → Banque → Finances la page financière principale.

## Phase 2 — Interface & expérience utilisateur

- [x] Nouvelle identité visuelle sombre et structurée.
- [x] Navigation AgriLife intégrée au menu Échap.
- [x] Tutoriel lancé une fois réellement en jeu.
- [x] Assistance native intégrée.
- [x] Support 1920x1080 validé comme base.
- [x] Pictogrammes conservés comme élément volontaire de l’identité AgriLife.
- [x] Tableau de bord : action obligatoire contextuelle Banque → Conseiller → Société → Permis.
- [ ] Finaliser l’adaptation 1440p / 4K.
- [ ] Continuer à harmoniser taille, netteté et placement des pictogrammes **sans les supprimer**.
- [ ] Conserver une présentation proche d’une application/web moderne sans surcharge.
- [ ] Harmoniser tailles de texte, boutons et onglets.
- [ ] Supprimer tout artefact visuel résiduel.
- [ ] Synchroniser chaque évolution majeure avec le tutoriel et Échap → Assistance.

## Phase 3 — Personnel, contrats, ordres de travail & paie

Le module Personnel doit devenir un véritable système de main-d’œuvre. **AgriLife devient la source unique de paie des salariés** afin d’éviter de payer deux fois un même ouvrier lorsqu’une tâche est exécutée par FS25, Courseplay ou AutoDrive.

### Salariés & contrats
- [x] Structure Personnel / Équipe & paie.
- [x] Base des employés AgriLife.
- [x] Compétences visuelles en étoiles.
- [ ] Ajouter trois types de contrats : **CDI, CDD et saisonnier**.
- [ ] CDI : emploi permanent, salaire régulier, ancienneté, évolution salariale, coût de rupture/licenciement selon règles AgriLife.
- [ ] CDD : date de début et de fin, salaire défini, renouvellement possible, fin automatique ou transformation en CDI.
- [ ] Saisonnier : recrutement pour une campagne/période déterminée (semis, récolte, ensilage, vendanges, etc.) avec disponibilité temporaire.
- [ ] Fiche salarié complète : contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, expérience, historique et état actuel.
- [ ] Disponibilité, horaires, pauses, heures supplémentaires, congés, maladie et absences.
- [ ] Promotion, augmentation, renouvellement, fin de contrat et licenciement.

### Une personne = une tâche réelle
- [ ] **1 salarié disponible = 1 tâche automatisée active maximum.**
- [ ] Empêcher qu’un même salarié soit affecté simultanément à plusieurs véhicules/tâches.
- [ ] Libérer automatiquement le salarié à la fin, l’arrêt ou l’annulation de sa tâche.
- [ ] Afficher clairement : disponible / affecté / en pause / absent / congé / malade.

### Centre d’ordres AgriLife — fonctionnement sans Courseplay/AutoDrive
- [ ] Permettre de donner directement un ordre à un salarié depuis AgriLife lorsque Courseplay/AutoDrive ne sont pas utilisés.
- [ ] Sélection visuelle : **salarié → véhicule → outil → travail → champ/destination**.
- [ ] Proposer les travaux compatibles avec le véhicule et l’outil réellement attaché.
- [ ] S’appuyer sur l’IA native FS25 lorsque le travail demandé est supporté par le jeu.
- [ ] Commandes : démarrer, mettre en pause, reprendre, arrêter/rappeler.
- [ ] Afficher l’état de la mission, la progression, le champ/destination, le véhicule et l’outil utilisés.
- [ ] Prévoir des ordres agricoles : préparation du sol, semis, fertilisation, pulvérisation, récolte, transport et autres travaux supportés.
- [ ] Ne jamais simuler un travail impossible : si FS25 ne sait pas exécuter l’ordre, l’interface doit l’indiquer au joueur.

### Paie unique & intégrations FS25 / Courseplay / AutoDrive
- [ ] Faire d’AgriLife **l’unique moteur de salaire** des employés enregistrés dans le module Personnel.
- [ ] Neutraliser le coût horaire de l’ouvrier vanilla FS25 lorsqu’une tâche est liée à un salarié AgriLife afin d’éviter la double facturation.
- [ ] Intégration optionnelle Courseplay : associer chaque tâche/driver Courseplay à un salarié AgriLife disponible.
- [ ] Lorsque Courseplay exécute la tâche pour un salarié AgriLife, neutraliser sa facturation de main-d’œuvre et laisser AgriLife calculer la paie.
- [ ] Intégration optionnelle AutoDrive : associer chaque conducteur/tâche AutoDrive à un salarié AgriLife disponible et éviter toute double facturation de main-d’œuvre si nécessaire.
- [ ] Les intégrations doivent être faites **à l’exécution par détection/hooks**, sans modifier les fichiers de Courseplay ou AutoDrive, afin de rester compatibles avec leurs mises à jour.
- [ ] Si Courseplay ou AutoDrive est absent, AgriLife doit rester entièrement fonctionnel avec son propre centre d’ordres et l’IA native FS25.
- [ ] Prévoir une sécurité : si une intégration n’est plus compatible après une mise à jour d’un mod tiers, ne pas casser AgriLife et revenir proprement au fonctionnement autonome.

### Expérience, compétences & évolution
- [ ] Chaque salarié gagne de l’expérience uniquement grâce au **travail réellement effectué**.
- [ ] Compétence générale + spécialités : sol, semis, fertilisation, récolte, transport, élevage, mécanique, etc.
- [ ] La progression dépend du temps de travail, du type de tâche, de la réussite et des incidents éventuels.
- [ ] Les étoiles/compétences évoluent progressivement au fil de la carrière du salarié.
- [ ] Un salarié expérimenté peut devenir plus efficace/fiable dans sa spécialité sans créer de bonus irréalistes.
- [ ] Le niveau de compétence doit influencer la rémunération et les possibilités d’évolution du salarié.
- [ ] Conserver l’historique de carrière du salarié dans la sauvegarde.

### Interface Personnel visuelle
- [ ] Cartes salariés avec pictogramme/portrait, nom, contrat, étoiles, spécialités et état en temps réel.
- [ ] Badge visuel CDI / CDD / SAISONNIER.
- [ ] Pendant une affectation : véhicule, outil, tâche, champ/destination, progression et durée de travail visibles.
- [ ] Écran de planification permettant d’affecter rapidement une personne à une tâche sans devoir parcourir plusieurs menus.
- [ ] Tableau de paie : salaire de base, heures réalisées, heures supplémentaires, primes/coûts et total employeur.
- [ ] Alertes visuelles en cas de salarié indisponible, fin de CDD, fin de saison, dépassement horaire ou tâche interrompue.

### Multijoueur
- [ ] Préparer la logique multijoueur : joueurs humains = collaborateurs actifs, sans bonus artificiels.
- [ ] Éviter qu’un joueur humain et un salarié AgriLife soient comptés deux fois pour la même tâche.

## Phase 4 — Carrière, XP, examens & permis

- [x] Structure carrière / XP.
- [x] Structure examens.
- [x] Permis agricole et progression d’examens disponibles en Difficile.
- [x] Le HUD conserve l’action exacte à réaliser pendant toute l’épreuve, y compris en Difficile — **implémenté en 0.6.4.24, à revalider en jeu**.
- [x] Panneau HUD vert + pictogramme après chaque étape réussie avec affichage immédiat de la consigne suivante — **implémenté en 0.6.4.24, à revalider en jeu**.
- [x] Affichage persistant de la nature de la dernière erreur d’examen.
- [x] Correction logique du retour du matériel : présence réelle de l’outil dans son cercle d’origine sans sortie/rentrée artificielle — **à revalider en jeu après l’étape 5**.
- [x] Progression de secours pour les travaux réels lorsque la surface WorkArea n’est pas remontée : outil compatible actif/abaissé + déplacement réel — **implémenté en 0.6.4.24**.
- [ ] Revalider toute la chaîne réelle des 10 étapes sur une partie complète.
- [ ] Valider définitivement l’épreuve 5 « cultivation » avec le test utilisateur au retour.
- [ ] Vérifier ensuite les étapes 6/10 à 10/10, notamment retour/dételage/parking/sortie.
- [ ] Vérifier chaque outil et chaque type de travail comptabilisé.
- [ ] Développer la réputation patron/société à partir de l’activité réelle.
- [ ] Faire évoluer le statut professionnel sans choix de profil artificiel.

## Phase 5 — Société & administration

- [x] Base du module Société.
- [x] Ordonnancement du démarrage clarifié : la société n’est proposée qu’après la banque et le conseiller lorsqu’ils sont requis.
- [ ] Gestion plus profonde de la structure juridique.
- [ ] Charges administratives selon difficulté.
- [ ] Obligations de création et de conformité en Difficile.
- [ ] Réputation et santé de l’entreprise exploitées par Banque, Contrats et Huissier.

## Phase 6 — Assurances

- [x] Base de l’écran Assurance.
- [ ] Contrats différenciés par formule, capital et risque.
- [ ] Sinistres et franchises.
- [ ] Impact du comportement, historique et difficulté sur les primes.
- [ ] Interaction avec atelier, véhicules, bâtiments et exploitation.

## Phase 7 — Atelier & cycle de vie du matériel

- [x] Base de l’Atelier.
- [x] État du matériel et opérations de maintenance.
- [ ] Usure, entretien et immobilisation plus poussés.
- [ ] Marché de l’occasion cohérent avec l’état réel du matériel.
- [ ] Coûts de maintenance et réparations liés à l’historique.
- [ ] Interaction avec assurances et trésorerie.

## Phase 8 — Contrats & coopératives

- [x] Base des contrats commerciaux.
- [ ] Passer d’une logique de mission à de vrais engagements commerciaux.
- [ ] Prix, volumes, délais, pénalités et qualité négociés.
- [ ] Contrats possibles avant semis/plantation.
- [ ] Acheteurs et coopératives multiples.
- [ ] Impact du conseiller, de la réputation et de l’historique.
- [ ] Surfaces conseillées / volumes prévisionnels.

## Phase 9 — Huissier & contentieux

Module volontairement approfondi et fortement lié à Banque.

- [ ] Retards et incidents de paiement.
- [ ] Relances et mises en demeure.
- [ ] Transmission au module Huissier.
- [ ] Frais, échéanciers et procédures.
- [ ] Conséquences sur réputation, banque, contrats et société.
- [ ] Mécanismes de sortie réalistes : régularisation, négociation, restructuration.

## Phase 10 — Compatibilités PC optionnelles

AgriLife Manager doit rester autonome : aucune de ces compatibilités ne doit devenir une dépendance dure.

- [ ] Courseplay.
- [ ] AutoDrive.
- [ ] Soil Fertilizer.
- [ ] Precision Farming / systèmes compatibles pertinents.
- [ ] Autres mods de gestion ou réalisme identifiés pendant les tests.
- [ ] Vérifier qu’AgriLife continue à fonctionner correctement lorsque ces mods sont absents.

## Phase 11 — Sauvegardes, migration & multijoueur

- [x] État AgriLife enregistré dans la sauvegarde carrière.
- [x] Migration des sauvegardes existantes sans écraser leur patrimoine.
- [x] Conservation de la dette FS25 existante comme dette héritée.
- [x] Nouvelle carrière : capital AgriLife et suppression du prêt de départ FS25.
- [ ] Renforcer les migrations entre versions du mod.
- [ ] Tests de corruption/récupération backup.
- [ ] Multi-fermes.
- [ ] Multijoueur complet.
- [ ] Autorité serveur et synchronisation réseau de tous les modules.

## Phase 12 — Localisation

- [x] Français comme langue principale de développement/test.
- [ ] Relecture complète FR.
- [ ] Relecture complète EN.
- [ ] Finaliser IT sans reliquats anglais.
- [ ] Chinois simplifié.
- [ ] Chinois traditionnel.
- [ ] Vérifier toutes les clés manquantes et doublons l10n.

## Phase 13 — Préparation publication

Objectif final : version PC propre et publiable, notamment pour soumission officielle GIANTS/ModHub si elle respecte les exigences applicables au moment de la soumission.

- [ ] Audit complet du modDesc.
- [ ] Vérification copyrights et licences des composants tiers.
- [ ] Nettoyage des fichiers de développement et tests non nécessaires au package final.
- [ ] Suppression des logs/debugs de développement inutiles.
- [ ] Validation XML/Lua/assets/l10n.
- [ ] Tests nouvelle partie / sauvegarde existante / migration / reprise après crash.
- [ ] Tests sans mods tiers.
- [ ] Tests avec les principaux mods de compatibilité.
- [ ] Tests 1080p / 1440p / 4K.
- [ ] Documentation utilisateur finale.
- [ ] Changelog de release.
- [ ] Packaging final sans suffixe TEST.
- [ ] Version publique uniquement lorsque le projet est suffisamment stable.

---

**Auteur : Chez_Squall**  
**Projet : FS25_AgriLifeManager**  
**Statut actuel : développement privé / builds TEST**
