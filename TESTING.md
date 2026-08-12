# Tests - AgriLife Manager

Version de référence : **0.9.3.0 TEST**

## Principe

Une fonction peut être écrite et intégrée sans être certifiée en jeu. Les contrôles statiques éliminent les défauts évidents, mais la validation finale exige FS25, sauvegarde/rechargement, contrôle visuel et lecture du `log.txt`.

Le statut **ÉCRIT / À CERTIFIER** ne doit jamais être confondu avec **VALIDÉ EN JEU**.

## Feuille de route active

La campagne active suit `docs/FS25_TEST_ROADMAP_0.9.3.0.md`.

Ordre principal :

1. préparation commune ;
2. **Facile** ;
3. **Normal** ;
4. **Difficile** ;
5. comparaison directe des trois difficultés ;
6. compatibilités/maps ;
7. UI, langues, logs et décision finale.

Chaque difficulté possède un **GATE**. Tant qu’un défaut bloquant empêche ce gate de passer, la campagne ne continue pas vers la difficulté suivante.

## Périmètre prioritaire 0.9.3.0

En plus de toute la fermeture Atelier 8.1 de la 0.9.2.0, la certification doit maintenant couvrir :

- usure mécanique comportementale AgriLife et neutralisation de l’usure mécanique vanilla comme source de réparation ;
- séparation usure progressive / collision événementielle ;
- consommation carburant/énergie selon puissance, charge, régime, comportement, état mécanique et difficulté ;
- constat d’accident manuel pour un conducteur joueur et automatique pour un ouvrier IA ;
- décisions Assurance/Banque sensibles réservées au patron/propriétaire ;
- classement perte totale/épave avec acceptation explicite du patron ;
- horaires : Banque 08:00-12:00 / 14:00-18:00, concessionnaire 08:00-19:00, atelier personnel 24/7, usines 08:00-19:00, points de vente 08:00-12:00 / 14:00-18:00 ;
- sauvegarde/rechargement de tous les nouveaux états 0.9.3.0.

Le protocole historique A à Z reste disponible dans `docs/FS25_CERTIFICATION_A_TO_Z.md` pour les contrôles complémentaires.

## Multijoueur

La publication multijoueur reste désactivée. L’architecture multi-fermes est prévue, mais aucun statut public de compatibilité réseau ne doit être déclaré avant la campagne serveur dédiée.

## Critère de validation

Un scénario n’est **VALIDÉ EN JEU** que si le résultat correspond à l’attendu, que la persistance tient après reload lorsque nécessaire, que le `log.txt` ne montre pas d’erreur AgriLife liée au scénario et qu’aucune régression UI bloquante n’est observée.
