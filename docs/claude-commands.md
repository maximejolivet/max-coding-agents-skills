# COMMANDES CLAUDE CODE

Référence des commandes de Claude Code et du plugin `max`. Pour la liste complète et à jour, taper `/help` dans une session.

## SOMMAIRE

1. [Commandes slash](#1-commandes-slash-dans-une-session)
2. [Skills installés sur cette machine](#2-skills-installés-sur-cette-machine)
3. [Commandes du plugin `max`](#3-commandes-du-plugin-max)
4. [Commandes terminal](#4-commandes-terminal-hors-session)
5. [Raccourcis](#5-raccourcis)

---

## 1. COMMANDES SLASH (dans une session)

À taper dans le prompt de Claude Code, en commençant par `/`.

### Session et contexte

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `/help` | Aide et liste des commandes | `/help` |
| `/clear` | Efface la conversation (changement de tâche) | `/clear` |
| `/compact` | Résume la conversation pour libérer du contexte, sans l'effacer | `/compact garde les décisions sur l'auth` |
| `/resume` | Rouvre une session précédente depuis une liste | `/resume` |
| `/context` | Montre la part du contexte utilisée | `/context` |
| `/cost` | Coût et durée de la session | `/cost` |
| `/status` | Modèle, compte, dossier et réglages actifs | `/status` |
| `/exit` | Quitte Claude Code | `/exit` |

### Réglages et projet

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `/model` | Change de modèle pour la session | `/model sonnet` |
| `/config` | Écran des réglages (thème, verbosité…) | `/config` |
| `/permissions` | Outils autorisés sans confirmation | règle `Bash(npm run test:*)` |
| `/memory` | Ouvre les fichiers CLAUDE.md | `/memory` |
| `/init` | Crée un CLAUDE.md décrivant le projet (une fois par projet) | `/init` |
| `/add-dir` | Ajoute un dossier à la session | `/add-dir ~/Sites/autre-projet` |
| `/ide` | Connecte Claude Code à l'IDE | `/ide` |
| `/login`, `/logout` | Connexion ou déconnexion du compte Anthropic | `/login` |
| `/doctor` | Diagnostique l'installation | `/doctor` |

### Extensions

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `/agents` | Crée et gère des sous-agents | `/agents` |
| `/mcp` | Serveurs MCP connectés et leur état | `/mcp` |
| `/hooks` | Commandes shell lancées sur des événements | linter après chaque édition `.ts` |
| `/plugin` | Gère plugins et marketplaces | `/plugin install max@max` |
| `/reload-plugins` | Recharge les plugins sans redémarrer | `/reload-plugins` |

Installer le plugin `max` :

```
> /plugin marketplace add maximejolivet/claude-skills-max
> /plugin install max@max
```

---

## 2. SKILLS INSTALLÉS SUR CETTE MACHINE

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `/code-review` | Relit le diff courant ou une PR, signale les bugs probables | `/code-review 42` |
| `/security-review` | Revue de sécurité de la branche courante | `/security-review` |
| `/simplify` | Nettoie le code modifié (ne cherche pas les bugs) | `/simplify` |
| `/loop` | Relance un prompt à intervalle fixe | `/loop 5m vérifie le déploiement` |
| `/schedule` | Agent cloud planifié (cron ou une seule fois) | `/schedule chaque lundi 9h, résume les PR` |

---

## 3. COMMANDES DU PLUGIN `max`

Elles s'invoquent sous `/max:<skill>` ; taper `/max:` pour les lister. Détail dans [skills-tools.md](skills-tools.md), sous-agents dans [agents-tools.md](agents-tools.md).

### Cycle d'une modification

Dans l'ordre d'une fonctionnalité, de la branche à la PR.

| Étape | Commande | À quoi ça sert | Exemple |
| :---: | :--- | :--- | :--- |
| 1 | `/max:switch` | Crée `feat/<slug>` ou `fix/<slug>` depuis `main` à jour, change de branche, nettoie les branches mergées | `/max:switch feat/ma-feature` |
| 2 | `/max:commit` | Message `type(scope): emoji description`, scope obligatoire | `/max:commit` |
| 3 | `/max:versioning` | +0.0.1, aligné dans `plugin.json`, `marketplace.json` et le badge, puis `tests/check.sh` | `/max:versioning` |
| 4 | `/max:review` | Relit le changement : correction, sécurité, performance, standards, tests. Verdict classé par gravité | `/max:review` |
| 5 | `/max:pull-request` | Commit ciblé, push, PR en **Draft** vers `main` | `/max:pull-request` |
| – | `/max:pr-review` | Relit la PR d'un autre, prépare la review, ne poste que sur accord | `/max:pr-review 23` |

Le passage en « Ready for review » et le merge restent à faire par l'utilisateur.

### Audit et infrastructure

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `/max:security` | Audite dépendances, Docker et workflows Actions, classe par criticité | `/max:security` |
| `/max:test` | Écrit, lance et diagnostique des tests (non-régression d'abord pour un bug) | `/max:test le test UserServiceTest est instable` |
| `/max:docker` | Dockerfile, Compose, Makefile, CI de build | `/max:docker` |
| `/max:kubernetes` | Manifestes, Kustomize, Helm, déploiement Actions | `/max:kubernetes` |

### Développement par stack

Chacun lit le code existant, propose l'approche, implémente, puis renvoie vers `/max:review`.

| Commande | Stack | Exemple |
| :--- | :--- | :--- |
| `/max:symfony` | Symfony 6.4, 7.x, 8.x | `/max:symfony ajoute une commande de purge des sessions` |
| `/max:nuxt` | Nuxt 3 et 4 | `/max:nuxt ajoute une page /contact` |
| `/max:react` | React 18 et 19 | `/max:react crée un hook useDebounce` |

### Sous-agents (sur demande)

Lancés en général par un skill. Deux se demandent explicitement :

| Agent | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `max:docs-updater` | Compare les `.md` au code, rend les corrections à appliquer (lecture seule) | `utilise l'agent max:docs-updater` |
| `max:agile-planner` | Choisit Scrum ou Kanban et remplit la page projet dans Notion | `utilise l'agent max:agile-planner` |

---

## 4. COMMANDES TERMINAL (hors session)

| Commande | À quoi ça sert | Exemple |
| :--- | :--- | :--- |
| `claude` | Session interactive dans le dossier courant | `claude` |
| `claude "question"` | Session avec un premier message | `claude "explique l'architecture"` |
| `claude -p "question"` | Mode non interactif, idéal en script ou pipe | `git diff \| claude -p "message de commit"` |
| `claude -c` | Reprend la dernière conversation du dossier | `claude -c` |
| `claude -r` | Choisir une session à reprendre | `claude -r` |
| `claude --plugin-dir` | Charge un plugin local sans l'installer (dev de ce dépôt) | `claude --plugin-dir ~/Sites/claude-skills-max` |
| `claude update` | Met à jour Claude Code | `claude update` |
| `claude mcp` | Gère les serveurs MCP | `claude mcp list` |
| `claude doctor` | Diagnostique l'installation | `claude doctor` |

---

## 5. RACCOURCIS

| Raccourci | Effet | Exemple |
| :--- | :--- | :--- |
| `!commande` | Lance une commande shell, sortie ajoutée à la conversation | `!git status` |
| `@fichier` | Ajoute un fichier au contexte | `explique @src/Header.tsx` |
| `Shift+Tab` | Change le mode : demander, accepter les éditions, planifier | – |
| `Esc` | Interrompt la réponse en cours | – |
| `Esc Esc` | Retour en arrière dans la conversation | – |
