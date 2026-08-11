# AgriLife Manager - Farming Simulator 25

AgriLife Manager ajoute à FS25 une couche complète de gestion de carrière agricole : banque, entreprise, carrière et qualifications, administration, contrats et marchés, atelier, économie, réputation, comptabilité et conséquences persistantes.

**Auteur : Chez_Squall**  
**Plateforme cible : PC**  
**Statut : développement pré-1.0**  
**Version interne courante : 0.7.0.0**

## Structure du projet

La branche `main` est organisée autour de la source active, pas autour de copies de patches de build.

- `modDesc.xml` : déclaration FS25 et ordre de chargement des scripts.
- `src/` : code Lua actif.
- `gui/` : interface XML lorsqu'elle est publiée dans le dépôt.
- `translations/` : traductions et clés l10n lorsqu'elles sont synchronisées.
- `tests/` : contrôles du projet.
- `tools/` : vérification et packaging.
- `docs/` : documentation technique et conception.
- `development/` : notes de chantier uniquement.

Les anciens patches découpés des étapes 1 à 3 ont été retirés de l'arborescence active. Ils restent consultables dans l'historique Git. Le code courant est publié directement à son chemin réel.

Voir [Organisation du dépôt](docs/REPOSITORY_LAYOUT.md).

## Architecture joueur

Le tableau de bord regroupe exactement six modules :

1. Banque
2. Entreprise
3. Carrière & Qualifications
4. Administration
5. Contrats & Marchés
6. Atelier

Démarrage, Interface et Finalisation sont des blocs transversaux et ne sont pas des modules joueur.

## Démarrage

Trois difficultés sont prévues :

| Niveau | Capital de départ | Règle principale |
|---|---:|---|
| Facile | 200 000 € | Banque et permis facultatifs, accès véhicule libre. |
| Normal | 100 000 € | Banque et conseiller obligatoires, permis provisoire de 3 mois. |
| Difficile | 50 000 € | Banque et conseiller obligatoires, examen requis avant conduite normale. |

La logique de l'étape 1 est isolée dans `src/modules/economy/EconomyStartupRoadmap1.lua`. Elle expose une machine d'état commune pour migration, tutoriel, difficulté, banque, conseiller, examen et carrière prête.

## Interface

L'étape 2 est publiée dans `src/ui/AgriLifeInterface6.lua`.

Elle consolide les six modules joueur, les redirections de navigation, les onglets désactivés et l'affichage piloté par l'état réel du Démarrage.

## Banque

L'étape 3 est publiée dans `src/modules/bank/BankRoadmap3.lua`.

Elle complète la couche Banque avec dette FS25 héritée séparée, détail des prêts, historique filtrable, contrat bancaire, analyse de financement, prévision de trésorerie et checklist du module.

## État de la build 0.7.0.0

Le package joueur correspondant est nommé `FS25_AgriLifeManager.zip`.

Dernière vérification statique locale :

- 91 XML
- 80 Lua actifs
- 146 callbacks
- 210 contrôles
- 27 langues
- 4 831 clés l10n

SHA-256 du ZIP local correspondant : `45a66c117f1525418409c2917d20a1e68ebaf5058425e8240745c6737946d6d2`.

Les tests en jeu ne sont pas considérés comme terminés par cette synchronisation.

## Source public et assets

Chez_Squall autorise la publication dans ce dépôt du code source et des fichiers originaux AgriLife Manager.

Les composants ou assets tiers restent soumis à leurs propres droits. Un fichier présent dans une build locale n'est pas automatiquement publiable dans le dépôt. Les gros binaires ne sont ajoutés que lorsque leur origine et leur droit de redistribution sont vérifiés.

Le dépôt GitHub représente le développement source. Il ne transforme pas automatiquement un commit en build officielle prête à jouer.

Voir [Publication du source](SOURCE_PUBLICATION.md) et [Copyright et distribution](COPYRIGHT.md).

## Méthode de synchronisation

Pour chaque build :

1. modifier la source active ;
2. exécuter les contrôles statiques ;
3. mettre à jour la documentation utile ;
4. synchroniser les vrais fichiers source sur GitHub ;
5. construire `FS25_AgriLifeManager.zip` ;
6. vérifier que GitHub et le ZIP décrivent le même état interne.

Les archives, sauvegardes, logs et fichiers temporaires sont exclus par `.gitignore`.

## Feuille de route

Ordre de référence :

**Démarrage -> Interface de base -> Banque -> Entreprise -> Carrière & Qualifications -> Administration -> Contrats & Marchés -> Atelier -> Finalisation**

La feuille de route reste la source de vérité pour le contenu fonctionnel et les validations : [ROADMAP.md](ROADMAP.md).

## Documentation

- [Feuille de route](ROADMAP.md)
- [Fonctionnalités](FEATURES.md)
- [Organisation du dépôt](docs/REPOSITORY_LAYOUT.md)
- [Publication du source](SOURCE_PUBLICATION.md)
- [Personnel et main-d'oeuvre](docs/WORKFORCE_DESIGN.md)
- [Économie dynamique et agronomie](docs/DYNAMIC_ECONOMY_AGRONOMY.md)
- [Changelog](CHANGELOG.md)
- [Contributions](CONTRIBUTING.md)
- [Copyright](COPYRIGHT.md)

© 2026 Chez_Squall. Tous droits réservés sur les éléments originaux d'AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.
