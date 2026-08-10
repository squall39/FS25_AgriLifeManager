# Publication du source — AgriLife Manager

## Statut

Le dépôt `squall39/FS25_AgriLifeManager` est désormais un **dépôt public officiel de développement**.

Chez_Squall a autorisé le **10 août 2026** la publication sur GitHub du code source et des fichiers originaux AgriLife Manager.

Cette décision concerne la visibilité et la collaboration autour du projet. **Elle ne change pas l’ordre de développement validé.**

## Ordre de travail inchangé

Le programme reste :

1. stabilisation des builds TEST actuelles ;
2. validation complète des examens, du HUD, de la persistance par sauvegarde, de l’onboarding et des trois difficultés ;
3. Réputation de l’exploitation ;
4. Comptabilité & fiscalité ;
5. Contrôles administratifs & sanctions ;
6. poursuite progressive des autres phases définies dans `ROADMAP.md`.

La méthode reste également inchangée :

**correction / intégration → test ciblé en jeu → log et retour → correction → validation → étape suivante.**

Une demande, idée ou contribution GitHub ne modifie donc pas automatiquement les priorités. Elle doit rester cohérente avec la feuille de route et les principes AgriLife.

## Versions et snapshots

La dernière archive de code réellement disponible lors de cette mise à jour est **0.6.4.24 TEST**.

La documentation de développement décrit déjà certains travaux ciblés pour **0.6.4.25 TEST**, notamment la séparation joueur humain / GPS natif / salariés AgriLife. Un snapshot 0.6.4.24 ne doit donc jamais être présenté comme du code 0.6.4.25.

La numérotation reste volontairement **inférieure à 1.0.0.0** tant que le projet n’est pas terminé et validé.

## Fichiers à ne pas publier dans Git

Même avec un dépôt public, les éléments suivants restent exclus du versionnage :

- `log.txt` et crash dumps ;
- sauvegardes FS25 et backups ;
- fichiers `.env`, secrets, clés privées ou identifiants ;
- archives de travail et packages TEST ;
- dossiers locaux `mods`, caches, builds et fichiers temporaires.

Le `.gitignore` du dépôt applique ces protections.

## Assets et composants tiers

Les fichiers originaux AgriLife peuvent être publiés avec l’autorisation de Chez_Squall.

Les composants ou assets tiers restent soumis aux droits, licences et conditions de redistribution de leurs auteurs. Leur présence dans une archive de développement ne doit pas être interprétée comme une autorisation automatique de les republier sur GitHub.

## Builds officielles

Le dépôt public expose le développement, mais **une branche, un commit, un fork ou un snapshot GitHub n’est pas automatiquement une build officielle prête à jouer**.

Les builds officielles et leurs canaux de distribution restent décidés par Chez_Squall.
