# Anatomie d'un skill

Un skill est un dossier `skills/<nom>/` contenant un fichier `SKILL.md`. Claude Code le lit quand tu tapes `/max:<nom>`, ou quand ta demande ressemble à sa `description`.

## L'en-tête obligatoire

```yaml
---
name: review
description: Relit un changement de code avant le merge - … À utiliser quand l'utilisateur demande de relire un diff, ou invoque /max:review.
---
```

| Champ         | Règle |
| :------------ | :---- |
| `name`        | Exactement le nom du dossier. |
| `description` | Dit **ce que fait** le skill et **quand** s'en servir, et nomme la commande `/max:<nom>`. C'est elle qui décide du déclenchement automatique. |

`tests/check.sh` rejette un skill privé de l'un des deux.

## Champs optionnels

Claude Code en reconnaît d'autres (référence : [documentation des skills](https://code.claude.com/docs/en/skills.md)).

| Champ | Ce qu'il change |
| :---- | :-------------- |
| `when_to_use` | Ajoute du contexte de déclenchement à `description`. |
| `argument-hint` | Affiche un indice d'argument dans l'autocomplétion, ex. `[n° ou URL de PR]`. |
| `arguments` | Nomme des arguments positionnels, repris avec `$nom`. |
| `allowed-tools` | Autorise des outils sans confirmation pendant le tour du skill, sans interdire les autres. |
| `disallowed-tools` | Retire des outils à Claude le temps du skill. |
| `disable-model-invocation` | `true` : seul l'utilisateur peut lancer le skill. |
| `user-invocable` | `false` : le skill disparaît du menu `/`, Claude seul l'appelle. |
| `model`, `effort` | Imposent un modèle ou un niveau d'effort (`low` à `max`) pour le tour. |
| `context`, `agent`, `background` | `context: fork` exécute le skill dans un sous-agent isolé ; `agent` choisit son type ; `background: false` attend la fin. |
| `hooks` | Hooks actifs pendant le skill. |
| `paths` | Restreint le chargement automatique à certains fichiers (globs). |
| `shell` | Interpréteur des blocs `` !`commande` `` : `bash` ou `powershell`. |

Trois pièges :

- Une clé inconnue est ignorée en silence, donc une coquille ne produit aucune erreur.
- Un YAML invalide fait charger le skill sans aucun champ.
- Hors Claude Code (claude.ai, API Skills), seules les clés `name`, `description`, `license`, `compatibility`, `metadata` et `allowed-tools` passent ; les autres déclenchent une erreur.

## Le corps

Les skills de ce dépôt déroulent le même plan :

1. **Intention** : en deux phrases, ce que le skill produit et pour qui.
2. **Périmètre** : ce qu'il lit (diff, branche, PR).
3. **Stack** : application de `stacks/DETECT.md`, puis lecture de `stacks/<techno>/INDEX.md` pour la nature utile.
4. **Repli** : si rien n'existe pour la stack, règles génériques, annoncées comme telles.
5. **Étapes** et **forme de la sortie**, précises.
6. **Limites** : ce qu'il ne fait pas sans ton accord (push sur `main`, publication d'une revue, `kubectl apply`…).

## Règles d'écriture

- Un skill transverse ne cite aucune techno ; elles vivent dans `stacks/`.
- Le `core` d'une techno est référencé, jamais copié.
- Les chemins vers le dépôt s'écrivent `${CLAUDE_SKILL_DIR}/../../stacks/…`.
- Un nouveau skill est ajouté au tableau du `README.md` et à la `description` de `.claude-plugin/marketplace.json`.
