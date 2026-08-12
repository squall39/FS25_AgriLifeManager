# FS25_AgriLifeManager

**AgriLife Manager** est un mod PC pour Farming Simulator 25 centré sur la gestion complète d'une exploitation : démarrage de carrière, banque, entreprise, salariés, carrière et qualifications, administration, contrats, marchés, atelier, concessionnaire, assurances et systèmes de gestion associés.

## État courant

- Version source synchronisée : **0.9.1.0 TEST**
- Auteur : **Chez_Squall**
- Plateforme cible : PC
- Multijoueur : infrastructure écrite mais désactivée tant que la campagne réseau n'est pas certifiée
- Package joueur : `FS25_AgriLifeManager.zip`

## Feuille de route

`ROADMAP.md` reste le **registre maître additif** du projet. Aucune idée validée ne doit être supprimée ou condensée au point d'en perdre le contenu.

La passe 0.9.1.0 ferme les derniers scripts métier identifiés dans Démarrage, Interface et Banque. Les neuf étapes possèdent désormais leur écriture fonctionnelle.

**Écriture fonctionnelle hors tests : 100 % en Facile, Normal et Difficile.**

Cela ne signifie pas que le mod est certifié ou prêt à publier : les cases encore ouvertes concernent notamment les tests FS25 réels, sauvegarde/rechargement, compatibilités, contrôle visuel 1080p/1440p/4K, multijoueur, relectures de traduction et validation de publication.

## Fermeture 0.9.1.0

- relation bancaire et consultation d'offres enrichies ;
- profils de risque, sévérité, solidité et vitesse d'étude par banque ;
- conseiller compatible avec banque, dossier et objet de financement ;
- influence du marché et de la difficulté sur taux, capacité et décision ;
- grand livre professionnel avec catégories, contreparties, fournisseurs, contrats, références, types de flux et tags persistants ;
- filtres comptables par période, catégorie, fournisseur, contrat, type, source et tag ;
- distinction résultat / investissement / financement / capitaux propres ;
- amortissements ;
- compte de résultat ;
- bilan simplifié incluant trésorerie, matériel, foncier, productions, dettes et fiscalité ;
- capacité d'autofinancement et couverture du service de dette ;
- rentabilité par activité ;
- séparation compte professionnel / personnel plus contraignante selon la difficulté ;
- synthèses Banque et Carrière sur le tableau de bord ;
- politique responsive prudente 1080p / 1440p / 4K ;
- affichage monétaire professionnel au centime.

## Organisation du dépôt

Le package joueur reste la source de vérité exécutable. GitHub publie les sources texte maintenables et la roadmap complète lorsque cela est pertinent. Certains gros fichiers historiques et assets binaires ne sont pas automatiquement republiés ; le manifeste de synchronisation indique cette limite.

## Règles de développement

- Trois difficultés uniquement : **Facile / Normal / Difficile**.
- Chaque fonctionnalité doit avoir une conséquence réelle en jeu.
- Une seule autorité par système métier.
- Courseplay, AutoDrive, Precision Farming, Soil Fertilizer, MudSystem et les systèmes mécaniques tiers restent optionnels.
- Les contenus maps/multifruits sont détectés dynamiquement lorsque FS25 le permet.
- Les 27 langues distribuées gardent exactement le même jeu de clés l10n.
- La version reste sous `1.0.0.0` tant que le projet n'est pas entièrement certifié.

© 2026 Chez_Squall.
