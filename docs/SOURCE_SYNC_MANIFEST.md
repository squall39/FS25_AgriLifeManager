# Synchronisation du source GitHub

Version de test préparée : **0.9.3.24 TEST**
Version déclarée sur `main` : **0.9.3.24 TEST**
Date : **13 août 2026**

La build joueur 0.9.3.24 est la référence exécutable préparée pour le premier test F03 Banque. F01 et F02 restent validées. F03 n'est pas encore certifiée dans Farming Simulator 25.

## Préparation F03 0.9.3.24

- lecture du capital restant et des mois restants du prêt corrigée ;
- remboursement anticipé calculé sur le capital réellement restant ;
- montant, frais et débit total présentés avant confirmation ;
- frais propres au prêt conservés selon sa banque d'origine ;
- réaménagement calculé sur la durée réellement restante ;
- confirmations Oui / Non avant les actions bancaires engageantes ;
- découvert remplacé par une autorisation temporaire avec durée, frais, intérêts, régularisation, mise en demeure et contentieux ;
- contentieux bancaire relié au Juridique sans double comptabilisation du principal ;
- dossiers fiscaux et bancaires séparés dans le Juridique ;
- retour explicite lorsque la banque est fermée ;
- parité des traductions de la build conservée sur 27 langues ;
- audits statiques et packaging TEST validés avant essai en jeu.

## État réel de `main`

`main` porte désormais le numéro 0.9.3.24 et les fichiers de suivi F03. Le dépôt ne doit toutefois pas être présenté comme miroir complet du ZIP 0.9.3.24 tant que toutes les sources actives F03 ne sont pas présentes et vérifiées.

Gaps historiques ou F03 encore ouverts :

- `src/modules/bank/Bank6Service.lua` absent de `main` ;
- `src/modules/bank/Bank6Events.lua` absent de `main` ;
- `src/modules/bank/BankModule.lua` absent de `main` ;
- `src/modules/administration/Administration6Service.lua` absent de `main` ;
- `src/modules/administration/AdministrationRoadmap6.lua` absent de `main` ;
- le répertoire `translations/` distribué dans la build n'est pas encore miroité ;
- `tools/verify_release.py` n'est pas encore miroité ;
- les modifications F03 de certains gros fichiers déjà présents, notamment Banque, Juridique, interface, Assistance et feuille de route, restent à comparer octet par octet avec la build avant de déclarer le miroir complet.

Les appels d'écriture directs du connecteur peuvent refuser certains gros fichiers Lua. Un fichier n'est jamais considéré synchronisé tant que sa présence et son contenu n'ont pas été vérifiés sur `main`.

## Règles de synchronisation

- distinguer clairement la version de test et l'état réel du dépôt ;
- ne jamais déclarer un fichier synchronisé s'il n'est pas présent et vérifié ;
- conserver la build joueur comme référence exécutable tant que le miroir GitHub est incomplet ;
- retirer les helpers temporaires après usage ;
- aucun tiret cadratin dans les contenus du projet.
