# Sous-agents

Les agents (`agents/<nom>.md`) sont des relecteurs et auditeurs **en lecture seule**. Le skill les orchestre et les lance en parallèle ; un agent n'en lance jamais d'autres. Ils s'invoquent sous `max:<nom>`.

| Agent                   | Lancé par                          | Rôle                                                                  |
| :---------------------- | :--------------------------------- | :-------------------------------------------------------------------- |
| `correctness-reviewer`  | `/max:review`                      | Bugs, cause racine, cas limites, régressions.                         |
| `security-reviewer`     | `/max:review`                      | Validation des entrées, contrôle d'accès, injections, secrets.        |
| `standards-reviewer`    | `/max:review`                      | Standards, performance, couverture de tests.                          |
| `frontend-reviewer`     | `/max:review` (si la stack a un front) | Hydratation, réactivité, effets, accessibilité.                   |
| `dependencies-auditor`  | `/max:security`                    | Lockfiles, avis de sécurité, alertes Dependabot.                      |
| `docker-auditor`        | `/max:security`                    | Images de base, privilèges, secrets, ports.                           |
| `actions-auditor`       | `/max:security`                    | Workflows GitHub Actions (actions non épinglées, permissions, injection). |
| `codebase-surveyor`     | `/max:symfony`, `/max:nuxt`, `/max:react` | Explore un gros projet avant un changement.                    |

## Quand les lancer

`/max:review` relit seul un petit changement (environ 150 lignes sur 3 fichiers au plus) et délègue au-delà, ou dès que plusieurs préoccupations sont touchées. Il ne lance que les agents dont le périmètre est réellement touché.

## Anatomie

```yaml
---
name: correctness-reviewer
description: Relit … sous l'angle de la correction uniquement. Lecture seule. Lancé en parallèle par /max:review ; pas fait pour être appelé directement.
tools: Read, Grep, Glob, Bash
---
```

Un agent reçoit du skill le diff, l'intention (issue ou PR) et le chemin de la ressource de la stack. Il reste dans son couloir, ne modifie rien, ne committe pas, n'installe rien, et rend ses constats du plus grave au moins grave (`Bloquant`, `Majeur`, `Mineur`, `Détail`). Si un agent échoue, le skill le signale et couvre sa dimension lui-même.
