# Fonctionnalités - AgriLife Manager

État de référence : **0.7.8.0 TEST**.

## Démarrage

- Facile / Normal / Difficile.
- Capital de départ AgriLife.
- Banque et conseiller selon difficulté.
- Permis provisoire Normal et examen obligatoire Difficile.
- Persistance et migration de sauvegarde.

## Banque

- Banque et conseiller.
- Comptes professionnel et personnel.
- Crédit, dette héritée, remboursement, refinancement et découvert.
- Score de crédit, contrats bancaires et prévision de trésorerie.
- Comptabilité et fiscalité.

## Entreprise

- CDI, CDD et saisonnier.
- Horaires, pauses, heures supplémentaires, congés, maladie et absences.
- Une personne = une tâche active.
- Planning et centre d'ordres.
- IA native FS25, Courseplay et AutoDrive optionnels.
- Paie unique AgriLife.
- XP salarié, spécialités, recrutement, formation, carrière et incidents.
- Réputation exploitation + dirigeant.

## Carrière & Qualifications

- Fiche carrière durable et XP par difficulté.
- Examen agricole en 10 étapes.
- Permis et historique des résultats.
- Qualifications phytosanitaire, manutention, forestier, transport, récolte et travaux publics.
- Verrous métier lorsque la difficulté l'exige.

## Administration

- Statut d'exploitation évolutif.
- Santé administrative et documents.
- Contrôles, récidive, régularisation, amendes, restrictions et immobilisation.
- Assurance et événements de gestion.
- Contentieux, huissier, plans de paiement, saisie et suspension.
- Conséquences sur Banque, Contrats et Entreprise.

## Contrats & Marchés

Des fondations sont présentes : marché dynamique, contrats, demande, points de vente et économie commune. La passe dédiée de l'étape 7 reste à fermer avant certification.

## Atelier

Des fondations sont présentes : entretien, réparation, stocks, maintenance et valeur de flotte. La passe dédiée de l'étape 8 reste à fermer.

## Compatibilités

- Courseplay : optionnel.
- AutoDrive : optionnel.
- Precision Farming : détection/capability-gating.
- Soil Fertilizer : détection/capability-gating.
- Maps et fillTypes : détection dynamique privilégiée.

## Multijoueur

Architecture par ferme et autorité serveur préparées, mais le `modDesc.xml` conserve `supported=false` jusqu'à validation réseau réelle.
