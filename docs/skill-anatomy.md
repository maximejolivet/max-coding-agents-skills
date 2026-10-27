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
