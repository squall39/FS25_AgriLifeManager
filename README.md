# 🌾 AgriLife Manager — Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**  
> AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : banque, conseiller, crédit, carrière, examens, personnel, contrats de travail, société, assurances, atelier, contrats commerciaux, réputation, finances professionnelles et, à terme, contentieux et huissier.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et une exploitation qui possède une véritable mémoire.

---

## 🚜 Le concept

FS25 simule déjà le travail agricole. AgriLife Manager ajoute tout ce qui se passe **autour** : créer son exploitation, choisir sa banque et son conseiller, obtenir un financement, passer des examens pratiques, faire évoluer sa carrière, recruter du personnel, payer ses salariés, organiser le travail, assurer son matériel, entretenir son parc, signer des contrats et construire progressivement la réputation de son entreprise.

L’objectif est que **les décisions prises aujourd’hui puissent encore avoir un impact plusieurs mois plus tard dans la sauvegarde**.

Une exploitation bien gérée doit progressivement obtenir de meilleures conditions bancaires, davantage de confiance, une équipe plus compétente et de meilleures opportunités. À l’inverse, dettes mal maîtrisées, incidents, mauvais choix ou réputation dégradée doivent rendre certaines portes plus difficiles à ouvrir.

---

## ⭐ Les grands systèmes

### 🏦 Banque et financement réellement jouables

Le joueur choisit une banque et un conseiller parmi plusieurs profils différents. Réputation, compétence, relation avec le joueur, endettement, santé de l’entreprise, historique de paiement et objet du financement participent au dossier.

Une demande de crédit n’est pas instantanée : elle est étudiée pendant plusieurs **heures de jeu FS25**. La décision peut être un accord, un accord sous conditions ou un refus.

AgriLife développe parallèlement son propre relevé professionnel avec frais, mouvements, prêts AgriLife, dette FS25 héritée, mensualités et suivi de la capacité d’emprunt.

### 🎓 Carrière, examens et permis agricole

Les examens sont pratiques et se déroulent directement dans la partie avec les vrais véhicules, outils et champs.

Le HUD indique l’étape en cours, l’action exacte attendue, la progression, la note et les erreurs. Chaque étape réussie déclenche un retour visuel et affiche immédiatement la prochaine consigne afin d’éviter de retourner constamment dans les menus.

La carrière et les compétences doivent refléter ce que le joueur réalise réellement en jeu, et non un simple profil choisi artificiellement au lancement.

### 👨‍🌾 Personnel, contrats de travail et ordres de mission

Le module Personnel est conçu autour d’une règle simple : **1 salarié disponible = 1 tâche automatisée active maximum**.

Les salariés auront un véritable contrat : **CDI, CDD ou saisonnier**. Ils disposeront d’un salaire, d’une ancienneté, d’une disponibilité, de spécialités, d’un historique et de compétences qui progresseront avec le travail réellement effectué.

AgriLife doit devenir la source unique de paie afin d’éviter qu’un même travail soit payé une fois par AgriLife et une seconde fois par FS25, Courseplay ou AutoDrive.

Le futur centre d’ordres suivra un flux visuel :

**salarié → véhicule → outil → travail → champ/destination → démarrer**

Sans Courseplay ni AutoDrive, AgriLife pourra utiliser l’IA native FS25 pour les tâches réellement supportées par le jeu.

### 🛰️ Joueur humain : GPS conservé, ouvrier vanilla retiré

À partir de la **0.6.4.25 TEST**, AgriLife commence à séparer clairement le joueur humain de la main-d’œuvre salariée.

Quand une carrière AgriLife est active, le joueur ne doit plus engager directement l’ouvrier natif FS25 avec la commande habituelle. En revanche, le **GPS / Steering Assist natif reste disponible**.

Les fonctions IA de FS25 ne sont pas supprimées : elles restent accessibles à AgriLife pour permettre au futur centre d’ordres de lancer lui-même les tâches des salariés enregistrés.

Cette architecture évite le cafouillage entre helper vanilla, Personnel AgriLife, paie, Courseplay et AutoDrive.

➡️ **[Conception détaillée du système Personnel](docs/WORKFORCE_DESIGN.md)**

### 🏢 Société et administration

Dans les niveaux les plus exigeants, créer et administrer son exploitation fait partie du gameplay. La structure de l’entreprise, sa santé, sa réputation et sa conformité doivent progressivement influencer Banque, contrats, assurances et futurs contentieux.

Le tableau de bord suit l’ordre réel des obligations : **banque → conseiller → société → permis** lorsque ces étapes sont requises.

### 🛡️ Assurances

Le module Assurance doit évoluer vers plusieurs contrats et niveaux de couverture avec primes, franchises, historique de sinistres et conséquences selon le niveau de risque.

### 🔧 Atelier et cycle de vie du matériel

Le matériel doit posséder une histoire économique : achat, utilisation, usure, entretien, réparation, immobilisation et valeur résiduelle. Atelier, Assurance et Banque doivent progressivement communiquer entre eux.

### 🤝 Contrats et coopératives

Le projet vise de véritables engagements commerciaux : volumes, prix, qualité, délais, pénalités, contrats avant semis, plusieurs acheteurs et coopératives, avec impact de la réputation et de l’historique.

### ⚖️ Huissier et contentieux

Les difficultés financières doivent former une chaîne cohérente :

**activité → finances → banque → crédit → incident → relance → négociation → contentieux → réputation**

Un problème bancaire ne doit pas se limiter à un message rouge : AgriLife prévoit retards, mises en demeure, échéanciers, frais, négociation et conséquences durables.

---

## 🎮 Trois niveaux de difficulté

| Niveau | Capital AgriLife | Philosophie générale |
|---|---:|---|
| **Facile** | 200 000 € | Gestion accessible, centrée sur Banque et XP/Carrière |
| **Normal** | 100 000 € | Banque + Personnel + Examens + XP/Carrière |
| **Difficile** | 50 000 € | Expérience complète avec obligations administratives renforcées |

Le niveau choisi est **permanent pour la sauvegarde**. Les modules verrouillés restent visibles afin que le joueur comprenne ce que les difficultés supérieures ajoutent.

Pour une nouvelle carrière, AgriLife fournit son propre capital et neutralise le prêt de départ FS25. Pour une sauvegarde existante, argent, terrains, bâtiments, véhicules et dette existante sont conservés.

---

## 🧠 Une carrière avec une mémoire

AgriLife Manager est construit autour d’une idée importante : la sauvegarde doit conserver l’histoire de l’exploitation.

Historique bancaire, crédit, réputation, carrière, examens, employés, contrats de travail, patrimoine, dette, société et événements doivent survivre aux sauvegardes/rechargements et former progressivement un dossier durable de l’exploitation.

---

## 🔌 Compatibilités prévues

Le cœur du mod doit fonctionner seul.

Les intégrations avec **Courseplay**, **AutoDrive**, **Soil Fertilizer**, Precision Farming et d’autres mods réalistes resteront optionnelles.

Pour Personnel, Courseplay et AutoDrive devront être considérés comme des moteurs d’exécution : **AgriLife garde la ressource humaine, la paie, l’expérience et l’affectation**.

---

## 🖥️ Interface

AgriLife possède une identité sombre et moderne avec cartes, tableaux, étoiles de compétence/réputation, indicateurs financiers et **pictogrammes fonctionnels qui font partie de l’identité du mod**.

La base 1920×1080 est utilisée pour les tests, avec adaptation 1440p et 4K prévue.

---

## 🧪 État actuel du développement

**Version de travail actuelle : 0.6.4.25 TEST**  
**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement privé / builds TEST**

La prochaine session de test doit principalement vérifier : la chaîne complète des examens corrigée depuis 0.6.4.24, le HUD permanent, les transitions d’étapes, le parcours Banque → Conseiller → Société → Permis, et la nouvelle séparation **ouvrier vanilla désactivé / GPS natif conservé**.

La numérotation restera volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas suffisamment terminés et validés.

---

## 🗺️ Feuille de route

Le développement est organisé en grandes phases :

1. Banque & finances
2. Interface & expérience utilisateur
3. Personnel, contrats, ordres de travail & paie
4. Carrière, XP, examens & permis
5. Société & administration
6. Assurances
7. Atelier & cycle de vie du matériel
8. Contrats & coopératives
9. Huissier & contentieux
10. Compatibilités PC optionnelles
11. Sauvegardes, migration & multijoueur
12. Localisation
13. Préparation publication

➡️ **[Consulter la feuille de route complète](ROADMAP.md)**

---

## 📚 Documentation du projet

- **[Feuille de route](ROADMAP.md)** — toutes les phases et fonctionnalités prévues
- **[Fonctionnalités détaillées](FEATURES.md)** — vision complète des systèmes AgriLife
- **[Personnel & main-d’œuvre](docs/WORKFORCE_DESIGN.md)** — contrats, paie, ordres, GPS, Courseplay/AutoDrive et progression des salariés
- **[Changelog](CHANGELOG.md)** — historique des builds TEST
- **[Règles de développement](CONTRIBUTING.md)** — principes de travail du projet
- **[Copyright et distribution](COPYRIGHT.md)** — droits et règles de diffusion

---

## 🌱 Vision

AgriLife Manager veut répondre à une question :

> **Que se passerait-il si Farming Simulator simulait aussi la vie économique et professionnelle d’un exploitant agricole ?**

Acheter une moissonneuse ne devrait pas être seulement une question de prix. Il faudrait aussi se demander si la banque suivra, si la trésorerie absorbera la mensualité, si les salariés sont disponibles, si l’assurance couvrira le risque, si le matériel sera entretenu et si l’investissement permettra réellement de développer l’exploitation.

C’est cette profondeur que le projet cherche à apporter.

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.
