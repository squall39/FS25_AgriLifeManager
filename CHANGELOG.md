# 0.9.3.57 TEST

- Entreprise Planning : première implémentation du cycle physique des ouvriers avec l'IA native FS25.
- L'ouvrier mémorise la position initiale du véhicule et du matériel affecté avant le départ.
- Si un outil affecté n'est pas déjà attelé, l'ouvrier se déplace vers son emplacement, le prend puis lance le travail de champ.
- Une fois le travail terminé, tout matériel pris par l'ouvrier est ramené à son emplacement de départ, dételé puis repositionné avec précision si le véhicule est arrivé suffisamment près.
- Le véhicule revient ensuite à son propre emplacement de départ avant que l'ordre soit marqué terminé.
- Les équipements déjà attelés avant l'affectation restent attelés au retour.
- Ajout d'une journalisation détaillée des phases FETCH_EQUIPMENT, FIELDWORK, RETURN_EQUIPMENT et RETURN_VEHICLE pour diagnostiquer précisément un refus de l'IA FS25.
- GitHub synchronisé après validation de la passe locale.

# 0.9.3.56 TEST

- Entreprise Planning : un seul bouton d'action est conservé dans la vue Planning. Le bouton d'en-tête est masqué, le gros bouton du panneau de droite devient l'unique action Planifier / Annuler.
- Entreprise Planning : le bouton du panneau de droite est maintenant réellement actif pour créer une nouvelle affectation lorsqu'aucune affectation n'existe pour le salarié sélectionné.
- Entreprise Planning : la disponibilité tient désormais compte des ordres de travail déjà actifs en plus de la file d'attente, afin d'éviter un bouton visuellement disponible suivi d'un refus ou d'une réservation en double.
- Entreprise Planning : la logique anti-doublon existante de la file reste active pour le salarié, le véhicule, l'outil principal et le matériel complémentaire.

# 0.9.3.55 TEST

- XP Carrière : la détection Récolte reçoit un second signal basé sur l'entrée réelle de grain dans la trémie de la moissonneuse.
- XP Carrière : lorsque FS25 fournit le rendement du fruit, le gain réel de trémie est converti en surface récoltée pour conserver la progression en XP par hectare.
- XP Carrière : le signal exact WorkArea reste prioritaire et bloque le repli trémie afin d'éviter le double comptage.
- XP Carrière : sur une culture ou un multifruit sans rendement exploitable, la trémie active au champ force au minimum le HUD sur Récolte sans inventer de points XP.
- XP Carrière : aucun repli trémie n'est comptabilisé pendant un examen agricole et aucune récolte d'examen n'est reportée après sa fin.
- Examen Récolte : comportement 0.9.3.54 conservé après retour test positif, les incohérences restantes seront traitées uniquement sur cas précis.

# 0.9.3.54 TEST

- Entreprise Planning : le panneau Planning des travaux affiche maintenant les vignettes FS25 du véhicule, de l'outil principal et du matériel complémentaire réellement affectés.
- Entreprise Planning : le bloc récapitulatif en bas de page est masqué dans la vue Planning afin de supprimer les informations en double.
- Entreprise Planning : pour Récolte, les deux sélecteurs deviennent BARRE DE COUPE et CHARIOT DE COUPE. Les chariots porte-coupe compatibles sont proposés comme matériel complémentaire.
- Entreprise Planning : une affectation est maintenant lancée automatiquement dès sa création. La file réessaie ensuite si l'automatisation FS25 est temporairement indisponible.
- Entreprise Planning : nettoyage défensif des doublons de réservation dans la file de travaux afin qu'un salarié, un véhicule, un outil ou un matériel complémentaire ne reste pas affecté deux fois.

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

