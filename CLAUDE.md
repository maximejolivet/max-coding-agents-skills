# CLAUDE.md

```bash
sh tests/check.sh                               # à lancer avant chaque commit
claude --plugin-dir ~/Sites/claude-skills-max   # essayer les skills en place
/reload-plugins                                 # après chaque modification
```

Ce dépôt est le plugin Claude Code `max` : l'environnement de développement de Maxime, développeur freelance qui travaille seul sur les dépôts GitHub de plusieurs clients. Aucun build. Version courante : `1.0.15`.

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

- Skill : `name` égal au nom du dossier, `description` non vide, cité `/max:<nom>` dans le README et dans `marketplace.json`.
- Agent : `name`, `description` et `tools` présents, aucun outil d'écriture.
- Tout `max:<nom>` et tout `stacks/<id>/INDEX.md` cités existent.
- Même version dans `plugin.json` et `marketplace.json`. Chaque PR ajoute `0.0.1` (`/max:versioning`), y compris dans le badge du README et ici.

## Flux

Branche `feat/<slug>` ou `fix/<slug>` depuis `main` à jour, commits `type(scope): emoji description` en anglais (`/max:commit`), PR en Draft vers `main`. Un changement de comportement d'un skill ou d'un agent se rejoue dans `tests/SCENARIOS.md`.
