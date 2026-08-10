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

## Phase 3 — Personnel & paie

- [x] Structure Personnel / Équipe & paie.
- [x] Base des employés AgriLife.
- [x] Compétences visuelles en étoiles.
- [ ] 1 salarié disponible = 1 tâche automatisée active.
- [ ] Intégration optionnelle des helpers FS25.
- [ ] Intégration optionnelle Courseplay.
- [ ] Intégration optionnelle AutoDrive.
- [ ] Disponibilité, affectation, horaires, salaires et heures supplémentaires.
- [ ] Congés, maladie, absences, promotion et licenciement.
- [ ] Compétence générale + spécialités : sol, semis, récolte, transport, élevage, mécanique, etc.
- [ ] Coût salarial lié au niveau de compétence.
- [ ] Préparer la logique multijoueur : joueurs humains = collaborateurs actifs, sans bonus artificiels.

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
