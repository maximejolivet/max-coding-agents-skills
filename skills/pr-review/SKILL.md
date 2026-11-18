---
name: pr-review
description: "Relit la pull request GitHub de quelqu'un d'autre - contenu face à l'issue, CI, forme des commits, langue, standards - et prépare une note de revue avec des commentaires ancrés et une recommandation approve ou request-changes. Brouillon par défaut : rien n'est posté sans accord. À utiliser quand Maxime donne une PR (URL ou numéro) à relire en tant que relecteur, ou invoque /max:pr-review."
argument-hint: "<numéro ou URL de PR>"
---

# Relire la PR d'un autre

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session.
2. Charger la PR (le dépôt se lit dans l'URL ; `GH_HOST=<hôte>` sur GitHub Enterprise) :

   ```bash
   gh pr view <n> -R <owner>/<repo>
   gh pr diff <n> -R <owner>/<repo>
   gh pr view <n> -R <owner>/<repo> --json commits
   gh pr checks <n> -R <owner>/<repo>
   gh issue view <issue> -R <owner>/<repo>
   ```

3. Lire `<max>/skills/review/SKILL.md` : ses modes, sa gravité, sa maîtrise du bruit et sa détection de stack s'appliquent ici. Ses chemins `<max>/…` partent de la même racine.

## Étapes

1. Relire le diff comme `/max:review`, en le jugeant face à l'issue chargée.
2. Ajouter les axes propres à la PR d'un autre (annexe) : CI, forme, langue, standards.
3. Fixer la recommandation : un Bloquant ou un Majeur donne `request-changes`, sinon `approve`.
4. Rédiger la note globale et un commentaire par constat (annexe), dans la langue de la PR.
5. Montrer la note, la liste des commentaires, la recommandation et ce qui n'a pas été vérifié. Ne rien poster.
6. Sur accord : poster une seule review `COMMENT` qui porte la note et les commentaires ancrés.
7. Sur un second accord, distinct : `gh pr review <n> -R <owner>/<repo> --approve -b "<message>"` ou `--request-changes -b "<message>"`.
8. Confirmer ce qui a été posté : URL, nombre de commentaires, état de l'approbation.

## Points d'arrêt

- Des checks sont en attente : les noter non vérifiés.
- Quelque chose n'a pas pu être vérifié : ne pas recommander `approve`.
- Le diff touche `.github/workflows/` : relire aussi le workflow avec les contrôles de `<max>/agents/actions-auditor.md`.
- L'API répond 422 (« Line could not be resolved ») : la ligne n'appartient pas au diff du fichier, corriger l'ancrage.
- L'accord donné pour une revue ne vaut pas pour la suivante.

## Ce qu'il ne fait pas

- Poster, approuver ou demander des changements sans accord explicite.
- Merger, ou passer la PR en « Ready for review ».
- Approuver en présence d'un Bloquant ou d'un Majeur.
- Signaler du code que la PR n'a pas touché : hors-scope.

## Annexe

### Axes propres

| Axe | À vérifier |
| :-- | :-- |
| CI | Un check rouge est un constat : Bloquant s'il est un vrai échec, Mineur s'il est instable ou sans rapport, en disant lequel |
| Commits | Un changement logique par commit ; convention du dépôt, sinon celle de `/max:commit` ; rupture signalée par `!` ou `BREAKING CHANGE:` (Majeur sinon) |
| PR | Issue liée par `Closes #n` ou `Refs #n` ; titre et description complets ; branche nommée selon le dépôt ; aucun fichier sans rapport |
| Langue | Celle du dépôt pour le code et pour la PR ; un écart est « à revoir », Mineur, sans effet sur la recommandation |
| Standards | Idiome local et standard de la stack. Si le dépôt ne dit rien : fonctions typées (paramètres et retour) et documentées |

La protection de branche décide du poids : avec « Require conversation resolution », chaque fil ouvert bloque le merge ; avec « Require approvals », l'approbation compte.

### Note globale

Elle devient le corps de la review. Les constats n'y figurent pas : chacun a son commentaire.

```markdown
## Review - <approve | changes requested>

| Axis                  | Verdict            |
| --------------------- | ------------------ |
| <only ⚠️/❌ axes>     | ⚠️ / ❌ + one line |

✅ <healthy axes on one line>

### Verified

- ✅ <check that ran> / ⚠️ <what could not be verified>

### Manual test

- [ ] <exact step>
```

### Commentaires

Un par Bloquant, Majeur ou Mineur, ancré sur une ligne du diff quand c'est possible. Les Détails tiennent sur une ligne en bas de la note.

```markdown
**[Blocking|Major|Minor|Nit|to review]** <symptom>
<why, and the exact fix - copyable, never "investigate X">
```

### Poster

```bash
HEAD=$(gh pr view <n> -R <owner>/<repo> --json headRefOid -q .headRefOid)

jq -n --arg head "$HEAD" --arg body "$(cat note.md)" --slurpfile comments comments.json \
  '{commit_id:$head, event:"COMMENT", body:$body, comments:$comments[0]}' > review.json

gh api -X POST "repos/<owner>/<repo>/pulls/<n>/reviews" --input review.json
```

`comments.json` :

```json
[{ "path": "<fichier>", "line": <nouvelle_ligne>, "side": "RIGHT", "body": "**[Major]** …" }]
```

`side: "RIGHT"` pour une ligne ajoutée ou de contexte, `"LEFT"` avec l'ancien numéro pour une ligne supprimée ; `start_line` et `start_side` pour une plage. Les fichiers `note.md`, `comments.json` et `review.json` s'écrivent hors du dépôt.
