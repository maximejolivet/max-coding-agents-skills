---
name: switch
description: "Change de branche git en sécurité - vérifie l'état du dépôt, gère les changements non commités (commit ou stash, jamais de perte), crée feat/<slug> ou fix/<slug> depuis main à jour, revient sur une branche existante, et nettoie les branches déjà mergées. À utiliser quand l'utilisateur demande de changer de branche, de basculer, de créer une branche, de revenir sur main ou de nettoyer ses branches locales, ou invoque /max:switch."
---

# Changer de branche

Passer d'une branche à une autre sans perdre le moindre travail, et partir d'un `main` à jour pour toute nouvelle branche. Utiliser `git switch` (pas `git checkout`).

## Ce que demande l'utilisateur

Aller sur une branche existante, en créer une (`feat/<slug>` ou `fix/<slug>`), revenir sur `main`, supprimer la branche liée ou nettoyer les branches mergées. Sans cible claire, lister les branches locales (`git branch -vv`) et demander.

## Appels possibles

| Appel | Effet |
|---|---|
| `/max:switch <branche>` | bascule sur une branche existante |
| `/max:switch feat/<slug>` ou `fix/<slug>` | crée la branche depuis `main` à jour |
| `/max:switch delete` | supprime la branche liée, soit la branche courante (voir « Supprimer la branche liée ») |
| `/max:switch delete <branche>` ou `delete #<PR>` | supprime la branche nommée, ou celle de la PR indiquée |
| `/max:switch delete --remote` | supprime aussi la branche distante |
| `/max:switch delete --force` | autorise `git branch -D` si la branche n'est pas mergée |
| `/max:switch clean` | nettoie toutes les branches mergées |

`delete` accepte `--remote` et `--force` ensemble. Sans `--remote`, la branche distante n'est jamais touchée.

## Déroulé

1. **État du dépôt** : `git status -sb` et `git branch --show-current`, pour repérer changements non commités et fichiers non suivis.
2. **Travail en cours** : le cas échéant, demander quoi en faire avant de basculer :
   - le committer (renvoyer vers `/max:commit`) ;
   - le mettre de côté : `git stash push -u -m "<branche>: <résumé>"`, en gardant la trace du stash pour le restaurer ;
   - l'emporter : seulement si `git switch` l'accepte sans conflit.
3. **Branche existante** : `git switch <branche>`. Si elle n'existe que sur le remote, la même commande la crée en suivi. Restaurer le stash associé si l'utilisateur le souhaite.
4. **Nouvelle branche** :
   - nom `feat/<slug>` ou `fix/<slug>` (slug court, minuscules, tirets) ;
   - `git fetch origin`, `git switch main`, `git pull --ff-only origin main`, puis `git switch -c <branche>` ;
   - si `main` ne se met pas à jour en fast-forward, s'arrêter et expliquer.
5. **Contrôle final** : `git status -sb`, puis annoncer la branche courante, son retard ou son avance sur le remote et les stashs restants.

## Supprimer la branche liée

Avec `delete`, la cible est, par ordre de priorité : l'argument (`<branche>`, ou la branche de la PR `#<n>` via `gh pr view <n> --json headRefName`), sinon la branche courante. Si la cible est `main`, s'arrêter : elle ne se supprime jamais.

1. **Retrouver la PR liée** : `gh pr list --head <branche> --state all --json number,state,isDraft`. Annoncer la branche, la PR et son état.
2. **Vérifier le merge** : la PR doit être `MERGED` (ou la branche déjà mergée dans `main`). PR ouverte, ou fermée sans merge : le dire et s'arrêter, sauf `--force` confirmé.
3. **Travail en cours** : le traiter comme à l'étape 2 du « Déroulé » (commit ou stash) avant de quitter la branche.
4. **Revenir sur un `main` à jour** : `git fetch --prune origin`, `git switch main`, `git pull --ff-only origin main`.
5. **Confirmer** : montrer ce qui va disparaître (branche locale, et distante avec `--remote`) et attendre l'accord.
6. **Supprimer** : `git branch -d <branche>`. S'il refuse (non mergée en local, après un squash par exemple), ne passer à `-D` que si `--force` a été donné **et** que l'utilisateur confirme cette branche. Avec `--remote` et une PR mergée : `git push origin --delete <branche>` ; ignorer sans erreur si GitHub l'a déjà supprimée.
7. **Contrôler** : `git branch -vv`, puis annoncer ce qui reste.

## Nettoyer les branches mergées

Seulement sur demande, ou à proposer après un merge :

1. `git fetch --prune origin`, `git switch main`, `git pull --ff-only origin main`.
2. Lister les branches locales mergées (`git branch --merged main`, hors `main`) et celles dont le remote a disparu (`git branch -vv`, marquées `gone`).
3. Présenter la liste, demander confirmation, puis `git branch -d <branche>`.

## Garde-fous

- Ne jamais perdre de travail : ni `git checkout -- .`, ni `git reset --hard`, ni `git clean`, ni `git stash drop` sans accord explicite.
- Jamais de `git branch -D` sans accord explicite pour chaque branche non mergée.
- Aucun push ni suppression de branche distante sans demande : `delete --remote` en est une, rien d'autre.
- Ne jamais supprimer `main` ni une branche dont la PR est encore ouverte.
- Ne jamais committer sur `main` : si l'utilisateur s'y trouve avec des changements, proposer une nouvelle branche.
- Le skill ne crée ni commit ni PR : il renvoie vers `/max:commit` et `/max:pull-request`.
