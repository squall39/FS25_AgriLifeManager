# 🌾 AgriLife Manager — Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**

AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : banque, conseiller, crédit, carrière, examens, personnel, contrats de travail, société, assurances, atelier, contrats commerciaux, réputation, comptabilité, fiscalité, économie dynamique et, à terme, contrôles administratifs, sanctions et contentieux.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et une exploitation qui possède une véritable mémoire.

> **Principe central : chaque nouvelle fonctionnalité doit produire une conséquence réelle en jeu.**

> [!WARNING]
> **Projet en développement actif.** Le dépôt est public afin de rendre le développement, la documentation et les retours plus accessibles, mais AgriLife Manager n’est pas encore une version finale. Les builds TEST peuvent contenir des fonctions incomplètes ou nécessiter des migrations. La numérotation restera volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.

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

**La difficulté agit sur tout AgriLifeManager**, pas seulement sur le capital de départ. Banque, crédits, examens, XP, personnel, salaires, assurances, atelier, fiscalité, réputation, marchés, contrats, contrôles, sanctions et événements doivent tous consulter le même profil de difficulté enregistré dans la sauvegarde.

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

### 🌍 Économie & marchés dynamiques

AgriLife prévoit un moteur économique commun capable d’influencer :

- le matériel neuf et d’occasion ;
- les outils et accessoires ;
- les palettes, big bags, semences, engrais et autres intrants ;
- le carburant et les énergies détectables ;
- le foncier et les champs ;
- la location de matériel, outils, parcelles et productions/usines lorsque leur gestion est techniquement sûre ;
- les produits agricoles et issus des productions ;
- les contrats, coopératives et débouchés commerciaux.

Le marché doit évoluer avec **offre, demande, saison, disponibilité, événements et historique**, sans fluctuations absurdes ni prix purement aléatoires.

La chaîne économique de référence est :

**sol / pratiques → intrants → coût de production → rendement / qualité → marché mondial → marchés locaux → coopératives / usines → contrats → comptabilité → banque → réputation**

➡️ **[Conception détaillée de l’économie dynamique](docs/DYNAMIC_ECONOMY_AGRONOMY.md)**

### 🤝 Contrats et coopératives

Le projet vise de vrais engagements commerciaux : volumes, prix, qualité, délais, pénalités, contrats avant semis, acheteurs et coopératives multiples.

Les contrats seront reliés au moteur de marché dynamique : demande, cours, volumes recherchés et primes pourront évoluer. La réputation, l’historique et la difficulté resteront également déterminants.

### ⚖️ Huissier et contentieux

Chaîne visée :

**activité → finances → banque → crédit → incident → relance → négociation → contentieux → réputation**

Délais, frais, tolérances et escalade dépendront également du niveau de difficulté.

---

## 🌾 Toutes maps & multifruit — objectif d’architecture

AgriLifeManager ne doit pas dépendre d’une liste fermée de maps ou de cultures.

Le projet vise la détection dynamique des **fruits, fillTypes, produits, points de vente, productions, parcelles et articles magasin** enregistrés dans la partie. Les multifruits correctement enregistrés par une map ou un mod doivent pouvoir être intégrés aux systèmes AgriLife sans ajout manuel systématique.

Lorsqu’un contenu tiers utilise une implémentation non détectable ou non sûre, AgriLife doit l’ignorer proprement plutôt que casser la partie.

---

## 🌱 Precision Farming & Soil Fertilizer

Ces intégrations restent **optionnelles**. AgriLifeManager ne doit pas refaire leur logique agronomique.

Lorsqu’ils sont présents et que leurs données sont accessibles de manière fiable, Precision Farming et Soil Fertilizer pourront enrichir les coûts de production, contrats qualité, primes, réputation, contrôles et rentabilité.

**La difficulté AgriLife modifie les conséquences économiques et administratives, pas artificiellement les lois agronomiques de Precision Farming ou Soil Fertilizer.**

En leur absence, AgriLife doit rester pleinement fonctionnel avec FS25 vanilla.

---

## 🌍 Traductions et clés l10n

AgriLifeManager doit être utilisable proprement dans **toutes les langues distribuées avec le mod**.

- Aucun texte joueur important ne doit rester codé en dur.
- Chaque nouvelle chaîne doit recevoir une clé l10n.
- Tous les fichiers de langue doivent contenir exactement le même jeu de clés.
- Les clés manquantes, doublons, clés inutilisées et fautes de nommage doivent être détectés avant les builds importantes.
- Les nouvelles clés doivent être ajoutées immédiatement à toutes les langues distribuées.
- Une version publiable doit avoir **0 clé manquante, 0 clé brute visible, 0 traduction vide et 0 fallback involontaire**.
- Les traductions doivent respecter une terminologie cohérente pour l’agriculture, la banque, la comptabilité, l’administration, le droit et le personnel.

---

## 🧠 Une carrière avec une mémoire

Historique bancaire, crédit, réputation, carrière, examens, employés, contrats de travail, patrimoine, dette, société, fiscalité, marchés, locations, contrôles et événements doivent survivre aux sauvegardes/rechargements.

Un **Journal de bord AgriLife** est prévu pour conserver les grandes étapes : permis obtenu, salarié embauché, financement majeur, évolution de statut, contrôle, contrat important, sinistre ou autre événement marquant.

---

## 🔌 Compatibilités prévues

Le cœur du mod doit fonctionner seul. Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres intégrations resteront optionnelles.

La compatibilité sera testée progressivement sur plusieurs maps vanilla, modmaps et maps multifruits.

---

## 🖥️ Interface

AgriLife possède une identité sombre et moderne avec cartes, tableaux, étoiles de compétence/réputation, indicateurs financiers et pictogrammes fonctionnels.

Base de test : 1920×1080, avec adaptation 1440p et 4K prévue.

---

## 🧪 État actuel du développement

**Version de travail documentée : 0.6.4.25 TEST**  
**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement public / builds TEST**

La prochaine session de test doit principalement vérifier la chaîne complète des examens corrigée depuis 0.6.4.24, le HUD permanent, la persistance propre à la sauvegarde et la séparation joueur humain / GPS natif / salariés AgriLife.

---

## 🐛 Signaler un problème ou proposer une idée

Le dépôt public peut servir à centraliser les retours utiles au développement.

Pour un bug, merci de fournir autant que possible :

- version AgriLifeManager ;
- version de Farming Simulator 25 ;
- map utilisée ;
- difficulté AgriLife ;
- nouvelle partie ou sauvegarde existante ;
- étapes permettant de reproduire le problème ;
- résultat attendu et résultat obtenu ;
- `log.txt` de la session concernée ;
- autres mods susceptibles d’intervenir.

Utilisez les formulaires GitHub **Bug report** ou **Feature request** afin de garder des retours exploitables.

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
- **[Économie dynamique, multifruit, Precision Farming & Soil Fertilizer](docs/DYNAMIC_ECONOMY_AGRONOMY.md)**
- **[Changelog](CHANGELOG.md)**
- **[Règles de développement et contributions](CONTRIBUTING.md)**
- **[Copyright et distribution](COPYRIGHT.md)**

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.