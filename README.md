# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier, concessionnaire, assurances et systèmes de gestion associés.

## État courant

- Version source synchronisée : **0.9.0.0 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : infrastructure écrite mais désactivée tant que la campagne réseau n'est pas certifiée
- Package joueur : `FS25_AgriLifeManager.zip`

### Feuille de route

La feuille de route complète est conservée dans `ROADMAP.md` et fonctionne comme **registre maître additif** : les idées validées ne sont jamais supprimées lors d'une mise à jour. Une mise à jour de feuille de route modifie uniquement l'état des points déjà prévus, précise leur avancement ou ajoute une nouvelle idée explicitement validée.

- Étapes 1 à 3 : intégrées, avec plusieurs points historiques avancés encore à compléter et/ou certifier.
- Étape 4 Entreprise : écriture complète, certification en jeu à faire.
- Étape 5 Carrière & Qualifications : écriture complète, certification en jeu à faire.
- Étape 6 Administration : écriture complète, certification en jeu à faire.
- Étape 7 Contrats & Marchés : écriture complète, certification en jeu à faire.
- Étape 8 Atelier, Concessionnaire & Gestion technique du parc : écriture complète, certification en jeu à faire.
- Étape 9 Finalisation : infrastructure de finalisation écrite et intégrée, certification globale à faire.

Voir `ROADMAP.md` pour le détail complet de toutes les idées conservées.

## Finalisation 0.9.0.0

La build 0.9.0.0 ajoute le schéma de sauvegarde 4, la migration 3 vers 4, l'identité de carrière, le suivi de récupération backup, les audits de persistance et de compatibilité, l'isolation multi-fermes, un squelette réseau serveur autoritaire non publié, le tutoriel paginé rebasé, les audits l10n/publication, la documentation utilisateur et un packaging TEST/PUBLIC reproductible.

Le multijoueur reste volontairement `supported=false` tant que sa certification réelle n'est pas terminée.

## Organisation du dépôt

Le dépôt publie la source texte maintenable du mod aux mêmes chemins que le package lorsque cela est pertinent :

- `src/` : Lua actif ;
- `gui/` : XML et définitions texte d'interface ;
- `translations/` : l10n ;
- `tests/` : contrôles ;
- `tools/` : vérification et packaging ;
- `data/`, `placeables/`, `vehicles/` : configurations et scripts texte publiables ;
- `docs/` : documentation technique et utilisateur ;
- `modDesc.xml` : descripteur de la version source courante.

Les gros assets binaires et contenus tiers ne sont publiés que lorsque leurs droits de redistribution sont vérifiés.

## Règles de développement

- Trois difficultés uniquement : **Facile / Normal / Difficile**.
- Chaque fonctionnalité doit avoir une conséquence réelle en jeu.
- Les systèmes ne doivent pas être dupliqués entre modules.
- Courseplay, AutoDrive, Precision Farming, Soil Fertilizer, MudSystem et les systèmes mécaniques tiers restent optionnels.
- Les contenus maps/multifruits sont détectés dynamiquement lorsque FS25 le permet.
- Les 27 langues distribuées doivent garder le même jeu de clés l10n.
- La version reste sous `1.0.0.0` tant que les grands systèmes ne sont pas terminés et validés.

## État de validation

La présence du code sur GitHub signifie qu'il est **écrit et intégré**, pas qu'il est automatiquement certifié dans FS25. Les étapes 4 à 9 nécessitent encore leur campagne de certification en jeu et les étapes 1 à 3 conservent des finitions historiques prévues par la roadmap.

© 2026 Chez_Squall.
