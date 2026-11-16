---
name: debug
description: "Diagnostique et corrige un bug par sa cause racine - reproduction déterministe, hypothèses testées une à une, bisect git, test de non-régression vu rouge puis vert, correctif minimal. À utiliser quand Maxime signale un bug, une erreur, une exception, un test qui échoue, un comportement inattendu ou une régression, ou invoque /max:debug."
argument-hint: "[symptôme, message d'erreur ou numéro d'issue]"
---

# Déboguer

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **dev**.
3. Réunir le symptôme : comportement observé et attendu, message et trace complets, versions, fréquence, issue liée (`gh issue view <n>`). Demander la pièce qui manque.

## Étapes

1. **Reproduire.** Obtenir une commande, un test ou une requête qui échoue à chaque fois. Pour un bug intermittent : figer ce qui varie (ordre, temps, concurrence, données) et mesurer le taux d'échec.
2. **Isoler**, du moins coûteux au plus coûteux :
   1. lire la trace de bas en haut jusqu'au premier code du projet, puis le code autour ;
   2. si cela marchait avant : `git bisect run <commande de repro>` sur une branche jetable, puis `git bisect reset` ; sinon `git log -S`, `git blame` ;
   3. réduire l'entrée ou le code jusqu'à ce que le bug disparaisse ;
   4. observer les valeurs réelles : logs temporaires, débogueur, `dump`.
3. **Formuler** deux ou trois hypothèses classées par vraisemblance, chacune avec le test qui la tranche. N'en tester qu'une à la fois.
4. **Établir la cause** : elle explique tout le symptôme, y compris son absence ailleurs.
5. **Corriger** : test de non-régression vu rouge (`/max:test`), correctif minimal sur la cause, test vu vert, puis suite complète, linter et types.
6. **Chercher les cas jumeaux** (`grep` du même motif) et les signaler.
7. **Rendre compte** : reproduction, cause avec `fichier:ligne` et commit d'origine, correctif, vérification chiffrée, points non vérifiés.

Sur un gros projet, l'agent `max:codebase-surveyor` peut cartographier la zone ; les modifications restent dans la session.

## Points d'arrêt

- Le bug ne se reproduit pas : le dire, lister ce qui manque (logs, données, configuration) et s'arrêter.
- Trois hypothèses réfutées : revenir au symptôme, le cadrage est sans doute faux.
- Le test de non-régression ne passe pas au rouge : il ne reproduit pas le bug.
- Le correctif demande un refactoring : le proposer à part (`/max:refactor`).

## Ce qu'il ne fait pas

- Corriger à l'aveugle, ou masquer l'erreur : `catch` vide, valeur par défaut, `sleep`, retry, délai rallongé.
- Supprimer, ignorer ou affaiblir un test.
- Laisser l'instrumentation (logs, `dump`, `debugger`) en place.
- Faire le bisect ou les essais sur la branche par défaut.
- Toucher des données de production.
