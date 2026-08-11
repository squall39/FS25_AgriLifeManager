# Entreprise et main-d'oeuvre - conception AgriLife Manager

Version de référence : **0.7.8.0 TEST**.

Ce document décrit l'architecture retenue pour l'étape 4 Entreprise. L'écriture est complète ; la certification en jeu reste à faire.

## Principe central

**1 salarié disponible = 1 tâche automatisée active maximum.**

AgriLife gère la ressource humaine, son contrat, son coût, son planning, son évolution et son historique. Le moteur d'exécution est ensuite choisi selon le travail et les mods disponibles : IA native FS25, Courseplay ou AutoDrive.

## Contrats et états

Contrats actifs :

- CDI ;
- CDD ;
- saisonnier.

États principaux : disponible, affecté, pause, absent, congé, malade, formation, repos requis et fin de contrat.

La fiche salarié conserve identité, contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, XP, historique de travail, formations, incidents et évolution de carrière.

## Une personne = une tâche

- un salarié ne peut pas avoir deux tâches actives ;
- un véhicule ne peut pas être réservé par deux tâches AgriLife ;
- une tâche terminée, arrêtée ou annulée libère les ressources ;
- après reload, une tâche qui était réellement en cours revient en état contrôlé et demande une reprise au lieu de rester faussement active.

## Centre d'ordres

Flux :

**salarié -> véhicule -> outil -> travail -> champ/destination -> moteur d'exécution**

Les travaux proposés sont filtrés à partir du matériel réellement disponible. AgriLife ne doit jamais annoncer comme exécutable un travail que le moteur sélectionné ne sait pas réaliser.

## Joueur, GPS et salariés AgriLife

Le joueur humain reste distinct des salariés automatisés.

- le Steering Assist/GPS natif reste utilisable ;
- l'embauche directe d'un helper vanilla peut être redirigée lorsque la carrière AgriLife l'exige ;
- les API IA natives restent disponibles pour les tâches lancées par AgriLife ;
- une action réellement conduite par un joueur humain ne consomme pas artificiellement un salarié.

## Paie unique

Payroll reste la source unique de salaire des salariés AgriLife. Le coût d'un helper ou moteur externe est neutralisé ou compensé uniquement pour la tâche AgriLife concernée afin d'éviter une double paie.

Le suivi conserve notamment les heures normales, heures supplémentaires et le coût employeur.

## Courseplay et AutoDrive

Les deux intégrations restent optionnelles et runtime :

- aucun fichier tiers n'est modifié ;
- une API incompatible ne doit pas casser Entreprise ;
- le mode AUTO peut retomber sur l'IA native FS25 ;
- la tâche reste liée à un salarié AgriLife pour le temps, la paie, l'XP et l'historique.

## Progression, recrutement et planning

- XP uniquement sur travail réellement effectué ;
- spécialités et familiarité matériel ;
- marché de recrutement et score d'adéquation ;
- formations avec coût et indisponibilité réelle ;
- planning/file d'ordres ;
- prévision de besoin de main-d'oeuvre et recommandation de saisonniers ;
- incidents et performances intégrés à la carrière du salarié.

## Réputation

La réputation exploitation + dirigeant appartient à Entreprise. Banque, Contrats, Assurance et Administration la consultent sans recréer un second moteur.

## Multijoueur

L'isolation par `farmId`, les permissions et l'autorité serveur sont préparées, mais le multijoueur reste désactivé dans le `modDesc.xml` tant qu'une campagne réseau réelle n'est pas validée.

## Certification restante

La campagne en jeu doit encore vérifier : IA native, Courseplay, AutoDrive, paie, planning, horaires, sauvegarde/rechargement, absence de double affectation et logs propres.

© 2026 Chez_Squall.
