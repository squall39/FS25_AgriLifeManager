# Project sync status

Checkpoint GitHub : 2026-08-15.

Build de test locale actuelle : 0.9.3.58 TEST.

État validé en jeu avant ce checkpoint :
- examens agricoles globalement fonctionnels, avec seulement quelques incohérences mineures restant à peaufiner ;
- Planning Entreprise : sélection véhicule / outil / barre / chariot, vignettes matériel, bouton unique de planification et prévention des doublons validés visuellement ;
- chantier actif : cycle physique des ouvriers et automatisation FS25.

Cycle ouvrier 0.9.3.58 en test :
1. mémoriser l'emplacement initial du véhicule et des équipements ;
2. aller chercher le matériel non attelé ;
3. effectuer un transit FS25 `GOTO` vers le champ lorsque celui-ci est éloigné ;
4. lancer le vrai `FIELDWORK` une fois à proximité ;
5. ramener et dételer le matériel emprunté à son emplacement initial ;
6. ramener le véhicule à son emplacement initial ;
7. terminer l'affectation seulement après le retour.

Référence technique externe étudiée avec autorisation communiquée par l'utilisateur : `LeGrizzly/FS25_EmployeeManager`, branche `fix/gui/refacto`. Le modèle `GOTO -> FIELDWORK -> GOTO retour` de son JobManager et l'enregistrement `x/y/z/angle` de son ParkingManager sont retenus comme références, puis adaptés aux règles AgriLife.

Le ZIP 0.9.3.58 est la référence exécutable de test actuelle. Le dépôt contient le checkpoint, le changelog de progression et la documentation du cycle ouvrier. Le miroir source dézippé complet reste à réaligner fichier par fichier avec le ZIP avant de considérer GitHub comme strictement identique à la build joueur.
