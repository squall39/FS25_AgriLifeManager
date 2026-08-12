# Résultats de certification en jeu — AgriLife Manager 0.9.3.0 TEST

Date de campagne : 12 août 2026
Build de référence : `FS25_AgriLifeManager_0.9.3.0_TEST_final.zip`
Difficulté en cours : **Facile**

> Ce document enregistre uniquement les validations réellement effectuées dans Farming Simulator 25. Un test statique ou une fonction écrite ne suffit pas pour passer un scénario en VALIDÉ EN JEU.

## PHASE 1 — FACILE

### F01 — Création de carrière et onboarding

**Statut : VALIDÉ EN JEU**

Validation joueur : 12 août 2026, campagne Facile.

Points déclarés validés :
- création de la sauvegarde de test en Facile ;
- onboarding au bon moment après entrée réelle sur la map ;
- tutoriel utilisable ;
- navigation du tutoriel ;
- Assistance cohérente ;
- règles de départ Facile acceptées comme conformes.

Contrôle du log transmis :
- `FS25_AgriLifeManager` détecté en version `0.9.3.0` ;
- cycle d’arrêt AgriLife propre observé (`STOPPING -> STOPPED`, destruction du Core et détachement du listener) ;
- aucun défaut AgriLife bloquant identifié dans les éléments contrôlés du log ;
- des warnings/erreurs concernant d’autres mods ou noms de mods existent dans le log global et ne sont pas attribués à AgriLife Manager.

**Décision : F01 = OK / CERTIFIÉ EN JEU.**

### F02 — Interface et HUD

**Statut : EN TEST**

À contrôler :
- ouvrir les six modules du tableau de bord ;
- navigation, boutons, textes et absence de chevauchement ;
- mini-PDA / couronne XP ;
- progression permis séparée de l’XP ;
- libellés d’activité ;
- sauvegarde puis recharge avec l’interface déjà utilisée.
