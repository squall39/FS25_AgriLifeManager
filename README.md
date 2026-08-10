# 🌾 AgriLife Manager — Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**

AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : banque, conseiller, crédit, carrière, examens, personnel, contrats de travail, société, assurances, atelier, contrats commerciaux, réputation, comptabilité, fiscalité et, à terme, contrôles administratifs, sanctions et contentieux.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et une exploitation qui possède une véritable mémoire.

> **Principe central : chaque nouvelle fonctionnalité doit produire une conséquence réelle en jeu.**

---

## 🚜 Le concept

FS25 simule déjà le travail agricole. AgriLife Manager ajoute tout ce qui se passe autour : gérer son exploitation, choisir sa banque et son conseiller, obtenir un financement, passer des examens pratiques, faire évoluer sa carrière, recruter du personnel, payer ses salariés, organiser le travail, assurer son matériel, entretenir son parc, signer des contrats et construire progressivement la réputation de son entreprise.

L’objectif est que **les décisions prises aujourd’hui puissent encore avoir un impact plusieurs mois plus tard dans la sauvegarde**.

---

## 🎮 Trois difficultés uniquement

AgriLife Manager conserve **uniquement trois niveaux : Facile, Normal et Difficile**.

| Niveau | Capital de départ | Philosophie |
|---|---:|---|
| **Facile** | 200 000 € | Gestion accessible, tolérances plus larges, coûts et sanctions réduits. |
| **Normal** | 100 000 € | Réglage de référence, expérience complète et équilibrée. |
| **Difficile** | 50 000 € | Contraintes, coûts, risques, contrôles et conséquences renforcés. |

**La difficulté agit sur tout AgriLifeManager**, pas seulement sur le capital de départ. Banque, crédits, examens, XP, personnel, salaires, assurances, atelier, fiscalité, réputation, contrats, contrôles, sanctions et événements doivent tous consulter le même profil de difficulté enregistré dans la sauvegarde.

Le niveau choisi est permanent pour la carrière.

---

## ⭐ Les grands systèmes

### 🏦 Banque et financement

Banque, conseiller, réputation, compétence, relation avec le joueur, endettement, santé de l’entreprise, historique de paiement, objet du financement et difficulté participent au dossier.

Une demande de crédit est étudiée pendant plusieurs heures de jeu FS25 et peut être acceptée, refusée ou conditionnée. Taux, plafond, garanties, frais et délais doivent varier selon le dossier et le niveau choisi.

### 🎓 Carrière, XP, examens et permis

Les examens sont pratiques et se déroulent directement dans la partie avec les vrais véhicules, outils et champs.

Le HUD indique l’étape, l’action attendue, la progression, la note et les erreurs. La difficulté doit influer sur les frais d’inscription, les tolérances, la notation et les exigences.

La carrière et les compétences reflètent le travail réellement effectué et non un profil artificiel choisi au lancement.

### 👨‍🌾 Personnel, contrats de travail et ordres de mission

Principe central : **1 salarié disponible = 1 tâche automatisée active maximum**.

Les salariés auront des contrats CDI, CDD ou saisonniers, avec salaire, ancienneté, disponibilité, spécialités, historique et compétences progressant avec le travail réel.

AgriLife doit devenir la source unique de paie afin d’éviter toute double facturation par FS25, Courseplay ou AutoDrive.

Le futur centre d’ordres suivra :

**salarié → véhicule → outil → travail → champ/destination → démarrer**

### 🛰️ Joueur humain, GPS et ouvriers

À partir de la 0.6.4.25 TEST, AgriLife sépare clairement le joueur humain de la main-d’œuvre salariée. Le **GPS / Steering Assist natif reste disponible**, tandis que la main-d’œuvre automatisée doit être rattachée au système Personnel AgriLife.

➡️ **[Conception détaillée du système Personnel](docs/WORKFORCE_DESIGN.md)**

### 🏢 Société, administration et statuts

La société doit devenir un vrai élément de gameplay, avec obligations, coûts, conformité et conséquences variant selon Facile / Normal / Difficile.

À terme, l’exploitation pourra évoluer :

**petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**

Cette évolution dépendra de l’expérience, de la réputation, du capital, des examens, de la conformité et de l’activité réellement réalisée.

### ⭐ Réputation de l’exploitation

La réputation est le **premier grand système à développer après stabilisation**. Elle évoluera selon contrats, retards, dettes, incidents, examens, qualité du travail, conformité et gestion générale.

Elle influencera Banque, Conseiller, Contrats, Coopératives, Assurance et futurs contentieux. Gains, pertes et seuils varieront selon la difficulté.

### 📊 Comptabilité & fiscalité

Deuxième grande priorité après stabilisation : chiffre d’affaires, charges, salaires, assurances, intérêts, entretien, résultat, actifs, dettes, amortissements et historique pluriannuel.

Fiscalité, échéances, séparation pro/perso et conséquences d’impayé seront adaptées à Facile / Normal / Difficile.

### 🧾 Contrôles administratifs & sanctions

Troisième grande priorité après stabilisation. Les contrôles vérifieront les obligations réellement applicables à la carrière : documents, permis, assurances, conformité et autres exigences.

Fréquence, seuils, avertissements, délais de régularisation, amendes, immobilisations et récidives dépendront de la difficulté.

### 🛡️ Assurances

Contrats, primes, franchises, exclusions et couverture évolueront selon risque, historique, réputation et difficulté.

### 🔧 Atelier et cycle de vie du matériel

Le matériel doit posséder une histoire économique : achat, utilisation, usure, entretien, réparation, immobilisation et valeur résiduelle. Coûts et conséquences seront adaptés au niveau choisi.

### 🤝 Contrats et coopératives

Le projet vise de vrais engagements commerciaux : volumes, prix, qualité, délais, pénalités, contrats avant semis, acheteurs et coopératives multiples.

Les contrats recevront une notation influençant réputation et futures offres, avec exigences et pénalités dépendant de la difficulté.

### ⚖️ Huissier et contentieux

Chaîne visée :

**activité → finances → banque → crédit → incident → relance → négociation → contentieux → réputation**

Délais, frais, tolérances et escalade dépendront également du niveau de difficulté.

---

## 🌍 Traductions et clés l10n

AgriLifeManager doit être utilisable proprement dans **toutes les langues distribuées avec le mod**.

- Aucun texte joueur important ne doit rester codé en dur.
- Chaque nouvelle chaîne doit recevoir une clé l10n.
- Tous les fichiers de langue doivent contenir exactement le même jeu de clés.
- Les clés manquantes, doublons, clés inutilisées et fautes de nommage doivent être détectés avant les builds importantes.
- Les nouvelles clés doivent être ajoutées immédiatement à toutes les langues distribuées.
- Une version publique doit avoir **0 clé manquante, 0 clé brute visible, 0 traduction vide et 0 fallback involontaire**.
- Les traductions doivent respecter une terminologie cohérente pour l’agriculture, la banque, la comptabilité, l’administration, le droit et le personnel.

La feuille de route prévoit aussi l’extension progressive aux langues pertinentes de FS25/ModHub afin que le mod soit accessible au plus grand nombre.

---

## 🧠 Une carrière avec une mémoire

Historique bancaire, crédit, réputation, carrière, examens, employés, contrats de travail, patrimoine, dette, société, fiscalité, contrôles et événements doivent survivre aux sauvegardes/rechargements.

Un **Journal de bord AgriLife** est prévu pour conserver les grandes étapes : permis obtenu, salarié embauché, financement majeur, évolution de statut, contrôle, contrat important, sinistre ou autre événement marquant.

---

## 🔌 Compatibilités prévues

Le cœur du mod doit fonctionner seul. Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres intégrations resteront optionnelles.

---

## 🖥️ Interface

AgriLife possède une identité sombre et moderne avec cartes, tableaux, étoiles de compétence/réputation, indicateurs financiers et pictogrammes fonctionnels.

Base de test : 1920×1080, avec adaptation 1440p et 4K prévue.

---

## 🧪 État actuel du développement

**Version de travail documentée : 0.6.4.25 TEST**  
**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement privé / builds TEST**

La prochaine session de test doit principalement vérifier la chaîne complète des examens corrigée depuis 0.6.4.24, le HUD permanent, la persistance propre à la sauvegarde et la séparation joueur humain / GPS natif / salariés AgriLife.

La numérotation restera volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas suffisamment terminés et validés.

---

## 🗺️ Feuille de route

Après stabilisation :

1. **Réputation de l’exploitation**
2. **Comptabilité & fiscalité**
3. **Contrôles administratifs & sanctions**

➡️ **[Consulter la feuille de route complète](ROADMAP.md)**

---

## 📚 Documentation

- **[Feuille de route](ROADMAP.md)**
- **[Fonctionnalités détaillées](FEATURES.md)**
- **[Personnel & main-d’œuvre](docs/WORKFORCE_DESIGN.md)**
- **[Changelog](CHANGELOG.md)**
- **[Règles de développement](CONTRIBUTING.md)**
- **[Copyright et distribution](COPYRIGHT.md)**

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.