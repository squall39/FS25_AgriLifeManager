# Cycle ouvrier - 0.9.3.58 TEST

## But de cette passe

Résoudre le cas où une affectation Entreprise est créée correctement mais où l'ouvrier ne met pas physiquement le véhicule en mouvement vers le champ.

## Référence technique autorisée

Étude de `LeGrizzly/FS25_EmployeeManager`, branche `fix/gui/refacto`, avec autorisation de réutilisation communiquée par l'utilisateur.

Les éléments utiles identifiés sont surtout :

- `scripts/managers/jobmanager.lua` : séparation explicite du transit et du travail ;
- `scripts/managers/parkingmanager.lua` : mémorisation de position et orientation puis retour par job GOTO ;
- `scripts/extensions/HelperNameExtension.lua` : idée optionnelle pour afficher plus tard le nom du salarié comme aide FS25.

## Différence importante avec la 0.9.3.57

La 0.9.3.57 lançait le job `FIELDWORK` directement après la prise du matériel, même lorsque le véhicule se trouvait loin du champ.

La 0.9.3.58 ajoute un vrai état `TRANSIT_TO_FIELD` :

1. `FETCH_EQUIPMENT` si du matériel doit être récupéré ;
2. `TRANSIT_TO_FIELD` avec `AIJobType.GOTO` si le champ est à plus de 150 m ;
3. `FIELDWORK` une fois le véhicule arrivé près du champ ;
4. `RETURN_EQUIPMENT` pour chaque équipement emprunté ;
5. `RETURN_VEHICLE` pour replacer le véhicule à son point de départ.

## Démarrage FIELDWORK

Le job de travail de champ utilise désormais le démarrage direct FS25 quand le véhicule est déjà à proximité. Le paramètre `applyCurrentState` reçoit cet état de démarrage direct afin d'éviter de demander au job FIELDWORK d'assurer à lui seul un long trajet depuis la ferme.

Avant chaque job IA, AgriLife tente aussi de :

- démarrer le moteur ;
- libérer le frein ;
- désactiver le régulateur ;
- journaliser si l'IA est réellement active après l'appel à `startJob`.

## Règles AgriLife conservées

Les comportements d'EmployeeManager ne sont pas repris aveuglément :

- pas de location automatique d'un outil de remplacement ;
- pas de substitution du matériel choisi par le joueur ;
- chaque outil, barre ou chariot affecté garde sa propre position d'origine ;
- le matériel qui n'était pas attelé au départ doit être rendu puis dételé à son emplacement initial ;
- le matériel déjà attelé au départ reste attelé au retour ;
- le véhicule revient à son emplacement initial ;
- les réservations anti-doublons d'AgriLife restent la source de vérité ;
- l'arrêt d'un job est interprété avec le message IA pour distinguer réussite et échec.

## Test demandé

Premier test : tracteur + cultivateur sur un champ situé à plus de 150 m.

Le log attendu doit montrer successivement, selon la configuration :

`FETCH_EQUIPMENT` -> `TRANSIT_TO_FIELD` -> `FIELDWORK` -> `RETURN_EQUIPMENT` -> `RETURN_VEHICLE`.

Deuxième test seulement après validation : moissonneuse + barre de coupe + chariot.
