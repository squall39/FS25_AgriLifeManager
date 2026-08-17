# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier, assurances, leasing, occasion et systèmes de gestion associés.

## État courant

- Version de travail : **0.9.3.97 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : infrastructure prévue, publication désactivée tant que la campagne réseau n'est pas certifiée
- Package de test : `FS25_AgriLifeManager.zip`
- Correctif actif : staging natif puis accostage d'attelage en boucle fermée
- Validation FS25 prioritaire : Louise Martin + MT635 + cultivateur 980 + champ 45

## Feuille de route

`ROADMAP.md` reste le registre maître additif du projet. Une idée validée ne doit pas disparaître lors d'une mise à jour.

Le cycle de travail reste : correction -> test ciblé en jeu -> validation complète -> phase suivante.

## GitHub

La branche `main` contient la source active et la documentation utiles au développement. Les archives de transfert, backups, logs, sauvegardes et anciens rapports ponctuels ne doivent pas rester dans la branche principale.

Le ZIP reste l'artefact utilisé pour les tests FS25 et la distribution. Une synchronisation GitHub confirme l'alignement du source, pas la validation fonctionnelle dans Farming Simulator 25.

## Organisation

- `src/` : code Lua actif
- `gui/` : interface et ressources UI publiables
- `translations/` : localisation
- `data/` : configurations
- `vehicles/` et `placeables/` : contenu source publiable du package
- `tests/` : contrôles automatisés
- `tools/` : audits et packaging
- `docs/` : documentation technique active

## Règles de développement

- Chaque fonctionnalité doit avoir une conséquence réelle en jeu.
- Une fonction non validée dans FS25 reste à certifier.
- Les intégrations externes restent optionnelles.
- Les 27 langues distribuées gardent le même jeu de clés.
- La version reste sous `1.0.0.0` tant que le projet n'est pas entièrement certifié.
- Aucun tiret cadratin dans les contenus du projet.
- Aucune attribution automatique à une IA ou à un fournisseur dans les contenus publics.

© 2026 Chez_Squall.
