# Synchronisation du source GitHub

Version de reference : **0.9.3.22 TEST**
Date : **13 aout 2026**

La build ZIP joueur reste la reference executable utilisee dans Farming Simulator 25 pendant la campagne de test. La branche `main` est en cours de conversion vers un miroir complet du mod dezippa.

## Synchronisation 0.9.3.22

- version runtime et package portees a `0.9.3.22` ;
- correction F02 du tableau de bord et de la carte Banque integree ;
- `Dashboard6Service.lua`, `F02Clarity0920.lua` et `WorkshopPartHudIcons.lua` font partie du source actif ;
- changelog, protocole de test et etat projet actualises ;
- le memo personnel reste local et ne doit jamais etre publie sur GitHub.

## Gaps historiques encore ouverts

`main` ne doit pas etre presente comme miroir octet par octet tant que tous les fichiers actifs du ZIP ne sont pas verifies sur le depot. Les gaps historiques peuvent encore concerner des traductions, ressources GUI, textures, vehicules, placeables ou autres actifs binaires utiles au package.

Aucun gap n est considere ferme tant que le chemin correspondant n est pas reellement present et verifie sur `main`.

## Regles de synchronisation

- la version GitHub et la version de test doivent etre identifiees clairement ;
- toute difference entre `main` et la build doit etre signalee ;
- Git conserve l historique, les anciennes copies inutiles ne restent pas sur `main` ;
- aucun tiret cadratin ;
- aucune attribution automatique ou marque de generateur dans les contenus du projet.

## Etat test

F01 reste validee. F02 reste active. La 0.9.3.22 est auditee statiquement et doit etre certifiee dans Farming Simulator 25 avant ouverture de la phase Banque fonctionnelle.
