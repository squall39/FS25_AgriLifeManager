# Publication du source - AgriLife Manager

## Statut

Le dépôt `squall39/FS25_AgriLifeManager` est un **dépôt public officiel de développement**.

Chez_Squall a autorisé le **10 août 2026** la publication sur GitHub du code source et des fichiers originaux AgriLife Manager.

Cette décision concerne la visibilité et la collaboration autour du projet. **Elle ne change pas l’ordre de développement validé.**

## État réel du dépôt

L’autorisation de publier le source ne signifie pas que chaque build locale est automatiquement synchronisée sur GitHub.

Tant que la présence physique de tous les fichiers de la build courante sur `main` n’a pas été vérifiée, le dépôt ne doit pas être présenté comme un miroir complet de la dernière build locale.

La documentation GitHub peut donc être plus récente que le source effectivement publié, ou inversement. Toute synchronisation doit être vérifiée avant annonce publique.

## Ordre de travail officiel

Le programme reste :

1. Démarrage ;
2. Interface de base ;
3. Banque ;
4. Entreprise ;
5. Carrière & Qualifications ;
6. Administration ;
7. Contrats & Marchés ;
8. Atelier ;
9. Finalisation.

Un module est terminé complètement avant ouverture du suivant.

Une issue, idée ou contribution GitHub ne modifie pas automatiquement les priorités. Elle doit rester cohérente avec la feuille de route et les principes AgriLife.

## Méthode de validation

Chaque bloc suit la logique :

**fonctionnalités → interface → liens nécessaires → sauvegarde → difficulté → l10n → tableau de bord → contrôles internes → test joueur → corrections → validation finale**

Les micro-tests sont réservés aux infrastructures globales critiques comme sauvegarde/chargement, onboarding, accès véhicule ou synchronisation.

## Versions et builds

La numérotation reste volontairement **inférieure à 1.0.0.0** tant que le projet n’est pas terminé et validé.

Les archives livrées au joueur utilisent le nom :

`FS25_AgriLifeManager.zip`

Le numéro de version reste dans les métadonnées, le changelog et les informations internes du mod.

Un snapshot GitHub ne doit jamais être présenté comme une build plus récente qu’il ne l’est réellement.

## Fichiers à ne pas publier dans Git

Même avec un dépôt public, les éléments suivants restent exclus du versionnage :

- `log.txt` et crash dumps ;
- sauvegardes FS25 et backups ;
- fichiers `.env`, secrets, clés privées ou identifiants ;
- archives de travail ;
- dossiers locaux `mods`, caches, builds et fichiers temporaires.

Le `.gitignore` doit appliquer ces protections.

## Assets et composants tiers

Les fichiers originaux AgriLife peuvent être publiés avec l’autorisation de Chez_Squall.

Les composants ou assets tiers restent soumis aux droits, licences et conditions de redistribution de leurs auteurs. Leur présence dans une archive de développement ne constitue pas une autorisation automatique de republication sur GitHub.

## Builds officielles

Le dépôt public expose le développement, mais **une branche, un commit, un fork ou un snapshot GitHub n’est pas automatiquement une build officielle prête à jouer**.

Les builds officielles et leurs canaux de distribution restent décidés par Chez_Squall.

## Style et attribution

Le caractère em dash n’est pas utilisé dans les contenus du projet.

Aucune mention `Generated with...`, `Co-Authored-By:`, attribution à une IA, nom de modèle ou lien vers un fournisseur d’IA ne doit être ajouté aux commits, PR, releases, README, documentation, commentaires de code ou textes en jeu.

L’auteur public du projet reste **Chez_Squall**.

Voir `docs/WRITING_AND_ATTRIBUTION.md`.
