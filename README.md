# 🌾 AgriLife Manager — Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**  
> AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : banque, conseiller, crédit, carrière, examens, personnel, contrats de travail, société, assurances, atelier, contrats commerciaux, réputation, comptabilité, fiscalité et, à terme, contrôles administratifs, sanctions et contentieux.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et une exploitation qui possède une véritable mémoire.

> **Principe central : chaque nouvelle fonctionnalité doit produire une conséquence réelle en jeu.**

---

## 🚜 Le concept

FS25 simule déjà le travail agricole. AgriLife Manager ajoute tout ce qui se passe **autour** : gérer son exploitation, choisir sa banque et son conseiller lorsque le niveau l’exige, obtenir un financement, passer des examens pratiques, faire évoluer sa carrière, recruter du personnel, payer ses salariés, organiser le travail, assurer son matériel, entretenir son parc, signer des contrats et construire progressivement la réputation de son entreprise.

L’objectif est que **les décisions prises aujourd’hui puissent encore avoir un impact plusieurs mois plus tard dans la sauvegarde**.

Une exploitation bien gérée doit progressivement obtenir de meilleures conditions bancaires, davantage de confiance, une équipe plus compétente et de meilleures opportunités. À l’inverse, dettes mal maîtrisées, incidents, mauvais choix, défauts de conformité ou réputation dégradée doivent avoir des conséquences identifiables et durables.

---

## ⭐ Les grands systèmes

### 🏦 Banque et financement réellement jouables

Le joueur peut entrer dans une vraie relation bancaire AgriLife. Banque, conseiller, réputation, compétence, relation avec le joueur, endettement, santé de l’entreprise, historique de paiement et objet du financement participent au dossier.

Une demande de crédit n’est pas instantanée : elle est étudiée pendant plusieurs **heures de jeu FS25**. La décision peut être un accord, un accord sous conditions ou un refus.

AgriLife développe parallèlement son propre relevé professionnel avec frais, mouvements, prêts AgriLife, dette FS25 héritée, mensualités et suivi de la capacité d’emprunt.

### 🎓 Carrière, examens et permis agricole

Les examens sont pratiques et se déroulent directement dans la partie avec les vrais véhicules, outils et champs.

Le HUD indique l’étape en cours, l’action exacte attendue, la progression, la note et les erreurs. Chaque étape réussie déclenche un retour visuel et affiche immédiatement la prochaine consigne afin d’éviter de retourner constamment dans les menus.

La carrière et les compétences doivent refléter ce que le joueur réalise réellement en jeu, et non un simple profil choisi artificiellement au lancement.

Le permis agricole est une obligation de progression dans les niveaux **Réaliste et Strict**.

### 👨‍🌾 Personnel, contrats de travail et ordres de mission

Le module Personnel est conçu autour d’une règle simple : **1 salarié disponible = 1 tâche automatisée active maximum**.

Les salariés auront un véritable contrat : **CDI, CDD ou saisonnier**. Ils disposeront d’un salaire, d’une ancienneté, d’une disponibilité, de spécialités, d’un historique et de compétences qui progresseront avec le travail réellement effectué.

AgriLife doit devenir la source unique de paie afin d’éviter qu’un même travail soit payé une fois par AgriLife et une seconde fois par FS25, Courseplay ou AutoDrive.

Le futur centre d’ordres suivra un flux visuel :

**salarié → véhicule → outil → travail → champ/destination → démarrer**

Sans Courseplay ni AutoDrive, AgriLife pourra utiliser l’IA native FS25 pour les tâches réellement supportées par le jeu.

### 🛰️ Joueur humain : GPS conservé, ouvrier vanilla séparé

À partir de la **0.6.4.25 TEST**, AgriLife commence à séparer clairement le joueur humain de la main-d’œuvre salariée.

Quand une carrière AgriLife est active, le joueur ne doit plus engager directement un ouvrier natif comme s’il s’agissait d’une ressource humaine gratuite et indépendante du système Personnel. En revanche, le **GPS / Steering Assist natif reste disponible**.

Les fonctions IA de FS25 ne sont pas supprimées : elles restent accessibles à AgriLife pour permettre au futur centre d’ordres de lancer lui-même les tâches des salariés enregistrés.

Cette architecture évite le cafouillage entre helper vanilla, Personnel AgriLife, paie, Courseplay et AutoDrive.

➡️ **[Conception détaillée du système Personnel](docs/WORKFORCE_DESIGN.md)**

### 🏢 Société, statuts et administration

En **Réaliste et Strict**, créer et administrer son exploitation fait partie du gameplay. Société et permis agricole deviennent de vraies obligations de démarrage.

À terme, l’exploitation doit pouvoir évoluer par statuts :

**petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**

Cette évolution dépendra de l’expérience, de la réputation, du capital, des examens, de la conformité et de l’activité réellement réalisée.

### ⭐ Réputation de l’exploitation

La réputation devient le **premier grand système à développer après la stabilisation des builds actuelles**.

Elle doit évoluer selon les contrats terminés, retards, dettes, incidents, examens, qualité du travail, conformité et gestion générale. Elle influencera notamment Banque, Conseiller, Contrats, Coopératives, Assurance et futurs contentieux.

### 📊 Comptabilité & fiscalité

La comptabilité/fiscalité est la **deuxième grande priorité après stabilisation**.

AgriLife doit suivre chiffre d’affaires, charges, salaires, assurances, intérêts, entretien, résultat, actifs, dettes et historique pluriannuel. Les niveaux les plus exigeants devront imposer une séparation professionnelle/personnelle plus contraignante et de vraies échéances fiscales.

### 🧾 Contrôles administratifs & sanctions

Les contrôles administratifs sont la **troisième grande priorité après stabilisation**.

Un contrôle pourra vérifier les obligations réellement applicables à la difficulté choisie : permis, assurance, documents, conformité ou autres exigences. Les conséquences pourront aller de l’avertissement à l’amende ou à l’immobilisation selon la gravité, avec une cause toujours compréhensible par le joueur.

### 🛡️ Assurances

Le module Assurance doit évoluer vers plusieurs contrats et niveaux de couverture avec primes, franchises, historique de sinistres et conséquences selon le niveau de risque.

### 🔧 Atelier et cycle de vie du matériel

Le matériel doit posséder une histoire économique : achat, utilisation, usure, entretien, réparation, immobilisation et valeur résiduelle. Atelier, Assurance et Banque doivent progressivement communiquer entre eux.

### 🤝 Contrats et coopératives

Le projet vise de véritables engagements commerciaux : volumes, prix, qualité, délais, pénalités, contrats avant semis, plusieurs acheteurs et coopératives, avec impact de la réputation et de l’historique.

Les contrats devront également recevoir une notation selon le respect des conditions, la qualité et les incidents, avec effet sur les futures opportunités.

### ⚖️ Huissier et contentieux

Les difficultés financières doivent former une chaîne cohérente :

**activité → finances → banque → crédit → incident → relance → négociation → contentieux → réputation**

Un problème bancaire ou fiscal ne doit pas se limiter à un message rouge : AgriLife prévoit retards, mises en demeure, échéanciers, frais, négociation et conséquences durables.

---

## 🎮 Difficultés — cible fonctionnelle

La conception cible distingue **Libre, Facile, Réaliste et Strict**.

| Obligation de démarrage | Libre | Facile | Réaliste | Strict |
|---|---:|---:|---:|---:|
| Banque + conseiller obligatoires | Non | Non | Oui | Oui |
| Création de la société obligatoire | Non | Non | Oui | Oui |
| Permis agricole obligatoire | Non | Non | Oui | Oui |

Les systèmes peuvent rester accessibles dans les niveaux plus souples sans y être imposés. **Réaliste** vise une gestion complète et crédible ; **Strict** conserve la même logique avec des exigences, coûts, pénalités et conséquences plus lourds.

Le niveau choisi est permanent pour la sauvegarde.

---

## 🧠 Une carrière avec une mémoire

AgriLife Manager est construit autour d’une idée importante : la sauvegarde doit conserver l’histoire de l’exploitation.

Historique bancaire, crédit, réputation, carrière, examens, employés, contrats de travail, patrimoine, dette, société, fiscalité, contrôles et événements doivent survivre aux sauvegardes/rechargements et former progressivement un dossier durable de l’exploitation.

Un **Journal de bord AgriLife** est prévu pour retracer les grandes étapes : permis obtenu, salarié embauché, premier gros financement, évolution de statut, contrôle, contrat important ou autre événement marquant.

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

**Version de travail documentée : 0.6.4.25 TEST**  
**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement privé / builds TEST**

La prochaine session de test doit principalement vérifier : la chaîne complète des examens corrigée depuis 0.6.4.24, le HUD permanent, les transitions d’étapes, la persistance propre à la sauvegarde et la nouvelle séparation **joueur humain / GPS natif / salariés AgriLife**.

La numérotation restera volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas suffisamment terminés et validés.

---

## 🗺️ Feuille de route

Après stabilisation de la base actuelle, les trois priorités validées sont :

1. **Réputation de l’exploitation**
2. **Comptabilité & fiscalité**
3. **Contrôles administratifs & sanctions**

La feuille de route détaillée couvre ensuite Personnel, Carrière/Examens, statuts d’exploitation, Assurances, Atelier, Contrats/Coopératives, Contentieux, compatibilités, sauvegardes/multijoueur, localisation et préparation publication.

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

Acheter une moissonneuse ne devrait pas être seulement une question de prix. Il faudrait aussi se demander si la banque suivra, si la trésorerie absorbera la mensualité, si les salariés sont disponibles, si l’assurance couvrira le risque, si le matériel sera entretenu, si l’exploitation est en conformité et si l’investissement permettra réellement de se développer.

C’est cette profondeur que le projet cherche à apporter.

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.
