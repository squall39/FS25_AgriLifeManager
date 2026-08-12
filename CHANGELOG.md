# Changelog - AgriLife Manager

Le détail historique des anciennes builds reste disponible dans l'historique Git. Ce fichier conserve les principaux jalons de la branche actuelle.

## 0.9.1.0 TEST - Synchronisation des idées validées

- Registre maître additif des idées et de leur état.
- Règle permanente conversation -> roadmap -> tutoriel/Assistance -> GitHub -> build.
- Flux Atelier validé : remorquage, palettes de pièces, réparation maison et assurance cohérente.
- Camion de service joueur marqué `À intégrer` pour suppression ; kit terrain limité aux urgences.

## 0.9.1.0 TEST - Tutoriel, Assistance et localisation

- Guide de départ reconstruit en 13 sujets suivant l'ordre réel d'une carrière AgriLife.
- Explications harmonisées pour Banque, Entreprise, comptabilité/fiscalité, Carrière/Qualifications, personnel, Administration, Contrats/Marchés, Assurance, Atelier, parc, leasing, occasion, journal et sauvegarde.
- Règles Facile / Normal / Difficile alignées sur le code actif : tous les grands modules restent accessibles ; les obligations, coûts, tolérances, délais et conséquences varient selon le mode.
- Assistance FS25 reconstruite sur les mêmes clés l10n que le tutoriel afin d'éviter toute divergence future.
- Suppression des textes français codés en dur dans l'Assistance.
- 27 langues alignées à 5 047 clés, sans clé manquante, valeur vide, doublon ni placeholder incompatible.
- Audit linguistique ajouté pour distinguer la parité structurelle des anciennes chaînes nécessitant encore une relecture humaine.
- Gate de release mis à jour pour contrôler les 13 rubriques et leur présence dans l'Assistance.

## 0.9.1.0 TEST - Fermeture de l'écriture fonctionnelle

- Les derniers scripts métier identifiés dans Démarrage, Interface et Banque sont écrits et intégrés.
- Banque enrichie avec consultation d'offres, profils de risque/solidité/sévérité, compatibilité conseiller et influence des marchés sur le financement.
- Décisions de crédit enrichies avec facteurs marché, comptabilité, séparation pro/perso et capacité réelle.
- Grand livre économique enrichi avec métadonnées persistantes : contrepartie, fournisseur, contrat/référence, type de flux et tags.
- Filtres comptables par période, catégorie, fournisseur, contrat, type de flux, source et tags.
- Compte de résultat corrigé pour séparer exploitation, investissement, financement et capitaux propres.
- Amortissements, bilan simplifié, fiscalité, capacité d'autofinancement, couverture du service de dette et rentabilité par activité.
- Tableau de bord Banque/Carrière enrichi.
- Politique responsive prudente 1080p/1440p/4K et affichage monétaire professionnel au centime.
- 27 langues alignées à 5 019 clés.
- Roadmap maître et `modDesc.xml` synchronisés exactement avec le package.
- **Écriture fonctionnelle hors tests : 100 % pour Facile, Normal et Difficile.**
- Certification FS25 réelle volontairement séparée de cet état d'écriture.

## 0.9.0.0 TEST - Finalisation

- Étape 9 Finalisation écrite et intégrée côté infrastructure.
- Schéma de sauvegarde 4, migration 3 vers 4, identité de carrière et récupération backup.
- Isolation multi-fermes et squelette réseau serveur autoritaire non publié.
- Audits compatibilités, l10n et publication.
- Tutoriel paginé rebasé, documentation utilisateur et packaging TEST/PUBLIC.

## 0.8.1.0 TEST - Constats, responsabilité et bonus-malus

- Constat unique relié à la responsabilité, l'Atelier et l'Assurance.
- Répartition responsable / non responsable / partagée / indéterminée.
- Devis Atelier comme référence de règlement.
- Bonus-malus durable et primes futures reliées à la responsabilité.

## 0.8.0.0 TEST - Atelier et Concessionnaire

- Gestion technique du parc, pannes fonctionnelles, pièces, délais, révisions et contrôle technique.
- Marché dynamique des pièces et intégrations optionnelles MudSystem / Advanced Damage System.

## 0.7.9.0 TEST - Contrats & Marchés

- Contrats commerciaux, acheteurs, coopératives, marchés dynamiques, multifruits, neuf/occasion, intrants, énergie, foncier, locations et productions.

## 0.7.8.0 TEST - Administration

- Statut, conformité, contrôles, sanctions, assurance et contentieux.

## 0.7.7.0 TEST - Carrière & Qualifications

- Carrière durable, XP, permis, examens et qualifications spécialisées.

## 0.7.6.0 TEST - Entreprise complète

- RH, paie, ordres, IA, planning, XP salarié, recrutement, incidents et réputation.

## Historique antérieur

Les builds antérieures restent consultables dans l'historique Git.
