# Changelog — AgriLife Manager

Toutes les évolutions importantes du projet seront consignées ici.

## 0.6.4.24 TEST

- Correction du blocage de l’épreuve 5/10 : la surface WorkArea exacte reste prioritaire, mais un outil compatible réellement abaissé, en fonctionnement ou en traitement WorkArea peut désormais faire progresser l’épreuve par une preuve de travail/distance de secours.
- Le simple déplacement avec l’outil relevé ne doit pas valider l’épreuve de travail.
- Le HUD conserve maintenant l’action exacte à réaliser même en difficulté Difficile ; il ne se réduit plus au seul nom de l’activité.
- Chaque étape réussie déclenche pendant quelques secondes un état HUD vert avec pictogramme de réussite et la consigne de l’étape suivante.
- Le correctif 0.6.4.23 du retour du matériel dans son cercle d’origine est conservé.
- La dernière erreur d’examen reste visible après la notification temporaire.
- Le tableau de bord suit maintenant réellement la séquence obligatoire : Banque → Conseiller → Société → Permis. Le bouton d’action ouvre Banque ou Examens lorsque c’est l’étape attendue.
- Les pictogrammes restent volontairement au cœur de l’identité visuelle AgriLife ; ils ne sont pas destinés à être supprimés.
- Tutoriel et Assistance synchronisés avec le nouveau comportement du HUD d’examen en FR, EN, IT, chinois simplifié et chinois traditionnel.
- Aucun changement de schéma de sauvegarde requis.
- **Statut : build prête pour tests, pas encore validée en jeu.**

## 0.6.4.23 TEST

- Correction de l’étape 7/10 des examens : le retour du matériel se valide désormais lorsque l’outil assigné est réellement dans son cercle de retour, sans obligation artificielle de ressortir de la zone puis d’y revenir.
- Correction applicable à toutes les cartes compatibles FS25, sans traitement spécifique à Le Méchet.
- La nature de la dernière erreur d’examen reste visible dans le HUD et sur la page Examens : dommage matériel ou mauvais champ.
- La dernière erreur est maintenant sauvegardée et synchronisée.
- Tutoriel et Assistance mis à jour avec ce comportement.

## 0.6.4.22 TEST

- Différenciation initiale des profils de banques et de conseillers.
- Étoiles de réputation et compétence affichées dans Banque.
- Base du relevé du compte professionnel.
- Poursuite de la refonte UI Banque.
- Poursuite des tests du moteur de décision de crédit.

## 0.6.4.21 TEST

- Ajustements Banque et interface.
- Préparation de la différenciation des banques/conseillers.

## 0.6.4.20 TEST

- Auteur corrigé en Chez_Squall.
- Ajout des mentions de copyright et de distribution dans les fichiers de documentation et d’accueil.

## 0.6.4.19 TEST

- Le délai d’étude des demandes de crédit suit désormais l’horloge de jeu FS25 plutôt que le temps réel.
- Nettoyage d’anciens pictogrammes/artefacts UI.

## Versions antérieures

Les versions 0.6.4.x antérieures correspondent aux phases successives de restructuration d’AgriLife Manager : persistance par sauvegarde, migration, Banque, carrière/XP, examens, société, personnel, assurances, atelier, tutoriel et Assistance.

> Ce changelog sera complété progressivement à partir des builds conservées et des commits GitHub.
