---
name: switch
description: "Change de branche git sans perdre de travail - bascule sur une branche, en crée une depuis la branche par défaut à jour, supprime la branche d'une PR mergée, nettoie les branches mergées. À utiliser quand Maxime veut changer, créer, supprimer ou nettoyer une branche, revenir sur la branche par défaut, ou invoque /max:switch."
argument-hint: "[branche | feat/slug | delete [branche|#PR] [--remote] [--force] | clean]"
---

# Changer de branche

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session. Elle donne la branche par défaut, notée `<défaut>` ci-dessous, et le nommage des branches du dépôt.
2. Lancer `git status -sb` et `git branch --show-current`.
3. S'il reste du travail non commité, demander quoi en faire : le committer (`/max:commit`), le mettre de côté (`git stash push -u -m "<branche>: <résumé>"`), ou l'emporter si `git switch` l'accepte sans conflit.

## Étapes

| Appel | Déroulé |
| :-- | :-- |
| `/max:switch <branche>` | Basculer |
| `/max:switch feat/<slug>` ou `fix/<slug>` | Créer |
| `/max:switch delete [<branche> ou #<PR>] [--remote] [--force]` | Supprimer |
| `/max:switch clean` | Nettoyer |

Sans cible claire : `git branch -vv`, puis demander.

### Basculer

1. `git switch <branche>`. Une branche qui n'existe que sur le remote est créée en suivi.
2. Restaurer le stash lié si Maxime le demande.
3. `git status -sb` : annoncer la branche, son avance ou son retard, les stashs restants.

### Créer

1. `git fetch origin`, `git switch <défaut>`, `git pull --ff-only origin <défaut>`.
2. `git switch -c <branche>` : nommage du dépôt, sinon `feat/<slug>` ou `fix/<slug>`, slug court en minuscules avec des tirets.
3. `git status -sb`.

### Supprimer

La cible est l'argument, sinon la branche courante. Pour `#<PR>` : `gh pr view <n> --json headRefName`.

1. `gh pr list --head <branche> --state all --json number,state,isDraft` : annoncer la branche, la PR et son état.
2. `git fetch --prune origin`, `git switch <défaut>`, `git pull --ff-only origin <défaut>`.
3. Montrer ce qui sera supprimé (locale, et distante avec `--remote`), puis attendre l'accord.
4. `git branch -d <branche>`. Avec `--remote` et une PR mergée : `git push origin --delete <branche>` ; ignorer l'erreur si GitHub l'a déjà supprimée.
5. `git branch -vv` : annoncer ce qui reste.

### Nettoyer

1. `git fetch --prune origin`, `git switch <défaut>`, `git pull --ff-only origin <défaut>`.
2. Lister `git branch --merged <défaut>` (hors `<défaut>`) et les branches marquées `gone` dans `git branch -vv`.
3. Montrer la liste, attendre l'accord, puis `git branch -d` sur chacune.

## Points d'arrêt

- `<défaut>` ne se met pas à jour en fast-forward : s'arrêter et expliquer.
- La cible d'une suppression est `<défaut>` : s'arrêter.
- La PR est ouverte, ou fermée sans merge : s'arrêter, sauf `--force` confirmé.
- `git branch -d` refuse (squash, par exemple) : `-D` seulement si `--force` a été passé et que Maxime confirme cette branche.
- Maxime est sur `<défaut>` avec des changements : proposer une nouvelle branche.

## Ce qu'il ne fait pas

- `git checkout -- .`, `git reset --hard`, `git clean`, `git stash drop`.
- Toucher une branche distante sans `--remote`.
- Pousser, committer ou ouvrir une PR : `/max:commit` et `/max:pull-request` s'en chargent.
