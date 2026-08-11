# Changelog - AgriLife Manager

Toutes les évolutions importantes du projet sont consignées ici.

## 0.7.0.0

- Étape 1 Démarrage : machine d'état centrale pour migration, tutoriel, difficulté, banque, conseiller, examen et carrière prête.
- Étape 1 Démarrage : logique isolée dans `src/modules/economy/EconomyStartupRoadmap1.lua` afin d'éviter de maintenir un patch géant de `Economy6Service.lua`.
- Étape 2 Interface : couche UI transversale à six modules dans `src/ui/AgriLifeInterface6.lua`, redirections de navigation et verrouillage visuel cohérent.
- Étape 3 Banque : extensions de la feuille de route dans `src/modules/bank/BankRoadmap3.lua`, avec dette FS25 héritée séparée, détail des prêts, historique filtrable, prévision de trésorerie, analyse de financement et checklist.
- Réorganisation GitHub : suppression de l'arborescence active `development/steps/` et de ses patches découpés. Ces fichiers restent disponibles dans l'historique Git.
- Réorganisation GitHub : la source courante est désormais publiée directement à ses chemins réels. `development/` est réservé aux notes de chantier.
- Ajout de `.gitignore` pour exclure archives, sauvegardes, logs, caches et fichiers temporaires.
- Ajout de `docs/REPOSITORY_LAYOUT.md` pour définir une structure de dépôt unique et lisible.
- Distribution : séparation explicite entre dépôt source officiel et package jouable.
- Build joueur correspondante : `FS25_AgriLifeManager.zip`, SHA-256 `45a66c117f1525418409c2917d20a1e68ebaf5058425e8240745c6737946d6d2`.
- Vérification statique : **OK - 91 XML, 80 Lua actifs, 146 callbacks, 210 contrôles, 27 langues, 4 831 clés l10n**.
- Les tests en jeu restent à poursuivre. La synchronisation du code ne marque pas les étapes comme validées fonctionnellement.

## 0.6.4.38

- Écriture projet : nettoyage du style dans tous les fichiers texte du package.
- Qualité : le vérificateur de release contrôle le style et la parité l10n.
- Onboarding : suppression d'un message français codé en dur, remplacé par une clé l10n déjà distribuée.
- Compte personnel : affichage des montants détaillés au centime et arrondi des mouvements de paie au centime afin que le relevé puisse être recalculé ligne par ligne.
- Permis provisoire Normal : l'amende de 500 € utilise le type explicite `PROVISIONAL_LICENCE_FINE` pour afficher son libellé dédié dans le relevé personnel.
- Traductions : suppression de la clé inutilisée et vide `agrilifemanager_fmf_viaSearchUsed` et correction de `agrilifemanager_label_pluralS` en allemand.
- Contribution GitHub #2 : intégration des corrections sûres sans écraser le référentiel de traduction plus récent de la build courante. Le dialogue tutoriel paginé reste à rebaser et tester séparément.
- Vérification statique : **OK - 89 XML, 59 Lua actifs, 129 callbacks, 208 contrôles, 27 langues, 4 684 clés par langue**.

## 0.6.4.30

- Examen étape 3/10 : correction du blocage du trajet de 800 m.
- Étape 3 : lecture directe de l'état de l'équipement assigné pour éviter un faux état actif pendant le déplacement.
- Étape 4 : lecture directe de l'état de l'équipement assigné.
- Onboarding : tant que la difficulté n'est pas confirmée, l'entrée ou la prise de contrôle d'un véhicule est bloquée.
- Aucun changement de schéma de sauvegarde.

## 0.6.4.29

- Examen étape 1 : parcours effectué avec le tracteur seul.
- Étape 2 : l'attelage doit être effectué après le début de l'étape.
- Étape 3 : préparation du transport renforcée.
- Étape 4 : validation après une vraie transition vers la position de travail.

## 0.6.4.28

- Banque : correction du chargement des pictogrammes internes.
- Les 21 pictogrammes Banque possèdent un ID GUI explicite et un chemin résolu après initialisation du GUI.
- Rendu Banque validé en jeu en 1920x1080.

## 0.6.4.27

- Banque : première normalisation du jeu d'icônes internes.
- Création de `gui/bankicons` et correction du libellé Banque partenaire.

## 0.6.4.26

- Correction complémentaire du blocage de l'étape 6/10.
- L'étape 6 valide l'équipement arrêté et relevé.
- Examen 1 à 10, obtention du permis, rechargement et isolation entre sauvegardes validés en jeu le 10 août 2026.

## 0.6.4.25

- Correction du blocage de l'étape 6/10 après validation du travail.
- Message de réussite d'une étape affiché plus longtemps.
- Notification FS25 explicite lors de chaque étape validée.

## Versions antérieures

Les versions 0.6.4.x antérieures correspondent aux phases successives de restructuration d'AgriLife Manager : persistance par sauvegarde, migration, Banque, carrière et XP, examens, société, personnel, assurances, atelier, tutoriel et Assistance.
