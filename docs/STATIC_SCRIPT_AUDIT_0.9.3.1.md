# Audit statique scripts - AgriLife Manager 0.9.3.1 TEST

Date : 12 août 2026.

## Objet

La 0.9.3.1 est un correctif de certification F02. Les systèmes de gameplay 0.9.3 restent inchangés ; le patch corrige les défauts d'interface observés en Facile.

## Corrections contrôlées

- Journal/Historique : compatibilité `registerControls` FS25 1.21 et libellé clarifié.
- Tutoriel : contrôleur chargé comme dialogue et non comme frame.
- Constat accident : même sécurisation du contrôleur avant son futur scénario de test.
- HomeFrame : appel Banque hors portée supprimé.
- Difficulté : affichage permanent dans l'en-tête et verrou après validation.
- Navigation : états selected/disabled neutralisés pour supprimer la surcouche bleu/violet.
- Banque et Administration : zones serrées aérées.
- Assistance : trois niveaux uniquement, Facile / Normal / Difficile.

## Résultats locaux de la build jouable

- version : 0.9.3.1 ;
- package TEST : 427 fichiers ;
- SHA-256 : `9651a39e2108b11be7d40078c2f73187aa619eecb8c68b521352be94f2f0678e` ;
- XML : 84 valides ;
- Lua runtime actifs : 118 ;
- localisation : 27 langues x 5023 clés ;
- `audit_l10n_usage.py` : OK ;
- `audit_publication.py` : OK ;
- `audit_roadmap_writing_completion.py` : OK ;
- `audit_workshop81_closure.py` : OK ;
- `audit_093_systems.py` : OK ;
- `audit_f02_ui_fix.py` : OK ;
- `verify_release.py` : OK ;
- camion de service / branding GMC dédié : absent ;
- huiles et lubrifiants : conservés ;
- multijoueur : toujours non publié.

## Certification terrain

F01 reste enregistré comme validé sur la 0.9.3.0. Le tutoriel paginé doit être recontrôlé une fois après correction. F02 reste non validé jusqu'au test de la 0.9.3.1 dans FS25 et au contrôle du nouveau `log.txt`.
