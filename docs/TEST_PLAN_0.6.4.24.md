# Plan de test — AgriLife Manager 0.6.4.24 TEST

Objectif : reprendre exactement les problèmes observés lors du test du 10 août 2026 et valider la continuité de l’examen sans retourner dans les menus.

## Test principal — examen complet

1. Démarrer un examen avec un matériel compatible.
2. Vérifier que le HUD affiche en permanence **Étape X/10** et la consigne exacte, y compris en Difficile.
3. Après chaque étape, vérifier l’apparition pendant quelques secondes d’un panneau vert avec pictogramme de réussite.
4. Vérifier que ce panneau indique la prochaine consigne.
5. À l’étape 5/10, réaliser réellement le travail avec l’outil abaissé/actif. La progression doit avancer même si le véhicule/mod ne remonte pas correctement la surface WorkArea.
6. Lever l’outil et rouler : la progression de travail ne doit pas continuer artificiellement.
7. Poursuivre jusqu’à 6/10 puis 7/10.
8. À 7/10, ramener l’outil dans son cercle d’origine : l’étape doit se valider sans obligation de ressortir puis revenir.
9. À 8/10, dételer l’outil dans la zone demandée.
10. À 9/10, ramener et immobiliser le tracteur au point demandé.
11. À 10/10, respecter la consigne de sortie et vérifier la clôture de l’examen.
12. Vérifier le panneau final permis obtenu / examen non validé et la note finale.

## Erreurs

- Provoquer si possible une erreur contrôlée.
- Vérifier que le compteur augmente.
- Vérifier que la nature de la dernière erreur reste lisible après la notification temporaire.

## Sauvegarde / reprise

- Sauvegarder pendant un examen en cours.
- Quitter puis recharger la partie.
- Vérifier l’étape, le matériel assigné, la progression et la consigne HUD.

## Banque / onboarding

- Sur la page Banque, choisir une banque et un conseiller.
- Vérifier que la page Banque affiche une confirmation de sélection au lieu de demander immédiatement « Validez la société ».
- Revenir au tableau de bord : la prochaine étape obligatoire doit alors être Société lorsque la difficulté l’exige.

## Résultat attendu

La 0.6.4.24 n’est considérée comme validée que lorsque l’examen peut être mené de 1/10 à 10/10 sans blocage et sans devoir ouvrir le menu pour connaître la consigne.
