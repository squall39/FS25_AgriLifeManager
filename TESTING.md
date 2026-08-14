# Tests AgriLife Manager

Version de référence : **0.9.3.26 TEST**

État de campagne :
- F01 : **VALIDÉ EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉ EN JEU** en 0.9.3.23.
- F03 : **ACTIVE - Banque fonctionnelle**.
- F04+ : **EN ATTENTE** jusqu’à validation complète de F03.

Préparation F03 :
- convention bancaire entre exploitation, banque et conseiller ;
- correction du bouton de signature de convention ;
- simulation de crédit possible avant convention, envoi réel réservé à une convention bancaire active ;
- banques et conseillers avec accès et progression de 0 à 5 ;
- accès libre aux profils compatibles en Facile ;
- progression requise dans les autres difficultés ;
- banques locales, régionales, nationales, internationales et en ligne ;
- conseillers rattachés à leur établissement ;
- explication obligatoire avant chaque choix ayant une conséquence ;
- découvert professionnel temporaire avec durée, frais, intérêts, délai de régularisation, mise en demeure et contentieux ;
- séparation des dossiers bancaires et fiscaux dans le Juridique ;
- refus par Non = aucune écriture financière.

## Test F03 à reprendre ce soir

1. Ouvrir `Échap > AgriLife Manager > Banque` sur la 0.9.3.26.
2. Parcourir plusieurs banques avec les flèches.
3. Vérifier qu’un profil classique, un profil international et un profil en ligne sont compréhensibles.
4. Parcourir les conseillers et vérifier qu’ils correspondent à la banque sélectionnée.
5. Revenir sur la banque et le conseiller de référence de la sauvegarde.
6. Vérifier que `Signer convention` est disponible.
7. Ouvrir la fenêtre de confirmation de convention.
8. Vérifier que le texte explique la durée, les services débloqués, l’engagement et les conséquences d’une rupture.
9. Répondre **Non** pour ce premier contrôle.
10. Envoyer une capture de la page Banque, une capture de la confirmation et le `log.txt`.

Ne confirmer aucune vraie signature ni opération financière avec **Oui** avant validation de ce contrôle.

## Correction XP 0.9.3.26

La correction XP est écrite et auditée mais son retest en jeu est **reporté**. Elle ne bloque pas la poursuite de F03 Banque.

Retest à faire plus tard :
1. Effectuer une activité qui affiche le HUD XP sur le mini-PDA.
2. Vérifier qu’à 3 036 XP une spécialité affiche 3 étoiles.
3. Vérifier que l’XP total est affiché séparément.
4. Vérifier que le palier affiche 36 / 1 000 XP et environ 4 %, et non 3 036 / 7 500 XP avec 1 %.
5. Envoyer une capture du HUD XP et le log.
