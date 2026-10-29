---
name: refactor
description: Mène un refactoring ou une migration à grande échelle sans changer le comportement - filet de sécurité de tests d'abord, découpage en lots indépendants et annulables, vérification après chaque lot, sous-agents en parallèle pour l'exploration seulement, un commit par lot. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur veut renommer, déplacer, restructurer, migrer vers une nouvelle API, version ou bibliothèque, supprimer du code mort ou appliquer un changement répétitif sur beaucoup de fichiers, ou invoque /max:refactor.
---

# Refactoring et migration à grande échelle

Changer la structure du code **sans changer son comportement observable**, par petits lots que l'on peut vérifier et annuler un par un. Un refactoring qui mélange restructuration et changement de comportement ne se relit pas : séparer les deux.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack en une ligne, puis charger `stacks/<stack>/INDEX.md` pour la nature **dev** (qui tire `core`) afin de respecter les idiomes de la techno et les règles de la version cible. Sans ressource, le dire et s'en tenir aux conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## Cadrer

1. **Objectif** - ce qui change et pourquoi, en une phrase (renommage, extraction, montée de version, remplacement d'une bibliothèque).
2. **Périmètre** - dossiers et fichiers concernés, ce qui reste intact. Mesurer l'ampleur (`grep -rn`, `git grep -c`) plutôt que l'estimer.
3. **Comportement à préserver** - API publique, formats de données, effets de bord. C'est ce que les tests doivent continuer à prouver.
4. **Critère de fin** - un état vérifiable (« plus aucune occurrence de `X` », « la suite passe sur la nouvelle version »).

## Filet de sécurité d'abord

- Lancer la suite : elle doit être **verte avant** de toucher quoi que ce soit. Sinon, noter l'état de départ et ne pas mettre les échecs sur le dos du refactoring.
- Si la zone n'est pas couverte, écrire d'abord des **tests de caractérisation** (ils figent le comportement actuel, même imparfait) via `/max:test`, et les voir passer avant de commencer.
- Sans aucun test possible, le dire et choisir des lots plus petits avec vérification manuelle décrite.

## Découper en lots

- Des lots **indépendants**, de taille comparable, chacun terminé et vérifiable seul (un module, une couche, un type de changement).
- Ordre : d'abord les lots à faible risque et haute valeur de preuve, les parties centrales ensuite. Écrire le plan avec des cases à cocher (dans la réponse, ou dans un fichier si la tâche est longue) pour pouvoir reprendre.
- Les changements purement mécaniques (renommage, déplacement) passent par l'outil du langage ou de l'IDE, ou un script, plutôt que par des éditions à la main une à une.
- Proposer le plan et **attendre l'accord** avant d'exécuter, sauf si la demande est déjà précise.

## Exécuter un lot

1. Faire le changement du lot, rien d'autre.
2. Vérifier : linter, types, build et tests concernés, via le runner du projet. Rapporter ce qui a réellement tourné.
3. En cas d'échec : lire l'erreur, corriger la cause, 2 ou 3 essais au plus ; au-delà, revenir en arrière sur le lot et remonter le blocage.
4. Un **commit par lot** au format `max:commit` (`refactor(<scope>): ♻️ …`) ; ne committer que sur demande de l'utilisateur.

Sur un gros chantier, des sous-agents en lecture seule (ex. `max:codebase-surveyor`) peuvent **cartographier** les usages en parallèle. Les écritures restent faites par la session principale, un lot à la fois, pour éviter les conflits.

## Fin de chantier

- Relancer toute la suite, le linter et le build ; vérifier le critère de fin (recherche des restes de l'ancien code).
- Lancer `/max:review` sur le diff complet, puis `/max:pull-request`. Une PR énorme se relit mal : proposer de la scinder par lot quand c'est possible.

## Format de la réponse

1. L'objectif, le périmètre et le critère de fin.
2. Le plan en lots, avec le risque de chacun.
3. Pour chaque lot exécuté : ce qui a changé, la vérification réelle (nombres), le commit.
4. Ce qui reste, les écarts de comportement éventuels et les points non vérifiés.

## Hors périmètre

- Ne pas changer le comportement en même temps : un bug trouvé en route est signalé ou traité dans un commit séparé, jamais glissé dans le refactoring.
- Ne jamais supprimer, ignorer ou affaiblir un test pour que le lot passe.
- Ne pas installer de dépendance ni migrer de version sans accord ; ne pas toucher aux fichiers générés ou aux lockfiles à la main.
- Pas de `git push`, de merge ni de `git reset --hard` sans accord explicite ; travailler sur une branche, jamais sur `main`.
- La relecture relève de `/max:review`, les tests de `/max:test`, la conception d'un workflow multi-agents de `/max:agent-workflow`.
