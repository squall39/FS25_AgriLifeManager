# F03 Banque - horaires visibles - 0.9.3.36 TEST

## Objectif

Afficher l'état d'ouverture de la banque actuellement parcourue sans masquer les messages de sélection, de verrouillage ou de confirmation.

## Comportement attendu

- banque physique : horaires 08:00-12:00 / 14:00-18:00 ;
- état ouvert en vert pendant une plage d'ouverture ;
- état fermé en orange hors plage d'ouverture ;
- banque numérique : ouverte 24/7 ;
- le statut suit la banque affichée avec les flèches avant même sa confirmation ;
- l'heure utilisée est l'heure du jeu FS25.

## Test ciblé F03

1. Ouvrir AgriLife Manager puis Banque.
2. Parcourir plusieurs banques physiques avec les flèches.
3. Vérifier l'affichage des horaires et de l'état ouvert ou fermé.
4. Parcourir une banque numérique et vérifier 24/7.
5. Changer l'heure du jeu pour tester une plage fermée, par exemple entre 12:00 et 14:00 ou après 18:00.
6. Vérifier que les messages de verrouillage et de confirmation Banque/Conseiller restent lisibles.
7. Sauvegarder, quitter et contrôler le log.

F03 reste active jusqu'à validation réelle dans Farming Simulator 25.
