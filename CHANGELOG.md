# 0.9.3.57 TEST

- Entreprise Planning : première implémentation du cycle physique des ouvriers avec l'IA native FS25.
- L'ouvrier mémorise la position initiale du véhicule et du matériel affecté avant le départ.
- Si un outil affecté n'est pas déjà attelé, l'ouvrier se déplace vers son emplacement, le prend puis lance le travail de champ.
- Une fois le travail terminé, tout matériel pris par l'ouvrier est ramené à son emplacement de départ, dételé puis repositionné avec précision si le véhicule est arrivé suffisamment près.
- Le véhicule revient ensuite à son propre emplacement de départ avant que l'ordre soit marqué terminé.
- Les équipements déjà attelés avant l'affectation restent attelés au retour.
- Ajout d'une journalisation détaillée des phases FETCH_EQUIPMENT, FIELDWORK, RETURN_EQUIPMENT et RETURN_VEHICLE pour diagnostiquer précisément un refus de l'IA FS25.
- GitHub reste volontairement hors de cette passe locale.

# 0.9.3.56 TEST

- Entreprise Planning : un seul bouton d'action est conservé dans la vue Planning. Le bouton d'en-tête est masqué, le gros bouton du panneau de droite devient l'unique action Planifier / Annuler.
- Entreprise Planning : le bouton du panneau de droite est maintenant réellement actif pour créer une nouvelle affectation lorsqu'aucune affectation n'existe pour le salarié sélectionné.
- Entreprise Planning : la disponibilité tient désormais compte des ordres de travail déjà actifs en plus de la file d'attente, afin d'éviter un bouton visuellement disponible suivi d'un refus ou d'une réservation en double.
- Entreprise Planning : la logique anti-doublon existante de la file reste active pour le salarié, le véhicule, l'outil principal et le matériel complémentaire.
- GitHub reste volontairement hors de cette passe locale.

# 0.9.3.55 TEST

- XP Carrière : la détection Récolte reçoit un second signal basé sur l'entrée réelle de grain dans la trémie de la moissonneuse.
- XP Carrière : lorsque FS25 fournit le rendement du fruit, le gain réel de trémie est converti en surface récoltée pour conserver la progression en XP par hectare.
- XP Carrière : le signal exact WorkArea reste prioritaire et bloque le repli trémie afin d'éviter le double comptage.
- XP Carrière : sur une culture ou un multifruit sans rendement exploitable, la trémie active au champ force au minimum le HUD sur Récolte sans inventer de points XP.
- XP Carrière : aucun repli trémie n'est comptabilisé pendant un examen agricole et aucune récolte d'examen n'est reportée après sa fin.
- Examen Récolte : comportement 0.9.3.54 conservé après retour test positif, les incohérences restantes seront traitées uniquement sur cas précis.
- GitHub reste volontairement hors de cette passe locale.

# 0.9.3.54 TEST

- Entreprise Planning : le panneau Planning des travaux affiche maintenant les vignettes FS25 du véhicule, de l'outil principal et du matériel complémentaire réellement affectés.
- Entreprise Planning : le bloc récapitulatif en bas de page est masqué dans la vue Planning afin de supprimer les informations en double.
- Entreprise Planning : pour Récolte, les deux sélecteurs deviennent BARRE DE COUPE et CHARIOT DE COUPE. Les chariots porte-coupe compatibles sont proposés comme matériel complémentaire.
- Entreprise Planning : une affectation est maintenant lancée automatiquement dès sa création. La file réessaie ensuite si l'automatisation FS25 est temporairement indisponible.
- Entreprise Planning : nettoyage défensif des doublons de réservation dans la file de travaux afin qu'un salarié, un véhicule, un outil ou un matériel complémentaire ne reste pas affecté deux fois.
- GitHub reste volontairement hors de cette passe locale.

# 0.9.3.53 TEST

- Examen Récolte étape 5 : la distance parcourue ne valide plus la récolte. La progression exige une vraie surface récoltée ou une hausse réelle du grain dans la trémie.
- Examen Récolte étape 6 : la trémie doit être vidée, la récolte arrêtée et la barre relevée avant validation.
- Entreprise Planning : les 11 clés de sélecteurs ajoutées récemment sont replacées dans le bloc l10n chargé par FS25 pour les 27 langues.
- Entreprise Planning : une barre de coupe utilisée à l'avant est affichée dans AVANT / MASSE, avec OUTIL ARRIÈRE séparé pour éviter les informations contradictoires.
- Entreprise Planning : textes des sélecteurs et boutons agrandis pour améliorer la lisibilité à 1920 x 1080.

# 0.9.3.52 TEST

- F04.3 Planning: selectors are now explicit and ordered Vehicle, Front/Weight, Rear Tool, Work, Field.
- F04.3 Planning: front equipment no longer lists unrelated rear work implements such as cultivators.
- F04.3 Planning: work-tool side is shown as FRONT or REAR and the literal line-break entity in the assignment preview is fixed.
- Exams: fixed a Lua scope error in harvest work-position evaluation that caused a repeated update error at Exam6Service.lua:237.
- Exams: harvest cutter work position now reads the official FS25 attacher-joint state before fallback checks.

## 0.9.3.51 - F04.3 Planning et examen Récolte

- Correction de la compilation de `F04EnterprisePerformance09346.lua` qui empêchait l'installation fiable des couches Planning suivantes.
- Sélecteur Planning outil réactivé avec diagnostic du nombre d'outils compatibles.
- Espacement revu des commandes matériel dans Entreprise.
- Examen Récolte : étape de position de travail renforcée avec état d'abaissement GIANTS et détection physique relative de la barre de coupe.

# 0.9.3.50 TEST - Planning outil et examen Récolte

- F04.3 : le sélecteur d'outil parcourt maintenant tout le graphe du matériel possédé, y compris les outils déjà attelés à un véhicule racine.
- F04.3 : les vignettes véhicule, outil et équipement avant continuent d'utiliser les images StoreItem FS25 réelles.
- Examen Récolte : étape 2 = transport 800 m avec chariot porte-coupe et barre réellement portée sur le chariot.
- Examen Récolte : étape 3 = attelage réel de la barre de coupe à la moissonneuse après le trajet.
- Examen Récolte : étape 4 = détection directe de la position de travail réelle de la barre de coupe, sans verrou impossible lié à l'état de départ de l'étape.
- HUD examen : ordre d'affichage des lignes remis dans le sens naturel de lecture pour éviter les consignes qui semblaient coupées ou inversées.
- F04.2 reste validé. F04.3 reste en test.

# 0.9.3.49 TEST - Planning matériel réel

- F04.3 : ajoute une sélection manuelle séparée du véhicule, de l'outil principal et de l'équipement avant ou de la masse.
- Utilise les vignettes réelles du StoreItem FS25 pour le matériel sélectionné avec repli visuel uniquement si FS25 ne fournit aucune image.
- Respecte exactement l'outil choisi et n'effectue plus de substitution implicite après la sélection.
- Enregistre l'équipement complémentaire dans le planning et le conserve après sauvegarde.
- Ajoute les conflits de réservation sur l'outil principal et l'équipement complémentaire.
- Conserve le filtrage sur les champs possédés et l'absence de départ automatique en F04.3.

# 0.9.3.47 TEST - fast path Entreprise F04.2

- Remplace la chaîne empilée de rafraîchissements Paie/Entreprise par un seul rendu direct dédié à la page Entreprise.
- Le rendu lit les états déjà en mémoire et n'appelle plus les snapshots complets Économie, Paie ou Entreprise à chaque clic.
- Les candidats sont lus depuis l'état Entreprise courant sans régénération implicite du marché.
- La liste salariés, le dossier salarié/propriétaire, les salaires, la sélection véhicule, le type de travail, le champ et l'ordre actif sont reconstruits dans un passage unique.
- Planning, Formations et Incidents ne calculent leurs données que lorsque leur vue est ouverte.
- La promotion du dossier salarié ne construit plus de prévision de main-d'œuvre avant l'action.
- Ajoute une télémétrie uniquement si le rendu rapide dépasse 12 ms.
- Les salaires validés en 0.9.3.46 sont conservés sans modification.
- F04.2 Dossier salarié, propriétaire, salaires et fluidité validée en jeu sur 0.9.3.47.
- F04.3 Planning devient le prochain bloc officiel de test.
- GitHub synchronisé après validation de F04.2.

# 0.9.3.44 TEST - stabilité UI et cohérence des examens par activité

- Supprime le décorateur `Economy:getFarmState` du module d'aide agricole, identifié dans les gels UI avec `stack overflow`.
- L'aide agricole initialise désormais uniquement sa propre sous-structure lorsqu'elle en a réellement besoin.
- Corrige la cohérence du scénario Récolte : l'étape 1 exige une machine de récolte compatible au lieu d'accepter un tracteur ordinaire.
- L'étape d'attelage Récolte exige une vraie barre de coupe/cutter attachée à la machine.
- Généralise les textes d'examen autour du `véhicule d'examen` afin d'éviter les consignes contradictoires entre activité et matériel.
- Conserve les corrections d'affichage et de progression des versions précédentes.
- F04.2 Entreprise reste la campagne officielle ; ces corrections Examen proviennent du test parallèle.

# 0.9.3.43 TEST - examen étape 4 machines automotrices

- Corrige l’étape 4/10 de l’examen qui pouvait rester à 0 % avec une moissonneuse et sa barre de coupe.
- La détection de position de travail fusionne maintenant l’état de l’outil assigné et celui de l’ensemble automoteur lorsque la spécialisation du scénario est portée par le véhicule racine.
- Ajoute une progression intermédiaire visible à l’étape 4 afin que le HUD ne reste plus figé à 0 % pendant la préparation.
- Ajoute le diagnostic `Prepare-state` dans le log pour identifier immédiatement les états abaissé, déplié, prêt et armé.
- Conserve la règle validée : l’XP de carrière reste suspendue pendant l’examen agricole.

# 0.9.3.42 TEST - correction finale des textes tronqués du tableau de bord

- Recompose la barre d étape du tableau de bord sur trois niveaux.
- Étend le message explicatif de 450 px à 1138 px pour empêcher la troncature des confirmations et consignes longues.
- Conserve la lisibilité renforcée de la 0.9.3.41 sur la navigation, les cartes et le bandeau supérieur.
- Conserve le retour à la ligne de la valeur permis dans Carrière et Qualifications.
- Étend aussi la page Examen : objectif et critère disposent de plusieurs lignes complètes.
- Le HUD d examen ne coupe plus les consignes longues avec `...` : objectif et messages peuvent être rendus sur plusieurs lignes au-dessus du mini-PDA.
- Aucun changement métier ni changement de schéma de sauvegarde.

## 0.9.3.40 TEST

- F04.2 : corrige un `stack overflow` introduit par le recalcul salarial 0.9.3.39.
- Le calcul du salaire ne demande plus le snapshot complet Economie pour lire la difficulté.
- La difficulté est lue directement dans l'état Economie afin d'éviter la boucle Economie -> Paie -> Salaire -> Economie.
- Le marché des candidats utilise la même lecture directe.
- Le service Entreprise lit également la difficulté directement depuis l’état Économie pour supprimer ce type de récursion à la source.
- Aucun changement de schéma de sauvegarde.

# 0.9.3.39 TEST - dossier RH complet et salaires par difficulté

- Restaure l'affichage complet du Dossier salarié après la fusion avec Carrière salarié.
- Le panneau affiche de nouveau les informations de contrat, paie, spécialité, XP, performance, temps de travail, absences, ordre actif et carrière.
- Ajoute les informations de paie recommandée, fourchette, réputation et moral dans la fiche.
- Le propriétaire utilise la même fiche complète avec son rôle traduit et ne peut plus recevoir une action de promotion.
- Rééquilibre la rémunération automatique selon la difficulté : Facile 85 %, Normal 95 %, Difficile 105 % de la grille de référence.
- Rééquilibre aussi les salaires demandés par les nouveaux candidats avec une formule cohérente avec leur compétence et leur expérience.
- Les salaires manuels existants restent sauvegardés mais sont bornés automatiquement dans la nouvelle fourchette du mode.
- Aucun changement de schéma de sauvegarde.

# 0.9.3.38 TEST - dossier salarié unifié F04.2

- Agrandit le titre et le contenu du panneau `Dossier salarié` dans Entreprise.
- Le titre passe à 20 px et le texte principal à 13 px, avec une zone de texte plus haute afin d'utiliser davantage le panneau droit.
- Fusionne `Carrière salarié` dans `Dossier salarié` sans retirer de fonctionnalité métier.
- Conserve niveau, XP, performance, réussites, échecs, formations, incidents, promotions et action de promotion dans la fiche unique.
- Masque le bouton `Carrière salarié` devenu redondant et redistribue l'espace entre les autres onglets Entreprise.
- Prépare la remise en miroir GitHub des sources Entreprise requises par la build joueur ; le miroir complet reste à certifier.
- F04.1 Recrutement reste validé en jeu. F04.2 Dossier salarié unifié devient le contrôle actif.

# 0.9.3.37 TEST - traçabilité des frais de recrutement F04

- Corrige le débit de 350 € lors d'un recrutement qui réduisait bien la trésorerie sans créer de ligne dans le relevé du compte professionnel.
- Le recrutement crée maintenant un mouvement bancaire `PAYROLL_RECRUITMENT_FEE` avec montant, solde après opération et nom du salarié.
- Le relevé professionnel affiche `Salarié recruté`, avec la catégorie de frais et le nom du salarié dans les tags.
- Ajoute un test de non-régression qui vérifie le débit et sa présence dans le relevé bancaire.
- F03 Banque reste validée. F04 Entreprise reste active jusqu'au retest du recrutement et de sa persistance.

# 0.9.3.36 TEST - horaires visibles dans Banque

- Affiche l'état ouvert ou fermé de la banque actuellement parcourue dans la page Banque.
- Les banques physiques suivent 08:00-12:00 / 14:00-18:00 selon l'heure du jeu.
- Les banques numériques affichent une disponibilité 24/7.
- Conserve les messages de sélection Banque/Conseiller sans chevauchement.
- F03 Banque validée en jeu sur cette build après contrôle banque fermée, banque ouverte, banque numérique et log propre.

# 0.9.3.35 TEST - correction interaction Banque et fluidité finale

- Corrige le blocage de tous les clics Banque en 0.9.3.34 causé par `tonumber(select(1, ...))` dans le wrapper des horaires opérationnels.
- Isole explicitement les varargs avant conversion afin que banque, conseiller, convention, prêt, découvert, refinancement et paiement fiscal ne puissent plus planter sur un second argument texte.
- Ajoute un garde de release qui interdit désormais tout motif `tonumber(select(...))` dans les sources Lua.
- La navigation AgriLife utilise le snapshot de démarrage léger mis en cache au lieu du snapshot Économie complet à chaque changement de page.
- Le snapshot de démarrage expose maintenant directement les champs nécessaires à la navigation UI sans synchroniser les comptes personnels ni recalculer tout le module Économie.
- La page Banque ne relit plus le snapshot Économie complet uniquement pour connaître l'état du tutoriel.
- Les états sélectionnés des boutons Banque/Conseiller sont mis en cache comme les textes, couleurs et visibilités afin d'éviter les invalidations GUI identiques.
- La confirmation d'une banque ne déclenche plus deux rafraîchissements synchrones en solo, et la confirmation du conseiller ne repeint plus toute l'application.
- F03 reste active. Test ciblé requis : confirmer banque, confirmer conseiller, signer convention, sauvegarder/recharger, puis vérifier le log sans `mouseEvent` AgriLife.

# 0.9.3.33 TEST - finition fluidité UI

- Le log 0.9.3.32 confirme un démarrage propre et un montage AgriLife d'environ 294 ms, sans erreur bloquante.
- Les rafraîchissements de page n'ont pas dépassé le seuil de 8 ms, mais un micro-freeze reste perceptible à haute fréquence d'affichage.
- Les helpers UI n'envoient plus `setText`, `setVisible`, `setDisabled`, `setImageColor` ou `setTextColor` lorsque la valeur demandée est déjà affichée.
- Les changements de page évitent ainsi les invalidations de layout et de rendu inutiles.
- Les icônes et étoiles ne sont plus réassignées lorsque leur texture et leur couleur sont inchangées.
- La navigation AgriLife possède maintenant une signature d'état et n'est repeinte que lorsque la page active ou les droits de progression changent réellement.
- Le profiler UI descend à 1,5 ms et distingue navigation, rafraîchissement de page et étapes d'ouverture du menu.
- Aucun changement de gameplay, d'économie ou de sauvegarde dans cette passe.

# 0.9.3.32 TEST - micro-optimisation UI

- Cache court des snapshots de démarrage et tableau de bord pour supprimer les requêtes répétées dans une même interaction.
- Le tutoriel utilise désormais l'état brut lorsqu'aucun guide actif n'a besoin du snapshot Économie complet.
- Cache court des permissions UI, de la simulation de prêt et du prêt principal pendant un rafraîchissement bancaire.
- Réutilisation du snapshot de convention bancaire dans les décorateurs de la page Banque.
- Snapshot de démarrage regroupé : une seule lecture Banque et une seule lecture Examen par interaction au lieu de réentrées répétées.
- Tableau de bord : suppression d'une seconde lecture Examen et cache résumé de 750 ms.
- Suivi carrière : les racines IA identiques ne sont plus parcourues plusieurs fois dans la même frame et les réaccrochages de compatibilité véhicules sont amortis par petits lots.
- CUMA : contrôle des réservations limité à deux fois par seconde, cohérent avec son horloge en minutes de jeu.
- Personnel : contrôle des horaires des ordres actifs limité à quatre fois par seconde au lieu d'une fois par frame.
- Télémétrie ciblée : tout rafraîchissement de page AgriLife supérieur ou égal à 8 ms est journalisé pour identifier le dernier gel résiduel.
- Aucun changement de gameplay ou de données financières dans cette passe.

## 0.9.3.31 - TEST

- Corrige les gels importants observés après le retour du menu AgriLife en 0.9.3.30.
- Supprime le double contrôle périodique qui reconstruisait les commandes du menu Finances jusqu'à deux fois par seconde.
- Les protections Finances, Contrats et réinitialisation vanilla s'installent désormais une seule fois puis cessent leur polling.
- Le tableau de bord n'exécute plus la comptabilité avancée bancaire à chaque rafraîchissement.
- La santé financière affichée utilise l'état mensuel déjà calculé au lieu de recalculer Banque, Paie, Entreprise, Juridique et Contrats à chaque repaint.
- Le snapshot courant des aides agricoles ne rescane plus toutes les parcelles à chaque ouverture de page.
- Le mode de difficulté affiché dans l'en-tête utilise le snapshot brut léger.
- Le contrôle Finalisation au démarrage devient léger. L'audit profond reste disponible uniquement à la demande.
- Supprime le second rafraîchissement complet du dashboard après le montage GUI.
- F03 reste active. Contrôle requis avant reprise Banque : absence de gels récurrents dans le menu ESC et log sans stack overflow.

## 0.9.3.30 - TEST

- Corrige le `stack overflow` 0.9.3.28/0.9.3.29 qui empêchait AgriLife Manager de se monter dans le menu ESC.
- Supprime la boucle Economy -> Administration -> Economy introduite par le calcul des aides agricoles.
- Ajoute une garde globale de réentrance sur les snapshots Economy avant tous les décorateurs de snapshot.
- Les consommateurs de difficulté Administration, Legal, Contrats et Banque utilisent désormais l'état brut de difficulté lorsqu'un snapshot complet n'est pas nécessaire.
- F03 reste active. Premier contrôle requis : chargement, icône AgriLife visible, ouverture/fermeture du menu et log sans stack overflow.

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
