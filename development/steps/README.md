# Intégration feuille de route 0.7.0.0

Ce dossier contient les changements de code des trois premières étapes de la feuille de route dans un format découpé et facile à relire.

## Étape 1 - Démarrage

Fichier : `Etape1_Demarrage.patch`

SHA-256 : `eae7d07c8a06a3b0a0443a430ffa4e531c9be0c2b0fb5cef81daa65aee31ce9e`

Le patch ajoute la machine d'état de démarrage, `getStartupStep()`, `getStartupSnapshot()`, `validateStartupState()` et les gardes de cohérence avant validation du niveau de difficulté.

## Étape 2 - Interface de base

Fichiers :

- `Etape2_Interface.patch.part00`
- `Etape2_Interface.patch.part01`
- `Etape2_Interface.patch.part02`

Reconstruction Linux/macOS :

```bash
cat Etape2_Interface.patch.part00 Etape2_Interface.patch.part01 Etape2_Interface.patch.part02 > Etape2_Interface.patch
```

Sous PowerShell :

```powershell
Get-Content Etape2_Interface.patch.part00,Etape2_Interface.patch.part01,Etape2_Interface.patch.part02 -Raw | Set-Content Etape2_Interface.patch -NoNewline
```

SHA-256 attendu : `a12ef60b82c762f0a01e29c8c16718acc3e41fd9fe7a367a74798d1e97f2226e`

Cette étape ajoute la couche d'interface transversale, les six modules joueur, les redirections de navigation et l'utilisation du snapshot de Démarrage comme source de vérité.

## Étape 3 - Banque

Fichiers :

- `Etape3_Banque.patch.part00`
- `Etape3_Banque.patch.part01`
- `Etape3_Banque.patch.part02`

Reconstruction Linux/macOS :

```bash
cat Etape3_Banque.patch.part00 Etape3_Banque.patch.part01 Etape3_Banque.patch.part02 > Etape3_Banque.patch
```

Sous PowerShell :

```powershell
Get-Content Etape3_Banque.patch.part00,Etape3_Banque.patch.part01,Etape3_Banque.patch.part02 -Raw | Set-Content Etape3_Banque.patch -NoNewline
```

SHA-256 attendu : `2535972c462b82b4c816bde1597d18743cd84d8bdbef9fe74224c9466a2423a4`

Cette étape ajoute le snapshot Banque de la roadmap, la dette héritée séparée, les détails de prêts, l'historique filtrable, la prévision de trésorerie, l'analyse de financement et la checklist du module.

## Build joueur correspondante

Version interne : `0.7.0.0`

Nom du package : `FS25_AgriLifeManager.zip`

SHA-256 : `ee6dbd9f7b841f61738ac601204c70144f6769a637d521e126ecf8e785514939`

Vérification statique de la build : 91 XML, 79 Lua actifs, 146 callbacks, 210 contrôles, 27 langues et 4 831 clés l10n.

Les tests en jeu ne sont pas considérés comme terminés ou validés par cette synchronisation. Les patches documentent le code intégré à la build, pas une validation fonctionnelle définitive.
