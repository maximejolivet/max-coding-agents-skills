# Outils des skills

Un skill n'a pas de champ `tools` : il emploie ceux de la session Claude Code. Ce relevé, tiré des `SKILL.md`, indique ce que chacun exécute, quels sous-agents il mobilise et s'il lit `stacks/`. Les outils des agents sont dans [agents-tools.md](agents-tools.md).

## Git et GitHub

| Skill               | Commandes                          | Sous-agents | `stacks/` |
| :------------------ | :--------------------------------- | :---------- | :-------: |
| `/max:switch`       | `git`, `gh`                        | –           | non |
| `/max:commit`       | `git`                              | –           | non |
| `/max:versioning`   | `git`, `sh tests/check.sh`         | –           | non |
| `/max:pull-request` | `git`, `gh`                        | –           | non |
| `/max:rebase`       | `git`                              | –           | non |
| `/max:release`      | `git`, `gh`                        | –           | oui |
| `/max:hotfix`       | `git`, `gh`, runner de tests       | –           | oui |
| `/max:issue`        | `gh issue list`, `gh issue create` | –           | oui |

## Relecture et audit

| Skill            | Commandes                                                   | Sous-agents | `stacks/` |
| :--------------- | :---------------------------------------------------------- | :---------- | :-------: |
| `/max:review`    | `git`, `gh`, `make`, `docker compose`                       | `correctness-reviewer`, `security-reviewer`, `standards-reviewer`, `frontend-reviewer` | oui |
| `/max:pr-review` | `gh`, `jq`, `make`, `docker compose`                        | –           | oui |
| `/max:security`  | `composer`, `npm`/`yarn`/`pnpm`, `trivy`, `make`, `docker`  | `dependencies-auditor`, `docker-auditor`, `actions-auditor` | oui |
| `/max:test`      | `make`, `docker compose`, `composer`                        | –           | oui |
| `/max:a11y`      | `axe`, `pa11y`, Lighthouse s'ils sont installés             | –           | oui |
| `/max:perf`      | profileurs, Lighthouse, `EXPLAIN` selon la stack            | `codebase-surveyor` | oui |

## Développement et diagnostic

| Skill             | Commandes                                         | Sous-agents | `stacks/` |
| :---------------- | :------------------------------------------------ | :---------- | :-------: |
| `/max:symfony`    | `composer`, `make`, `docker compose`              | `codebase-surveyor` | oui |
| `/max:nuxt`       | `npm`/`yarn`/`pnpm`                               | `codebase-surveyor` | oui |
| `/max:react`      | selon le projet                                   | `codebase-surveyor` | oui |
| `/max:refactor`   | linter, types, build et tests du projet           | `codebase-surveyor` | oui |
| `/max:debug`      | `git bisect`, débogueur, runner de tests          | `codebase-surveyor` | oui |
| `/max:migrate-db` | outil de migration du projet                      | –           | oui |
| `/max:explain`    | `git`, `ls`                                       | `codebase-surveyor` | oui |

## Infrastructure et méthode

| Skill                 | Commandes                                                              | Sous-agents | `stacks/` |
| :-------------------- | :--------------------------------------------------------------------- | :---------- | :-------: |
| `/max:docker`         | `docker`, `docker compose`, `make`                                     | –           | oui |
| `/max:kubernetes`     | `kubectl get`/`diff`/`--dry-run=server` (lecture), `helm lint`/`template`/`diff` | – | oui |
| `/max:ci`             | `gh run`, `actionlint` si présent                                      | –           | oui |
| `/max:agent-workflow` | –                                                                      | –           | non |

## Points d'attention

- Les skills transverses (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) lisent la stack avant d'agir : les commandes réellement lancées dépendent donc du projet.
- Les skills `symfony`, `nuxt` et `react` finissent en renvoyant vers `/max:review`, lequel prépare `/max:pull-request`.
- Seul un skill démarre des sous-agents, et il les démarre ensemble.
- Les actions qui écrivent à l'extérieur (`git push`, `gh pr create`, `helm upgrade`, `docker system prune`…) attendent ton accord.
- Ce tableau recopie les `SKILL.md` à un instant donné : à vérifier quand un skill évolue.
