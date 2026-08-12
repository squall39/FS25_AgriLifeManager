# État de synchronisation AgriLife Manager

Version de référence : **0.9.1.0 TEST**  
Build TEST de référence : `FS25_AgriLifeManager_step1_sync.zip`  
SHA256 : `5f1d19a7ccb842bbab09121b2610436bf7ae29c97dfbab54c8553fb148e5207b`

## Règle permanente

Toute idée explicitement validée doit être reflétée dans :

1. la feuille de route additive et son registre maître ;
2. le tutoriel de départ si elle concerne le comportement joueur ;
3. le menu `Échap > Assistance`, qui partage les mêmes clés l10n ;
4. GitHub, pour conserver la décision et les sources texte maintenables ;
5. la build de référence, qui reste la source exécutable.

Une idée documentée mais non codée garde le statut `À intégrer` ou `Partiellement intégrée`. Une fonctionnalité codée mais non testée reste `À certifier`.

## Dernière décision validée

Flux Atelier / Assurance :

- panne légère, panne immobilisante dépannable et casse lourde distinguées ;
- service de dépannage/remorquage vers concessionnaire ou atelier de l’exploitation ;
- retrait planifié du camion de service achetable par le joueur ;
- kit terrain limité au diagnostic et aux interventions d’urgence ;
- pièces réellement commandées au concessionnaire, retirées ou livrées sur palettes physiques puis consommées du stock atelier ;
- réparation maison moins chère surtout par économie de main-d’œuvre, avec atelier, compétences, pièces et temps requis ;
- assurance calculée selon cause, contrat, franchise, responsabilité, entretien et alertes ignorées ;
- assistance/remorquage pouvant être couverts séparément ;
- réparation maison indemnisée uniquement sur les dépenses admissibles réellement engagées, jamais de bénéfice d’assurance.

## État actuel

La roadmap, le registre maître, les sujets 10/11 du tutoriel, l’Assistance, le guide utilisateur, la matrice d’implémentation et l’audit l10n ont été mis à jour dans la build de référence. Les gates statiques passent avec 27 langues et 5 047 clés par langue.
