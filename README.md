<div align="center">

# Max

**Des skills Claude Code pour relire, publier et sécuriser son code sur GitHub.**

Un plugin Claude Code, distribué par son propre marketplace.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![Namespace](https://img.shields.io/badge/namespace-%2Fmax%3A-blue)](#les-skills)
[![Version](https://img.shields.io/badge/version-0.0.0-lightgrey)](.claude-plugin/plugin.json)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)
[![Dernier commit](https://img.shields.io/github/last-commit/maximejolivet/claude-skills-max)](https://github.com/maximejolivet/claude-skills-max/commits/main)
[![Stars](https://img.shields.io/github/stars/maximejolivet/claude-skills-max?style=flat)](https://github.com/maximejolivet/claude-skills-max/stargazers)

![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![Symfony](https://img.shields.io/badge/Symfony-000000?logo=symfony&logoColor=white)
![Nuxt](https://img.shields.io/badge/Nuxt-00DC82?logo=nuxt&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)

</div>

## En bref

Le plugin `max` regroupe quatre skills qui couvrent la vie d'un changement : on le relit, on ouvre la pull request, on relit celle des autres, et on vérifie la sécurité du projet. Chaque skill s'appelle avec le préfixe `/max:`.

|                 |                                                      |
| :-------------- | :--------------------------------------------------- |
| **Plugin**      | `max`                                                |
| **Auteur**      | Maxime                                               |
| **Code source** | <https://github.com/maximejolivet/claude-skills-max> |

**Sommaire** : [Les skills](#les-skills) · [Installer](#installer) · [Mettre à jour](#mettre-à-jour) · [Utiliser](#utiliser) · [Organisation du dépôt](#organisation-du-dépôt) · [Contribuer](#contribuer) · [Licence](#licence)

## Les skills

| Skill           | Commande             | Ce qu'il fait                                                                                                                                                                                                                                                   |
| :-------------- | :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `review`        | `/max:review`        | Relit un diff avant le merge et rend un verdict classé par gravité : bugs, sécurité, performance, standards, tests. Sur un gros diff, confie la relecture à des sous-agents en parallèle (correction, sécurité, standards, et front-end si la stack en a un). S'adapte à la techno du projet grâce au dossier `stacks/`, et tient compte des checks GitHub Actions de la PR.                              |
| `pull-request` | `/max:pull-request` | Prépare la pull request : un commit ciblé, le push de la branche, puis `gh pr create` en brouillon, avec une description qui renvoie à l'issue (`Closes #n`).                                                                                                   |
| `pr-review`  | `/max:pr-review`  | Relit la PR de quelqu'un d'autre : contenu, forme, langue, standards et checks Actions. Lit l'issue liée, rédige une review (note globale et commentaires sur les lignes) et conseille d'approuver ou de demander des changements.                              |
| `security`      | `/max:security`      | Audite les dépendances, l'infrastructure et les workflows : `composer audit`, `npm audit`, alertes Dependabot, configuration Docker, GitHub Actions. Quand plusieurs écosystèmes sont présents, un sous-agent par domaine travaille en parallèle. Les failles sont classées selon le risque réel, et chacune vient avec son correctif ou sa marche à suivre. |
| `symfony` | `/max:symfony` | Guide le développement Symfony (6.4, 7.x, 8.x) : lit le code existant, propose l'approche, implémente services, contrôleurs, Doctrine, formulaires, Messenger, écrit les tests, puis renvoie vers `/max:review`. Charge `stacks/symfony/`. |
| `react` | `/max:react` | Guide le développement React (18 et 19) : lit le code existant, propose l'approche, implémente composants, hooks, état, effets, données serveur et formulaires, vérifie accessibilité et performances, puis renvoie vers `/max:review`. Charge `stacks/react/`. |
| `nuxt` | `/max:nuxt` | Guide le développement Nuxt (3 et 4) : lit le code existant, propose l'approche, implémente pages, composants, composables, routes serveur Nitro, gère le chargement de données et l'hydratation, puis renvoie vers `/max:review`. Charge `stacks/nuxt/`. |
| `test` | `/max:test` | Écrit, lance et diagnostique les tests (unitaires, intégration, fonctionnels) : test de non-régression d'abord pour un bug, tests déterministes et isolés, analyse des échecs et des tests instables, intégration à GitHub Actions. Charge la section `test` de `stacks/<techno>/`. |
| `docker` | `/max:docker` | Écrit et relit Dockerfile, Compose, Makefile et CI GitHub Actions : builds reproductibles, images minimales (multi-stage), utilisateur non root, secrets hors des couches, healthchecks, build et publication sur GHCR avec actions épinglées. |
| `kubernetes` | `/max:kubernetes` | Écrit, relit et débogue des manifestes Kubernetes, du Kustomize et des charts Helm : probes, ressources, `securityContext`, NetworkPolicy, secrets, déploiement via GitHub Actions. Lecture seule par défaut : jamais d'`apply` ni de `delete` sans accord. |
| `commit` | `/max:commit` | Rédige les messages de commit au format sémantique `type(scope): emoji description` (feat, fix, refactor, perf, security…), avec scope obligatoire, trailers (`Refs`, `Closes`, `Verified-by`) et changements cassants. Sert de base aux commits de `/max:pull-request`. |

## Installer

Le marketplace se déclare une fois, puis on installe le plugin qu'il contient.

**Depuis GitHub (recommandé)**

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

**Depuis un clone local**

```bash
git clone git@github.com:maximejolivet/claude-skills-max.git
```

```bash
/plugin marketplace add ~/Sites/claude-skills-max
/plugin install max@max
```

Les skills sont utilisables dès la fin de l'installation. Tape `/max:` pour les voir tous.

## Mettre à jour

```bash
# Recharge la définition du marketplace depuis sa source (GitHub ou dossier local)
/plugin marketplace update max

# Réinstalle le plugin pour obtenir la dernière version des skills
/plugin install max@max
```

Avec un clone local, fais d'abord un `git pull`, puis `/plugin marketplace update max`.

## Utiliser

Le cycle d'une fonctionnalité, de la branche au nettoyage :

```bash
git checkout main && git pull origin main     # partir de main à jour
git checkout -b feat/ma-nouvelle-feature      # une branche par fonctionnalité (feat/…, fix/…)
# … développer, puis committer : feat(scope): ✨ add feature x  (cf. /max:commit)
```

```
/max:review       # relit le diff et donne un verdict classé par gravité
/max:pull-request # pousse la branche et ouvre la pull request en brouillon vers main
```

Une fois la PR fusionnée sur GitHub, on resynchronise le local :

```bash
git checkout main && git pull && git fetch -p && git branch -d feat/ma-nouvelle-feature
```

`/max:pull-request` rappelle ces étapes et ne pousse jamais sur `main`.

Pour relire la PR d'un collègue, lance `/max:pr-review` avec son URL ou son numéro : le skill lit l'issue liée et les checks GitHub Actions, puis prépare la review. `/max:security` s'utilise à part, quand tu veux auditer un projet.

Les skills `pull-request` et `pr-review` passent par la CLI [`gh`](https://cli.github.com). Installe-la et connecte-toi avec `gh auth login` avant de les utiliser.

## Organisation du dépôt

```
claude-skills-max/
├── .claude-plugin/
│   ├── marketplace.json     # déclare le marketplace "max" et le plugin "max"
│   └── plugin.json          # manifeste du plugin (nom, version), lu en développement local
├── .github/
│   ├── pull_request_template.md   # modèle de description des pull requests
│   └── workflows/check.yml        # lance tests/check.sh à chaque PR
├── tests/
│   ├── check.sh             # contrôle de cohérence du plugin
│   └── SCENARIOS.md         # scénarios de vérification manuelle
├── agents/                  # sous-agents lancés en parallèle par /max:review et /max:security
│   ├── correctness-reviewer.md
│   ├── security-reviewer.md
│   ├── standards-reviewer.md
│   ├── frontend-reviewer.md      # ajouté à /max:review si la stack a un front
│   ├── codebase-surveyor.md      # explore le code pour les skills de développement
│   ├── dependencies-auditor.md   # utilisés par /max:security
│   ├── docker-auditor.md
│   └── actions-auditor.md
├── stacks/                  # connaissances propres à chaque techno, chargées à la demande
│   ├── DETECT.md            # procédure commune de détection + valeurs par défaut par langage
│   ├── detect.sh            # script de détection (lecture seule)
│   ├── nuxt/
│   │   └── INDEX.md         # Forme 1 : un seul fichier découpé en sections
│   ├── react/
│   │   └── INDEX.md         # Forme 1 : un seul fichier découpé en sections
│   └── symfony/
│       └── INDEX.md         # Forme 1 : un seul fichier découpé en sections
└── skills/
    ├── review/SKILL.md      # détecte la stack, puis charge stacks/<x>/INDEX.md (review)
    ├── pull-request/SKILL.md
    ├── pr-review/SKILL.md
    ├── commit/SKILL.md
    ├── react/SKILL.md       # point d'entrée de développement : charge stacks/react/INDEX.md (dev)
    ├── nuxt/SKILL.md        # point d'entrée de développement : charge stacks/nuxt/INDEX.md (dev)
    ├── symfony/SKILL.md     # point d'entrée de développement : charge stacks/symfony/INDEX.md (dev)
    ├── test/SKILL.md        # générique : détecte la stack → charge stacks/<x>/INDEX.md (test)
    ├── docker/SKILL.md
    ├── kubernetes/SKILL.md
    └── security/SKILL.md    # détecte la stack, puis charge stacks/<x>/INDEX.md (security)
```

### Détection de la stack

Tous les skills qui s'adaptent à la techno suivent la même procédure, décrite dans `stacks/DETECT.md`, et s'appuient sur le script `stacks/detect.sh`. Il reconnaît à partir des fichiers du projet les langages, gestionnaires de paquets, frameworks (Symfony, Laravel, Drupal, WordPress, Vue, Nuxt, React, Next.js, Angular, Django, Rails…), outils de test, Docker, Kubernetes et GitHub Actions, sans rien lancer ni installer. Une stack sans ressource dans `stacks/` fonctionne quand même, avec des valeurs par défaut par langage ; ajouter une stack ne demande aucune modification des skills.

### Les skills ne connaissent aucune techno

`review`, `security`, `pr-review`, `test`, `docker` et `kubernetes` restent génériques : aucune techno n'y est écrite en dur. Ils repèrent la stack du projet, puis ouvrent `stacks/<techno>/INDEX.md` en indiquant ce dont ils ont besoin (`core` avec `dev`, `review`, `security`, `test` ou `deploy`). Un dossier de techno prend l'une de ces deux formes, selon son poids :

- **Forme 1** : un fichier unique, découpé en sections.
- **Forme 2** : un dossier avec un fichier par usage (`CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`), quand une section devient trop longue.

Dans les deux cas, le point d'entrée reste `stacks/<techno>/INDEX.md` : les skills n'ont pas à savoir quelle forme est utilisée. Le `core` d'une techno n'est écrit qu'une fois et n'est jamais recopié dans `review`, `security` ou `pr-review`. Le lancement des outils suit toujours le même ordre : `make`, puis `docker compose`.

## Contribution

**Ajouter un skill.** Crée `skills/<nom>/SKILL.md` avec un en-tête (`name` et `description`), puis le contenu. Ajoute une ligne au tableau des skills ci-dessus et cite-le dans la `description` de `.claude-plugin/marketplace.json`. Pour une nouvelle version, change `version` dans `marketplace.json` **et** dans `plugin.json` (les deux doivent rester identiques), ainsi que le badge en haut de ce fichier.

**Ajouter une techno.** Crée `stacks/<techno>/INDEX.md`. Commence par la Forme 1, avec les sections `## core`, `## dev`, `## review`, `## security`, `## test` et `## deploy` (seulement celles utiles). Passe à la Forme 2 seulement quand une section devient trop longue. Écris le `core` une seule fois et ne mets aucune techno en dur dans les skills génériques.

**Vérifier avant de committer.** `sh tests/check.sh` contrôle la cohérence du plugin (frontmatter, références, versions, détection de stack) ; il tourne aussi en CI. Pour le comportement réel des skills et des agents, suivre les scénarios de `tests/SCENARIOS.md` dans une session.

**Tester en local.** Lance Claude Code en lui indiquant ton clone : les skills sont lus sur place, sans réinstallation.

```bash
claude --plugin-dir ~/Sites/claude-skills-max   # lit les skills directement dans le dossier
/reload-plugins                                 # prend en compte tes modifications sans redémarrer
```

Passer par `/plugin marketplace update max` puis `/plugin install max@max` copie le plugin depuis sa source : c'est plus long, donc à réserver à la vérification d'une version déjà installée.

## Licence

[MIT](LICENSE) © 2026 Maxime
