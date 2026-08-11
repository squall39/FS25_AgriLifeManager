# Changelog - AgriLife Manager

Toutes les évolutions importantes du projet sont consignées ici.

## 0.6.4.38

- Écriture projet : suppression du caractère em dash dans tous les fichiers texte du package.
- Qualité : le vérificateur de release contrôle désormais le style, l’attribution et la parité l10n.
- Onboarding : suppression d’un message français codé en dur, remplacé par une clé l10n déjà distribuée.
- Compte personnel : affichage des montants détaillés au centime et arrondi des mouvements de paie au centime afin que le relevé puisse être recalculé ligne par ligne.
- Permis provisoire Normal : l’amende de 500 € utilise désormais le type explicite `PROVISIONAL_LICENCE_FINE` pour afficher son libellé dédié dans le relevé personnel.
- Traductions : suppression de la clé inutilisée et vide `agrilifemanager_fmf_viaSearchUsed` et correction de `agrilifemanager_label_pluralS` en allemand.
- Contribution GitHub #2 : intégration des corrections sûres sans écraser le référentiel de traduction plus récent de la build courante. Le dialogue tutoriel paginé reste à rebaser et tester séparément.
- Vérification statique : **OK - 89 XML, 59 Lua actifs, 129 callbacks, 208 contrôles, 27 langues, 4 684 clés par langue, aucune clé manquante, dupliquée ou vide**.

## 0.6.4.30

- Examen étape **3/10** : correction du blocage du trajet de 800 m.
- Cause identifiée : `getIsOperating()` sur un outil `Attachable` peut hériter de l’état du tracteur parent dans FS25 et maintenir artificiellement l’outil en état actif pendant le déplacement.
- L’étape 3 utilise désormais l’état direct de l’équipement assigné : **relevé, éteint et sans traitement WorkArea**.
- Ajout du diagnostic `Route-state` dans `log.txt` pour connaître précisément `transportReady`, `lowered`, `turnedOn` et `processing`.
- Étape 4 : lecture directe de l’état de l’équipement assigné afin d’éviter les faux états hérités.
- Texte étape 3 corrigé : **800 m en position transport** ; suppression de la notion trompeuse de « zone de travail ».
- Onboarding : tant que la difficulté n’est pas confirmée, l’entrée / prise de contrôle d’un véhicule est bloquée ; un contrôle obtenu par un autre chemin est annulé.
- Ajout de la clé l10n `agrilife_difficulty_vehicle_locked` dans les traductions distribuées.
- Aucun changement de schéma de sauvegarde.
- Vérification statique : **OK - 89 XML, 59 Lua actifs, 129 callbacks, 206 contrôles, 6 ressources modDesc, 73 références de ressources XML**.

## 0.6.4.29

- Examen étape 1 : parcours désormais strictement effectué avec le tracteur seul.
- Tout outil attelé pendant l’étape 1 bloque la progression et remet la distance de cette étape à zéro.
- Étape 2 : l’attelage doit être effectué après le début de l’étape ; un outil déjà attaché ne peut plus la valider automatiquement.
- Étape 3 : préparation du transport renforcée.
- Étape 4 : validation après une vraie transition vers la position de travail.
- Étapes 5 à 10 et résultat final inchangés.

## 0.6.4.28

- Banque : correction racine du chargement des pictogrammes internes.
- Les 21 pictogrammes Banque possèdent un ID GUI explicite et sont résolus en Lua avec un chemin absolu après initialisation du GUI.
- Textures Banque normalisées en 128×128 DXT5 avec mipmaps.
- Diagnostic : `Bank pictograms resolved 21/21 with absolute paths`.
- Rendu Banque validé en jeu en 1920×1080.

## 0.6.4.27

- Banque : première normalisation du jeu d’icônes internes.
- Création de `gui/bankicons` et correction du libellé `Banque partenaire`.
- Aucun changement de logique bancaire ni de schéma de sauvegarde.

## 0.6.4.26

- Correction complémentaire du blocage de l’étape **6/10**.
- L’étape 6 valide l’action réellement demandée : **équipement arrêté et relevé** ; le repliage n’est plus bloquant.
- Ajout du diagnostic `Secure-state` dans `log.txt`.
- Examen 1→10, obtention du permis, rechargement et isolation entre sauvegardes validés en jeu le 10 août 2026.

## 0.6.4.25

- Correction du blocage de l’étape 6/10 après validation du travail.
- Message de réussite d’une étape affiché plus longtemps.
- Notification FS25 explicite lors de chaque étape validée.
- `gui/icons/success.dds` recompressé en DXT5.

### Personnel - conception conservée, implémentation après stabilisation

La séparation **joueur humain / GPS natif / salariés AgriLife**, la règle **1 salarié disponible = 1 tâche active maximum**, la paie unique AgriLife et le futur centre d’ordres restent validés dans `docs/WORKFORCE_DESIGN.md`. Leur implémentation ne doit pas interrompre la stabilisation actuelle des examens, du HUD, de la persistance, de l’onboarding et des difficultés.

## 0.6.4.24

- Correction du blocage de l’épreuve 5/10 avec preuve de travail/distance de secours.
- Le HUD conserve l’action exacte à réaliser même en difficulté Difficile.
- Chaque étape réussie déclenche un état HUD vert avec pictogramme de réussite.
- Tableau de bord : Banque → Conseiller → Société → Permis.

## Versions antérieures

Les versions 0.6.4.x antérieures correspondent aux phases successives de restructuration d’AgriLife Manager : persistance par sauvegarde, migration, Banque, carrière/XP, examens, société, personnel, assurances, atelier, tutoriel et Assistance.
