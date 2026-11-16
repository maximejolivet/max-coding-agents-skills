# Contribuer à Max

Bienvenue. Cette page donne l'essentiel pour proposer un changement ; pour une visite complète du dépôt, passe par [docs/developer-onboarding.md](docs/developer-onboarding.md).

## Principes

- Tout le contenu est rédigé en français ; seuls les noms techniques restent tels quels.
- Un skill transverse n'écrit jamais une techno en toutes lettres : ce savoir appartient à `stacks/`.
- Les règles communes à une techno (`core`) sont écrites à un seul endroit.
- La cible est GitHub : CLI `gh` et GitHub Actions.

## Déroulé d'une contribution

1. Ouvre une branche `feat/<slug>` ou `fix/<slug>` à partir de `main` à jour (`/max:switch`).
2. Fais ton changement, puis exécute `sh tests/check.sh`.
3. Commite en `type(scope): emoji description`, scope toujours renseigné, par exemple `feat(review): ✨ …` (`/max:commit` s'en charge).
4. Monte la version de 0.0.1 (`/max:versioning`).
5. Ouvre une PR en Draft vers `main` avec `Closes #n` (`/max:pull-request`).
6. Une fois mergé, nettoie tes branches locales (`/max:switch`).

Aucun push direct sur `main`.

## Où intervenir

| Objectif            | Fichiers à modifier                                       | À mettre à jour en même temps                               |
| :------------------ | :-------------------------------------------------------- | :---------------------------------------------------------- |
| Nouveau skill       | `skills/<nom>/SKILL.md`                                   | Tableau du `README.md`, `description` de `marketplace.json` |
| Nouvel agent        | `agents/<nom>.md`, et le skill qui l'appelle              | `docs/agents.md`, `docs/agents-tools.md`, `README.md`       |
| Nouvelle techno     | `stacks/detect.sh`, `stacks/<techno>/INDEX.md`            | Rien d'autre : les skills restent inchangés                 |
| Nouvelle version    | `version` dans `marketplace.json` **et** `plugin.json`    | Badge de version du `README.md`                             |

Détails de format : [skill-anatomy](docs/skill-anatomy.md), [agents](docs/agents.md), [stacks](docs/stacks.md).

## Contrôles

```bash
sh tests/check.sh
```

Le script valide le frontmatter, les références `max:<nom>` et `stacks/<id>/INDEX.md`, l'égalité des versions et la détection de stack. La CI le rejoue sur chaque PR, mais lance-le avant de committer.

Si ton changement modifie sensiblement le comportement d'un skill ou d'un agent, joue aussi les scénarios correspondants de `tests/SCENARIOS.md` dans une vraie session.

## Essayer en local

```bash
claude --plugin-dir ~/Sites/claude-skills-max
/reload-plugins    # recharge après chaque modification
```
