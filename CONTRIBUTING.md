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
- `ROADMAP.md` est un registre maître additif : ne jamais supprimer une idée validée lors d'une mise à jour.

## Cycle obligatoire d'une build

1. Modifier et vérifier la source active.
2. Exécuter les contrôles disponibles.
3. Mettre à jour l'état des points réellement intégrés dans la feuille de route complète, sans supprimer ni condenser les idées existantes.
4. Synchroniser cette feuille de route sur GitHub.
5. Copier la même feuille de route à jour dans `docs/ROADMAP.md` du mod.
6. Mettre à jour changelog, documentation, version et fichiers concernés.
7. Synchroniser les sources GitHub nécessaires.
8. Construire `FS25_AgriLifeManager.zip`.
9. Ré-extraire le ZIP et vérifier que `docs/ROADMAP.md` correspond à l'état GitHub de la build.
10. Exécuter les vérifications finales du package.
11. Seulement ensuite envoyer le ZIP au testeur.
12. Effectuer la certification en jeu lorsque le bloc est prêt.

**Un ZIP n'est pas considéré prêt à être envoyé si la feuille de route GitHub et la feuille de route embarquée dans le mod ne sont pas synchronisées avec la build.**

## Écriture et attribution

- Ne pas utiliser le caractère em dash dans les contenus du projet.
- Conserver une rédaction simple et cohérente.
- Ne pas ajouter d'attribution automatique ou de marque fournisseur dans les contenus publics.
- L'auteur public des éléments originaux reste Chez_Squall.

## Rapports de bugs

Indiquer si possible : version AgriLife, version FS25, map, difficulté, nouvelle/ancienne sauvegarde, étapes de reproduction, résultat attendu/obtenu, `log.txt` et mods susceptibles d'interagir.
