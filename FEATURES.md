# Fonctionnalités - AgriLife Manager

Ce document présente la vision fonctionnelle d’AgriLife Manager. Certains systèmes sont déjà jouables, d’autres sont en cours de développement ou planifiés.

## Principe de conception

AgriLife Manager ne doit pas devenir une collection de menus sans effet sur la partie.

**Chaque nouvelle fonctionnalité doit avoir une conséquence réelle en jeu** : accès ou refus, coût, avantage, obligation, réputation, progression, risque, sanction, opportunité ou évolution durable de la carrière.

## Difficulté - trois niveaux uniquement

Le mod conserve **Facile, Normal et Difficile**.

La difficulté est un paramètre global de la carrière. Chaque module consulte le même profil sauvegardé afin d’éviter des comportements incohérents entre Banque, Entreprise, Carrière & Qualifications, Administration, Contrats & Marchés et Atelier.

### Facile

- capital de départ : **200 000 €** ;
- banque et conseiller facultatifs au démarrage ;
- examen/permis facultatif ;
- accès véhicule libre ;
- coûts, sanctions et exigences plus permissifs.

### Normal

- capital de départ : **100 000 €** ;
- banque + conseiller obligatoires ;
- permis provisoire de **3 mois de jeu** ;
- rappel toutes les **6 heures de jeu** ;
- amende unique de **500 €** sur le compte personnel après expiration ;
- conduite normale autorisée pendant la période provisoire.

### Difficile

- capital de départ : **50 000 €** ;
- banque + conseiller obligatoires ;
- examen agricole obligatoire ;
- accès normal aux véhicules verrouillé jusqu’à obtention du permis ;
- matériel d’examen utilisable pendant une épreuve active ;
- contraintes, coûts, risques et conséquences renforcés.

La difficulté agit ensuite sur crédit, taux, garanties, examens, XP, salaires, assurances, entretien, fiscalité, réputation, contrats, marchés, contrôles, sanctions et événements de gestion.

## Démarrage

Démarrage n’est pas un module joueur. Il initialise la carrière, le niveau de difficulté, le capital, les obligations initiales, la banque/conseiller lorsque requis, le permis et la persistance de l’état AgriLife dans la sauvegarde FS25.

La validation actuelle porte sur les trois parcours Facile, Normal et Difficile, puis sur migration et isolation des sauvegardes.

## Interface

Le tableau de bord est la racine de l’information et présente exactement six modules :

1. Banque
2. Entreprise
3. Carrière & Qualifications
4. Administration
5. Contrats & Marchés
6. Atelier

L’Interface reste une couche transversale : navigation, tutoriel, Assistance, HUD, notifications, tableaux de bord, lisibilité 1080p/1440p/4K et futur Journal de bord AgriLife.

## Banque

La Banque regroupe relation bancaire, conseiller, crédit, compte professionnel, compte personnel, dette, trésorerie, comptabilité et fiscalité.

Sont prévus :

- contrat bancaire à durée déterminée ;
- renouvellement, changement et rupture anticipée ;
- conséquences de relation, incidents et réputation ;
- prêts conservés chez leur banque d’origine ;
- refinancement ;
- historique complet des transactions ;
- prévision de trésorerie ;
- bilan, résultat et fiscalité AgriLife.

## Entreprise

Entreprise regroupe salariés, contrats de travail, paie, ordres de travail, expérience des employés et réputation de l’exploitation.

Principe central : **1 salarié disponible = 1 tâche automatisée active maximum**.

AgriLife doit devenir la source unique de paie des salariés enregistrés afin d’éviter toute double facturation par FS25, Courseplay ou AutoDrive.

Contrats prévus : CDI, CDD et saisonnier.

## Carrière & Qualifications

Ce module regroupe XP joueur, carrière, examens, permis et qualifications spécialisées.

Les examens sont pratiques et se déroulent directement dans la partie. Le HUD affiche étape, action attendue, progression, note et erreurs.

La progression XP normale reste séparée de la progression d’examen.

Qualifications spécialisées envisagées : pulvérisation/phytosanitaire, télescopique, forestier, transport agricole et autres catégories pertinentes.

## Administration

Administration regroupe société, statuts, conformité, assurances, contrôles, sanctions, événements de gestion, huissier et contentieux.

Chaque sanction doit avoir une cause compréhensible et une conséquence réelle. Les sanctions personnelles ne doivent pas être payées silencieusement par l’entreprise.

Un statut d’exploitation évolutif est prévu :

**petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**

## Contrats & Marchés

AgriLife vise de véritables engagements commerciaux : acheteurs multiples, coopératives, volumes, prix, qualité, échéances, pénalités et contrats avant semis.

Le même moteur économique doit alimenter :

- cultures et produits ;
- multifruits ;
- matériel neuf et occasion ;
- intrants, palettes et big bags ;
- carburants et énergies ;
- foncier ;
- locations ;
- productions/usines ;
- contrats et coopératives.

Les fluctuations restent bornées, progressives et cohérentes.

## Atelier

Atelier possède l’état, l’usure, l’entretien, les réparations, les immobilisations et l’historique technique du matériel.

Le matériel doit conserver une histoire économique : achat, utilisation, entretien, sinistres, réparation et valeur résiduelle.

## Réputation

La réputation appartient au module Entreprise. Les autres modules la consultent mais ne recréent pas leur propre moteur de réputation.

Elle évolue à partir d’événements réels : contrats, retards, dettes, incidents, examens, qualité du travail, conformité et gestion.

## Compte professionnel et compte personnel

Les deux comptes restent séparés.

Le compte personnel doit justifier clairement capital initial, salaire brut, retenues, net versé, logement, frais bancaires personnels, sanctions et solde après mouvement.

Le compte professionnel conserve les charges et opérations de l’exploitation.

## Journal de bord AgriLife

La carrière conservera une chronologie des événements importants : permis obtenu, salarié embauché, financement majeur, évolution de statut, contrôle administratif, contrat marquant, sinistre ou autre étape importante.

## Toutes maps et multifruit

AgriLifeManager ne doit pas dépendre d’une liste fermée de maps ou de cultures.

Le projet vise la détection dynamique des fruits, fillTypes, produits, points de vente, productions, parcelles, articles magasin, véhicules, outils, palettes, big bags et ressources enregistrées dans la partie lorsque les API FS25 le permettent.

Un contenu non détectable de manière sûre doit être ignoré proprement sans casser AgriLife.

## Precision Farming & Soil Fertilizer

Ces intégrations restent optionnelles.

AgriLife ne refait pas leur agronomie. Il utilise leurs données fiables pour produire des conséquences économiques, contractuelles, administratives et réputationnelles.

## Traductions & clés l10n

Règles :

- aucune chaîne joueur importante codée en dur ;
- chaque texte visible possède une clé l10n ;
- toutes les langues distribuées possèdent exactement les mêmes clés ;
- toute nouvelle clé est ajoutée immédiatement à tous les fichiers de langue ;
- détection des clés manquantes, doublons, fautes de nommage et clés inutilisées ;
- contrôle des accents, caractères spéciaux, encodage UTF-8, textes longs, unités, montants et dates ;
- glossaire cohérent pour les termes agricoles, bancaires, comptables, juridiques, administratifs et liés au personnel.

**Critère de publication : 0 clé manquante, 0 clé brute visible, 0 traduction vide et 0 fallback involontaire.**

Une contribution l10n est suivie dans l’issue GitHub #2 et devra être rebasée sur le référentiel courant avant intégration.

## Sauvegardes & migration

Chaque carrière possède son propre état AgriLife et ne doit jamais récupérer la progression d’une autre sauvegarde.

Le niveau Facile / Normal / Difficile est enregistré dans la carrière et doit rester stable après sauvegarde/rechargement.

Les sauvegardes existantes conservent argent, terrains, bâtiments, véhicules et dette FS25 héritée lorsque nécessaire.

## Compatibilités

Le mod doit fonctionner seul. Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres intégrations restent optionnels.

## Multijoueur

À terme, AgriLife doit fonctionner en multi-fermes et multijoueur complet, avec autorité serveur et synchronisation des modules.

## Style et attribution

Le caractère em dash n’est pas utilisé dans les contenus du projet.

Aucune attribution à une IA ou à un fournisseur d’IA ne doit être ajoutée aux commits, PR, releases, README, documentation, commentaires de code ou textes en jeu.

Le projet reste attribué à **Chez_Squall**.

---

Pour l’état d’avancement détaillé, consulter **[ROADMAP.md](ROADMAP.md)**.

© 2026 **Chez_Squall**.
