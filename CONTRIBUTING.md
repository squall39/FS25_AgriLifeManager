# Développement & contributions - AgriLife Manager

Le dépôt AgriLife Manager est public afin de rendre le développement, le code source original, la documentation et les retours plus accessibles. Le projet reste toutefois en **développement actif**.

## Règle de priorité

**Le passage du dépôt en public ne change pas l’ordre de travail AgriLifeManager.**

L’ordre officiel reste celui défini dans `ROADMAP.md` :

1. Démarrage ;
2. Interface de base ;
3. Banque ;
4. Entreprise ;
5. Carrière & Qualifications ;
6. Administration ;
7. Contrats & Marchés ;
8. Atelier ;
9. Finalisation.

Un bloc est terminé et validé avant d’ouvrir le suivant.

Une issue, une proposition ou une pull request publique ne devient donc pas automatiquement prioritaire. Elle doit rester cohérente avec l’architecture, les décisions validées et le programme de test.

## Règles de travail

- Conserver la compatibilité de sauvegarde autant que possible.
- Toute modification majeure doit être documentée dans le tutoriel initial et dans Échap → Assistance lorsque ces éléments sont concernés.
- Les nouvelles fonctions doivent être testées sur une partie propre et, si nécessaire, sur une sauvegarde existante migrée.
- Les intégrations Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres doivent rester optionnelles.
- Ne pas introduire de dépendance obligatoire inutile.
- Conserver l’auteur du projet sous le nom **Chez_Squall**.
- Ne jamais retirer les copyrights ou licences des composants tiers.
- Avant une build importante : contrôler XML, Lua, l10n, assets référencés, intégrité du ZIP et persistance de sauvegarde.
- Les nouvelles fonctions doivent avoir une conséquence réelle en jeu et ne pas être de simples éléments décoratifs de menu.
- Les nouvelles chaînes visibles par le joueur doivent utiliser l10n et être ajoutées à toutes les langues distribuées.
- Les archives livrées utilisent le nom `FS25_AgriLifeManager.zip`.
- Le numéro de version reste inférieur à `1.0.0.0` tant que les grands systèmes ne sont pas terminés et validés.

## Style d’écriture

Règle stricte pour tout contenu du projet : commits, PR, releases, README, docs, commentaires de code, textes en jeu, changelog et notes de build.

- Ne jamais utiliser le caractère em dash.
- Utiliser un tiret normal, une virgule, des parenthèses, deux-points ou une phrase séparée.
- Relire ou scanner le texte avant publication.

## Attribution

- Ne jamais ajouter `Generated with...`.
- Ne jamais ajouter `Co-Authored-By:` pour un assistant ou fournisseur d’IA.
- Ne jamais ajouter de lien, nom de modèle ou nom de fournisseur d’IA dans les commits, PR, releases, README, documentation, commentaires de code ou textes en jeu.
- Le projet et ses éléments originaux restent attribués à **Chez_Squall**.

Voir `docs/WRITING_AND_ATTRIBUTION.md`.

## Retours, bugs et idées

Les issues GitHub peuvent être utilisées pour signaler un bug, proposer une idée ou soumettre une contribution.

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

Avant de joindre un `log.txt`, vérifier qu’il ne contient pas d’information personnelle que vous ne souhaitez pas rendre publique, notamment un nom de session Windows ou un chemin local identifiable.

Un rapport reproductible accompagné du log est prioritaire sur un simple message du type « ça ne marche pas ».

## Contributions de code

Les propositions techniques peuvent être discutées via une issue avant d’engager une grosse modification.

Une modification ne doit pas casser l’architecture, les sauvegardes ou les principes validés dans `ROADMAP.md`.

Les grosses refontes doivent idéalement être isolées afin de rester faciles à tester, comparer, rebaser et relire.

Une contribution préparée sur une ancienne build doit être **rebasée sur le référentiel courant** avant intégration. Elle ne doit pas écraser des clés l10n, fichiers ou comportements ajoutés depuis sa préparation.

La publication du source original par Chez_Squall est autorisée sur ce dépôt. Les composants et assets tiers restent soumis à leurs propres droits et conditions de redistribution : voir `COPYRIGHT.md` et `SOURCE_PUBLICATION.md`.

## Traductions

Toute contribution l10n doit respecter :

- même jeu de clés dans toutes les langues distribuées ;
- aucun doublon ;
- aucune valeur vide volontaire ;
- placeholders strictement conservés ;
- XML valide ;
- aucune chaîne joueur importante codée en dur ;
- comparaison avec la langue de référence réellement courante avant fusion.

La contribution suivie dans l’issue GitHub #2 doit être rebasée avant intégration, car le jeu de clés du projet a continué à évoluer après sa préparation.

## Convention de version

Tant qu’AgriLife Manager n’est pas terminé, la version reste **inférieure à 1.0.0.0**.

Le package joueur reste nommé `FS25_AgriLifeManager.zip`. Les numéros de version apparaissent dans les métadonnées et le changelog, pas dans le nom du ZIP livré.

## Branches

Pendant la phase actuelle :

- `main` : base publique de travail ;
- des branches dédiées peuvent être utilisées pour les grosses refontes ou contributions importantes.

La présence d’un fichier ou d’une documentation sur `main` ne suffit pas à affirmer que la dernière build locale complète est synchronisée. Cette synchronisation doit être vérifiée explicitement.

## Tests

La méthode privilégiée est de développer un **bloc cohérent complet**, puis de le tester comme un vrai cycle de gameplay.

Les micro-tests intermédiaires sont réservés aux mécanismes transversaux critiques comme :

- sauvegarde et rechargement ;
- onboarding ;
- accès véhicule ;
- synchronisation ;
- migration ;
- autre infrastructure capable de bloquer tout le mod.

Les tests doivent couvrir, selon la modification :

- nouvelle partie ;
- reprise de sauvegarde existante ;
- Facile / Normal / Difficile ;
- fonctionnement sans mods tiers ;
- compatibilités concernées ;
- absence d’erreur pertinente dans `log.txt`.

## Références

Avant toute contribution importante, consulter :

- `ROADMAP.md` ;
- `FEATURES.md` ;
- `SOURCE_PUBLICATION.md` ;
- `docs/WRITING_AND_ATTRIBUTION.md` ;
- `docs/WORKFORCE_DESIGN.md` lorsque Entreprise est concernée ;
- `docs/DYNAMIC_ECONOMY_AGRONOMY.md` pour les marchés, multifruits, Precision Farming et Soil Fertilizer ;
- `COPYRIGHT.md` pour les règles de copyright et de distribution.
