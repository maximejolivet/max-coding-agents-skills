# Skills et outils

Un skill (`skills/<nom>/SKILL.md`) ne déclare pas de champ `tools` : il utilise les outils de la session Claude Code. Ce tableau résume ce que chaque skill mobilise d'après son `SKILL.md` : les commandes qu'il lance, les sous-agents qu'il orchestre et le recours à `stacks/`. Les sous-agents et leurs outils sont dans [agents-tools.md](agents-tools.md).

| Skill | Rôle | Commandes | Sous-agents | `stacks/` |
| :--- | :--- | :--- | :--- | :---: |
| `/max:commit` | Rédige un message de commit sémantique. | `git` | – | – |
| `/max:switch` | Change de branche sans perdre de travail, nettoie les branches mergées. | `git` | – | – |
| `/max:versioning` | Incrémente et aligne la version du plugin. | `git`, `sh tests/check.sh` | – | – |
| `/max:pull-request` | Branche, commit ciblé, push, PR en Draft. | `git`, `gh` | – | – |
| `/max:pr-review` | Relit la PR de quelqu'un d'autre et prépare la review. | `gh`, `jq`, `make`, `docker compose` | – | oui |
| `/max:review` | Relit un diff avant le merge, verdict classé par gravité. | `git`, `gh`, `make`, `docker compose` | `correctness-reviewer`, `security-reviewer`, `standards-reviewer`, `frontend-reviewer` | oui |
| `/max:security` | Audite dépendances, Docker et workflows Actions. | `composer`, `npm`/`yarn`/`pnpm`, `trivy`, `make`, `docker` | `dependencies-auditor`, `docker-auditor`, `actions-auditor` | oui |
| `/max:test` | Écrit, lance et diagnostique les tests. | `make`, `docker compose`, `composer` | – | oui |
| `/max:docker` | Dockerfile, Compose, Makefile et CI. | `docker`, `docker compose`, `make` | – | oui |
| `/max:kubernetes` | Manifestes, Kustomize, Helm, déploiement Actions. | `kubectl get`/`diff`/`--dry-run=server` (lecture seule), `helm lint`/`template`/`diff` | – | oui |
| `/max:symfony` | Développement Symfony, puis renvoi vers `/max:review`. | `composer`, `make`, `docker compose` | `codebase-surveyor` | oui |
| `/max:nuxt` | Développement Nuxt, puis renvoi vers `/max:review`. | `npm`/`yarn`/`pnpm` | `codebase-surveyor` | oui |
| `/max:react` | Développement React, puis renvoi vers `/max:review`. | selon le projet | `codebase-surveyor` | oui |
| `/max:refactor` | Refactoring et migration par lots, vérifiés et annulables. | linter, types, build, tests via le runner du projet | `codebase-surveyor` (cartographie, lecture seule) | oui |
| `/max:debug` | Débogage par la cause racine : repro, isolation, bisect, test de non-régression, correctif minimal. | `git bisect`, débogueur, runner de tests du projet | `codebase-surveyor` (lecture seule) | oui |
| `/max:agent-workflow` | Conçoit un workflow agentique (découpage, mécanisme, boucle de vérification, garde-fous, contexte). | – | – | – |

## À retenir

- Les skills génériques (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) détectent la stack puis chargent `stacks/<techno>/INDEX.md` ; les commandes réellement lancées dépendent donc du projet.
- Les skills de développement (`symfony`, `nuxt`, `react`) renvoient vers `/max:review`, qui prépare `/max:pull-request`.
- Les sous-agents ne sont lancés que par un skill, en parallèle ; un agent n'en lance jamais d'autres.
- La colonne « Commandes » est un relevé des `SKILL.md`, à relire si un skill change. Les écritures (`git push`, `gh pr create`, `helm upgrade`, `docker system prune`…) ne se font que sur demande ou après accord.
