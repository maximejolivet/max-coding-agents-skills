---
name: perf
description: Améliore les performances en mesurant - définit une métrique et un budget, profile pour trouver le vrai goulot (requêtes N+1, rendu, bundle, E/S), applique un seul changement à la fois et prouve le gain par une mesure avant/après. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur signale une lenteur, veut optimiser une page, une requête, un build ou un bundle, améliorer un score Lighthouse ou les Core Web Vitals, ou invoque /max:perf.
---

# Optimiser en mesurant

Pas de mesure, pas d'optimisation. On optimise le **goulot réel**, pas celui qu'on soupçonne, et on ne garde un changement que si la mesure le justifie.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis charger `stacks/<stack>/INDEX.md` pour la nature **dev** (qui tire `core`) afin de connaître les outils de profilage et les pièges de la techno. Sans ressource, s'en tenir aux conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## 1. Définir la cible

- La **métrique** (temps de réponse p95, LCP, taille du bundle, durée du build, mémoire), le **chemin** concerné et le **budget** visé. Sans budget, en proposer un raisonnable et le valider.
- Pour le web : suivre `${CLAUDE_SKILL_DIR}/../../references/core-web-vitals-checklist.md`.

## 2. Mesurer l'état de départ

- Une mesure **reproductible** : même données, même machine, plusieurs passes (médiane, pas un seul essai). Noter l'environnement.
- Outils selon le cas : Lighthouse / DevTools (front), profileur du langage ou de la stack, `EXPLAIN` / journal des requêtes lentes (base), analyseur de bundle, `time` sur le build.

## 3. Trouver le goulot

Du plus fréquent au plus rare :

1. **Requêtes** : N+1, index manquant, `SELECT *`, absence de pagination, appels répétés dans une boucle.
2. **Réseau et E/S** : appels séquentiels qui pourraient être parallèles, absence de cache, charges utiles trop lourdes.
3. **Rendu / front** : rendu inutile, image non dimensionnée, JavaScript bloquant, bundle trop gros, polices.
4. **CPU / mémoire** : algorithme en O(n²), copies inutiles, fuites.

Un sous-agent en lecture seule (`max:codebase-surveyor`) peut cartographier le chemin chaud sur un gros projet ; les modifications restent dans la session principale.

## 4. Corriger, un changement à la fois

1. Un seul changement, ciblé sur le goulot identifié.
2. **Remesurer** dans les mêmes conditions. Garder si le gain est net et dépasse le bruit ; sinon revenir en arrière.
3. Vérifier que le comportement est intact (suite de tests, `/max:test`) : une optimisation ne change pas le résultat.
4. Noter le gain en chiffres : avant, après, écart.

## Format de la réponse

1. Métrique, budget, conditions de mesure.
2. Mesure de départ et goulot identifié (preuve : profil, plan d'exécution).
3. Changements, chacun avec sa mesure avant/après.
4. Résultat final contre le budget, et ce qui reste.

## Hors périmètre

- Pas d'optimisation prématurée ni de complexité ajoutée pour un gain non mesuré (cache, mémoïsation, dénormalisation).
- Ne jamais affaiblir une validation, une sécurité ou un test pour gagner du temps.
- Pas d'outil de profilage ni de dépendance installés sans accord ; pas de mesure sur la production sans accord.
- La relecture relève de `/max:review`, les tests de `/max:test`.
