# Tests - AgriLife Manager

Version de référence : **0.9.2.0 TEST**

## Principe

Une fonction peut être écrite et intégrée sans être certifiée en jeu. Les contrôles statiques, audits Python et specs Lua éliminent les défauts évidents, mais la validation finale exige FS25, sauvegarde/rechargement, contrôle visuel et lecture du `log.txt`.

Le statut **ÉCRIT / À CERTIFIER** ne doit jamais être confondu avec **VALIDÉ EN JEU**.

## Feuille de route active de la campagne de test

La campagne 0.9.2.0 doit suivre `docs/FS25_TEST_ROADMAP_0.9.2.0.md`.

Cette feuille de route est volontairement séparée de `ROADMAP.md` : elle ne décrit pas les fonctions à développer, mais uniquement **l’ordre de certification en jeu**.

Ordre obligatoire de la campagne principale :

1. préparation commune ;
2. **Facile** — validation fonctionnelle générale avec contraintes minimales ;
3. **Normal** — banque/conseiller obligatoires et permis provisoire ;
4. **Difficile** — permis/assurance obligatoires, verrous et conséquences renforcées ;
5. comparaison directe des trois difficultés ;
6. compatibilités/maps ;
7. UI, langues, logs et décision finale.

Chaque difficulté possède un **GATE**. Tant qu’un bug bloquant empêche ce gate de passer, la campagne ne continue pas vers la difficulté suivante.

## Périmètre 0.9.2.0 prioritaire

La certification doit couvrir en particulier la fermeture Atelier 8.1 :

- véhicules, automoteurs, remorques, outils, accessoires, chargeurs et masses/poids ;
- pannes légères, immobilisantes et casses lourdes ;
- verrou réel du redémarrage ;
- kit terrain limité aux urgences ;
- dépannage/remorquage et choix de destination ;
- commandes et palettes physiques de pièces ;
- huiles et lubrifiants ;
- réparation personnelle et concessionnaire ;
- délai personnel de 2 à 3 fois celui du concessionnaire selon atelier/compétence ;
- matériel de remplacement concessionnaire et location de secours ;
- assurance mécanique, assistance/remorquage, franchise et dépenses réellement engagées ;
- absence du camion de service joueur.

## Certification complémentaire

Le protocole historique détaillé A à Z reste disponible dans `docs/FS25_CERTIFICATION_A_TO_Z.md` pour les scénarios complémentaires et les contrôles de profondeur. En cas de divergence d’ordre, la campagne active 0.9.2.0 suit d’abord `docs/FS25_TEST_ROADMAP_0.9.2.0.md`.

## Multijoueur

L’infrastructure réseau existe mais la publication multijoueur reste désactivée. Aucun scénario multi ne doit faire passer le statut public à compatible tant que la certification réseau dédiée n’a pas été réalisée.

## Critère de validation d’un scénario

Un scénario n’est marqué **VALIDÉ EN JEU** que si :

1. le résultat observé correspond au résultat attendu ;
2. la sauvegarde/recharge ne casse pas l’état concerné lorsqu’il est persistant ;
3. le `log.txt` ne contient pas d’erreur Lua liée au mod ;
4. aucune régression UI bloquante n’est observée ;
5. les preuves minimales utiles sont conservées.

## Règle de roadmap

Une case de `ROADMAP.md` exigeant une validation terrain reste ouverte tant que la certification FS25 correspondante n’a pas été effectuée, même si son code est déjà écrit.
