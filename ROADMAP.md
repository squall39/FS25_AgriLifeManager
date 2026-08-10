# Feuille de route — AgriLife Manager

> **Règle de développement : on termine et valide complètement un bloc avant d’ouvrir le suivant.**  
> Ordre de travail : **Démarrage → Interface de base → Banque → Entreprise → Carrière & Qualifications → Administration → Contrats & Marchés → Atelier → Finalisation**.

# 1 — Démarrage

Le **Démarrage** est la racine de toute carrière AgriLifeManager. Ce n’est pas un module du tableau de bord : il initialise la sauvegarde, le niveau de difficulté, les obligations de départ et les règles globales qui seront ensuite utilisées par tous les modules.

## Principes directeurs validés

- **Chaque nouvelle fonctionnalité doit avoir une conséquence réelle en jeu.** Un système ne doit pas exister uniquement pour remplir un menu.
- Les décisions doivent pouvoir produire des effets différés : progression, réputation, accès au crédit, contrats, assurance, fiscalité, sanctions, marchés ou développement de l’exploitation.
- La sauvegarde AgriLife doit rester propre à chaque carrière FS25 et conserver l’histoire de l’exploitation.
- Les intégrations avec Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres mods restent optionnelles : le cœur d’AgriLife doit fonctionner seul.
- La numérotation reste volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.
- **Aucun texte destiné au joueur ne doit rester codé en dur.** Toute chaîne visible doit passer par une clé l10n.
- **Toutes les langues distribuées avec le mod doivent posséder exactement les mêmes clés.** Une build publiable ne doit contenir aucune clé manquante.
- **Compatibilité universelle recherchée : aucune liste fixe de maps, fruits ou multifruits.** AgriLife doit détecter dynamiquement les contenus enregistrés par FS25, la map et les mods lorsque les API du jeu le permettent.
- **L’économie dynamique doit être commune à tous les modules concernés.** Marchés, coopératives, contrats, productions, location, carburant, foncier, matériel et comptabilité ne doivent pas fonctionner en silos séparés.
- **Tous les grands systèmes restent disponibles quelle que soit la difficulté.** La difficulté modifie les obligations, coûts, tolérances, délais et conséquences. Le mode Facile reste volontairement plus libre, sans transformer le cœur d’AgriLife en un autre mod.

## Choix de difficulté — trois niveaux uniquement

AgriLife Manager conserve **uniquement trois difficultés : Facile, Normal et Difficile**.

| Niveau | Capital de départ | Philosophie |
|---|---:|---|
| **Facile** | 200 000 € | Gestion libre et accessible, tolérances larges, obligations réduites et sanctions faibles. |
| **Normal** | 100 000 € | Expérience complète équilibrée avec banque obligatoire et permis provisoire limité dans le temps. |
| **Difficile** | 50 000 € | Expérience complète avec obligations renforcées, banque obligatoire et permis définitif requis avant conduite normale. |

Le niveau choisi est permanent pour la sauvegarde.

### Facile

- Banque et conseiller **facultatifs au démarrage**.
- Examen/permis **facultatif**.
- Le joueur peut utiliser librement les véhicules dès le départ.
- Plus de tolérance et d’accompagnement.
- Coûts, sanctions, intérêts, franchises et pénalités réduits.
- Critères d’examen et de financement plus permissifs.
- Événements négatifs et fluctuations économiques moins sévères.

### Normal

- Banque + conseiller **obligatoires au démarrage**.
- Une fois la banque et le conseiller validés, AgriLife active la carrière et délivre un **permis provisoire de 3 mois de jeu**.
- Pendant ces 3 mois, le joueur peut utiliser les véhicules et travailler normalement.
- Notification de rappel **toutes les 6 heures de jeu** tant que le permis définitif n’est pas obtenu.
- À l’expiration du permis provisoire : **amende unique de 500 €**, prélevée sur le **compte personnel du dirigeant**, jamais sur le compte professionnel.
- Après expiration, l’état devient **Permis provisoire expiré / échéance dépassée** et les rappels continuent tant que l’examen n’est pas réussi.
- Si le compte personnel ne peut pas régler une sanction, la société ne doit pas payer silencieusement à sa place ; ce cas devra être transmis plus tard à l’Administration comme sanction personnelle impayée.
- Le délai de 3 mois ne commence qu’après validation banque + conseiller, pas pendant le tutoriel ou le choix de difficulté.

### Difficile

- Banque + conseiller **obligatoires au démarrage**.
- Après validation bancaire, l’examen agricole devient **obligatoire**.
- Le joueur ne doit pas pouvoir utiliser normalement les véhicules tant que le permis définitif n’est pas obtenu.
- Exception : le matériel nécessaire à une épreuve active doit rester utilisable pendant l’examen.
- Dossiers bancaires plus exigeants, coûts et garanties plus sévères.
- Examens moins tolérants et erreurs plus pénalisantes.
- Fiscalité, assurances, charges, contrôles et sanctions renforcés.
- Réputation plus importante dans l’accès aux opportunités.
- Marchés et locations plus sensibles aux tensions économiques.
- Mauvaise gestion financière ou administrative avec conséquences durables.

## Règle centrale : la difficulté agit sur tout AgriLifeManager

Chaque module doit consulter le même profil de difficulté central. Selon le niveau choisi, AgriLife peut faire varier notamment :

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
- amplitude et vitesse des évolutions de marché ;
- coût et disponibilité des locations ;
- aide contextuelle, tutoriel et niveau d’accompagnement.

## Séquence logique de démarrage

1. Arrivée réelle du joueur sur la map.
2. Lancement du tutoriel/onboarding uniquement une fois le gameplay réellement chargé, jamais pendant le choix du personnage ou des vêtements.
3. Choix **Facile / Normal / Difficile**.
4. Validation définitive du niveau pour cette sauvegarde.
5. Attribution du capital de départ AgriLife une seule fois.
6. Chargement du profil global de difficulté.
7. Application du parcours correspondant :
   - **Facile** → carrière libre immédiatement ; banque et examen facultatifs.
   - **Normal** → banque + conseiller obligatoires → carrière active + permis provisoire 3 mois → examen à passer avant échéance pour éviter sanction.
   - **Difficile** → banque + conseiller obligatoires → examen obligatoire → déblocage complet de la conduite après obtention du permis.
8. Validation du démarrage.
9. Passage à la carrière active ; tous les modules utilisent ensuite le même profil de difficulté pendant toute la sauvegarde.

## Tutoriel / onboarding du démarrage

- [x] Tutoriel différé jusqu’à l’arrivée réelle en gameplay.
- [x] Tutoriel mis à jour pour expliquer les différences Facile / Normal / Difficile et l’ordre Banque → Permis lorsque requis.
- [x] Le mode Normal explique le permis provisoire de 3 mois, les rappels et l’amende de 500 € après échéance.
- [ ] Revalider complètement l’onboarding dans chacun des trois niveaux de difficulté.

## Persistance du démarrage

- [x] État AgriLife enregistré dans la sauvegarde carrière FS25.
- [x] Nouvelle carrière : capital AgriLife et gestion dédiée du démarrage.
- [x] Migration des sauvegardes existantes sans écraser leur patrimoine — mécanisme existant, revalidation terrain encore à faire dans la campagne actuelle.
- [x] Conservation de la dette FS25 existante comme dette héritée — mécanisme existant, revalidation terrain encore à faire dans la campagne actuelle.
- [x] Le niveau Normal, le départ validé et le permis provisoire persistent après sauvegarde/rechargement.
- [x] La banque et le conseiller sélectionnés dans le parcours Normal restent associés à la carrière après rechargement.
- [ ] Garantir par test complet qu’une nouvelle partie ne récupère jamais la progression AgriLife d’une autre sauvegarde.
- [ ] Revalider la persistance du niveau Facile après sauvegarde/rechargement complet.
- [ ] Revalider la persistance du niveau Difficile après sauvegarde/rechargement complet.
- [ ] Revalider la migration d’une ancienne sauvegarde avec patrimoine et dette FS25 existante.
- [ ] Revalider la persistance AgriLife et l’absence de progression partagée entre deux nouvelles carrières.

## État des tests Démarrage

### Facile

- [x] Capital de départ : **200 000 €**.
- [x] Banque non obligatoire au démarrage.
- [x] Examen non obligatoire.
- [x] Accès véhicule libre.
- [x] Tableau de bord cohérent avec le mode Facile sur la build testée.
- [ ] Faire un dernier cycle sauvegarde → rechargement → contrôle du démarrage déjà validé.

### Normal

- [x] Capital de départ : **100 000 €**.
- [x] Banque + conseiller obligatoires avant validation du départ.
- [x] Permis provisoire activé après validation banque + conseiller.
- [x] Durée : **3 mois de jeu**.
- [x] Accès véhicule autorisé pendant le permis provisoire.
- [x] Notification de rappel toutes les **6 heures de jeu**.
- [x] Tableau de bord : **PERMIS PROVISOIRE** + échéance restante.
- [x] À expiration : **PROVISOIRE EXPIRÉ / ÉCHÉANCE DÉPASSÉE**.
- [x] Rappels maintenus après expiration tant que l’examen n’est pas réussi.
- [x] Amende unique : **500 €**.
- [x] Amende débitée sur le **compte personnel** et non sur la trésorerie professionnelle.
- [x] Le compte personnel justifie les mouvements : capital, salaire, retenues, net versé, logement, frais bancaires personnels et amende.
- [x] Vérification chiffrée du troisième mois : solde personnel attendu et affiché **8 525 €** après amende dans le scénario testé.
- [ ] Harmoniser définitivement les arrondis affichés afin que chaque addition ligne par ligne retombe toujours exactement sur le solde présenté.
- [ ] Remplacer tout libellé générique de type « mouvement personnel » pour l’amende par un libellé explicite **Amende permis provisoire**.
- [ ] Faire un dernier cycle sauvegarde → rechargement après expiration pour vérifier que l’état expiré et l’amende déjà payée ne se rejouent pas.

### Difficile — prochain test

- [ ] Capital de départ : **50 000 €**.
- [ ] Banque + conseiller obligatoires.
- [ ] Examen obligatoire après validation bancaire.
- [ ] Verrouillage de l’accès normal aux véhicules avant obtention du permis.
- [ ] Exception fonctionnelle pour le véhicule/matériel de l’examen actif.
- [ ] Refaire la chaîne complète des 10 étapes si nécessaire.
- [ ] Sauvegarder/recharger en cours d’examen pour vérifier la persistance de l’étape.
- [ ] Terminer l’examen, sauvegarder/recharger et vérifier que le permis reste obtenu et que l’accès véhicule reste débloqué.

### Ancienne sauvegarde / isolation — à faire après Difficile

- [ ] Charger l’ancienne sauvegarde sans écraser argent, véhicules, terrains, bâtiments ou progression FS25.
- [ ] Vérifier que la dette FS25 existante est conservée comme dette héritée sans duplication.
- [ ] Vérifier qu’une nouvelle carrière créée après les autres tests reste totalement vierge côté AgriLife.

---

# 2 — Interface & expérience utilisateur

L’Interface n’est **pas un module métier**. Elle sert de couche commune pour présenter les six modules joueur et les informations globales de la carrière.

## Tableau de bord — racine de l’information

Le tableau de bord conserve la structure visuelle actuelle en **6 cartes**, une par module :

1. **Banque**
2. **Entreprise**
3. **Carrière & Qualifications**
4. **Administration**
5. **Contrats & Marchés**
6. **Atelier**

Le bloc **État du noyau** n’a pas vocation à rester une carte joueur. Les diagnostics techniques doivent être déplacés hors du tableau de bord principal.

Le **Démarrage** n’est pas une carte. Le bas du tableau de bord peut néanmoins conserver les informations globales comme le niveau de difficulté et l’état « départ validé ».

### Résumés attendus sur les 6 cartes

- **Banque** : banque actuelle, conseiller, contrat bancaire, durée/échéance du contrat, trésorerie, dette et score de crédit.
- **Entreprise** : salariés actifs, disponibles/occupés/absents, masse salariale, tâches actives et réputation de l’exploitation.
- **Carrière & Qualifications** : niveau, XP, état réel du permis, échéance éventuelle, examens réussis, qualifications et progression.
- **Administration** : statut administratif, assurance, contrôles/alertes, sanctions ou échéances en cours.
- **Contrats & Marchés** : contrats actifs, prochaine échéance, coopérative/acheteur, tendance de marché et opportunités importantes.
- **Atelier** : état du matériel, entretiens dus, immobilisations, réparations et alertes atelier.

### Carte Carrière & Qualifications / permis

- [x] En Normal, afficher **PERMIS PROVISOIRE** à la place de « Disponible » pendant la période provisoire.
- [x] Afficher l’échéance restante du permis provisoire.
- [x] Après expiration, afficher **PROVISOIRE EXPIRÉ** et **ÉCHÉANCE DÉPASSÉE**.
- [ ] En Facile, afficher clairement le caractère **FACULTATIF** du permis/examen.
- [ ] En Difficile, afficher clairement **EXAMEN OBLIGATOIRE / ACCÈS VÉHICULE VERROUILLÉ** avant réussite.
- [ ] Après réussite, afficher **PERMIS OBTENU / RÉUSSI**, score/résultat, tentatives et historique utile.

## Identité visuelle & navigation

- [x] Nouvelle identité visuelle sombre et structurée.
- [x] Navigation AgriLife intégrée au menu Échap.
- [x] Tutoriel différé jusqu’à l’arrivée réelle en gameplay.
- [x] Assistance native intégrée.
- [x] Support 1920×1080 validé comme base.
- [x] Pictogrammes conservés comme élément volontaire de l’identité AgriLife.
- [x] Tableau de bord avec action obligatoire contextuelle.
- [x] Adaptation initiale du tutoriel et des avertissements aux parcours Facile / Normal / Difficile pour le Démarrage.
- [ ] Finaliser l’adaptation 1440p / 4K.
- [ ] Harmoniser taille, netteté et placement des pictogrammes sans les supprimer.
- [ ] Harmoniser tailles de texte, boutons et onglets.
- [ ] Supprimer tout artefact visuel résiduel.
- [ ] Synchroniser chaque évolution majeure avec le tutoriel et Échap → Assistance.
- [ ] Ajouter un **Journal de bord AgriLife** retraçant les grands événements de la carrière.
- [ ] Ajouter des vues lisibles pour tendances de marché, contrats, locations et coûts de production.
- [ ] Vérifier le HUD permanent, les transitions d’étapes et les erreurs explicites.

---

# 3 — Module Banque

Le module Banque regroupe **Banque & finance + Comptabilité & fiscalité**. Il possède les données financières ; les autres modules peuvent les consulter mais ne doivent pas recréer leur propre logique bancaire ou comptable.

**Règle de chantier : le module Banque devra être terminé de A à Z et validé avant d’ouvrir le chantier Entreprise.**

## Banque, conseiller & relation bancaire

- [x] Base Banque et Conseiller.
- [x] Choix banque + conseiller utilisé comme prérequis réel du Démarrage en Normal.
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
- [ ] Ajouter des raisons détaillées de décision et journaliser les facteurs déterminants.
- [ ] Faire varier taux, plafond, durée, garanties et délai selon banque, conseiller, objet, dossier et difficulté.
- [ ] Intégrer les tendances économiques et les marchés dans certaines décisions de financement.

## Contrat bancaire durable

La banque et le conseiller ne doivent pas rester des sélecteurs libres une fois la relation engagée. Cette partie est volontairement laissée au chantier **Banque**, pas au Démarrage.

- [ ] Ajouter une phase de consultation/offre avant engagement.
- [ ] Permettre au joueur de choisir une banque et un conseiller compatibles avec son dossier.
- [ ] Signer un **contrat bancaire à durée déterminée** entre exploitation, banque et conseiller.
- [ ] Une fois le contrat signé, verrouiller l’accès aux autres banques/conseillers pendant la durée du contrat.
- [ ] Afficher clairement la banque, le conseiller, le statut du contrat et le temps restant dans Banque et sur le Tableau de bord.
- [ ] Permettre le renouvellement naturel du contrat à échéance.
- [ ] Permettre un changement de banque à échéance.
- [ ] Permettre une rupture volontaire anticipée avec conséquences réelles : frais éventuels, baisse de confiance/réputation bancaire et interdiction temporaire de revenir dans la banque quittée.
- [ ] Permettre une résiliation anticipée par la banque en cas de situation grave : mauvaise réputation, incidents répétés, déficit/découvert excessif, impayés ou autres critères cohérents.
- [ ] Conserver les prêts existants liés à leur banque d’origine même après changement d’établissement.
- [ ] Prévoir refinancement/rachat de dette lorsqu’une autre banque accepte de reprendre le dossier.
- [ ] Sauvegarder et synchroniser complètement la relation bancaire.

## Comptes & finances de base

- [x] Base du compte professionnel.
- [x] Base du compte personnel.
- [x] Début de relevé/mouvements sur le compte professionnel.
- [x] Relevé personnel enrichi : capital initial, paies, brut, retenues, net versé, logement, frais bancaires personnels, sanctions et solde après mouvement.
- [x] Séparation vérifiée entre compte professionnel et compte personnel pour l’amende du permis provisoire Normal.
- [ ] Harmoniser tous les arrondis monétaires affichés afin que le relevé soit recalculable ligne par ligne sans écart visuel.
- [ ] Historique complet des transactions avec catégories/tags.
- [ ] Filtres par période, catégorie, fournisseur, contrat et type de flux.
- [ ] Détail des prêts : capital, restant dû, taux, mensualité, échéance, durée, coût total et remboursement anticipé.
- [ ] Affichage séparé de la dette FS25 héritée sur les sauvegardes existantes.
- [ ] Prévision de trésorerie et capacité d’emprunt.
- [ ] Refinancement / renégociation via conseiller.

## Comptabilité & fiscalité

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
- [ ] Intégrer achats, ventes, locations, carburants, intrants, contrats et productions au calcul réel de rentabilité.

## Menu Finances vanilla FS25

- [x] Blocage fonctionnel des nouvelles opérations de crédit vanilla.
- [ ] Intercepter les actions avant comptabilisation FS25.
- [ ] Supprimer/désactiver visuellement les commandes Emprunter / Rembourser dans le menu Finances vanilla.
- [ ] Préserver le reste des informations financières utiles du jeu.
- [ ] À terme, faire d’AgriLife → Banque → Finances la page financière principale.

---

# 4 — Module Entreprise

Le module Entreprise regroupe la gestion de la main-d’œuvre, la paie, les ordres de travail, l’évolution des salariés et la **réputation de l’exploitation/du dirigeant**.

## Salariés & contrats de travail

- [x] Structure Personnel / Équipe & paie.
- [x] Base des employés AgriLife.
- [x] Compétences visuelles en étoiles.
- [ ] Renommer/réorganiser l’entrée actuelle **Salaires & Personnel** en **Entreprise** lorsque ce chantier sera ouvert.
- [ ] Ajouter trois types de contrats : **CDI, CDD et saisonnier**.
- [ ] Fiche salarié complète : contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, expérience et historique.
- [ ] Disponibilité, horaires, pauses, heures supplémentaires, congés, maladie et absences.
- [ ] Promotion, augmentation, renouvellement, fin de contrat et licenciement.
- [ ] Faire varier coûts employeur, contraintes et tolérances selon la difficulté.

## Une personne = une tâche réelle

- [ ] **1 salarié disponible = 1 tâche automatisée active maximum.**
- [ ] Empêcher qu’un même salarié soit affecté simultanément à plusieurs véhicules/tâches.
- [ ] Libérer automatiquement le salarié à la fin, l’arrêt ou l’annulation de sa tâche.
- [ ] Afficher clairement : disponible / affecté / en pause / absent / congé / malade.

## Centre d’ordres AgriLife

- [ ] Sélection visuelle : **salarié → véhicule → outil → travail → champ/destination**.
- [ ] Proposer les travaux compatibles avec le véhicule et l’outil réellement attaché.
- [ ] S’appuyer sur l’IA native FS25 lorsque le travail demandé est supporté par le jeu.
- [ ] Commandes : démarrer, mettre en pause, reprendre, arrêter/rappeler.
- [ ] Afficher état, progression, champ/destination, véhicule et outil utilisés.
- [ ] Ne jamais simuler un travail impossible.

## Paie unique & intégrations d’exécution

AgriLife devient la source unique de paie des salariés enregistrés afin d’éviter de payer deux fois un même ouvrier lorsqu’une tâche est exécutée par FS25, Courseplay ou AutoDrive.

- [ ] Faire d’AgriLife l’unique moteur de salaire des employés enregistrés dans Entreprise.
- [ ] Neutraliser le coût horaire de l’ouvrier vanilla lorsqu’une tâche est liée à un salarié AgriLife.
- [ ] Intégration optionnelle Courseplay par détection/hooks, sans modifier Courseplay.
- [ ] Intégration optionnelle AutoDrive par détection/hooks, sans modifier AutoDrive.
- [ ] Prévoir un retour propre au fonctionnement autonome si un mod tiers devient temporairement incompatible.
- [ ] Valider la séparation joueur humain / GPS natif / salariés AgriLife.

## Expérience & évolution des salariés

- [ ] Chaque salarié gagne de l’expérience uniquement grâce au travail réellement effectué.
- [ ] Compétence générale + spécialités : sol, semis, fertilisation, récolte, transport, élevage, mécanique, etc.
- [ ] Progression selon temps de travail, type de tâche, réussite, incidents et difficulté.
- [ ] Le niveau de compétence influence salaire et évolution sans bonus irréalistes.
- [ ] Conserver l’historique de carrière du salarié dans la sauvegarde.

## Réputation de l’exploitation

La réputation appartient à l’Entreprise. Banque, Administration, Contrats & Marchés et autres systèmes la **consultent**, mais ne doivent pas recréer leur propre moteur de réputation.

- [ ] Créer une réputation globale de l’exploitation et du dirigeant.
- [ ] Faire évoluer la réputation à partir d’actions réelles : contrats, retards, dettes, incidents, examens, qualité du travail et gestion.
- [ ] Conserver l’historique des événements ayant modifié la réputation.
- [ ] Utiliser la réputation dans Banque, Conseiller, Contrats, Coopératives, Assurance et futurs contentieux.
- [ ] Débloquer progressivement de meilleures opportunités lorsque la réputation est solide.
- [ ] Permettre de reconstruire progressivement une réputation dégradée.
- [ ] Faire varier gains, pertes et seuils de réputation selon la difficulté.
- [ ] Afficher les principaux facteurs expliquant la note de réputation.

---

# 5 — Module Carrière & Qualifications

Le module Carrière & Qualifications regroupe **XP joueur, examens, permis, qualifications spécialisées et historique professionnel**. Les anciennes entrées séparées « Examens » et « XP & Carrière » doivent converger vers ce module unique.

## Carrière & XP

- [x] Structure carrière / XP.
- [ ] Ajouter une fiche de carrière durable : heures, hectares, travaux, examens, contrats, incidents et grandes étapes.
- [ ] Faire dépendre la vitesse d’XP et la progression du profil Facile / Normal / Difficile.
- [ ] Conserver une séparation stricte entre progression XP normale et progression des examens.

## Examens & permis

- [x] Structure examens.
- [x] HUD d’examen avec étape, action, progression, note et erreurs.
- [x] Panneau de réussite vert + consigne suivante.
- [x] Affichage persistant de la dernière erreur d’examen.
- [x] Correction logique du retour du matériel dans sa zone d’origine.
- [x] Progression de secours pour certains travaux réels : outil compatible actif/abaissé + déplacement réel.
- [x] État provisoire Normal relié au Démarrage : 3 mois, rappels 6 h, expiration et sanction personnelle.
- [ ] Revalider toute la chaîne réelle des 10 étapes sur une partie complète en Difficile lors de la prochaine session.
- [ ] Valider définitivement l’épreuve 5 « cultivation » dans la campagne de test actuelle.
- [ ] Vérifier les étapes 6/10 à 10/10 : retour, dételage, parking et sortie.
- [ ] Vérifier chaque outil et chaque type de travail comptabilisé.
- [ ] Faire varier frais d’inscription, tolérance, notation et exigences selon Facile / Normal / Difficile.
- [ ] Après réussite, le Tableau de bord doit afficher **PERMIS OBTENU / RÉUSSI** avec score/résultat et historique utile, jamais seulement « Disponible ».

## Qualifications spécialisées

- [ ] Ajouter des qualifications spécialisées : pulvérisation/phytosanitaire, télescopique, forestier, transport agricole ou autres catégories pertinentes.
- [ ] Faire dépendre l’accès à certaines activités professionnelles des qualifications réellement obtenues lorsque cela est cohérent avec le niveau choisi.

---

# 6 — Module Administration

Le module Administration regroupe **société/statuts administratifs, assurances, conformité, contrôles, sanctions, événements de gestion, huissier et contentieux**.

## Société & administration

- [x] Base du module Société.
- [ ] Faire dépendre obligations, coûts, formalités et délais de Facile / Normal / Difficile.
- [ ] Gestion plus profonde de la structure juridique.
- [ ] Utiliser la santé administrative de l’entreprise dans Banque, Contrats, Assurance et Contentieux.

## Statut d’exploitation évolutif

- [ ] Créer un statut professionnel progressif : **petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**.
- [ ] Conditions d’évolution : expérience, réputation, capital, examens, conformité et activité réelle.
- [ ] Donner à chaque statut des droits, opportunités et obligations supplémentaires.

## Contrôles administratifs & sanctions

- [ ] Contrôles de conformité de l’exploitation.
- [ ] Vérifier permis, assurances, documents et obligations réellement applicables au niveau choisi.
- [ ] Prévoir avertissement, régularisation, amende ou immobilisation selon gravité et difficulté.
- [ ] Historiser contrôles et récidives.
- [ ] Faire varier fréquence, seuils et sévérité des contrôles selon la difficulté.
- [ ] Faire influencer les sanctions par le comportement antérieur et la réputation.
- [ ] Chaque sanction doit avoir une cause identifiable par le joueur.
- [ ] Reprendre plus tard les sanctions personnelles impayées (ex. amende de permis Normal non réglable) sans ponction silencieuse sur la société.

## Événements de gestion

- [ ] Échéance, facture imprévue, contrôle, réparation lourde, absence salarié ou autre incident crédible.
- [ ] Adapter fréquence et sévérité à la difficulté.
- [ ] Donner plusieurs solutions réalistes lorsque c’est possible.

## Assurances

L’Assurance devient une composante de l’Administration et non une carte/module séparé du tableau de bord.

- [x] Base de l’écran Assurance.
- [ ] Contrats différenciés par formule, capital et risque.
- [ ] Sinistres et franchises.
- [ ] Impact du comportement, de la réputation, de l’historique et de la difficulté sur les primes.
- [ ] Interaction avec atelier, véhicules, bâtiments et exploitation.
- [ ] Faire varier primes, franchises, exclusions et tolérances selon Facile / Normal / Difficile.

## Huissier & contentieux

- [ ] Retards et incidents de paiement.
- [ ] Relances et mises en demeure.
- [ ] Transmission au système Huissier/Contentieux.
- [ ] Frais, échéanciers et procédures.
- [ ] Conséquences sur réputation, banque, contrats et société.
- [ ] Mécanismes de sortie réalistes : régularisation, négociation, restructuration.
- [ ] Prendre en compte les dettes fiscales et administratives.
- [ ] Faire varier délais, frais, tolérances et escalade selon la difficulté.

---

# 7 — Module Contrats & Marchés

Le module Contrats & Marchés regroupe **contrats commerciaux, coopératives, économie mondiale, marchés locaux, multifruits, matériel neuf/occasion, intrants, carburants, foncier, locations et productions/usines**.

## Contrats commerciaux & coopératives

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
- [ ] **Brancher les contrats et coopératives sur le moteur de marché dynamique.**
- [ ] Faire évoluer prix proposés, volumes recherchés, primes, pénalités et opportunités selon offre, demande, saison, marché et réputation.
- [ ] Permettre aux fruits et produits multifruits détectés dynamiquement de générer leurs propres opportunités de marché et contrats lorsqu’ils sont exploitables par les systèmes FS25.
- [ ] Relier les contrats de qualité aux données réellement disponibles de Precision Farming / Soil Fertilizer sans imposer ces mods.

## Architecture universelle — toutes maps / multifruit

- [ ] Détecter dynamiquement les fruits, fillTypes, produits, points de vente, productions, parcelles et articles magasin enregistrés dans la partie.
- [ ] Éviter toute liste fermée de cultures ou de maps dans le cœur du système.
- [ ] Supporter les multifruits ajoutés par la map ou par des mods dès lors qu’ils sont correctement enregistrés dans FS25.
- [ ] Détecter les productions/usines et leurs entrées/sorties lorsqu’elles utilisent les systèmes accessibles de FS25.
- [ ] Prévoir un fallback propre : un contenu non détectable est ignoré sans casser AgriLifeManager.

## Marché mondial des productions et produits

- [ ] Créer une tendance mondiale et des tendances locales pour les productions vendables.
- [ ] Faire varier les prix selon offre/demande, saison, stocks simulés, événements et activité économique.
- [ ] Éviter les fluctuations absurdes : bornes, inertie et retour progressif vers un prix de référence.
- [ ] Relier prix mondiaux, prix locaux, points de vente, coopératives, contrats et rentabilité.
- [ ] Permettre aux produits issus de productions/usines d’entrer dans le marché dynamique.
- [ ] Prendre en compte les multifruits détectés sans configuration manuelle systématique.

## Marché mondial du neuf et de l’occasion

- [ ] Marché dynamique des tracteurs, véhicules, outils et accessoires.
- [ ] Faire varier disponibilité, délais et prix du neuf selon demande et catégorie.
- [ ] Marché de l’occasion avec âge, heures, état, entretien, réparations, région simulée, rareté et demande.
- [ ] Faire varier la valeur de revente selon état réel et situation du marché.
- [ ] Inclure les articles de magasin compatibles détectés dynamiquement plutôt qu’une liste figée.

## Consommables, palettes & big bags

- [ ] Marché dynamique des palettes, big bags, semences, engrais, amendements, consommables et autres intrants enregistrés.
- [ ] Faire varier prix et disponibilité en fonction de la demande, de la saison et des tensions de marché.
- [ ] Relier le coût réel des intrants à la comptabilité et à la marge des productions/contrats.

## Carburants & énergie

- [ ] Prix dynamique du diesel et des autres énergies/carburants détectables.
- [ ] Faire évoluer les prix dans le temps avec inertie et événements crédibles.
- [ ] Répercuter le coût du carburant sur coûts de production, transport, travaux et rentabilité.
- [ ] Faire varier l’impact selon Facile / Normal / Difficile sans créer de prix incohérents.

## Foncier / champs dynamiques

- [ ] Marché foncier dynamique à partir des parcelles disponibles sur la map.
- [ ] Faire varier valeur des terres selon surface, potentiel économique, localisation disponible, rareté et contexte de marché.
- [ ] Ajouter des opportunités temporaires de vente ou de location lorsque techniquement possible.
- [ ] Conserver une logique compatible avec la structure propre de chaque map.

## Location dynamique — matériel, champs & usines

- [ ] Étendre la location dynamique au **matériel, outils, accessoires, champs/parcelles et productions/usines** lorsque le type d’actif peut être géré proprement.
- [ ] Faire varier tarif, disponibilité, durée, caution/frais et conditions selon marché et difficulté.
- [ ] Prévoir location courte, saisonnière ou plus longue lorsque pertinente.
- [ ] Intégrer les loyers dans la comptabilité, la trésorerie et les décisions bancaires.
- [ ] Prévoir conséquences réalistes en cas de retard, dégradation ou rupture de contrat de location.
- [ ] Ne jamais forcer une location sur un actif qu’une map ou un mod tiers ne permet pas de gérer de manière sûre.

## Productions / usines

- [ ] Intégrer achat, vente et location des productions/usines au moteur économique lorsque leur propriété peut être pilotée proprement.
- [ ] Faire varier leur valeur selon capacité, rentabilité potentielle, intrants, débouchés et contexte de marché.
- [ ] Relier coût des intrants, prix des sorties, entretien/charges et rentabilité réelle de la production.

## Contrats & coopératives reliés au marché

- [ ] Le marché mondial influence les besoins des coopératives et acheteurs.
- [ ] Une forte demande peut augmenter prix, volumes recherchés ou primes ; une surproduction peut les réduire.
- [ ] Les contrats doivent tenir compte des marchés mais aussi de la réputation, de l’historique et de la difficulté.
- [ ] Conserver plusieurs acheteurs avec stratégies différentes afin d’éviter un prix unique artificiel.

## Precision Farming & Soil Fertilizer — intégrations enrichies

- [ ] **Ne pas refaire leur agronomie dans AgriLifeManager.**
- [ ] Utiliser Precision Farming comme source optionnelle de données agronomiques réellement disponibles.
- [ ] Utiliser Soil Fertilizer comme source optionnelle pour les données de sol, fertilisation, intrants et qualité qu’il expose de manière exploitable.
- [ ] Transformer ces données en conséquences AgriLife : coûts, rentabilité, conditions contractuelles, primes qualité, réputation, contrôles et historique.
- [ ] Relier le prix dynamique des intrants aux coûts de production issus de Soil Fertilizer lorsque pertinent.
- [ ] Permettre à certains contrats/coopératives d’imposer des critères agronomiques uniquement lorsqu’ils peuvent être mesurés de façon fiable.
- [ ] Si PF ou Soil Fertilizer est absent, conserver un fonctionnement AgriLife complet basé sur FS25 vanilla.
- [ ] Si une donnée externe devient indisponible ou change après une mise à jour, désactiver seulement l’enrichissement concerné sans casser la sauvegarde.
- [ ] **La difficulté AgriLife modifie les conséquences économiques/administratives, pas artificiellement les lois agronomiques de PF ou Soil Fertilizer.**

## Chaîne économique de référence

**sol / pratiques → intrants → coût de production → rendement / qualité → marché mondial → marchés locaux → coopératives / usines → contrats → comptabilité → banque → réputation**

Documentation détaillée : **[docs/DYNAMIC_ECONOMY_AGRONOMY.md](docs/DYNAMIC_ECONOMY_AGRONOMY.md)**.

---

# 8 — Module Atelier

Le module Atelier possède tout ce qui concerne l’état, l’entretien, l’usure, les réparations, les immobilisations et l’historique technique du matériel. Les marchés peuvent influencer sa valeur économique mais ne doivent pas dupliquer la logique d’entretien.

- [x] Base de l’Atelier.
- [x] État du matériel et opérations de maintenance.
- [ ] Usure, entretien et immobilisation plus poussés.
- [ ] Relier la valeur du matériel au marché mondial du neuf et de l’occasion.
- [ ] Coûts de maintenance et réparations liés à l’historique.
- [ ] Interaction avec assurances et trésorerie.
- [ ] Historique économique complet du matériel : achat, usage, entretien, sinistres, réparation et valeur résiduelle.
- [ ] Faire varier coûts, tolérances et conséquences d’entretien selon la difficulté.

---

# 9 — Finalisation

La Finalisation n’est **pas un module joueur**. Elle regroupe les phases techniques nécessaires pour rendre AgriLifeManager stable, compatible, traduisible, migrable, multijoueur et publiable.

## Compatibilités PC optionnelles

AgriLife Manager doit rester autonome : aucune compatibilité ne doit devenir une dépendance dure.

- [ ] Courseplay.
- [ ] AutoDrive.
- [ ] Soil Fertilizer — intégration enrichie mais optionnelle.
- [ ] Precision Farming — intégration enrichie mais optionnelle.
- [ ] Autres mods de gestion ou réalisme identifiés pendant les tests.
- [ ] Vérifier qu’AgriLife continue à fonctionner correctement lorsque ces mods sont absents.
- [ ] Vérifier l’auto-détection sur plusieurs maps vanilla, modmaps et maps multifruits.

## Sauvegardes, migration & multijoueur

- [x] État AgriLife enregistré dans la sauvegarde carrière FS25.
- [x] Migration des sauvegardes existantes sans écraser leur patrimoine — à revalider dans la campagne Démarrage actuelle.
- [x] Conservation de la dette FS25 existante comme dette héritée — à revalider dans la campagne Démarrage actuelle.
- [x] Nouvelle carrière : capital AgriLife et gestion dédiée du démarrage.
- [ ] Garantir qu’une nouvelle partie ne récupère jamais la progression AgriLife d’une autre sauvegarde.
- [ ] Sauvegarder l’état des marchés, locations, contrats et tendances économiques par carrière.
- [ ] Renforcer les migrations entre versions du mod.
- [ ] Tests de corruption/récupération backup.
- [ ] Multi-fermes.
- [ ] Multijoueur complet.
- [ ] Autorité serveur et synchronisation réseau de tous les modules.

## Traductions, localisation & clés l10n

### Référentiel de clés

- [ ] Utiliser une langue de référence complète pour recenser toutes les clés du mod.
- [ ] Inventorier automatiquement toutes les clés l10n utilisées dans Lua, XML, GUI, tutoriel, assistance, notifications, examens, menus et modules.
- [ ] Comparer chaque fichier de langue au référentiel et détecter clés absentes, doublons, clés inutilisées et fautes de nommage.
- [ ] Interdire les textes joueur codés directement dans Lua/XML lorsque le système l10n peut être utilisé.
- [ ] Ajouter une vérification de cohérence des clés avant chaque build importante.

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

### Critères l10n avant publication

- [ ] **0 clé manquante dans toutes les langues distribuées.**
- [ ] **0 texte joueur codé en dur non justifié.**
- [ ] **0 clé l10n brute visible en jeu.**
- [ ] **0 traduction volontairement laissée vide.**
- [ ] Audit complet des traductions après chaque ajout massif de fonctionnalités.

## Méthode de développement & validation

- Conserver une base jouable stable avant d’ouvrir un nouveau grand bloc.
- **Terminer entièrement le bloc ou module en cours avant de passer au suivant.**
- Ordre obligatoire : **Démarrage → Interface de base → Banque → Entreprise → Carrière & Qualifications → Administration → Contrats & Marchés → Atelier → Finalisation**.
- Ne pas commencer le développement fonctionnel d’un module futur simplement parce que le module courant lui transmettra une donnée ; préparer seulement le point de connexion nécessaire côté module courant.
- Développer **un système complet et cohérent** avant de demander un test joueur, au lieu d’enchaîner les micro-builds et micro-tests.
- Continuer les contrôles statiques/verifiers après chaque changement de développement.
- Réserver les tests rapides intermédiaires aux infrastructures globales critiques : sauvegarde/chargement, onboarding, accès véhicule, synchronisation ou autre mécanisme transversal.
- Chaque module doit être testé comme un vrai cycle de gameplay complet avec ses conséquences et ses interactions.
- Un module n’est considéré terminé qu’après : fonctionnalités → interface → liens nécessaires → sauvegarde → difficulté → l10n → tableau de bord → contrôles internes → test joueur → corrections → validation finale.

## Préparation publication

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
- [ ] Tests sur maps vanilla, modmaps et maps multifruits.
- [ ] Tests du marché dynamique, des locations, contrats, coopératives, carburants, usines et foncier.
- [ ] Tests 1080p / 1440p / 4K.
- [ ] Audit final des traductions et des clés l10n.
- [ ] Documentation utilisateur finale.
- [ ] Changelog de release.
- [ ] Packaging final propre.
- [ ] Les archives de build livrées utilisent le nom **`FS25_AgriLifeManager.zip`** ; le numéro de version reste dans les métadonnées/changelog.
- [ ] Version publique uniquement lorsque le projet est suffisamment stable.
- [ ] Conserver une numérotation **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.

---

## Architecture finale du menu joueur

Le tableau de bord regroupe exactement **6 modules fonctionnels** :

1. **Banque**
2. **Entreprise**
3. **Carrière & Qualifications**
4. **Administration**
5. **Contrats & Marchés**
6. **Atelier**

**Démarrage**, **Interface** et **Finalisation** ne sont pas des modules joueur.

---

**Auteur : Chez_Squall**  
**Projet : FS25_AgriLifeManager**  
**Statut actuel : développement pré-1.0 — Démarrage en cours de validation, Normal validé, Difficile prochain test**