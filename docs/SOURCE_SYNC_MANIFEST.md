# Synchronisation du source GitHub

Version de reference : **0.9.3.23 TEST**
Date : **13 aout 2026**

La build ZIP joueur 0.9.3.23 reste la reference executable utilisee dans Farming Simulator 25 pendant la campagne de test.

## Etat 0.9.3.23

- F01 : validee en jeu ;
- F02 : validee en jeu en 0.9.3.23 ;
- F03 : active, Banque fonctionnelle ;
- `modDesc.xml` et `src/core/AgriLifeVersion.lua` sont en 0.9.3.23 ;
- le correctif F02 du tableau de bord est present sur `main` ;
- `ROADMAP.md`, `docs/ROADMAP.md` et `TESTING.md` enregistrent la fermeture de F02 ;
- les fichiers temporaires de synchronisation ont ete retires de `main`.

## Gaps historiques encore ouverts

`main` ne doit pas etre presente comme miroir octet par octet tant que tous les fichiers du ZIP ne sont pas verifies sur le depot.

Le controle du 13 aout 2026 confirme que le repertoire `translations/` distribue dans la build ZIP n est pas encore present sur `main`. Le fichier `tools/verify_release.py` distribue dans la build n est pas encore present non plus.

Ces ecarts restent ouverts jusqu a presence et verification reelles des chemins concernes.

## Regles de synchronisation

- la version du depot et la version de test doivent etre identifiees clairement ;
- toute difference entre `main` et la build doit etre signalee ;
- les anciens fichiers temporaires ne restent pas sur `main` ;
- aucun tiret cadratin dans les contenus du projet.
