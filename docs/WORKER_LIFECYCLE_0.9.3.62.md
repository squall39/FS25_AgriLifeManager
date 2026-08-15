# Worker lifecycle 0.9.3.62 TEST

## Origine du correctif

Le test FS25 de la 0.9.3.61 confirme que le cycle ouvrier atteint bien la phase `FETCH_EQUIPMENT`, crée un job IA natif et active momentanément l'IA. Le trajet vers le John Deere 980 placé dans le hangar est ensuite refusé par FS25 comme cible inaccessible. Le log répète `fetch_drive_failed` à environ 16,7 m du matériel.

Le blocage n'est donc plus la résolution du champ, le salarié, le véhicule ou le Dispatch. Il se situe dans la stratégie de récupération physique d'un outil stationné dans une zone que la navigation IA ne peut pas cibler proprement.

## Stratégie 0.9.3.62

- Un équipement local situé à moins de 50 m du véhicule est considéré comme matériel de cour et n'impose plus un `GOTO` vers son emplacement exact.
- Un équipement plus éloigné conserve un trajet d'approche, avec un point cible arrêté à 15 m de son origine.
- Le transit séparé vers le champ n'est utilisé qu'au-delà de 150 m.
- À 150 m ou moins, AgriLife lance directement le vrai `FIELDWORK` FS25. Le démarrage direct reste réservé à une proximité inférieure à 50 m.
- Après le travail et le retour du véhicule, le matériel local emprunté est dételé puis replacé exactement à la transformation enregistrée au début de l'ordre.
- Les échecs IA restent surveillés et journalisés par phase.

## Test ciblé

1. Laisser le John Deere 980 dételé dans le hangar.
2. Affecter Hugo au MT635 ou au 3650.
3. Sélectionner le 980, `Travail du sol` et le champ 4.
4. Lancer la planification puis ne plus intervenir pendant au moins 20 secondes.
5. Vérifier l'absence du message `cible inaccessible` pendant la récupération du 980.
6. Vérifier dans le log la ligne `yard equipment picked up=980`.
7. Vérifier ensuite le départ réel du tracteur et le démarrage du travail du champ.
8. La validation complète du cycle ne sera acquise qu'après retour du tracteur et remise du 980 à son emplacement d'origine.

Statut : TEST, validation FS25 requise.
