# CLAUDE.md

Collection de skills Claude Code maison (namespace `max`, invocables `/max:<skill>`), distribuée comme plugin via un marketplace. Le contenu est en français, sauf les noms techniques.

## Structure

- `.claude-plugin/marketplace.json` : déclare le marketplace `max` et le plugin `max`.
- `.claude-plugin/plugin.json` : manifeste du plugin `max` (utilisé pour le dev local via `--plugin-dir`).
- `skills/<nom>/SKILL.md` : un skill par dossier. Frontmatter obligatoire (`name`, `description`), puis le corps.
- `stacks/<techno>/` : spécificités par technologie, chargées à la demande par les skills génériques.
  - Forme 1 : un fichier unique `INDEX.md` sectionné.
  - Forme 2 : un dossier avec `INDEX.md` (dispatcher) + `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`.
- `stacks/DETECT.md` et `stacks/detect.sh` : détection de la stack, commune à tous les skills (`detect.sh` est en lecture seule). Une nouvelle techno s'ajoute dans le script et dans `stacks/<techno>/INDEX.md`, sans toucher aux skills.
- `agents/<nom>.md` : sous-agents en lecture seule, lancés en parallèle par les skills (le skill orchestre, un agent n'en lance pas d'autres). `correctness-reviewer`, `security-reviewer`, `standards-reviewer` et `frontend-reviewer` (conditionnel) pour `/max:review` ; `dependencies-auditor`, `docker-auditor`, `actions-auditor` pour `/max:security` ; `codebase-surveyor` pour `/max:symfony`, `/max:nuxt`, `/max:react` sur un gros projet. Invoqués sous `max:<nom>`.

## Skills

| Skill | Rôle |
| --- | --- |
| `review` | Review d'un diff avant merge, stack-agnostique, verdict ordonné par sévérité. |
| `pull-request` | Prépare une PR GitHub en Draft (commit ciblé, push, `gh pr create`). |
| `pr-review` | Review côté reviewer d'une PR GitHub existante, stack-agnostique (`gh`, checks Actions). |
| `react` | Développement React (18 et 19) : point d'entrée qui charge `stacks/react/` (dev), puis renvoie vers `review`. |
| `nuxt` | Développement Nuxt (3 et 4) : point d'entrée qui charge `stacks/nuxt/` (dev), puis renvoie vers `review`. |
| `symfony` | Développement Symfony : point d'entrée qui charge `stacks/symfony/` (dev), puis renvoie vers `review`. |
| `test` | Écrire, lancer et diagnostiquer les tests, stack-agnostique (charge la nature `test` de `stacks/`). |
| `docker` | Dockerfile, Compose, Makefile et CI GitHub Actions (builds reproductibles, images minimales, sécurité, DX). |
| `kubernetes` | Manifestes, Kustomize, Helm et déploiement GitHub Actions ; lecture seule par défaut sur le cluster. |
| `security` | Audit dépendances, infra et workflows GitHub Actions, stack-agnostique. |
| `commit` | Messages de commit sémantiques (`type(scope): emoji description`), utilisés par `pull-request`. |

Plateforme cible : GitHub (CLI `gh`, GitHub Actions). Cycle de vie d'une branche : partir de `main` à jour, `feat/<slug>` ou `fix/<slug>`, commits sémantiques (`feat(scope): ✨ …`, skill `commit`), PR en Draft vers `main`, nettoyage local après le merge.

Les skills génériques (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) ne codent aucune techno en dur. Ils détectent la stack avec `stacks/DETECT.md` puis chargent `stacks/<techno>/INDEX.md` avec la nature voulue (`core` + `dev` | `review` | `security` | `test` | `deploy`).

## Conventions

- Le `core` d'une techno n'existe qu'une seule fois. Ne pas le dupliquer entre `review`, `security` et `pr-review`.
- Ne coder aucune techno en dur dans les skills génériques.
- Un nouveau skill : créer `skills/<nom>/SKILL.md`, ajouter une ligne dans le tableau du `README.md`, et l'ajouter à la `description` de `marketplace.json`.
- Garder `version` identique dans `marketplace.json` et `plugin.json`. Les deux doivent rester alignés.

## Développement local

```bash
claude --plugin-dir ~/Sites/claude-skills-max   # lit les skills en place
/reload-plugins                                 # applique les modifs sans redémarrer
```

Pas de build. Deux niveaux de vérification :

- `sh tests/check.sh` : contrôle de cohérence (frontmatter des skills et agents, références `max:<nom>` et `stacks/<id>/INDEX.md`, versions alignées, détection de stack sur des projets factices). Il tourne aussi en CI (`.github/workflows/check.yml`). À lancer avant chaque commit.
- `tests/SCENARIOS.md` : scénarios manuels pour vérifier le comportement des skills et des agents dans une vraie session (`claude --plugin-dir …`).

Un nouvel agent ou skill doit passer `tests/check.sh` ; un changement de comportement important se vérifie avec les scénarios concernés.

## Points ouverts

- Les versions sont à `0.0.0`.
