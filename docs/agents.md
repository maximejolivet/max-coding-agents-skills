# Agents

```bash
ls agents/ && grep -H '^tools:\|^model:' agents/*.md
```

Un agent est un fichier `agents/<nom>.md`, appelé `max:<nom>`. Il lit et rapporte ; le skill décide. Aucun agent n'écrit, et aucun n'en lance un autre.

## Qui lance quoi

| Agent | Lancé par | Outils | Modèle |
| :-- | :-- | :-- | :-- |
| `correctness-reviewer` | `/max:review` | Read, Grep, Glob, Bash | défaut |
| `security-reviewer` | `/max:review` | Read, Grep, Glob, Bash | défaut |
| `standards-reviewer` | `/max:review` | Read, Grep, Glob, Bash | défaut |
| `frontend-reviewer` | `/max:review`, si le diff touche du front | Read, Grep, Glob, Bash | défaut |
| `dependencies-auditor` | `/max:security` | Read, Grep, Glob, Bash, WebFetch | défaut |

| Agent | Lancé par | Outils | Modèle |
| :-- | :-- | :-- | :-- |
| `docker-auditor` | `/max:security` | Read, Grep, Glob, Bash | défaut |
| `actions-auditor` | `/max:security` ; lu par `/max:pr-review` | Read, Grep, Glob, Bash | défaut |
| `codebase-surveyor` | `/max:dev`, `/max:debug`, `/max:refactor`, `/max:perf`, `/max:explain` | Read, Grep, Glob, Bash | `sonnet` |
| `docs-updater` | Maxime, dans ce dépôt seulement | Read, Grep, Glob, Bash | `sonnet` |

`/max:symfony`, `/max:nuxt` et `/max:react` passent par `/max:dev`. `dependencies-auditor` est le seul à sortir du dépôt, pour lire les avis de sécurité.

## Deux usages d'un même fichier

- **Délégation.** Sur un gros diff ou plusieurs domaines, le skill lance les agents dans le même tour et fusionne leurs constats.
- **Passe unique.** Sur un petit changement, le skill lit la section `## Contrôles` de l'agent et l'applique lui-même.

La liste de contrôle n'existe donc qu'à un endroit : dans l'agent.

## Écrire un agent

Frontmatter vérifié dans la [documentation officielle](https://code.claude.com/docs/en/sub-agents.md) le 2026-11-16 : `name` et `description` sont requis, `tools` et `model` facultatifs. `check.sh` exige `tools` et refuse `Write`, `Edit`, `NotebookEdit`.

```yaml
---
name: correctness-reviewer
description: Relit un diff sous le seul angle de la correction - … Lecture seule. Lancé en parallèle par le skill review, jamais directement.
tools: Read, Grep, Glob, Bash
---
```

Plan du corps :

1. Une phrase d'ouverture : l'action, la lecture seule, ce qui appartient aux autres agents.
2. `## Entrée` : ce que le skill transmet. L'agent ne voit pas la conversation.
3. `## Étapes` : numérotées.
4. `## Contrôles` : la liste complète, en groupes nommés.
5. `## Sortie` : le format exact, l'échelle de gravité, la phrase à rendre quand il n'y a rien.
6. `## Limites`.

À savoir : un agent de plugin ignore `hooks`, `mcpServers`, `permissionMode` et `initialPrompt`. Sans `tools`, il hériterait de tous les outils, écriture comprise.
