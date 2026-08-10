# Plan de test — AgriLife Manager

Ce document sert de point de reprise après chaque session de développement. Une fonctionnalité n’est considérée comme validée qu’après un test réel dans Farming Simulator 25.

## Build à tester

**0.6.4.24 TEST**

Statut : **prête pour test utilisateur — non encore validée en jeu**.

## 1 — Parcours de démarrage en Difficile

Vérifier l’ordre des étapes obligatoires sur le tableau de bord :

1. avant sélection bancaire : `CHOISIR LA BANQUE` ;
2. après banque, avant conseiller : `CHOISIR LE CONSEILLER` ;
3. après banque + conseiller : `CRÉER / VALIDER LA SOCIÉTÉ` ;
4. après société, si le permis est requis : `PASSER LE PERMIS`.

Chaque bouton doit ouvrir le module correspondant et ne doit pas déclencher une étape administrative différente de celle annoncée.

## 2 — HUD d’examen

Démarrer un examen et vérifier à chaque étape :

- affichage de `Étape X/10` ;
- affichage de l’action exacte à effectuer ;
- progression visible ;
- note visible ;
- erreurs visibles ;
- aucune nécessité de retourner dans Échap → Examens pour connaître la consigne.

Après réussite d’une étape :

- état visuel vert pendant quelques secondes ;
- pictogramme de réussite ;
- confirmation de l’étape validée ;
- apparition immédiate de la prochaine consigne.

## 3 — Épreuve 5 : cultivation / travail réel

C’est le test prioritaire de la 0.6.4.24.

1. utiliser un cultivateur compatible ;
2. l’abaisser et travailler réellement le sol ;
3. vérifier que la progression quitte 0 % et augmente ;
4. relever l’outil puis rouler : la progression doit s’arrêter ;
5. abaisser et reprendre le travail : la progression doit reprendre ;
6. continuer jusqu’à validation de l’étape 5.

Le moteur privilégie toujours la surface WorkArea réellement traitée. Le mécanisme de secours ne doit servir qu’aux outils compatibles réellement en position/état de travail lorsque le signal de surface n’est pas disponible.

## 4 — Étapes 6 à 10

Continuer l’examen complet après l’étape 5 et vérifier :

- sécurisation/fin du travail ;
- retour vers la zone demandée ;
- retour du matériel dans son cercle d’origine ;
- dételage si demandé ;
- stationnement/position finale ;
- sortie ou clôture finale de l’examen.

Pour le retour matériel, l’outil assigné doit être reconnu directement lorsqu’il se trouve réellement dans sa zone. Aucune sortie puis rentrée artificielle du cercle ne doit être nécessaire.

## 5 — Erreurs d’examen

Si possible, provoquer volontairement une faute contrôlée : mauvais champ ou dommage matériel.

Vérifier que :

- le compteur d’erreurs augmente ;
- la pénalité de note est appliquée ;
- la nature de la dernière erreur reste lisible après disparition de la notification temporaire ;
- l’information est toujours présente dans la page Examens.

## 6 — Sauvegarde / reprise

Pendant un examen en cours :

1. sauvegarder ;
2. quitter ;
3. recharger la sauvegarde ;
4. vérifier étape, progression, note, erreurs et dernière erreur ;
5. vérifier que le HUD reprend avec la bonne consigne.

## Retour attendu en cas de problème

Conserver :

- une capture d’écran montrant l’étape et le HUD ;
- le `log.txt` de la session ;
- une phrase décrivant précisément ce qui était fait au moment du blocage.

Cela permet de reprendre directement le diagnostic sans refaire toute la chaîne de tests.

---

**Auteur : Chez_Squall**  
**Build de référence : 0.6.4.24 TEST**
