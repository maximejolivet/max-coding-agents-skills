# Outils des agents

Chaque agent déclare ses outils dans la ligne `tools` du frontmatter de `agents/<nom>.md`. Ce tableau en donne le relevé ; le rôle de chacun est expliqué dans [agents.md](agents.md).

| Agent                  | Outils déclarés                         | Modèle   | Spécificité |
| :--------------------- | :-------------------------------------- | :------- | :---------- |
| `actions-auditor`      | Read, Grep, Glob, Bash                  | défaut   | Examine `.github/workflows`. |
| `agile-planner`        | Read, Grep, Glob, Bash + 7 outils Notion | `sonnet` | Seul agent qui écrit, et uniquement dans Notion. |
| `codebase-surveyor`    | Read, Grep, Glob, Bash                  | `sonnet` | Résume la structure d'un gros projet. |
| `correctness-reviewer` | Read, Grep, Glob, Bash                  | défaut   | Relit la logique du diff. |
| `dependencies-auditor` | Read, Grep, Glob, Bash, WebFetch        | défaut   | Seul à pouvoir consulter le web, pour les avis de sécurité. |
| `docker-auditor`       | Read, Grep, Glob, Bash                  | défaut   | Lance un scanner d'image s'il est présent. |
| `docs-updater`         | Read, Grep, Glob, Bash                  | `sonnet` | Rend des corrections, n'en applique aucune. |
| `frontend-reviewer`    | Read, Grep, Glob, Bash                  | défaut   | Intervient si le diff touche du front. |
| `security-reviewer`    | Read, Grep, Glob, Bash                  | défaut   | Sécurité applicative du diff. |
| `standards-reviewer`   | Read, Grep, Glob, Bash                  | défaut   | Exécute les linters du projet. |

## Outils Notion d'`agile-planner`

- `mcp__claude_ai_Notion__notion-search`
- `mcp__claude_ai_Notion__notion-fetch`
- `mcp__claude_ai_Notion__notion-query-data-sources`
- `mcp__claude_ai_Notion__notion-create-pages`
- `mcp__claude_ai_Notion__notion-create-database`
- `mcp__claude_ai_Notion__notion-update-page`
- `mcp__claude_ai_Notion__notion-get-self`

## Ce qu'il faut retenir

- Aucun agent ne reçoit `Edit`, `Write` ni `Agent` : ils ne modifient pas les fichiers et ne délèguent pas.
- `Bash` est encadré par le prompt de chaque agent : sondes en lecture (`git`, `grep`, `ls`), linters et audits (`composer audit`, `npm audit`, `trivy`) sans correction automatique, jamais de commit ni de push.
- Le droit de sortie de `dependencies-auditor` (`WebFetch`) et celui d'écriture d'`agile-planner` (Notion) sont les deux seules exceptions au socle commun.
- Pour explorer d'autres agents, skills et outils, voir la [sélection de dépôts IA](depots-tools.md).
