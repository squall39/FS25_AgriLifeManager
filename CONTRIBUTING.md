# Développement et contributions - AgriLife Manager

AgriLife Manager est un projet public en développement actif. Le dépôt sert à suivre la source, la documentation et les retours sans modifier la feuille de route fonctionnelle.

## Ordre de référence

1. Démarrage
2. Interface de base
3. Banque
4. Entreprise
5. Carrière & Qualifications
6. Administration
7. Contrats & Marchés
8. Atelier
9. Finalisation

La feuille de route reste la référence pour le contenu et les validations. Une issue ou une contribution ne modifie pas automatiquement les priorités.

## Source active

La branche `main` doit contenir les vrais fichiers source à leurs chemins réels.

- `src/` : Lua actif
- `gui/` : interface XML
- `translations/` : localisation
- `tests/` : contrôles
- `tools/` : vérification et packaging
- `docs/` : documentation
- `development/` : notes de chantier uniquement

Les patches de build, copies de fichiers et archives découpées ne doivent pas devenir une seconde représentation permanente du code. L'historique Git suffit pour conserver les anciennes versions.

## Règles de travail

- Conserver la compatibilité des sauvegardes autant que possible.
- Toute fonction visible par le joueur doit utiliser l10n.
- Les langues distribuées doivent conserver le même jeu de clés.
- Les intégrations Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres restent optionnelles.
- Ne pas introduire de dépendance obligatoire inutile.
- Chaque fonction doit avoir une conséquence réelle en jeu.
- Ne pas retirer les copyrights ou licences des composants tiers.
- Les assets tiers ne sont publiés que si leur redistribution est autorisée.
- Le package joueur conserve le nom `FS25_AgriLifeManager.zip`.
- La version reste inférieure à `1.0.0.0` tant que les grands systèmes ne sont pas terminés et validés.

## Cycle d'une build

1. Modifier la source active.
2. Contrôler XML, Lua, callbacks, ressources et l10n.
3. Mettre à jour le changelog et la documentation concernés.
4. Synchroniser les fichiers source modifiés sur GitHub.
5. Construire le ZIP joueur séparément.
6. Vérifier la version interne et l'intégrité du ZIP.
7. Effectuer les tests en jeu nécessaires.

Une build n'est pas annoncée comme totalement synchronisée si le ZIP contient des modifications de source absentes de `main`.

## Fichiers exclus

Ne pas versionner les sauvegardes FS25, logs, crash dumps, caches, secrets, archives de travail, backups et fichiers temporaires. Le `.gitignore` couvre ces catégories.

## Écriture et attribution

- Ne pas utiliser le caractère em dash dans les contenus du projet.
- Conserver une rédaction simple et cohérente.
- Ne pas ajouter d'attribution technique automatique ou de marque fournisseur dans les commits, PR, releases, documentation, commentaires de code ou textes en jeu.
- L'auteur public des éléments originaux du projet reste Chez_Squall.

## Retours et bugs

Pour un bug, fournir si possible :

- version AgriLife Manager ;
- version Farming Simulator 25 ;
- map ;
- difficulté ;
- nouvelle partie ou sauvegarde existante ;
- étapes de reproduction ;
- résultat attendu ;
- résultat obtenu ;
- `log.txt` de la session ;
- mods susceptibles d'interagir.

Avant de publier un log, retirer les données personnelles ou chemins locaux identifiables qui ne sont pas nécessaires au diagnostic.
