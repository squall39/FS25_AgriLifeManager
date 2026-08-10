# Feuille de route — AgriLife Manager

Cette feuille de route décrit l’ordre de développement retenu pour AgriLife Manager. Elle évolue avec les tests, mais les principes validés ci-dessous servent désormais de référence au projet.

## Principes directeurs validés

- **Chaque nouvelle fonctionnalité doit avoir une conséquence réelle en jeu.** Un système ne doit pas exister uniquement pour remplir un menu.
- Les décisions doivent pouvoir produire des effets différés : progression, réputation, accès au crédit, contrats, assurance, fiscalité, sanctions ou développement de l’exploitation.
- La sauvegarde AgriLife doit rester propre à chaque carrière FS25 et conserver l’histoire de l’exploitation.
- Les intégrations avec Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres mods restent optionnelles : le cœur d’AgriLife doit fonctionner seul.
- La numérotation reste volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.

## Priorités immédiates

### 0 — Stabilisation des builds TEST actuelles

Avant d’ouvrir de gros nouveaux chantiers, terminer la validation de la base actuelle :

1. Revalider la chaîne complète des examens, en particulier l’étape 5 « cultivation » corrigée en 0.6.4.24.
2. Vérifier les étapes 6/10 à 10/10 : retour, dételage, parking et sortie.
3. Vérifier le HUD permanent, les transitions d’étapes et les erreurs explicites.
4. Revalider la persistance AgriLife dans la sauvegarde FS25 et l’absence de progression partagée entre deux nouvelles carrières.
5. Valider la séparation joueur humain / GPS natif / salariés AgriLife introduite pour la 0.6.4.25.
6. Revalider complètement le parcours d’onboarding selon la difficulté choisie.

### Ordre des trois prochains grands systèmes

Une fois cette stabilisation terminée, l’ordre validé est :

1. **Réputation de l’exploitation**
2. **Comptabilité & fiscalité**
3. **Contrôles administratifs & sanctions**

Ces trois systèmes doivent connecter les modules déjà présents au lieu de fonctionner comme des écrans isolés.

## Difficultés — règle fonctionnelle cible

La conception cible distingue les niveaux **Libre, Facile, Réaliste et Strict**.

Règles validées pour les obligations de démarrage :

| Obligation | Libre | Facile | Réaliste | Strict |
|---|---:|---:|---:|---:|
| Banque + conseiller obligatoires | Non | Non | Oui | Oui |
| Création de la société obligatoire | Non | Non | Oui | Oui |
| Permis agricole obligatoire | Non | Non | Oui | Oui |

Les niveaux les plus accessibles peuvent laisser ces systèmes disponibles sans les imposer. Réaliste et Strict doivent réellement contraindre la progression, avec des conséquences plus fortes en Strict.

---

## Phase 1 — Banque & finance

### Banque / conseiller
- [x] Base Banque et Conseiller.
- [x] Demande de crédit avec délai d’étude.
- [x] Délai basé sur l’horloge de jeu FS25, pas sur le temps réel.
- [x] Décision réelle : acceptation, refus ou validation conditionnelle selon le dossier.
- [x] Persistance du dossier bancaire en sauvegarde.
- [x] Une seule demande active à la fois.
- [x] Objet du financement sélectionnable.
- [x] Profils bancaires et conseillers différenciés.
- [x] Réputation et compétence affichées séparément en étoiles pour banques et conseillers.
- [x] Qualité intrinsèque du professionnel séparée de la relation/confiance personnelle du joueur.
- [ ] Aligner définitivement les obligations Banque/Conseiller sur Libre / Facile / Réaliste / Strict.
- [ ] Ajouter/affiner solidité bancaire, politique de risque, sévérité et rapidité d’étude.
- [ ] Bloquer le changement de banque/conseiller pendant une demande en cours.
- [ ] Ajouter des raisons détaillées de décision et journaliser les facteurs déterminants.
- [ ] Faire varier davantage taux, plafond, durée, garanties et délai selon banque, conseiller, objet et qualité du dossier.

### Comptes & finances de base
- [x] Base du compte professionnel.
- [x] Base du compte personnel.
- [x] Début de relevé/mouvements sur le compte professionnel.
- [ ] Historique complet des transactions avec catégories/tags.
- [ ] Filtres par période, catégorie, fournisseur, contrat et type de flux.
- [ ] Détail des prêts : capital, restant dû, taux, mensualité, échéance, durée, coût total, remboursement anticipé.
- [ ] Affichage séparé de la dette FS25 héritée sur les sauvegardes existantes.
- [ ] Prévision de trésorerie et capacité d’emprunt.
- [ ] Refinancement / renégociation via conseiller.

### Menu Finances vanilla FS25
- [x] Blocage fonctionnel des nouvelles opérations de crédit vanilla.
- [ ] Intercepter les actions avant comptabilisation FS25.
- [ ] Supprimer/désactiver visuellement les commandes Emprunter / Rembourser dans le menu Finances vanilla.
- [ ] Préserver le reste des informations financières utiles du jeu.
- [ ] À terme, faire d’AgriLife → Banque → Finances la page financière principale.

## Phase 2 — Interface & expérience utilisateur

- [x] Nouvelle identité visuelle sombre et structurée.
- [x] Navigation AgriLife intégrée au menu Échap.
- [x] Tutoriel différé jusqu’à l’arrivée réelle en gameplay.
- [x] Assistance native intégrée.
- [x] Support 1920×1080 validé comme base.
- [x] Pictogrammes conservés comme élément volontaire de l’identité AgriLife.
- [x] Tableau de bord avec action obligatoire contextuelle.
- [ ] Finaliser l’adaptation 1440p / 4K.
- [ ] Continuer à harmoniser taille, netteté et placement des pictogrammes **sans les supprimer**.
- [ ] Conserver une présentation proche d’une application moderne sans surcharge.
- [ ] Harmoniser tailles de texte, boutons et onglets.
- [ ] Supprimer tout artefact visuel résiduel.
- [ ] Synchroniser chaque évolution majeure avec le tutoriel et Échap → Assistance.
- [ ] Ajouter un **Journal de bord AgriLife** retraçant les grands événements de la carrière.

## Phase 3 — Personnel, contrats, ordres de travail & paie

Le module Personnel doit devenir un véritable système de main-d’œuvre. **AgriLife devient la source unique de paie des salariés** afin d’éviter de payer deux fois un même ouvrier lorsqu’une tâche est exécutée par FS25, Courseplay ou AutoDrive.

### Salariés & contrats
- [x] Structure Personnel / Équipe & paie.
- [x] Base des employés AgriLife.
- [x] Compétences visuelles en étoiles.
- [ ] Ajouter trois types de contrats : **CDI, CDD et saisonnier**.
- [ ] CDI : emploi permanent, salaire régulier, ancienneté, évolution salariale et coût de rupture.
- [ ] CDD : date de début et de fin, salaire défini, renouvellement possible, fin automatique ou transformation en CDI.
- [ ] Saisonnier : recrutement temporaire pour semis, récolte, ensilage, vendanges ou autre campagne.
- [ ] Fiche salarié complète : contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, expérience et historique.
- [ ] Disponibilité, horaires, pauses, heures supplémentaires, congés, maladie et absences.
- [ ] Promotion, augmentation, renouvellement, fin de contrat et licenciement.

### Une personne = une tâche réelle
- [ ] **1 salarié disponible = 1 tâche automatisée active maximum.**
- [ ] Empêcher qu’un même salarié soit affecté simultanément à plusieurs véhicules/tâches.
- [ ] Libérer automatiquement le salarié à la fin, l’arrêt ou l’annulation de sa tâche.
- [ ] Afficher clairement : disponible / affecté / en pause / absent / congé / malade.

### Centre d’ordres AgriLife
- [ ] Permettre de donner directement un ordre à un salarié depuis AgriLife lorsque Courseplay/AutoDrive ne sont pas utilisés.
- [ ] Sélection visuelle : **salarié → véhicule → outil → travail → champ/destination**.
- [ ] Proposer les travaux compatibles avec le véhicule et l’outil réellement attaché.
- [ ] S’appuyer sur l’IA native FS25 lorsque le travail demandé est supporté par le jeu.
- [ ] Commandes : démarrer, mettre en pause, reprendre, arrêter/rappeler.
- [ ] Afficher l’état de la mission, la progression, le champ/destination, le véhicule et l’outil utilisés.
- [ ] Ne jamais simuler un travail impossible.

### Paie unique & intégrations FS25 / Courseplay / AutoDrive
- [ ] Faire d’AgriLife **l’unique moteur de salaire** des employés enregistrés dans Personnel.
- [ ] Neutraliser le coût horaire de l’ouvrier vanilla lorsqu’une tâche est liée à un salarié AgriLife.
- [ ] Intégration optionnelle Courseplay par détection/hooks, sans modifier Courseplay.
- [ ] Intégration optionnelle AutoDrive par détection/hooks, sans modifier AutoDrive.
- [ ] Prévoir un retour propre au fonctionnement autonome si un mod tiers devient temporairement incompatible.

### Expérience, compétences & évolution
- [ ] Chaque salarié gagne de l’expérience uniquement grâce au **travail réellement effectué**.
- [ ] Compétence générale + spécialités : sol, semis, fertilisation, récolte, transport, élevage, mécanique, etc.
- [ ] Progression selon temps de travail, type de tâche, réussite et incidents.
- [ ] Le niveau de compétence influence salaire et évolution sans bonus irréalistes.
- [ ] Conserver l’historique de carrière du salarié dans la sauvegarde.

### Interface Personnel
- [ ] Cartes salariés avec pictogramme/portrait, nom, contrat, étoiles, spécialités et état en temps réel.
- [ ] Badge visuel CDI / CDD / SAISONNIER.
- [ ] Pendant une affectation : véhicule, outil, tâche, champ/destination, progression et durée de travail visibles.
- [ ] Tableau de paie : salaire de base, heures, heures supplémentaires, primes/coûts et total employeur.

## Phase 4 — Carrière, XP, examens & permis

- [x] Structure carrière / XP.
- [x] Structure examens.
- [x] HUD d’examen avec étape, action, progression, note et erreurs.
- [x] Panneau de réussite vert + affichage immédiat de la consigne suivante — **implémenté en 0.6.4.24, à revalider en jeu**.
- [x] Affichage persistant de la nature de la dernière erreur d’examen.
- [x] Correction logique du retour du matériel dans sa zone d’origine — **à revalider en jeu après l’étape 5**.
- [x] Progression de secours pour certains travaux réels : outil compatible actif/abaissé + déplacement réel — **implémenté en 0.6.4.24**.
- [ ] Revalider toute la chaîne réelle des 10 étapes sur une partie complète.
- [ ] Valider définitivement l’épreuve 5 « cultivation » avec le test utilisateur au retour.
- [ ] Vérifier ensuite les étapes 6/10 à 10/10, notamment retour/dételage/parking/sortie.
- [ ] Vérifier chaque outil et chaque type de travail comptabilisé.
- [ ] Aligner le caractère obligatoire du permis sur **Réaliste et Strict uniquement**.
- [ ] Ajouter des qualifications spécialisées : pulvérisation/phytosanitaire, télescopique, forestier, transport agricole ou autres catégories pertinentes.
- [ ] Faire évoluer le statut professionnel sans choix artificiel de profil au démarrage.
- [ ] Ajouter une fiche de carrière durable : heures, hectares, travaux, examens, contrats, incidents et grandes étapes.

## Phase 5 — Réputation de l’exploitation

**Premier grand système à développer après stabilisation.**

- [ ] Créer une réputation globale de l’exploitation et du dirigeant.
- [ ] Faire évoluer la réputation à partir d’actions réelles : contrats terminés, retards, dettes, incidents, examens, qualité du travail et gestion.
- [ ] Conserver l’historique des événements ayant modifié la réputation.
- [ ] Utiliser la réputation dans Banque, Conseiller, Contrats, Coopératives, Assurance et futurs contentieux.
- [ ] Débloquer progressivement de meilleures opportunités lorsque la réputation est solide.
- [ ] Rendre une mauvaise réputation réellement pénalisante sans créer de blocage définitif impossible à corriger.
- [ ] Ajouter des mécanismes réalistes de récupération de réputation sur plusieurs périodes.
- [ ] Afficher les principaux facteurs expliquant la note de réputation.

## Phase 6 — Comptabilité & fiscalité

**Deuxième grand système à développer après stabilisation.**

- [ ] Construire un véritable exercice comptable AgriLife.
- [ ] Chiffre d’affaires, produits, charges, salaires, assurances, intérêts, entretien et autres dépenses catégorisés.
- [ ] Bénéfice/perte de l’exercice.
- [ ] Amortissement du matériel et des investissements lorsque pertinent.
- [ ] Bilan simplifié mais cohérent : trésorerie, dettes, actifs et résultat.
- [ ] Fiscalité adaptée au niveau de difficulté.
- [ ] Échéances fiscales et paiement depuis le compte professionnel.
- [ ] Clôture d’exercice avec récapitulatif annuel.
- [ ] Historique pluriannuel des résultats.
- [ ] Utiliser résultats, endettement et capacité d’autofinancement dans les décisions bancaires.
- [ ] Séparation pro/perso de plus en plus contraignante en Réaliste et Strict.
- [ ] Conséquences réelles en cas d’impayé fiscal ou de trésorerie insuffisante.

## Phase 7 — Société, statuts, administration, contrôles & sanctions

**Troisième grand système à développer après stabilisation.**

### Société & administration
- [x] Base du module Société.
- [ ] Aligner définitivement l’obligation de création de société sur **Réaliste et Strict uniquement**.
- [ ] Gestion plus profonde de la structure juridique.
- [ ] Charges et obligations administratives selon difficulté.
- [ ] Utiliser la santé de l’entreprise dans Banque, Contrats, Assurance et Contentieux.

### Licence / statut d’exploitation évolutif
- [ ] Créer un statut professionnel progressif : **petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**.
- [ ] Définir des conditions d’évolution : expérience, réputation, capital, examens, conformité et activité réelle.
- [ ] Donner à chaque statut des droits, opportunités et obligations supplémentaires.
- [ ] Éviter les déblocages artificiels : l’évolution doit être méritée par la carrière.

### Contrôles administratifs & sanctions
- [ ] Contrôles de conformité de l’exploitation.
- [ ] Vérifier permis, assurances, documents et obligations réellement applicables au niveau choisi.
- [ ] Prévoir avertissement, régularisation, amende ou immobilisation selon la gravité et la difficulté.
- [ ] Historiser les contrôles et récidives.
- [ ] Faire influencer les sanctions par le comportement antérieur et la réputation.
- [ ] Éviter les événements arbitraires : chaque sanction doit avoir une cause identifiable par le joueur.

### Événements de gestion
- [ ] Ajouter des événements peu fréquents mais significatifs : échéance, facture imprévue, contrôle, réparation lourde, absence salarié ou autre incident crédible.
- [ ] Adapter fréquence et sévérité à la difficulté.
- [ ] Donner plusieurs solutions réalistes lorsque c’est possible.

## Phase 8 — Assurances

- [x] Base de l’écran Assurance.
- [ ] Contrats différenciés par formule, capital et risque.
- [ ] Sinistres et franchises.
- [ ] Impact du comportement, de la réputation, de l’historique et de la difficulté sur les primes.
- [ ] Interaction avec atelier, véhicules, bâtiments et exploitation.
- [ ] Contrôler l’obligation d’assurance selon le niveau choisi.

## Phase 9 — Atelier & cycle de vie du matériel

- [x] Base de l’Atelier.
- [x] État du matériel et opérations de maintenance.
- [ ] Usure, entretien et immobilisation plus poussés.
- [ ] Marché de l’occasion cohérent avec l’état réel du matériel.
- [ ] Coûts de maintenance et réparations liés à l’historique.
- [ ] Interaction avec assurances et trésorerie.
- [ ] Historique économique complet du matériel : achat, usage, entretien, sinistres, réparation et valeur résiduelle.

## Phase 10 — Contrats & coopératives

- [x] Base des contrats commerciaux.
- [ ] Passer d’une logique de mission à de vrais engagements commerciaux.
- [ ] Prix, volumes, délais, pénalités et qualité négociés.
- [ ] Contrats possibles avant semis/plantation.
- [ ] Acheteurs et coopératives multiples.
- [ ] Impact du conseiller, de la réputation et de l’historique.
- [ ] Surfaces conseillées / volumes prévisionnels.
- [ ] Ajouter une **notation de contrat** selon respect des délais, qualité du travail, incidents et conditions remplies.
- [ ] Faire influencer cette notation sur les futures offres et la réputation.

## Phase 11 — Huissier & contentieux

Module volontairement approfondi et fortement lié à Banque, Fiscalité et Administration.

- [ ] Retards et incidents de paiement.
- [ ] Relances et mises en demeure.
- [ ] Transmission au module Huissier.
- [ ] Frais, échéanciers et procédures.
- [ ] Conséquences sur réputation, banque, contrats et société.
- [ ] Mécanismes de sortie réalistes : régularisation, négociation, restructuration.
- [ ] Prendre en compte les dettes fiscales et administratives lorsque les systèmes correspondants seront actifs.

## Phase 12 — Compatibilités PC optionnelles

AgriLife Manager doit rester autonome : aucune de ces compatibilités ne doit devenir une dépendance dure.

- [ ] Courseplay.
- [ ] AutoDrive.
- [ ] Soil Fertilizer.
- [ ] Precision Farming / systèmes compatibles pertinents.
- [ ] Autres mods de gestion ou réalisme identifiés pendant les tests.
- [ ] Vérifier qu’AgriLife continue à fonctionner correctement lorsque ces mods sont absents.

## Phase 13 — Sauvegardes, migration & multijoueur

- [x] État AgriLife enregistré dans la sauvegarde carrière FS25.
- [x] Migration des sauvegardes existantes sans écraser leur patrimoine.
- [x] Conservation de la dette FS25 existante comme dette héritée.
- [x] Nouvelle carrière : capital AgriLife et gestion dédiée du démarrage.
- [ ] Garantir qu’une nouvelle partie ne récupère jamais la progression AgriLife d’une autre sauvegarde.
- [ ] Renforcer les migrations entre versions du mod.
- [ ] Tests de corruption/récupération backup.
- [ ] Multi-fermes.
- [ ] Multijoueur complet.
- [ ] Autorité serveur et synchronisation réseau de tous les modules.

## Phase 14 — Localisation

- [x] Français comme langue principale de développement/test.
- [ ] Relecture complète FR.
- [ ] Relecture complète EN.
- [ ] Finaliser IT sans reliquats anglais.
- [ ] Chinois simplifié.
- [ ] Chinois traditionnel.
- [ ] Vérifier toutes les clés manquantes et doublons l10n.

## Phase 15 — Préparation publication

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
