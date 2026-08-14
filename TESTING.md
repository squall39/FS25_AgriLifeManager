# Tests AgriLife Manager

Version de référence : **0.9.3.27 TEST**

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
Correction F03 0.9.3.25 :
- le bouton `Signer` récupère correctement l’autorisation `bank.manage` ;
- un propriétaire autorisé doit pouvoir ouvrir la confirmation de signature ;
- un profil non autorisé reçoit un retour explicite au lieu d’un bouton silencieux.

Retest ciblé F03 0.9.3.25 :
1. Ouvrir Banque.
2. Vérifier que `Signer` est actif.
3. Cliquer `Signer`.
4. La confirmation doit apparaître.
5. Répondre `Non` pour ce premier retest.
6. Vérifier qu’aucun mouvement financier ni contrat n’a été créé.



## F03 - extension 0.9.3.25

Catalogue banques 0 à 5 :
- vérifier les catégories locale, régionale, nationale, internationale et en ligne ;
- vérifier que les conseillers proposés appartiennent à la banque sélectionnée ;
- vérifier qu'en Facile tous les profils compatibles sont accessibles ;
- vérifier qu'en Normal et Difficile les profils supérieurs restent visibles mais expliquent le verrou de progression ;
- vérifier qu'un clic de confirmation Banque ou Conseiller affiche les conséquences avant validation ;
- vérifier que `Signer convention` affiche banque, conseiller, durée, bonus de relation, frais de rupture indicatifs et services débloqués ;
- vérifier qu'une demande de prêt reste simulable mais non envoyable tant que la convention n'est pas active ;
- vérifier qu'une banque en ligne accepte les actions client hors horaires bancaires traditionnels.

Correction XP 0.9.3.26 intégrée dans 0.9.3.27, retest reporté par décision de test :
1. Effectuer une activité qui affiche le HUD XP sur le mini-PDA.
2. Vérifier qu'à 3 036 XP une spécialité affiche 3 étoiles.
3. Vérifier que l'XP total est affiché séparément.
4. Vérifier que le palier affiche 36 / 1 000 XP et environ 4 %, et non 3 036 / 7 500 XP avec 1 %.
5. Envoyer une capture du HUD XP et le log.

Le retest XP est volontairement reporté et ne bloque pas la reprise de F03 Banque.



## Préparation transversale 0.9.3.27 - écrite, non certifiée en jeu

Cette passe a été autorisée avant la reprise des tests sans ouvrir F04. La phase de certification reste F03 Banque.

- Entreprise : séparation nom d'exploitation / forme juridique / activité / réseau professionnel.
- Formes juridiques : EI, EARL, GAEC, SCEA, EURL, SARL, SASU, SAS.
- ETA : activité secondaire réellement raccordée aux prestations inter-exploitations.
- Coopérative agricole : adhésion réellement raccordée aux offres commerciales coopératives.
- CUMA : socle de données, migration et comptabilité présents, mais sélection volontairement non activée tant que le catalogue de matériel mutualisé et les réservations ne sont pas fonctionnels.
- Groupement d'employeurs et autres activités préparées : non sélectionnables tant que leurs effets métier complets ne sont pas raccordés.
- Conseiller de gestion : moteur d'analyse réel et historique, connecté au recrutement et aux choix de structure.
- Contrats AgriLife : paiement immédiat, mensuel ou différé après livraison selon le profil commercial.
- Contournements vanilla : nouveaux contrats FS25 bloqués, crédit vanilla bloqué, reset matériel remplacé lorsqu'un callback FS25 compatible est détecté.
- Tout choix conséquent ouvert par cette passe doit afficher une explication avant confirmation.

### Reprise des tests

La reprise se fait sur 0.9.3.27. On reprend d'abord F03 Banque exactement au contrôle de la convention bancaire déjà prévu. Les systèmes 0.9.3.27 ci-dessus auront leurs tests ciblés après la fermeture de F03 ou lorsqu'un contrôle de fumée est nécessaire pour sécuriser la build.
