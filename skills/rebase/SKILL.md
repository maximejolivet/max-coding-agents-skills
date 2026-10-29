---
name: rebase
description: Rebase ou fusionne une branche sur main en sécurité - sauvegarde de la branche d'abord, résolution des conflits fichier par fichier en comprenant les deux côtés, vérification après chaque étape, push avec force-with-lease seulement sur accord. À utiliser quand l'utilisateur veut mettre sa branche à jour, rebaser, résoudre des conflits, squasher ou réordonner des commits, ou invoque /max:rebase.
---

# Rebase et conflits en sécurité

Mettre une branche à jour **sans perdre de travail**. Réécrire l'historique est risqué : on sauvegarde avant, on vérifie après, on ne pousse qu'avec accord.

## Avant de commencer

1. `git status -sb` : l'arbre doit être propre. Sinon, commiter (`/max:commit`) ou mettre de côté (`/max:switch`).
2. Vérifier que la branche n'est **pas partagée** : `git log origin/<branche>..` et la PR (`gh pr view`). Rebaser une branche sur laquelle d'autres travaillent demande leur accord.
3. **Sauvegarde** : `git branch backup/<branche>-<date>` avant toute réécriture. La supprimer seulement quand tout est vérifié et poussé.
4. `git fetch origin`. Choisir la méthode :
   - **rebase** (`git rebase origin/main`) : historique linéaire, préféré pour une branche de PR privée ;
   - **merge** (`git merge origin/main`) : si la branche est partagée ou si l'historique des commits compte.

## Résoudre les conflits

1. `git status` : lister les fichiers en conflit. Un conflit à la fois.
2. Pour chacun, **comprendre les deux côtés** : `git log -p origin/main -- <fichier>` (ce qui a changé sur `main`) et ses propres commits. Ne jamais choisir `--ours`/`--theirs` en bloc sans lire.
3. Fichiers générés et lockfiles : ne pas fusionner à la main ; régénérer avec l'outil du projet après avoir résolu les sources.
4. Après résolution : retirer tous les marqueurs (`grep -rn '<<<<<<<\|>>>>>>>'`), `git add <fichier>`, `git rebase --continue`.
5. Lancer le linter, les types et les tests **à la fin** (et après chaque étape si le rebase est long).
6. Bloqué ou perdu : `git rebase --abort` ramène à l'état d'avant, sans dégâts.

## Squasher ou réordonner

`git rebase -i` n'est pas disponible dans cet environnement interactif : utiliser `git reset --soft <base>` puis un nouveau commit (`/max:commit`), ou `git rebase --onto` pour déplacer une série. Annoncer le plan avant de réécrire.

## Publier

La branche a été réécrite : un push simple sera refusé. Proposer `git push --force-with-lease origin <branche>` et **attendre l'accord**. Jamais `--force` nu, jamais sur `main`.

## Format de la réponse

1. Méthode choisie, branche de sauvegarde créée.
2. Conflits : fichiers, résolution retenue et pourquoi.
3. Vérification réelle (linter, tests) et résultat de `git log --oneline origin/main..`.
4. Ce qui reste : push (force-with-lease) en attente d'accord, suppression de la sauvegarde.

## Hors périmètre

- Jamais de `git push --force`, `git reset --hard`, `git clean` ni de suppression de branche (`-D`, distante) sans accord explicite.
- Ne pas rebaser `main` ni une branche protégée.
- Ne pas résoudre un conflit dont on ne comprend pas l'intention : poser la question.
