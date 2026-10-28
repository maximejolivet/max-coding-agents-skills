# Contribuer

Merci de contribuer à Max. Ce fichier résume le flux ; la visite guidée du dépôt est dans [docs/developer-onboarding.md](docs/developer-onboarding.md).

## Avant de commencer

- Les skills et agents sont en français, sauf les noms techniques.
- Un skill générique ne contient aucune techno en dur : les spécificités vont dans `stacks/`.
- Le `core` d'une techno n'est écrit qu'une fois.
- Plateforme cible : GitHub (`gh`, GitHub Actions).

## Flux

1. Créer une branche `feat/<slug>` ou `fix/<slug>` depuis `main` à jour (`/max:switch`).
2. Modifier, puis lancer `sh tests/check.sh`.
3. Committer au format `type(scope): emoji description`, scope obligatoire (`feat(review): ✨ …`). Le skill `/max:commit` le rédige.
4. Ouvrir une PR en Draft vers `main` (`/max:pull-request`), avec le lien vers l'issue (`Closes #n`).
5. Incrémenter la version de `0.0.1` (`/max:versioning`).
6. Après le merge : nettoyer les branches mergées (`/max:switch`).

Ne pas pousser directement sur `main`.

## Ce que je modifie, ce que je mets à jour

| Je veux…            | Je touche                                                   | Je mets aussi à jour                                        |
| :------------------ | :---------------------------------------------------------- | :---------------------------------------------------------- |
| Ajouter un skill    | `skills/<nom>/SKILL.md` (frontmatter `name`, `description`) | Tableau du `README.md`, `description` de `marketplace.json` |
| Ajouter un agent    | `agents/<nom>.md` et le skill qui le lance                  | `docs/agents.md`, `README.md`                               |
| Ajouter une techno  | `stacks/detect.sh` et `stacks/<techno>/INDEX.md`            | Aucun skill ne change                                       |
| Publier une version | `version` dans `marketplace.json` **et** `plugin.json`      | Le badge de version du `README.md`                          |

Formats : [docs/skill-anatomy.md](docs/skill-anatomy.md), [docs/agents.md](docs/agents.md), [docs/stacks.md](docs/stacks.md).

## Vérifier

```bash
sh tests/check.sh
```

Contrôle le frontmatter des skills et agents, les références `max:<nom>` et `stacks/<id>/INDEX.md`, l'alignement des versions et la détection de stack. Il tourne aussi en CI sur chaque PR : à lancer avant chaque commit.

Pour un changement de comportement important d'un skill ou d'un agent, suivre les scénarios concernés de `tests/SCENARIOS.md` dans une vraie session.

## Tester en local

```bash
claude --plugin-dir ~/Sites/claude-skills-max
/reload-plugins   # applique les modifs sans redémarrer
```
