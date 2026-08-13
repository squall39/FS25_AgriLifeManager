# État de synchronisation AgriLife Manager

Date de reprise : **13 août 2026**  
Version de référence actuelle : **0.9.3.13 TEST**  
Build joueur : `FS25_AgriLifeManager_0.9.3.13_UI_ENTERPRISE_WORKSHOP_FIX.zip`  
SHA-256 build : `60c0be2f728c96dcabc19ed83d69c6b05c0325f4bc41c6084c16d76b56cf4a48`

## Règle de travail

Une phase est terminée uniquement après : **correction -> test ciblé en jeu -> validation complète -> phase suivante**. Les fonctions non testées en jeu restent à certifier.

## Situation actuelle

- F01 : **validée en jeu** ; ne pas la rejouer.
- F02 / stabilisation et cohérence de l'interface : **toujours active**.
- Le gel de la souris sur la page Banque a été corrigé et validé à partir de la 0.9.3.9.
- Les pictogrammes principaux ont été harmonisés et les carrés blancs de la Banque supprimés.
- Le guidage contextuel a été remis en place sans réintroduire le gel du panneau.
- La Banque affiche le conseiller actif ; le tableau de bord doit également afficher banque + conseiller + réputation/compétence.
- Entreprise, Administration, Contrats et Atelier ont reçu plusieurs corrections de lisibilité et de chevauchement.
- La 0.9.3.13 ajoute les icônes HUD/store du matériel dans Entreprise/Atelier/occasion, bloque l'embauche multiple d'un même candidat et nettoie les vues détaillées Entreprise.

## Ce qui reste à valider à la prochaine reprise

1. Retest visuel de **0.9.3.13 uniquement** : Entreprise (toutes les vues), Contrats, Atelier, marché de l'occasion et Banque.
2. Vérifier qu'aucune vue Entreprise ne chevauche encore le profil salarié.
3. Vérifier qu'un candidat déjà embauché ne peut plus être recruté une seconde fois et qu'un nouveau candidat distinct est proposé.
4. Vérifier les icônes HUD/store du matériel dans Entreprise, Atelier et marché de l'occasion.
5. Vérifier la lisibilité des boutons Banque du bas et le résumé Banque du tableau de bord (nom du conseiller + étoiles réputation/compétence).
6. Envoyer uniquement les captures des défauts restants et le log si erreur Lua/comportement anormal.

## Phase suivante

**Ne pas démarrer la phase Banque fonctionnelle tant que F02 n'est pas entièrement propre.** Une fois F02 validée, la Banque sera testée par petits blocs : partenaire/conseiller -> simulation de crédit -> demande/décision -> remboursement/restructuration -> persistance.

## Source de vérité

La build ZIP 0.9.3.13 ci-dessus reste la référence exécutable exacte pour les tests FS25. GitHub conserve l'état de travail, les sources déjà synchronisées et ce dossier de reprise ; la synchronisation massive des binaires de la build n'est pas assimilée à une certification en jeu.
