# Conception — Personnel, ouvriers, ordres de travail et paie

Ce document décrit l’architecture retenue pour faire du module Personnel d’AgriLife Manager un véritable système de main-d’œuvre, et non une simple liste de salariés.

## Principe directeur

**1 salarié disponible = 1 tâche automatisée active maximum.**

AgriLife doit devenir la couche de gestion humaine au-dessus de l’IA native FS25, de Courseplay et d’AutoDrive. Le salarié existe d’abord dans AgriLife ; le moteur qui réalise le trajet ou le travail est ensuite choisi selon les outils présents dans la partie.

Le joueur ne doit jamais payer deux fois le même travail. Quand une tâche est associée à un salarié AgriLife, **la paie vient d’AgriLife**. Les coûts d’ouvrier natifs ou tiers doivent être neutralisés uniquement pour cette tâche, via détection/hooks runtime, sans modifier les fichiers de Courseplay ou AutoDrive.

## Contrats de travail

### CDI
- contrat permanent ;
- salaire régulier ;
- période d’essai possible ;
- ancienneté ;
- augmentations et promotions ;
- coût de rupture/licenciement selon les règles AgriLife ;
- priorité pour les postes permanents et salariés très qualifiés.

### CDD
- date/période de début et de fin ;
- salaire négocié ;
- renouvellement possible ;
- transformation possible en CDI ;
- fin automatique à échéance avec alerte préalable.

### Saisonnier
- embauche liée à une campagne ou une période agricole ;
- exemples : semis, ensilage, moisson, pommes de terre, betteraves, vendanges ;
- disponibilité temporaire ;
- coût potentiellement plus élevé en période de forte demande ;
- fin automatique à la fin de la saison/mission prévue ;
- possibilité de réembaucher un saisonnier déjà connu l’année suivante.

### Apprenti
Le statut apprenti peut rester disponible en complément des trois contrats demandés. Il progresse plus lentement au départ, coûte moins cher et peut évoluer vers un autre contrat.

## Fiche salarié

Chaque salarié doit conserver :
- identité ;
- type de contrat ;
- date d’embauche ;
- échéance éventuelle ;
- ancienneté ;
- salaire et coût employeur ;
- disponibilité ;
- statut : disponible / affecté / pause / congé / malade / absent ;
- expérience totale ;
- niveau général ;
- spécialités ;
- historique des tâches ;
- incidents et réussites ;
- véhicules/outils principalement utilisés ;
- formations/certifications éventuelles.

## Compétences et progression

Le salarié progresse **uniquement grâce au travail réellement effectué**.

Spécialités prévues :
- conduite générale ;
- préparation du sol ;
- semis/plantation ;
- fertilisation ;
- pulvérisation ;
- récolte ;
- transport ;
- élevage ;
- mécanique/atelier ;
- manutention/logistique.

La progression peut dépendre du temps de travail utile, du type de tâche, de la réussite, des interruptions, des dégâts et des erreurs. Les étoiles doivent évoluer progressivement et rester cohérentes avec le niveau de salaire.

Un meilleur salarié ne doit pas produire un bonus arcade. Les avantages doivent rester crédibles : meilleure fiabilité, moins d’incidents, plus grande polyvalence, accès à des travaux plus complexes, éventuellement meilleure précision ou meilleure capacité à terminer une tâche sans intervention.

## Centre d’ordres AgriLife

Quand le joueur n’utilise pas Courseplay ou AutoDrive, AgriLife doit permettre d’affecter directement un salarié à une tâche.

Flux visuel cible :

**Salarié → Véhicule → Outil → Travail → Champ/destination → Validation**

Exemples d’ordres :
- cultiver/labourer ;
- semer/planter ;
- fertiliser ;
- pulvériser ;
- faucher/faner/andainer ;
- récolter ;
- transporter ;
- livrer ;
- rejoindre un point ;
- ramener un véhicule à la ferme.

AgriLife doit utiliser l’IA native FS25 lorsqu’elle sait réellement effectuer le travail. Si la tâche n’est pas supportée, l’interface doit le dire au joueur au lieu de simuler un travail fictif.

## Intégration Courseplay

Détection optionnelle uniquement.

Lorsqu’une tâche Courseplay démarre :
1. identifier la ferme et le véhicule ;
2. vérifier s’il existe une affectation AgriLife ;
3. réserver le salarié ;
4. rattacher la tâche Courseplay au salarié ;
5. neutraliser uniquement la facturation de main-d’œuvre correspondante ;
6. suivre temps, état et fin de tâche ;
7. créditer l’expérience du salarié ;
8. libérer le salarié quand Courseplay termine/annule/échoue.

Aucun fichier Courseplay ne doit être modifié sur disque.

## Intégration AutoDrive

Même philosophie que Courseplay :
- un conducteur AutoDrive consomme un salarié AgriLife ;
- une tâche de transport = un salarié occupé ;
- la paie vient d’AgriLife ;
- expérience transport/logistique ;
- retour à l’état disponible à la fin de la tâche ;
- fonctionnement entièrement optionnel.

## Intégration helper FS25

Quand le helper natif est utilisé via AgriLife :
- choisir un salarié disponible ;
- l’affecter au véhicule ;
- laisser FS25 exécuter le travail ;
- empêcher la double facturation ;
- suivre le temps réel de travail ;
- attribuer expérience et historique au salarié.

Si un helper est lancé directement hors du centre AgriLife, une politique devra être choisie : affectation automatique à un salarié libre ou maintien du fonctionnement vanilla avec avertissement. Le comportement doit rester prévisible.

## Interface visuelle

### Cartes salariés
Chaque carte doit montrer au premier coup d’œil :
- pictogramme/portrait ;
- nom ;
- badge CDI / CDD / SAISONNIER / APPRENTI ;
- étoiles ;
- spécialité principale ;
- statut en temps réel ;
- véhicule/tâche si affecté.

### Planning
Vue de planification avec colonnes ou cartes :
- disponibles ;
- en mission ;
- absents ;
- contrats proches de l’échéance.

### Mission en cours
Afficher :
- salarié ;
- véhicule ;
- outil ;
- champ/destination ;
- type de tâche ;
- durée ;
- progression ;
- moteur d’automatisation utilisé : FS25 / Courseplay / AutoDrive ;
- statut et éventuelle anomalie.

## Recrutement — idée complémentaire

Créer à terme un **marché de l’emploi agricole** : plusieurs candidats générés avec niveaux, spécialités, prétentions salariales et disponibilités différentes.

Le joueur ne cliquerait plus seulement sur « recruter CDI » : il pourrait comparer 3 à 6 candidats, choisir un contrat et accepter ou négocier une proposition.

La qualité des candidats disponibles pourrait dépendre de :
- réputation de l’exploitation ;
- salaire proposé ;
- période de l’année ;
- taille/activité de l’entreprise ;
- conditions de travail ;
- historique employeur.

## Formation et certifications — idée complémentaire

Certains travaux complexes pourraient nécessiter une compétence ou une formation interne. Le joueur pourrait payer une formation, immobilisant temporairement le salarié mais améliorant sa spécialité.

Cela créerait un vrai choix : recruter cher un salarié expérimenté ou former un salarié déjà présent.

## Sécurité et compatibilité

- aucun hard dependency Courseplay/AutoDrive ;
- aucune modification permanente de leurs fichiers ;
- détection runtime ;
- si une API tierce change, AgriLife continue de fonctionner seul ;
- jamais de salarié réservé définitivement après crash/arrêt de tâche ;
- récupération des affectations au chargement ;
- autorité serveur en multijoueur ;
- une même personne ne peut pas être utilisée deux fois simultanément.

## Ordre d’implémentation recommandé

1. Contrat saisonnier + affichage visuel des contrats.
2. État salarié et affectation unique persistante.
3. Historique de travail et progression de compétences.
4. Centre d’ordres basé sur l’IA native FS25.
5. Paie unique AgriLife pour les tâches affectées.
6. Intégration Courseplay.
7. Intégration AutoDrive.
8. Marché de l’emploi, formation et planning avancé.
9. Synchronisation multijoueur complète.

---

**Auteur : Chez_Squall**  
**Projet : FS25_AgriLifeManager**
