# Résultats de test - AgriLife Manager 0.9.3.1 TEST

Date : 12 août 2026
Difficulté : **Facile**
Build corrective : `FS25_AgriLifeManager_0.9.3.1_TEST_final.zip`
SHA-256 : `9651a39e2108b11be7d40078c2f73187aa619eecb8c68b521352be94f2f0678e`

## Origine

Cette build corrige les anomalies constatées pendant F02 sur la 0.9.3.0. Elle ne valide pas automatiquement F02 : le scénario doit être rejoué dans FS25.

## Historique

- F01 sur 0.9.3.0 : **VALIDÉ EN JEU**.
- F02 sur 0.9.3.0 : **KO / À CORRIGER**.

## Correctifs à revalider sur 0.9.3.1

- navigation vert/anthracite sans états bleu/violet persistants ;
- `MODE : FACILE`, `MODE : NORMAL` ou `MODE : DIFFICILE` visible dans l'en-tête sur toutes les pages ;
- difficulté verrouillée après validation de la carrière ;
- bouton `Historique AgriLife` explicite et dialogue fonctionnel ;
- tutoriel paginé Précédent / Suivant / Terminer sans fallback InfoDialog ;
- aucun appel nil dans HomeFrame lors de la Banque ;
- Banque et Administration sans chevauchement gênant ;
- sauvegarde, sortie complète, recharge et nouveau contrôle du `log.txt`.

**Statut F02 : À REFAIRE sur 0.9.3.1.**
