---
name: switch
description: "Change de branche git en sécurité - vérifie l'état du dépôt, gère les changements non commités (commit ou stash, jamais de perte), crée feat/<slug> ou fix/<slug> depuis main à jour, revient sur une branche existante, et nettoie les branches déjà mergées. À utiliser quand l'utilisateur demande de changer de branche, de basculer, de créer une branche, de revenir sur main ou de nettoyer ses branches locales, ou invoque /max:switch."
---

# Changer de branche

Basculer d'une branche à l'autre sans perdre de travail, et partir de `main` à jour pour toute nouvelle branche. Utilise `git switch` (pas `git checkout`).

## Périmètre

La demande de l'utilisateur : une branche existante, une nouvelle branche (`feat/<slug>` ou `fix/<slug>`), le retour sur `main`, la suppression de la branche liée, ou le nettoyage des branches mergées. Sans cible claire, lister les branches locales (`git branch -vv`) et demander.

## Paramètres

| Appel | Effet |
|---|---|
| `/max:switch <branche>` | bascule sur une branche existante |
| `/max:switch feat/<slug>` ou `fix/<slug>` | crée la branche depuis `main` à jour |
| `/max:switch delete` | supprime la branche liée : la branche courante (voir « Supprimer la branche liée ») |
| `/max:switch delete <branche>` ou `delete #<PR>` | supprime la branche nommée, ou celle de la PR indiquée |
| `/max:switch delete --remote` | supprime aussi la branche distante |
| `/max:switch delete --force` | autorise `git branch -D` si la branche n'est pas mergée |
| `/max:switch clean` | nettoyage de toutes les branches mergées |

`delete` accepte `--remote` et `--force` ensemble. Sans `--remote`, la branche distante n'est jamais touchée.

## Étapes

1. **État du dépôt** : `git status -sb`, `git branch --show-current`. Repérer les changements non commités et les fichiers non suivis.
2. **Changements en cours** : s'il y en a, demander quoi en faire avant de basculer :
   - les commiter (renvoyer vers `/max:commit`) ;
   - les mettre de côté : `git stash push -u -m "<branche>: <résumé>"`, en notant le stash pour le restaurer ;
   - les emporter : seulement si `git switch` le permet sans conflit.
3. **Branche existante** : `git switch <branche>`. Si elle n'existe que sur le remote, `git switch <branche>` la crée en suivi. Restaurer le stash associé si l'utilisateur le demande.
4. **Nouvelle branche** :
   - nom `feat/<slug>` ou `fix/<slug>` (slug court, en minuscules, avec des tirets) ;
   - `git fetch origin`, `git switch main`, `git pull --ff-only origin main`, puis `git switch -c <branche>` ;
   - si `main` ne se met pas à jour en fast-forward, s'arrêter et expliquer.
5. **Vérifier** : `git status -sb` et annoncer la branche courante, son retard ou avance sur le remote, et les stashs restants.

## Supprimer la branche liée

Sur `delete`, la branche cible est, dans l'ordre : l'argument (`<branche>` ou la branche de la PR `#<n>`, via `gh pr view <n> --json headRefName`), sinon la branche courante. Si la cible est `main`, s'arrêter : ne jamais la supprimer.

1. **Identifier la PR liée** : `gh pr list --head <branche> --state all --json number,state,isDraft`. Annoncer la branche, la PR et son état.
2. **Vérifier le merge** : la PR doit être `MERGED` (ou la branche mergée dans `main`). Une PR ouverte ou fermée sans merge : le dire et s'arrêter, sauf `--force` confirmé.
3. **Changements en cours** : traiter comme à l'étape 2 de « Étapes » (commit ou stash) avant de quitter la branche.
4. **Se placer sur `main` à jour** : `git fetch --prune origin`, `git switch main`, `git pull --ff-only origin main`.
5. **Confirmer** : montrer ce qui sera supprimé (branche locale, et distante si `--remote`) et attendre l'accord.
6. **Supprimer** : `git branch -d <branche>`. S'il refuse (non mergée en local, par exemple après un squash), ne forcer avec `-D` que si `--force` a été passé **et** que l'utilisateur confirme cette branche. Avec `--remote` et une PR mergée : `git push origin --delete <branche>` ; ignorer sans erreur si GitHub l'a déjà supprimée.
7. **Vérifier** : `git branch -vv` et annoncer ce qui reste.

## Nettoyage des branches mergées

Uniquement sur demande, ou à proposer après un merge :

1. `git fetch --prune origin`, `git switch main`, `git pull --ff-only origin main`.
2. Lister les branches locales mergées (`git branch --merged main`, hors `main`) et celles dont le remote a disparu (`git branch -vv`, marquées `gone`).
3. Montrer la liste et demander confirmation, puis `git branch -d <branche>`.

## Garde-fous

- Ne jamais perdre de travail : pas de `git checkout -- .`, `git reset --hard`, `git clean`, ni `git stash drop` sans accord explicite.
- Ne jamais forcer une suppression (`git branch -D`) sans accord explicite pour chaque branche non mergée.
- Ne jamais pousser, ni supprimer une branche distante, sans demande : `delete --remote` en est une, rien d'autre.
- Ne jamais supprimer `main`, ni une branche dont la PR est encore ouverte.
- Ne jamais committer sur `main` : si l'utilisateur est sur `main` avec des changements, proposer une nouvelle branche.
- Le skill ne crée ni commit ni PR : il renvoie vers `/max:commit` et `/max:pull-request`.
