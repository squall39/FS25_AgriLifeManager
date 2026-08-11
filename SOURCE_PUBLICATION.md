# Publication du source - AgriLife Manager

## Statut

Le dépôt `squall39/FS25_AgriLifeManager` est le dépôt public officiel de développement d'AgriLife Manager.

Chez_Squall autorise la publication du code source et des fichiers originaux du projet dans ce dépôt.

## Organisation

La source active doit être publiée directement à son chemin réel. La branche `main` ne doit plus utiliser des patches découpés comme représentation principale d'une build.

Structure de référence :

- `modDesc.xml` pour la déclaration FS25 ;
- `src/` pour Lua ;
- `gui/` pour l'interface ;
- `translations/` pour la localisation ;
- `tests/` pour les contrôles ;
- `tools/` pour la vérification et le packaging ;
- `docs/` pour la documentation ;
- `development/` pour les notes de chantier uniquement.

Voir `docs/REPOSITORY_LAYOUT.md`.

## Synchronisation

Une livraison de développement n'est considérée comme synchronisée que lorsque le ZIP local, les fichiers source publiés et la documentation décrivent la même version interne.

La présence d'un numéro de version dans la documentation ne suffit pas à prouver que tous les fichiers de la build locale sont physiquement présents sur GitHub. La synchronisation doit être vérifiée avant de l'annoncer comme complète.

Les fichiers sources ajoutés ou modifiés pendant le développement doivent être publiés à leur chemin réel dès que possible, au lieu de créer une copie dans un dossier de patches.

## Archives et fichiers locaux

Ne pas versionner :

- `FS25_AgriLifeManager.zip` dans la branche source ;
- sauvegardes FS25 et backups ;
- `log.txt` et crash dumps ;
- secrets et identifiants ;
- caches ;
- archives et fichiers temporaires.

Le package jouable est construit séparément de la branche source.

## Assets et composants tiers

Les fichiers originaux AgriLife Manager peuvent être publiés avec l'autorisation de Chez_Squall.

Les assets ou composants tiers restent soumis à leurs droits, licences et conditions de redistribution. Leur présence dans une build locale ne constitue pas une autorisation automatique de republication sur GitHub.

Les binaires tiers ne sont ajoutés au dépôt qu'après vérification de leur statut.

## Validation

Le dépôt source et le ZIP peuvent contenir du code non encore validé en jeu. Une synchronisation GitHub confirme l'état du code, pas sa validation fonctionnelle.

La feuille de route reste la source de vérité pour les tests et validations.

## Versions

La numérotation reste inférieure à `1.0.0.0` tant que les grands systèmes ne sont pas terminés et validés.

Le package joueur conserve toujours le nom `FS25_AgriLifeManager.zip`.

L'auteur public du projet reste Chez_Squall.
