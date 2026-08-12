# Étape 9 - Finalisation

Version d'écriture : **0.9.0.0 TEST**

L'étape 9 ferme les infrastructures transversales du projet sans déclarer la certification FS25 terminée.

## Écrit et intégré

- matrice de compatibilités optionnelles avec fallback autonome ;
- audit dynamique du contenu de la map et des fillTypes sans liste fixe ;
- schéma de sauvegarde 4 et migration 3 vers 4 ;
- identité de carrière persistante et suivi de récupération backup ;
- historique de migrations ;
- audit de couverture de persistance des modules ;
- contrôle d'isolation multi-fermes en mémoire ;
- squelette réseau serveur autoritaire, données séparées par ferme et miroir client ;
- publication multijoueur bloquée tant que la campagne réseau n'est pas certifiée ;
- tutoriel paginé rebasé sur la source courante avec Prev, Next, fermeture et fallback ;
- audit l10n : parité, valeurs vides, placeholders et clés statiquement utilisées ;
- glossaire de référence ;
- audit de publication et des composants tiers ;
- packaging TEST/PUBLIC reproductible ;
- documentation utilisateur et checklist de publication.

## Certification encore nécessaire

Les scénarios qui exigent le vrai moteur FS25 restent à réaliser en jeu : multi, résolutions d'écran, plusieurs maps réelles, crash/reprise réelle, campagne complète de chaque difficulté et validation finale avant publication.
