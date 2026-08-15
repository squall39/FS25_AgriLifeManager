# Cycle ouvrier - 0.9.3.57 TEST

## Objectif

Une affectation Entreprise doit devenir un vrai cycle physique et non une simple entrée de planning.

## Cycle attendu

- Enregistrer la position et l'orientation initiales du véhicule.
- Enregistrer la position et l'orientation initiales de chaque équipement sélectionné.
- Conserver la distinction entre matériel déjà attelé et matériel à aller chercher.
- Utiliser l'IA native FS25 pour les déplacements lorsque possible.
- Aller chercher puis atteler les équipements requis qui ne sont pas déjà attachés.
- Se rendre au champ et lancer le travail réel correspondant à l'affectation.
- À la fin du travail, retourner chaque équipement emprunté à sa position initiale et le dételer.
- Ne pas dételer un équipement qui était déjà attelé avant l'affectation.
- Ramener le véhicule à sa position initiale et arrêter le cycle.
- Ne marquer l'ordre TERMINÉ qu'après le retour du véhicule et du matériel.

## Phases de diagnostic

- `FETCH_EQUIPMENT`
- `TRANSIT_TO_FIELD`
- `FIELDWORK`
- `RETURN_EQUIPMENT`
- `RETURN_VEHICLE`

Les transitions doivent être journalisées afin qu'un refus de l'IA FS25 soit identifiable directement dans `log.txt`.

## Référence autorisée : EmployeeManager

Dépôt étudié : `LeGrizzly/FS25_EmployeeManager`, branche `fix/gui/refacto`.

Éléments à réutiliser ou adapter :

- `JobManager:startFieldWork` : préparation du véhicule, validation du matériel puis séparation du trajet et du travail.
- Pour un champ éloigné, création d'un job `AIJobType.GOTO`, validation puis démarrage par `g_currentMission.aiSystem:startJob`.
- Après le trajet, création séparée d'un job `AIJobType.FIELDWORK` avec `applyCurrentState`, `positionAngleParameter`, `setValues` et `validate` avant démarrage.
- `JobManager:update` : machine d'états simple permettant de chaîner TRANSIT -> FIELDWORK -> RETURN_TO_PARKING.
- `ParkingManager` : enregistrement persistant de `x/y/z/angle`, association à un véhicule et retour par un job GOTO.
- `ParkingManager:autoRecordSpot` : mémorisation automatique de l'emplacement actuel au moment de l'affectation d'un véhicule.
- `HelperNameExtension` : possibilité ultérieure d'afficher le nom du salarié comme nom d'aide FS25 pendant un job.

## Adaptations nécessaires pour AgriLife

Ne pas recopier le système tel quel. AgriLife doit conserver ses règles plus strictes :

- ne jamais louer automatiquement un outil si le joueur en a explicitement affecté un ;
- aller réellement chercher un outil éloigné au lieu de l'atteler à distance ;
- mémoriser séparément la position de chaque outil, barre de coupe et chariot ;
- retourner chaque équipement emprunté à sa propre position et orientation initiales ;
- conserver attaché tout équipement qui l'était déjà avant l'affectation ;
- inspecter le message d'arrêt du job et différencier réussite, échec et annulation au lieu de considérer toute disparition du job comme une réussite ;
- empêcher les doubles réservations du salarié, du véhicule et de tous les équipements ;
- garder la logique AgriLife de sauvegarde et de planning comme source de vérité.

## Direction 0.9.3.58

La prochaine passe doit reprendre surtout le modèle `GOTO -> FIELDWORK -> GOTO retour` d'EmployeeManager et le combiner avec le cycle de restitution déjà écrit dans AgriLife. L'objectif prioritaire est de résoudre le cas actuel où une affectation est créée correctement mais où l'ouvrier ne met pas physiquement le véhicule en mouvement.
