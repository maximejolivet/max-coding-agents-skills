---
name: debug
description: Diagnostique et corrige un bug en remontant à sa cause racine - reproduction fiable d'abord, hypothèses classées et testées une par une, bisect git pour trouver le commit fautif, test de non-régression vu rouge puis vert, correctif minimal. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur signale un bug, une erreur, une exception, un test qui échoue, un comportement inattendu, une régression, ou invoque /max:debug.
---

# Débogage par la cause racine

Trouver **pourquoi** le bug existe avant de le corriger. Un correctif posé sur un symptôme, sans cause établie, revient sous une autre forme. Ne jamais deviner à coups d'essais : chaque action vérifie une hypothèse.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack en une ligne, puis charger `stacks/<stack>/INDEX.md` pour la nature **dev** (qui tire `core`) afin de connaître les pièges propres à la techno et à sa version. Sans ressource, le dire et s'en tenir aux conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## 1. Cadrer le symptôme

- Comportement **observé** contre comportement **attendu**, en une phrase chacun.
- Message d'erreur et trace complets, versions, environnement, fréquence (toujours, parfois, depuis quand).
- Lire l'issue liée si elle existe (`gh issue view`). Ne pas supposer ce qui n'est pas écrit : demander la pièce manquante plutôt que l'inventer.

## 2. Reproduire

- Obtenir une reproduction **minimale et déterministe** : une commande, un test ou une requête qui échoue à chaque fois.
- Bug intermittent : chercher ce qui varie (ordre, temps, concurrence, données, état partagé) et le figer ; relancer plusieurs fois pour mesurer le taux d'échec.
- Impossible à reproduire : le dire, lister ce qui manque (logs, données, config) et s'arrêter là. Ne pas corriger à l'aveugle.

## 3. Isoler

Réduire l'espace de recherche, du plus rapide au plus coûteux :

1. **Lire la trace** de bas en haut jusqu'au premier code du projet ; lire le code autour, pas seulement la ligne.
2. **Régression ?** Si cela marchait avant, `git bisect run <commande de repro>` désigne le commit fautif ; sinon `git log -S` / `git blame` sur la zone. Lancer le bisect sur une branche jetable, et `git bisect reset` à la fin.
3. **Réduire l'entrée** ou le code jusqu'à ce que le bug disparaisse : ce qui vient d'être retiré est la cause ou y mène.
4. **Observer** plutôt que supposer : logs temporaires, débogueur, `dump` de valeurs réelles aux frontières. Retirer cette instrumentation avant de finir.

Sur un gros projet, `max:codebase-surveyor` peut cartographier la zone en lecture seule ; les modifications restent dans la session principale.

## 4. Hypothèses

- Écrire 2 ou 3 hypothèses **classées par probabilité**, chacune avec le test qui la confirme ou l'écarte.
- Tester **une seule à la fois**, noter le résultat. Une hypothèse écartée est une information, pas un échec.
- La cause racine est établie quand on sait **expliquer le symptôme en entier**, y compris pourquoi il n'apparaît pas ailleurs. Sinon, continuer.
- Après 3 hypothèses réfutées, revenir à l'étape 1 : le cadrage est probablement faux.

## 5. Corriger

1. **Test de non-régression d'abord** (`/max:test`) : il reproduit le bug, on le **voit rouge** pour la bonne raison.
2. **Correctif minimal** sur la cause, pas sur le symptôme : pas de `try/catch` qui avale l'erreur, pas de valeur par défaut qui masque, pas de `sleep`.
3. Voir le test **vert**, puis relancer la suite complète, le linter et les types.
4. Chercher les **cas jumeaux** (`grep` du même motif ailleurs) ; les signaler ou les corriger dans un commit séparé.

## Format de la réponse

1. Symptôme : observé contre attendu.
2. Reproduction : la commande ou le test, et son résultat.
3. Cause racine : ce qui se passe, `fichier:ligne`, et le commit d'origine si trouvé.
4. Correctif : ce qui change, le test ajouté, la vérification réelle (nombres).
5. Risques, cas jumeaux et points non vérifiés.

## Hors périmètre

- Ne pas refactorer en passant : relève de `/max:refactor`.
- Ne jamais supprimer, ignorer ou affaiblir un test pour le faire passer.
- Ne pas masquer une erreur (catch vide, retry en boucle, timeout rallongé) en guise de correctif.
- Pas de `git push`, de merge, de `git reset --hard` ni de modification de données de production sans accord explicite ; le bisect et les essais se font sur une branche, jamais sur `main`.
- Retirer le code d'instrumentation (logs, `dump`, `debugger`) avant de rendre la main.
- La relecture relève de `/max:review`, les tests de `/max:test`, la PR de `/max:pull-request`.
