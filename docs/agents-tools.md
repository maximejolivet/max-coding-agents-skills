# Agents et outils

Les outils de chaque agent sont déclarés dans le champ `tools` du frontmatter de `agents/<nom>.md`. Pour le rôle de chaque agent et le skill qui le lance, voir [agents.md](agents.md). Pour aller plus loin sur les agents, les skills et les outils, voir la [sélection de dépôts sur l'IA](https://github.com/maximejolivet/maximejolivet/blob/master/IA.md).

| Agent | Rôle | Lancé par | Outils | Modèle |
| :--- | :--- | :--- | :--- | :--- |
| `actions-auditor` | Audite les workflows GitHub Actions : actions non épinglées, permissions du token, déclencheurs dangereux, injection de script, secrets. | `/max:security` | Read, Grep, Glob, Bash | (défaut) |
| `agile-planner` | Choisit Scrum ou Kanban d'après les user stories et remplit la page de gestion de projet dans Notion. | sur demande | Read, Grep, Glob, Bash + 7 outils Notion (ci-dessous) | `sonnet` |
| `codebase-surveyor` | Explore le code existant avant un changement : structure, éléments réutilisables, idiomes locaux, risques. | `/max:symfony`, `/max:nuxt`, `/max:react`, `/max:refactor`, `/max:debug` | Read, Grep, Glob, Bash | `sonnet` |
| `correctness-reviewer` | Relit un diff sous l'angle de la correction : cause racine, cas limites, régressions. | `/max:review` | Read, Grep, Glob, Bash | (défaut) |
| `dependencies-auditor` | Cherche les vulnérabilités connues : lockfiles Composer et JS, avis de la stack, alertes Dependabot. | `/max:security` | Read, Grep, Glob, Bash, WebFetch | (défaut) |
| `docker-auditor` | Audite Docker et Compose : images de base, privilèges, socket, secrets, ports, scans d'image. | `/max:security` | Read, Grep, Glob, Bash | (défaut) |
| `docs-updater` | Compare les `.md` au code réel et rend les corrections exactes à appliquer, sans rien modifier. | sur demande | Read, Grep, Glob, Bash | `sonnet` |
| `frontend-reviewer` | Relit le code front : hydratation, réactivité, effets, accessibilité, taille du paquet, SEO. | `/max:review` (si front) | Read, Grep, Glob, Bash | (défaut) |
| `security-reviewer` | Relit un diff sous l'angle applicatif : validation des entrées, accès, injections, XSS/CSRF, secrets. | `/max:review` | Read, Grep, Glob, Bash | (défaut) |
| `standards-reviewer` | Lance les linters et relit standards, performance (N+1) et couverture de tests. | `/max:review` | Read, Grep, Glob, Bash | (défaut) |

## Outils Notion de `agile-planner`

- `mcp__claude_ai_Notion__notion-search`
- `mcp__claude_ai_Notion__notion-fetch`
- `mcp__claude_ai_Notion__notion-query-data-sources`
- `mcp__claude_ai_Notion__notion-create-pages`
- `mcp__claude_ai_Notion__notion-create-database`
- `mcp__claude_ai_Notion__notion-update-page`
- `mcp__claude_ai_Notion__notion-get-self`

## À retenir

- Aucun agent n'a `Edit`, `Write` ni `Agent` : ils sont en lecture seule et n'en lancent jamais d'autres.
- `Bash` est restreint par consigne dans le prompt de chaque agent : sondes en lecture seule (`git`, `grep`, `ls`), linters et audits (`composer audit`, `npm audit`, `trivy`) sans correctif automatique ; jamais de modification, de commit ni de push. `standards-reviewer` lance les linters du projet, `dependencies-auditor` les audits de lockfiles.
- `agile-planner` est le seul à écrire, et uniquement dans Notion, jamais dans le dépôt.
- `dependencies-auditor` est le seul à avoir `WebFetch`, pour consulter les avis de sécurité.
