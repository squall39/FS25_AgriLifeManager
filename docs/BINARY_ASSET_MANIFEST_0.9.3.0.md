# Manifeste des assets binaires - AgriLife Manager 0.9.3.0 TEST

Build jouable de référence : `FS25_AgriLifeManager_0.9.3.0_TEST_final.zip`  
SHA-256 du ZIP : `303a1f11111e8e8d40be65f5e93081dec0686e89e2c69d05ba2f10521202a7fa`

## Inventaire

La build de référence contient **177 assets binaires** pour une taille cumulée d’environ **54 048 322 octets**. Il s’agit principalement de DDS/PNG/I3D et données associées nécessaires à l’interface, aux placeables et aux ressources du mod.

Les sources texte et XML sont maintenues séparément sur GitHub. Le connecteur utilisé lors de la maintenance du 12 août 2026 ne permet pas de transférer directement en masse l’arborescence binaire locale complète ; le ZIP validé reste donc la référence octet-par-octet de ces assets tant qu’un miroir binaire dédié n’a pas été réalisé.

## Assets à conserver

Sont notamment considérés utiles à la build 0.9.3.0 :

- `icon.dds` ;
- `gui/agrilife_menu_tab.dds` ;
- icônes Banque et Aide ;
- textures et atlas UI du mini-PDA ;
- assets du `FieldServiceKit` ;
- `placeables/OilTank.i3d` et ses ressources ;
- assets du point de service huile/lubrifiants ;
- assets de palettes/pièces utilisés par l’Atelier.

## Assets à ne pas réintroduire

Le camion de service joueur a été supprimé. Les éléments qui lui étaient propres ne doivent pas revenir sur `main` ni dans une prochaine build :

- dossier `vehicles/serviceTruck/` ;
- `vehicles/ServiceTruck6.lua` ;
- dialogues ServiceTruck ;
- icônes `service_truck.*` ;
- branding GMC uniquement utilisé par ce camion.

Les huiles, lubrifiants, cuves et points de service ne font **pas** partie de cette suppression : ils restent nécessaires au système Atelier.

## Règle de nettoyage

Un asset binaire ne doit être supprimé que s’il est non référencé, non nécessaire à la build, non utilisé par un outil/audit et sans valeur historique documentaire. Un fichier temporaire de transfert, un doublon exact ou un asset spécifique à une fonctionnalité définitivement retirée doit être supprimé.
