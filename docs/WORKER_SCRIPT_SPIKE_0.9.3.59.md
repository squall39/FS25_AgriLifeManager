# Worker execution spike - 0.9.3.59

Branche de travail : `dev/workers-09359`.

Ce chantier reste volontairement isolé de `main` et n'est pas encore chargé par `modDesc.xml`. Il ne modifie donc pas la build 0.9.3.58 TEST utilisée pour les essais en jeu.

## Objectif

Préparer le moteur d'exécution physique des salariés Entreprise avec une machine à états claire :

`FETCH_EQUIPMENT -> TRANSIT_TO_FIELD -> FIELDWORK -> RETURN_EQUIPMENT -> RETURN_VEHICLE -> COMPLETE`

États de sortie supplémentaires : `FAILED` et `CANCELLED`.

## Script ajouté

`src/modules/enterprise/EnterpriseWorkerExecution09359.lua`

Le script couvre déjà :

- capture de la position et de l'orientation initiales du véhicule ;
- capture séparée de la position et de l'orientation de chaque équipement sélectionné ;
- mémorisation de l'état initial attelé ou non attelé ;
- réservation du véhicule pendant l'affectation ;
- préparation du véhicule avant un job IA ;
- transit vers le champ avec `AIJobType.GOTO` au-delà de 150 m ;
- lancement `AIJobType.FIELDWORK` avec démarrage direct à moins de 50 m ;
- retour du véhicule par `GOTO` vers sa position et son orientation d'origine ;
- suivi du job IA actif et transition au message `AI_JOB_STOPPED` ;
- libération de la réservation à la fin, en échec ou à l'annulation ;
- hooks pour la récupération et le retour du matériel sans location automatique et sans remplacement arbitraire du matériel choisi.

## Choix volontaire pour le matériel

Le script ne force pas encore l'attelage et le dételage lui-même. Les opérations `fetchEquipment` et `returnEquipment` passent par des callbacks d'intégration.

Ce choix est volontaire tant que la source exacte du coordinateur ouvrier de la build 0.9.3.58 n'est pas présente sur GitHub. Cela évite de brancher une API d'attelage supposée et de casser le matériel sélectionné par le joueur.

Chaque callback reçoit les objets sélectionnés avec leur pose d'origine et l'information `wasAttached`. Le coordinateur final pourra donc :

1. aller chercher uniquement le matériel qui n'était pas attelé ;
2. l'atteler sans substitution ;
3. après le travail, le ramener à sa pose d'origine ;
4. dételer uniquement ce qui était dételé au début ;
5. conserver attelé ce qui l'était déjà au départ.

## Points techniques confirmés pendant l'étude

Le callback FS25 `AI_JOB_STOPPED` reçoit le job et le message IA. Il faut associer le job à l'affectation AgriLife et ne jamais traiter les jobs d'autres systèmes.

Une attention particulière reste nécessaire pour l'arrêt manuel. Un message de type `OK` peut correspondre à un arrêt demandé par le joueur. L'intégration finale devra donc distinguer cet arrêt d'une vraie fin de travail avant d'accorder XP, réputation ou validation de tâche.

## Prochaine intégration

Quand le coordinateur 0.9.3.58 exact est disponible dans le dépôt, la suite prévue est :

1. brancher `EnterpriseWorkerExecution09359` sur le service Entreprise existant ;
2. relier les callbacks d'attelage et de restitution au matériel réellement sélectionné dans Planning ;
3. relier `AI_JOB_STOPPED` au moteur par référence de job ;
4. traiter explicitement l'arrêt manuel et les erreurs IA ;
5. charger le script dans une nouvelle build TEST ;
6. tester d'abord tracteur + cultivateur sur un champ à plus de 150 m ;
7. seulement après validation, tester moissonneuse + barre + chariot.

Aucune fonction de cette branche n'est considérée comme validée avant test réel dans Farming Simulator 25.
