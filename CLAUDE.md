# CLAUDE.md

Ce dépôt est le plugin Claude Code `max` : ses skills s'appellent par `/max:<skill>` et il est distribué par un marketplace GitHub. Tout est rédigé en français, hors noms techniques. Le catalogue des skills se trouve dans `README.md`.

## Organisation du dépôt

- `.claude-plugin/marketplace.json` déclare le marketplace et le plugin `max` ; `.claude-plugin/plugin.json` est le manifeste (utilisé en développement local avec `--plugin-dir`).
- `skills/<nom>/SKILL.md` : un dossier par skill, frontmatter `name` + `description` obligatoire, puis le corps.
- `agents/<nom>.md` : sous-agents en lecture seule, appelés sous `max:<nom>`. Le skill les orchestre et les lance en parallèle ; aucun agent n'en lance d'autre.
- `stacks/DETECT.md` et `stacks/detect.sh` : détection de stack partagée par tous les skills (`detect.sh` ne fait que lire).
- `stacks/<techno>/` : connaissances propres à une techno, lues à la demande.
  - Forme 1 : un `INDEX.md` découpé en sections.
  - Forme 2 : `INDEX.md` (aiguillage) avec `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`.
- `tests/check.sh` vérifie la cohérence ; `tests/SCENARIOS.md` liste les scénarios à jouer à la main.

## Règles de conception

- Les skills transverses (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`) n'écrivent aucune techno : ils détectent la stack, puis lisent `stacks/<techno>/INDEX.md` pour la nature voulue (`core` + `dev`, ou `review`, `security`, `test`, `deploy`).
- Le `core` d'une techno est écrit une seule fois ; `review`, `security` et `pr-review` s'y réfèrent sans le recopier.
- Pour une nouvelle techno : l'ajouter à `detect.sh` et créer `stacks/<techno>/INDEX.md`. Aucun skill n'est modifié.
- Pour un nouveau skill : créer `skills/<nom>/SKILL.md`, ajouter une ligne au tableau du `README.md` et le citer dans la `description` de `marketplace.json`.
- La `version` doit être la même dans `marketplace.json`, `plugin.json` et le badge du `README.md`. Chaque PR l'augmente de `0.0.1` (skill `versioning`), faute de quoi Claude Code ne propose pas la mise à jour. Version courante : `1.0.15`.
- Cible : GitHub (`gh`, Actions). Branches `feat/<slug>` ou `fix/<slug>` créées depuis un `main` à jour, commits `type(scope): emoji description` (skill `commit`), PR en Draft vers `main`, nettoyage local une fois mergée.

## Travailler sur le dépôt

Aucun build.

```bash
claude --plugin-dir ~/Sites/claude-skills-max   # charge les skills depuis le dépôt
/reload-plugins                                 # prend en compte les modifications
```

- `sh tests/check.sh` contrôle le frontmatter des skills et agents, les références `max:<nom>` et `stacks/<id>/INDEX.md`, l'égalité des versions et la détection de stack sur des projets factices. Il tourne aussi en CI (`.github/workflows/check.yml`) ; à exécuter avant chaque commit.
- Après un changement de comportement notable d'un skill ou d'un agent, rejouer les scénarios concernés de `tests/SCENARIOS.md` dans une vraie session.
