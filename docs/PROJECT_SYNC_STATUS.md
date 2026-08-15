# Project sync status

Checkpoint GitHub : 2026-08-15.

Build de test locale actuelle : 0.9.3.57 TEST.

État validé en jeu avant ce checkpoint :
- examens agricoles globalement fonctionnels, avec seulement quelques incohérences mineures restant à peaufiner ;
- Planning Entreprise : sélection véhicule / outil / barre / chariot, vignettes matériel, bouton unique de planification et prévention des doublons validés visuellement ;
- prochain chantier actif : cycle physique des ouvriers et automatisation FS25.

Cycle ouvrier 0.9.3.57 en test :
1. mémoriser l'emplacement initial du véhicule et des équipements ;
2. aller chercher le matériel non attelé ;
3. lancer le travail de champ ;
4. ramener et dételer le matériel emprunté à son emplacement initial ;
5. ramener le véhicule à son emplacement initial ;
6. terminer l'affectation seulement après le retour.

Référence de travail externe autorisée par l'utilisateur : LeGrizzly/FS25_EmployeeManager, branche fix/gui/refacto, à étudier pour la logique JobManager / ParkingManager / IA native FS25.

Note : le ZIP 0.9.3.57 reste la référence exécutable de test. Ce checkpoint documente l'avancement courant avant la prochaine passe d'intégration des ouvriers.
