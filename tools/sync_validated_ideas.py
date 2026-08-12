from pathlib import Path

ROOT = Path.cwd()
roadmap = ROOT / 'ROADMAP.md'
registry_file = ROOT / 'docs' / 'IDEA_REGISTRY.md'
if not roadmap.exists() or not registry_file.exists():
    raise SystemExit('ROADMAP.md or docs/IDEA_REGISTRY.md missing')

text = roadmap.read_text(encoding='utf-8')
registry = registry_file.read_text(encoding='utf-8').rstrip() + '\n'

maintenance = '> **Règle de maintenance de la feuille de route :** ce fichier est le registre maître additif du projet. Une mise à jour peut modifier l’état d’un point, préciser son avancement ou ajouter une idée validée, mais ne doit jamais supprimer, condenser ou reformuler une idée au point d’en perdre le contenu.\n'
sync_rule = '> **Règle de synchronisation conversation / projet :** dès qu’une idée AgriLife est explicitement validée, elle doit être enregistrée de façon additive dans cette feuille de route et son registre maître. Si elle concerne le joueur, le tutoriel de départ et `Échap > Assistance` sont mis à jour dans la même passe. GitHub et la build de référence doivent ensuite être synchronisés avant de considérer la décision comme archivée. Une idée validée peut être documentée avant son intégration technique, mais son statut doit alors rester `À intégrer` ou `Partiellement intégrée` et ne jamais être présenté comme terminé.'
if sync_rule not in text:
    if maintenance not in text:
        raise SystemExit('Roadmap maintenance anchor missing')
    text = text.replace(maintenance, maintenance + '>\n' + sync_rule + '\n', 1)

blocks = [
('## Pièces détachées et qualités de remplacement\n', '### Évolution validée - commande physique et réparation à l’exploitation', '''## Pièces détachées et qualités de remplacement\n\n### Évolution validée - commande physique et réparation à l’exploitation\n\n- [ ] Transformer la palette générique actuelle en **véritable palette de pièces commandées** : le diagnostic/devis détermine les références et quantités nécessaires, le concessionnaire prépare la commande, puis le joueur la retire ou la fait livrer physiquement.\n- [ ] Les pièces livrées alimentent un **stock atelier réel** et sont consommées par les réparations ; aucune réparation maison ne doit créer gratuitement les pièces nécessaires.\n- [ ] La réparation à l’exploitation doit coûter moins cher principalement grâce à l’économie de main-d’œuvre, tout en exigeant atelier adapté, niveau de qualification, pièces disponibles et temps d’immobilisation.\n- [ ] Les interventions lourdes ou réglementaires peuvent rester réservées au concessionnaire selon le composant, la garantie, l’assurance et la difficulté.\n'''),
("## Immobilisation, dépannage et continuité d'activité\n", '### Évolution validée - panne légère, dépannage et remorquage', '''## Immobilisation, dépannage et continuité d'activité\n\n### Évolution validée - panne légère, dépannage et remorquage\n\n- [ ] Distinguer trois niveaux opérationnels : **panne légère** (véhicule encore déplaçable), **panne immobilisante dépannable sur place** et **casse lourde** avec redémarrage interdit.\n- [ ] Une panne immobilisante doit proposer un **service de dépannage/remorquage** géré par le concessionnaire ou un prestataire AgriLife, avec choix de destination vers le concessionnaire ou l’atelier de l’exploitation lorsqu’il est compatible.\n- [ ] Le remorquage possède un coût et un délai d’intervention cohérents avec la difficulté, la distance/zone de service et la couverture d’assistance.\n- [ ] Le **camion atelier achetable par le joueur doit être retiré** : il n’apporte pas assez de gameplay par rapport au service de dépannage externe.\n- [ ] Conserver le **kit de service terrain** uniquement pour un diagnostic et des dépannages d’urgence limités ; il ne doit plus réparer magiquement une casse moteur ou une transmission lourde au milieu d’un champ.\n'''),
('## Garanties, assurances et sinistres\n', '### Évolution validée - cohérence panne, réparation et assurance', '''## Garanties, assurances et sinistres\n\n### Évolution validée - cohérence panne, réparation et assurance\n\n- [ ] L’assurance ne rembourse **jamais automatiquement toute panne**. La décision doit distinguer accident, panne mécanique soudaine, usure normale, entretien négligé, défaut connu ignoré et événement couvert par une garantie spécifique.\n- [ ] La prise en charge doit consulter le **contrat, la franchise, la responsabilité, l’historique d’entretien, les alertes ignorées et le diagnostic Atelier** avant de calculer remorquage, pièces, main-d’œuvre admissible et reste à charge.\n- [ ] Une garantie d’assistance peut couvrir tout ou partie du dépannage/remorquage indépendamment de la prise en charge de la réparation elle-même.\n- [ ] En réparation maison, l’assurance peut indemniser les **dépenses admissibles réellement engagées**, notamment les pièces couvertes, mais ne verse pas une main-d’œuvre fictive et ne doit jamais permettre de réaliser un bénéfice.\n- [ ] Comparer clairement dans l’interface : réparation concessionnaire, réparation à l’exploitation, délai, pièces, main-d’œuvre, franchise, montant assurance et reste à charge.\n''')]
for anchor, marker, block in blocks:
    if marker not in text:
        if anchor not in text:
            raise SystemExit('Roadmap anchor missing: ' + anchor.strip())
        text = text.replace(anchor, block, 1)

registry_heading = '# Registre maître des idées validées et état d’intégration'
footer = '\n---\n\n**Auteur : Chez_Squall**'
registry_start = text.find(registry_heading)
if registry_start >= 0:
    footer_start = text.find(footer, registry_start)
    if footer_start < 0:
        raise SystemExit('Roadmap registry footer anchor missing')
    text = text[:registry_start] + registry + text[footer_start:]
else:
    if footer not in text:
        raise SystemExit('Roadmap footer anchor missing')
    text = text.replace(footer, '\n---\n\n' + registry + '\n---\n\n**Auteur : Chez_Squall**', 1)

roadmap.write_text(text, encoding='utf-8')
(ROOT / 'docs').mkdir(exist_ok=True)
(ROOT / 'docs' / 'ROADMAP.md').write_text(text, encoding='utf-8')

# User-facing and maintenance docs.
p = ROOT / 'docs' / 'USER_GUIDE.md'
if p.exists():
    t = p.read_text(encoding='utf-8')
    old = "## Atelier et assurance\n\nUn accident peut produire un constat, une décision de responsabilité et un devis Atelier. La prise en charge dépend ensuite de la responsabilité retenue. Le bonus-malus est modifié seulement lorsque la responsabilité le justifie.\n\nLes délais de pièces, immobilisations et réparations continuent d'exister même lorsqu'une assurance prend une partie des coûts en charge.\n"
    new = "## Atelier, dépannage, pièces et assurance\n\nUne panne légère peut encore permettre de rejoindre l’atelier ou le concessionnaire. Une panne immobilisante peut nécessiter un dépannage ou un remorquage. Le flux validé prévoit le choix entre concessionnaire et atelier de l’exploitation lorsqu’il est suffisamment équipé.\n\nLa réparation maison repose sur des pièces réellement commandées au concessionnaire, retirées ou livrées sur palettes puis consommées dans le stock atelier. Elle réduit surtout le coût de main-d’œuvre, mais exige compétences, équipement, pièces et temps. Les casses lourdes peuvent rester réservées au professionnel. Le camion atelier achetable par le joueur doit être retiré ; le kit terrain reste limité aux urgences.\n\nL’assurance ne paie pas automatiquement toute panne. Elle tient compte de la cause, du contrat, de la franchise, de la responsabilité, de l’entretien et des alertes ignorées. Le remorquage peut être couvert séparément. Pour une réparation maison, seules les dépenses admissibles réellement engagées peuvent être indemnisées : l’assurance ne doit jamais créer de bénéfice.\n"
    if old in t:
        t = t.replace(old, new, 1)
    elif '## Atelier, dépannage, pièces et assurance' not in t:
        t += '\n\n' + new
    p.write_text(t, encoding='utf-8')

for rel, title, body in [
('docs/IMPLEMENTATION_MATRIX.md', '## Synchronisation des idées validées', "Le registre maître ajouté à `ROADMAP.md` distingue l’état du code, la présence dans le tutoriel/Assistance et la certification FS25. Le flux panne immobilisante -> dépannage/remorquage -> concessionnaire ou atelier -> pièces physiques -> réparation -> assurance est actuellement **partiellement intégré** ; le retrait du camion joueur et la finalisation de la réparation maison restent à intégrer/certifier."),
('docs/SOURCE_SYNC_MANIFEST.md', '## Règle de synchronisation conversation -> projet', "Une décision explicitement validée doit être enregistrée dans la roadmap et son registre maître. Si elle change le comportement joueur, tutoriel et Assistance sont mis à jour dans toutes les langues distribuées. GitHub et la build de référence doivent ensuite refléter la même décision. Une idée non codée reste `À intégrer` ou `Partiellement intégrée`."),
('docs/L10N_AUDIT.md', '## Synchronisation Atelier / Assurance', "Les sujets 10 et 11 du tutoriel ont été révisés dans les **27 langues** pour refléter le dépannage/remorquage, la réparation maison avec pièces physiques et la logique d’assurance. `Échap > Assistance` réutilise exactement ces mêmes clés.")]:
    p = ROOT / rel
    if p.exists():
        t = p.read_text(encoding='utf-8')
        if title not in t:
            t += f'\n{title}\n\n{body}\n'
        p.write_text(t, encoding='utf-8')

p = ROOT / 'CHANGELOG.md'
if p.exists():
    t = p.read_text(encoding='utf-8')
    title = '## 0.9.1.0 TEST - Synchronisation des idées validées'
    if title not in t:
        block = title + "\n\n- Registre maître additif des idées et de leur état.\n- Règle permanente conversation -> roadmap -> tutoriel/Assistance -> GitHub -> build.\n- Flux Atelier validé : remorquage, palettes de pièces, réparation maison et assurance cohérente.\n- Camion de service joueur marqué `À intégrer` pour suppression ; kit terrain limité aux urgences.\n\n"
        marker = "Le détail historique des anciennes builds reste disponible dans l'historique Git. Ce fichier conserve les principaux jalons de la branche actuelle.\n\n"
        t = t.replace(marker, marker + block, 1) if marker in t else block + t
        p.write_text(t, encoding='utf-8')

print('VALIDATED IDEAS SYNC: OK')
