---
name: hotfix
description: Mène un correctif urgent sur une version déjà en production - branche fix/ depuis le tag ou main, correctif minimal avec test de non-régression, PR en Draft prioritaire, puis backport sur les autres branches. Indépendant de la stack. À utiliser quand un bug bloquant touche la production, quand l'utilisateur demande un hotfix, un correctif urgent ou un backport, ou invoque /max:hotfix.
---

# Correctif urgent (hotfix)

Corriger vite **sans embarquer autre chose**. Le périmètre est le plus petit possible : un hotfix qui grossit retarde la remise en service.

## Cadrer

1. **Gravité et impact** - qui est touché, depuis quand, y a-t-il un contournement immédiat (désactiver un drapeau, revenir au tag précédent) ? Si oui, le proposer en premier : il peut suffire.
2. **Version en production** - le tag ou le commit déployé (`git tag --sort=-v:refname | head`, `gh release list`). La base du correctif est **cette version**, pas forcément `main`.
3. **Écart avec `main`** - `git log <tag>..main --oneline`. S'il est faible, partir de `main` ; sinon, partir du tag (`git switch -c fix/<slug> <tag>`) et cibler la branche de maintenance correspondante.

## Corriger

1. Branche `fix/<slug>` depuis la base choisie (voir `/max:switch`).
2. Cause racine : suivre `/max:debug` en version courte (repro, hypothèse confirmée).
3. **Test de non-régression d'abord**, vu rouge, puis correctif **minimal**, vu vert (`/max:test`). Pas de refactoring ni de nettoyage au passage.
4. Linter, types et suite complète. Ne jamais affaiblir un test pour que le correctif passe.
5. Commit `fix(<scope>): 🐛 …` (`/max:commit`), version incrémentée selon `/max:versioning`.

## Publier et rétroporter

- PR en Draft via `/max:pull-request`, titre et description en précisant « hotfix » et l'impact ; demander une relecture prioritaire (`/max:review`).
- **Backport** : le correctif doit aussi atterrir sur `main` et les branches maintenues. Proposer `git cherry-pick -x <commit>` sur une branche dédiée par cible, avec sa propre PR. Signaler les conflits plutôt que de les résoudre à l'aveugle.
- Après le déploiement : proposer `/max:release` pour tagger la version corrective.

## Format de la réponse

1. Gravité, base retenue (tag/branche) et contournement possible.
2. Cause racine et correctif, test ajouté, vérification réelle.
3. PR et cibles de backport (à faire, faites).
4. Risques et points non vérifiés.

## Hors périmètre

- Jamais de push direct sur `main` ni sur une branche de production, jamais de `--force`, `reset --hard` ou `-D` sans accord explicite.
- Ne pas déployer ni exécuter d'opération sur la production : le skill prépare le correctif, l'équipe déploie.
- Un bug non urgent relève de `/max:debug`.
