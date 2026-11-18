# CLAUDE.md

```bash
sh tests/check.sh                               # à lancer avant chaque commit
claude --plugin-dir ~/.claude/max-coding-agents-skills   # essayer les skills en place
/reload-plugins                                 # après chaque modification
```

Ce dépôt est le plugin Claude Code `max` : l'environnement de développement de Maxime, développeur web full-stack qui travaille seul sur les dépôts GitHub de plusieurs clients. Aucun build. Version courante : `1.0.20`.

## Structure

| Chemin | Rôle |
| :-- | :-- |
| `skills/<nom>/SKILL.md` | Un skill par dossier, appelé `/max:<nom>`. Il porte le déroulé. |
| `agents/<nom>.md` | Sous-agents en lecture seule, appelés `max:<nom>`. Ils portent les listes de contrôle. |
| `stacks/DETECT.md`, `stacks/detect.sh`, `stacks/<techno>/INDEX.md` | Détection de la stack et savoir de chaque techno. |
| `references/regles.md` | Règles communes, lues par chaque skill avant sa première étape. |
| `tests/check.sh`, `tests/SCENARIOS.md` | Contrôle de cohérence et scénarios manuels. |

Manifestes : `.claude-plugin/marketplace.json` et `.claude-plugin/plugin.json`. Garde-fou git : `hooks/hooks.json` et `scripts/guard-git.sh`.

## Règles de conception

- Trois couches : le skill porte le déroulé, l'agent fait la lecture, la stack apporte le savoir de la techno. Une règle vit dans une seule couche ; les autres y renvoient.
- Aucune techno en dur dans un skill transverse. Ajouter une techno : `stacks/detect.sh` et `stacks/<techno>/INDEX.md`, rien d'autre.
- Les agents restent en lecture seule et n'en lancent aucun autre.
- Prudence par défaut : PR en Draft, revue postée sur accord, cluster en lecture seule, aucun contrôle déclaré passé sans avoir tourné.
- Les conventions du dépôt client priment sur les défauts de Max. Aucun nom de client, secret ni donnée réelle dans le dépôt.

## Écrire un fichier `.md`

- Français, phrases courtes, impératif. Noms techniques tels quels.
- Un skill suit le plan de `docs/skill-anatomy.md` : préalables, étapes, points d'arrêt, ce qu'il ne fait pas. Sa première ligne utile est une action.
- Tout déroulé est numéroté. Cinq éléments au plus par liste ou par groupe, sauf inventaire qui doit rester complet.
- Ni phrase d'annonce, ni résumé final. Un skill ne décrit que ce que Claude ne ferait pas correctement seul.
- Les consignes de réponse à Maxime s'écrivent dans `references/regles.md`, jamais dans un skill.

## Contraintes de `tests/check.sh`

- Skill : `name` égal au nom du dossier, `description` sans chevrons qui cite `/max:<nom>` et contient « À utiliser », plan de `docs/skill-anatomy.md`. Cité `/max:<nom>` dans le README, `marketplace.json` et `tests/SCENARIOS.md`.
- Chemins d'un skill : première ligne des préalables qui résout `<max>`, `references/regles.md` lu dans les préalables, aucun `${CLAUDE_SKILL_DIR}`.
- Agent : `name`, `description` et `tools` présents, outils de lecture seule uniquement, plan `Entrée`, `Étapes`, `Contrôles` (facultatif), `Sortie`, `Limites`, aucun `max:<nom>` dans le corps. Cité dans le README et `docs/agents.md`.
- Références : tout `max:<nom>`, `<max>/<chemin>`, `stacks/<id>/INDEX.md` et lien Markdown relatif cités existent. Tout fichier de `references/` est cité par un skill ou un agent.
- Stack : `INDEX.md` avec `## core` et les seules natures connues, framework émis par `detect.sh` et listé dans `stacks/DETECT.md`, nature d'un skill conforme au tableau de `stacks/DETECT.md`.
- Dépôt : scripts en `#!/bin/sh` sans erreur shellcheck, garde-fou git exercé, actions épinglées par SHA, aucun secret, CRLF, marqueur de conflit ni bloc de code non refermé.
- Même version dans `plugin.json` et `marketplace.json`. Chaque PR ajoute `0.0.1` (`/max:versioning`), y compris dans le badge du README et ici. Le nombre de skills et de sous-agents du README suit le dépôt.

## Flux

Branche `feat/<slug>` ou `fix/<slug>` depuis `main` à jour, commits `type(scope): emoji description` en anglais (`/max:commit`), PR en Draft vers `main`. Un changement de comportement d'un skill ou d'un agent se rejoue dans `tests/SCENARIOS.md`.
