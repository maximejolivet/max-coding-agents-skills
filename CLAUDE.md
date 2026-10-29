# CLAUDE.md

Plugin Claude Code `max` (skills invocables `/max:<skill>`), distribué via un marketplace GitHub. Le contenu est en français, sauf les noms techniques. La liste des skills et leur rôle sont dans `README.md`.

## Structure

- `.claude-plugin/marketplace.json` : déclare le marketplace et le plugin `max`.
- `.claude-plugin/plugin.json` : manifeste du plugin (dev local via `--plugin-dir`).
- `skills/<nom>/SKILL.md` : un skill par dossier. Frontmatter obligatoire (`name`, `description`), puis le corps.
- `agents/<nom>.md` : sous-agents en lecture seule, invoqués sous `max:<nom>`. Le skill orchestre et les lance en parallèle ; un agent n'en lance jamais d'autres.
- `stacks/DETECT.md` + `stacks/detect.sh` : détection de la stack, commune à tous les skills (`detect.sh` est en lecture seule).
- `stacks/<techno>/` : spécificités par technologie, chargées à la demande.
  - Forme 1 : un `INDEX.md` sectionné.
  - Forme 2 : `INDEX.md` (dispatcher) + `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`.
- `tests/check.sh` (cohérence) et `tests/SCENARIOS.md` (scénarios manuels).

## Conventions

- Les skills génériques (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) ne codent aucune techno en dur : ils détectent la stack, puis chargent `stacks/<techno>/INDEX.md` avec la nature voulue (`core` + `dev` | `review` | `security` | `test` | `deploy`).
- Le `core` d'une techno n'existe qu'une fois. Ne pas le dupliquer entre `review`, `security` et `pr-review`.
- Nouvelle techno : l'ajouter dans `detect.sh` et créer `stacks/<techno>/INDEX.md`, sans toucher aux skills.
- Nouveau skill : créer `skills/<nom>/SKILL.md`, ajouter une ligne au tableau du `README.md` et le citer dans la `description` de `marketplace.json`.
- `version` reste identique dans `marketplace.json` et `plugin.json` (et dans le badge du `README.md`). Chaque PR l'incrémente de `0.0.1` (skill `versioning`) ; sinon Claude Code ne propose pas la mise à jour. Version actuelle : `1.0.7`.
- Plateforme cible : GitHub (`gh`, Actions). Branches `feat/<slug>` ou `fix/<slug>` depuis `main` à jour, commits sémantiques `type(scope): emoji description` (skill `commit`), PR en Draft vers `main`, nettoyage local après le merge.

## Développement

Pas de build.

```bash
claude --plugin-dir ~/Sites/claude-skills-max   # lit les skills en place
/reload-plugins                                 # applique les modifs sans redémarrer
```

- `sh tests/check.sh` : frontmatter des skills et agents, références `max:<nom>` et `stacks/<id>/INDEX.md`, versions alignées, détection de stack sur des projets factices. Tourne aussi en CI (`.github/workflows/check.yml`). À lancer avant chaque commit.
- `tests/SCENARIOS.md` : à suivre dans une vraie session pour tout changement de comportement important d'un skill ou d'un agent.
