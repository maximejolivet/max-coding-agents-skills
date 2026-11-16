# Modifier Max

```bash
git clone git@github.com:maximejolivet/claude-skills-max.git && cd claude-skills-max
sh tests/check.sh
claude --plugin-dir "$PWD"      # puis /reload-plugins après chaque édition
```

Aucun build, aucune dépendance. Il faut Claude Code et la CLI `gh`.

## Flux

1. `/max:switch feat/<slug>` : branche depuis `main` à jour.
2. Modifier, puis `sh tests/check.sh`.
3. `/max:commit` : `type(scope): emoji description`, en anglais.
4. `/max:versioning` : +0.0.1.
5. `/max:review`, puis `/max:pull-request` : PR en Draft vers `main`.

Après le merge : `/max:switch delete`.

## Quel fichier pour quelle tâche

| Tâche | Fichiers | À mettre à jour aussi |
| :-- | :-- | :-- |
| Nouveau skill | `skills/<nom>/SKILL.md` | README, `description` de `marketplace.json`, tableau des natures de `stacks/DETECT.md` s'il charge une stack, `tests/SCENARIOS.md` |
| Nouvel agent | `agents/<nom>.md`, le skill qui le lance | `docs/agents.md`, README |
| Nouvelle techno | `stacks/detect.sh`, `stacks/<techno>/INDEX.md` | Tableau « Indices » de `stacks/DETECT.md` ; aucun skill |
| Règle commune à tous les skills | `references/regles.md` | `tests/SCENARIOS.md`, groupe A |
| Nouvelle version | `/max:versioning` | Rien d'autre |

Formats : [docs/skill-anatomy.md](docs/skill-anatomy.md) pour un skill, [docs/agents.md](docs/agents.md) pour un agent, [stacks/DETECT.md](stacks/DETECT.md) pour une stack.

## Vérifier

- `sh tests/check.sh` : frontmatter, références, versions, détection de stack. Il tourne aussi en CI à chaque PR.
- `tests/SCENARIOS.md` : à rejouer dans une vraie session quand le comportement d'un skill ou d'un agent change. `check.sh` ne voit pas ce qu'un skill fait.
- L'agent `max:docs-updater`, sur demande : écarts entre la documentation et le dépôt.

## Erreurs courantes

| Symptôme | Correction |
| :-- | :-- |
| Un skill transverse nomme une techno | Déplacer ce contenu dans `stacks/` |
| La même règle dans un skill et dans un agent | La garder dans une seule couche, renvoyer depuis l'autre |
| `check.sh` échoue sur un skill non déclaré | Le citer `/max:<nom>` dans le README et `marketplace.json` |
| Le skill ne se déclenche pas | Sa `description` ne dit pas quand l'utiliser |
| Des chevrons dans une `description` | Les retirer : ils s'affichent `&lt;` et `&gt;` |
