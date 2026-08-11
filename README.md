# 🌾 AgriLife Manager - Farming Simulator 25

> **Et si Farming Simulator ne s’arrêtait plus à conduire des machines ?**

AgriLife Manager transforme une partie FS25 en véritable parcours de chef d’exploitation : banque, entreprise, carrière, qualifications, administration, contrats, marchés, atelier, économie, réputation, comptabilité et conséquences durables.

**AgriLife Manager n’est pas pensé comme un simple menu supplémentaire.** Le projet vise à créer une couche complète de gestion autour de la ferme, avec des décisions qui ont des conséquences dans le temps et une exploitation qui possède une véritable mémoire.

> **Principe central : chaque nouvelle fonctionnalité doit produire une conséquence réelle en jeu.**

> [!WARNING]
> **Projet en développement actif.** Le dépôt est public et le source original AgriLife Manager est autorisé à y être publié, mais le mod n’est pas encore une version finale. La numérotation restera volontairement **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.

---

## 🔓 Dépôt source public

Depuis le **10 août 2026**, Chez_Squall autorise officiellement la publication sur ce dépôt GitHub du **code source et des fichiers originaux AgriLife Manager**.

Cela ne change pas l’ordre de développement. GitHub sert à rendre le projet, son code, sa documentation et les retours plus accessibles, pas à remplacer la feuille de route.

Les composants ou assets tiers restent soumis à leurs propres droits et conditions de redistribution.

➡️ **[Statut et règles de publication du source](SOURCE_PUBLICATION.md)**  
➡️ **[Copyright et distribution](COPYRIGHT.md)**

---

## 🚜 Le concept

FS25 simule déjà le travail agricole. AgriLife Manager ajoute ce qui se passe autour : gérer son exploitation, choisir sa banque et son conseiller, obtenir des financements, passer des examens pratiques, faire évoluer sa carrière, recruter du personnel, organiser le travail, assurer et entretenir le matériel, signer des contrats et construire progressivement la réputation de l’entreprise.

L’objectif est que **les décisions prises aujourd’hui puissent encore avoir un impact plusieurs mois plus tard dans la sauvegarde**.

---

## 🎮 Trois difficultés uniquement

AgriLife Manager conserve **Facile, Normal et Difficile**.

| Niveau | Capital de départ | Démarrage |
|---|---:|---|
| **Facile** | 200 000 € | Banque et permis facultatifs, accès véhicule libre. |
| **Normal** | 100 000 € | Banque + conseiller obligatoires, permis provisoire de 3 mois. |
| **Difficile** | 50 000 € | Banque + conseiller obligatoires, examen obligatoire avant conduite normale. |

Le niveau choisi est permanent pour la carrière.

La difficulté agit ensuite sur tout AgriLifeManager : coûts, tolérances, délais, crédit, examens, XP, personnel, assurances, atelier, fiscalité, réputation, contrats, marchés, contrôles, sanctions et événements.

---

## 🧩 Architecture finale du joueur

Le tableau de bord est la racine de l’information et regroupe exactement **6 modules fonctionnels** :

1. **Banque**
2. **Entreprise**
3. **Carrière & Qualifications**
4. **Administration**
5. **Contrats & Marchés**
6. **Atelier**

**Démarrage**, **Interface** et **Finalisation** sont des blocs transversaux, pas des modules joueur.

---

## 🏦 Banque

La Banque possède la relation bancaire, le conseiller, les crédits, la trésorerie, les comptes, la dette, la comptabilité et la fiscalité.

À terme, la banque et le conseiller seront liés par un véritable contrat bancaire avec durée, renouvellement, changement d’établissement, rupture anticipée, conséquences, prêts conservés chez leur banque d’origine et possibilité de refinancement.

---

## 👨‍🌾 Entreprise

Entreprise regroupe salariés, contrats de travail, paie, ordres de travail, expérience des employés et réputation de l’exploitation.

Principe central : **1 salarié disponible = 1 tâche automatisée active maximum**.

AgriLife doit devenir la source unique de paie pour les employés enregistrés afin d’éviter les doubles coûts avec FS25, Courseplay ou AutoDrive.

---

## 🎓 Carrière & Qualifications

Ce module regroupe XP joueur, carrière, examens, permis et qualifications spécialisées.

Les examens sont pratiques et se déroulent directement dans la partie avec les vrais véhicules, outils et champs. Le HUD suit l’étape, l’action attendue, la progression, la note et les erreurs.

---

## 🏢 Administration

Administration regroupe société, statuts, conformité, assurances, contrôles, sanctions, événements de gestion, huissier et contentieux.

Chaque sanction doit avoir une cause identifiable et une conséquence réelle. Les dettes et sanctions personnelles ne doivent pas être payées silencieusement par l’entreprise.

---

## 🤝 Contrats & Marchés

Ce module regroupe contrats commerciaux, coopératives, marchés mondiaux et locaux, multifruits, intrants, carburants, matériel neuf et occasion, foncier, locations et productions.

Le moteur économique doit rester borné, inertiel et cohérent. Il doit détecter dynamiquement les contenus réellement enregistrés dans la partie plutôt que dépendre de listes fixes.

Chaîne économique de référence :

**sol / pratiques → intrants → coût de production → rendement / qualité → marché mondial → marchés locaux → coopératives / usines → contrats → comptabilité → banque → réputation**

➡️ **[Conception détaillée de l’économie dynamique](docs/DYNAMIC_ECONOMY_AGRONOMY.md)**

---

## 🔧 Atelier

Atelier possède l’état, l’usure, l’entretien, les réparations, les immobilisations et l’historique technique du matériel.

La valeur économique du matériel pourra être influencée par les marchés, mais la logique d’entretien reste la responsabilité de l’Atelier.

---

## 🌾 Toutes maps & multifruit

AgriLifeManager ne doit pas dépendre d’une liste fermée de maps ou de cultures.

Le projet vise la détection dynamique des **fruits, fillTypes, produits, points de vente, productions, parcelles, articles magasin, véhicules, outils et autres contenus enregistrés** lorsque les API FS25 le permettent.

Lorsqu’un contenu tiers n’est pas détectable de manière sûre, AgriLife doit l’ignorer proprement plutôt que casser la partie.

---

## 🌱 Precision Farming & Soil Fertilizer

Ces intégrations restent **optionnelles**. AgriLifeManager ne doit pas refaire leur logique agronomique.

Lorsqu’ils sont présents et que leurs données sont accessibles de manière fiable, Precision Farming et Soil Fertilizer pourront enrichir coûts de production, contrats qualité, primes, réputation, contrôles et rentabilité.

La difficulté AgriLife modifie les conséquences économiques et administratives, pas les lois agronomiques de ces mods.

---

## 🌍 Traductions et clés l10n

AgriLifeManager doit être utilisable proprement dans **toutes les langues distribuées avec le mod**.

Critères de publication :

- 0 clé manquante ;
- 0 clé brute visible ;
- 0 traduction vide ;
- 0 fallback involontaire ;
- aucun texte joueur important codé en dur ;
- même jeu de clés dans toutes les langues distribuées.

Une contribution de traduction est actuellement suivie dans l’issue GitHub #2. Elle doit être rebasée sur le référentiel courant avant intégration afin de ne pas écraser des clés ajoutées depuis sa préparation.

---

## 🧠 Une carrière avec une mémoire

Historique bancaire, crédits, réputation, carrière, examens, employés, contrats, patrimoine, dette, société, fiscalité, marchés, locations, contrôles et événements doivent survivre aux sauvegardes et rechargements.

Un **Journal de bord AgriLife** est prévu pour conserver les grandes étapes de la carrière.

---

## 🔌 Compatibilités prévues

Le cœur du mod doit fonctionner seul. Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres intégrations resteront optionnelles.

La compatibilité sera testée progressivement sur plusieurs maps vanilla, modmaps et maps multifruits.

---

## 🖥️ Interface

AgriLife possède une identité sombre et moderne avec cartes, tableaux, étoiles de compétence ou réputation, indicateurs financiers et pictogrammes fonctionnels.

Base de test : 1920×1080, avec adaptation 1440p et 4K prévue.

---

## 🧪 État actuel du développement

**Plateforme cible : PC**  
**Auteur : Chez_Squall**  
**Statut : développement pré-1.0**

Le bloc **Démarrage** est en cours de validation. Le parcours Normal a été validé fonctionnellement, avec quelques finitions d’affichage encore prévues. Le prochain test joueur porte sur le parcours **Difficile**, puis sur migration et isolation des sauvegardes.

La feuille de route reste la source de vérité pour l’état précis des validations.

---

## 🧭 Ordre de travail officiel

Le développement suit cet ordre et ne saute pas de module :

**Démarrage → Interface de base → Banque → Entreprise → Carrière & Qualifications → Administration → Contrats & Marchés → Atelier → Finalisation**

Un bloc est terminé seulement après fonctionnalités, interface, sauvegarde, difficulté, l10n, tableau de bord, contrôles internes, test joueur, corrections et validation finale.

➡️ **[Consulter la feuille de route complète](ROADMAP.md)**

---

## ✍️ Style et attribution

Les contenus du projet utilisent une voix simple et humaine. Le caractère em dash n’est pas utilisé.

Aucune mention `Generated with...`, `Co-Authored-By:`, attribution à une IA, nom de modèle ou lien vers un fournisseur d’IA ne doit être ajouté aux commits, PR, releases, README, documentation, commentaires de code ou textes en jeu.

Le projet reste attribué à **Chez_Squall**.

➡️ **[Règles d’écriture et d’attribution](docs/WRITING_AND_ATTRIBUTION.md)**

---

## 🐛 Signaler un problème ou proposer une idée

Utilisez les formulaires GitHub **Bug report** ou **Feature request**.

Pour un bug, indiquez autant que possible : version AgriLife, version FS25, map, difficulté, nouvelle partie ou sauvegarde existante, étapes de reproduction, résultat attendu et obtenu, mods susceptibles d’interagir et `log.txt` de la session concernée.

Avant de publier un log, vérifiez qu’il ne contient pas de donnée personnelle que vous ne souhaitez pas rendre publique, notamment un nom de session Windows ou un chemin local identifiable.

---

## 📚 Documentation

- **[Feuille de route](ROADMAP.md)**
- **[Fonctionnalités détaillées](FEATURES.md)**
- **[Publication du source](SOURCE_PUBLICATION.md)**
- **[Personnel & main-d’œuvre](docs/WORKFORCE_DESIGN.md)**
- **[Économie dynamique, multifruit, Precision Farming & Soil Fertilizer](docs/DYNAMIC_ECONOMY_AGRONOMY.md)**
- **[Règles d’écriture et d’attribution](docs/WRITING_AND_ATTRIBUTION.md)**
- **[Changelog](CHANGELOG.md)**
- **[Règles de développement et contributions](CONTRIBUTING.md)**
- **[Copyright et distribution](COPYRIGHT.md)**

---

© 2026 **Chez_Squall**. Tous droits réservés sur les éléments originaux d’AgriLife Manager. Les composants et ressources tiers conservent leurs droits et licences respectifs.
