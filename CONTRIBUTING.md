# Développement et contributions - AgriLife Manager

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

La feuille de route reste la référence. Une issue ou une contribution ne change pas automatiquement les priorités.

## Source active

La branche `main` doit contenir les vrais fichiers texte maintenables aux chemins utilisés par le package :

- `src/` ;
- `gui/` ;
- `translations/` ;
- `tests/` ;
- `tools/` ;
- `data/` ;
- Lua/XML publiables de `placeables/` et `vehicles/` ;
- `docs/` ;
- `modDesc.xml`.

Ne pas créer une seconde représentation permanente du code dans des dossiers de builds, patches ou copies de Lua.

## Règles de travail

- Conserver la compatibilité des sauvegardes autant que possible.
- Toute fonction visible doit utiliser l10n.
- Les 27 langues distribuées gardent le même jeu de clés.
- Les intégrations externes restent optionnelles.
- Chaque nouvelle fonction doit avoir une conséquence réelle en jeu.
- Ne pas retirer les copyrights ou licences tiers.
- Le package joueur conserve le nom `FS25_AgriLifeManager.zip`.
- La version reste inférieure à `1.0.0.0` avant validation globale.

## Cycle d'une build

1. Modifier la source active.
2. Exécuter les contrôles disponibles.
3. Mettre à jour changelog, documentation et feuille de route si nécessaire.
4. Synchroniser GitHub.
5. Construire le ZIP joueur séparément.
6. Ré-extraire et vérifier le ZIP.
7. Effectuer la certification en jeu lorsque le bloc est prêt.

## Écriture et attribution

- Ne pas utiliser le caractère em dash dans les contenus du projet.
- Conserver une rédaction simple et cohérente.
- Ne pas ajouter d'attribution automatique ou de marque fournisseur dans les contenus publics.
- L'auteur public des éléments originaux reste Chez_Squall.

## Rapports de bugs

Indiquer si possible : version AgriLife, version FS25, map, difficulté, nouvelle/ancienne sauvegarde, étapes de reproduction, résultat attendu/obtenu, `log.txt` et mods susceptibles d'interagir.
