# 🌾 AgriLife Manager — Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**  
> AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : choix de difficulté, banque, conseiller, crédit, carrière, examens, personnel, société, assurances, atelier, contrats, réputation, finances professionnelles et, à terme, contentieux et huissier.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et qui obligent le joueur à gérer son exploitation comme une vraie entreprise agricole.

---

## 🚜 Le concept

Dans FS25, vous savez déjà semer, fertiliser, récolter, transporter et investir dans du matériel. AgriLife Manager ajoute tout ce qui se passe **autour** de ce travail : obtenir son permis agricole, faire progresser sa carrière, choisir une banque et un conseiller, demander un financement, payer ses charges, employer du personnel, gérer sa société, suivre son compte professionnel, faire face aux incidents et construire progressivement sa réputation.

L’objectif est simple : **faire en sorte qu’une décision prise aujourd’hui puisse encore avoir un impact plusieurs mois plus tard dans la sauvegarde.**

Une exploitation bien gérée doit progressivement obtenir de meilleures conditions bancaires, davantage de confiance, de meilleures opportunités commerciales et une situation financière plus solide. À l’inverse, de mauvais choix, des dettes mal maîtrisées, des incidents de paiement, des erreurs professionnelles ou une réputation dégradée doivent fermer des portes et rendre la partie plus difficile.

---

## ⭐ Pourquoi AgriLife Manager est différent

### 🏦 Banque et financement réellement jouables

Le joueur choisit sa banque et son conseiller parmi plusieurs profils différents. Chaque établissement possède ses propres caractéristiques, tandis que les conseillers disposent de leur propre réputation et compétence.

Une demande de crédit n’est pas accordée instantanément : elle est étudiée pendant plusieurs **heures de jeu FS25**. Le résultat dépend du dossier du joueur, de son niveau de difficulté, de son endettement, de sa réputation, de la santé de son entreprise, de la relation bancaire et de l’objet du financement.

Le système est prévu pour produire plusieurs résultats : accord, accord sous conditions ou refus. Les taux, plafonds, garanties, durées et conditions doivent progressivement devenir eux aussi dépendants du profil bancaire et du dossier.

### 💳 Véritable compte professionnel

AgriLife Manager développe son propre environnement financier avec compte professionnel, mouvements, catégories, frais bancaires, prêts AgriLife, dette FS25 héritée, capacité d’emprunt et suivi du coût réel des financements.

L’objectif à terme est que la page Banque d’AgriLife devienne le véritable centre financier de la ferme : relevé professionnel, historique détaillé, prévisions de trésorerie, refinancement, mensualités, intérêts, frais et incidents.

### 🎓 Carrière, examens et permis agricole

En difficulté élevée, le joueur ne devient pas automatiquement un exploitant reconnu. Il doit faire progresser sa carrière et passer des examens pratiques.

Les examens demandent de réaliser de vraies opérations agricoles avec le matériel de la partie : travailler le bon champ, respecter les étapes, éviter les erreurs et ramener le matériel dans les zones prévues. Les fautes sont comptabilisées et expliquées au joueur.

Depuis la **0.6.4.24 TEST**, le HUD d’examen conserve l’action exacte à réaliser même en Difficile. Chaque étape réussie déclenche un retour visuel vert avec pictogramme et affiche directement la consigne suivante, afin de rester dans le gameplay sans retourner constamment dans le menu. Le moteur de travail dispose aussi d’une validation de secours pour les outils compatibles qui travaillent réellement mais dont la surface WorkArea n’est pas remontée correctement.

La progression professionnelle est conçue pour dépendre de ce que le joueur réalise réellement en jeu, pas d’un simple choix de profil au lancement.

### 👨‍🌾 Personnel et main-d’œuvre

Les employés AgriLife ne sont pas destinés à être de simples noms décoratifs. Le principe retenu est : **1 salarié disponible = 1 tâche automatisée active**.

À terme, helpers FS25, Courseplay et AutoDrive pourront consommer une ressource humaine AgriLife disponible. Les salariés auront leurs compétences, spécialités, salaires, horaires, absences, congés, promotions et coûts réels pour l’exploitation.

### 🏢 Société et administration

Dans les niveaux les plus exigeants, créer et administrer son exploitation fait partie du gameplay. La structure de l’entreprise, sa santé, sa réputation et sa conformité doivent progressivement influencer la Banque, les contrats commerciaux, les assurances et les futurs contentieux.

Le tableau de bord suit désormais la séquence obligatoire de façon contextuelle : **banque → conseiller → société → permis** lorsque ces étapes sont requises par la difficulté. Le bouton d’action dirige vers le module réellement attendu au lieu d’afficher une action administrative hors contexte.

### 🛡️ Assurances

Le module Assurance est destiné à couvrir matériel, exploitation et événements liés au risque. Formules, franchises, historique de sinistres et comportement du joueur doivent à terme modifier les primes et les conditions proposées.

### 🔧 Atelier et cycle de vie du matériel

AgriLife Manager développe également une logique de maintenance, état du matériel, immobilisation, coût d’entretien et valeur réelle des véhicules. L’objectif est de relier progressivement l’atelier aux assurances, à la trésorerie et au marché de l’occasion.

### 🤝 Contrats et coopératives

Le projet prévoit de dépasser la simple logique de missions FS25 pour aller vers de véritables engagements commerciaux : volumes, prix, qualité, délais, pénalités, contrats avant semis et relations avec plusieurs acheteurs ou coopératives.

### ⚖️ Huissier et contentieux

C’est l’un des systèmes prévus les plus poussés. Un incident bancaire ne doit pas simplement afficher un message rouge : retards, relances, mises en demeure, négociation, échéancier, transmission au contentieux et conséquences sur la réputation doivent former une chaîne cohérente.

Le but est de créer un véritable lien entre :

**activité → finances → banque → crédit → incident → contentieux → réputation → nouvelles possibilités de jeu**.

---

## 🎮 Trois niveaux de difficulté

| Niveau | Capital AgriLife | Philosophie générale |
|---|---:|---|
| **Facile** | 200 000 € | Gestion accessible, centrée sur Banque et XP/Carrière |
| **Normal** | 100 000 € | Gestion renforcée avec personnel, examens et progression professionnelle |
| **Difficile** | 50 000 € | Expérience complète : banque, société, permis, obligations administratives et gestion approfondie |

Le niveau choisi est **permanent pour la sauvegarde**. Les modules non accessibles restent visibles mais verrouillés afin que le joueur comprenne ce que les difficultés supérieures ajoutent au gameplay.

Pour une **nouvelle carrière**, AgriLife Manager fournit son propre capital de départ et neutralise le prêt de départ FS25. Pour une **sauvegarde existante**, l’argent, les terrains, bâtiments, véhicules et dettes existantes sont conservés afin de permettre une migration sans détruire la progression du joueur.

---

## 🧠 Une simulation qui doit se souvenir du joueur

AgriLife Manager est construit autour d’une idée importante : la sauvegarde doit conserver l’histoire de l’exploitation.

Les systèmes sont donc progressivement reliés entre eux : historique bancaire, demandes de crédit, réputation, carrière, examens, employés, patrimoine, dette, société et événements doivent survivre aux sauvegardes/rechargements et former un dossier durable de l’exploitation.

Ce n’est pas un mod où l’on ferme un menu et où tout est oublié. Le but est de construire **une carrière agricole avec une mémoire**.

---

## 🔌 Compatibilités prévues

Le cœur du mod doit rester autonome et fonctionner sans dépendances obligatoires. Les intégrations prévues avec **Courseplay**, **AutoDrive**, **Soil Fertilizer**, Precision Farming et d’autres mods réalistes doivent rester optionnelles.

Ainsi, AgriLife Manager pourra enrichir une configuration très modée sans empêcher une utilisation plus simple sur une installation FS25 standard.

---

## 🖥️ Interface

Le projet dispose de sa propre identité visuelle sombre, pensée comme une véritable application de gestion intégrée à FS25. Les pages sont progressivement harmonisées autour de cartes, tableaux, étoiles de compétence/réputation, indicateurs financiers et **pictogrammes fonctionnels qui font partie de l’identité AgriLife**.

La base 1920×1080 est actuellement utilisée pour les tests, avec une adaptation 1440p et 4K prévue dans la feuille de route.

Une galerie de captures d’écran sera ajoutée progressivement au dépôt afin de présenter les principaux modules.

---

## 🧪 État actuel du développement

**Version de travail actuelle : 0.6.4.24 TEST**  
**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement privé / builds TEST**

La 0.6.4.24 est prête pour la prochaine session de tests : progression réelle de l’épreuve 5, continuité jusqu’aux étapes de retour, HUD permanent, panneau de réussite et parcours Banque → Conseiller → Société → Permis. Tant que ces mécaniques et les autres grands modules ne sont pas suffisamment stables, la numérotation restera volontairement **inférieure à 1.0.0.0**.

---

## 🗺️ Feuille de route

Le développement est organisé en grandes phases :

1. Banque & finances
2. Interface & expérience utilisateur
3. Personnel & paie
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
- **[Changelog](CHANGELOG.md)** — historique des builds TEST
- **[Règles de développement](CONTRIBUTING.md)** — principes de travail du projet
- **[Copyright et distribution](COPYRIGHT.md)** — droits et règles de diffusion

---

## 🌱 Vision

AgriLife Manager veut répondre à une question :

> **Que se passerait-il si Farming Simulator simulait aussi la vie économique et professionnelle d’un exploitant agricole ?**

Acheter une moissonneuse ne devrait pas être seulement une question de prix. Il faudrait pouvoir se demander si la banque suivra, si l’entreprise peut absorber la mensualité, si les salariés sont disponibles, si l’assurance couvrira le risque et si cet investissement permettra réellement de développer l’exploitation.

C’est cette profondeur que le projet cherche à apporter.

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.
