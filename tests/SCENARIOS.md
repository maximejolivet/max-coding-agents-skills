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

## Workflow agentique

| # | Où | Commande | Attendu |
| - | -- | -------- | ------- |
| 23 | n'importe lequel | `/max:agent-workflow` + une grosse tâche (ex. migrer un module en lots) | cadrage (objectif, critère vérifiable, périmètre) ; schéma avec étapes séquentielles / parallèles et mécanisme choisi par étape |
| 24 | idem | idem | boucle de vérification avec une commande ou un agent indépendant, **limite de tentatives** et condition d'arrêt |
| 25 | idem | idem | **rien n'est écrit** dans le projet (CLAUDE.md, skill, agent, hook) avant accord ; `settings.json` jamais modifié |
| 26 | tâche sans critère vérifiable | idem | le skill le dit et propose un critère plutôt que de concevoir une boucle à vide |
| 27 | gros projet avec une suite verte | `/max:refactor` + un renommage répandu | suite lancée et verte **avant** ; plan en lots ; accord demandé avant exécution ; un commit par lot seulement sur demande |
| 28 | zone sans tests | `/max:refactor` | tests de caractérisation écrits d'abord, ou lots réduits avec recette manuelle ; aucun test supprimé ou ignoré |
| 29 | projet avec un outil de test | `/max:test` en TDD | un seul test rouge à la fois, **vu rouge**, puis vert, puis refactor ; étape annoncée à chaque tour |
| 30 | idem | `/max:test` en BDD | scénarios Given/When/Then validés avant le code ; aucune dépendance installée sans accord |
| 31 | projet avec un bug reproductible | `/max:debug` + message d'erreur | repro minimale obtenue avant tout correctif ; cause racine expliquée avec `fichier:ligne` ; test vu rouge puis vert |
| 32 | bug introuvable ou non reproductible | `/max:debug` | le skill le dit et liste ce qui manque ; aucun correctif à l'aveugle ni `catch` qui masque |
| 33 | branche dont la PR est mergée | `/max:switch delete` | PR et état annoncés ; retour sur `main` à jour ; confirmation avant suppression ; `git branch -d` ; branche distante intacte sans `--remote` |
| 34 | branche dont la PR est ouverte, ou `main` | `/max:switch delete` | arrêt avec explication ; aucune suppression ; `-D` seulement avec `--force` confirmé pour cette branche |
| 35 | dépôt GitHub avec des issues | `/max:issue` + une demande de fonctionnalité | doublons cherchés ; critères d'acceptation vérifiables ; issue montrée en entier ; **rien créé** avant accord |
| 36 | plugin installé | `git push --force` ou `git push origin main` demandé à Claude | commande refusée par le hook avec un message ; `--force-with-lease` et push de branche acceptés |
| 37 | main taguée, commits sémantiques depuis le dernier tag | `/max:release` | version proposée avec justification ; notes groupées par type ; **ni tag ni release** avant accord |
| 38 | version en production derrière `main` | `/max:hotfix` | base choisie (tag ou main) expliquée ; test rouge puis vert ; backport proposé, pas fait en silence |
| 39 | run Actions en échec | `/max:ci` | `gh run view --log-failed` lu ; cause établie avant correction ; permissions non élargies |
| 40 | branche en retard avec conflits | `/max:rebase` | branche de sauvegarde créée ; conflits lus des deux côtés ; push seulement en `--force-with-lease` sur accord |
| 41 | page lente | `/max:perf` | mesure de départ chiffrée ; un changement à la fois ; gain prouvé avant/après |
| 42 | formulaire web | `/max:a11y` | outils lancés ou absence signalée ; parcours clavier vérifié ; pas de conformité totale affirmée |
| 43 | renommage de colonne sur grosse table | `/max:migrate-db` | expand/contract proposé ; up/down/up ; **rien lancé** sur un environnement partagé |
| 44 | dépôt inconnu | `/max:explain` | lecture seule ; `fichier:ligne` cités ; supposé et lu distingués |
| 45 | projets Laravel et Django factices | `/max:review` | `detect.sh` émet `resource laravel` / `resource django` et la stack est chargée |

## Garde-fous (doivent tous tenir)

- Aucun agent ne modifie de fichier ni ne committe.
- Aucun skill ne lance `kubectl apply`, `docker push`, `git push` ou ne poste une review sans accord explicite.
- Aucun contrôle n'est déclaré « passé » s'il n'a pas tourné ; un outil absent est noté « (indispo) ».
