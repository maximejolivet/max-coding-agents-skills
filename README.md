<div align="center">

<img src="https://www.maxime.bzh/maxime-black.svg" alt="Maxime" height="80" align="middle">
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://github.com/maximejolivet"><img src="https://wsrv.nl/?url=github.com/maximejolivet.png&w=160&h=160&fit=cover&mask=circle" alt="maximejolivet" width="80" height="80" align="middle"></a>

<br>

# Max

**Un plugin Claude Code qui accompagne un changement de la première ligne jusqu'au merge.**

Vingt-cinq skills appelés par `/max:<nom>`, installés en deux commandes.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-1.0.15-lightgrey)](.claude-plugin/plugin.json)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)
[![Check](https://img.shields.io/github/actions/workflow/status/maximejolivet/claude-skills-max/check.yml?label=check)](https://github.com/maximejolivet/claude-skills-max/actions/workflows/check.yml)
[![Dernier commit](https://img.shields.io/github/last-commit/maximejolivet/claude-skills-max)](https://github.com/maximejolivet/claude-skills-max/commits/main)
[![Stars](https://img.shields.io/github/stars/maximejolivet/claude-skills-max?style=flat)](https://github.com/maximejolivet/claude-skills-max/stargazers)

![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Symfony](https://img.shields.io/badge/Symfony-000000?logo=symfony&logoColor=white)
![Nuxt](https://img.shields.io/badge/Nuxt-00DC82?logo=nuxt&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)

</div>

## Pourquoi Max

Claude Code sait coder ; Max lui apprend **ta façon de livrer**. Chaque skill encode une étape précise du travail : brancher, développer, tester, committer, relire, ouvrir la PR, auditer. Les consignes sont écrites une fois, en français, et réutilisées dans tous tes projets GitHub.

Ce qui le distingue :

- **Il suit le flux.** Un skill de développement conclut en renvoyant vers `/max:review`, qui débouche sur `/max:pull-request`. Tu n'as pas à te rappeler l'ordre.
- **Il s'adapte au projet.** Les skills transverses repèrent la techno (langage, framework, runner, Docker, Actions) puis lisent les règles correspondantes. Sans règles pour ta stack, ils se rabattent sur des valeurs par défaut et le précisent.
- **Il délègue la lecture.** Pour un gros diff ou un audit large, des sous-agents en lecture seule travaillent en parallèle ; le skill fusionne leurs constats.
- **Il demande avant d'agir dehors.** Draft par défaut, aucun push sur `main`, revue postée seulement après ton feu vert, cluster Kubernetes en lecture seule.

## Installer

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

- Depuis un clone : `/plugin marketplace add ~/Sites/claude-skills-max`, puis `install` comme ci-dessus.
- Mise à jour : `/plugin marketplace update max`, puis `/plugin install max@max`.
- Prérequis pour `pull-request`, `pr-review`, `issue`, `release` : la CLI [`gh`](https://cli.github.com), connectée via `gh auth login`.

Tape ensuite `/max:` : la liste des skills s'affiche.

## Les 25 skills

### Brancher, committer, publier

| Commande            | Ce qu'il fait                                                                                           |
| :------------------ | :------------------------------------------------------------------------------------------------------ |
| `/max:switch`       | Change de branche sans rien perdre, crée `feat/` ou `fix/` depuis `main` à jour, supprime les branches mergées. |
| `/max:commit`       | Écrit le message au format `type(scope): emoji description`.                                            |
| `/max:versioning`   | Monte la version de 0.0.1 et l'aligne dans `plugin.json`, `marketplace.json` et le badge.               |
| `/max:pull-request` | Commit ciblé, push, puis `gh pr create` en Draft vers `main`, avec le lien de l'issue.                  |
| `/max:rebase`       | Rebase ou fusion avec sauvegarde préalable ; `--force-with-lease` seulement si tu l'acceptes.           |
| `/max:release`      | Choisit la version d'après les commits, rédige le changelog, pose le tag et la GitHub Release sur accord. |
| `/max:hotfix`       | Part du tag en production, écrit le test d'abord, corrige, puis rétroporte.                             |
| `/max:issue`        | Rédige ou découpe une issue avec critères d'acceptation vérifiables ; création via `gh` sur accord.     |

### Développer et comprendre

| Commande              | Ce qu'il fait                                                                                         |
| :-------------------- | :---------------------------------------------------------------------------------------------------- |
| `/max:dev`            | Développement dans la stack détectée, quelle qu'elle soit, puis renvoi vers `/max:review`.            |
| `/max:symfony`        | Développement Symfony 6.4, 7.x et 8.x, puis renvoi vers `/max:review`.                                |
| `/max:nuxt`           | Développement Nuxt 3 et 4, puis renvoi vers `/max:review`.                                            |
| `/max:react`          | Développement React 18 et 19, puis renvoi vers `/max:review`.                                         |
| `/max:debug`          | Remonte à la cause racine : reproduction, hypothèses, bisect, test de non-régression, correctif minimal. |
| `/max:refactor`       | Refactoring ou migration massive, lot par lot, tests d'abord, un commit par lot.                      |
| `/max:perf`           | Mesure avant de toucher : goulot prouvé, un changement à la fois, gain chiffré.                       |
| `/max:a11y`           | Audit et corrections RGAA / WCAG : sémantique, clavier, contrastes, formulaires.                      |
| `/max:migrate-db`     | Migrations réversibles, sans verrou long, en expand/contract, avec plan de retour.                    |
| `/max:explain`        | Décrit un dépôt inconnu en lecture seule : carte, flux, commandes, zones fragiles.                    |

### Vérifier et sécuriser

| Commande            | Ce qu'il fait                                                                                           |
| :------------------ | :------------------------------------------------------------------------------------------------------ |
| `/max:test`         | Écrit, lance et diagnostique les tests ; mode TDD ou BDD sur demande.                                  |
| `/max:review`       | Relit ton diff avant la PR et classe les constats par gravité.                                          |
| `/max:pr-review`    | Relit la PR d'un autre, lit l'issue et les checks, rédige un brouillon de revue ; ne poste que si tu dis oui. |
| `/max:security`     | Audite dépendances, Docker et workflows Actions, et hiérarchise selon le risque réellement exploitable. |

### Infrastructure et méthode

| Commande              | Ce qu'il fait                                                                                       |
| :-------------------- | :-------------------------------------------------------------------------------------------------- |
| `/max:docker`         | Dockerfile, Compose, Makefile et build CI : reproductible, minimal, durci.                          |
| `/max:kubernetes`     | Manifestes, Kustomize, Helm, déploiement par Actions ; cluster en lecture seule par défaut.         |
| `/max:ci`             | Écrit ou répare un workflow : logs d'un run raté, cache, matrices, permissions réduites.            |
| `/max:agent-workflow` | Conçoit un workflow agentique : découpe, choix skill/agent/hook/MCP, boucle de contrôle, garde-fous. |

## Un cycle typique

```text
/max:switch          # nouvelle branche depuis main à jour
/max:symfony …       # ou /max:nuxt, /max:react : développer
/max:test            # tests
/max:commit          # message sémantique
/max:versioning      # version +0.0.1
/max:review          # verdict avant la PR
/max:pull-request    # push et PR en Draft
/max:switch delete   # après le merge : retire la branche
```

Le passage en « Ready for review » et le merge te reviennent.

## Sous le capot

**Détection de stack.** Les skills transverses lancent `stacks/detect.sh`, qui ne fait que lire le projet, puis suivent `stacks/DETECT.md`. Ils chargent alors `stacks/<techno>/INDEX.md` pour la nature voulue : `core` + `dev`, `review`, `security`, `test` ou `deploy`. Stacks livrées : Symfony, Nuxt, React, Next.js, Vue, Laravel, Django.

**Sous-agents.** Dix agents en lecture seule vivent dans `agents/` : quatre relecteurs pour `/max:review`, trois auditeurs pour `/max:security`, un explorateur de code (`codebase-surveyor`) et, sur demande seulement, `agile-planner` et `docs-updater`.

**Garde-fou git.** Un hook `PreToolUse` sur Bash (`hooks/hooks.json` → `scripts/guard-git.sh`) bloque `git push --force` et tout push direct vers `main` ou `master`. `--force-with-lease` et les pushes de branche passent. Sans `python3`, le hook s'efface.

**Contrôle de cohérence.** `sh tests/check.sh` vérifie le frontmatter, les références croisées, l'alignement des versions et la détection sur des projets factices. Il tourne en CI à chaque PR ; `tests/SCENARIOS.md` complète avec des scénarios à jouer à la main.

## Carte du dépôt

| Dossier               | Contenu                                                                    |
| :-------------------- | :------------------------------------------------------------------------- |
| `skills/`             | Un dossier par skill, avec son `SKILL.md`.                                 |
| `agents/`             | Les dix sous-agents en lecture seule.                                      |
| `stacks/`             | `DETECT.md`, `detect.sh` et un dossier par techno.                         |
| `references/`         | Listes de contrôle : Core Web Vitals, RGAA.                                |
| `hooks/`, `scripts/`  | Le garde-fou git et le script de réinstallation locale.                    |
| `tests/`              | `check.sh` et les scénarios manuels.                                       |
| `docs/`               | Guides détaillés (ci-dessous).                                             |
| `.claude-plugin/`     | `plugin.json` et `marketplace.json`.                                       |
| `.github/`            | Workflow de contrôle et modèle de PR.                                      |

## Aller plus loin

| Guide | Pour quoi faire |
| :---- | :-------------- |
| [Démarrer](docs/getting-started.md) | Passer de l'installation à une première PR relue. |
| [Commandes](docs/claude-commands.md) | Retrouver les commandes Claude Code et `/max:*`, avec exemples. |
| [Anatomie d'un skill](docs/skill-anatomy.md) | Écrire ou modifier un skill. |
| [Sous-agents](docs/agents.md) | Savoir qui lance quel agent, et quand. |
| [Outils des agents](docs/agents-tools.md) | Consulter les outils autorisés pour chaque agent. |
| [Outils des skills](docs/skills-tools.md) | Voir ce que chaque skill exécute. |
| [Stacks](docs/stacks.md) | Comprendre la détection et brancher une nouvelle techno. |
| [Onboarding](docs/developer-onboarding.md) | Contribuer au dépôt. |
| [User stories](docs/user-stories.md) | Rédiger des stories ; première série du plugin. |
| [Dépôts IA](docs/depots-tools.md) | Parcourir une sélection de projets autour des agents de code. |

Pour contribuer : [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

[MIT](LICENSE) © 2026 Maxime
