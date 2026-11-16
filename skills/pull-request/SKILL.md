---
name: pull-request
description: "Ouvre une pull request GitHub en Draft - branche dédiée, index ciblé, un commit, push, puis gh pr create avec une description structurée liée à l'issue. À utiliser quand Maxime demande de préparer, ouvrir ou créer une PR après un correctif ou une fonctionnalité, ou invoque /max:pull-request."
---

# Ouvrir une pull request

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`), le modèle de PR du dépôt et la langue.
2. Lancer `git status -sb` et `gh auth status`.
3. Si `/max:review` vient de tourner : reprendre son verdict, ses contrôles exécutés et ses notes hors-scope, sans les recalculer.

L'appel de ce skill vaut accord pour pousser la branche et créer la PR en Draft. Rien de plus.

## Étapes

1. **Branche.** Sur `<défaut>` : créer la branche avec `/max:switch` avant tout commit.
2. **Index.** `git add <fichiers>` pour les seuls fichiers du changement, puis `git diff --cached --name-only`.
3. **Commit.** Un commit ciblé, écrit avec `/max:commit`, l'issue en trailer.
4. **Push.** `git push -u origin <branche>`, puis `gh pr list --head <branche> --state open`.
5. **Création.** Écrire la description dans un fichier temporaire hors du dépôt, puis :

   ```bash
   gh pr create --head <branche> --base <défaut> --title "<titre>" --body-file <fichier> --draft
   ```

6. **Compte rendu.** L'URL, l'état Draft, `gh pr checks <numéro>`, ce qui a été commité et ce qui a été laissé de côté.

Titre : la convention des commits du dépôt. Description : le modèle du dépôt (`.github/pull_request_template.md`) s'il existe, sinon l'annexe.

## Points d'arrêt

- Une PR ouverte existe déjà pour la branche : la mettre à jour avec `gh pr edit`, ne pas en créer une seconde.
- L'index contient un fichier sans rapport, un secret ou une donnée client : s'arrêter.
- Le dépôt vise une autre base que `<défaut>` (ses PR récentes le montrent) : demander laquelle.
- Les checks échouent : le dire, ne pas les relancer.

## Ce qu'il ne fait pas

- `gh pr ready`, approuver ou merger : la recette et le merge reviennent à Maxime.
- Pousser sur `<défaut>`, `git push --force`, `git branch -D`.
- `git add .` ou `git add -A`.
- Supprimer la branche après le merge : `/max:switch delete`.

## Annexe : modèle par défaut

Correctif :

```markdown
## Context

Closes #<issue> - <the problem, in one paragraph>

## Root cause

<what caused it; name the commits, routes or services involved>

## Fix

<what changed and why it is correct; what is left unchanged on purpose>

## Verification

- ✅ <check that actually ran, with its result>

### Manual test

<exact steps to confirm>

## Out of scope

<latent issues for a separate issue>
```

Fonctionnalité : remplacer `Root cause` et `Fix` par une section `## Change` (ce qui est ajouté, les choix faits, ce qui est laissé de côté). `Closes #n` ferme l'issue au merge ; `Refs #n` quand la PR ne traite le sujet qu'en partie.
