# État de synchronisation AgriLife Manager

Version de référence : **0.9.3.0 TEST**  
Build jouable de référence : `FS25_AgriLifeManager_0.9.3.0_TEST_final.zip`  
SHA-256 : `303a1f11111e8e8d40be65f5e93081dec0686e89e2c69d05ba2f10521202a7fa`

## Règle permanente

Toute idée explicitement validée doit être reflétée dans :

1. la feuille de route additive et son registre maître ;
2. le tutoriel de départ si elle concerne le comportement joueur ;
3. le menu `Échap > Assistance`, qui partage les mêmes clés l10n ;
4. les 27 traductions distribuées ;
5. GitHub, pour conserver la décision, les sources et les audits maintenables ;
6. la build de référence.

Une idée documentée mais non codée garde le statut `À intégrer` ou `Partiellement intégrée`. Une fonctionnalité codée mais non testée reste `À certifier`.

## État 0.9.3.0 TEST

La build de référence contient **424 fichiers**, **118 Lua runtime actifs**, **84 XML** et **27 langues avec 5 023 clés chacune**.

La fermeture Atelier 8.1 est intégrée : parc maintenable complet, verrou de casse lourde, kit terrain limité, remorquage, pièces physiques, réparation interne/concessionnaire, assurance mécanique, délais internes plus longs et matériel de remplacement. Le camion de service achetable par le joueur est retiré ; les huiles et lubrifiants utiles restent conservés.

La 0.9.3.0 ajoute :

- usure mécanique comportementale AgriLife, avec neutralisation de l’usure mécanique vanilla comme source de réparation ;
- collisions traitées comme dommages événementiels distincts de l’usure progressive ;
- consommation carburant/énergie selon puissance, charge, régime, comportement, état mécanique et difficulté ;
- constat manuel pour un conducteur joueur et constat automatique pour un ouvrier IA ;
- décisions Assurance/Banque sensibles réservées au patron/propriétaire ;
- classement perte totale/épave avec proposition économique et acceptation explicite du patron ;
- horaires centralisés : Banque 08:00-12:00 / 14:00-18:00, concessionnaire 08:00-19:00, atelier personnel 24/7, usines 08:00-19:00 pour les interactions commerciales, points de vente 08:00-12:00 / 14:00-18:00.

## Campagne de test active

La campagne officielle suit `docs/FS25_TEST_ROADMAP_0.9.3.0.md`, dans l’ordre **Facile → Normal → Difficile**, avec un gate après chaque difficulté.

## GitHub

`main` conserve les sources maintenables, la documentation, les audits et l’historique utile du projet. Les anciens runners/workflows/payloads one-shot de synchronisation devenus inutiles ont été supprimés et aucune référence active au camion de service ne doit subsister.

La build ZIP ci-dessus reste la **référence exécutable exacte** utilisée pour les tests. Le connecteur GitHub utilisé dans cette session ne permet pas d’importer directement en masse les gros fichiers binaires locaux DDS/I3D ; ils ne doivent donc pas être déclarés comme miroir complet tant qu’un transfert binaire dédié n’a pas été réalisé. Leur contenu de référence reste celui du ZIP validé.

## Multijoueur

L’architecture multi-fermes est prévue, mais la publication multijoueur reste désactivée jusqu’à la campagne réseau dédiée. Une ferme devra posséder ses propres données AgriLife et les décisions sensibles resteront soumises aux permissions serveur.
