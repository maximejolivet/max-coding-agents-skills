---
name: hotfix
description: Mène un correctif urgent sur une version déjà en production - branche fix/ depuis le tag ou main, correctif minimal avec test de non-régression, PR en Draft prioritaire, puis backport sur les autres branches. Indépendant de la stack. À utiliser quand un bug bloquant touche la production, quand l'utilisateur demande un hotfix, un correctif urgent ou un backport, ou invoque /max:hotfix.
---

# Hotfix

Remettre la production d'aplomb vite, **sans y glisser autre chose**. Plus le périmètre est étroit, plus la remise en service est rapide : un hotfix qui s'élargit s'éternise.

## 1. Évaluer la situation

1. **Gravité et impact** : qui est touché, depuis quand, existe-t-il un contournement immédiat (couper un drapeau, revenir au tag précédent) ? S'il y en a un, le proposer d'abord : il peut suffire.
2. **Version déployée** : repérer le tag ou le commit en production (`git tag --sort=-v:refname | head`, `gh release list`). Le correctif part de **cette version**, pas forcément de `main`.
3. **Distance à `main`** : `git log <tag>..main --oneline`. Si l'écart est mince, partir de `main` ; sinon créer la branche depuis le tag (`git switch -c fix/<slug> <tag>`) et viser la branche de maintenance correspondante.

## 2. Corriger

1. Créer `fix/<slug>` depuis la base retenue (voir `/max:switch`).
2. Identifier la cause racine en suivant `/max:debug` en version abrégée : reproduction, hypothèse confirmée.
3. Écrire d'abord le **test de non-régression** et le voir rouge, puis le correctif **minimal** et le voir vert (`/max:test`). Aucun refactoring, aucun nettoyage en passant.
4. Passer linter, vérification de types et suite complète. Un test ne s'affaiblit jamais pour que le correctif passe.
5. Committer `fix(<scope>): 🐛 …` (`/max:commit`) et incrémenter la version selon `/max:versioning`.

## 3. Publier et rétroporter

- Ouvrir la PR en Draft avec `/max:pull-request`, en mentionnant « hotfix » et l'impact, et demander une relecture prioritaire (`/max:review`).
- **Backport** : le correctif doit aussi rejoindre `main` et les branches maintenues. Proposer `git cherry-pick -x <commit>` sur une branche dédiée par cible, avec sa propre PR. Signaler les conflits au lieu de les trancher à l'aveugle.
- Une fois déployé, suggérer `/max:release` pour tagger la version corrective.

## Forme de la réponse

1. Gravité, base retenue (tag ou branche) et contournement éventuel.
2. Cause racine, correctif, test ajouté et vérification réellement exécutée.
3. PR et cibles de backport (faites ou à faire).
4. Risques et points non vérifiés.

## Limites

- Jamais de push direct sur `main` ni sur une branche de production, ni de `--force`, `reset --hard` ou `-D` sans accord explicite.
- Aucun déploiement ni opération sur la production : le skill prépare le correctif, l'équipe le met en ligne.
- Un bug non urgent relève de `/max:debug`.
