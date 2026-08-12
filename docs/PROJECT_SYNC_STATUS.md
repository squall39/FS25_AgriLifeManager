# État de synchronisation AgriLife Manager

Version de référence : **0.9.3.1 TEST**  
Build jouable de référence : `FS25_AgriLifeManager_0.9.3.1_TEST_final.zip`  
SHA-256 : `9651a39e2108b11be7d40078c2f73187aa619eecb8c68b521352be94f2f0678e`

## Règle permanente

Toute idée explicitement validée doit être reflétée dans :

1. la feuille de route additive et son registre maître ;
2. le tutoriel de départ si elle concerne le comportement joueur ;
3. le menu `Échap > Assistance`, qui partage les mêmes clés l10n ;
4. les 27 traductions distribuées ;
5. GitHub, pour conserver la décision, les sources et les audits maintenables ;
6. la build de référence.

Une idée documentée mais non codée garde le statut `À intégrer` ou `Partiellement intégrée`. Une fonctionnalité codée mais non testée reste `À certifier`.

## État 0.9.3.1 TEST

La build corrective contient **427 fichiers**, **118 Lua runtime actifs**, **84 XML** et **27 langues avec 5 023 clés chacune**.

Les systèmes de gameplay 0.9.3 restent inchangés : usure mécanique comportementale AgriLife, collisions séparées, consommation énergétique comportementale, constat joueur/IA, autorité patron pour Assurance/Banque, perte totale/épave et horaires centralisés.

Le correctif 0.9.3.1 traite F02 :

- retour à la palette AgriLife vert/anthracite et neutralisation des états bleu/violet persistants ;
- niveau actif visible dans l'en-tête sur toutes les pages ;
- difficulté verrouillée après validation de la carrière ;
- `Journal` renommé `Historique AgriLife` et fonction clarifiée ;
- correction `registerControls` des dialogues sous FS25 1.21 ;
- tutoriel, Historique et constat chargés comme dialogues et non comme frames ;
- correction de l'appel HomeFrame Banque hors portée ;
- aération des écrans Banque et Administration ;
- Assistance difficulté limitée aux trois niveaux officiels Facile, Normal et Difficile ;
- ancien branding GMC résiduel supprimé avec le reste du camion de service.

## Campagne de test active

F01 Facile reste enregistré comme **VALIDÉ EN JEU** sur la 0.9.3.0. Comme le dialogue paginé a été corrigé, son affichage doit être recontrôlé une fois. F02 est **À REFAIRE sur 0.9.3.1** avant le passage à F03.

Les résultats sont suivis dans `docs/TEST_RESULTS_0.9.3.0.md` et `docs/TEST_RESULTS_0.9.3.1.md`.

## GitHub

`main` conserve la documentation, les audits et les sources qui ont pu être matérialisées par le connecteur. La build ZIP ci-dessus reste la **référence exécutable exacte** utilisée pour les tests.

Le connecteur GitHub de cette session ne permet pas d'importer directement en masse l'arborescence locale complète, notamment les gros binaires et certains fichiers source/l10n absents de `main`. Il ne faut donc pas présenter `main` comme un miroir octet-par-octet du ZIP tant qu'un transfert dédié n'a pas été réalisé. Les corrections F02 et leur état de test sont néanmoins documentés sur `main` avec leur hash de build.

## Multijoueur

L'architecture multi-fermes est prévue, mais la publication multijoueur reste désactivée jusqu'à la campagne réseau dédiée. Une ferme devra posséder ses propres données AgriLife et les décisions sensibles resteront soumises aux permissions serveur.
