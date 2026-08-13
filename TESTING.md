# Tests AgriLife Manager

Version de référence : **0.9.3.23 TEST**

Etat de campagne :
- F01 : **VALIDÉ EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉ EN JEU** en 0.9.3.23.
- F03 : **ACTIVE - Banque fonctionnelle**.
- F04+ : **EN ATTENTE** jusqu'à validation complète de F03.

Validation F02 0.9.3.23 :
- ligne d'aide supérieure complète et lisible en 1920 x 1080 ;
- Banque et Conseiller sur deux lignes distinctes ;
- notes Banque et Conseiller au format x/5 ;
- Score de crédit sans répétition du nom de banque ;
- aucun warning de police lié aux anciens caractères étoile ;
- aucun Error, traceback ou défaut de montage UI AgriLife dans le log du retest ;
- application montée puis cycle de vie passé de MOUNTING_UI à RUNNING.

Premier test F03 :
- ouvrir Banque ;
- vérifier la page et les données sans effectuer d'opération financière ;
- ne pas emprunter, rembourser, transférer ou confirmer un changement de banque/conseiller ;
- envoyer une capture de la page Banque complète et le log FS25.
