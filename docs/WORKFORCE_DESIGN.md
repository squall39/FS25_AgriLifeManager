# Personnel & main-d’œuvre — conception AgriLife Manager

Ce document fixe la conception du futur système Personnel. Le principe central est simple : **les salariés AgriLife sont de vraies ressources de travail, avec un contrat, un coût, des compétences, une disponibilité et une affectation réelle.**

## 1. Une personne = une tâche

Un salarié disponible ne peut exécuter qu’une seule tâche automatisée à la fois.

États prévus :
- disponible ;
- affecté ;
- en pause ;
- absent ;
- en congé ;
- malade ;
- indisponible temporairement.

Une tâche terminée, arrêtée ou annulée libère automatiquement le salarié.

## 2. Contrats de travail

Trois contrats seront proposés :

### CDI
Emploi permanent, salaire régulier, ancienneté, évolution salariale, promotions et coût de rupture selon les règles AgriLife.

### CDD
Date de début et de fin, salaire défini, renouvellement possible et transformation éventuelle en CDI.

### Saisonnier
Contrat temporaire pour une campagne : semis, récolte, ensilage, vendanges ou autre période de forte activité.

Chaque salarié disposera d’une fiche comprenant son contrat, son ancienneté, son salaire, son coût employeur, ses spécialités, ses compétences, sa disponibilité et son historique.

## 3. AgriLife devient la source unique de paie

Lorsqu’un salarié AgriLife est affecté à une tâche automatisée, **AgriLife doit être le seul système qui calcule son salaire**.

Objectif : empêcher la double facturation entre :
- AgriLife ;
- l’ouvrier vanilla FS25 ;
- Courseplay ;
- AutoDrive lorsque sa logique entraîne un coût de main-d’œuvre.

Les intégrations devront neutraliser uniquement le coût de main-d’œuvre concerné, sans modifier les fichiers de Courseplay ou AutoDrive. Elles seront réalisées par détection et hooks afin de rester aussi robustes que possible aux mises à jour externes.

Si une intégration devient incompatible, AgriLife doit revenir proprement au fonctionnement autonome au lieu de casser la sauvegarde ou le module Personnel.

## 4. Centre d’ordres AgriLife

Même sans Courseplay ni AutoDrive, le joueur doit pouvoir donner un ordre directement depuis AgriLife.

Flux visuel retenu :

**salarié → véhicule → outil → travail → champ ou destination → démarrer**

AgriLife utilisera l’IA native FS25 lorsque le travail demandé est réellement supporté par le jeu.

Exemples :
- préparation du sol ;
- labour ;
- semis ;
- fertilisation ;
- pulvérisation ;
- récolte ;
- transport ;
- autres travaux compatibles détectés.

L’interface ne doit jamais faire croire qu’une tâche est exécutable si le moteur FS25 ne sait pas la réaliser.

## 5. Tableau d’affectation visuel

Pendant une tâche, l’écran Personnel devra montrer immédiatement :
- salarié ;
- type de contrat ;
- état ;
- véhicule ;
- outil ;
- travail ;
- champ ou destination ;
- progression ;
- durée de travail ;
- coût de la tâche ;
- éventuels incidents.

Les cartes salariés conserveront les pictogrammes AgriLife, les étoiles, les spécialités et des badges CDI / CDD / SAISONNIER.

## 6. Expérience et évolution réelle

Un salarié gagne de l’expérience uniquement lorsqu’il travaille réellement.

Spécialités prévues :
- conduite ;
- préparation du sol ;
- semis ;
- fertilisation et protection des cultures ;
- récolte ;
- transport ;
- élevage ;
- mécanique / entretien ;
- autres spécialisations ajoutées selon le gameplay.

La progression dépendra du temps réellement travaillé, de la nature des tâches, de leur réussite et des incidents éventuels. Les étoiles pourront évoluer progressivement.

Le niveau de compétence pourra influencer la fiabilité, l’accès à certaines tâches et le salaire, sans transformer les salariés expérimentés en bonus irréalistes.

## 7. Idées complémentaires retenues pour étude

### Marché du recrutement
Créer un vrai vivier de candidats avec salaire demandé, spécialités, expérience et type de contrat recherché. Tous les candidats ne seraient pas disponibles en permanence.

### Qualifications et formations
Certaines tâches pourraient exiger une qualification : traitement phytosanitaire, transport lourd, conduite de certaines machines ou maintenance avancée. Une formation coûterait du temps et de l’argent mais resterait acquise au salarié.

### Feuille d’heures
Conserver les heures normales, heures supplémentaires, pauses et historique mensuel. La paie devient vérifiable depuis le compte professionnel.

### Planning et file d’ordres
Permettre de préparer une tâche à l’avance. Si le salarié ou le matériel est occupé, l’ordre reste planifié et démarre lorsque les conditions sont réunies, si le joueur l’autorise.

### Familiarité avec le matériel
Un salarié utilisant régulièrement une même catégorie de machine pourrait devenir plus fiable avec cette catégorie sans obtenir de gain de vitesse artificiel excessif.

### Incidents et responsabilité
Dégâts matériels, tâche interrompue ou mauvaise exécution pourraient alimenter l’historique du salarié et interagir plus tard avec Atelier, Assurance et réputation de l’entreprise.

### Entretiens et évolution de carrière
Ancienneté, très bonnes performances ou nouvelles qualifications pourraient déclencher une demande d’augmentation, une promotion ou un changement de poste.

## 8. Courseplay / AutoDrive / FS25

### FS25 natif
Une tâche IA native liée à un salarié AgriLife consomme ce salarié et la paie vanilla correspondante doit être neutralisée pour éviter le double paiement.

### Courseplay
Chaque driver/tâche Courseplay doit être associé à un salarié AgriLife disponible. Courseplay reste le moteur d’exécution ; AgriLife gère la ressource humaine, son coût et son évolution.

### AutoDrive
Même principe pour les tâches de conduite/transport : un conducteur AgriLife doit être disponible et réellement affecté.

Aucune de ces intégrations ne devient une dépendance obligatoire.

## 9. Multijoueur

Les joueurs humains représentent une main-d’œuvre réelle et ne doivent pas être comptés deux fois. Une tâche conduite par un joueur humain ne consomme pas artificiellement un salarié AgriLife.

## Ordre d’implémentation proposé

1. contrats CDI / CDD / saisonnier ;
2. état et disponibilité des salariés ;
3. moteur d’affectation une personne = une tâche ;
4. paie unique AgriLife et neutralisation du coût vanilla ;
5. centre d’ordres basé sur l’IA native FS25 ;
6. expérience et spécialités ;
7. intégration Courseplay ;
8. intégration AutoDrive ;
9. recrutement, formations, planning et incidents ;
10. multijoueur complet.

Ce chantier sera développé par étapes afin de ne pas déstabiliser les autres systèmes. La priorité immédiate reste la validation complète de la build 0.6.4.24 et de la chaîne d’examen avant d’ouvrir une grosse phase Personnel.

© 2026 Chez_Squall.