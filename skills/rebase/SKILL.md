---
name: rebase
description: "Met une branche à jour par rebase ou fusion sans perdre de travail - branche de sauvegarde, conflits résolus fichier par fichier en lisant les deux côtés, vérification, puis push en force-with-lease sur accord. À utiliser quand Maxime veut mettre sa branche à jour, rebaser, résoudre des conflits, squasher ou réordonner des commits, ou invoque /max:rebase."
---

# Rebase et conflits

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`).
2. Lancer `git status -sb` : l'arbre doit être propre. Sinon `/max:commit`, ou un stash par `/max:switch`.
3. Lancer `git log origin/<branche>..` et `gh pr view` : savoir si quelqu'un d'autre travaille sur la branche.

## Étapes

1. Sauvegarder : `git branch backup/<branche>-<date>`.
2. `git fetch origin`, puis choisir :

   | Méthode | Commande | Quand |
   | :-- | :-- | :-- |
   | Rebase | `git rebase origin/<défaut>` | Branche de PR personnelle |
   | Fusion | `git merge origin/<défaut>` | Branche partagée, ou historique à préserver |

3. Résoudre un conflit à la fois. Lire les deux côtés : `git log -p origin/<défaut> -- <fichier>`, puis ses propres commits.
4. Régénérer les lockfiles et les fichiers générés avec l'outil du projet, une fois les sources résolues.
5. Vérifier qu'il ne reste aucun marqueur (`grep -rn '<<<<<<<\|>>>>>>>'`), puis `git add <fichier>` et `git rebase --continue`.
6. Lancer linter, types et tests. Montrer `git log --oneline origin/<défaut>..`.
7. Proposer `git push --force-with-lease origin <branche>` et attendre l'accord. Supprimer la sauvegarde une fois tout poussé et vérifié.

Squasher ou réordonner : `git rebase -i` n'est pas disponible. Utiliser `git reset --soft <base>` puis un nouveau commit (`/max:commit`), ou `git rebase --onto`. Annoncer le plan avant de réécrire.

## Points d'arrêt

- La branche est partagée : un rebase demande l'accord des autres.
- L'intention d'un des deux côtés d'un conflit n'est pas claire : poser la question.
- Blocage : `git rebase --abort` rend l'état initial.
- Les tests échouent après le rebase : ne pas pousser.

## Ce qu'il ne fait pas

- `--ours` ou `--theirs` en bloc sans avoir lu.
- `git push --force`, `git reset --hard`, `git clean`, `git branch -D`.
- Rebaser `<défaut>` ou une branche protégée.
