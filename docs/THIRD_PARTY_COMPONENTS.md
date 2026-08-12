# Composants tiers et compatibilités

AgriLife Manager doit rester autonome et ne doit pas embarquer le code d'un mod tiers sans autorisation de redistribution explicite.

## Intégrations optionnelles

| Intégration | Utilisation AgriLife | Code tiers embarqué |
|---|---|---|
| Courseplay | Détection et exécution optionnelle par capacités | Non |
| AutoDrive | Détection et exécution optionnelle par capacités | Non |
| Precision Farming | Lecture optionnelle de données agronomiques accessibles | Non |
| Soil Fertilizer | Lecture optionnelle de données sol/intrants accessibles | Non |
| MudSystem | Lecture optionnelle de données disponibles, notamment pneus et contraintes | Non |
| Advanced Damage System | Lecture optionnelle des états mécaniques disponibles | Non |

## Règles

- aucune dépendance dure à un mod tiers ;
- aucune copie de logique propriétaire lorsque l'intégration peut être réalisée par API, spécialisation ou détection de capacités ;
- fallback AgriLife lorsque le fournisseur n'est pas présent ;
- une incompatibilité externe doit désactiver seulement l'enrichissement concerné ;
- les assets binaires tiers ne sont redistribués que si leurs droits le permettent explicitement.

Avant une publication publique, toute ressource externe ajoutée au package doit être recensée ici avec son origine et son droit de redistribution.
