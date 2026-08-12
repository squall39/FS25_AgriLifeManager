# Audit statique complet des scripts - AgriLife Manager 0.9.1.0

Date de référence : 2026-08-12  
Package audité : `FS25_AgriLifeManager_step1_sync.zip`  
SHA-256 du package audité : `5f1d19a7ccb842bbab09121b2610436bf7ae29c97dfbab54c8553fb148e5207b`

## Objet de l'audit

Cet audit cherche les scripts absents, oubliés, non chargés ou fonctionnellement incomplets **sans lancer Farming Simulator 25**. Il inclut les anciennes idées validées et les nouvelles décisions Atelier / Assurance : pannes immobilisantes, dépannage/remorquage, palettes physiques de pièces, réparation à l'exploitation, suppression du camion de service joueur, kit terrain limité aux urgences, prise en charge assurance et couverture des véhicules, remorques, outils et accessoires.

## Résultat global

- Lua présents dans le package : **122**.
- Lua runtime actifs : **109**.
- `extraSourceFiles` : **106**.
- spécialisations véhicule : **2** (`FieldServiceKit6`, `ServiceTruck6`).
- spécialisation placeable : **1** (`OilServicePoint6`).
- Lua présents mais non chargés : **13**, tous situés dans `tests/` ; **aucun script runtime orphelin**.
- XML : **91**, tous parsables.
- Références runtime `modDesc.xml` manquantes : **0**.
- Langues : **27**, **5 047 clés** chacune, parité statique OK.
- Gate publication : OK, version pré-1.0 et multijoueur non publié.

Conclusion : **aucun script déjà présent n'est oublié par `modDesc.xml`**. Les écarts sont des fonctionnalités validées qui restent à écrire ou à compléter.

---

# Audit étape par étape

## Étape 1 - Démarrage

Scripts présents : cœur, cycle de vie, contexte mission, persistance, migration, réglages et `EconomyStartupRoadmap1.lua`, avec les dépendances Banque / Carrière requises au démarrage.

**Aucun script métier manquant détecté statiquement.** Les trois difficultés, l'onboarding différé, le permis provisoire Normal, le verrou Difficile, la migration et la persistance ont des implémentations actives.

Statut : **installé / à certifier en jeu**.

## Étape 2 - Interface & expérience utilisateur

Scripts présents : `AgriLifeHomeFrame.lua`, `AgriLifeUIManager.lua`, `AgriLifeInterface6.lua`, `AgriLifeInterfaceRoadmap2Completion.lua`, `AgriLifeTutorialDialog.lua`, `AgriLifeTutorialRoadmapCompletion.lua`, `AgriLifeHelpIntegration6.lua`, `AgriLifeMiniPdaProgress.lua`, `AgriLifeJournalDialog.lua`, `AgriLifeStep7UI.lua`, `AgriLifeStep8UI.lua` et `AgriLifeRoadmapWritingCompletionUI.lua`.

**Aucun script UI manquant détecté.** Le tutoriel 13 sujets et l'Assistance sont chargés et partagent la même base l10n.

Statut : **installé / à certifier en jeu**.

## Étape 3 - Banque

Scripts présents : `Bank6Service.lua`, `Bank6Events.lua`, `BankModule.lua`, `BankRoadmap3.lua`, `BankRoadmap3Completion.lua`, `EconomyAccountingRoadmapCompletion.lua` et `DashboardRoadmapWritingCompletion.lua`.

Le checklist statique expose difficulté, accès banque/conseiller, décision différée de crédit, contrats bancaires, refinancement, historique de transactions, prévisions, comptabilité, clôture fiscale, impôts, remboursement anticipé, restructuration et découvert.

**Aucun script métier manquant détecté.**

## Étape 4 - Entreprise

Scripts présents : `Enterprise6Service.lua`, `EnterpriseRoadmap4.lua`, `EnterpriseRoadmap4Completion.lua`, `EnterpriseModule.lua`, modules Company, People, Payroll et compatibilités associées.

Le code expose contrats, planning, absences, promotions, salaire, rupture, ordres de travail, séparation salarié/joueur, XP salarié, spécialités, réputation et intégrations optionnelles.

**Aucun script métier manquant détecté.**

## Étape 5 - Carrière & Qualifications

Scripts présents : Career, Exam, Qualifications, trackers travail/transport et HUD associés.

Le checklist statique confirme XP selon difficulté, isolation XP pendant examen, catalogue qualifications, verrous métier, historique des résultats et examen en 10 étapes.

**Aucun script métier manquant détecté.**

## Étape 6 - Administration & Assurance

Scripts présents : Administration, Insurance, Claims/Liability, Bonus-Malus et Legal.

Ancien périmètre : statut/licence évolutif, conformité, contrôles récurrents, récidive, régularisation, sanctions, restrictions, événements de gestion, contentieux et contrats d'assurance sont présents.

### Manques liés aux nouvelles décisions

**ADM/INS-01 - couverture mécanique Atelier encore incomplète.** `WorkshopRoadmap8:getInsuranceRepairCoverage()` couvre surtout les pannes liées à un accident et exclut l'usure. Il manque la décision complète panne soudaine / usure normale / entretien négligé / alerte ignorée / garantie spécifique.

**ADM/INS-02 - assistance/remorquage séparée absente.** Aucune garantie d'assistance ne calcule encore séparément le remorquage selon contrat, plafond et franchise.

**ADM/INS-03 - règle “dépenses réellement engagées” absente.** Le sinistre Atelier utilise actuellement `job.totalCost`. Il manque un calcul qui plafonne l'indemnisation aux dépenses admissibles et interdit une main-d'œuvre fictive lors d'une réparation personnelle.

Recommandation : une complétion dédiée de type `src/modules/insurance/InsuranceWorkshopRoadmapCompletion.lua`.

Statut étape 6 : **ancien périmètre installé ; nouvelles règles Atelier/Assurance partielles**.

## Étape 7 - Contrats & Marchés

Scripts présents : CommercialContracts, DynamicMarket, AssetLifecycle, compatibilités et économie associées.

Découverte dynamique, marchés mondial/local, prix, multifruits, neuf/occasion, disponibilité, intrants, énergie, foncier, location, productions et agronomie optionnelle ont des implémentations chargées.

**Aucun script métier manquant détecté.**

## Étape 8 - Atelier, Concessionnaire & parc technique

C'est **la seule étape où l'audit statique trouve plusieurs briques validées encore non finalisées**.

### Déjà présent

Classification `motorized`, `self_propelled`, `trailer`, `implement`, `equipment`, systèmes mécaniques par spécialisation, pannes moteur/transmission/PTO/hydraulique/freinage/direction/suspension/pneus/roulements/attelage/essieux/dosage/électronique/outil, immobilisation, diagnostic, catalogue logique de pièces, commandes et inventaire logiques, atelier interne, révisions, contrôle technique, historique technique, occasion, valeur de revente, pont assurance accident et compatibilités ADS/MudSystem.

### Couverture véhicules, outils et accessoires

**Présente statiquement dans le cœur Atelier.** `getRuntimeVehicles()` utilise le `vehicleSystem`, `getAssetKind()` reconnaît remorques et outils attachables, et `getApplicableSystems()` ajoute les systèmes adaptés. Une masse/poids ou un accessoire attachable peut donc recevoir châssis/roulements/attelage, tandis qu'un outil spécialisé reçoit PTO, hydraulique, dosage, électronique ou système de travail selon ses spécialisations.

### Écarts à corriger

**WRK-08A - remorquage réel non implémenté.** `requestRecovery()` crée un job `RECOVERY`, puis la fin du job pose surtout `recoveredToWorkshop=true`. Il manque transfert/destination réelle, atelier ferme ou concessionnaire, coût selon distance/zone et maintien correct de l'état de panne après transport.

**WRK-08B - récupération imposée au concessionnaire.** Le job `RECOVERY` utilise `provider="DEALER"`. Le choix concessionnaire / atelier de l'exploitation n'existe pas encore.

**WRK-08C - palette physique de commande absente.** `orderPart()` alimente un inventaire logique. `vehicles/sparePartsPallet/sparePartsPallet.xml` reste une palette générique de 100 pièces achetable au magasin, non liée à une commande, une référence, une qualité, un véhicule ou un bon de livraison. Il manque le flux commande -> préparation -> palette -> retrait/livraison -> stock -> consommation.

Recommandation : spécialisation de type `vehicles/SparePartsOrderPallet6.lua` ou service physique équivalent.

**WRK-08D - réparation interne : logique présente, comptabilité à corriger.** Le provider `INTERNAL` existe et réduit la main-d'œuvre. Mais `createWorkshopJob()` prélève encore un coût de main-d'œuvre interne puis `performJobCompletion()` enregistre aussi le travail dans la paie. Risque de double coût et de main-d'œuvre artificielle pour le dirigeant. Il faut distinguer dirigeant, salarié mécanicien et prestataire.

**WRK-08E - camion de service encore totalement installé.** Il reste dans `storeItems`, comme spécialisation, via `ServiceTruck6.lua`, à 75 000 €, avec ses dialogues et sa restauration mobile. La décision validée de retrait n'est pas appliquée.

**WRK-08F - kit terrain répare encore trop.** `FieldServiceKit6:activateAgriLifeFieldKit()` fait diagnostic puis `repair` directement, sans filtre de gravité. Il faut une liste blanche d'urgences, une réparation provisoire et le refus des casses lourdes.

**WRK-08G - dépannage physique limité aux matériels motorisés.** `PhysicalWorkshop6:findNearestVehicle()` exige `spec_motorized`. Le cœur Atelier sait suivre remorques/outils/accessoires, mais le kit physique ne peut pas encore sélectionner un outil ou accessoire non motorisé.

**WRK-08H - absence de filtre d'exclusion des objets non maintenables.** `syncVehicles()` enregistre tout objet du `vehicleSystem` de la ferme. Cela peut inclure palettes, kits ou objets support. Il faut `isMaintainableAsset()` pour garder tracteurs, automoteurs, remorques, outils, chargeurs, masses et accessoires, tout en excluant consommables et hand tools.

**WRK-08I - assurance du remorquage absente.** Le coût `RECOVERY` n'est pas relié à une garantie d'assistance, une franchise ou un plafond.

**WRK-08J - comparatif de choix incomplet.** `AgriLifeStep8UI.lua` permet `DEALER/INTERNAL`, mais pas encore le comparatif complet pièces, main-d'œuvre, délai, remorquage, assurance, franchise et reste à charge.

**WRK-08K - verrou de redémarrage lourd incomplet.** Les défauts critiques moteur utilisent bien `stopEngine=true` et `lockStart=true`, et `applyTechnicalEffects()` coupe un moteur déjà démarré. En revanche, aucun hook runtime distinct n'intercepte statiquement la commande de démarrage suivante. Une casse moteur lourde n'est donc pas encore garantie comme impossible à redémarrer jusqu'à réparation. Il faut un verrou moteur persistant relié à l'état `agriLifeImmobilized` / `lockStart`, retiré uniquement après réparation ou état technique redevenu compatible.

### Priorités d'écriture

1. Complétion Recovery/Towing autour de `WorkshopRoadmap8.lua`.
2. Complétion Physical Parts Orders / liaison palette.
3. Complétion Insurance Workshop Coverage.
4. Modification `FieldServiceKit6.lua` + `PhysicalWorkshop6.lua`.
5. Correction comptabilité du provider `INTERNAL`.
6. Retrait runtime de `ServiceTruck6.lua`, du storeItem et des dialogues actifs.
7. Complétion `AgriLifeStep8UI.lua` pour comparatif et destination.
8. Filtre commun `isMaintainableAsset()` couvrant explicitement véhicules, remorques, outils, accessoires, chargeurs et masses/poids.
9. Verrou runtime persistant empêchant réellement le redémarrage lors d’une casse lourde.

Statut étape 8 : **socle avancé installé ; nouvelles décisions validées encore partielles**.

## Étape 9 - Finalisation

Scripts présents : réseau, migration, persistance, finalisation, compatibilité, audits et packaging.

Sauvegarde/migration, backup, compatibilité, audits, packaging et infrastructure réseau existent.

Le multijoueur est **installé comme infrastructure mais volontairement désactivé** (`supported=false`, `publicationEnabled=false`, `certified=false`). Ce n'est pas un script manquant.

# Liste finale des scripts runtime non chargés

**Aucun.** Les 13 Lua non actifs sont uniquement les fichiers `tests/*` et ne doivent pas être chargés dans le jeu.

# Conclusion

Le mod n'a pas un problème de scripts oubliés dans l'archive. **Le runtime actuel est complet du point de vue du chargement.**

Les travaux restant à écrire sans attendre un test FS25 sont principalement les complétions de l'étape 8 : remorquage réel, choix de destination, palette physique de commande, cohérence de la réparation interne, suppression du camion de service, limitation du kit terrain, couverture physique des outils/accessoires, filtre des objets maintenables, verrou réel de redémarrage en casse lourde et assurance Atelier/remorquage conforme aux dépenses réelles.

Ces éléments doivent être traités avant de pouvoir considérer le registre des nouvelles idées Atelier comme `Intégrée`.
