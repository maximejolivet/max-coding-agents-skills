# Anatomie d'un skill

Un skill est un dossier `skills/<nom>/` avec un `SKILL.md`. Claude Code le charge à l'appel de `/max:<nom>`, ou quand la `description` correspond à la demande.

## Frontmatter

```yaml
---
name: review
description: Relit un changement de code avant le merge - … À utiliser quand l'utilisateur demande de relire un diff, ou invoque /max:review.
---
```

- `name` : identique au nom du dossier.
- `description` : ce que fait le skill **et** quand l'utiliser. C'est ce qui déclenche le chargement ; elle cite toujours la commande `/max:<nom>`.

`tests/check.sh` refuse un skill sans ces deux champs.

### Champs facultatifs

Claude Code accepte d'autres champs (source : [doc des skills](https://code.claude.com/docs/en/skills.md), section « Frontmatter reference »).

| Champ | Effet | Exemple |
| :--- | :--- | :--- |
| `when_to_use` | Contexte de déclenchement en plus de `description` (nom avec underscore). | `when_to_use: Use when the user says "ship it"` |
| `argument-hint` | Indice d'autocomplétion pour les arguments. | `argument-hint: [n° ou URL de PR]` |
| `arguments` | Noms d'arguments positionnels, substitués par `$nom`. | `arguments: [issue, branch]` |
| `allowed-tools` | Outils utilisables sans demande de permission pendant le tour qui invoque le skill. Ne restreint pas les autres. | `allowed-tools: Bash(git add *) Bash(git commit *)` |
| `disallowed-tools` | Outils retirés à Claude pendant le skill. | `disallowed-tools: AskUserQuestion` |
| `disable-model-invocation` | `true` : seul l'utilisateur lance le skill, via `/max:<nom>`. | `disable-model-invocation: true` |
| `user-invocable` | `false` : masque le skill du menu `/`, seul Claude peut l'invoquer. | `user-invocable: false` |
| `model` | Modèle pour le tour courant, ou `inherit`. | `model: inherit` |
| `effort` | Niveau d'effort : `low`, `medium`, `high`, `xhigh`, `max`. | `effort: high` |
| `context` | `fork` : exécute le skill dans un sous-agent, sans l'historique. | `context: fork` |
| `agent` | Type de sous-agent si `context: fork`. | `agent: Explore` |
| `background` | Avec `context: fork` : `false` attend le résultat dans le tour. | `background: false` |
| `hooks` | Hooks enregistrés à l'invocation du skill. | voir la doc des hooks |
| `paths` | Globs qui limitent le chargement automatique aux fichiers correspondants. | `paths: "src/**/*.ts"` |
| `shell` | Shell des blocs `` !`commande` `` : `bash` (défaut) ou `powershell`. | `shell: powershell` |

À savoir :

- Un champ inconnu est ignoré sans erreur : une faute de frappe ne fait rien, sans message.
- Si le YAML ne se parse pas, le skill se charge sans aucun champ.
- Hors Claude Code (upload sur claude.ai, API Skills), seuls `name`, `description`, `license`, `compatibility`, `metadata` et `allowed-tools` sont acceptés ; toute autre clé provoque une erreur.

## Corps

Les skills de ce dépôt suivent le même squelette :

1. **But** en deux phrases : ce que le skill rend, et à qui.
2. **Périmètre** : ce qu'il faut lire ou relire (PR, diff, branche courante).
3. **Détecter la stack** : suivre `stacks/DETECT.md` puis charger `stacks/<techno>/INDEX.md` avec la nature voulue. Aucune techno n'est écrite en dur.
4. **Dégradation propre** : sans ressource pour la stack, appliquer les règles génériques et le dire.
5. **Étapes** et **format de sortie** précis.
6. **Garde-fous** : ce que le skill ne fait jamais sans accord (pousser sur `main`, poster une review, `kubectl apply`).

## Règles

- Un skill générique reste indépendant de la techno ; les spécificités vont dans `stacks/`.
- Le `core` d'une techno n'existe qu'une fois, jamais recopié dans un skill.
- Chemins vers les ressources du dépôt : `${CLAUDE_SKILL_DIR}/../../stacks/…`.
- Un nouveau skill s'ajoute au tableau du `README.md` et à la `description` de `.claude-plugin/marketplace.json`.
