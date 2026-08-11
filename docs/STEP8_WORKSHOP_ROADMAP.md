# Étape 8 - Atelier, Concessionnaire & Gestion technique du parc

Cette spécification détaille le périmètre validé de l'étape 8. Elle complète la feuille de route maître sans supprimer aucun ancien point. Lors du packaging de la prochaine build, le même contenu doit être fusionné dans `ROADMAP.md` et dans `docs/ROADMAP.md` du mod.

L'étape 8 devient un écosystème technique complet qui couvre **véhicules, machines, outils et accessoires**. AgriLife gère le garage, le concessionnaire, les diagnostics, les pièces, les stocks, les délais, l'immobilisation, les coûts, la main-d'oeuvre, les garanties, l'historique et les conséquences économiques. Les systèmes mécaniques tiers compatibles peuvent fournir des données de panne ou de physique, mais AgriLife ne doit pas dupliquer leur moteur interne.

## Principes fondamentaux

- [x] Base de l'Atelier.
- [x] État du matériel et opérations de maintenance.
- [ ] Étendre le suivi technique à **tout le parc** : tracteurs, véhicules, moissonneuses, automoteurs, remorques, outils attelés, accessoires, chargeurs, outils PTO, matériels hydrauliques et autres équipements détectables.
- [ ] Aucun équipement compatible ne doit être traité comme un simple objet sans historique technique lorsqu'AgriLife peut l'identifier de manière sûre.
- [ ] Une panne doit toujours avoir une **conséquence fonctionnelle logique**, proportionnée au composant touché et à sa gravité.
- [ ] Ne jamais réduire une panne à un simple pourcentage rouge sans effet réel.
- [ ] Prévoir un fallback AgriLife autonome lorsque les mods mécaniques tiers sont absents ou qu'une donnée externe n'est plus exploitable.

## Architecture mécanique par composants

- [ ] Décomposer les véhicules et matériels compatibles en systèmes cohérents : moteur, lubrification, carburant, admission, refroidissement, électrique, transmission, embrayage, ponts, prise de force, hydraulique, freinage, direction, suspension, châssis, pneus/roues, éclairage, vitrage et autres organes pertinents.
- [ ] Décomposer aussi les outils et accessoires selon leur vraie logique : cardans, boîtiers, chaînes, courroies, roulements, essieux, freins, vérins, flexibles, pompes, moteurs hydrauliques, disques, dents, couteaux, rouleaux, systèmes de dosage, électronique et organes spécifiques au type d'outil.
- [ ] Adapter automatiquement la liste des composants au type réel de matériel. Un semoir, une benne et un tracteur ne doivent pas présenter les mêmes organes.
- [ ] Chaque composant possède au minimum un état, une usure, une criticité, un historique et une conséquence de défaillance.
- [ ] Conserver un état global lisible sans transformer l'interface en mur de jauges.

## Usure, stress et vieillissement réel

- [ ] Usure, entretien et immobilisation plus poussés.
- [ ] Faire progresser l'usure avec le temps réel d'utilisation, les heures, la distance, la charge, la vitesse, le régime, la température, les chocs, le patinage, les conditions de terrain et l'entretien.
- [ ] Différencier vieillissement normal, mauvais usage, surcharge, choc, défaut d'entretien et incident externe.
- [ ] Le pourcentage de dégâts doit évoluer progressivement et servir de conséquence d'un état mécanique réel, pas remplacer la logique des composants.
- [ ] Une pièce usée peut dégrader progressivement rendement, puissance, précision, consommation, température, vibrations, bruit, freinage ou fiabilité avant la panne complète lorsque cela a du sens.
- [ ] Les outils et accessoires doivent eux aussi subir une usure cohérente avec leur travail réel.

## Pannes fonctionnelles et chaîne de conséquences

- [ ] Construire une table de conséquences mécaniques par composant et par gravité.
- [ ] Une panne moteur critique peut couper le moteur et immobiliser le véhicule.
- [ ] Une fuite d'huile peut provoquer baisse de niveau/pression, échauffement, perte de fiabilité puis casse moteur si le joueur insiste.
- [ ] Une fuite de carburant peut provoquer surconsommation, perte d'alimentation, arrêt moteur et risque d'immobilisation selon gravité.
- [ ] Un cardan ou un organe de transmission cassé doit couper la transmission de l'effort concerné et empêcher le travail ou le déplacement lorsque cette transmission est nécessaire.
- [ ] Une panne hydraulique peut réduire puis supprimer les fonctions hydrauliques concernées sans forcément arrêter le moteur.
- [ ] Un ressort ou élément de suspension cassé peut dégrader stabilité, charge admissible, confort et sécurité sans immobiliser automatiquement le véhicule si la panne ne le justifie pas.
- [ ] Une crevaison ou un pneu gravement endommagé doit affecter tenue de route, vitesse, traction et possibilité de continuer selon gravité.
- [ ] Un pare-brise cassé, un phare défectueux ou un défaut secondaire doit avoir des conséquences adaptées sans provoquer artificiellement une panne moteur.
- [ ] Les pannes critiques peuvent interdire le démarrage, arrêter un équipement, couper une fonction précise ou imposer une immobilisation technique.
- [ ] Le joueur doit comprendre **pourquoi** la machine fonctionne moins bien, s'arrête ou devient interdite d'utilisation.

## Diagnostic et devis

- [ ] Ajouter diagnostic visuel, diagnostic atelier et diagnostic concessionnaire avec niveaux de précision différents.
- [ ] Permettre des symptômes avant diagnostic complet : fuite, bruit, vibration, fumée, température, perte de puissance, pression faible, défaut électrique ou autre indice crédible.
- [ ] Le diagnostic doit identifier les composants suspects, confirmer les pièces nécessaires et estimer temps de travail, coût et immobilisation.
- [ ] Prévoir devis détaillé : pièces, main-d'oeuvre, consommables, transport, urgence, taxes/frais applicables et délai estimé.
- [ ] Un diagnostic approfondi peut détecter des défauts cachés sur un matériel d'occasion.

## Pièces détachées et qualités de remplacement

- [ ] Créer un catalogue fictif cohérent de pièces par famille de composants sans dépendre de références constructeurs réelles.
- [ ] Prévoir plusieurs qualités lorsque pertinent : **origine/OEM, adaptable, reconditionnée et occasion**.
- [ ] Différencier prix, fiabilité attendue, garantie, état initial et durée de vie potentielle selon la qualité choisie.
- [ ] Une pièce d'occasion possède son propre état et peut être moins chère mais moins durable.
- [ ] Une pièce reconditionnée possède une qualité, une garantie et une durée de vie propres.
- [ ] Les pièces montées deviennent partie intégrante de l'historique du véhicule ou de l'outil.

## Marché dynamique des pièces atelier/concessionnaire

- [ ] **Brancher le marché des pièces directement sur le moteur économique dynamique de l'étape 7.**
- [ ] Ne pas créer un second moteur de marché spécifique à l'Atelier.
- [ ] Faire varier prix, stock, rareté et disponibilité des pièces selon demande, saison, événements économiques, catégorie, ancienneté du matériel et tensions d'approvisionnement.
- [ ] Les pièces origine, adaptables, reconditionnées et d'occasion possèdent des marchés distincts mais reliés.
- [ ] Prévoir pénuries, ruptures temporaires, réapprovisionnement et variations crédibles de disponibilité.
- [ ] Prévoir livraison standard, livraison prioritaire et express avec coût et délai différents.
- [ ] Une pièce indisponible doit réellement retarder la réparation si aucune alternative compatible n'est choisie.
- [ ] Le délai de commande et de livraison doit utiliser le temps de jeu et persister après sauvegarde/rechargement.
- [ ] Le marché dynamique des pièces doit influencer devis, coûts de maintenance, rentabilité, assurance et valeur économique du parc.

## Concessionnaire et relation SAV

- [ ] Transformer le concessionnaire en véritable partenaire technique : diagnostic, devis, commande de pièces, entretien, réparation, garantie, campagne de rappel, reprise et estimation.
- [ ] Faire concorder le concessionnaire avec le marché dynamique du neuf et de l'occasion écrit à l'étape 7.
- [ ] Conserver une relation concessionnaire pouvant influencer tarifs de main-d'oeuvre, remises, priorité de stock, délais, véhicule/matériel de remplacement et qualité de service.
- [ ] Prévoir réparation chez le concessionnaire lorsque l'atelier de l'exploitation ne possède pas la compétence, l'outillage ou l'autorisation nécessaire.
- [ ] Les grosses réparations peuvent immobiliser le matériel plusieurs heures ou plusieurs jours de jeu.

## Atelier interne de l'exploitation

- [ ] Permettre à l'exploitation d'effectuer elle-même certaines réparations si elle possède atelier, outillage, pièces et compétence suffisants.
- [ ] Relier les travaux atelier aux salariés et compétences mécaniques du module Entreprise.
- [ ] Une réparation interne doit immobiliser réellement le salarié et le matériel pendant le temps prévu.
- [ ] Faire évoluer les réparations accessibles selon compétence : entretien courant, pneus/batterie, hydraulique, électrique, moteur, transmission et autres niveaux cohérents.
- [ ] Une réparation improvisée ou réalisée avec compétence insuffisante ne doit pas être équivalente à une réparation professionnelle parfaite.

## Entretien périodique obligatoire

- [ ] Mettre en place une **révision obligatoire tous les ans** pour les véhicules et équipements concernés.
- [ ] La révision annuelle vérifie les opérations d'entretien applicables : huile, filtres, fluides, freins, pneus, hydraulique, sécurité, graissage, réglages et autres points pertinents.
- [ ] Adapter la révision au type de matériel : un outil sans moteur ne reçoit pas une vidange moteur fictive.
- [ ] Générer échéance, rappel, ordre de travail, coût, pièces/consommables nécessaires et historique de révision.
- [ ] Le retard de révision augmente le risque mécanique et peut affecter garantie, assurance, valeur de revente ou conformité selon difficulté.

## Contrôle technique obligatoire

- [ ] Mettre en place un **contrôle technique obligatoire tous les 2 ans** pour les véhicules et matériels auxquels il est cohérent de l'appliquer.
- [ ] Étendre les contrôles de sécurité aux remorques, outils et accessoires lorsque leur nature le justifie : freinage, éclairage, attelage, essieux, pneus, protections, cardans, fuites ou autres éléments de sécurité.
- [ ] Le contrôle produit un résultat détaillé : conforme, défaut mineur, défaut majeur, défaut critique.
- [ ] Prévoir contre-visite après réparation des défauts qui l'exigent.
- [ ] Un défaut critique peut provoquer une immobilisation immédiate jusqu'à réparation et contre-visite.
- [ ] Un défaut mineur comme un éclairage secondaire ne doit pas immobiliser arbitrairement un tracteur si la réglementation AgriLife ne le justifie pas.
- [ ] Relier contrôle technique, révision et conformité au module Administration pour échéances, sanctions et interdictions d'utilisation éventuelles.
- [ ] Conserver dates, kilométrage/heures, résultat, défauts et contre-visites dans le dossier de vie du matériel.

## Immobilisation, dépannage et continuité d'activité

- [ ] Une panne ou un contrôle critique peut immobiliser réellement un véhicule, un outil ou un accessoire.
- [ ] Empêcher les ordres de travail AgriLife d'affecter un matériel techniquement indisponible.
- [ ] Prévoir dépannage sur place lorsque la panne est compatible, sinon remorquage/transport atelier lorsque techniquement possible.
- [ ] Permettre au joueur de choisir entre attendre la pièce, payer l'express, louer une machine, utiliser un autre matériel ou faire réparer au concessionnaire.
- [ ] Relier les décisions d'immobilisation aux locations et au marché de l'étape 7.

## Garanties, assurances et sinistres

- [ ] Interaction avec assurances et trésorerie.
- [ ] Gérer garanties constructeur, garanties pièces et garanties de réparation avec durée et exclusions.
- [ ] Faire dépendre une prise en garantie de l'entretien, du type de panne, de l'historique et des conditions applicables.
- [ ] Relier accident, casse, panne couverte, franchise et indemnisation au module Administration/Assurance sans dupliquer son moteur.
- [ ] Une négligence grave ou un entretien obligatoire non réalisé peut réduire ou annuler certaines prises en charge lorsque cela est prévu.

## Historique technique, économique et valeur de revente

- [ ] Coûts de maintenance et réparations liés à l'historique.
- [ ] Historique économique complet du matériel : achat, usage, entretien, sinistres, réparation et valeur résiduelle.
- [ ] Créer un **dossier de vie/carnet d'entretien permanent** pour chaque véhicule, outil et accessoire suivi.
- [ ] Historiser achats, heures/km, révisions, diagnostics, pannes, pièces changées, réparations, contrôles techniques, accidents, garanties et immobilisations.
- [ ] Relier la valeur du matériel au marché mondial du neuf et de l'occasion.
- [ ] Faire influencer la valeur de revente par état réel, qualité des réparations, historique d'entretien, pannes graves, contrôle technique, nombre de propriétaires si disponible et situation du marché.
- [ ] Permettre une inspection avant achat d'occasion avec niveau de diagnostic et risque de défaut caché cohérent.

## Difficulté

- [ ] Faire varier coûts, tolérances et conséquences d'entretien selon la difficulté.
- [ ] Facile conserve les mêmes grands systèmes mais avec pannes moins sévères, délais plus tolérants, coûts réduits et accompagnement renforcé.
- [ ] Normal utilise les règles de référence Atelier/Concessionnaire.
- [ ] Difficile renforce coût de négligence, conséquences des pannes, exigences de conformité, délais économiques et impact financier sans créer de panne artificielle.
- [ ] La difficulté ne doit jamais changer la logique physique d'un composant : elle module fréquence, tolérance, coûts et conséquences de gestion.

## Compatibilité MudSystem et système mécanique réaliste

- [ ] Intégration optionnelle forte avec **MudSystem** : exploiter proprement les informations accessibles concernant terrain, patinage, pneus, pression, crevaisons et contraintes associées sans copier ni remplacer son moteur.
- [ ] Intégration optionnelle forte avec le **système mécanique réaliste ciblé / Advanced Damage System ou projet équivalent lié à SquallQT**, après identification exacte de l'API et des hooks disponibles.
- [ ] Lorsque le système mécanique tiers est présent, lui laisser l'autorité sur ses données mécaniques et utiliser AgriLife pour garage, pièces, délais, salariés, facturation, garantie, immobilisation, historique et valeur économique.
- [ ] Lorsque MudSystem est présent, éviter les doubles calculs de pneus/crevaisons et convertir ses événements exploitables en conséquences atelier.
- [ ] Avec les deux mods présents, rechercher une fusion fonctionnelle maximale sans modifier leurs fichiers et sans dépendance dure.
- [ ] Sans l'un ou l'autre, conserver un système Atelier AgriLife autonome et cohérent.
- [ ] Toute incompatibilité future doit désactiver uniquement le pont concerné, jamais casser la sauvegarde ou l'Atelier.

## Chaîne technique de référence

**acheter -> utiliser -> user/stresser -> détecter un symptôme -> diagnostiquer -> commander les pièces -> attendre/louer/dépanner -> réparer -> réviser/contrôler -> garantir/assurer -> historiser -> revendre**
