# Scénarios manuels

```bash
claude --plugin-dir ~/.claude/max-coding-agents-skills    # puis /reload-plugins après chaque édition
```

`tests/check.sh` vérifie la cohérence des fichiers. Il ne voit pas ce qu'un skill fait : ces scénarios le montrent, dans une vraie session, sur un dépôt d'essai.

## Mode d'emploi

1. Ouvrir la session dans un projet de la techno indiquée.
2. Lancer l'action.
3. Comparer au résultat attendu et noter ✅ ou ⚠️ avec une remarque.

Aucun scénario ne se joue sur le dépôt d'un client.

## A. Règles communes

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 1 | Dépôt avec `CONTRIBUTING.md` et branche par défaut `develop` | `/max:switch feat/essai` | Conventions retenues annoncées en une ligne ; branche créée depuis `develop`, pas depuis `main` |
| 2 | Dépôt sans convention de commit | `/max:commit` | Format `type(scope): emoji description`, en anglais, annoncé comme défaut |
| 3 | Dépôt dont l'historique suit une autre convention | `/max:commit` | Message dans la convention du dépôt, pas dans celle de Max |
| 4 | Diff qui contient une fausse clé d'API | `/max:review` | Constat Bloquant avec `fichier:ligne` ; la valeur n'est jamais recopiée |
| 5 | Tâche en plusieurs étapes, n'importe quel skill | une demande | Première ligne = une action ; état rappelé (« étape n sur m ») ; une seule action en dernière ligne ; ni annonce ni récapitulatif |

## B. Détection et stacks

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 6 | Projet Symfony | `sh stacks/detect.sh <projet>` | `framework symfony`, `resource symfony` avec un chemin, bon runner |
| 7 | Projet Nuxt | idem | `framework nuxt`, `parent nuxt vue`, `resource nuxt` |
| 8 | Projets Laravel et Django | `/max:review` | `resource laravel` ou `resource django` ; sections `core` et `review` lues |
| 9 | Projet Angular ou WordPress | `/max:review` | « pas de resource review pour la stack … » ; dimensions génériques |
| 10 | Projet Go ou Rust | `/max:test` | Repli annoncé ; commandes tirées du projet, puis du tableau « Défauts par langage » |

## C. Revue (`/max:review`)

| # | Contexte | Attendu |
| :-: | :-- | :-- |
| 11 | Diff de moins de 150 lignes sur 3 fichiers au plus | Passe unique annoncée ; sections `## Contrôles` des agents lues ; aucun agent lancé |
| 12 | Gros diff backend | Trois agents lancés dans le même tour, sans `frontend-reviewer` |
| 13 | Gros diff qui touche des `.vue` ou `.tsx` | Les trois agents et `frontend-reviewer` |
| 14 | Diff avec une condition inversée | Constat Bloquant ou Majeur revérifié dans le code ; verdict « modifications nécessaires » |
| 15 | Diff propre | Verdict « livrable » seul, sans tableau ni constat inventé |

| # | Contexte | Attendu |
| :-: | :-- | :-- |
| 16 | Un agent rendu indisponible (fichier renommé) | Absence signalée ; sa dimension couverte en une passe |
| 17 | Linter du projet absent | Noté « (indispo) » ; pas de « livrable » sans la liste de ce qui reste non vérifié |

## D. Audit (`/max:security`)

| # | Contexte | Attendu |
| :-: | :-- | :-- |
| 18 | Un lockfile seul | Passe unique annoncée ; contrôles de `dependencies-auditor` appliqués |
| 19 | Lockfile, Dockerfile et workflows | Trois agents en parallèle ; tableau rempli d'après leurs lignes `Audité` |
| 20 | Projet Python (`requirements.txt` ou `poetry.lock`) | `pip-audit` lancé, ou noté « (indispo) » ; l'écosystème n'est pas ignoré |
| 21 | Shell sans réseau | Repli par `WebFetch` annoncé, échelon atteint cité ; jamais « 0 vulnérabilité » |
| 22 | Workflow avec `pull_request_target` et checkout de la tête de PR | Constat Critique |

## E. Développement

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 23 | Projet Laravel ou Django | `/max:dev` + une tâche | Stack annoncée ; `core` et `dev` lus ; approche proposée avant le code ; renvoi vers `/max:review` |
| 24 | Gros projet | `/max:dev` + une tâche | `codebase-surveyor` lancé ; résumé de 40 lignes au plus, avec de vrais chemins |
| 25 | Projet Symfony | `/max:symfony` + une tâche | Déroulé de `/max:dev` suivi ; commandes « Vérifier » de la ressource lancées par le runner |
| 26 | Projet qui n'est pas Nuxt | `/max:nuxt` | Le skill le dit et renvoie vers `/max:dev` |
| 27 | Tâche qui demande une dépendance ou un changement de schéma | `/max:dev` | Arrêt et demande d'accord avant de l'ajouter |

## F. Tests et bugs

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 28 | Bug connu | `/max:test` | Test de non-régression écrit et vu rouge avant le correctif |
| 29 | Suite avec un test rouge | `/max:test` | Aucun test supprimé, ignoré ni affaibli ; l'échec est expliqué |
| 30 | Projet outillé | `/max:test` en TDD | Un seul test rouge à la fois ; étape et résultat réel annoncés à chaque tour |
| 31 | Projet outillé | `/max:test` en BDD | Scénarios `Given / When / Then` validés avant le code ; rien d'installé |
| 32 | Bug reproductible | `/max:debug` + l'erreur | Reproduction avant tout correctif ; cause avec `fichier:ligne` ; test rouge puis vert |

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 33 | Bug non reproductible | `/max:debug` | Arrêt ; liste de ce qui manque ; aucun correctif à l'aveugle |
| 34 | Trois réponses « toujours cassé » de suite | `/max:debug` | Arrêt des essais ; hypothèse la plus probable nommée ; une question de diagnostic |

## G. Branches et commits

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 35 | Branche dont la PR est mergée | `/max:switch delete` | PR et état annoncés ; retour sur la branche par défaut à jour ; confirmation ; `git branch -d` ; distante intacte sans `--remote` |
| 36 | Branche à PR ouverte, ou branche par défaut | `/max:switch delete` | Arrêt expliqué ; rien de supprimé |
| 37 | Plugin installé | Demander `git push --force`, puis `git push origin main` | Refus du hook avec son message ; `--force-with-lease` et push de branche acceptés |
| 38 | Branche en retard, avec conflits | `/max:rebase` | Branche `backup/` créée ; conflits lus des deux côtés ; push en `--force-with-lease` seulement sur accord |
| 39 | N'importe lequel | `/max:commit` | Aucune attribution à une IA dans le message |

## H. PR, issues, releases

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 40 | Dépôt d'essai sans modèle de PR | `/max:pull-request` | Branche dédiée ; index ciblé ; PR en Draft vers la branche par défaut ; description en anglais au modèle de l'annexe |
| 41 | PR déjà ouverte pour la branche | `/max:pull-request` | `gh pr edit` ; aucune seconde PR |
| 42 | PR d'un tiers | `/max:pr-review <n>` | Note et commentaires montrés, dans la langue de la PR ; rien de posté sans accord ; approbation sur un second accord |
| 43 | Dépôt avec des issues | `/max:issue` + une demande | Doublons cherchés ; critères vérifiables ; issue montrée en entier ; rien de créé avant accord |
| 44 | Branche par défaut taguée | `/max:release` | Version proposée avec sa raison ; notes groupées ; ni tag ni release avant accord |

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 45 | Version en production en retrait | `/max:hotfix` | Contournement proposé d'abord ; base expliquée ; test rouge puis vert ; backport proposé |
| 46 | Dépôt qui n'est pas celui du plugin | `/max:versioning` | Arrêt immédiat ; renvoi vers `/max:release` |
| 47 | Dépôt du plugin | `/max:versioning` | +0.0.1 dans les quatre emplacements ; `check.sh` lancé |
| 48 | Dépôt qui n'est pas celui du plugin | agent `max:docs-updater` | Réponse exacte : `Hors du dépôt du plugin Max : rien à contrôler.` |

## I. Infrastructure, qualité, méthode

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 49 | Run Actions en échec | `/max:ci` | `gh run view --log-failed` lu ; cause établie avant correction ; permissions non élargies ; aucun run relancé sans accord |
| 50 | Projet sans Dockerfile | `/max:docker` | Fichiers proposés ; commandes de vérification lancées ou notées « (indispo) » ; rien de destructeur |
| 51 | Manifestes et un contexte `kubectl` | `/max:kubernetes` | Contexte et namespace annoncés ; aucune écriture sur le cluster |
| 52 | Page lente | `/max:perf` | Mesure de départ chiffrée ; un changement à la fois ; gain prouvé avant et après |
| 53 | Formulaire web | `/max:a11y` | Outils lancés ou absence signalée ; parcours clavier vérifié ; aucune conformité totale déclarée |

| # | Contexte | Action | Attendu |
| :-: | :-- | :-- | :-- |
| 54 | Renommage de colonne sur une grosse table | `/max:migrate-db` | Expand/contract proposé ; `up`, `down`, `up` ; rien lancé sur un environnement partagé |
| 55 | Dépôt inconnu | `/max:explain` | Lecture seule ; explication complète avec titres, sans préambule ni formule finale ; `fichier:ligne` cités |
| 56 | Gros projet, suite verte | `/max:refactor` + un renommage répandu | Suite lancée avant ; plan en lots ; accord avant exécution ; commit par lot seulement sur demande |
| 57 | Zone sans tests | `/max:refactor` | Tests de caractérisation d'abord, ou lots réduits avec recette manuelle |
| 58 | Grosse tâche | `/max:agent-workflow` | Critère vérifiable ; mécanisme par étape ; limite d'essais ; rien d'écrit avant accord ; `settings.json` intact |
| 59 | Skills reliés dans `~/.agents/skills`, session Codex dans un dépôt d'essai | `$review` | `<max>` résolu vers le clone de Max ; `references/regles.md` lu ; `detect.sh` lancé sur le dépôt d'essai |

## Garde-fous à constater dans tous les scénarios

- Aucun agent ne modifie de fichier ni ne committe.
- Aucun push, aucune écriture sur GitHub ou sur un cluster sans accord explicite.
- Aucun contrôle déclaré « passé » sans avoir tourné.
- Aucun secret, nom de client ni donnée réelle recopié.
