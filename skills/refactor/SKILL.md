---
name: refactor
description: Mène un refactoring ou une migration à grande échelle sans changer le comportement - filet de sécurité de tests d'abord, découpage en lots indépendants et annulables, vérification après chaque lot, sous-agents en parallèle pour l'exploration seulement, un commit par lot. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur veut renommer, déplacer, restructurer, migrer vers une nouvelle API, version ou bibliothèque, supprimer du code mort ou appliquer un changement répétitif sur beaucoup de fichiers, ou invoque /max:refactor.
---

# Refactoring et migration d'envergure

Modifier la structure du code **sans toucher à son comportement observable**, en petits lots vérifiables et annulables un à un. Mêler restructuration et changement de comportement rend le diff illisible : les deux se traitent séparément.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack en une ligne, puis lire `stacks/<stack>/INDEX.md` pour la nature **dev** (qui inclut `core`) : idiomes de la techno et règles de la version visée. Sans ressource, le dire et suivre les conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## Cadrer

1. **Objectif** : ce qui change et pourquoi, en une phrase (renommage, extraction, montée de version, remplacement de bibliothèque).
2. **Périmètre** : dossiers et fichiers touchés, ce qui reste intact. Mesurer l'ampleur (`grep -rn`, `git grep -c`) au lieu de l'estimer.
3. **Comportement à préserver** : API publique, formats de données, effets de bord. Les tests doivent continuer à le prouver.
4. **Critère de fin** : un état vérifiable (« plus aucune occurrence de `X` », « la suite passe sur la nouvelle version »).

## Filet de sécurité

- Lancer la suite : elle doit être **verte avant** toute modification. Sinon, noter l'état initial pour ne pas imputer ces échecs au refactoring.
- Zone non couverte : écrire d'abord des **tests de caractérisation** (ils figent le comportement actuel, même imparfait) avec `/max:test` et les voir passer avant de commencer.
- Aucun test possible : le dire, prendre des lots plus petits et décrire la vérification manuelle.

## Découper en lots

- Des lots **indépendants**, de taille voisine, terminés et vérifiables isolément (un module, une couche, un type de changement).
- Ordre : d'abord les lots peu risqués qui apportent le plus de preuves, puis les parties centrales. Écrire le plan en cases à cocher (dans la réponse, ou dans un fichier si le chantier est long) pour pouvoir reprendre.
- Les changements mécaniques (renommage, déplacement) passent par l'outil du langage ou de l'IDE, ou par un script, plutôt que par des éditions manuelles une à une.
- Proposer le plan et **attendre l'accord** avant d'exécuter, sauf si la demande est déjà précise.

## Exécuter un lot

1. Appliquer le changement du lot, et rien d'autre.
2. Vérifier : linter, types, build et tests concernés via le runner du projet, en rapportant ce qui a réellement tourné.
3. Échec : lire l'erreur, corriger la cause, deux ou trois essais au plus ; au-delà, annuler le lot et remonter le blocage.
4. Un **commit par lot** au format `max:commit` (`refactor(<scope>): ♻️ …`), uniquement si l'utilisateur le demande.

Sur un gros chantier, des sous-agents en lecture seule (par exemple `max:codebase-surveyor`) peuvent **cartographier** les usages en parallèle. Les écritures restent dans la session principale, un lot après l'autre, pour éviter les conflits.

## Clôture

- Relancer toute la suite, le linter et le build ; vérifier le critère de fin (chercher les restes de l'ancien code).
- Passer `/max:review` sur l'ensemble du diff, puis `/max:pull-request`. Une PR gigantesque se relit mal : proposer de la scinder par lot quand c'est possible.

## Forme de la réponse

1. Objectif, périmètre et critère de fin.
2. Plan en lots, avec le risque de chacun.
3. Pour chaque lot exécuté : ce qui a changé, la vérification réelle (chiffres), le commit.
4. Ce qui reste, les écarts de comportement éventuels et les points non vérifiés.

## Limites

- Pas de changement de comportement en parallèle : un bug découvert en route est signalé ou traité dans un commit à part, jamais glissé dans le refactoring.
- Un test ne se supprime, ne s'ignore ni ne s'affaiblit pour qu'un lot passe.
- Aucune dépendance installée ni montée de version sans accord ; pas d'édition manuelle des fichiers générés ou des lockfiles.
- Aucun `git push`, merge ou `git reset --hard` sans accord explicite ; travailler sur une branche, jamais sur `main`.
- La relecture relève de `/max:review`, les tests de `/max:test`, la conception d'un workflow multi-agents de `/max:agent-workflow`.
