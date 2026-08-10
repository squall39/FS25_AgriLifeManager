# Développement & contributions — AgriLife Manager

Le dépôt AgriLife Manager est public afin de rendre le développement, la documentation et les retours plus accessibles. Le projet reste toutefois en **développement actif** et les builds actuelles sont des builds TEST.

## Règles de travail

- Conserver la compatibilité de sauvegarde autant que possible.
- Toute modification majeure doit être documentée dans le tutoriel initial et dans Échap → Assistance.
- Les nouvelles fonctions doivent être testées sur une partie propre et, si nécessaire, sur une sauvegarde existante migrée.
- Les intégrations Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres doivent rester optionnelles.
- Ne pas introduire de dépendance obligatoire inutile.
- Conserver l’auteur du projet sous le nom **Chez_Squall**.
- Ne jamais retirer les copyrights/licences des composants tiers.
- Avant une build TEST importante : contrôler XML, Lua, l10n, assets référencés, intégrité du ZIP et persistance de sauvegarde.
- Les nouvelles fonctions doivent avoir une conséquence réelle en jeu et ne pas être de simples éléments décoratifs de menu.
- Les nouvelles chaînes visibles par le joueur doivent utiliser l10n et être ajoutées à toutes les langues distribuées.

## Retours, bugs et idées

Les issues GitHub peuvent être utilisées pour signaler un bug ou proposer une idée.

Pour un bug, fournir autant que possible :

- version AgriLifeManager ;
- version de Farming Simulator 25 ;
- map utilisée ;
- difficulté AgriLife ;
- nouvelle partie ou sauvegarde existante ;
- étapes exactes pour reproduire le problème ;
- résultat attendu et résultat obtenu ;
- `log.txt` de la session concernée ;
- liste des mods susceptibles d’interagir avec le problème.

Un rapport reproductible accompagné du log est prioritaire sur un simple message du type « ça ne marche pas ».

## Contributions de code

Le dépôt étant public, les propositions techniques peuvent être discutées via une issue avant d’engager une grosse modification. Une modification ne doit pas casser l’architecture, les sauvegardes ou les principes validés dans `ROADMAP.md`.

Les grosses refontes doivent idéalement être isolées afin de rester faciles à tester et à relire.

## Convention de version

Tant qu’AgriLife Manager n’est pas terminé, la version reste **inférieure à 1.0.0.0**.

Les versions intermédiaires peuvent porter le suffixe conceptuel `TEST` dans les noms de package de développement, mais le numéro déclaré dans le mod doit rester conforme au format FS25.

## Branches

Pendant la phase actuelle :

- `main` : base de travail validée ;
- des branches dédiées pourront être utilisées pour les grosses refontes ou contributions importantes.

## Tests

Après chaque correction significative, conserver un plan de test court et reproductible afin de valider uniquement la fonction modifiée avant de poursuivre.

Les tests prioritaires doivent couvrir, selon la modification :

- nouvelle partie ;
- reprise de sauvegarde existante ;
- les trois difficultés Facile / Normal / Difficile ;
- fonctionnement sans mods tiers ;
- compatibilités concernées ;
- absence d’erreur pertinente dans `log.txt`.

## Références

Avant toute contribution importante, consulter :

- `ROADMAP.md` ;
- `FEATURES.md` ;
- `docs/WORKFORCE_DESIGN.md` lorsque le Personnel est concerné ;
- `docs/DYNAMIC_ECONOMY_AGRONOMY.md` pour les marchés, multifruits, Precision Farming et Soil Fertilizer ;
- `COPYRIGHT.md` pour les règles de copyright et de distribution.
