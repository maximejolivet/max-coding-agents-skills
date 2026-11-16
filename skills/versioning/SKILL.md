---
name: versioning
description: "Monte la version du plugin Max - lit la version actuelle, ajoute 0.0.1, l'aligne dans plugin.json, marketplace.json, le badge du README et CLAUDE.md, puis lance tests/check.sh. Ne vaut que dans le dépôt du plugin. À utiliser avant d'ouvrir une PR sur ce dépôt, ou quand Maxime demande de monter ou d'aligner la version du plugin, ou invoque /max:versioning."
---

# Version du plugin

## Préalables

1. Lancer `grep -q '"name": "max"' .claude-plugin/plugin.json`. S'il échoue, s'arrêter : ce skill ne vaut que pour le dépôt du plugin. Sur un dépôt client, la version relève de `/max:release`.
2. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
3. Lancer `grep -n '"version"' .claude-plugin/plugin.json .claude-plugin/marketplace.json` : ne jamais modifier une version sans l'avoir lue.

## Étapes

1. Relever ce qui a changé depuis la dernière version : `git log`, `git diff <défaut>`, `git status -sb`.
2. Annoncer l'incrément : ancienne version, nouvelle version, raison.
3. Modifier les quatre emplacements, et eux seuls :

   | Fichier | Champ |
   | :-- | :-- |
   | `.claude-plugin/plugin.json` | `version` |
   | `.claude-plugin/marketplace.json` | `version` du plugin `max` |
   | `README.md` | badge `version-X.Y.Z-lightgrey` |
   | `CLAUDE.md` | « Version courante » |

4. Mettre à jour `CHANGELOG.md` s'il existe (`Added`, `Changed`, `Fixed`, date `YYYY-MM-DD`).
5. Lancer `sh tests/check.sh`, puis relire le diff : quatre versions identiques, rien d'autre.

Règle du dépôt : chaque PR ajoute `0.0.1` au PATCH, documentation comprise. Sans incrément, Claude Code ne propose pas la mise à jour.

## Points d'arrêt

- MINOR ou MAJOR : seulement sur demande explicite. MINOR pour un ajout compatible, MAJOR pour une rupture (skill renommé ou supprimé).
- Deux PR ouvertes en même temps : la seconde se rebase et prend la version suivante.
- La version installée dépasse celle du dépôt (`~/.claude/plugins/installed_plugins.json`) : repartir au-dessus de la plus haute publiée.
- `check.sh` échoue : corriger avant de continuer.

## Ce qu'il ne fait pas

- Créer un tag ou une release : le marketplace lit la branche par défaut, le merge suffit.
- Créer `CHANGELOG.md`.
- Toucher la version d'une dépendance ou d'une stack.
