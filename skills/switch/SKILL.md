---
name: switch
description: "Change de branche git en sécurité - vérifie l'état du dépôt, gère les changements non commités (commit ou stash, jamais de perte), crée feat/<slug> ou fix/<slug> depuis main à jour, revient sur une branche existante, et nettoie les branches déjà mergées. À utiliser quand l'utilisateur demande de changer de branche, de basculer, de créer une branche, de revenir sur main ou de nettoyer ses branches locales, ou invoque /max:switch."
---

# Changer de branche

Basculer d'une branche à l'autre sans perdre de travail, et partir de `main` à jour pour toute nouvelle branche. Utilise `git switch` (pas `git checkout`).

## Périmètre

La demande de l'utilisateur : une branche existante, une nouvelle branche (`feat/<slug>` ou `fix/<slug>`), le retour sur `main`, ou le nettoyage des branches mergées. Sans cible claire, lister les branches locales (`git branch -vv`) et demander.

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

## Nettoyage des branches mergées

Uniquement sur demande, ou à proposer après un merge :

1. `git fetch --prune origin`, `git switch main`, `git pull --ff-only origin main`.
2. Lister les branches locales mergées (`git branch --merged main`, hors `main`) et celles dont le remote a disparu (`git branch -vv`, marquées `gone`).
3. Montrer la liste et demander confirmation, puis `git branch -d <branche>`.

## Garde-fous

- Ne jamais perdre de travail : pas de `git checkout -- .`, `git reset --hard`, `git clean`, ni `git stash drop` sans accord explicite.
- Ne jamais forcer une suppression (`git branch -D`) sans accord explicite pour chaque branche non mergée.
- Ne jamais pousser, ni supprimer une branche distante, sans demande.
- Ne jamais committer sur `main` : si l'utilisateur est sur `main` avec des changements, proposer une nouvelle branche.
- Le skill ne crée ni commit ni PR : il renvoie vers `/max:commit` et `/max:pull-request`.
