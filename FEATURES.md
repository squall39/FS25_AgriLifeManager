# Fonctionnalités — AgriLife Manager

Ce document présente la vision fonctionnelle d’AgriLife Manager. Certains systèmes sont déjà jouables, d’autres sont en cours de développement ou planifiés.

## Principe de conception

AgriLife Manager ne doit pas devenir une collection de menus sans effet sur la partie.

**Chaque nouvelle fonctionnalité doit avoir une conséquence réelle en jeu** : accès ou refus, coût, avantage, obligation, réputation, progression, risque, sanction, opportunité ou évolution durable de la carrière.

## Difficulté — trois niveaux uniquement

Le mod conserve **Facile, Normal et Difficile**.

La difficulté est un paramètre global de la carrière et doit agir sur **tout le mod**. Chaque module consulte le même profil de difficulté sauvegardé avec la partie afin d’éviter des comportements incohérents entre Banque, Examens, Personnel, Assurance, Fiscalité, Contrats ou Administration.

### Facile

Gestion accessible avec davantage de tolérance, coûts et sanctions réduits, critères plus permissifs et accompagnement renforcé.

### Normal

Réglage de référence d’AgriLifeManager. Tous les grands systèmes sont actifs avec un niveau de contrainte équilibré et réaliste.

### Difficile

Contraintes, coûts, risques, contrôles, exigences bancaires, fiscalité, sanctions et conséquences renforcés. Les erreurs de gestion doivent avoir un impact plus durable.

La difficulté peut notamment agir sur : capital de départ, obligations, crédit, taux et garanties, examens, XP, salaires, assurances, entretien, fiscalité, réputation, contrats, contrôles, sanctions, contentieux et événements de gestion.

## Banque & conseiller

AgriLife remplace progressivement la logique de prêt instantané de FS25 par une relation bancaire construite dans le temps.

Le dossier prend en compte notamment réputation, qualité de la banque, compétence du conseiller, relation bancaire, dettes, incidents, objet du financement, santé de l’entreprise et difficulté.

Les demandes sont étudiées pendant des heures de jeu FS25 et peuvent être acceptées, refusées ou conditionnées. Taux, plafond, garanties, frais et délais doivent varier avec le profil et la difficulté.

## Compte professionnel et compte personnel

Le compte professionnel devient la mémoire financière de l’exploitation : solde, mouvements, catégories, frais, mensualités, intérêts, dette AgriLife, dette FS25 héritée, capacité d’emprunt, prévision de trésorerie et historique des incidents.

Le compte personnel reste distinct. La séparation professionnelle/personnelle devient plus contraignante à mesure que la difficulté augmente.

## Réputation de l’exploitation

La réputation est le **premier grand système prioritaire après stabilisation des builds TEST actuelles**.

Elle évolue à partir d’événements réels : contrats, retards, dettes, incidents, examens, qualité du travail, conformité et historique de gestion.

Elle influence Banque, Conseiller, Contrats, Coopératives, Assurance, Administration et futurs contentieux. Gains, pertes et seuils doivent dépendre de la difficulté.

## Comptabilité & fiscalité

Deuxième grande priorité après stabilisation.

Sont prévus : chiffre d’affaires, produits et charges, salaires, assurances, intérêts, entretien, résultat annuel, actifs, dettes, amortissements, historique pluriannuel, échéances fiscales et clôture d’exercice.

Fiscalité, délais, pénalités et conséquences d’impayé varient selon Facile / Normal / Difficile.

## Carrière & XP

La carrière reflète l’expérience réellement acquise sur l’exploitation. La progression prend en compte travaux réalisés, résultats, examens, réputation et historique professionnel.

Une fiche de carrière durable doit suivre heures, hectares, examens, contrats, incidents et grandes étapes de développement.

La vitesse de progression et les seuils peuvent varier selon la difficulté.

## Examens & permis agricole

Les examens sont pratiques et se déroulent directement dans la partie.

Le HUD affiche étape, action attendue, progression, note et erreurs. Après validation d’une étape, la consigne suivante apparaît immédiatement. La validation privilégie le travail réel et utilise un mécanisme de secours lorsque certains outils ne remontent pas correctement leur WorkArea.

**0.6.4.24 TEST :** la chaîne corrigée attend encore une validation complète des 10 étapes.

Frais d’inscription, tolérance, notation et exigences doivent varier selon la difficulté.

Des qualifications spécialisées pourront compléter le permis général : phytosanitaire/pulvérisation, télescopique, forestier, transport agricole ou autres catégories pertinentes.

## Personnel, contrats & paie

Principe central : **1 salarié disponible = 1 tâche automatisée active maximum**.

Les salariés représentent une vraie capacité de main-d’œuvre et disposent de contrats CDI, CDD ou saisonniers, d’un salaire, d’une ancienneté, de compétences, de spécialités, d’un historique et d’un état de disponibilité.

AgriLife doit devenir la **source unique de paie** des salariés enregistrés afin d’éviter une double facturation par FS25, Courseplay ou AutoDrive.

Le futur centre d’ordres suit :

**salarié → véhicule → outil → type de travail → champ ou destination**

Coûts employeur, contraintes, tolérances et progression des salariés peuvent dépendre de la difficulté.

## Joueur humain, GPS et ouvriers

Le joueur humain reste distinct de la main-d’œuvre salariée. Le GPS / Steering Assist natif reste disponible, mais les tâches automatisées doivent être rattachées au système Personnel AgriLife afin de conserver une gestion cohérente des ressources humaines et de la paie.

## Société, administration & statut d’exploitation

La société devient un véritable élément de gameplay avec obligations, coûts, formalités et conformité adaptés au niveau choisi.

Un statut évolutif est prévu :

**petite exploitation → exploitation professionnelle → entreprise agricole → grande entreprise**

Le passage d’un statut au suivant dépend de l’expérience, de la réputation, du capital, des examens, de la conformité et de l’activité réelle.

## Contrôles administratifs & sanctions

Troisième grande priorité après stabilisation.

Les contrôles vérifient uniquement les obligations réellement applicables à la carrière : permis, assurances, documents, conformité ou autres exigences actives.

Les conséquences peuvent inclure avertissement, délai de régularisation, amende, immobilisation, effet sur la réputation et aggravation en cas de récidive.

Fréquence, seuils et sévérité doivent dépendre de la difficulté. Chaque sanction doit avoir une cause compréhensible et identifiable.

## Événements de gestion

Des événements peu fréquents mais significatifs pourront créer de vraies situations de gestion : échéance, facture imprévue, contrôle, réparation lourde, absence salarié ou autre incident crédible.

Fréquence et sévérité dépendent du niveau choisi.

## Assurances

Contrats, primes, franchises, exclusions et couverture doivent évoluer selon risque, historique, réputation et difficulté.

## Atelier & matériel

Le matériel possède une histoire économique : achat, utilisation, usure, entretien, immobilisation, réparation, sinistres et valeur résiduelle.

Coûts, tolérances et conséquences d’entretien varient avec la difficulté.

## Contrats & coopératives

AgriLife vise de véritables engagements commerciaux : acheteurs multiples, coopératives, volumes, prix, qualité, échéances, pénalités, contrats avant semis et historique commercial.

Chaque contrat pourra recevoir une notation selon le respect réel des engagements. Exigences, tolérances et pénalités varient selon la difficulté.

## Huissier & contentieux

Chaîne visée :

**retard → relance → mise en demeure → négociation → échéancier → contentieux → frais → conséquences bancaires et réputationnelles**

Délais, frais, tolérances et escalade dépendent du niveau choisi.

## Journal de bord AgriLife

La carrière conserve une chronologie des événements importants : permis obtenu, salarié embauché, financement majeur, évolution de statut, contrôle administratif, contrat marquant, sinistre ou autre étape importante.

## Traductions & clés l10n

AgriLifeManager doit être proprement utilisable dans **toutes les langues distribuées avec le mod**.

Règles :

- aucune chaîne joueur importante codée en dur ;
- chaque texte visible possède une clé l10n ;
- toutes les langues distribuées possèdent exactement les mêmes clés ;
- toute nouvelle clé est ajoutée immédiatement à tous les fichiers de langue ;
- détection des clés manquantes, doublons, fautes de nommage et clés inutilisées ;
- contrôle des accents, caractères spéciaux, encodage UTF-8, textes longs, unités, montants et dates ;
- glossaire cohérent pour les termes agricoles, bancaires, comptables, juridiques, administratifs et liés au personnel ;
- extension progressive aux langues pertinentes de FS25/ModHub.

**Critère de publication : 0 clé manquante, 0 clé brute visible, 0 traduction vide et 0 fallback involontaire.**

## Sauvegardes & migration

Chaque carrière possède son propre état AgriLife et ne doit jamais récupérer la progression d’une autre sauvegarde.

Le niveau Facile / Normal / Difficile est enregistré dans la carrière et doit rester stable après sauvegarde/rechargement.

Les sauvegardes existantes conservent argent, terrains, bâtiments, véhicules et dette FS25 héritée lorsque nécessaire.

## Compatibilités

Le mod doit fonctionner seul. Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et autres intégrations restent optionnels.

## Multijoueur

À terme, AgriLife doit fonctionner en multi-fermes et multijoueur complet, avec autorité serveur et synchronisation des modules.

## Interface & localisation

L’interface suit une identité sombre et moderne avec informations hiérarchisées, cartes, tableaux, étoiles de réputation/compétence et pictogrammes fonctionnels.

---

Pour l’état d’avancement détaillé, consulter **[ROADMAP.md](ROADMAP.md)**.

© 2026 **Chez_Squall**.