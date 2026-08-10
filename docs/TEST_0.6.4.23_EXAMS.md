# Test ciblé — 0.6.4.23 TEST — Examens

Retour externe reçu sur la map **Le Méchet** (ModHub) : après une récolte, l'étape 7/10 demandait de ramener le matériel dans le cercle de retour, mais la validation pouvait rester bloquée même avec le matériel dans la zone. Le compteur d'erreurs pouvait également augmenter sans conserver clairement la nature de l'erreur affichée.

## Correction 0.6.4.23

- L'étape 7 valide maintenant la position réelle de l'outil assigné dans le cercle de retour.
- Plus besoin de ressortir artificiellement de la zone puis d'y revenir pour armer l'étape.
- La dernière erreur d'examen reste visible dans le HUD et dans la page Examens.
- Causes actuellement détaillées : dommage matériel et mauvais champ travaillé.
- La dernière erreur est persistée dans la sauvegarde et synchronisée dans le snapshot d'examen.
- Le correctif est générique et ne contient aucun traitement spécifique à Le Méchet.

## Test demandé

1. Lancer un examen de récolte ou avec outil attelé.
2. Atteindre l'étape 7/10.
3. Ramener l'outil assigné dans le cercle affiché : passage attendu à 8/10.
4. Vérifier qu'aucune sortie/rentrée artificielle de la zone n'est nécessaire.
5. Provoquer si possible un léger dommage ou travailler volontairement un mauvais champ.
6. Vérifier que la nature de la dernière erreur reste lisible après la notification temporaire.
7. Sauvegarder/recharger pendant l'examen et reprendre le test.

**Auteur : Chez_Squall**
