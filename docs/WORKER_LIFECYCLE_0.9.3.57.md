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
- `FIELDWORK`
- `RETURN_EQUIPMENT`
- `RETURN_VEHICLE`

Les transitions doivent être journalisées afin qu'un refus de l'IA FS25 soit identifiable directement dans `log.txt`.

## Référence externe à comparer

Le dépôt `LeGrizzly/FS25_EmployeeManager`, branche `fix/gui/refacto`, est autorisé par l'utilisateur comme référence et source de scripts réutilisables. Les parties prioritaires à étudier sont `JobManager`, `ParkingManager` et l'intégration des jobs IA `GOTO` / `FIELDWORK`.
