# Tests - AgriLife Manager

Version de référence : **0.9.1.0 TEST**

## Principe

Une fonction peut être écrite et intégrée sans être certifiée en jeu. Les contrôles statiques, audits Python et specs Lua éliminent les défauts évidents, mais la validation finale exige FS25, sauvegarde/rechargement, contrôle visuel et lecture du `log.txt`.

Le statut **ÉCRIT / À CERTIFIER** ne doit jamais être confondu avec **VALIDÉ EN JEU**.

## État de la build 0.9.1.0

L'écriture fonctionnelle hors tests est considérée comme complète pour **Facile, Normal et Difficile**. La certification terrain reste ouverte.

Contrôles hors jeu actuellement documentés :

- `audit_roadmap_writing_completion.py` : OK ;
- `verify_release.py` : OK ;
- `audit_l10n_usage.py` : OK ;
- `audit_publication.py` : OK ;
- `writing_style_spec.py` : OK ;
- sources actives manquantes dans `modDesc.xml` : **0** ;
- XML : **91** ;
- Lua actifs déclarés ou spécialisés : **108** ;
- callbacks UI : **170** ;
- contrôles UI : **229** ;
- langues : **27** ;
- clés l10n : **5 019 par langue**.

Les specs Lua présentes dans le dépôt ne sont pas considérées comme exécutées lorsqu'aucun runtime Lua/luac n'est disponible dans l'environnement de construction.

## Certification terrain obligatoire

Le protocole détaillé se trouve dans `docs/FS25_CERTIFICATION_A_TO_Z.md`.

La certification doit couvrir au minimum :

- installation propre de la build TEST ;
- nouvelle partie pour Facile, Normal et Difficile ;
- onboarding et tutoriel après l'entrée effective sur la map ;
- banque, conseiller, financement et comptabilité ;
- création/état de l'exploitation selon la difficulté ;
- permis agricole et ses 10 étapes ;
- XP, catégories d'activité, niveaux et HUD ;
- salariés, contrats, administration et marchés ;
- atelier, pannes, entretien, assurance et historique technique ;
- sauvegarde/rechargement et migrations ;
- fonctionnement sans mods tiers ;
- compatibilités optionnelles lorsqu'elles sont présentes ;
- map vanilla, modmap et cas multifruits ;
- plusieurs résolutions/UI scales pertinentes ;
- absence d'erreur Lua et de warning AgriLife Manager anormal dans `log.txt`.

## Multijoueur

L'infrastructure réseau existe mais la publication multijoueur reste désactivée. Aucun scénario multi ne doit faire passer le statut public à compatible tant que la certification réseau dédiée n'a pas été réalisée.

## Critère de validation d'un scénario

Un scénario n'est marqué **VALIDÉ EN JEU** que si :

1. le résultat observé correspond au résultat attendu ;
2. la sauvegarde/recharge ne casse pas l'état concerné lorsque le scénario est persistant ;
3. le `log.txt` ne contient pas d'erreur Lua liée au mod ;
4. aucune régression UI bloquante n'est observée ;
5. les preuves minimales demandées par le protocole sont conservées.

## Règle de roadmap

Une case de `ROADMAP.md` exigeant une validation terrain reste ouverte tant que la certification FS25 correspondante n'a pas été effectuée, même si son code est déjà écrit.
