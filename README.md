<div align="center">

<img src="https://www.maxime.bzh/maxime-black.svg" alt="Maxime" height="80" align="middle">
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://github.com/maximejolivet"><img src="https://wsrv.nl/?url=github.com/maximejolivet.png&w=160&h=160&fit=cover&mask=circle" alt="maximejolivet" width="80" height="80" align="middle"></a>

<br>

# Max

**Des skills spécialisés pour agents de code IA : développer, relire, tester, livrer et sécuriser une application, de la première ligne de code à la production.**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-1.0.17-lightgrey)](.claude-plugin/plugin.json)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)
[![Check](https://img.shields.io/github/actions/workflow/status/maximejolivet/max-coding-agents-skills/check.yml?label=check)](https://github.com/maximejolivet/max-coding-agents-skills/actions/workflows/check.yml)
[![Dernier commit](https://img.shields.io/github/last-commit/maximejolivet/max-coding-agents-skills)](https://github.com/maximejolivet/max-coding-agents-skills/commits/main)
[![Stars](https://img.shields.io/github/stars/maximejolivet/max-coding-agents-skills?style=flat)](https://github.com/maximejolivet/max-coding-agents-skills/stargazers)

![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Symfony](https://img.shields.io/badge/Symfony-000000?logo=symfony&logoColor=white)
![Nuxt](https://img.shields.io/badge/Nuxt-00DC82?logo=nuxt&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)

</div>

## À propos

Max est un plugin [Claude Code](https://claude.com/claude-code) pour les projets hébergés sur GitHub. Il réunit 26 skills, 9 sous-agents en lecture seule et les règles de 7 technos.

- **Un cycle complet.** Chaque étape a son skill et renvoie vers la suivante, du développement à la pull request.
- **Adapté au projet.** Max détecte la stack et applique les conventions du dépôt avant ses propres défauts.
- **Des relectures en parallèle.** Sur un gros diff, des sous-agents relisent la correction, la sécurité, les standards et le front.
- **Prudent par défaut.** PR en Draft, revue postée sur accord, cluster en lecture seule.
- **Vérifié.** Aucun contrôle n'est déclaré passé sans avoir tourné.

## Installer

Installe la CLI [`gh`](https://cli.github.com) et connecte-toi avec `gh auth login`. Les skills GitHub en dépendent.

### Claude Code

```bash
/plugin marketplace add maximejolivet/max-coding-agents-skills
/plugin install max@max
```

Tape `/max:` pour lister les skills, puis lance `/max:explain` sur un dépôt à découvrir.

Pour mettre à jour :

```bash
/plugin marketplace update max
/plugin install max@max
```

### Codex

Clone le dépôt, puis relie chaque skill au dossier personnel lu par [Codex](https://learn.chatgpt.com/docs/build-skills) :

```bash
git clone https://github.com/maximejolivet/max-coding-agents-skills.git ~/max-coding-agents-skills
mkdir -p ~/.agents/skills
for skill in ~/max-coding-agents-skills/skills/*/; do ln -sfn "${skill%/}" ~/.agents/skills/; done
```

Redémarre Codex, puis tape `/skills` pour les lister ou `$explain` pour en lancer un.

Pour mettre à jour, lance `git -C ~/max-coding-agents-skills pull`, puis relance la boucle `for` si de nouveaux skills sont arrivés.

Max est conçu pour Claude Code et n'a pas encore été validé sur Codex :

- Le garde-fou git n'est pas actif : `git push --force` et les push vers `main` ne sont pas bloqués.
- Les sous-agents `max:<nom>` ne sont pas installés : les relectures se font sans délégation.

## Cycle d'une fonctionnalité

```text
/max:switch feat/mon-sujet   # crée la branche depuis la branche par défaut à jour
/max:dev                     # lit l'existant, implémente par petits pas, vérifie
/max:review                  # rend un verdict classé par gravité
/max:pull-request            # commit ciblé, push, PR en Draft
/max:switch delete           # supprime la branche après le merge
```

## Les skills

### Développer

| Commande | Rôle |
| :-- | :-- |
| `/max:dev` | Développe dans la stack détectée, quelle qu'elle soit, puis renvoie vers la revue. |
| `/max:symfony` | Développe en Symfony (6.4, 7.x, 8.x). |
| `/max:nuxt` | Développe en Nuxt (3 et 4). |
| `/max:react` | Développe en React (18 et 19). |
| `/max:debug` | Trouve la cause racine d'un bug : reproduction, hypothèses, bisect, test de non-régression. |
| `/max:refactor` | Refactorise ou migre par lots annulables, vérifiés un à un. |
| `/max:migrate-db` | Conçoit une migration de base réversible, sans verrou long, avec un plan de retour. |
| `/max:explain` | Explique un dépôt inconnu en lecture seule : carte, flux, commandes, zones à risque. |

### Vérifier

| Commande | Rôle |
| :-- | :-- |
| `/max:review` | Relit un changement avant le merge et donne le correctif exact de chaque constat. |
| `/max:pr-review` | Relit la PR de quelqu'un d'autre et prépare la revue, postée sur accord. |
| `/max:test` | Écrit, lance et diagnostique les tests, avec un mode TDD ou BDD sur demande. |
| `/max:security` | Audite les dépendances, Docker et GitHub Actions, classés selon le risque réel. |
| `/max:perf` | Optimise en mesurant : vrai goulot, un changement à la fois, gain chiffré. |
| `/max:a11y` | Audite et corrige l'accessibilité selon le RGAA et les WCAG. |

### Git et GitHub

| Commande | Rôle |
| :-- | :-- |
| `/max:switch` | Bascule, crée, supprime ou nettoie une branche sans perdre de travail. |
| `/max:commit` | Écrit le message dans la convention du dépôt, sinon au format sémantique. |
| `/max:pull-request` | Ouvre une PR en Draft liée à l'issue. |
| `/max:rebase` | Met une branche à jour avec sauvegarde, `--force-with-lease` sur accord. |
| `/max:issue` | Rédige ou découpe une issue aux critères vérifiables, créée sur accord. |
| `/max:release` | Choisit la version d'après les commits, écrit les notes, tague et publie sur accord. |
| `/max:hotfix` | Corrige en urgence la version déployée, test d'abord, puis backport. |
| `/max:versioning` | Monte la version de ce plugin. Ne vaut que dans ce dépôt. |

### Infrastructure et workflows

| Commande | Rôle |
| :-- | :-- |
| `/max:docker` | Écrit et relit Dockerfile, Compose et Makefile. |
| `/max:kubernetes` | Écrit et débogue manifestes, Kustomize et Helm, en lecture seule sur le cluster par défaut. |
| `/max:ci` | Écrit, accélère et débogue les workflows GitHub Actions. |
| `/max:agent-workflow` | Conçoit un workflow agentique : découpage, orchestration, vérification, garde-fous. |

## Fonctionnement

### Règles communes

Chaque skill lit [`references/regles.md`](references/regles.md) avant sa première étape.

- **Le dépôt décide.** `CLAUDE.md`, `CONTRIBUTING.md`, l'historique git et la CI passent avant les défauts de Max.
- **Rien ne fuit.** Aucun nom de client, secret ou donnée réelle dans un commit, une PR, une issue ou un exemple.
- **Rien d'irréversible sans accord.** Un accord vaut pour une action, pas pour la suivante.

Quand le dépôt ne dit rien, Max écrit commits, PR et issues en anglais, nomme les branches `feat/<slug>` ou `fix/<slug>` et formate les commits en `type(scope): emoji description`.

### Garde-fou git

Un hook `PreToolUse` refuse `git push --force`, `git push -f` et tout push direct vers `main` ou `master`. `--force-with-lease` reste permis. Sans `python3`, le hook laisse tout passer.

### Détection de la stack

`stacks/detect.sh` lit le projet sans rien exécuter ni installer. Le skill charge ensuite les sections utiles de `stacks/<techno>/INDEX.md`.

Symfony, Laravel, Django, Nuxt, Vue, React et Next.js ont leurs règles. Une autre stack passe par les valeurs par défaut de son langage. La procédure est dans [`stacks/DETECT.md`](stacks/DETECT.md).

### Sous-agents

| Agent | Lancé par | Angle |
| :-- | :-- | :-- |
| `correctness-reviewer` | `/max:review` | Demande couverte, cause racine, cas limites, régressions. |
| `security-reviewer` | `/max:review` | Failles applicatives dans le diff. |
| `standards-reviewer` | `/max:review` | Standards, performance, couverture de tests. |
| `frontend-reviewer` | `/max:review`, si le diff touche du front | Hydratation, réactivité, accessibilité, poids du paquet, SEO. |
| `dependencies-auditor` | `/max:security` | Vulnérabilités connues des dépendances. |
| `docker-auditor` | `/max:security`, si Docker est présent | Images, privilèges, secrets, ports. |
| `actions-auditor` | `/max:security`, si des workflows existent | Épinglage, permissions, déclencheurs, injections. |
| `codebase-surveyor` | `/max:dev`, `/max:debug`, `/max:refactor`, `/max:perf`, `/max:explain` | Exploration d'un gros projet. |
| `docs-updater` | Sur demande, dans ce dépôt | Écarts entre la documentation et le code. |

## Structure du dépôt

```text
max-coding-agents-skills/
├── .claude-plugin/
│   ├── marketplace.json           # déclare le marketplace "max" et le plugin "max"
│   └── plugin.json                # manifeste du plugin (nom, version)
├── .github/
│   ├── pull_request_template.md   # modèle de description des pull requests
│   └── workflows/check.yml        # lance tests/check.sh à chaque PR
├── agents/                        # sous-agents en lecture seule
│   ├── correctness-reviewer.md    # /max:review : bugs, cause racine, cas limites
│   ├── security-reviewer.md       # /max:review : failles applicatives dans le diff
│   ├── standards-reviewer.md      # /max:review : standards, performance, couverture de tests
│   ├── frontend-reviewer.md       # /max:review : ajouté si le diff touche du front
│   ├── dependencies-auditor.md    # /max:security : lockfiles, avis, Dependabot
│   ├── docker-auditor.md          # /max:security : images, privilèges, secrets, ports
│   ├── actions-auditor.md         # /max:security : workflows GitHub Actions
│   ├── codebase-surveyor.md       # dev, debug, refactor, perf, explain : exploration d'un gros projet
│   └── docs-updater.md            # sur demande : écarts entre la documentation et le code
├── commands/                      # vide pour l'instant
├── docs/
│   ├── agents.md                  # les sous-agents, quand et comment ils sont lancés
│   └── skill-anatomy.md           # anatomie d'un skill (frontmatter, squelette, règles)
├── hooks/
│   └── hooks.json                 # garde-fou git : enregistre scripts/guard-git.sh
├── references/
│   ├── regles.md                  # règles communes, lues par chaque skill avant sa première étape
│   ├── core-web-vitals-checklist.md # liste de contrôle Core Web Vitals
│   └── rgaa-checklist.md          # liste de contrôle RGAA
├── scripts/
│   ├── guard-git.sh               # hook : bloque git push --force et push direct vers main/master
│   └── reinstall-plugin.sh        # réinstalle le plugin en local
├── skills/
│   ├── dev/SKILL.md               # développement dans la stack détectée
│   ├── symfony/SKILL.md           # développement Symfony
│   ├── nuxt/SKILL.md              # développement Nuxt
│   ├── react/SKILL.md             # développement React
│   ├── debug/SKILL.md             # débogage par la cause racine
│   ├── refactor/SKILL.md          # refactoring et migration par lots
│   ├── migrate-db/SKILL.md        # migrations de base de données sûres
│   ├── explain/SKILL.md           # comprendre un dépôt inconnu, lecture seule
│   ├── review/SKILL.md            # revue d'un changement avant le merge
│   ├── pr-review/SKILL.md         # revue de la PR de quelqu'un d'autre
│   ├── test/SKILL.md              # écriture, lancement et diagnostic des tests
│   ├── security/SKILL.md          # audit des dépendances et de l'infrastructure
│   ├── perf/SKILL.md              # optimisation mesurée, avant/après
│   ├── a11y/SKILL.md              # accessibilité RGAA / WCAG
│   ├── switch/SKILL.md            # bascule, création et nettoyage de branches
│   ├── commit/SKILL.md            # messages de commit
│   ├── pull-request/SKILL.md      # commit ciblé, push, PR en Draft
│   ├── rebase/SKILL.md            # rebase et conflits en sécurité
│   ├── issue/SKILL.md             # rédige ou découpe une issue GitHub
│   ├── release/SKILL.md           # version, notes, tag et GitHub Release sur accord
│   ├── hotfix/SKILL.md            # correctif urgent sur la version en production
│   ├── versioning/SKILL.md        # incrémente et aligne la version du plugin
│   ├── docker/SKILL.md            # Dockerfile, Compose, Makefile
│   ├── kubernetes/SKILL.md        # manifestes, Kustomize, Helm
│   ├── ci/SKILL.md                # workflows GitHub Actions
│   └── agent-workflow/SKILL.md    # conception d'un workflow agentique
├── stacks/                        # règles de chaque techno, chargées à la demande
│   ├── DETECT.md                  # procédure de détection et valeurs par défaut par langage
│   ├── detect.sh                  # script de détection (lecture seule)
│   ├── django/INDEX.md
│   ├── laravel/INDEX.md
│   ├── nextjs/INDEX.md
│   ├── nuxt/INDEX.md
│   ├── react/INDEX.md
│   ├── symfony/INDEX.md
│   └── vue/INDEX.md
├── tests/
│   ├── check.sh                   # contrôle de cohérence du plugin
│   └── SCENARIOS.md               # scénarios de vérification manuelle
├── CLAUDE.md                      # instructions du dépôt pour Claude Code
├── CONTRIBUTING.md                # flux de contribution, fichiers à modifier et vérifications
├── LICENSE
├── README.md
└── renovate.json                  # configuration Renovate
```

## Contribuer

Lance `sh tests/check.sh` avant chaque commit. Le script tourne aussi en CI à chaque PR.

- [CONTRIBUTING.md](CONTRIBUTING.md) : flux de contribution et fichiers à modifier.
- [Anatomie d'un skill](docs/skill-anatomy.md) : format et règles d'écriture.
- [Sous-agents](docs/agents.md) : format et usages d'un agent.
- [Scénarios manuels](tests/SCENARIOS.md) : à rejouer quand le comportement d'un skill change.

## Licence

[MIT](LICENSE) © 2026 Maxime
