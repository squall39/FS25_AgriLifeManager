# Feuille de route — Phase de test AgriLife Manager 0.9.2.0 TEST

> **Document dédié uniquement à la campagne de test.**
> Il ne remplace pas la feuille de route fonctionnelle du mod.
> L’objectif est de tester AgriLife Manager dans un ordre logique, en progressant de **Facile → Normal → Difficile**, sans mélanger les exigences propres à chaque niveau.

## Règles générales de campagne

- Utiliser la build de référence **0.9.2.0 TEST**.
- Commencer chaque difficulté sur une **nouvelle sauvegarde dédiée**.
- Utiliser d’abord une **map vanilla**, sans autre mod scripté non indispensable.
- Ne passer au niveau suivant que si les tests bloquants du niveau courant sont validés.
- Après chaque grand bloc : **sauvegarder → quitter complètement FS25 → relancer → contrôler l’état → lire `log.txt`**.
- Statuts autorisés : `À TESTER`, `EN TEST`, `OK`, `KO`, `À REFAIRE`, `NON APPLICABLE`.
- Une fonction codée n’est jamais considérée comme validée tant qu’elle n’a pas été confirmée en jeu.
- Toute anomalie doit être notée avec : niveau, scénario, résultat attendu, résultat observé, capture si utile et extrait du `log.txt`.

---

# PHASE 0 — Préparation commune

## T00 — Installation propre
- [ ] Retirer toute ancienne version de `FS25_AgriLifeManager`.
- [ ] Installer uniquement **0.9.2.0 TEST**.
- [ ] Vérifier que le mod est reconnu par FS25.
- [ ] Vérifier que le camion de service AgriLife n’apparaît plus dans le magasin.
- [ ] Vérifier que les conteneurs/cuves d’huile et lubrifiants sont toujours disponibles.
- [ ] Vérifier l’absence d’erreur Lua AgriLife au chargement.

**GO phase suivante :** le mod charge proprement et aucun contenu supprimé ne réapparaît.

## T01 — Références de test
Préparer trois sauvegardes distinctes :
- `AgriLife_TEST_FACILE`
- `AgriLife_TEST_NORMAL`
- `AgriLife_TEST_DIFFICILE`

Pour chaque sauvegarde, conserver :
- map utilisée ;
- version FS25 ;
- mods actifs ;
- `log.txt` de référence ;
- captures importantes.

---

# PHASE 1 — FACILE

## Objectif
Valider d’abord le fonctionnement général du mod avec le moins de contraintes possible.  
Le mode Facile sert de **smoke test fonctionnel complet** avant d’ajouter les obligations de Normal et Difficile.

## F01 — Création de carrière et onboarding
- [ ] Créer la sauvegarde `AgriLife_TEST_FACILE`.
- [ ] Choisir **Facile**.
- [ ] Terminer complètement la création/vêtements du personnage.
- [ ] Vérifier qu’aucune fenêtre AgriLife ne s’ouvre pendant les vêtements.
- [ ] Entrer réellement sur la map.
- [ ] Vérifier le déclenchement du tutoriel au bon moment.
- [ ] Parcourir les 13 sujets du tutoriel.
- [ ] Vérifier Précédent / Suivant / Terminer.
- [ ] Rouvrir le guide manuellement.
- [ ] Vérifier `Échap > Assistance` et la cohérence avec le tutoriel.

**Attendu Facile :**
- capital de départ : **200 000 €** ;
- banque/conseiller : **facultatifs** ;
- permis agricole : **facultatif** ;
- assurance : **non obligatoire** ;
- aucun verrou Difficile ne doit apparaître.

## F02 — Interface et HUD
- [ ] Ouvrir les six modules du tableau de bord.
- [ ] Vérifier navigation, boutons, textes et absence de chevauchement.
- [ ] Vérifier mini-PDA / couronne XP.
- [ ] Vérifier progression permis séparée de l’XP.
- [ ] Vérifier libellés d’activité.
- [ ] Tester au moins une sauvegarde/recharge avec l’interface déjà utilisée.

## F03 — Banque et finances
- [ ] Ouvrir la banque sans obligation préalable.
- [ ] Tester conseiller.
- [ ] Consulter une offre de crédit.
- [ ] Souscrire un crédit valide.
- [ ] Vérifier compte professionnel/personnel.
- [ ] Vérifier grand livre.
- [ ] Vérifier amortissement/bilan/CAF sur des mouvements connus.
- [ ] Vérifier fiscalité Facile.
- [ ] Sauvegarder/recharger.

## F04 — Permis et XP
- [ ] Vérifier qu’un véhicule reste utilisable sans permis obligatoire.
- [ ] Lancer volontairement le parcours permis.
- [ ] Vérifier qu’aucun XP carrière ne progresse pendant l’examen.
- [ ] Tester conduite/transport.
- [ ] Tester travail du sol.
- [ ] Tester moisson.
- [ ] Tester livraison.
- [ ] Vérifier seuil XP/niveau/étoile.
- [ ] Sauvegarder/recharger la progression.

> Le parcours complet 1 → 10 peut être terminé ici si l’objectif est de valider l’examen une première fois avant Normal/Difficile.

## F05 — Entreprise, salariés et réputation
- [ ] Recruter un salarié.
- [ ] Vérifier contrat et salaire.
- [ ] Créer un ordre de travail.
- [ ] Vérifier planning.
- [ ] Tester IA FS25.
- [ ] Vérifier XP salarié.
- [ ] Déclencher un incident ou événement de réputation.
- [ ] Vérifier historique et persistance.

## F06 — Administration
- [ ] Ouvrir le module Administration.
- [ ] Vérifier statut/licence d’exploitation.
- [ ] Vérifier documents et conformité.
- [ ] Déclencher au moins un contrôle possible.
- [ ] Vérifier avertissement/sanction si applicable.
- [ ] Vérifier journal/historique.
- [ ] Sauvegarder/recharger.

## F07 — Contrats et marchés
- [ ] Accepter un contrat commercial.
- [ ] Réussir un contrat.
- [ ] Faire échouer/expirer un second scénario.
- [ ] Vérifier réputation/notation acheteur.
- [ ] Vérifier marché mondial/local.
- [ ] Vérifier intrants.
- [ ] Vérifier énergie/carburant.
- [ ] Vérifier foncier.
- [ ] Vérifier location.
- [ ] Vérifier neuf/occasion.
- [ ] Vérifier productions/fillTypes détectés.

## F08 — Atelier 0.9.2.0 : socle
Tester au minimum quatre familles :
1. véhicule motorisé ;
2. remorque ;
3. outil ;
4. accessoire ou masse/poids.

Pour chacune :
- [ ] vérifier apparition dans le parc maintenable ;
- [ ] vérifier composants adaptés au type ;
- [ ] vérifier diagnostic ;
- [ ] vérifier historique technique ;
- [ ] vérifier sauvegarde/recharge.

## F09 — Pannes et immobilisation
- [ ] Produire une panne légère.
- [ ] Vérifier que le matériel reste déplaçable si prévu.
- [ ] Produire une panne immobilisante dépannable.
- [ ] Tester le kit terrain.
- [ ] Vérifier que le kit ne fait qu’une intervention autorisée/provisoire.
- [ ] Produire une casse lourde.
- [ ] Vérifier arrêt moteur.
- [ ] Vérifier **impossibilité réelle de redémarrer**.
- [ ] Vérifier qu’une casse lourde ne peut pas être réparée magiquement dans le champ.

## F10 — Dépannage, remorquage et transport
- [ ] Demander un dépannage.
- [ ] Choisir destination concessionnaire.
- [ ] Refaire avec destination atelier de l’exploitation.
- [ ] Vérifier coût.
- [ ] Vérifier délai.
- [ ] Vérifier état immobilisé pendant l’intervention.
- [ ] Vérifier arrivée/destination correcte.
- [ ] Tester aussi un outil/remorque non motorisé avec récupération/transport.

## F11 — Pièces, huiles et réparation personnelle
- [ ] Effectuer un diagnostic nécessitant des pièces.
- [ ] Commander les pièces.
- [ ] Vérifier délai de préparation.
- [ ] Retirer ou faire livrer la palette physique.
- [ ] Vérifier références/quantités.
- [ ] Vérifier entrée dans le stock atelier.
- [ ] Vérifier consommation des pièces.
- [ ] Vérifier huile/lubrifiant requis si applicable.
- [ ] Vérifier consommation réelle des fluides.
- [ ] Vérifier qu’aucune pièce n’est créée gratuitement.

## F12 — Réparation personnelle vs concessionnaire
Créer deux réparations comparables.

### Atelier personnel
- [ ] vérifier coût pièces ;
- [ ] vérifier absence de fausse facturation de main-d’œuvre du dirigeant ;
- [ ] vérifier temps d’immobilisation ;
- [ ] vérifier que le délai est **2× à 3×** celui du concessionnaire selon compétence/atelier.

### Concessionnaire
- [ ] vérifier coût supérieur par main-d’œuvre ;
- [ ] vérifier délai plus court ;
- [ ] demander un matériel de remplacement ;
- [ ] vérifier qu’il correspond au type de matériel immobilisé ;
- [ ] vérifier restitution automatique à la fin de la réparation ;
- [ ] vérifier proposition/location de secours si aucun prêt n’est disponible.

## F13 — Assurance Atelier
- [ ] panne soudaine couverte ;
- [ ] usure normale non couverte ;
- [ ] entretien négligé ;
- [ ] alerte critique ignorée ;
- [ ] accident ;
- [ ] franchise ;
- [ ] plafond ;
- [ ] assistance/remorquage ;
- [ ] réparation concessionnaire ;
- [ ] réparation maison ;
- [ ] vérifier qu’une réparation maison n’indemnise que les dépenses réellement engagées ;
- [ ] vérifier qu’aucun scénario ne permet de gagner de l’argent via l’assurance.

## F14 — Sauvegarde complète Facile
- [ ] Sauvegarder avec XP, crédit, salarié, contrat, panne/job Atelier et commande de pièces actifs.
- [ ] Quitter complètement FS25.
- [ ] Recharger.
- [ ] Vérifier tous les états.
- [ ] Contrôler `log.txt`.

### GATE FACILE
Passage à Normal uniquement si :
- [ ] aucun crash ;
- [ ] aucune erreur Lua bloquante ;
- [ ] onboarding et UI fonctionnels ;
- [ ] sauvegarde fiable ;
- [ ] Atelier 0.9.2.0 fonctionnel sur les quatre familles de matériel ;
- [ ] aucun exploit évident argent/XP/assurance.

---

# PHASE 2 — NORMAL

## Objectif
Rejouer le parcours avec les contraintes intermédiaires et surtout valider **banque obligatoire + permis provisoire**.

**Attendu Normal :**
- capital de départ : **100 000 €** ;
- banque/conseiller : **obligatoires** ;
- permis définitif : non obligatoire immédiatement ;
- permis provisoire : **3 mois de jeu** ;
- rappel : environ toutes les **6 heures de jeu** ;
- amende personnelle à échéance : **500 €** ;
- assurance : non obligatoire par règle globale.

## N01 — Démarrage Normal
- [ ] Nouvelle sauvegarde `AgriLife_TEST_NORMAL`.
- [ ] Vérifier capital.
- [ ] Vérifier obligation banque/conseiller.
- [ ] Vérifier qu’aucune ancienne règle “entreprise obligatoire” n’apparaît.
- [ ] Vérifier tutoriel adapté au mode.

## N02 — Banque obligatoire
- [ ] Refuser/retarder la banque si possible.
- [ ] Vérifier les fonctions réellement bloquées.
- [ ] Accepter la banque.
- [ ] Vérifier déblocage.
- [ ] Vérifier conseiller.
- [ ] Sauvegarder/recharger avant et après acceptation.

## N03 — Permis provisoire
- [ ] Vérifier activation du provisoire.
- [ ] Vérifier durée 3 mois.
- [ ] Vérifier rappels.
- [ ] Vérifier absence de progression XP pendant examen.
- [ ] Laisser expirer volontairement le provisoire sur une sauvegarde dédiée.
- [ ] Vérifier amende **500 € sur le compte personnel**.
- [ ] Vérifier qu’elle n’est appliquée qu’une fois.
- [ ] Vérifier que les rappels continuent jusqu’au permis définitif.
- [ ] Obtenir ensuite le permis définitif.
- [ ] Vérifier disparition de la logique provisoire.

## N04 — Économie et pénalités Normal
- [ ] Comparer prix/coûts au Facile.
- [ ] Vérifier fiscalité Normal.
- [ ] Vérifier maintenance plus exigeante que Facile.
- [ ] Vérifier pénalités de contrats.
- [ ] Vérifier conséquences financières sans valeurs Facile/Difficile mélangées.

## N05 — Atelier Normal
Refaire les scénarios critiques :
- [ ] panne légère ;
- [ ] dépannage terrain ;
- [ ] casse lourde ;
- [ ] verrou redémarrage ;
- [ ] remorquage atelier ;
- [ ] remorquage concessionnaire ;
- [ ] palette de pièces ;
- [ ] fluides ;
- [ ] réparation personnelle 2×–3× ;
- [ ] concessionnaire plus rapide ;
- [ ] prêt matériel ;
- [ ] location de secours ;
- [ ] assurance.

Vérifier en particulier que la compétence mécanique et le niveau d’atelier influencent correctement le délai personnel.

## N06 — Sauvegarde Normal
- [ ] Sauvegarder pendant permis provisoire.
- [ ] Recharger.
- [ ] Sauvegarder pendant réparation/remorquage.
- [ ] Recharger.
- [ ] Vérifier horloges/délais/états.
- [ ] Contrôler `log.txt`.

### GATE NORMAL
Passage à Difficile uniquement si :
- [ ] banque obligatoire correcte ;
- [ ] provisoire 3 mois correct ;
- [ ] rappel correct ;
- [ ] amende personnelle unique correcte ;
- [ ] aucun verrou persistant après permis définitif ;
- [ ] Atelier et assurance toujours cohérents ;
- [ ] sauvegarde/reload propres.

---

# PHASE 3 — DIFFICILE

## Objectif
Valider les vrais verrous et les conséquences maximales.

**Attendu Difficile :**
- capital de départ : **50 000 €** ;
- banque/conseiller : **obligatoires** ;
- permis agricole définitif : **obligatoire** ;
- conduite normale verrouillée avant obtention du permis ;
- matériel d’examen utilisable pour l’examen ;
- assurance : **obligatoire** ;
- coûts/entretien plus sévères ;
- pénalités examen/contrats renforcées.

## D01 — Démarrage et verrous
- [ ] Nouvelle sauvegarde `AgriLife_TEST_DIFFICILE`.
- [ ] Vérifier capital 50 000 €.
- [ ] Vérifier banque/conseiller obligatoires.
- [ ] Vérifier assurance obligatoire.
- [ ] Vérifier permis obligatoire.
- [ ] Vérifier qu’un véhicule normal ne peut pas être utilisé avant permis.
- [ ] Vérifier que le véhicule/matériel d’examen reste utilisable dans le contexte d’examen.
- [ ] Sauvegarder/recharger avec les verrous encore actifs.

## D02 — Permis complet 1 → 10
Pour chaque étape :
- [ ] objectif correct ;
- [ ] aucune validation prématurée ;
- [ ] validation unique ;
- [ ] retour visuel ;
- [ ] XP carrière bloqué pendant examen ;
- [ ] sauvegarde/reload après étapes 3, 6, 9 et 10.

À l’étape 10 :
- [ ] démarrage/arrêt conforme ;
- [ ] confirmation finale claire ;
- [ ] permis définitif enregistré ;
- [ ] véhicule normal déverrouillé ;
- [ ] aucun nouvel examen demandé après réussite.

## D03 — Assurance obligatoire
- [ ] Vérifier impossibilité de rester non assuré lorsque le mode l’interdit.
- [ ] Tester formule/couverture.
- [ ] Tester franchise.
- [ ] Tester panne non couverte.
- [ ] Tester panne couverte.
- [ ] Tester remorquage avec/sans garantie adaptée.
- [ ] Tester accident responsable/non responsable si possible.

## D04 — Atelier Difficile
- [ ] Vérifier maintenance plus sévère.
- [ ] Vérifier conséquences d’entretien négligé.
- [ ] Vérifier qualification mécanique requise.
- [ ] Tenter une réparation lourde sans qualification.
- [ ] Vérifier blocage ou forte pénalité prévue.
- [ ] Vérifier temps personnel 2×–3× concessionnaire.
- [ ] Vérifier intérêt réel du prêt concessionnaire.
- [ ] Vérifier qu’une réparation personnelle longue peut obliger à louer un matériel de remplacement pour poursuivre l’activité.
- [ ] Vérifier coûts et trésorerie.

## D05 — Contrats, administration et sanctions
- [ ] Faire échouer un contrat.
- [ ] Vérifier pénalité Difficile.
- [ ] Tester contrôle administratif.
- [ ] Tester récidive.
- [ ] Vérifier sanction.
- [ ] Vérifier influence réputation/banque/assurance lorsque prévue.
- [ ] Vérifier impossibilité de contourner les sanctions par save/reload.

## D06 — Stress financier
Créer un scénario volontairement tendu :
- [ ] crédit ;
- [ ] réparation lourde ;
- [ ] matériel immobilisé ;
- [ ] location de secours ;
- [ ] franchise d’assurance ;
- [ ] salarié/paie ;
- [ ] contrat en cours.

Vérifier :
- [ ] grand livre ;
- [ ] trésorerie ;
- [ ] échéances ;
- [ ] absence de double débit ;
- [ ] absence de remboursement supérieur aux dépenses ;
- [ ] conséquences cohérentes.

## D07 — Sauvegarde Difficile
- [ ] Sauvegarder avec plusieurs contraintes actives.
- [ ] Quitter complètement FS25.
- [ ] Recharger.
- [ ] Vérifier permis, assurance, banque, panne, réparation, prêt/location, contrats et administration.
- [ ] Contrôler `log.txt`.

### GATE DIFFICILE
Validation du niveau uniquement si :
- [ ] tous les verrous attendus fonctionnent ;
- [ ] aucune restriction Facile/Normal n’est appliquée à tort ;
- [ ] aucune obligation Difficile ne peut être contournée ;
- [ ] assurance et Atelier restent cohérents ;
- [ ] sauvegarde/reload fiables ;
- [ ] aucun exploit économique critique.

---

# PHASE 4 — Comparaison directe des trois difficultés

Cette phase vérifie qu’une même action donne bien des conséquences différentes selon le niveau.

## C01 — Tableau comparatif
Rejouer un petit scénario identique dans les trois sauvegardes :
- crédit ;
- contrat ;
- entretien ;
- panne ;
- réparation personnelle ;
- réparation concessionnaire ;
- sinistre ;
- sauvegarde/reload.

Comparer :
- [ ] capital ;
- [ ] obligations ;
- [ ] fiscalité ;
- [ ] coûts ;
- [ ] délais ;
- [ ] pénalités ;
- [ ] maintenance ;
- [ ] permis ;
- [ ] assurance ;
- [ ] restrictions.

## C02 — Absence de contamination entre sauvegardes
- [ ] Passer de Facile à Normal.
- [ ] Passer de Normal à Difficile.
- [ ] Revenir à Facile.
- [ ] Vérifier que chaque carrière conserve son propre mode et ses propres données.
- [ ] Vérifier qu’aucune banque/permis/XP/Atelier n’est partagé entre sauvegardes.

---

# PHASE 5 — Compatibilité après validation des trois niveaux

Seulement après validation de Facile, Normal et Difficile sur map vanilla :

- [ ] modmap standard ;
- [ ] modmap multifruits ;
- [ ] productions supplémentaires ;
- [ ] Precision Farming ;
- [ ] Soil Fertilizer ;
- [ ] Courseplay ;
- [ ] AutoDrive ;
- [ ] MudSystem ;
- [ ] Advanced Damage System ;
- [ ] autres intégrations optionnelles déclarées.

Tester d’abord chaque intégration séparément, puis quelques combinaisons raisonnables.

---

# PHASE 6 — UI, langues et stabilité finale

## U01 — Résolutions
- [ ] 1920×1080 ;
- [ ] résolution supérieure disponible ;
- [ ] au moins deux valeurs de UI scale.

## U02 — Langues
- [ ] français : campagne principale ;
- [ ] anglais ;
- [ ] allemand ou espagnol ;
- [ ] vérifier absence de clé brute `$l10n_...`.

## U03 — Logs
Après chaque difficulté et en fin de campagne :
- [ ] rechercher `Error` ;
- [ ] rechercher `Warning` ;
- [ ] rechercher `stack traceback` ;
- [ ] rechercher `nil value` ;
- [ ] rechercher `attempt to` ;
- [ ] distinguer les warnings FS25 externes des anomalies AgriLife.

---

# PHASE 7 — Décision finale 0.9.2.0 TEST

La build peut passer de **TEST** à candidate suivante uniquement si :

- [ ] Facile = GO ;
- [ ] Normal = GO ;
- [ ] Difficile = GO ;
- [ ] comparaison trois niveaux = OK ;
- [ ] sauvegardes/reloads = OK ;
- [ ] Atelier 8.1 = OK ;
- [ ] assurance = OK ;
- [ ] permis 1 → 10 = OK ;
- [ ] XP/HUD = OK ;
- [ ] banque/comptabilité = OK ;
- [ ] entreprise = OK ;
- [ ] administration = OK ;
- [ ] contrats/marchés = OK ;
- [ ] aucune corruption de sauvegarde ;
- [ ] aucun crash reproductible ;
- [ ] aucun double paiement/XP/indemnisation ;
- [ ] aucun verrou de progression cassé ;
- [ ] logs de référence propres côté AgriLife Manager.

---

# Ordre recommandé des sessions

1. **Session 1 — Préparation + Facile F01 à F04**
2. **Session 2 — Facile F05 à F14**
3. **Session 3 — Normal N01 à N03**
4. **Session 4 — Normal N04 à N06**
5. **Session 5 — Difficile D01 + permis complet D02**
6. **Session 6 — Difficile D03 à D07**
7. **Session 7 — Comparaison des trois difficultés**
8. **Session 8 — Compatibilités/maps**
9. **Session 9 — UI/langues/logs et décision finale**

Cette organisation permet d’arrêter immédiatement la campagne lorsqu’un défaut bloquant est découvert, de le corriger, puis de reprendre à partir du dernier **GATE** validé au lieu de recommencer toute la certification.
