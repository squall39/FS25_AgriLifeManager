# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier et systèmes de gestion associés.

## État courant

- Version source synchronisée : **0.7.8.0 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : préparé mais désactivé tant que la campagne réseau n'est pas certifiée
- Package joueur : `FS25_AgriLifeManager.zip`

### Feuille de route

- Étapes 1 à 3 : intégrées, campagne de validation à terminer.
- Étape 4 Entreprise : écriture complète, certification en jeu à faire.
- Étape 5 Carrière & Qualifications : écriture complète, certification des examens et qualifications à faire.
- Étape 6 Administration : écriture complète, certification en jeu à faire.
- Étape 7 Contrats & Marchés : prochaine passe dédiée.
- Étape 8 Atelier : fondations présentes, passe dédiée à faire.
- Étape 9 Finalisation : fermeture globale et campagne A -> Z.

Voir `ROADMAP.md` pour le détail.

## Organisation du dépôt

Le dépôt publie la source texte maintenable du mod aux mêmes chemins que le package lorsque cela est pertinent :

- `src/` : Lua actif ;
- `gui/` : XML et définitions texte d'interface ;
- `translations/` : l10n ;
- `tests/` : contrôles ;
- `tools/` : vérification de release ;
- `data/`, `placeables/`, `vehicles/` : configurations et scripts texte publiables ;
- `docs/` : documentation technique ;
- `modDesc.xml` : version et chargement FS25.

Les gros assets binaires du ZIP ne sont pas automatiquement dupliqués dans le dépôt public. Voir `SOURCE_PUBLICATION.md`.

## Principes du projet

- Trois difficultés uniquement : Facile, Normal et Difficile.
- Chaque fonction importante doit avoir une conséquence réelle en jeu.
- La réputation appartient au module Entreprise et est consultée par les autres modules.
- Les intégrations Courseplay, AutoDrive, Precision Farming, Soil Fertilizer et autres restent optionnelles.
- Le projet évite les listes fixes de maps/cultures quand l'API FS25 permet une détection dynamique.
- Toutes les chaînes joueur utilisent l10n.
- La version reste inférieure à 1.0.0.0 avant validation globale.

## Validation

Une fonction peut être écrite et intégrée sans être encore certifiée en jeu. Les contrôles statiques et tests Lua ne remplacent pas une campagne FS25 réelle avec sauvegarde/rechargement et lecture du `log.txt`.

## Contribution et publication

Consulter :

- `CONTRIBUTING.md`
- `TESTING.md`
- `SOURCE_PUBLICATION.md`
- `COPYRIGHT.md`

© 2026 Chez_Squall.
