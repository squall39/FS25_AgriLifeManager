# Développement

Ce dossier ne contient plus les patches découpés des builds courantes.

La source active doit être publiée directement à son emplacement réel dans le dépôt, par exemple `src/`, `gui/`, `translations/`, `tests/` ou `tools/`.

Les anciens patches des étapes 1 à 3 restent disponibles dans l'historique Git. Ils ne sont plus conservés dans l'arborescence active afin d'éviter d'avoir deux représentations concurrentes du même code.

## Règle de synchronisation

1. Modifier la source active.
2. Exécuter les contrôles statiques.
3. Mettre à jour la documentation et le changelog concernés.
4. Synchroniser les fichiers source réels sur GitHub.
5. Construire `FS25_AgriLifeManager.zip` séparément pour le test joueur.
6. Vérifier que le ZIP et GitHub décrivent la même version interne.

Les binaires ou composants tiers ne sont publiés dans Git que lorsque leurs droits de redistribution sont vérifiés.
