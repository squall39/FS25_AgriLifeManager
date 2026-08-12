# Tests - AgriLife Manager

Version de référence : **0.9.3.1 TEST**

La feuille de route active de certification terrain est :

- `docs/FS25_TEST_ROADMAP_0.9.3.1.md`

Elle est indépendante de `ROADMAP.md` et organise la campagne dans l’ordre **Facile → Normal → Difficile** avec un GO/NO-GO à la fin de chaque niveau.

La famille 0.9.3 ajoute à la campagne 0.9.2.0 la certification de l’usure mécanique comportementale AgriLife, la neutralisation de l’usure vanilla, les dommages de collision séparés, la consommation carburant/énergie comportementale, les constats joueur/IA, l’autorité exclusive du patron pour les décisions assurance/banque, le classement épave et les horaires d’ouverture.

Une fonction reste **À CERTIFIER** jusqu’à validation réelle dans FS25, sauvegarde/rechargement et contrôle du `log.txt`.

## Correctif F02 - 0.9.3.1

- F01 : validé en jeu sur la 0.9.3.0 ; recontrôle ciblé du tutoriel paginé requis après correction UI.
- F02 : non validé sur la 0.9.3.0 à cause du Journal, du fallback tutoriel, d'un appel HomeFrame hors portée et de la palette bleu/violet.
- 0.9.3.1 : corrige ces défauts, affiche le mode actif en permanence et verrouille la difficulté après validation.
- Reprendre la campagne par F02 avant F03.
