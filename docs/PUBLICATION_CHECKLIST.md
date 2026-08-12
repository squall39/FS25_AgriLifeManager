# Checklist de publication AgriLife Manager

Cette checklist distingue **écriture prête** et **certification en jeu**.

## Gates automatiques

- [x] Vérification XML et références locales.
- [x] Vérification des sources Lua déclarées dans `modDesc.xml`.
- [x] Vérification de parité l10n des 27 langues.
- [x] Vérification des clés l10n statiquement utilisées.
- [x] Vérification du style d'écriture du projet.
- [x] Vérification de l'absence de fichiers temporaires courants.
- [x] Vérification version pré-1.0 et multijoueur non publié.
- [x] Packaging reproductible avec profils TEST et PUBLIC.

## Vérifications manuelles avant publication stable

- [ ] Nouvelle carrière Facile complète.
- [ ] Nouvelle carrière Normal complète.
- [ ] Nouvelle carrière Difficile complète.
- [ ] Sauvegarde existante et migration.
- [ ] Reprise après sauvegarde endommagée réelle.
- [ ] Maps vanilla, modmaps et maps multifruits.
- [ ] Courseplay / AutoDrive présents et absents.
- [ ] Precision Farming / Soil Fertilizer présents et absents.
- [ ] MudSystem / Advanced Damage System présents et absents.
- [ ] Interface 1080p / 1440p / 4K.
- [ ] Contrats, marchés, locations, carburants, productions et foncier en cycle long.
- [ ] Atelier, pannes, commandes de pièces, assurance, constats et bonus-malus.
- [ ] Multijoueur et multi-fermes avant activation de `multiplayer supported="true"`.
- [ ] Log FS25 sans erreur ni avertissement AgriLife non justifié.
- [ ] Audit final des licences et ressources redistribuées.

Aucune case de certification terrain ne doit être fermée uniquement parce que le code existe.
