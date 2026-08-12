# Changelog - AgriLife Manager

Le détail historique des anciennes builds reste disponible dans l'historique Git. Ce fichier conserve les jalons de la branche actuelle au lieu de recopier toutes les notes 0.6.x.

## 0.8.1.0 TEST - Constats, responsabilité Atelier/Assurance & bonus-malus

- Constat accident enrichi : conducteur séparé de la responsabilité, tiers, circonstances, preuves, décision et recours persistants.
- Responsabilité : responsable, non responsable, partagée ou indéterminée ; aucune indemnisation définitive sans décision exploitable.
- Le devis Atelier final devient la référence de réparation et répartit réellement la charge entre Assurance et exploitation.
- Non responsable : réparation prise en charge par l'Assurance avec recours tiers lorsqu'il existe ; aucun malus.
- Responsable : réparations propres à la charge de l'exploitation selon la règle AgriLife ; la responsabilité civile peut couvrir les dommages tiers.
- Responsabilité partagée : ventilation proportionnelle et demi-malus.
- Contre-expertise/recours : nouvelle décision recalculée sans double pénalité.
- Bonus-malus durable : coefficient 1,00, bonus annuel, malus selon responsabilité, bornes et protection du bonus maximal.
- Les primes véhicule, responsabilité civile et transport suivent réellement le coefficient.
- Historique, persistance, interface Assurance et feuille de route additive mis à jour.
- 76 assertions constats/responsabilité et 51 assertions bonus-malus, avec non-régression des étapes précédentes.
- Certification FS25 réelle volontairement différée.

## 0.8.0.0 TEST - Atelier, Concessionnaire & Gestion technique du parc

- Étape 8 écrite et intégrée côté package.
- Suivi technique de tout le parc : véhicules, machines, outils et accessoires.
- Composants adaptés au matériel, usure/stress et pannes fonctionnelles avec conséquences logiques.
- Diagnostics, symptômes, devis, immobilisation, dépannage et continuité d'activité.
- Pièces OEM, adaptables, reconditionnées et occasion.
- Marché dynamique des pièces branché sur le moteur économique de l'étape 7, avec stock, rareté, pénuries et livraisons standard/prioritaire/express.
- Concessionnaire/SAV, campagnes de rappel et garanties.
- Atelier interne relié aux compétences mécaniques des salariés et au niveau d'infrastructure.
- Révision annuelle obligatoire et contrôle technique tous les deux ans avec défauts et contre-visite.
- Assurance, carnet de vie, valeur de revente et inspection technique des occasions.
- Intégrations optionnelles MudSystem et Advanced Damage System par capacités, sans dépendance dure ni duplication de leur moteur.
- 168 assertions Atelier 8 et 21 assertions inspection occasion, avec non-régression des étapes précédentes.
- Certification FS25 réelle volontairement différée.

## 0.7.9.0 TEST - Contrats & Marchés

- Étape 7 Contrats & Marchés écrite et intégrée.
- Engagements commerciaux, négociation, acheteurs et coopératives.
- Notation A-E, relations acheteurs et conséquences sur les futures opportunités.
- Marchés mondial et locaux dynamiques avec détection maps/multifruits.
- Matériel neuf/occasion avec disponibilité, stock et délais de livraison.
- Intrants, carburants, énergie, foncier, locations et productions/usines.
- Precision Farming et Soil Fertilizer utilisés uniquement comme enrichissements optionnels.
- Feuille de route complète conservée et mise à jour de manière additive.
- Certification FS25 réelle volontairement différée.

## 0.7.8.0 TEST - Administration

- Étape 6 Administration écrite et intégrée.
- Statut d'exploitation évolutif, santé administrative et documents.
- Contrôles, récidive, régularisation, amendes, restrictions et immobilisation.
- Assurance et événements de gestion.
- Contentieux, huissier, plans de paiement, saisie et suspension.
- Restrictions reliées à Banque, Contrats et Entreprise.
- Certification FS25 réelle volontairement différée.

## 0.7.7.0 TEST - Carrière & Qualifications

- Étape 5 écrite et intégrée.
- Fiche de carrière durable et XP selon Facile / Normal / Difficile.
- Séparation stricte XP normal / progression d'examen.
- Examen agricole en 10 étapes avec historique durable.
- Qualifications spécialisées et verrous métier.

## 0.7.6.0 TEST - Entreprise complète

- Étape 4 fermée côté écriture.
- CDI, CDD, saisonniers, horaires, congés, maladie, absences, heures supplémentaires et évolution salariale.
- Une personne = une tâche, centre d'ordres et planning.
- IA native FS25, Courseplay et AutoDrive optionnels avec fallback.
- Paie unique AgriLife.
- XP salarié, recrutement, formations, carrière, incidents et réputation.

## Historique antérieur

Les builds antérieures restent consultables dans l'historique Git.
