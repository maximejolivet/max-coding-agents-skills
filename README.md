<div align="center">

<img src="https://www.maxime.bzh/maxime-black.svg" alt="Maxime" height="80" align="middle">
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://github.com/maximejolivet"><img src="https://wsrv.nl/?url=github.com/maximejolivet.png&w=160&h=160&fit=cover&mask=circle" alt="maximejolivet" width="80" height="80" align="middle"></a>

<br>

# Max

**Des skills Claude Code pour développer, relire, tester, publier et sécuriser son code sur GitHub.**

Distribuée comme plugin `max` via son propre marketplace ; chaque skill s'appelle avec le préfixe `/max:`.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-0.0.0-lightgrey)](.claude-plugin/plugin.json)
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

## À propos

Max est un plugin [Claude Code](https://claude.com/claude-code) qui regroupe onze skills pour suivre un changement de bout en bout, de la première ligne de code au merge : développer, committer, relire, tester, ouvrir la pull request, relire celle des autres et auditer la sécurité du projet. Il est pensé pour des projets hébergés sur GitHub (CLI `gh`, GitHub Actions).

- **Un cycle complet.** Du développement à la revue, chaque étape a son skill et renvoie vers la suivante : `/max:symfony`, `/max:nuxt` ou `/max:react` finissent par `/max:review`, qui prépare `/max:pull-request`.
- **Adapté à ta techno.** Les skills génériques détectent la stack du projet (langage, framework, outils de test, Docker, Kubernetes, Actions) puis chargent les règles de la techno concernée. Symfony, Nuxt et React sont fournis ; une stack inconnue fonctionne avec des valeurs par défaut.
- **Des relectures en parallèle.** Sur un gros diff, `/max:review` confie la correction, la sécurité, les standards et le front à des sous-agents en lecture seule ; `/max:security` fait de même par domaine (dépendances, Docker, Actions).
- **Prudent par défaut.** Les PR sont ouvertes en Draft, jamais de push sur `main`, une review n'est postée que sur accord explicite, et le cluster Kubernetes reste en lecture seule.
- **Vérifié.** Un contrôle de cohérence (`tests/check.sh`) tourne en CI à chaque PR, et des scénarios manuels couvrent le comportement réel des skills.

Tout est en français, sauf les noms techniques, et se distribue via son propre marketplace : une installation, puis chaque skill s'appelle avec le préfixe `/max:`.

## Installation

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

Depuis un clone local : `/plugin marketplace add ~/Sites/claude-skills-max`, puis la même commande `install`.

Pour mettre à jour : `/plugin marketplace update max`, puis `/plugin install max@max`.

Les skills `pull-request` et `pr-review` passent par la CLI [`gh`](https://cli.github.com) : installe-la et connecte-toi avec `gh auth login`.

## Les skills

| Commande            | Rôle                                                                                                                |
| :------------------ | :------------------------------------------------------------------------------------------------------------------ |
| `/max:review`       | Relit un diff avant le merge et rend un verdict classé par gravité (bugs, sécurité, performance, standards, tests). |
| `/max:pull-request` | Prépare une PR en Draft : commit ciblé, push, `gh pr create` avec lien vers l'issue.                                |
| `/max:pr-review`    | Relit la PR de quelqu'un d'autre (issue liée, checks Actions) et prépare la review ; ne poste que sur accord.       |
| `/max:commit`       | Rédige des messages de commit sémantiques : `type(scope): emoji description`.                                       |
| `/max:test`         | Écrit, lance et diagnostique les tests ; test de non-régression d'abord pour un bug.                                |
| `/max:security`     | Audite dépendances, Docker et workflows GitHub Actions ; classe les failles selon le risque réel.                   |
| `/max:docker`       | Dockerfile, Compose, Makefile et CI : builds reproductibles, images minimales, sécurité.                            |
| `/max:kubernetes`   | Manifestes, Kustomize, Helm et déploiement Actions ; lecture seule par défaut sur le cluster.                       |
| `/max:symfony`      | Développement Symfony (6.4, 7.x, 8.x), puis renvoi vers `/max:review`.                                              |
| `/max:nuxt`         | Développement Nuxt (3 et 4), puis renvoi vers `/max:review`.                                                        |
| `/max:react`        | Développement React (18 et 19), puis renvoi vers `/max:review`.                                                     |

## Cycle d'une fonctionnalité

```bash
git checkout main && git pull origin main   # partir de main à jour
git checkout -b feat/ma-feature             # feat/<slug> ou fix/<slug>
# développer, puis committer (/max:commit)
```

```text
/max:review         # verdict avant la PR
/max:pull-request   # push + PR en Draft vers main
```

Après le merge : `git checkout main && git pull && git fetch -p && git branch -d feat/ma-feature`.

`/max:pull-request` ne pousse jamais sur `main`.

## Fonctionnement

### Détection de la stack

Les skills génériques (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) ne codent aucune techno en dur. Ils détectent la stack avec `stacks/detect.sh` (lecture seule, rien n'est lancé ni installé) selon la procédure de `stacks/DETECT.md`, puis chargent `stacks/<techno>/INDEX.md` avec la nature voulue : `core` + `dev`, `review`, `security`, `test` ou `deploy`. Une stack sans ressource dans `stacks/` fonctionne avec des valeurs par défaut par langage.

Un dossier de techno prend une de ces formes :

- **Forme 1** : un seul `INDEX.md`, découpé en sections.
- **Forme 2** : `INDEX.md` (dispatcher) + `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`.

Stacks fournies : Symfony, Nuxt, React.

### Sous-agents

Les skills orchestrent des sous-agents en lecture seule, lancés en parallèle (`agents/`, invoqués sous `max:<nom>`) :

- `/max:review` : `correctness-reviewer`, `security-reviewer`, `standards-reviewer`, et `frontend-reviewer` si la stack a un front.
- `/max:security` : `dependencies-auditor`, `docker-auditor`, `actions-auditor`.
- `/max:symfony`, `/max:nuxt`, `/max:react` : `codebase-surveyor` sur un gros projet.

## Structure du dépôt

```text
claude-skills-max/
├── .claude-plugin/
│   ├── marketplace.json           # déclare le marketplace "max" et le plugin "max"
│   └── plugin.json                # manifeste du plugin (nom, version), lu en développement local
├── .github/
│   ├── pull_request_template.md   # modèle de description des pull requests
│   └── workflows/check.yml        # lance tests/check.sh à chaque PR
├── tests/
│   ├── check.sh                   # contrôle de cohérence du plugin
│   └── SCENARIOS.md               # scénarios de vérification manuelle
├── agents/                        # sous-agents en lecture seule, lancés en parallèle par les skills
│   ├── correctness-reviewer.md    # /max:review : bugs, cause racine, cas limites
│   ├── security-reviewer.md       # /max:review : failles applicatives dans le diff
│   ├── standards-reviewer.md      # /max:review : standards, performance, couverture de tests
│   ├── frontend-reviewer.md       # /max:review : ajouté si la stack a un front
│   ├── dependencies-auditor.md    # /max:security : lockfiles, avis, Dependabot
│   ├── docker-auditor.md          # /max:security : images, privilèges, secrets, ports
│   ├── actions-auditor.md         # /max:security : workflows GitHub Actions
│   └── codebase-surveyor.md       # symfony, nuxt, react : exploration d'un gros projet
├── stacks/                        # connaissances propres à chaque techno, chargées à la demande
│   ├── DETECT.md                  # procédure commune de détection + valeurs par défaut par langage
│   ├── detect.sh                  # script de détection (lecture seule)
│   ├── nuxt/
│   │   └── INDEX.md               # Forme 1 : un seul fichier découpé en sections
│   ├── react/
│   │   └── INDEX.md               # Forme 1 : un seul fichier découpé en sections
│   └── symfony/
│       └── INDEX.md               # Forme 1 : un seul fichier découpé en sections
├── skills/
│   ├── review/SKILL.md            # détecte la stack, puis charge stacks/<x>/INDEX.md (review)
│   ├── pull-request/SKILL.md      # commit ciblé, push, PR en Draft
│   ├── pr-review/SKILL.md         # relit une PR existante côté reviewer
│   ├── commit/SKILL.md            # messages de commit sémantiques
│   ├── test/SKILL.md              # générique : détecte la stack → stacks/<x>/INDEX.md (test)
│   ├── security/SKILL.md          # détecte la stack, puis charge stacks/<x>/INDEX.md (security)
│   ├── docker/SKILL.md            # Dockerfile, Compose, Makefile, CI
│   ├── kubernetes/SKILL.md        # manifestes, Kustomize, Helm
│   ├── symfony/SKILL.md           # point d'entrée de développement : charge stacks/symfony/INDEX.md (dev)
│   ├── nuxt/SKILL.md              # point d'entrée de développement : charge stacks/nuxt/INDEX.md (dev)
│   └── react/SKILL.md             # point d'entrée de développement : charge stacks/react/INDEX.md (dev)
├── CLAUDE.md                      # instructions du dépôt pour Claude Code
├── README.md
└── LICENSE
```

### Ce que contrôle `tests/check.sh`

| Contrôle                | Détail                                                                         |
| :---------------------- | :----------------------------------------------------------------------------- |
| Frontmatter             | `name` et `description` présents dans chaque skill et chaque agent.            |
| Références              | Les `max:<nom>` et `stacks/<id>/INDEX.md` cités existent bien.                 |
| Versions                | `version` identique dans `marketplace.json` et `plugin.json`.                  |
| Détection de la stack   | `detect.sh` testé sur des projets factices.                                    |

### Qui charge quoi

| Élément          | Chargé par                                         | Quand                                          |
| :--------------- | :------------------------------------------------- | :--------------------------------------------- |
| `SKILL.md`       | Claude Code                                        | À l'appel de `/max:<skill>`.                   |
| `stacks/DETECT.md` | `review`, `security`, `pr-review`, `test`, `docker`, `kubernetes` | Au début, pour repérer la stack.   |
| `stacks/<x>/INDEX.md` | Les skills génériques et `symfony`, `nuxt`, `react` | Selon la nature voulue (`core` + `dev`, `review`, `security`, `test`, `deploy`). |
| `agents/*.md`    | Le skill orchestrateur                             | En parallèle, sur un gros diff ou plusieurs domaines. |

## Contributions

- **Nouveau skill** : crée `skills/<nom>/SKILL.md` (frontmatter `name` et `description`), ajoute une ligne au tableau ci-dessus et cite-le dans la `description` de `marketplace.json`.
- **Nouvelle techno** : ajoute-la dans `stacks/detect.sh` et crée `stacks/<techno>/INDEX.md`. Le `core` n'est écrit qu'une fois ; les skills ne sont pas modifiés.
- **Version** : garde `version` identique dans `marketplace.json` et `plugin.json`, ainsi que le badge de ce fichier.

Avant chaque commit, lance `sh tests/check.sh` (frontmatter, références, versions, détection de stack ; il tourne aussi en CI). Pour le comportement réel des skills et agents, suis `tests/SCENARIOS.md`.

Pour tester en local sans réinstaller :

```bash
claude --plugin-dir ~/Sites/claude-skills-max
/reload-plugins   # applique les modifs sans redémarrer
```

## Licence

[MIT](LICENSE) © 2026 Maxime
