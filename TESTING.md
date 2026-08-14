## Test F04.2 Dossier et salaires 0.9.3.40

Statut : **ACTIF**. La 0.9.3.39 est rejetée pour `stack overflow` lors des interactions UI.

Objectif immédiat : vérifier que l'interface Entreprise peut être parcourue sans récursion ni hausse anormale de mémoire.

1. Charger la même sauvegarde avec la 0.9.3.40.
2. Ouvrir AgriLife Manager puis Entreprise.
3. Cliquer successivement sur Hugo, Lou et le propriétaire.
4. Parcourir plusieurs candidats et revenir sur les salariés.
5. Ouvrir le dossier complet de chaque profil.
6. Vérifier l'absence de gel, d'erreur `mouseEvent` et de `stack overflow`.
7. Vérifier les salaires Facile et la fiche propriétaire.
8. Fournir captures et `log.txt`.

## Test F04.2 Dossier complet et salaires 0.9.3.39

Objectif : valider la fiche RH complète pour salarié et propriétaire, puis la nouvelle grille salariale dépendante de la difficulté.

1. Ouvrir Entreprise en mode Facile.
2. Sélectionner Hugo Bernard puis ouvrir Dossier salarié. La fiche doit afficher identité, rôle traduit, contrat, ancienneté, statut, salaire, brut, coût employeur, spécialité, XP, performance, temps, congés, absences, ordre actif, salaire recommandé, fourchette, réputation, moral et carrière.
3. Sélectionner Lou Martin et vérifier que toutes les valeurs sont rafraîchies pour Lou.
4. Sélectionner le propriétaire. Le titre doit identifier le rôle Propriétaire, la fiche doit rester complète et le bouton Promouvoir doit être désactivé.
5. En mode Facile, vérifier que les salaires affichés sont plus bas que dans la 0.9.3.38. Référence attendue au niveau 1 et réputation 50 : salarié AUTO environ 1 490 €/mois, propriétaire AUTO environ 1 620 €/mois.
6. Vérifier qu'un candidat de recrutement affiche une demande salariale cohérente avec le mode Facile, généralement inférieure à l'ancienne grille.
7. Ne recruter personne pour ce sous-test.
8. Sauvegarder, quitter et recharger. Vérifier que la fiche et les salaires restent cohérents.
9. Fournir une capture salarié, une capture propriétaire et `log.txt`.

F04.1 reste VALIDÉ EN JEU. F04.2 reste ACTIVE jusqu'à validation de ce test.

## Validation F04.1 Recrutement 0.9.3.37

F04.1 est **VALIDÉ EN JEU** : recrutement fonctionnel, frais fixes de 350 € débités une seule fois, ligne `Salarié recruté` visible dans le relevé professionnel avec le nom du salarié, solde cohérent, sauvegarde/rechargement validés et log AgriLife propre.

Validation observée avec le recrutement de Lou Martin : trésorerie à 199 300 €, mouvement `FRAIS RECRUTEMENT | Lou Martin` à -350 € et persistance après rechargement de la sauvegarde en 0.9.3.37.

## Test F04.2 Dossier salarié 0.9.3.38

Objectif : valider la fiche salarié agrandie et la fusion de la carrière salarié dans le même écran avant d'ouvrir Planning, Formations et Incidents.

1. Ouvrir AgriLife Manager > Entreprise.
2. Sélectionner Hugo Bernard puis ouvrir `DOSSIER SALARIÉ`.
3. Vérifier que le titre et les informations utilisent nettement mieux le panneau droit et restent entièrement lisibles.
4. Contrôler contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, XP, niveau, performance, réussites/échecs, formations, incidents, promotions et ordre actif affichés.
5. Vérifier que le bouton `Carrière salarié` n'est plus affiché.
6. Vérifier que l'action de promotion, lorsqu'elle devient disponible, est proposée directement dans `Dossier salarié`.
7. Revenir à la liste, sélectionner Lou Martin puis ouvrir `DOSSIER SALARIÉ`.
8. Vérifier que les informations correspondent bien à Lou Martin et qu'aucune donnée de Hugo Bernard ne reste affichée.
9. Ne modifier aucun salaire, contrat ou statut pendant ce contrôle.
10. Passer plusieurs fois d'un salarié à l'autre et signaler tout micro-freeze ou information qui ne se rafraîchit pas.
11. Fournir une capture de chaque dossier salarié et le `log.txt`.

F04 reste **ACTIVE - Entreprise** jusqu'à validation complète des sous-tests suivants.

## Validation F03 Banque 0.9.3.36

F03 est **VALIDÉE EN JEU** : convention bancaire fonctionnelle et persistante, banque physique fermée avec horaires visibles, banque physique ouverte selon l'heure du jeu, banque numérique ouverte 24/7, interface lisible et log AgriLife propre.

## Test F03 Banque 0.9.3.35

Objectif : valider la sélection officielle banque/conseiller puis la signature réelle de convention sans faux refus de crédit.

1. Ouvrir AgriLife Manager > Banque.
2. Parcourir une autre banque avec une flèche. Vérifier que `Signer convention` est désactivé et qu'aucun ancien conseiller n'est présenté comme conseiller de cette banque.
3. Cliquer sur le nom de la banque choisie et confirmer OUI.
4. Choisir ensuite un conseiller compatible, cliquer sur son nom et confirmer OUI.
5. Vérifier que `Signer convention` devient disponible seulement après ces deux confirmations.
6. Cliquer `Signer convention`, répondre OUI.
7. Vérifier que la relation devient active, qu'aucun prêt n'est créé et que la trésorerie ne bouge pas anormalement.
8. Sauvegarder, quitter, recharger et vérifier la persistance.
9. Fournir deux captures et `log.txt`.

Performance : signaler tout micro-freeze restant pendant parcours banque/conseiller et ouverture de la confirmation.

## Test performance 0.9.3.33

- Charger la même sauvegarde.
- Ouvrir AgriLife Manager.
- Alterner 10 fois Tableau de bord et Banque.
- Fermer puis rouvrir AgriLife 5 fois.
- Noter si le dernier micro-freeze a disparu, diminué ou reste identique.
- Envoyer le log afin de contrôler les lignes `[AgriLife][Performance]`.
- Les seuils de télémétrie sont maintenant à 1,5 ms pour attraper les micro-pics invisibles au seuil précédent.

# Test actif 0.9.3.33

Contrôle performance bloquant avant F03 : la navigation Tableau de bord / Banque et l'ouverture d'AgriLife doivent paraître instantanées. Le log doit rester sans `stack overflow`, `MODULE_LOAD_FAILED`, `UI_XML_LOAD_FAILED`, atteindre `MOUNTING_UI -> RUNNING`, et les nouvelles lignes Performance doivent permettre d'identifier tout coût restant au-dessus de 1,5 ms.

# Tests AgriLife Manager

Version de référence : **0.9.3.40 TEST**

État de campagne :
- F01 : **VALIDÉ EN JEU**. Ne pas recommencer.
- F02 : **VALIDÉ EN JEU** en 0.9.3.23.
- F03 : **VALIDÉ EN JEU** en 0.9.3.36.
- F04 : **ACTIVE - Entreprise**.
- F05+ : **EN ATTENTE** jusqu’à validation complète de F04.
