---
name: hotfix
description: "Mène un correctif urgent sur une version en production - contournement d'abord, branche depuis la version déployée, test de non-régression puis correctif minimal, PR en Draft, backport. À utiliser quand un bug bloquant touche la production, quand Maxime demande un hotfix, un correctif urgent ou un backport, ou invoque /max:hotfix."
---

# Correctif urgent

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`).
2. Lancer `git tag --sort=-v:refname | head` et `gh release list` : trouver la version déployée.
3. Relever qui est touché, depuis quand, et s'il existe un contournement immédiat (couper un drapeau, revenir au tag précédent).

## Étapes

1. Proposer le contournement en premier, s'il existe : il peut suffire.
2. Choisir la base avec `git log <tag>..<défaut> --oneline`. Écart faible : partir de `<défaut>`. Sinon : `git switch -c fix/<slug> <tag>`, et viser la branche de maintenance.
3. Établir la cause racine avec `/max:debug` : reproduction, hypothèse confirmée.
4. Écrire le test de non-régression et le voir rouge, puis le correctif minimal et le voir vert (`/max:test`).
5. Lancer linter, types et suite complète.
6. Committer (`/max:commit`), puis ouvrir la PR en Draft (`/max:pull-request`) en nommant le hotfix et son impact. Faire relire par `/max:review`.
7. Proposer le backport : `git cherry-pick -x <commit>` sur une branche par cible, chacune avec sa PR.

Après le déploiement : proposer `/max:release` pour la version corrective.

## Points d'arrêt

- Le bug ne se reproduit pas : s'arrêter et lister ce qui manque.
- Un cherry-pick entre en conflit : le signaler, ne pas trancher à l'aveugle.
- Le correctif grossit au-delà de la cause : s'arrêter, le reste part dans une issue.
- La base n'est pas `<défaut>` : faire confirmer la branche visée.

## Ce qu'il ne fait pas

- Déployer, ou agir sur la production.
- Refactorer ou nettoyer au passage.
- Affaiblir un test pour que le correctif passe.
- Pousser sur `<défaut>` ou sur une branche de production.
- Traiter un bug non urgent : `/max:debug`.
