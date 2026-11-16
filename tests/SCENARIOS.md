# Scénarios de vérification manuelle

`tests/check.sh` s'assure que le plugin est cohérent (frontmatter, références, détection de stack). Il ne dit rien de ce que les skills et agents **font** : cela ne se constate que dans une vraie session. Ces scénarios servent à le contrôler après un changement important.

## Mode d'emploi

1. Ouvrir une session avec `claude --plugin-dir ~/Sites/claude-skills-max`, puis `/reload-plugins` après chaque édition.
2. Pour chaque scénario, lancer la commande dans un projet de la techno indiquée.
3. Comparer au résultat attendu et noter l'issue : ✅ conforme, ⚠️ écart (avec une remarque).

## A. Détection de stack

| # | Contexte | Action | Résultat attendu |
| :-: | :------ | :----- | :--------------- |
| 1 | Projet Symfony | `sh stacks/detect.sh <projet>` | `framework symfony`, `resource symfony` avec un chemin, bon runner. |
| 2 | Projet Nuxt | idem | `framework nuxt`, `parent nuxt vue`, `resource nuxt`. |
| 3 | Projet sans ressource (Angular ou WordPress, par exemple) | `/max:review` sur un diff | Le verdict indique qu'aucune ressource review n'existe pour cette stack et applique les dimensions génériques. |
| 45 | Projets Laravel et Django factices | `/max:review` | `detect.sh` émet `resource laravel` / `resource django` et la stack est bien chargée. |

## B. Relecture (`/max:review`)

| # | Contexte | Résultat attendu |
| :-: | :------ | :--------------- |
| 4 | Petit diff (moins de 150 lignes, 3 fichiers au plus) | Passe unique, aucun agent, mode annoncé. |
| 5 | Gros diff backend | Trois agents lancés dans le même tour (`correctness`, `security`, `standards`), sans `frontend-reviewer`. |
| 6 | Gros diff touchant des `.vue` ou `.tsx` | Les trois agents **et** `frontend-reviewer`. |
| 7 | Diff contenant un bug volontaire (condition inversée) | Constat Bloquant ou Majeur, revérifié dans le code ; verdict « modifications nécessaires ». |
| 8 | Diff propre | Verdict « livrable », sans tableau et sans constat inventé. |
| 9 | Un agent rendu indisponible (fichier renommé) | Le skill signale l'absence et couvre lui-même la dimension. |

## C. Audit (`/max:security`)

| # | Contexte | Résultat attendu |
| :-: | :------ | :--------------- |
| 10 | Lockfile seul | Passe unique (un seul écosystème), mode annoncé. |
| 11 | Lockfile + Dockerfile + workflows | Trois agents en parallèle ; tableau de synthèse alimenté par leurs lignes `Audité`. |
| 12 | Sandbox sans réseau | Repli par WebFetch annoncé ; jamais de « 0 vulnérabilité » sans audit réel. |
| 13 | Workflow avec `pull_request_target` et checkout de la tête de PR | Constat Critique de `actions-auditor`. |

## D. Développement

| # | Contexte | Action | Résultat attendu |
| :-: | :------ | :----- | :--------------- |
| 14 | Gros projet Symfony, Nuxt ou React | `/max:symfony` (ou `nuxt`, `react`) + une tâche | `codebase-surveyor` lancé ; résumé de 40 lignes au plus, avec de vrais chemins. |
| 15 | Petit projet | idem | Exploration directe, aucun agent. |
| 16 | Projet d'une autre techno | `/max:nuxt` | Le skill constate que ce n'est pas du Nuxt et oriente ailleurs. |
| 17 | Quelconque | Tâche terminée | Renvoi vers `/max:review`, puis `/max:pull-request`. |

## E. Tests, commits, PR, branches

| # | Contexte | Action | Résultat attendu |
| :-: | :------ | :----- | :--------------- |
| 18 | Bug connu | `/max:test` | Test de non-régression écrit **et vu rouge** avant la correction. |
| 19 | Suite avec un test rouge | `/max:test` | Aucun test supprimé ni ignoré pour faire passer ; l'échec est expliqué. |
| 20 | Dépôt de test | `/max:pull-request` | Branche `feat/…` depuis `main` à jour, commit conforme à `/max:commit`, PR en **Draft**, rappel du nettoyage. |
| 21 | PR d'exemple | `/max:pr-review` | Brouillon seulement ; **rien posté** sans accord. |
| 22 | Quelconque | `/max:commit` | `type(scope): emoji description`, scope présent, aucune mention d'attribution à une IA. |
| 33 | Branche dont la PR est mergée | `/max:switch delete` | PR et état annoncés ; retour sur `main` à jour ; confirmation ; `git branch -d` ; distante intacte sans `--remote`. |
| 34 | Branche à PR ouverte, ou `main` | `/max:switch delete` | Arrêt avec explication, aucune suppression ; `-D` uniquement avec `--force` confirmé pour cette branche. |
| 36 | Plugin installé | Demander `git push --force` ou `git push origin main` | Refus par le hook avec un message ; `--force-with-lease` et push de branche acceptés. |
| 40 | Branche en retard avec conflits | `/max:rebase` | Branche de sauvegarde créée ; conflits lus des deux côtés ; push en `--force-with-lease` seulement sur accord. |

## F. Skills de méthode et d'exploitation

| # | Contexte | Action | Résultat attendu |
| :-: | :------ | :----- | :--------------- |
| 23 | Quelconque | `/max:agent-workflow` + grosse tâche (migrer un module par lots) | Cadrage (objectif, critère vérifiable, périmètre) ; schéma séquentiel/parallèle avec le mécanisme choisi par étape. |
| 24 | idem | idem | Boucle de vérification (commande ou agent indépendant), **limite d'essais** et condition d'arrêt. |
| 25 | idem | idem | **Rien n'est écrit** (CLAUDE.md, skill, agent, hook) avant accord ; `settings.json` jamais modifié. |
| 26 | Tâche sans critère vérifiable | idem | Le skill le signale et propose un critère au lieu d'une boucle à vide. |
| 27 | Gros projet, suite verte | `/max:refactor` + renommage répandu | Suite lancée et verte **avant** ; plan en lots ; accord avant exécution ; un commit par lot seulement sur demande. |
| 28 | Zone sans tests | `/max:refactor` | Tests de caractérisation d'abord, ou lots réduits avec recette manuelle ; aucun test supprimé ni ignoré. |
| 29 | Projet outillé en tests | `/max:test` en TDD | Un seul test rouge à la fois, **vu rouge**, puis vert, puis refactor ; étape annoncée à chaque tour. |
| 30 | idem | `/max:test` en BDD | Scénarios Given/When/Then validés avant le code ; aucune dépendance installée sans accord. |
| 31 | Bug reproductible | `/max:debug` + message d'erreur | Repro minimale avant tout correctif ; cause racine avec `fichier:ligne` ; test vu rouge puis vert. |
| 32 | Bug introuvable ou non reproductible | `/max:debug` | Le skill l'admet et liste ce qui manque ; pas de correctif à l'aveugle ni de `catch` qui masque. |
| 35 | Dépôt GitHub avec issues | `/max:issue` + une demande de fonctionnalité | Doublons cherchés ; critères vérifiables ; issue montrée en entier ; **rien créé** avant accord. |
| 37 | `main` taguée, commits sémantiques depuis le tag | `/max:release` | Version proposée avec justification ; notes groupées par type ; **ni tag ni release** avant accord. |
| 38 | Production en retrait de `main` | `/max:hotfix` | Choix de la base (tag ou `main`) expliqué ; test rouge puis vert ; backport proposé, jamais fait en silence. |
| 39 | Run Actions en échec | `/max:ci` | `gh run view --log-failed` lu ; cause établie avant correction ; permissions non élargies. |
| 41 | Page lente | `/max:perf` | Mesure de départ chiffrée ; un changement à la fois ; gain prouvé avant/après. |
| 42 | Formulaire web | `/max:a11y` | Outils lancés ou absence signalée ; parcours clavier vérifié ; aucune conformité totale affirmée. |
| 43 | Renommage de colonne sur grosse table | `/max:migrate-db` | Expand/contract proposé ; cycle up/down/up ; **rien lancé** sur un environnement partagé. |
| 44 | Dépôt inconnu | `/max:explain` | Lecture seule ; `fichier:ligne` cités ; distinction entre supposé et lu. |

## Garde-fous à toujours constater

- Aucun agent ne modifie de fichier ni ne committe.
- Aucun skill ne lance `kubectl apply`, `docker push` ou `git push`, ni ne poste une revue, sans accord explicite.
- Un contrôle n'est jamais déclaré « passé » s'il n'a pas tourné ; un outil absent se note « (indispo) ».
