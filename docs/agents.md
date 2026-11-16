# Sous-agents

Un sous-agent est un relecteur ou un auditeur **sans droit d'écriture**, défini dans `agents/<nom>.md` et appelé sous `max:<nom>`. Le skill joue le chef d'orchestre : il les démarre ensemble, récupère leurs constats et les assemble. Un agent n'en démarre jamais un autre.

## Qui fait quoi

| Agent                  | Appelé par | Angle de lecture |
| :--------------------- | :--------- | :--------------- |
| `correctness-reviewer` | `/max:review` | Le code fait-il ce que demande l'issue ? Cause racine, cas limites, régressions. |
| `security-reviewer`    | `/max:review` | Entrées non validées, droits d'accès, injections, XSS/CSRF, secrets. |
| `standards-reviewer`   | `/max:review` | Linters, idiomes locaux, requêtes N+1, tests manquants. |
| `frontend-reviewer`    | `/max:review`, si le diff touche du front | Hydratation, réactivité, effets, accessibilité, poids du bundle, SEO. |
| `dependencies-auditor` | `/max:security` | Lockfiles, avis de sécurité, alertes Dependabot. |
| `docker-auditor`       | `/max:security` | Images de base, privilèges, socket Docker, secrets, ports, scans. |
| `actions-auditor`      | `/max:security` | Actions non épinglées, permissions du token, injection de script. |
| `codebase-surveyor`    | `/max:symfony`, `/max:nuxt`, `/max:react`, `/max:refactor`, `/max:debug`, `/max:perf`, `/max:explain` | Cartographie un gros projet avant d'y toucher. |
| `agile-planner`        | à ta demande | Choisit Scrum ou Kanban d'après les stories et alimente Notion. |
| `docs-updater`         | à ta demande | Liste les écarts entre les `.md` et le code réel. |

## Délégation

Un petit changement (environ 150 lignes sur 3 fichiers au plus) est relu directement par `/max:review`. Au-delà, ou dès que plusieurs sujets se croisent, il confie chaque angle à l'agent adapté et n'appelle que ceux dont le périmètre est touché.

## Format d'un agent

```yaml
---
name: correctness-reviewer
description: Relit … sous l'angle de la correction uniquement. Lecture seule. Lancé en parallèle par /max:review ; pas fait pour être appelé directement.
tools: Read, Grep, Glob, Bash
---
```

Le skill transmet à l'agent le diff, l'intention (issue ou PR) et le chemin du fichier de la stack. En retour, l'agent :

- reste sur son seul angle ;
- ne modifie rien, ne commite pas, n'installe rien ;
- classe ses constats du plus sévère au plus léger : `Bloquant`, `Majeur`, `Mineur`, `Détail`.

Si un agent plante, le skill l'indique et traite lui-même la dimension manquante.

Les outils précis de chaque agent sont détaillés dans [agents-tools.md](agents-tools.md).
