# Aide-mémoire des commandes

Trois familles de commandes : celles de Claude Code, celles du plugin `max`, et celles du terminal. La liste officielle et à jour s'obtient avec `/help`.

**Sommaire** : [Dans une session](#dans-une-session) · [Skills présents sur cette machine](#skills-présents-sur-cette-machine) · [Plugin max](#plugin-max) · [Terminal](#terminal) · [Raccourcis](#raccourcis)

## Dans une session

### Gérer la conversation

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `/help` | Affiche l'aide | `/help` |
| `/clear` | Repart d'une conversation vide | `/clear` |
| `/compact` | Condense l'historique pour libérer du contexte | `/compact garde les choix sur l'auth` |
| `/resume` | Rouvre une ancienne session | `/resume` |
| `/context` | Montre le contexte consommé | `/context` |
| `/cost` | Affiche coût et durée | `/cost` |
| `/status` | Modèle, compte, dossier, réglages | `/status` |
| `/exit` | Quitte | `/exit` |

### Régler l'environnement

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `/model` | Change de modèle | `/model sonnet` |
| `/config` | Ouvre les réglages | `/config` |
| `/permissions` | Gère les outils autorisés sans confirmation | règle `Bash(npm run test:*)` |
| `/memory` | Édite les fichiers CLAUDE.md | `/memory` |
| `/init` | Génère un CLAUDE.md pour le projet | `/init` |
| `/add-dir` | Ajoute un dossier à la session | `/add-dir ~/Sites/autre-projet` |
| `/ide` | Relie Claude Code à ton IDE | `/ide` |
| `/login`, `/logout` | Connexion au compte | `/login` |
| `/doctor` | Diagnostique l'installation | `/doctor` |

### Étendre Claude Code

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `/agents` | Crée et gère des sous-agents | `/agents` |
| `/mcp` | État des serveurs MCP | `/mcp` |
| `/hooks` | Commandes déclenchées par des événements | lancer un linter après chaque édition `.ts` |
| `/plugin` | Plugins et marketplaces | `/plugin install max@max` |
| `/reload-plugins` | Recharge sans redémarrer | `/reload-plugins` |

## Skills présents sur cette machine

Ils ne font pas partie de `max` mais sont disponibles ici.

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `/code-review` | Cherche les bugs probables dans le diff ou une PR | `/code-review 42` |
| `/security-review` | Revue de sécurité de la branche | `/security-review` |
| `/simplify` | Allège le code modifié (sans chasser les bugs) | `/simplify` |
| `/loop` | Répète un prompt à intervalle régulier | `/loop 5m vérifie le déploiement` |
| `/schedule` | Agent cloud planifié, récurrent ou ponctuel | `/schedule chaque lundi 9h, résume les PR` |

## Plugin max

Tape `/max:` pour les lister. Détails : [skills-tools.md](skills-tools.md) et [agents-tools.md](agents-tools.md).

### Du branchement à la PR

| # | Commande | Effet | Exemple |
| :-: | :------ | :---- | :------ |
| 1 | `/max:switch` | Crée ou change de branche depuis `main` à jour ; `delete [branche\|#PR] [--remote] [--force]` retire la branche liée, `clean` retire toutes les mergées | `/max:switch delete --remote` |
| 2 | `/max:commit` | Message `type(scope): emoji description` | `/max:commit` |
| 3 | `/max:versioning` | +0.0.1 aligné partout, puis `tests/check.sh` | `/max:versioning` |
| 4 | `/max:review` | Verdict par gravité : correction, sécurité, performance, standards, tests | `/max:review` |
| 5 | `/max:pull-request` | Commit, push, PR en **Draft** vers `main` | `/max:pull-request` |
| – | `/max:pr-review` | Prépare la revue d'une PR tierce, poste sur accord | `/max:pr-review 23` |

Passer la PR en « Ready for review » et la merger restent des gestes manuels.

### Les autres skills

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `/max:test` | Écrit, lance, diagnostique les tests | `/max:test UserServiceTest est instable` |
| `/max:debug` | Cherche la cause racine d'un bug | `/max:debug paiement refusé pour 0 €` |
| `/max:refactor` | Chantier large découpé en lots | `/max:refactor remplace moment par date-fns` |
| `/max:perf` | Optimise avec mesures avant/après | `/max:perf la liste est lente` |
| `/max:a11y` | Audit RGAA / WCAG et correctifs | `/max:a11y formulaire d'inscription` |
| `/max:migrate-db` | Migration de base sans risque | `/max:migrate-db renomme la colonne email` |
| `/max:security` | Audit dépendances, Docker, Actions | `/max:security` |
| `/max:docker` | Dockerfile, Compose, Makefile | `/max:docker` |
| `/max:kubernetes` | Manifestes, Kustomize, Helm | `/max:kubernetes` |
| `/max:ci` | Workflow GitHub Actions | `/max:ci le job test échoue` |
| `/max:rebase` | Rebase ou fusion sécurisés | `/max:rebase ma branche sur main` |
| `/max:release` | Version, changelog, tag, Release | `/max:release` |
| `/max:hotfix` | Correctif urgent sur la production | `/max:hotfix paiement cassé en prod` |
| `/max:issue` | Issue ou découpage en issues | `/max:issue export CSV des commandes` |
| `/max:explain` | Explique un dépôt, lecture seule | `/max:explain comment marche la commande` |
| `/max:agent-workflow` | Conçoit un workflow agentique | `/max:agent-workflow découpe la migration en lots` |

### Développer par stack

Chaque skill lit le code, propose une approche, implémente, puis renvoie vers `/max:review`.

| Commande | Stack | Exemple |
| :------- | :---- | :------ |
| `/max:symfony` | Symfony 6.4, 7.x, 8.x | `/max:symfony commande de purge des sessions` |
| `/max:nuxt` | Nuxt 3 et 4 | `/max:nuxt page /contact` |
| `/max:react` | React 18 et 19 | `/max:react hook useDebounce` |

### Agents appelés par toi

La plupart des agents sont lancés par un skill. Deux se demandent à la main :

| Agent | Effet | Exemple |
| :---- | :---- | :------ |
| `max:docs-updater` | Liste les écarts entre `.md` et code | `utilise l'agent max:docs-updater` |
| `max:agile-planner` | Choisit Scrum ou Kanban, remplit Notion | `utilise l'agent max:agile-planner` |

## Terminal

| Commande | Effet | Exemple |
| :------- | :---- | :------ |
| `claude` | Session interactive | `claude` |
| `claude "question"` | Session avec un premier message | `claude "explique l'architecture"` |
| `claude -p "…"` | Mode non interactif, utile en pipe | `git diff \| claude -p "message de commit"` |
| `claude -c` | Reprend la dernière conversation du dossier | `claude -c` |
| `claude -r` | Choisit une session à reprendre | `claude -r` |
| `claude --plugin-dir` | Charge un plugin local | `claude --plugin-dir ~/Sites/claude-skills-max` |
| `claude update` | Met Claude Code à jour | `claude update` |
| `claude mcp` | Gère les serveurs MCP | `claude mcp list` |
| `claude doctor` | Diagnostique l'installation | `claude doctor` |

## Raccourcis

| Saisie | Effet | Exemple |
| :----- | :---- | :------ |
| `!commande` | Exécute du shell, résultat versé dans la conversation | `!git status` |
| `@fichier` | Joint un fichier au contexte | `explique @src/Header.tsx` |
| `Shift+Tab` | Alterne les modes : confirmer, accepter les éditions, planifier | – |
| `Esc` | Coupe la réponse en cours | – |
| `Esc Esc` | Remonte dans la conversation | – |
