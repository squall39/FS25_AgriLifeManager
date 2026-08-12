# Résultats de certification en jeu - AgriLife Manager 0.9.3.0 TEST

Date de campagne : 12 août 2026
Build de référence : `FS25_AgriLifeManager_0.9.3.0_TEST_final.zip`
Difficulté en cours : **Facile**

> Ce document enregistre uniquement les validations réellement effectuées dans Farming Simulator 25. Un test statique ou une fonction écrite ne suffit pas pour passer un scénario en VALIDÉ EN JEU.

## PHASE 1 - FACILE

### F01 - Création de carrière et onboarding

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
- cycle d'arrêt AgriLife propre observé (`STOPPING -> STOPPED`, destruction du Core et détachement du listener) ;
- aucun défaut AgriLife bloquant identifié dans les éléments contrôlés du premier log ;
- des warnings/erreurs concernant d'autres mods ou noms de mods existent dans le log global et ne sont pas attribués à AgriLife Manager.

**Décision : F01 = OK / CERTIFIÉ EN JEU.**

> Note de suivi : la 0.9.3.1 corrige le dialogue paginé. Le fonctionnement général de F01 reste enregistré comme validé, mais l'affichage du tutoriel paginé doit être recontrôlé une fois sur la build corrective.

### F02 - Interface et HUD

**Statut : KO / À CORRIGER SUR 0.9.3.0**

Résultat du test du 12 août 2026 :
- palette bleu/violet rejetée par le testeur ; retour demandé à l'identité visuelle AgriLife vert/anthracite ;
- niveau actif Facile/Normal/Difficile insuffisamment visible une fois la carrière lancée ;
- bouton `Journal` peu explicite ;
- erreur runtime `AgriLifeJournalDialog.lua:25` : méthode `registerControls` indisponible ;
- erreur runtime `AgriLifeHomeFrame.lua:3210` liée à un helper local hors portée dans l'extension Banque ;
- tutoriel paginé indisponible et fallback `InfoDialog` observé sur les 13 pages ;
- Banque et Administration jugées trop serrées à certains endroits.

**Décision : F02 = NON VALIDÉ. Correctif ciblé 0.9.3.1 requis avant F03.**
