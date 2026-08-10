# Fonctionnalités — AgriLife Manager

Ce document présente la vision fonctionnelle d’AgriLife Manager. Les systèmes décrits ici n’ont pas tous le même niveau d’avancement : certains sont déjà jouables, d’autres sont en cours de développement ou planifiés dans la feuille de route.

## Banque & conseiller

AgriLife Manager remplace progressivement la logique de prêt instantané de FS25 par une relation bancaire construite dans le temps.

Chaque banque et chaque conseiller possède un profil propre. Le joueur construit ensuite sa relation avec eux selon son historique, sa réputation, la santé de son exploitation et sa capacité à honorer ses engagements.

Le système bancaire doit prendre en compte :

- réputation du dirigeant et de l’exploitation ;
- qualité intrinsèque de la banque ;
- réputation et compétence du conseiller ;
- relation bancaire ;
- historique des paiements ;
- dettes existantes ;
- incidents bancaires ;
- situation juridique/contentieuse ;
- objet du financement ;
- difficulté choisie ;
- santé générale de l’entreprise.

Les demandes de crédit sont étudiées pendant des heures de jeu FS25 et peuvent être acceptées, refusées ou conditionnées.

## Compte professionnel

Le compte professionnel doit devenir la mémoire financière de l’exploitation.

Fonctions visées :

- solde et trésorerie ;
- relevé des mouvements ;
- catégories et tags ;
- frais bancaires ;
- mensualités ;
- intérêts ;
- coût total des crédits ;
- dette AgriLife ;
- dette FS25 héritée ;
- capacité d’emprunt ;
- prévision de trésorerie ;
- refinancement et renégociation ;
- historique des incidents.

## Compte personnel

Le compte personnel reste distinct du compte professionnel. En difficulté élevée, la séparation doit devenir réellement contraignante afin d’empêcher le joueur de traiter l’argent professionnel comme une caisse personnelle sans conséquence.

## Carrière & XP

La carrière ne repose pas sur un profil choisi artificiellement au départ. Elle doit refléter l’expérience réellement acquise sur l’exploitation.

La progression doit prendre en compte les travaux effectués, les résultats, les examens, la réputation et l’historique professionnel.

## Examens & permis agricole

Les examens sont pratiques et se déroulent directement dans la partie.

Le joueur doit effectuer des tâches agricoles réelles, respecter un ordre d’étapes, travailler au bon endroit, utiliser correctement le matériel et éviter les erreurs.

Le système d’examen est conçu pour que le joueur reste dans son tracteur et dans son travail au lieu de devoir retourner dans le menu après chaque étape :

- le HUD affiche en permanence **l’étape X/10** et l’action exacte attendue ;
- la progression, la note et le nombre d’erreurs restent visibles ;
- après une étape validée, le HUD passe temporairement en état de réussite avec **pictogramme vert** ;
- la consigne suivante apparaît immédiatement ;
- la dernière erreur connue reste expliquée après la disparition de la notification temporaire ;
- la validation du travail privilégie la surface WorkArea réellement traitée ;
- un mécanisme de secours peut reconnaître un outil compatible réellement abaissé/en travail lorsqu’un véhicule ou un mod ne remonte pas correctement la surface travaillée ;
- les étapes de retour vérifient la position réelle du matériel assigné dans sa zone d’origine.

Les erreurs doivent être explicites : mauvais champ, dégâts matériels ou autre faute liée à l’épreuve.

**0.6.4.24 TEST :** ces améliorations sont implémentées et attendent une validation complète en jeu sur les 10 étapes.

## Personnel & paie

Les salariés ne doivent pas être de simples entrées de menu.

Principe central : **un salarié disponible correspond à une capacité réelle de travail automatisé**.

À terme :

- affectations ;
- compétences générales ;
- spécialités ;
- salaires ;
- heures supplémentaires ;
- horaires ;
- absences ;
- maladie ;
- congés ;
- promotion ;
- licenciement ;
- intégration optionnelle helpers FS25 ;
- intégration optionnelle Courseplay ;
- intégration optionnelle AutoDrive.

## Société & administration

Le joueur doit progressivement gérer son exploitation comme une véritable structure professionnelle.

Les obligations administratives et juridiques varient selon la difficulté. La société doit ensuite être utilisée par les autres systèmes : Banque, Contrats, Assurance et Huissier.

Le parcours de démarrage est contextuel : lorsqu’une étape est requise, le tableau de bord affiche l’action réellement attendue. En Difficile, la logique visée est notamment **Banque → Conseiller → Société → Permis**, sans demander de valider la société avant que les choix bancaires requis soient terminés.

## Assurances

Le système Assurance doit évoluer vers plusieurs contrats et niveaux de couverture, avec primes, franchises, historique de sinistres et conséquences selon le niveau de risque.

## Atelier & matériel

Le matériel doit posséder une histoire économique : achat, utilisation, usure, entretien, immobilisation, réparation et valeur résiduelle.

Les coûts de maintenance doivent pouvoir affecter la trésorerie et interagir avec les assurances et le financement.

## Contrats & coopératives

Le projet vise des contrats agricoles plus proches de relations commerciales que de simples missions.

Sont prévus :

- acheteurs multiples ;
- coopératives ;
- volumes ;
- prix négociés ;
- exigences de qualité ;
- échéances ;
- pénalités ;
- contrats avant semis ;
- historique commercial ;
- impact de la réputation.

## Huissier & contentieux

Le module Huissier doit prolonger naturellement le système bancaire.

Chaîne visée :

**retard → relance → mise en demeure → négociation → échéancier → contentieux → frais → conséquences bancaires et réputationnelles**.

L’objectif n’est pas de punir arbitrairement le joueur, mais de donner des conséquences crédibles aux difficultés financières et plusieurs moyens réalistes d’en sortir.

## Difficulté

Trois niveaux structurent l’expérience :

- **Facile** : 200 000 € — Banque + XP/Carrière ;
- **Normal** : 100 000 € — Banque + Personnel + Examens + XP/Carrière ;
- **Difficile** : 50 000 € — expérience complète et obligations renforcées.

La difficulté choisie reste permanente pour la sauvegarde.

## Sauvegardes & migration

AgriLife Manager doit respecter les carrières existantes.

Nouvelle partie : capital AgriLife et suppression du prêt de départ FS25.

Sauvegarde existante : conservation de l’argent, des terrains, bâtiments, véhicules et de la dette FS25 existante, enregistrée comme dette héritée.

## Compatibilités

Le mod doit fonctionner seul.

Les intégrations prévues avec Courseplay, AutoDrive, Soil Fertilizer, Precision Farming et d’autres mods sont conçues comme des compatibilités optionnelles et non comme des dépendances obligatoires.

## Multijoueur

À terme, AgriLife doit fonctionner en multi-fermes et multijoueur complet, avec synchronisation serveur des systèmes et prise en compte des joueurs humains comme collaborateurs actifs de l’exploitation.

## Interface & localisation

L’interface AgriLife suit une identité sombre et moderne, avec informations hiérarchisées, cartes, tableaux, étoiles de réputation/compétence et **pictogrammes fonctionnels conservés comme élément important de l’identité du mod**.

Langues prévues : français, anglais, italien, chinois simplifié et chinois traditionnel, avec relecture et contrôle systématique des clés l10n.

---

Pour l’état d’avancement détaillé, consulter **[ROADMAP.md](ROADMAP.md)**.

© 2026 **Chez_Squall**.
