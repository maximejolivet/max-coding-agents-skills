---
name: rebase
description: Rebase ou fusionne une branche sur main en sécurité - sauvegarde de la branche d'abord, résolution des conflits fichier par fichier en comprenant les deux côtés, vérification après chaque étape, push avec force-with-lease seulement sur accord. À utiliser quand l'utilisateur veut mettre sa branche à jour, rebaser, résoudre des conflits, squasher ou réordonner des commits, ou invoque /max:rebase.
---

# Rebase et conflits sans risque

Remettre une branche à niveau **sans rien perdre**. Réécrire l'historique est délicat : on sauvegarde d'abord, on vérifie ensuite, on ne pousse qu'avec accord.

## Préparation

1. `git status -sb` : l'arbre doit être propre. Sinon, committer (`/max:commit`) ou mettre de côté (`/max:switch`).
2. S'assurer que la branche n'est **pas partagée** : `git log origin/<branche>..` et la PR (`gh pr view`). Rebaser une branche sur laquelle d'autres travaillent suppose leur accord.
3. **Sauvegarde** : `git branch backup/<branche>-<date>` avant toute réécriture. Ne la supprimer qu'une fois tout vérifié et poussé.
4. `git fetch origin`, puis choisir la méthode :
   - **rebase** (`git rebase origin/main`) : historique linéaire, à privilégier pour une branche de PR personnelle ;
   - **merge** (`git merge origin/main`) : quand la branche est partagée ou que l'historique des commits compte.

## Résoudre les conflits

1. `git status` liste les fichiers en conflit ; les traiter un par un.
2. Pour chacun, **comprendre les deux côtés** : `git log -p origin/main -- <fichier>` montre ce qui a bougé sur `main`, à comparer à ses propres commits. Jamais de `--ours` / `--theirs` en bloc sans avoir lu.
3. Fichiers générés et lockfiles : ne pas les fusionner à la main ; les régénérer avec l'outil du projet une fois les sources résolues.
4. Une fois résolu : supprimer tous les marqueurs (`grep -rn '<<<<<<<\|>>>>>>>'`), `git add <fichier>`, `git rebase --continue`.
5. Passer linter, types et tests **à la fin**, et après chaque étape si le rebase est long.
6. En cas de blocage : `git rebase --abort` restaure l'état initial sans dommage.

## Squasher ou réordonner

`git rebase -i` n'est pas utilisable ici (mode interactif). Employer `git reset --soft <base>` puis un nouveau commit (`/max:commit`), ou `git rebase --onto` pour déplacer une série. Annoncer le plan avant de réécrire.

## Publier

La branche a été réécrite : un push simple sera rejeté. Proposer `git push --force-with-lease origin <branche>` et **attendre l'accord**. Jamais de `--force` nu, jamais sur `main`.

## Forme de la réponse

1. Méthode retenue et branche de sauvegarde créée.
2. Conflits : fichiers, résolution choisie et raison.
3. Vérification réelle (linter, tests) et résultat de `git log --oneline origin/main..`.
4. Reste à faire : push (force-with-lease) en attente d'accord, suppression de la sauvegarde.

## Limites

- Jamais de `git push --force`, `git reset --hard`, `git clean` ni de suppression de branche (`-D`, distante) sans accord explicite.
- Ne pas rebaser `main` ni une branche protégée.
- Un conflit dont l'intention échappe ne se tranche pas : poser la question.
