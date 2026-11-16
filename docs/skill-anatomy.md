# Anatomie d'un skill

```bash
mkdir skills/<nom> && $EDITOR skills/<nom>/SKILL.md
```

Claude Code charge le fichier quand Maxime tape `/max:<nom>`, ou quand sa demande correspond à la `description`.

## Frontmatter

Vérifié dans la [documentation officielle](https://code.claude.com/docs/en/skills.md) le 2026-11-16.

```yaml
---
name: review
description: "Relit un changement de code avant le merge - … À utiliser quand Maxime demande de relire un diff, ou invoque /max:review."
argument-hint: "[numéro ou URL de PR | branche | fichier]"
---
```

| Champ | Statut | Règle dans ce dépôt |
| :-- | :-- | :-- |
| `name` | Facultatif pour Claude Code, exigé par `check.sh` | Identique au nom du dossier |
| `description` | Recommandé, exigé par `check.sh` | Ce que fait le skill, puis quand le déclencher ; cite `/max:<nom>` |
| `argument-hint` | Facultatif | Sur les skills qui prennent un argument |

À savoir :

- `description` et `when_to_use` réunis sont tronqués à 1 536 caractères dans la liste des skills : le cas d'usage principal vient en premier.
- Les chevrons d'une `description` s'affichent `&lt;` et `&gt;` : ne pas en mettre.
- Le frontmatter n'est lu que si `---` est la première ligne du fichier.
- Un champ inconnu est ignoré sans erreur. Un YAML invalide fait charger le skill sans aucun champ.
- Une valeur qui contient `:` ou `#` se met entre guillemets.

Les autres champs (`allowed-tools`, `disable-model-invocation`, `model`, `context`, `paths`…) sont décrits dans la documentation officielle. Aucun skill de ce dépôt ne les emploie.

## Corps

Le même plan pour tous les skills. « Quand l'utiliser » vit dans la `description`, pas dans le corps.

```markdown
# <Titre>

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. <commande à lancer ou fichier à lire>

## Étapes

1. <une action bornée>

## Points d'arrêt

- <condition> : <s'arrêter, demander, ou changer de voie>

## Ce qu'il ne fait pas

- <action interdite, ou renvoi vers le skill qui s'en charge>

## Annexe

<formats de sortie, tableaux, modèles - seulement s'il en faut>
```

Chemins : `${CLAUDE_SKILL_DIR}` est le dossier du skill. Le reste du plugin s'atteint par `${CLAUDE_SKILL_DIR}/../../`.

| Besoin | Ligne à écrire |
| :-- | :-- |
| Charger une stack | Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **review** |
| Lire la liste de contrôle d'un agent | Lire la section `## Contrôles` de `${CLAUDE_SKILL_DIR}/../../agents/<nom>.md` |
| Reprendre le déroulé d'un autre skill | Lire `${CLAUDE_SKILL_DIR}/../<autre>/SKILL.md` |

## Règles d'écriture

1. La première ligne utile est une action : une commande, un chemin, un contrôle.
2. Tout déroulé est numéroté. Une étape, une action bornée ; une étape triviale se fond dans la précédente.
3. Cinq éléments au plus par liste ou par groupe. Un inventaire qui doit être complet reste complet, en groupes nommés.
4. Une règle d'une autre couche (agent, stack, règles communes) ne se répète pas : on y renvoie.
5. Ni phrase d'annonce, ni résumé final, ni adverbe de précaution vide.

Et sur le fond :

- Français, phrases courtes, impératif.
- Un skill ne décrit que ce que Claude ne ferait pas correctement seul.
- Les consignes de réponse à Maxime s'écrivent dans `references/regles.md`.
- Un nouveau skill s'ajoute au README, à `marketplace.json` et à `tests/SCENARIOS.md`.
