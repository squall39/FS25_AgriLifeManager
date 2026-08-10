# Feuille de route — AgriLife Manager

Cette feuille de route décrit l’ordre de développement retenu pour AgriLife Manager. Elle évolue avec les tests, mais les principes validés ci-dessous servent de référence au projet.

## Principes directeurs validés

- **Chaque nouvelle fonctionnalité doit avoir une conséquence réelle en jeu.** Un système ne doit pas exister uniquement pour remplir un menu.
- Les décisions doivent pouvoir produire des effets différés : progression, réputation, accès au crédit, contrats, assurance, fiscalité, sanctions ou développement de l’exploitation.
- La sauvegarde AgriLife doit rester propre à chaque carrière FS25 et conserver l’histoire de l’exploitation.
- Les intégrations avec Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres mods restent optionnelles : le cœur d’AgriLife doit fonctionner seul.
- La numérotation reste volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.
- **Aucun texte destiné au joueur ne doit rester codé en dur.** Toute chaîne visible doit passer par une clé l10n.
- **Toutes les langues distribuées avec le mod doivent posséder exactement les mêmes clés.** Une build publiable ne doit contenir aucune clé manquante.

## Priorités immédiates

### 0 — Stabilisation des builds TEST actuelles

Avant d’ouvrir de gros nouveaux chantiers :

1. Revalider la chaîne complète des examens, en particulier l’étape 5 « cultivation » corrigée en 0.6.4.24.
2. Vérifier les étapes 6/10 à 10/10 : retour, dételage, parking et sortie.
3. Vérifier le HUD permanent, les transitions d’étapes et les erreurs explicites.
4. Revalider la persistance AgriLife dans la sauvegarde FS25 et l’absence de progression partagée entre deux nouvelles carrières.
5. Valider la séparation joueur humain / GPS natif / salariés AgriLife introduite pour la 0.6.4.25.
6. Revalider complètement l’onboarding dans chacun des trois niveaux de difficulté.

### Ordre des trois prochains grands systèmes

Une fois cette stabilisation terminée :

1. **Réputation de l’exploitation**
2. **Comptabilité & fiscalité**
3. **Contrôles administratifs & sanctions**

Ces trois systèmes doivent connecter les modules déjà présents au lieu de fonctionner comme des écrans isolés.

---

# Difficulté — trois niveaux uniquement

AgriLife Manager conserve **uniquement trois difficultés : Facile, Normal et Difficile**.

| Niveau | Capital de départ | Philosophie |
|---|---:|---|
| **Facile** | 200 000 € | Gestion accessible, tolérances plus larges, coûts et sanctions réduits. |
| **Normal** | 100 000 € | Expérience complète équilibrée, contraintes réalistes et progression structurée. |
| **Difficile** | 50 000 € | Expérience complète avec obligations, coûts, risques, contrôles et conséquences renforcés. |

Le niveau choisi est permanent pour la sauvegarde.

## Règle centrale : la difficulté agit sur tout AgriLifeManager

La difficulté ne doit jamais être un simple choix de capital de départ. **Chaque module AgriLife doit consulter le même profil de difficulté central.**

Selon le niveau choisi, AgriLife peut faire varier notamment :

- capital et aides de départ ;
- obligations Banque / Conseiller / Société / Permis ;
- critères et délais d’acceptation des crédits ;
- taux, frais, plafonds et garanties ;
- difficulté, tolérance et coût des examens ;
- vitesse d’XP et progression de carrière ;
- salaires, charges employeur, heures supplémentaires et coûts de rupture ;
- coût des assurances, franchises et conditions de couverture ;
- usure, entretien, réparation et immobilisation du matériel ;
- fiscalité, échéances, charges et pénalités ;
- fréquence et sévérité des contrôles administratifs ;
- avertissements, délais de régularisation, amendes et récidives ;
- réputation gagnée ou perdue ;
- exigences des contrats commerciaux et pénalités ;
- tolérance aux retards et incidents de paiement ;
- événements de gestion et conséquences économiques ;
- aide contextuelle, tutoriel et niveau d’accompagnement.

### Facile

- Plus de tolérance et d’accompagnement.
- Coûts, sanctions, intérêts, franchises et pénalités réduits.
- Critères d’examen et de financement plus permissifs.
- Événements négatifs moins sévères.
- Les systèmes AgriLife restent actifs : le joueur joue bien à AgriLifeManager, mais avec davantage de marge d’erreur.

### Normal

- Réglage de référence du mod.
- Tous les grands systèmes sont réellement actifs et équilibrés.
- Coûts, délais, contrôles, progression, réputation et sanctions correspondent au niveau de réalisme standard voulu pour AgriLife.

### Difficile

- Contraintes maximales prévues par le mod.
- Dossiers bancaires plus exigeants, coûts et garanties plus sévères.
- Examens moins tolérants et erreurs plus pénalisantes.
- Fiscalité, assurances, charges, contrôles et sanctions renforcés.
- Réputation plus importante dans l’accès aux opportunités.
- Mauvaise gestion financière ou administrative avec conséquences durables.

---

## Phase 1 — Banque & finance

### Banque / conseiller
- [x] Base Banque et Conseiller.
- [x] Demande de crédit avec délai d’étude basé sur l’horloge de jeu FS25.
- [x] Décision réelle : acceptation, refus ou validation conditionnelle selon le dossier.
- [x] Persistance du dossier bancaire en sauvegarde.
- [x] Une seule demande active à la fois.
- [x] Objet du financement sélectionnable.
- [x] Profils bancaires et conseillers différenciés.
- [x] Réputation et compétence affichées séparément en étoiles.
- [x] Qualité intrinsèque du professionnel séparée de la relation/confiance personnelle du joueur.
- [ ] Faire dépendre toutes les règles bancaires du profil Facile / Normal / Difficile.
- [ ] Ajouter/affiner solidité bancaire, politique de risque, sévérité et rapidité d’étude.
- [ ] Bloquer le changement de banque/conseiller pendant une demande en cours.
- [ ] Ajouter des raisons détaillées de décision et journaliser les facteurs déterminants.
- [ ] Faire varier taux, plafond, durée, garanties et délai selon banque, conseiller, objet, dossier et difficulté.

### Comptes & finances de base
- [x] Base du compte professionnel.
- [x] Base du compte personnel.
- [x] Début de relevé/mouvements sur le compte professionnel.
- [ ] Historique complet des transactions avec catégories/tags.
- [ ] Filtres par période, catégorie, fournisseur, contrat et type de flux.
- [ ] Détail des prêts : capital, restant dû, taux, mensualité, échéance, durée, coût total et remboursement anticipé.
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
- [ ] Adapter tutoriel, conseils et avertissements à Facile / Normal / Difficile.
- [ ] Finaliser l’adaptation 1440p / 4K.
- [ ] Harmoniser taille, netteté et placement des pictogrammes sans les supprimer.
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
- [ ] Fiche salarié complète : contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, expérience et historique.
- [ ] Disponibilité, horaires, pauses, heures supplémentaires, congés, maladie et absences.
- [ ] Promotion, augmentation, renouvellement, fin de contrat et licenciement.
- [ ] Faire varier coûts employeur, contraintes et tolérances selon la difficulté.

### Une personne = une tâche réelle
- [ ] **1 salarié disponible = 1 tâche automatisée active maximum.**
- [ ] Empêcher qu’un même salarié soit affecté simultanément à plusieurs véhicules/tâches.
- [ ] Libérer automatiquement le salarié à la fin, l’arrêt ou l’annulation de sa tâche.
- [ ] Afficher clairement : disponible / affecté / en pause / absent / congé / malade.

### Centre d’ordres AgriLife
- [ ] Sélection visuelle : **salarié → véhicule → outil → travail → champ/destination**.
- [ ] Proposer les travaux compatibles avec le véhicule et l’outil réellement attaché.
- [ ] S’appuyer sur l’IA native FS25 lorsque le travail demandé est supporté par le jeu.
- [ ] Commandes : démarrer, mettre en pause, reprendre, arrêter/rappeler.
- [ ] Afficher état, progression, champ/destination, véhicule et outil utilisés.
- [ ] Ne jamais simuler un travail impossible.

### Paie unique & intégrations
- [ ] Faire d’AgriLife l’unique moteur de salaire des employés enregistrés dans Personnel.
- [ ] Neutraliser le coût horaire de l’ouvrier vanilla lorsqu’une tâche est liée à un salarié AgriLife.
- [ ] Intégration optionnelle Courseplay par détection/hooks, sans modifier Courseplay.
- [ ] Intégration optionnelle AutoDrive par détection/hooks, sans modifier AutoDrive.
- [ ] Prévoir un retour propre au fonctionnement autonome si un mod tiers devient temporairement incompatible.

### Expérience & évolution
- [ ] Chaque salarié gagne de l’expérience uniquement grâce au travail réellement effectué.
- [ ] Compétence générale + spécialités : sol, semis, fertilisation, récolte, transport, élevage, mécanique, etc.
- [ ] Progression selon temps de travail, type de tâche, réussite, incidents et difficulté.
- [ ] Le niveau de compétence influence salaire et évolution sans bonus irréalistes.
- [ ] Conserver l’historique de carrière du salarié dans la sauvegarde.

## Phase 4 — Carrière, XP, examens & permis

- [x] Structure carrière / XP.
- [x] Structure examens.
- [x] HUD d’examen avec étape, action, progression, note et erreurs.
- [x] Panneau de réussite vert + consigne suivante — implémenté en 0.6.4.24, à revalider en jeu.
- [x] Affichage persistant de la dernière erreur d’examen.
- [x] Correction logique du retour du matériel dans sa zone d’origine — à revalider en jeu après l’étape 5.
- [x] Progression de secours pour certains travaux réels : outil compatible actif/abaissé + déplacement réel — implémenté en 0.6.4.24.
- [ ] Revalider toute la chaîne réelle des 10 étapes sur une partie complète.
- [ ] Valider définitivement l’épreuve 5 « cultivation ».
- [ ] Vérifier les étapes 6/10 à 10/10 : retour, dételage, parking et sortie.
- [ ] Vérifier chaque outil et chaque type de travail comptabilisé.
- [ ] Faire varier frais d’inscription, tolérance, notation et exigences selon Facile / Normal / Difficile.
- [ ] Ajouter des qualifications spécialisées : pulvérisation/phytosanitaire, télescopique, forestier, transport agricole ou autres catégories pertinentes.
- [ ] Ajouter une fiche de carrière durable : heures, hectares, travaux, examens, contrats, incidents et grandes étapes.

## Phase 5 — Réputation de l’exploitation

**Premier grand système à développer après stabilisation.**

- [ ] Créer une réputation globale de l’exploitation et du dirigeant.
- [ ] Faire évoluer la réputation à partir d’actions réelles : contrats, retards, dettes, incidents, examens, qualité du travail et gestion.
- [ ] Conserver l’historique des événements ayant modifié la réputation.
- [ ] Utiliser la réputation dans Banque, Conseiller, Contrats, Coopératives, Assurance et futurs contentieux.
- [ ] Débloquer progressivement de meilleures opportunités lorsque la réputation est solide.
- [ ] Permettre de reconstruire progressivement une réputation dégradée.
- [ ] Faire varier gains, pertes et seuils de réputation selon la difficulté.
- [ ] Afficher les principaux facteurs expliquant la note de réputation.

## Phase 6 — Comptabilité & fiscalité

**Deuxième grand système à développer après stabilisation.**

- [ ] Construire un véritable exercice comptable AgriLife.
- [ ] Chiffre d’affaires, produits, charges, salaires, assurances, intérêts, entretien et autres dépenses catégorisés.
- [ ] Bénéfice/perte de l’exercice.
- [ ] Amortissement du matériel et des investissements lorsque pertinent.
- [ ] Bilan simplifié : trésorerie, dettes, actifs et résultat.
- [ ] Fiscalité adaptée à Facile / Normal / Difficile.
- [ ] Échéances fiscales et paiement depuis le compte professionnel.
- [ ] Clôture d’exercice avec récapitulatif annuel.
- [ ] Historique pluriannuel des résultats.
- [ ] Utiliser résultats, endettement et capacité d’autofinancement dans les décisions bancaires.
- [ ] Séparation pro/perso plus contraignante à mesure que la difficulté augmente.
- [ ] Conséquences réelles en cas d’impayé fiscal ou de trésorerie insuffisante.

## Phase 7 — Société, statuts, administration, contrôles & sanctions

**Troisième grand système à développer après stabilisation.**

### Société & administration
- [x] Base du module Société.
- [ ] Faire dépendre obligations, coûts, formalités et délais de Facile / Normal / Difficile.
- [ ] Gestion plus profonde de la structure juridique.
- [ ] Utiliser la santé de l’entreprise dans Banque, Contrats, Assurance et Contentieux.

### Statut d’exploitation évolutif
- [ ] Créer un statut professionnel progressif : **petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**.
- [ ] Conditions d’évolution : expérience, réputation, capital, examens, conformité et activité réelle.
- [ ] Donner à chaque statut des droits, opportunités et obligations supplémentaires.

### Contrôles administratifs & sanctions
- [ ] Contrôles de conformité de l’exploitation.
- [ ] Vérifier permis, assurances, documents et obligations réellement applicables au niveau choisi.
- [ ] Prévoir avertissement, régularisation, amende ou immobilisation selon gravité et difficulté.
- [ ] Historiser contrôles et récidives.
- [ ] Faire varier fréquence, seuils et sévérité des contrôles selon la difficulté.
- [ ] Faire influencer les sanctions par le comportement antérieur et la réputation.
- [ ] Chaque sanction doit avoir une cause identifiable par le joueur.

### Événements de gestion
- [ ] Échéance, facture imprévue, contrôle, réparation lourde, absence salarié ou autre incident crédible.
- [ ] Adapter fréquence et sévérité à la difficulté.
- [ ] Donner plusieurs solutions réalistes lorsque c’est possible.

## Phase 8 — Assurances

- [x] Base de l’écran Assurance.
- [ ] Contrats différenciés par formule, capital et risque.
- [ ] Sinistres et franchises.
- [ ] Impact du comportement, de la réputation, de l’historique et de la difficulté sur les primes.
- [ ] Interaction avec atelier, véhicules, bâtiments et exploitation.
- [ ] Faire varier primes, franchises, exclusions et tolérances selon Facile / Normal / Difficile.

## Phase 9 — Atelier & cycle de vie du matériel

- [x] Base de l’Atelier.
- [x] État du matériel et opérations de maintenance.
- [ ] Usure, entretien et immobilisation plus poussés.
- [ ] Marché de l’occasion cohérent avec l’état réel du matériel.
- [ ] Coûts de maintenance et réparations liés à l’historique.
- [ ] Interaction avec assurances et trésorerie.
- [ ] Historique économique complet du matériel : achat, usage, entretien, sinistres, réparation et valeur résiduelle.
- [ ] Faire varier coûts, tolérances et conséquences d’entretien selon la difficulté.

## Phase 10 — Contrats & coopératives

- [x] Base des contrats commerciaux.
- [ ] Passer d’une logique de mission à de vrais engagements commerciaux.
- [ ] Prix, volumes, délais, pénalités et qualité négociés.
- [ ] Contrats possibles avant semis/plantation.
- [ ] Acheteurs et coopératives multiples.
- [ ] Impact du conseiller, de la réputation et de l’historique.
- [ ] Surfaces conseillées / volumes prévisionnels.
- [ ] Notation de contrat selon respect des délais, qualité du travail, incidents et conditions remplies.
- [ ] Faire influencer cette notation sur les futures offres et la réputation.
- [ ] Faire varier exigences, marges de tolérance et pénalités selon la difficulté.

## Phase 11 — Huissier & contentieux

Module volontairement approfondi et fortement lié à Banque, Fiscalité et Administration.

- [ ] Retards et incidents de paiement.
- [ ] Relances et mises en demeure.
- [ ] Transmission au module Huissier.
- [ ] Frais, échéanciers et procédures.
- [ ] Conséquences sur réputation, banque, contrats et société.
- [ ] Mécanismes de sortie réalistes : régularisation, négociation, restructuration.
- [ ] Prendre en compte les dettes fiscales et administratives.
- [ ] Faire varier délais, frais, tolérances et escalade selon la difficulté.

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
- [ ] Sauvegarder le niveau de difficulté dans la carrière et interdire qu’il change accidentellement après rechargement.
- [ ] Renforcer les migrations entre versions du mod.
- [ ] Tests de corruption/récupération backup.
- [ ] Multi-fermes.
- [ ] Multijoueur complet.
- [ ] Autorité serveur et synchronisation réseau de tous les modules.

## Phase 14 — Traductions, localisation & clés l10n

**Objectif : AgriLifeManager doit être utilisable proprement par tous les joueurs auxquels une langue est proposée.**

### Référentiel de clés
- [ ] Utiliser une langue de référence complète pour recenser toutes les clés du mod.
- [ ] Inventorier automatiquement toutes les clés l10n utilisées dans Lua, XML, GUI, tutoriel, assistance, notifications, examens, menus et modules.
- [ ] Comparer chaque fichier de langue au référentiel et détecter clés absentes, doublons, clés inutilisées et fautes de nommage.
- [ ] Interdire les textes joueur codés directement dans Lua/XML lorsque le système l10n peut être utilisé.
- [ ] Ajouter une vérification de cohérence des clés avant chaque build TEST importante.

### Traductions complètes
- [ ] Français complet et relu.
- [ ] Anglais complet et relu.
- [ ] Compléter toutes les autres langues distribuées avec le mod.
- [ ] Étendre progressivement la localisation aux langues pertinentes de FS25/ModHub afin que le mod puisse être utilisé par le plus grand nombre.
- [ ] Lorsqu’une nouvelle clé est ajoutée à une fonctionnalité, l’ajouter immédiatement à **tous** les fichiers de langue, même si certaines traductions restent temporairement marquées à relire pendant le développement.
- [ ] Aucune version publique ne doit afficher une clé brute du type `agrilife_xxx`, un texte vide ou un fallback anglais involontaire.

### Qualité de traduction
- [ ] Employer une terminologie agricole, bancaire, comptable, juridique et administrative cohérente dans chaque langue.
- [ ] Vérifier accents, caractères spéciaux, encodage UTF-8 et longueur des textes dans l’interface.
- [ ] Tester les textes longs en 1080p / 1440p / 4K pour éviter débordements et boutons coupés.
- [ ] Vérifier pluriels, montants, unités, dates et formulations contextuelles.
- [ ] Maintenir un glossaire AgriLife afin que les mêmes termes soient traduits de façon cohérente dans tout le mod.

### Critère de validation avant publication
- [ ] **0 clé manquante dans toutes les langues distribuées.**
- [ ] **0 texte joueur codé en dur non justifié.**
- [ ] **0 clé l10n brute visible en jeu.**
- [ ] **0 traduction volontairement laissée vide.**
- [ ] Audit complet des traductions après chaque ajout massif de fonctionnalités.

## Phase 15 — Préparation publication

Objectif final : version PC propre et publiable, notamment pour soumission officielle GIANTS/ModHub si elle respecte les exigences applicables au moment de la soumission.

- [ ] Audit complet du modDesc.
- [ ] Vérification copyrights et licences des composants tiers.
- [ ] Nettoyage des fichiers de développement et tests non nécessaires au package final.
- [ ] Suppression des logs/debugs de développement inutiles.
- [ ] Validation XML/Lua/assets/l10n.
- [ ] Tests nouvelle partie / sauvegarde existante / migration / reprise après crash.
- [ ] Tests des trois difficultés **Facile / Normal / Difficile** sur les modules majeurs.
- [ ] Tests sans mods tiers.
- [ ] Tests avec les principaux mods de compatibilité.
- [ ] Tests 1080p / 1440p / 4K.
- [ ] Audit final des traductions et des clés l10n.
- [ ] Documentation utilisateur finale.
- [ ] Changelog de release.
- [ ] Packaging final sans suffixe TEST.
- [ ] Version publique uniquement lorsque le projet est suffisamment stable.

---

**Auteur : Chez_Squall**  
**Projet : FS25_AgriLifeManager**  
**Statut actuel : développement privé / builds TEST**