# Tests - AgriLife Manager

## Règle

Les tests statiques vérifient la cohérence du source. La certification d'un bloc exige ensuite une campagne réelle dans Farming Simulator 25.

## Contrôles automatiques

La build 0.7.8.0 dispose notamment de :

- tests fonctionnels généraux ;
- tests Entreprise ;
- tests Carrière & Qualifications ;
- tests Administration ;
- parité l10n ;
- style d'écriture ;
- syntaxe Lua ;
- parsing XML ;
- vérification des sources `modDesc.xml` ;
- vérification de release.

## Campagne en jeu attendue

Pour chaque grand bloc :

1. nouvelle carrière ;
2. sauvegarde/rechargement ;
3. Facile / Normal / Difficile lorsque pertinent ;
4. ancienne sauvegarde/migration si le schéma est concerné ;
5. fonctionnement sans mods tiers ;
6. compatibilités tierces concernées ;
7. lecture du `log.txt` ;
8. contrôle de non-régression des blocs précédents.

## Priorités actuelles de certification

- Démarrage Difficile et chaîne des 10 examens ;
- Entreprise : IA native, paie, planning, Courseplay/AutoDrive et reload ;
- Carrière & Qualifications : examens et verrous de qualifications ;
- Administration : contrôles, régularisation, contentieux et restrictions ;
- puis étapes 7 et 8 avant la campagne finale A -> Z.

## Multijoueur

Ne pas réactiver `supported=true` avant une campagne réseau dédiée : création/chargement des fermes, autorité serveur, permissions, événements, reconnexion et isolation des données par ferme.
