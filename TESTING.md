# Tests - AgriLife Manager

Version de référence : **0.7.9.0 TEST**

## Principe

Une fonction peut être écrite et intégrée sans être certifiée en jeu. Les tests Lua et contrôles statiques servent à éliminer les défauts évidents, mais la validation finale exige FS25, sauvegarde/rechargement et contrôle du `log.txt`.

## Contrôles de la build 0.7.9.0

- fonctionnalités générales : **64 assertions** ;
- Entreprise : **159 assertions** ;
- Carrière & Qualifications : **71 assertions** ;
- Administration : **76 assertions** ;
- Contrats & Marchés : **103 assertions** ;
- Lua actifs : **93** ;
- Lua du package syntaxiquement contrôlés : **100** ;
- XML : **91** ;
- callbacks UI : **161** ;
- contrôles UI : **217** ;
- langues : **27** ;
- clés l10n : **4 961 par langue**.

## Certification terrain différée

Les étapes 4, 5, 6 et 7 sont écrites et intégrées mais restent à certifier. La certification devra couvrir au minimum :

- nouvelle partie et sauvegarde existante ;
- sauvegarde/rechargement ;
- Facile / Normal / Difficile ;
- absence d'erreur Lua dans `log.txt` ;
- comportements réels des salariés, permis, administration, contrats et marchés ;
- fonctionnement sans mods tiers ;
- compatibilités optionnelles lorsqu'elles sont présentes ;
- maps vanilla, modmaps et multifruits pour Contrats & Marchés.

## Règle de roadmap

Une case de `ROADMAP.md` qui exige une validation terrain reste ouverte tant que la certification FS25 n'a pas été effectuée, même si son code est déjà écrit.
