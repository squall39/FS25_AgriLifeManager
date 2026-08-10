# Économie dynamique & intégrations agronomiques — AgriLife Manager

Ce document formalise les décisions validées pour le futur moteur économique dynamique d’AgriLifeManager et ses intégrations avec Precision Farming, Soil Fertilizer, les cartes personnalisées et les systèmes multifruits.

## Principe central

AgriLifeManager doit rester autonome. Precision Farming et Soil Fertilizer sont des **sources de données et d’événements agronomiques optionnelles**, jamais des dépendances obligatoires.

AgriLife ne doit pas dupliquer leur logique agronomique. Il doit exploiter les informations qu’ils exposent pour produire des conséquences économiques, contractuelles, administratives et réputationnelles.

Chaîne cible :

**sol réel → intrants → coût de production → rendement/qualité → marché mondial → marchés locaux → coopératives/usines → contrats → comptabilité → banque → réputation**

## Precision Farming

Lorsque Precision Farming est présent et que les données nécessaires sont accessibles :

- utiliser les informations de parcelle pertinentes dans les contrats et la rentabilité ;
- permettre à certaines exigences de qualité ou de pratiques agricoles d’être évaluées à partir de données réelles ;
- alimenter la réputation, les primes contractuelles et certains contrôles lorsque cela a du sens ;
- ne jamais modifier ou remplacer les calculs agronomiques propres à Precision Farming ;
- revenir proprement au fonctionnement AgriLife standard lorsque Precision Farming est absent.

## Soil Fertilizer

Lorsque Soil Fertilizer est présent et que ses données sont accessibles :

- exploiter les informations de sol, fertilisation, intrants, résidus ou autres états agronomiques exposés par le mod ;
- relier les consommations d’intrants aux coûts réels de production ;
- intégrer les intrants enregistrés dans le marché dynamique AgriLife lorsque cela est techniquement possible ;
- permettre à des contrats ou coopératives d’utiliser certaines conditions agronomiques comme critères de prime, qualité ou conformité ;
- ne jamais modifier directement les fichiers de Soil Fertilizer ;
- ne jamais refaire dans AgriLife la logique agronomique déjà gérée par Soil Fertilizer.

## Difficulté AgriLife

Facile / Normal / Difficile ne doivent pas changer artificiellement la physique ou l’agronomie de Precision Farming ou Soil Fertilizer.

La difficulté AgriLife agit sur les **conséquences** :

- tolérance des contrats ;
- montant des primes et pénalités ;
- fréquence et sévérité de certains contrôles ;
- importance de la conformité dans la réputation ;
- conséquences économiques d’une mauvaise gestion ;
- niveau d’exigence des coopératives et acheteurs.

## Marché mondial dynamique

Le moteur économique doit pouvoir agir sur :

- prix de vente des cultures et produits ;
- intrants agricoles ;
- carburants et énergies ;
- palettes, big bags, consommables et accessoires ;
- véhicules, machines et outils neufs ;
- véhicules, machines et outils d’occasion ;
- location de matériels et outils ;
- location de champs ;
- achat/vente de champs lorsque la map le permet ;
- location et exploitation d’usines/productions lorsque techniquement supporté ;
- disponibilité, rareté, délais et volumes proposés.

## Contrats & coopératives

Les contrats et coopératives utilisent le même moteur économique dynamique.

Les offres peuvent varier selon :

- cours mondial et local du produit ;
- offre et demande ;
- saison et disponibilité ;
- volume recherché ;
- capacité et besoins des points de vente / productions lorsque disponibles ;
- réputation de l’exploitation ;
- historique avec la coopérative ;
- qualité et pratiques agricoles réellement observables ;
- difficulté AgriLife ;
- délais et risques de marché.

Les contrats peuvent proposer :

- prix fixe ;
- prix indexé ;
- prime qualité ;
- prime de volume ;
- bonus de livraison anticipée ;
- pénalité de retard ;
- pénalité de quantité manquante ;
- clauses liées à certaines pratiques agronomiques lorsque les données sont disponibles.

## Compatibilité universelle des maps et multifruits

Aucune liste fermée de fruits, produits ou cartes ne doit être codée en dur comme base du système.

AgriLife doit détecter dynamiquement, autant que les API FS25 le permettent :

- fruits enregistrés ;
- fillTypes enregistrés ;
- points de vente ;
- productions/usines ;
- parcelles/farmlands ;
- articles magasin ;
- véhicules et outils ;
- palettes et big bags ;
- ressources et intrants ajoutés par la map ou des mods.

Une culture ou un produit multifruit correctement enregistré dans FS25 doit pouvoir entrer automatiquement dans le marché, les coopératives et les contrats sans ajout manuel spécifique dans AgriLife.

## Règle de robustesse

Une intégration externe ne doit jamais casser le cœur du mod.

Si Precision Farming, Soil Fertilizer, une production, un fruit ou une map n’expose pas une donnée attendue, AgriLife doit :

1. détecter proprement l’absence de la donnée ;
2. désactiver uniquement la fonction enrichie concernée ;
3. conserver le fonctionnement économique et de carrière de base ;
4. éviter les erreurs Lua et les sauvegardes corrompues.

## Statut

Décisions validées pour la feuille de route AgriLifeManager. Ce document sert de référence fonctionnelle lors de l’implémentation du futur moteur économique dynamique et des compatibilités agronomiques.
