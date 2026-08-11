# Feuille de route - AgriLife Manager

Version de référence : **0.7.8.0 TEST**  
Auteur : **Chez_Squall**

> Règle de développement : un bloc peut être **écrit et intégré** sans être encore **certifié en jeu**. La certification reste distincte et nécessite une campagne FS25 réelle, sauvegarde/rechargement et contrôle du log.

## Principes permanents

- Trois difficultés uniquement : **Facile, Normal, Difficile**.
- Chaque fonctionnalité doit produire une conséquence réelle en jeu.
- Une seule source de vérité par système : pas de moteur métier dupliqué entre modules.
- Compatibilités externes optionnelles et détectées à l'exécution quand c'est possible.
- Pas de liste fixe de maps, cultures ou multifruits lorsque FS25 permet une détection dynamique.
- Toutes les chaînes joueur passent par l10n et les 27 langues distribuées gardent le même jeu de clés.
- La version reste inférieure à `1.0.0.0` jusqu'à la validation globale.
- Le multijoueur reste désactivé tant que la synchronisation réseau n'est pas certifiée.

## État global 0.7.8.0 TEST

| Étape | Écriture / intégration | Certification en jeu |
|---|---|---|
| 1. Démarrage | Intégrée | À terminer |
| 2. Interface de base | Intégrée | À terminer |
| 3. Banque | Intégrée | À terminer |
| 4. Entreprise | Écriture complète | À faire |
| 5. Carrière & Qualifications | Écriture complète | À faire |
| 6. Administration | Écriture complète | À faire |
| 7. Contrats & Marchés | Fondations présentes, passe dédiée à faire | À faire |
| 8. Atelier | Fondations présentes, passe dédiée à faire | À faire |
| 9. Finalisation | Infrastructure présente, fermeture finale à faire | À faire |

---

# 1 - Démarrage

Le Démarrage initialise la sauvegarde, la difficulté et les obligations initiales.

### Facile
- [x] Capital de départ 200 000 €.
- [x] Banque et conseiller facultatifs au démarrage.
- [x] Permis facultatif.
- [x] Accès véhicule libre.
- [ ] Revalider sauvegarde/rechargement complet.

### Normal
- [x] Capital de départ 100 000 €.
- [x] Banque + conseiller obligatoires.
- [x] Permis provisoire 3 mois après validation bancaire.
- [x] Rappel toutes les 6 heures de jeu.
- [x] Amende unique de 500 € sur le compte personnel à expiration.
- [x] État provisoire expiré persistant.
- [ ] Revalider sauvegarde/rechargement après expiration.

### Difficile
- [x] Capital de départ 50 000 € côté code.
- [x] Banque + conseiller obligatoires côté code.
- [x] Examen obligatoire et verrou véhicule côté code.
- [x] Exception pour le matériel de l'examen actif.
- [ ] Refaire la chaîne complète en jeu, y compris sauvegarde/rechargement pendant et après examen.

### Onboarding et isolation
- [x] Tutoriel différé jusqu'au gameplay réel.
- [x] Difficulté permanente par sauvegarde.
- [x] Migration et dette FS25 héritée prises en charge côté code.
- [ ] Revalider ancienne sauvegarde, migration et isolation entre plusieurs carrières.

---

# 2 - Interface de base

L'interface reste une couche commune et non un moteur métier.

- [x] Tableau de bord à 6 cartes : Banque, Entreprise, Carrière & Qualifications, Administration, Contrats & Marchés, Atelier.
- [x] Navigation et vues internes des modules.
- [x] Tutoriel, journal de bord, HUD et messages contextuels.
- [x] l10n généralisée et parité des langues contrôlée.
- [ ] Certifier l'affichage à plusieurs résolutions et échelles UI.
- [ ] Certifier toutes les transitions de pages et états verrouillés en jeu.

---

# 3 - Banque

- [x] Banque et conseiller.
- [x] Comptes professionnel et personnel.
- [x] Crédit, dette héritée, remboursement, refinancement, restructuration et découvert.
- [x] Contrat bancaire et échéances.
- [x] Score de crédit et conséquences de difficulté/réputation.
- [x] Comptabilité, fiscalité, clôture et prévision de trésorerie côté code.
- [x] Restrictions administratives consultées avant nouveau financement.
- [ ] Certifier les scénarios complets de financement, défaut, changement de banque et sauvegarde/rechargement.

---

# 4 - Entreprise

**État : écriture complète dans 0.7.6.0+, certification FS25 à faire.**

## Salariés et contrats
- [x] CDI, CDD et saisonnier.
- [x] Fiche salarié : contrat, ancienneté, salaire, coût employeur, disponibilité, spécialités, XP et historique.
- [x] Horaires, pauses, heures supplémentaires, congés, maladie et absences.
- [x] Promotion, augmentation, renouvellement, fin automatique et licenciement.
- [x] Coûts et tolérances dépendants de la difficulté.

## Une personne = une tâche
- [x] Un salarié = une tâche automatisée active maximum.
- [x] Un véhicule = une tâche AgriLife active maximum.
- [x] Libération automatique à la fin, arrêt ou annulation.
- [x] États disponible, affecté, pause, absent, congé, malade, formation et repos requis.

## Centre d'ordres
- [x] Salarié -> véhicule -> outil -> travail -> champ/destination.
- [x] Filtrage par matériel réellement compatible.
- [x] IA native FS25 pour les travaux supportés.
- [x] Démarrer, pause, reprendre, arrêter/rappeler.
- [x] Planning, file d'ordres et raisons de blocage.
- [x] Aucun travail impossible simulé.

## Paie et exécution
- [x] Payroll reste la source unique de salaire AgriLife.
- [x] Temps de travail réel et heures supplémentaires.
- [x] Neutralisation/compensation ciblée du coût externe sur la seule tâche AgriLife concernée.
- [x] Courseplay optionnel par API runtime.
- [x] AutoDrive optionnel par API runtime.
- [x] Fallback autonome vers FS25.
- [x] Séparation joueur humain / Steering Assist / salarié AgriLife.

## Évolution et réputation
- [x] XP salarié uniquement sur travail réel.
- [x] Spécialités, formations, familiarité matériel, carrière et incidents.
- [x] Recrutement, score candidat et prévision de main-d'oeuvre.
- [x] Réputation exploitation + dirigeant centralisée dans Entreprise.
- [x] Historique, facteurs, reconstruction progressive et effets de difficulté.
- [x] Ponts vers Banque, Contrats, Assurance et Administration.
- [ ] Certifier IA native, Courseplay, AutoDrive, paie, planning et reload en jeu.

---

# 5 - Carrière & Qualifications

**État : écriture complète dans 0.7.7.0+, certification des examens à faire.**

## Carrière & XP
- [x] Fiche durable : heures, hectares, travaux, contrats, incidents, examens, qualifications et étapes importantes.
- [x] Vitesse d'XP selon Facile / Normal / Difficile.
- [x] Séparation stricte entre XP normal et progression d'examen.

## Examens & permis
- [x] Examen agricole en 10 étapes.
- [x] HUD, progression, erreurs et panneau de réussite.
- [x] Permis provisoire Normal et verrou Difficile reliés au Démarrage.
- [x] Frais, tolérance, notation et exigences selon difficulté.
- [x] Tableau de bord : PERMIS OBTENU / RÉUSSI avec score et historique.
- [ ] Certifier l'épreuve 5 cultivation dans la campagne réelle.
- [ ] Certifier les étapes 6/10 à 10/10 : retour, dételage, parking et sortie.
- [ ] Certifier les 10 étapes sur une partie complète en Difficile.

## Qualifications spécialisées
- [x] Phytosanitaire/pulvérisation.
- [x] Manutention/télescopique.
- [x] Forestier.
- [x] Transport agricole.
- [x] Récolte et travaux publics.
- [x] Verrous d'activité quand la difficulté et le métier l'exigent.
- [ ] Certifier les verrous et déblocages avec matériel réel en jeu.

---

# 6 - Administration

**État : écriture complète dans 0.7.8.0, certification FS25 à faire.**

## Société et santé administrative
- [x] Obligations, coûts, formalités et délais selon difficulté.
- [x] Santé administrative consultable par les autres modules.
- [x] Documents administratifs, validité, coût et expiration.

## Statut d'exploitation évolutif
- [x] Petite exploitation -> exploitation professionnelle -> entreprise agricole -> grande entreprise.
- [x] Conditions : expérience, réputation, capital, activité, salariés, permis et conformité.
- [x] Droits, opportunités, capacités et obligations par statut.

## Contrôles et sanctions
- [x] Contrôles de conformité pondérés.
- [x] Vérification permis, assurance, fiscalité, immatriculation, comptes, registre des risques et contentieux selon le contexte.
- [x] Avertissement, régularisation, amende, restriction et immobilisation.
- [x] Historique et récidive.
- [x] Fréquence et sévérité selon difficulté.
- [x] Réputation et comportement antérieur pris en compte.
- [x] Immobilisation avec conséquences réelles sur ordres salariés, contrats et financements.

## Assurance, événements et contentieux
- [x] Obligations d'assurance dynamiques et surprime de risque administratif.
- [x] Événements de gestion avec paiement, contestation ou conséquences.
- [x] Impayés, relances, mise en demeure, huissier, plan de paiement, restriction, saisie et suspension.
- [x] Régularisation réelle obligatoire avant levée de certaines restrictions.
- [ ] Certifier les chaînes contrôle -> sanction -> régularisation et contentieux -> règlement en jeu.

---

# 7 - Contrats & Marchés

**Prochaine passe dédiée. Des fondations existent déjà, mais l'étape n'est pas fermée selon la feuille de route.**

Objectifs :
- contrats commerciaux fixes et indexés ;
- demande dynamique et prix bornés/inertiels ;
- délais, qualité, bonus et pénalités ;
- coopératives/acheteurs et réputation ;
- compatibilité dynamique fillTypes/multifruits/points de vente ;
- foncier, intrants, carburant, location et productions dans une économie commune ;
- conséquences administratives et financières réelles ;
- persistance et certification en jeu.

---

# 8 - Atelier

**Fondations présentes, passe dédiée à faire.**

Objectifs :
- diagnostic, entretien, réparation et immobilisation ;
- pneus, consommables et pièces ;
- stocks et commandes ;
- plans de maintenance ;
- historique économique ;
- valeur résiduelle et valeur de flotte ;
- interactions Assurance, Administration, Entreprise et Marchés ;
- certification avec matériel réel.

---

# 9 - Finalisation

- [ ] Revue complète des 6 modules joueur.
- [ ] Revue du Démarrage et des migrations.
- [ ] Campagne de tests A -> Z Facile / Normal / Difficile.
- [ ] Sauvegarde/rechargement sur chaque grand système.
- [ ] Anciennes sauvegardes et isolation entre carrières.
- [ ] Courseplay / AutoDrive / Precision Farming / Soil Fertilizer selon présence.
- [ ] Logs propres sans erreur pertinente AgriLife.
- [ ] Performance et absence de boucles/coûts excessifs.
- [ ] Validation multijoueur séparée avant réactivation de `supported=true`.
- [ ] Documentation, changelog, GitHub et package joueur alignés.
- [ ] Version 1.0.0.0 uniquement après validation globale.

---

## Priorités validées transversales

1. Réputation de l'exploitation et du dirigeant.
2. Comptabilité et fiscalité.
3. Contrôles administratifs et sanctions.

Ces trois axes sont désormais présents dans le code des étapes 3, 4 et 6. Leur certification réelle reste incluse dans la campagne finale.
