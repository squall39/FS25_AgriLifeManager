# État de développement 0.7.0.0

La build 0.7.0.0 intègre le code des trois premières étapes de la feuille de route sans attendre la fin des tests en jeu.

## Code intégré

1. Démarrage : machine d'état centrale, migration, tutoriel, difficulté, banque, conseiller, examen et état prêt.
2. Interface de base : six modules joueur, navigation consolidée, redirections et affichage piloté par le snapshot Démarrage.
3. Banque : dette héritée séparée, prêts détaillés, historique filtrable, contrat bancaire, financement, prévision de trésorerie et checklist du module.

## Validation

Le code est intégré dans le package joueur et passe les contrôles statiques. Les cases de validation terrain de la feuille de route restent inchangées tant que les tests en jeu correspondants ne sont pas terminés.

Vérification statique actuelle : 91 XML, 79 Lua actifs, 146 callbacks, 210 contrôles, 27 langues et 4 831 clés l10n.

## Package joueur

Nom : `FS25_AgriLifeManager.zip`

SHA-256 : `ee6dbd9f7b841f61738ac601204c70144f6769a637d521e126ecf8e785514939`

## Source découpé

Les changements des étapes 1 à 3 sont disponibles dans `development/steps/`.

Les étapes 2 et 3 sont découpées en plusieurs parties. Le fichier `development/steps/README.md` donne les commandes de reconstruction et les sommes SHA-256 attendues.

Les assets binaires tiers du ZIP joueur ne sont pas automatiquement republiés dans le dépôt public tant que leurs droits de redistribution n'ont pas été vérifiés.
