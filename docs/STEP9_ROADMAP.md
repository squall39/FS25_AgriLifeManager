# 9 - Finalisation

> **État code 0.9.0.0 TEST :** l'infrastructure prévue pour l'étape 9 est écrite et intégrée : compatibilités optionnelles et fallback, découverte universelle, schéma de sauvegarde 4, migration 3 vers 4, identité de carrière, récupération backup, audit de persistance, isolation multi-fermes, squelette réseau serveur autoritaire, tutoriel paginé rebasé, audits l10n/publication, glossaire, documentation et packaging TEST/PUBLIC. Le multijoueur reste volontairement non publié et toutes les cases exigeant une vraie campagne FS25 restent ouvertes jusqu'à certification.

La Finalisation n’est **pas un module joueur**. Elle regroupe les phases techniques nécessaires pour rendre AgriLifeManager stable, compatible, traduisible, migrable, multijoueur et publiable.

## Compatibilités PC optionnelles

> **Écriture 0.9.0.0 :** matrice Courseplay/AutoDrive/PF/Soil/MudSystem/ADS, fallback autonome et audit dynamique du contenu runtime intégrés. Les essais réels avec plusieurs combinaisons de mods/maps restent à certifier.

AgriLife Manager doit rester autonome : aucune compatibilité ne doit devenir une dépendance dure.

- [ ] Courseplay.
- [ ] AutoDrive.
- [ ] Soil Fertilizer - intégration enrichie mais optionnelle.
- [ ] Precision Farming - intégration enrichie mais optionnelle.
- [ ] Autres mods de gestion ou réalisme identifiés pendant les tests.
- [ ] Vérifier qu’AgriLife continue à fonctionner correctement lorsque ces mods sont absents.
- [ ] Vérifier l’auto-détection sur plusieurs maps vanilla, modmaps et maps multifruits.

## Sauvegardes, migration & multijoueur

> **Écriture 0.9.0.0 :** schéma 4, migration 3->4, identité de carrière, suivi backup, couverture de persistance, séparation multi-fermes et enveloppes réseau serveur autoritaires intégrés. `multiplayer supported="false"` reste obligatoire jusqu'à la campagne réseau réelle.

- [x] État AgriLife enregistré dans la sauvegarde carrière FS25.
- [x] Migration des sauvegardes existantes sans écraser leur patrimoine - à revalider dans la campagne Démarrage actuelle.
- [x] Conservation de la dette FS25 existante comme dette héritée - à revalider dans la campagne Démarrage actuelle.
- [x] Nouvelle carrière : capital AgriLife et gestion dédiée du démarrage.
- [ ] Garantir qu’une nouvelle partie ne récupère jamais la progression AgriLife d’une autre sauvegarde.
- [ ] Sauvegarder l’état des marchés, locations, contrats et tendances économiques par carrière.
- [ ] Renforcer les migrations entre versions du mod.
- [ ] Tests de corruption/récupération backup.
- [ ] Multi-fermes.
- [ ] Multijoueur complet.
- [ ] Autorité serveur et synchronisation réseau de tous les modules.

## Traductions, localisation & clés l10n

> **Écriture 0.9.0.0 :** le dialogue tutoriel paginé est rebasé sur la source courante, Prev/Next sont localisés directement, les 27 langues sont en parité et les audits de clés utilisées, valeurs vides, doublons et placeholders font partie du gate de packaging. La relecture native et les essais écran restent à certifier.

### Contribution issue GitHub #2 à intégrer proprement

Une contribution externe propose 27 fichiers de traduction alignés, un correctif de texte onboarding codé en dur, un dialogue tutoriel paginé et un outil de contrôle de parité l10n. Cette contribution a été préparée sur une base annonçant **4 636 clés** par langue.

- [ ] Ne pas écraser les traductions de la build courante avec ce ZIP sans comparaison, car le projet a continué à évoluer depuis la base utilisée par le contributeur.
- [ ] Rebaser les 34 clés manquantes proposées sur le référentiel l10n réellement courant.
- [ ] Intégrer la clé `agrilife_onboarding_tutorial_first_msg` si elle est toujours nécessaire et supprimer le texte joueur codé en dur correspondant.
- [ ] Vérifier la correction du libellé allemand `agrilifemanager_label_pluralS`.
- [ ] Examiner la clé `agrilifemanager_fmf_viaSearchUsed`, vide dans la contribution, puis la définir ou la retirer si elle est réellement inutilisée.
- [ ] Intégrer ou adapter `tests/l10n_parity_spec.lua` comme contrôle automatique avant build.
- [ ] Tester le dialogue tutoriel paginé en jeu avant adoption définitive, notamment Prev / Next, compteur de page, fermeture Échap et parcours migration.
- [ ] Vérifier que les boutons Prev / Next utilisent bien leurs clés l10n directement dans le XML, correctif signalé dans le ZIP reconstruit du contributeur.
- [ ] Garder l’espagnol `es` et `ea` à vérifier selon la variante régionale réellement attendue par FS25.

### Référentiel de clés

- [ ] Utiliser une langue de référence complète pour recenser toutes les clés du mod.
- [ ] Inventorier automatiquement toutes les clés l10n utilisées dans Lua, XML, GUI, tutoriel, assistance, notifications, examens, menus et modules.
- [ ] Comparer chaque fichier de langue au référentiel et détecter clés absentes, doublons, clés inutilisées et fautes de nommage.
- [ ] Interdire les textes joueur codés directement dans Lua/XML lorsque le système l10n peut être utilisé.
- [ ] Ajouter une vérification de cohérence des clés avant chaque build importante.

### Traductions complètes

- [ ] Français complet et relu.
- [ ] Anglais complet et relu.
- [ ] Compléter toutes les autres langues distribuées avec le mod.
- [ ] Étendre progressivement la localisation aux langues pertinentes de FS25/ModHub afin que le mod puisse être utilisé par le plus grand nombre.
- [ ] Lorsqu’une nouvelle clé est ajoutée à une fonctionnalité, l’ajouter immédiatement à **tous** les fichiers de langue, même si certaines traductions restent temporairement marquées à relire pendant le développement.
- [ ] Aucune version publique ne doit afficher une clé brute du type `agrilife_xxx`, un texte vide ou un fallback anglais involontaire.

### Qualité de traduction

- [ ] Employer une terminologie agricole, bancaire, comptable, juridique et administrative cohérente dans chaque langue.
- [ ] Vérifier accents, caractères spéciaux, encodage UTF-8 et longueur des textes dans l’interface.
- [ ] Tester les textes longs en 1080p / 1440p / 4K pour éviter débordements et boutons coupés.
- [ ] Vérifier pluriels, montants, unités, dates et formulations contextuelles.
- [ ] Maintenir un glossaire AgriLife afin que les mêmes termes soient traduits de façon cohérente dans tout le mod.

### Critères l10n avant publication

- [ ] **0 clé manquante dans toutes les langues distribuées.**
- [ ] **0 texte joueur codé en dur non justifié.**
- [ ] **0 clé l10n brute visible en jeu.**
- [ ] **0 traduction volontairement laissée vide.**
- [ ] Audit complet des traductions après chaque ajout massif de fonctionnalités.

## Méthode de développement & validation

- Conserver une base jouable stable avant d’ouvrir un nouveau grand bloc.
- **Terminer entièrement le bloc ou module en cours avant de passer au suivant.**
- Ordre obligatoire : **Démarrage → Interface de base → Banque → Entreprise → Carrière & Qualifications → Administration → Contrats & Marchés → Atelier → Finalisation**.
- Ne pas commencer le développement fonctionnel d’un module futur simplement parce que le module courant lui transmettra une donnée ; préparer seulement le point de connexion nécessaire côté module courant.
- Développer **un système complet et cohérent** avant de demander un test joueur, au lieu d’enchaîner les micro-builds et micro-tests.
- Continuer les contrôles statiques/verifiers après chaque changement de développement.
- Réserver les tests rapides intermédiaires aux infrastructures globales critiques : sauvegarde/chargement, onboarding, accès véhicule, synchronisation ou autre mécanisme transversal.
- Chaque module doit être testé comme un vrai cycle de gameplay complet avec ses conséquences et ses interactions.
- Un module n’est considéré terminé qu’après : fonctionnalités → interface → liens nécessaires → sauvegarde → difficulté → l10n → tableau de bord → contrôles internes → test joueur → corrections → validation finale.
- Avant chaque commit, release, documentation ou build : contrôler l’absence du caractère em dash et l’absence de toute attribution à une IA ou à un fournisseur d’IA.

## Préparation publication

> **Écriture 0.9.0.0 :** `verify_release.py`, `audit_l10n_usage.py`, `audit_publication.py` et `package_release.py` constituent le gate de packaging TEST/PUBLIC. La publication stable reste interdite tant que les validations en jeu et licences finales ne sont pas fermées.

Objectif final : version PC propre et publiable, notamment pour soumission officielle GIANTS/ModHub si elle respecte les exigences applicables au moment de la soumission.

- [ ] Audit complet du modDesc.
- [ ] Vérification copyrights et licences des composants tiers.
- [ ] Nettoyage des fichiers de développement et tests non nécessaires au package final.
- [ ] Suppression des logs/debugs de développement inutiles.
- [ ] Validation XML/Lua/assets/l10n.
- [ ] Tests nouvelle partie / sauvegarde existante / migration / reprise après crash.
- [ ] Tests des trois difficultés **Facile / Normal / Difficile** sur les modules majeurs.
- [ ] Tests sans mods tiers.
- [ ] Tests avec les principaux mods de compatibilité.
- [ ] Tests sur maps vanilla, modmaps et maps multifruits.
- [ ] Tests du marché dynamique, des locations, contrats, coopératives, carburants, usines et foncier.
- [ ] Tests 1080p / 1440p / 4K.
- [ ] Audit final des traductions et des clés l10n.
- [ ] Documentation utilisateur finale.
- [ ] Changelog de release.
- [ ] Packaging final propre.
- [ ] Les archives de build livrées utilisent le nom **`FS25_AgriLifeManager.zip`** ; le numéro de version reste dans les métadonnées/changelog.
- [ ] Version publique uniquement lorsque le projet est suffisamment stable.
- [ ] Conserver une numérotation **inférieure à 1.0.0.0** tant que les grands systèmes ne sont pas terminés et validés.

---
