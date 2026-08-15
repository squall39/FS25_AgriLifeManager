# Project sync status

Checkpoint GitHub : 2026-08-16.

Build de test locale actuelle : 0.9.3.62 TEST.

État validé en jeu avant ce checkpoint :
- examens agricoles globalement fonctionnels, avec les étapes de récolte encore suivies séparément ;
- Planning Entreprise : sélection du salarié, du véhicule, de l'outil, du travail et du champ fonctionnelle ;
- Dispatch Entreprise : création de l'ordre et démarrage du cycle ouvrier confirmés en jeu ;
- résolution du champ FS25 confirmée par la progression du cycle au-delà de `fieldwork_start:target_missing`.

Blocage observé en 0.9.3.61 :
- le trajet `GOTO` vers le John Deere 980 placé dans le hangar est refusé par FS25 comme cible inaccessible ;
- le log de test répète `fetch_drive_failed` à environ 16,7 m du 980 alors que le job IA devient d'abord actif.

Correction 0.9.3.62 en test :
1. le matériel local situé à moins de 50 m du véhicule est récupéré sans créer de cible `GOTO` dans le bâtiment ;
2. un matériel plus éloigné conserve un trajet d'approche, avec un point cible décalé de 15 m ;
3. le transit séparé vers le champ n'est utilisé qu'au-delà de 150 m ;
4. en dessous de 150 m, le vrai `FIELDWORK` FS25 est démarré directement ;
5. le matériel local emprunté est dételé au retour puis replacé exactement à sa transformation d'origine enregistrée ;
6. les scripts, noms publics et métadonnées restent AgriLife Manager, auteur Chez_Squall.

Ce checkpoint synchronise l'état technique utile à la 0.9.3.62. La validation fonctionnelle reste obligatoirement à faire dans Farming Simulator 25 avant de considérer ce cycle comme validé.
