# Tests AgriLife Manager

Version de référence : **0.9.3.24 TEST**

État de campagne :
- F01 : **VALIDÉ EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉ EN JEU** en 0.9.3.23.
- F03 : **ACTIVE - Banque fonctionnelle**.
- F04+ : **EN ATTENTE** jusqu’à validation complète de F03.

Préparation F03 0.9.3.24 :
- capital restant et mois restants du prêt actif corrigés ;
- remboursement anticipé calculé sur le vrai capital restant, avec frais de la banque d’origine annoncés avant validation ;
- réaménagement de prêt calculé sur la durée réellement restante ;
- confirmation Oui / Non avant toute action bancaire engageante de cette passe : demande de prêt, remboursement anticipé, réaménagement, découvert, contrat bancaire, refinancement et paiement fiscal ;
- refus avec **Non** = aucune écriture financière ;
- retour explicite si la banque est fermée ;
- découvert professionnel rendu réel : utilisé = solde négatif, échéances/frais automatiques couverts dans la limite autorisée, remboursement automatique à la remontée du solde, intérêts mensuels et dépassement visibles ;
- découvert utilisé et intérêts en retard comptés dans la dette AgriLife et la capacité bancaire ;
- messages F03 localisés et parité l10n conservée sur les 27 langues ;
- découvert autorisé uniquement pour une durée déterminée, avec frais d'autorisation ou de renouvellement ;
- échéance non régularisée = délai de régularisation, puis mise en demeure, puis transmission au Juridique ;
- le transfert contentieux convertit le solde négatif en créance afin d'éviter toute double facturation du principal ;
- les dossiers Juridique conservent maintenant une origine distincte pour le bancaire et le fiscal.

Premier test F03 :
1. Ouvrir `Échap > AgriLife Manager > Banque` pendant les horaires d’ouverture, soit 08:00-12:00 ou 14:00-18:00.
2. Contrôler toute la page sans confirmer de mouvement financier : banque, conseiller, trésorerie, dette FS25, dette AgriLife, score, capacité, prêt actif, capital restant, mois restants, découvert, contrat bancaire et refinancement.
3. Cliquer sur **une seule action engageante disponible** pour faire apparaître la confirmation. Répondre **Non**.
4. Vérifier que la trésorerie, la dette et le relevé bancaire n’ont pas changé après le refus.
5. Envoyer une capture plein écran de la page Banque et le `log.txt`.

Ne confirmer aucune opération avec **Oui** avant validation de ce premier contrôle F03.
- vérifier qu’aucune nouvelle autorisation de découvert ne peut être demandée pendant la régularisation, la mise en demeure ou un contentieux actif ;
