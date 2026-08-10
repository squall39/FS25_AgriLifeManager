# Changelog — AgriLife Manager

Toutes les évolutions importantes du projet sont consignées ici.

## 0.6.4.27 TEST

- Banque : correction ciblée du rendu des petits pictogrammes internes observé en 1920×1080.
- Création d’un jeu d’icônes Banque dédié dans `gui/bankicons` : fond transparent, glyphes normalisés et lisibles à petite taille.
- Les nouvelles icônes Banque sont isolées afin de ne pas modifier le rendu des pictogrammes utilisés par les autres écrans.
- DDS Banque recompressés en DXT5 avec mipmaps.
- Correction du libellé `Banque partenaire`, qui était tronqué en `Banque par...`.
- Aucun changement de logique bancaire ni de schéma de sauvegarde.
- Vérification statique : **OK — 89 XML, 59 Lua actifs, 129 callbacks, 206 contrôles, 6 ressources modDesc, 73 références de ressources XML**.
- **Statut : build prête pour revalidation visuelle de Banque, Financement et Relevé pro.**

## 0.6.4.26 TEST

- Correction complémentaire du blocage de l’étape **6/10** observé en jeu avec la 0.6.4.25.
- L’étape 6 valide désormais l’action réellement demandée au candidat : **équipement arrêté et relevé**. Le repliage n’est plus un prérequis bloquant, car plusieurs outils FS25/moddés peuvent rester déployés après relevage.
- La correction fonctionne directement sur une sauvegarde déjà bloquée à l’étape 6/10.
- Ajout d’un diagnostic `Secure-state` dans `log.txt` indiquant `operating`, `lowered`, `folded`, `foldable` et `scenarioMatch` dès que l’état détecté change.
- Vérification statique : **OK — 89 XML, 59 Lua actifs, 129 callbacks, 206 contrôles, 6 ressources modDesc, 73 références de ressources XML**.
- Aucun changement de schéma de sauvegarde requis.
- **Statut : examen 1→10, obtention du permis, rechargement et isolation entre sauvegardes validés en jeu le 10 août 2026.**

## 0.6.4.25 TEST

- Correction du blocage de l’étape **6/10** après la validation du travail : l’étape valide désormais directement l’état sécurisé réel de l’outil (**arrêté, relevé et replié si nécessaire**) au lieu d’exiger d’observer artificiellement un nouvel état abaissé/actif après l’étape 5.
- La correction fonctionne aussi lors de la reprise d’une sauvegarde déjà bloquée à l’étape 6/10.
- Le log de test du 10 août confirme que l’étape 5/10 atteint bien **100 %** puis est validée avant le passage à l’étape 6.
- Le message de réussite d’une étape reste affiché **8 secondes** au lieu de 4,5 secondes.
- Ajout d’une notification FS25 explicite lors de chaque étape validée avec le numéro de l’épreuve réussie et la consigne suivante, en complément du mini-HUD vert.
- `gui/icons/success.dds` recompressé en DXT5 afin d’éviter l’avertissement de texture brute observé au moment de la transition.
- Vérification statique : **OK — 89 XML, 59 Lua actifs, 129 callbacks, 206 contrôles, 6 ressources modDesc, 73 références de ressources XML**.
- Aucun changement de schéma de sauvegarde requis.
- **Statut : remplacée pour ce test par la 0.6.4.26 TEST.**

### Personnel — conception conservée, implémentation après stabilisation

La séparation **joueur humain / GPS natif / salariés AgriLife**, la règle **1 salarié disponible = 1 tâche active maximum**, la paie unique AgriLife et le futur centre d’ordres restent validés dans `docs/WORKFORCE_DESIGN.md`. Leur implémentation ne doit pas interrompre la stabilisation actuelle des examens, du HUD, de la persistance, de l’onboarding et des difficultés.

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
- **Statut : à revalider en jeu sur la chaîne complète des examens.**

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
