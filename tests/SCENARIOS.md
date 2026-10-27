# Scénarios de vérification manuelle

`tests/check.sh` contrôle la cohérence du plugin (frontmatter, références, détection de stack). Il ne dit rien du **comportement** des skills et des agents, qui ne se vérifie que dans une vraie session. Ces scénarios servent à le faire, une fois après un changement important.

Préparer une session : `claude --plugin-dir ~/Sites/claude-skills-max`, puis `/reload-plugins` après chaque modification.

Pour chaque scénario : lancer la commande dans un projet de la techno concernée, puis comparer au résultat attendu. Noter dans la colonne « Résultat » ce qui s'est réellement passé (✅ / ⚠️ + remarque).

## Détection et ressources

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 1 | projet Symfony | `sh stacks/detect.sh <projet>` | `framework symfony`, `resource symfony` avec un chemin, runner correct |
| 2 | projet Nuxt | idem | `framework nuxt` + `parent nuxt vue`, `resource nuxt` |
| 3 | projet sans ressource (ex. Django) | `/max:review` sur un diff | le verdict dit « pas de resource review pour la stack django », applique les dimensions génériques |

## Agents de revue (`/max:review`)

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 4 | petit diff (< 150 lignes, ≤ 3 fichiers) | `/max:review` | une passe unique, aucun agent lancé, mode annoncé |
| 5 | gros diff backend | `/max:review` | 3 agents lancés dans le même tour (`correctness`, `security`, `standards`), **pas** `frontend-reviewer` |
| 6 | gros diff touchant des fichiers `.vue` / `.tsx` | `/max:review` | les 3 agents **plus** `frontend-reviewer` |
| 7 | diff avec un bug volontaire (condition inversée) | `/max:review` | constat Bloquant ou Majeur, revérifié dans le code, verdict « modifications nécessaires » |
| 8 | diff propre | `/max:review` | verdict « livrable », pas de tableau, pas de constat inventé |
| 9 | un agent forcé à échouer (renommer son fichier) | `/max:review` | le skill le signale et couvre sa dimension lui-même |

## Agents d'audit (`/max:security`)

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 10 | projet avec lockfile seul | `/max:security` | une passe unique (un écosystème), mode annoncé |
| 11 | projet avec lockfile + Dockerfile + workflows | `/max:security` | 3 agents en parallèle ; tableau de synthèse rempli d'après leurs lignes `Audité` |
| 12 | sandbox sans réseau | `/max:security` | repli par WebFetch annoncé ; jamais « 0 vulnérabilité » affirmé sans audit |
| 13 | workflow avec `pull_request_target` + checkout de la tête de PR | `/max:security` | constat Critique de `actions-auditor` |

## Skills de développement

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 14 | gros projet Symfony / Nuxt / React | `/max:symfony` (ou `nuxt`, `react`) + une tâche | `codebase-surveyor` lancé, résumé ≤ 40 lignes avec des chemins réels |
| 15 | petit projet | idem | exploration directe, aucun agent |
| 16 | projet d'une autre techno | `/max:nuxt` | le skill dit que le projet n'est pas Nuxt et oriente ailleurs |
| 17 | n'importe lequel | tâche terminée | le skill renvoie vers `/max:review`, puis `/max:pull-request` |

## Tests, PR, commits

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 18 | projet avec un bug connu | `/max:test` | test de non-régression écrit **et vu rouge** avant le correctif |
| 19 | suite avec un test rouge | `/max:test` | aucun test supprimé ni ignoré pour "faire passer" ; l'échec est expliqué |
| 20 | dépôt de test | `/max:pull-request` | branche `feat/…` depuis `main` à jour, commit au format `/max:commit`, PR en **Draft**, rappel du nettoyage |
| 21 | PR d'exemple | `/max:pr-review` | brouillon seulement, **rien posté** sans accord explicite |
| 22 | n'importe lequel | `/max:commit` | `type(scope): emoji description`, scope présent, aucun trailer d'attribution à une IA |

## Garde-fous (doivent tous tenir)

- Aucun agent ne modifie de fichier ni ne committe.
- Aucun skill ne lance `kubectl apply`, `docker push`, `git push` ou ne poste une review sans accord explicite.
- Aucun contrôle n'est déclaré « passé » s'il n'a pas tourné ; un outil absent est noté « (indispo) ».
