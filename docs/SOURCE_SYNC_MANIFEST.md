# Synchronisation du source GitHub

Version de test preparee : **0.9.3.24 TEST**
Version actuellement presente sur `main` : **0.9.3.23 TEST**
Date : **13 aout 2026**

La build joueur 0.9.3.24 est preparee localement pour le premier test F03 Banque. F01 et F02 restent validees. F03 n est pas encore certifiee dans Farming Simulator 25.

## Preparation F03 0.9.3.24

- lecture du capital restant et des mois restants du pret corrigee ;
- remboursement anticipe calcule sur le capital reellement restant ;
- montant, frais et debit total presentes avant confirmation ;
- frais propres au pret conserves selon sa banque d origine ;
- reamenagement calcule sur la duree reellement restante ;
- confirmation Oui / Non avant demande de pret, remboursement anticipe, reamenagement, decouvert, contrat bancaire, refinancement et paiement fiscal ;
- retour explicite lorsque la banque est fermee ;
- parite des traductions de la build conservee sur 27 langues ;
- audits statiques et packaging TEST valides avant essai en jeu.

## Etat reel de `main`

`main` reste volontairement identifie en 0.9.3.23 tant que les sources actives necessaires a F03 ne sont pas toutes miroitees. Il ne doit pas etre presente comme copie complete du ZIP 0.9.3.24.

Les gaps connus comprennent notamment :

- `src/modules/bank/Bank6Service.lua` ;
- `src/modules/bank/Bank6Events.lua` ;
- `src/modules/bank/BankModule.lua` ;
- le repertoire `translations/` ;
- `tools/verify_release.py`.

Ces ecarts restent ouverts jusqu a presence et verification reelles des chemins concernes.

## Regles de synchronisation

- distinguer clairement la version de test et la version reellement presente sur le depot ;
- ne jamais declarer un fichier synchronise s il n est pas present ;
- conserver la build joueur comme reference executable tant que le miroir GitHub est incomplet ;
- retirer les helpers temporaires apres usage ;
- aucun tiret cadratin dans les contenus du projet.
