# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier et systèmes de gestion associés.

## État courant

- Version source synchronisée : **0.7.8.0 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : préparé mais désactivé tant que la campagne réseau n'est pas certifiée
- Package joueur : `FS25_AgriLifeManager.zip`

### Feuille de route

La feuille de route complète est conservée dans `ROADMAP.md` et fonctionne désormais comme **registre maître additif** : les idées validées ne sont jamais supprimées lors d'une mise à jour. Une mise à jour de feuille de route modifie uniquement l'état des points déjà prévus, ou ajoute une nouvelle idée explicitement validée.

- Étapes 1 à 3 : intégrées, campagne de validation à terminer.
- Étape 4 Entreprise : écriture complète, certification en jeu à faire.
- Étape 5 Carrière & Qualifications : écriture complète, certification des examens et qualifications à faire.
- Étape 6 Administration : écriture complète, certification en jeu à faire.
- Étape 7 Contrats & Marchés : prochaine passe dédiée.
- Étape 8 Atelier : fondations présentes, passe dédiée à faire.
- Étape 9 Finalisation : fermeture globale et campagne A -> Z.

Voir `ROADMAP.md` pour le détail complet de toutes les idées conservées.

## Organisation du dépôt

Le dépôt publie la source texte maintenable du mod aux mêmes chemins que le package lorsque cela est pertinent :

- `src/` : Lua actif ;
- `gui/` : XML et définitions texte d'interface ;
- `translations/` : l10n ;
- `tests/` : contrôles ;
- `tools/` : vérification de release ;
- `data/`, `placeables/`, `vehicles/` : configurations et scripts texte publiables ;
- `docs/` : documentation technique ;
- `modDesc.xml` : descripteur de la version source courante.

Les gros assets binaires et contenus tiers ne sont publiés que lorsque leurs droits de redistribution sont vérifiés.

## Règles de développement

- Trois difficultés uniquement : **Facile / Normal / Difficile**.
- Chaque fonctionnalité doit avoir une conséquence réelle en jeu.
- Les systèmes ne doivent pas être dupliqués entre modules.
- Courseplay, AutoDrive, Precision Farming, Soil Fertilizer et autres intégrations restent optionnels.
- Les contenus maps/multifruits sont détectés dynamiquement lorsque FS25 le permet.
- Les 27 langues distribuées doivent garder le même jeu de clés l10n.
- La version reste sous `1.0.0.0` tant que les grands systèmes ne sont pas terminés et validés.

## État de validation

La présence du code sur GitHub signifie qu'il est **écrit et intégré**, pas qu'il est automatiquement certifié dans FS25. Les étapes 4, 5 et 6 nécessitent encore leur campagne de certification en jeu.

© 2026 Chez_Squall.
